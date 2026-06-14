<%--
 =============================================================================
 forYou.jsp  ——  AI 为你推荐（独立页面）

 从首页"为你推荐"入口进入，基于 AI 分析用户行为和偏好进行个性化推荐。
 展示内容：
   1. AI 兴趣画像（标签云）
   2. 类型筛选（全部/图书/课程/讲座）
   3. 推荐卡片网格（附带推荐理由）
 
 路由：/forYou（ForYouServlet 转发）
 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ebookBuy301.pojo.*, java.util.*, java.math.BigDecimal" %>
<%!
    private String ss(Object o) { return o != null ? o.toString() : ""; }
%>
<%
    String ctx = request.getContextPath();
    ArrayList<RecommendItem> items = (ArrayList<RecommendItem>) request.getAttribute("items");
    if (items == null) items = new ArrayList<>();
    String filterType = (String) request.getAttribute("filterType");
    if (filterType == null) filterType = "all";
    boolean isPersonal = request.getAttribute("isPersonal") != null && (Boolean) request.getAttribute("isPersonal");
    int totalCount = (Integer) (request.getAttribute("totalCount") != null ? request.getAttribute("totalCount") : items.size());
    String error = (String) request.getAttribute("error");

    // 用户兴趣画像
    @SuppressWarnings("unchecked")
    Map<String, Double> profile = (Map<String, Double>) request.getAttribute("userProfile");
    if (profile == null) profile = new LinkedHashMap<>();

    // 类型配置
    String[][] tc = {
        {"books",     "#4facfe", "#00f2fe", "图书", "📕", "linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)"},
        {"courses",   "#667eea", "#764ba2", "课程", "📖", "linear-gradient(135deg, #667eea 0%, #764ba2 100%)"},
        {"lectures",  "#f093fb", "#f5576c", "讲座", "🎙️", "linear-gradient(135deg, #f093fb 0%, #f5576c 100%)"},
    };
    Map<String, String[]> tMap = new LinkedHashMap<>();
    for (String[] t : tc) tMap.put(t[0], t);

    // 统计
    Map<String, Integer> cnts = new LinkedHashMap<>();
    cnts.put("all", totalCount);
    for (String[] t : tc) cnts.put(t[0], 0);
    for (RecommendItem it : items) {
        String tp = it.getType() != null ? it.getType() : "";
        String key = tp.endsWith("s") ? tp : tp + "s";
        if (cnts.containsKey(key)) cnts.put(key, cnts.get(key) + 1);
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>为你推荐 · 博雅书院</title>
    <style>
        :root {
            --deep: #060b14; --card: #0d1525; --card-h: #131d32;
            --text: #e5e9f0; --muted: #7b8ba8; --border: #1a2740;
            --accent: #4facfe; --accent2: #a78bfa;
        }
        * { margin:0; padding:0; box-sizing:border-box; }
        html { scroll-behavior:smooth; }

        body {
            background: var(--deep);
            color: var(--text);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            min-height: 100vh; overflow-y:auto; overflow-x:hidden;
            -webkit-font-smoothing: antialiased;
        }

        /* ── 星空 ── */
        .sf { position:fixed; inset:0; pointer-events:none; z-index:0; }
        .sd {
            position:absolute; width:2px; height:2px;
            background:rgba(255,255,255,.22); border-radius:50%;
            animation:tw 3s ease-in-out infinite; animation-delay:0s;
        }
        @keyframes tw {
            0%,100% { opacity:.1; transform:scale(1); }
            50% { opacity:.6; transform:scale(2); }
        }

        /* ── 容器 ── */
        .wrap { max-width:1340px; margin:0 auto; padding:0 24px 80px; position:relative; z-index:1; }

        /* ── Hero ── */
        .hero { text-align:center; padding:48px 20px 20px; }
        .hero h1 {
            font-size:36px; font-weight:800; letter-spacing:4px;
            background: linear-gradient(135deg, #e0e7ff, #7dd3fc 30%, #f472b6 70%, #e0e7ff);
            -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text;
        }
        .hero .sub { color:var(--muted); font-size:14px; letter-spacing:1px; margin-top:6px; }
        .hero .sub .ai-badge {
            display:inline-block; margin-left:8px; padding:2px 10px; border-radius:12px;
            font-size:11px; background:linear-gradient(135deg,rgba(79,172,254,.15),rgba(167,139,250,.1));
            border:1px solid rgba(79,172,254,.25); color:#7dd3fc; vertical-align:middle;
        }

        /* AI 兴趣标签云 */
        .tag-cloud {
            display:flex; justify-content:center; flex-wrap:wrap; gap:8px;
            margin-top:16px;
        }
        .tcloud-item {
            padding:6px 16px; border-radius:20px; font-size:12px; letter-spacing:.5px;
            border:1px solid var(--border); color:var(--muted);
            transition:all .25s; cursor:default;
        }
        .tcloud-item:hover { border-color:rgba(79,172,254,.3); color:#c0d8f0; }
        .tcloud-item .tw {
            font-size:10px; color:#7dd3fc; margin-left:4px; opacity:.7;
        }
        .no-tags { color:var(--muted); font-size:12px; opacity:.4; }

        /* ── 筛选 ── */
        .fbar { display:flex; justify-content:center; gap:8px; margin:28px 0 32px; flex-wrap:wrap; }
        .ftab {
            display:inline-flex; align-items:center; gap:6px;
            padding:9px 22px; border-radius:24px; font-size:13px; font-weight:500;
            background:rgba(255,255,255,.03); border:1px solid var(--border);
            color:var(--muted); cursor:pointer; text-decoration:none;
            transition:all .25s;
        }
        .ftab:hover { border-color:rgba(79,172,254,.3); color:#c0d8f0; background:rgba(79,172,254,.05); }
        .ftab.on { background:rgba(79,172,254,.1); border-color:rgba(79,172,254,.4); color:#7dd3fc; box-shadow:0 0 12px rgba(79,172,254,.08); }
        .fcnt { font-size:10px; padding:1px 7px; border-radius:10px; background:rgba(255,255,255,.05); }
        .ftab.on .fcnt { background:rgba(79,172,254,.15); color:#7dd3fc; }

        /* ── 卡片网格 ── */
        .grid {
            display:grid; grid-template-columns:repeat(auto-fill, minmax(300px, 1fr)); gap:20px;
        }
        .card {
            background:var(--card); border:1px solid var(--border);
            border-radius:16px; overflow:hidden;
            transition:all .35s cubic-bezier(.22,.61,.36,1);
            cursor:pointer; position:relative;
            animation:fadeUp .45s ease forwards; opacity:0;
            animation-delay:var(--ad,0s);
        }
        .card:hover {
            border-color:rgba(79,172,254,.35); background:var(--card-h);
            transform:translateY(-5px);
            box-shadow:0 14px 36px rgba(0,0,0,.3), 0 0 0 1px var(--tc) inset;
        }
        .card:active { transform:scale(.98); }
        @keyframes fadeUp { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }

        .card::before {
            content:''; position:absolute; top:0;left:0;right:0; height:3px;
            background:var(--tg); opacity:.5; transition:opacity .35s;
        }
        .card:hover::before { opacity:1; }

        .card-cover {
            height:130px; display:flex; align-items:center; justify-content:center;
            font-size:42px; position:relative; overflow:hidden;
        }
        .card-cover::after {
            content:''; position:absolute; inset:0; z-index:3;
            background:linear-gradient(180deg, rgba(255,255,255,.1) 0%, transparent 40%);
            pointer-events:none;
        }
        .card-cover img { transition:transform .4s cubic-bezier(.22,.61,.36,1); }
        .card:hover .card-cover img { transform:scale(1.06); }
        .card-badge {
            position:absolute; top:10px; right:10px;
            padding:3px 10px; border-radius:20px; font-size:10px; font-weight:600;
            background:rgba(0,0,0,.55); backdrop-filter:blur(6px);
            border:1px solid rgba(255,255,255,.08); z-index:5;
        }
        .card-badge.personal { color:#7dd3fc; }
        .card-badge.social { color:#c084fc; }
        .card-badge.hot { color:#fb7185; }
        .card-badge.trending { color:#f59e0b; }

        .card-body { padding:16px 18px 18px; }
        .card-type { display:flex; align-items:center; gap:6px; margin-bottom:6px; }
        .card-dot { width:8px; height:8px; border-radius:50%; background:var(--tc); box-shadow:0 0 6px var(--tc); }
        .card-tlabel { font-size:10px; color:var(--muted); letter-spacing:1px; }
        .card-title { font-size:15px; font-weight:700; line-height:1.4; margin-bottom:5px;
            display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; }
        .card-desc { font-size:12px; color:var(--muted); line-height:1.6; margin-bottom:10px;
            display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; }
        .card-reason {
            font-size:10px; color:rgba(167,139,250,.7); margin-bottom:10px;
            display:flex; align-items:center; gap:4px;
        }
        .card-meta { display:flex; align-items:center; gap:10px; font-size:11px; color:var(--muted); flex-wrap:wrap; }
        .card-meta span { display:inline-flex; align-items:center; gap:3px; }
        .card-rating { margin-left:auto; font-weight:600; color:#f59e0b; font-size:12px; }

        /* ── 空态 ── */
        .empty { text-align:center; padding:80px 20px; }
        .empty-icon { font-size:64px; margin-bottom:16px; opacity:.3; }
        .empty h3 { font-size:18px; margin-bottom:6px; }
        .empty p { color:var(--muted); font-size:13px; }

        /* ── Footer ── */
        .ftr {
            text-align:center; padding:44px 0 0;
            color:var(--muted); font-size:11px; letter-spacing:3px; opacity:.2;
        }

        @media (max-width:768px) {
            .hero { padding:32px 16px 16px; }
            .hero h1 { font-size:24px; letter-spacing:1px; }
            .grid { grid-template-columns:1fr; gap:14px; }
        }
    </style>
    <!-- ========== 浅色主题全局兜底覆盖 ========== -->
    <style>
        html[data-theme$="-light"],html[data-theme$="-light"] body{background:#e8dfcf!important;color:#3d3929!important}
        html[data-theme$="-light"] [class*="card"],html[data-theme$="-light"] [class*="box"],html[data-theme$="-light"] [class*="module"]{background:rgba(238,233,222,.92)!important;border-color:rgba(139,119,80,.07)!important}
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3,html[data-theme$="-light"] [class*="title"]{color:#3d3929!important}
        html[data-theme$="-light"] p,html[data-theme$="-light"] li,html[data-theme$="-light"] [class*="desc"],html[data-theme$="-light"] [class*="muted"]{color:#7a7360!important}
        html[data-theme$="-light"] a{color:#0071e3!important}
        html[data-theme$="-light"] input,html[data-theme$="-light"] textarea,html[data-theme$="-light"] select{background:rgba(238,233,222,.94)!important;border-color:rgba(139,119,80,.12)!important;color:#3d3929!important}
        html[data-theme$="-light"] [class*="header"],html[data-theme$="-light"] [class*="navbar"]{background:rgba(238,233,222,.94)!important;border-color:rgba(139,119,80,.07)!important}
        html[data-theme$="-light"] [class*="item"]{background:rgba(238,233,222,.72)!important}
        html[data-theme$="-light"] [class*="particle"],html[data-theme$="-light"] [class*="star"]{opacity:.15!important}
        html[data-theme$="-light"] span,html[data-theme$="-light"] label,html[data-theme$="-light"] div{color:#3d3929!important}
        html[data-theme$="-light"] button:not([class*="primary"]){color:#3d3929!important}
        html[data-theme$="-light"] svg,html[data-theme$="-light"] [class*="icon"]{color:#5c5540!important;fill:#5c5540!important}
        html[data-theme$="-light"] input::placeholder,html[data-theme$="-light"] textarea::placeholder{color:#968e78!important}
        html[data-theme$="-light"] [class*="tag"],html[data-theme$="-light"] [class*="badge"]{color:#3d3929!important;background:rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] [class*="toast"],[class*="notification"]{color:#3d3929!important;background:rgba(248,243,230,.96)!important}
        html[data-theme$="-light"] a{color:#2563eb!important}
    </style>

</head>
<body>
<div class="sf" id="sf"></div>

<div class="wrap">

    <!-- ═══════ Hero ═══════ -->
    <div class="hero">
        <h1>为 你 推 荐</h1>
        <p class="sub">
            <%= isPersonal ? "AI 分析了你的学习行为与偏好" : "博雅精选 · 实时热度排行" %>
            <span class="ai-badge"><%= isPersonal ? "🤖 AI 驱动" : "🔥 热门趋势" %></span>
        </p>

        <!-- AI 兴趣画像标签云 -->
        <% if (isPersonal && !profile.isEmpty()) { %>
        <div class="tag-cloud">
            <% 
                int ti = 0;
                for (Map.Entry<String, Double> e : profile.entrySet()) {
                    if (ti++ >= 8) break;
                    double w = e.getValue();
                    double fontSize = 11 + (w / 100.0) * 6;
                    double opacity = 0.5 + (w / 100.0) * 0.5;
            %>
            <span class="tcloud-item" style="font-size:<%= String.format("%.0f", fontSize) %>px; opacity:<%= String.format("%.2f", opacity) %>;">
                <%= e.getKey() %><span class="tw"><%= String.format("%.0f", w) %>%</span>
            </span>
            <% } %>
        </div>
        <% } else if (!isPersonal) { %>
        <div class="tag-cloud" style="margin-top:12px;">
            <span class="no-tags">🔐 登录后 AI 将为你构建专属兴趣画像</span>
        </div>
        <% } %>
    </div>

    <!-- ═══════ 筛选 ═══════ -->
    <div class="fbar">
        <a href="<%= ctx %>/forYou" class="ftab <%= "all".equals(filterType) ? "on" : "" %>">🔮 全部<span class="fcnt"><%= totalCount %></span></a>
        <% for (String[] t : tc) { int n = cnts.getOrDefault(t[0], 0); %>
        <a href="<%= ctx %>/forYou?filterType=<%= t[0] %>" class="ftab <%= t[0].equals(filterType) ? "on" : "" %>">
            <%= t[3] %> <%= t[4] %><span class="fcnt"><%= n %></span>
        </a>
        <% } %>
    </div>

    <!-- ═══════ 错误/空态 ═══════ -->
    <% if (error != null) { %>
    <div class="empty"><div class="empty-icon">⚠️</div><h3>加载失败</h3><p><%= error %></p></div>
    <% } else if (items.isEmpty()) { %>
    <div class="empty"><div class="empty-icon">🪐</div><h3>暂无推荐</h3><p>换个分类试试吧</p></div>
    <% } else { %>

    <!-- ═══════ 卡片网格 ═══════ -->
    <div class="grid">
    <%
        int ix = 0;
        for (RecommendItem it : items) {
            String tp = it.getType() != null ? it.getType() : "courses";
            String key = tp.endsWith("s") ? tp : tp + "s";
            String[] cfg = tMap.getOrDefault(key, tc[0]);
            String color = cfg[1], cEnd = cfg[2], tLabel = cfg[3], tEmoji = cfg[4], grad = cfg[5];
            String badge = ss(it.getBadge());
            String r = it.getRating() != null ? String.format("%.1f", it.getRating()) : "";
            String reason = it.getMetaInfo();  // metaInfo now contains AI reason
            double d = 0.05 * (ix % 8);
    %>
    <div class="card" style="--tc:#<%= color %>; --tg:<%= grad %>; --ad:<%= String.format("%.2f",d) %>s;"
         onclick="go('<%= ss(it.getType()) %>','<%= ss(it.getRefId()) %>')">
    <%
            String coverImg = ss(it.getCoverImage());
    %>
        <div class="card-cover" style="background:<%= grad %>;opacity:.85;">
            <% if (!coverImg.isEmpty()) { %>
            <img src="<%= ctx + coverImg %>" alt=""
                 style="width:100%;height:100%;object-fit:cover;position:absolute;top:0;left:0;z-index:2;"
                 onerror="this.style.display='none';">
            <% } %>
            <span style="font-size:42px;position:relative;z-index:1;"><%= tEmoji %></span>
            <% if (!badge.isEmpty()) { %><span class="card-badge <%= badge %>" style="z-index:5;"><%= badge %></span><% } %>
        </div>
        <div class="card-body">
            <div class="card-type"><span class="card-dot"></span><span class="card-tlabel"><%= tLabel %></span></div>
            <div class="card-title"><%= ss(it.getTitle()) %></div>
            <div class="card-desc"><%= ss(it.getDescription()) %></div>
            <% if (reason != null && reason.contains("根据")) { %>
            <div class="card-reason">🤖 <%= reason %></div>
            <% } %>
            <div class="card-meta">
                <span>🎓 <%= ss(it.getAuthor()) %></span>
                <% if (it.getMetaInfo() != null && !reason.startsWith("根据")) { %>
                <span>⏱️ <%= it.getMetaInfo() %></span>
                <% } %>
                <% if (!r.isEmpty()) { %><span class="card-rating">⭐ <%= r %></span><% } %>
            </div>
        </div>
    </div>
    <% ix++; } %>
    </div>
    <% } %>

    <div class="ftr">✦&nbsp;&nbsp;B O Y A&nbsp;&nbsp;·&nbsp;&nbsp;A I&nbsp;&nbsp;推 荐&nbsp;&nbsp;✦</div>
</div>

<script>
    var ctx = '<%= ctx %>';
    function go(type, refId) {
        var url;
        if (type === 'books' || type === 'book') {
            url = 'bookDetail?bookId=' + encodeURIComponent(refId);
            title = '图书详情';
        } else if (type === 'lectures' || type === 'lecture') {
            url = 'lecturePage';
            title = '前沿讲坛';
        } else {
            url = 'pages/courses.jsp';
            title = '课程详情';
        }
        try {
            window.parent.postMessage({type:'navigate', url:url, title:title}, '*');
        } catch(e) {
            window.location.href = ctx + '/' + url;
        }
    }
    // 星空
    (function(){
        var f=document.getElementById('sf'), frag=document.createDocumentFragment();
        for(var i=0;i<60;i++){
            var d=document.createElement('div'); d.className='sd';
            d.style.left=Math.random()*100+'%'; d.style.top=Math.random()*100+'%';
            d.style.animationDuration=(2+Math.random()*3)+'s';
            d.style.animationDelay=Math.random()*4+'s';
            frag.appendChild(d);
        }
        f.appendChild(frag);
    })();
</script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
