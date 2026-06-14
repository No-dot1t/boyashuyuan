<%--
 =============================================================================
 creativeWorkshop.jsp
 =============================================================================

 用途      功能页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList, java.util.Map" %>
<%
    ArrayList<Map<String, Object>> works = (ArrayList<Map<String, Object>>) request.getAttribute("works");
    if (works == null) works = new ArrayList<>();
    Map<String, Integer> stats = (Map<String, Integer>) request.getAttribute("stats");
    if (stats == null) stats = new java.util.HashMap<>();
    String currentCategory = (String) request.getAttribute("currentCategory");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>博雅书院 | 创意工坊</title>
    <link rel="stylesheet" href="<%= ctx %>/CSS/index.css">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{background:var(--bg-space,#0a0b1a);color:#fff;font-family:'Segoe UI','PingFang SC',sans-serif;min-height:100vh}
        @keyframes fadeInUp{from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)}}
        @keyframes shimmer{0%{background-position:-200% 0}100%{background-position:200% 0}}
        @keyframes floatY{0%,100%{transform:translateY(0)}50%{transform:translateY(-5px)}}
        .workshop-container{max-width:1200px;margin:0 auto;padding:30px 20px}
        .workshop-header{text-align:center;margin-bottom:30px;animation:fadeInUp .6s ease-out}
        .workshop-header h1{font-size:2.2rem;margin-bottom:10px;background:linear-gradient(135deg,#fff 0%,#a855f7 50%,#fff 100%);background-size:200% auto;-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;animation:shimmer 3s linear infinite}
        .workshop-header p{color:rgba(255,255,255,0.5);font-size:1rem}
        .back-btn{display:inline-flex;align-items:center;gap:8px;padding:10px 24px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:10px;color:rgba(255,255,255,0.7);text-decoration:none;cursor:pointer;transition:all .3s;margin-bottom:20px;font-size:.92rem}
        .back-btn:hover{background:rgba(0,242,255,0.12);border-color:rgba(0,242,255,0.3);color:#fff;transform:translateX(-4px)}
        .stats-bar{display:flex;gap:15px;justify-content:center;margin-bottom:25px;flex-wrap:wrap;animation:fadeInUp .6s ease-out .1s both}
        .stat-item{padding:12px 22px;background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.06);border-radius:12px;text-align:center;transition:all .3s}
        .stat-item:hover{border-color:rgba(168,85,247,0.3);background:rgba(168,85,247,0.06)}
        .stat-item .sval{font-size:1.3rem;font-weight:700;color:var(--glow-primary,#00f2ff)}
        .stat-item .slabel{font-size:.72rem;color:rgba(255,255,255,0.4);margin-top:3px}
        .filter-bar{display:flex;gap:10px;justify-content:center;margin-bottom:30px;flex-wrap:wrap;animation:fadeInUp .6s ease-out .15s both}
        .filter-btn{padding:9px 22px;background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.07);border-radius:12px;color:rgba(255,255,255,0.6);cursor:pointer;font-size:.88rem;transition:all .4s cubic-bezier(.175,.885,.32,1.275);text-decoration:none}
        .filter-btn.active,.filter-btn:hover{background:rgba(168,85,247,0.12);border-color:rgba(168,85,247,0.3);color:#fff;transform:translateY(-2px);box-shadow:0 4px 15px rgba(0,0,0,0.15)}
        .works-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:20px;animation:fadeInUp .7s ease-out .25s both}
        .work-card{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:18px;overflow:hidden;transition:all .4s cubic-bezier(.175,.885,.32,1.275);cursor:pointer;position:relative}
        .work-card::after{content:'';position:absolute;bottom:0;left:0;right:0;height:3px;background:linear-gradient(90deg,#a855f7,#00f2ff);transform:scaleX(0);transition:transform .4s;transform-origin:left}
        .work-card:hover{transform:translateY(-8px);border-color:rgba(168,85,247,0.25);box-shadow:0 15px 40px rgba(0,0,0,0.3),0 0 40px rgba(168,85,247,0.06)}
        .work-card:hover::after{transform:scaleX(1)}
        .work-card:hover .work-cover{animation:floatY 3s ease-in-out infinite}
        .work-cover{height:180px;display:flex;align-items:center;justify-content:center;font-size:3rem;transition:transform .4s}
        .work-cover.c-3d{background:linear-gradient(145deg,#1a2840,#0f2040)}
        .work-cover.c-animation{background:linear-gradient(145deg,#2a1a3e,#1f1040)}
        .work-cover.c-digital{background:linear-gradient(145deg,#1a3e2a,#10402a)}
        .work-cover.c-design{background:linear-gradient(145deg,#3e2a1a,#402010)}
        .work-body{padding:20px}
        .work-body .work-cat{font-size:.72rem;padding:3px 8px;border-radius:6px;background:rgba(168,85,247,0.1);color:#a855f7;display:inline-block;margin-bottom:8px;border:1px solid rgba(168,85,247,0.15)}
        .work-body h3{font-size:1.02rem;margin-bottom:6px}
        .work-body p{font-size:.84rem;color:rgba(255,255,255,0.45);line-height:1.5;margin-bottom:12px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
        .work-footer{display:flex;justify-content:space-between;align-items:center;font-size:.78rem;color:rgba(255,255,255,0.35)}
        .work-footer .like-btn{display:flex;align-items:center;gap:4px;cursor:pointer;transition:all .3s;padding:5px 10px;border-radius:8px}
        .work-footer .like-btn:hover{color:#ef4444;background:rgba(239,68,68,0.1);transform:scale(1.05)}
        .work-footer .like-btn.liked{color:#ef4444}
        .detail-modal{display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.75);z-index:1000;justify-content:center;align-items:center;backdrop-filter:blur(6px)}
        .detail-modal.active{display:flex}
        .detail-panel{background:rgba(255,255,255,0.03);border:1px solid rgba(168,85,247,0.2);border-radius:20px;max-width:600px;width:90%;max-height:80vh;overflow-y:auto;position:relative;box-shadow:0 25px 60px rgba(0,0,0,0.5);animation:fadeInUp .3s ease-out}
        .detail-cover{height:200px;display:flex;align-items:center;justify-content:center;font-size:4rem;border-radius:20px 20px 0 0}
        .detail-body{padding:25px}
        .detail-body h2{font-size:1.35rem;margin-bottom:10px}
        .detail-body .dmeta{display:flex;gap:15px;margin-bottom:15px;font-size:.82rem;color:rgba(255,255,255,0.4);flex-wrap:wrap}
        .detail-body .ddesc{color:rgba(255,255,255,0.6);line-height:1.8;margin-bottom:20px}
        .detail-close{position:absolute;top:15px;right:20px;background:rgba(0,0,0,0.5);border:1px solid rgba(255,255,255,0.1);color:#fff;font-size:1.2rem;cursor:pointer;width:36px;height:36px;border-radius:50%;display:flex;align-items:center;justify-content:center;transition:all .3s}
        .detail-close:hover{background:rgba(239,68,68,0.3);border-color:rgba(239,68,68,0.4);transform:rotate(90deg)}
        ::-webkit-scrollbar{width:6px}::-webkit-scrollbar-track{background:rgba(255,255,255,0.02)}::-webkit-scrollbar-thumb{background:rgba(168,85,247,0.2);border-radius:3px}
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
    <div class="workshop-container">
        <a class="back-btn" href="<%= ctx %>/campus3d">← 返回元宇宙校园</a>
        <div class="workshop-header">
            <h1><span class="glow-text">🎨</span> 创意工坊</h1>
            <p>展示才华、激发灵感的创意空间</p>
        </div>

        <div class="stats-bar">
            <div class="stat-item"><div class="sval"><%= stats.getOrDefault("total",0) %></div><div class="slabel">作品总数</div></div>
            <div class="stat-item"><div class="sval"><%= stats.getOrDefault("3d",0) %></div><div class="slabel">3D建模</div></div>
            <div class="stat-item"><div class="sval"><%= stats.getOrDefault("animation",0) %></div><div class="slabel">动画</div></div>
            <div class="stat-item"><div class="sval"><%= stats.getOrDefault("digital",0) %></div><div class="slabel">数字艺术</div></div>
            <div class="stat-item"><div class="sval"><%= stats.getOrDefault("design",0) %></div><div class="slabel">设计</div></div>
        </div>

        <div class="filter-bar">
            <a class="filter-btn <%= "all".equals(currentCategory) ? "active" : "" %>" href="<%= ctx %>/creativeWorkshop?category=all">全部作品</a>
            <a class="filter-btn <%= "3d".equals(currentCategory) ? "active" : "" %>" href="<%= ctx %>/creativeWorkshop?category=3d">3D建模</a>
            <a class="filter-btn <%= "animation".equals(currentCategory) ? "active" : "" %>" href="<%= ctx %>/creativeWorkshop?category=animation">动画</a>
            <a class="filter-btn <%= "digital".equals(currentCategory) ? "active" : "" %>" href="<%= ctx %>/creativeWorkshop?category=digital">数字艺术</a>
            <a class="filter-btn <%= "design".equals(currentCategory) ? "active" : "" %>" href="<%= ctx %>/creativeWorkshop?category=design">设计</a>
        </div>

        <div class="works-grid">
            <% for (Map<String, Object> w : works) {
                String cat = (String) w.get("category");
                String name = (String) w.get("name");
            %>
            <div class="work-card" onclick='showWorkDetail(this)' data-name="<%= name %>" data-author="<%= w.get("author") %>"
                 data-cat="<%= w.get("categoryLabel") %>" data-desc="<%= w.get("description") %>" data-date="<%= w.get("date") %>" data-likes="<%= w.get("likes") %>">
                <div class="work-cover c-<%= cat %>">
                    <%= "3d".equals(cat) ? "🎮" : "animation".equals(cat) ? "🎬" : "digital".equals(cat) ? "🖥️" : "✏️" %>
                </div>
                <div class="work-body">
                    <span class="work-cat"><%= w.get("categoryLabel") %></span>
                    <h3><%= name %></h3>
                    <p><%= w.get("description") %></p>
                    <div class="work-footer">
                        <span>👤 <%= w.get("author") %></span>
                        <span class="like-btn" onclick="event.stopPropagation();toggleLike(this,<%= w.get("likes") %>)">❤️ <span><%= w.get("likes") %></span></span>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </div>

    <div class="detail-modal" id="workDetail">
        <div class="detail-panel">
            <button class="detail-close" onclick="document.getElementById('workDetail').classList.remove('active')">&times;</button>
            <div class="detail-cover" id="workDetailCover">🎨</div>
            <div class="detail-body">
                <h2 id="workDetailName">作品名称</h2>
                <div class="dmeta">
                    <span id="workDetailAuthor">👤 作者</span>
                    <span id="workDetailCat">🏷️ 类型</span>
                    <span id="workDetailDate">📅 日期</span>
                </div>
                <p class="ddesc" id="workDetailDesc">作品描述</p>
                <button style="width:100%;padding:12px;background:linear-gradient(135deg,#a855f7,#7c3aed);border:none;border-radius:10px;color:#fff;font-size:.95rem;cursor:pointer" onclick="showToast('👍 已点赞！')">❤️ 为作品点赞</button>
            </div>
        </div>
    </div>

    <script>
    function showWorkDetail(el) {
        var icons = {'3d':'🎮','animation':'🎬','digital':'🖥️','design':'✏️'};
        document.getElementById('workDetailCover').textContent = icons[el.getAttribute('data-cat')] || '🎨';
        document.getElementById('workDetailName').textContent = el.getAttribute('data-name');
        document.getElementById('workDetailAuthor').textContent = '👤 ' + el.getAttribute('data-author');
        document.getElementById('workDetailCat').textContent = '🏷️ ' + el.getAttribute('data-cat');
        document.getElementById('workDetailDate').textContent = '📅 ' + el.getAttribute('data-date');
        document.getElementById('workDetailDesc').textContent = el.getAttribute('data-desc');
        document.getElementById('workDetail').classList.add('active');
    }
    function toggleLike(el, n) {
        el.classList.toggle('liked');
        var span = el.querySelector('span');
        var liked = el.classList.contains('liked');
        span.textContent = liked ? parseInt(n)+1 : n;
        el.querySelector('span').previousSibling.textContent = liked ? '❤️' : '🤍';

        // 持久化点赞状态到 localStorage
        var workId = el.getAttribute('data-work-id') || el.closest('.work-card').getAttribute('data-work-id');
        if (workId) {
            var likes = JSON.parse(localStorage.getItem('boya_workshop_likes') || '{}');
            likes['work_' + workId] = liked;
            localStorage.setItem('boya_workshop_likes', JSON.stringify(likes));
        }
    }

    // 页面加载时恢复点赞状态
    (function restoreLikes() {
        var likes = JSON.parse(localStorage.getItem('boya_workshop_likes') || '{}');
        document.querySelectorAll('.work-like-btn').forEach(function(btn) {
            var workCard = btn.closest('.work-card');
            var workId = workCard ? workCard.getAttribute('data-work-id') : null;
            if (workId && likes['work_' + workId]) {
                btn.classList.add('liked');
                var span = btn.querySelector('span');
                if (span) {
                    var n = parseInt(span.textContent) || 0;
                    span.textContent = n + 1;
                }
                var beforeSpan = btn.querySelector('span').previousSibling;
                if (beforeSpan) beforeSpan.textContent = '❤️';
            }
        });
    })();
    function showToast(msg) {
        var t = document.createElement('div');
        t.textContent = msg;
        t.style.cssText = 'position:fixed;top:20px;left:50%;transform:translateX(-50%);padding:12px 24px;background:linear-gradient(135deg,#1a3050,#162540);border:1px solid rgba(0,242,255,0.3);border-radius:10px;color:#fff;z-index:9999;font-size:.95rem;box-shadow:0 4px 20px rgba(0,0,0,0.4);opacity:0;transition:opacity .3s';
        document.body.appendChild(t);
        setTimeout(function(){t.style.opacity='1'},10);
        setTimeout(function(){t.style.opacity='0';setTimeout(function(){t.remove()},300)},2500);
    }
    document.getElementById('workDetail').addEventListener('click', function(e) {
        if (e.target === this) this.classList.remove('active');
    });
    </script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
