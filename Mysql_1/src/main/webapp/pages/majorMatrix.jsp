<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.ebookBuy301.pojo.Major" %>
<%
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    ArrayList<Major> majors = (ArrayList<Major>) request.getAttribute("majors");
    if (majors == null) majors = new ArrayList<>();

    Map<String, List<Major>> groups = new LinkedHashMap<>();
    for (Major m : majors) {
        String cat = m.getCategory() != null ? m.getCategory() : "其他";
        groups.computeIfAbsent(cat, k -> new ArrayList<>()).add(m);
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>学域矩阵 · 博雅书院</title>
    <style>
        :root {
            --bg-deep: #060b14;
            --bg-card: #0d1525;
            --bg-card-hover: #131d32;
            --text: #e5e9f0;
            --text-muted: #7b8ba8;
            --border: #1a2740;
            --border-hover: #2d4070;
            /* 分类主题色 */
            --cat-eng: #4facfe;
            --cat-sci: #2dd4bf;
            --cat-hum: #f59e0b;
            --cat-art: #f472b6;
            --cat-soc: #a78bfa;
            --cat-cross: #fb7185;
            --cat-med: #34d399;
            --cat-agri: #a3e635;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html { scroll-behavior: smooth; }

        body {
            background: var(--bg-deep);
            color: var(--text);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", "Noto Sans SC", sans-serif;
            min-height: 100vh;
            overflow-y: auto;
            overflow-x: hidden;
            -webkit-font-smoothing: antialiased;
        }

        /* ========== 星空粒子背景 ========== */
        .starfield {
            position: fixed; inset: 0; pointer-events: none; z-index: 0;
        }
        .star-dot {
            position: absolute;
            width: 2px; height: 2px;
            background: rgba(255,255,255,0.3);
            border-radius: 50%;
            animation: twinkle 3s ease-in-out infinite;
            animation-delay: 0s;
        }
        @keyframes twinkle {
            0%, 100% { opacity: 0.15; transform: scale(1); }
            50% { opacity: 0.7; transform: scale(2.5); }
        }

        /* ========== 主容器 ========== */
        .container {
            max-width: 1280px;
            margin: 0 auto;
            padding: 0 24px 80px;
            position: relative;
            z-index: 1;
        }

        /* ========== Hero 区域 ========== */
        .hero {
            text-align: center;
            padding: 60px 20px 50px;
            position: relative;
        }
        .hero-ring {
            position: absolute;
            top: 50%; left: 50%;
            transform: translate(-50%, -50%);
            width: 320px; height: 320px;
            border-radius: 50%;
            border: 1px solid rgba(79,172,254,0.08);
            animation: ringPulse 4s ease-in-out infinite;
            pointer-events: none;
        }
        .hero-ring:nth-child(2) {
            width: 400px; height: 400px;
            animation-delay: 1s;
            border-color: rgba(167,139,250,0.06);
        }
        @keyframes ringPulse {
            0%, 100% { transform: translate(-50%, -50%) scale(1); opacity: 0.4; }
            50% { transform: translate(-50%, -50%) scale(1.12); opacity: 0.8; }
        }
        .hero-icon {
            width: 90px; height: 90px;
            margin: 0 auto 24px;
            background: radial-gradient(circle, rgba(79,172,254,0.18) 0%, transparent 70%);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 42px;
            position: relative;
            z-index: 1;
        }
        .hero h1 {
            font-size: 38px; font-weight: 800;
            letter-spacing: 4px;
            background: linear-gradient(135deg, #e0e7ff 0%, #7dd3fc 30%, #a78bfa 70%, #e0e7ff 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 10px;
            position: relative; z-index: 1;
        }
        .hero .subtitle {
            color: var(--text-muted);
            font-size: 15px;
            letter-spacing: 1px;
            position: relative; z-index: 1;
        }

        /* 统计栏 */
        .stats-row {
            display: flex; justify-content: center; gap: 48px;
            margin-top: 30px;
            position: relative; z-index: 1;
        }
        .stat-card {
            text-align: center;
            background: rgba(255,255,255,0.03);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 18px 28px;
            min-width: 100px;
            transition: all 0.3s;
        }
        .stat-card:hover {
            border-color: rgba(79,172,254,0.3);
            background: rgba(79,172,254,0.05);
            transform: translateY(-2px);
        }
        .stat-num {
            font-size: 32px; font-weight: 800;
            background: linear-gradient(135deg, #4facfe, #a78bfa);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .stat-label {
            font-size: 12px; color: var(--text-muted);
            letter-spacing: 2px; margin-top: 4px;
        }

        /* ========== 分类区块 ========== */
        .category-block {
            margin-bottom: 52px;
        }
        .cat-header {
            display: flex; align-items: center; gap: 14px;
            margin-bottom: 24px;
            padding-bottom: 14px;
            border-bottom: 1px solid var(--border);
            position: relative;
        }
        .cat-header::after {
            content: '';
            position: absolute;
            bottom: -1px; left: 0;
            width: 60px; height: 2px;
            border-radius: 2px;
            background: var(--cat-color);
        }
        .cat-dot {
            width: 12px; height: 12px;
            border-radius: 50%;
            background: var(--cat-color);
            box-shadow: 0 0 12px var(--cat-color);
            flex-shrink: 0;
        }
        .cat-name {
            font-size: 19px; font-weight: 700;
            letter-spacing: 1px;
            color: var(--text);
        }
        .cat-badge {
            margin-left: auto;
            font-size: 12px; color: var(--text-muted);
            padding: 4px 12px;
            background: rgba(255,255,255,0.03);
            border: 1px solid var(--border);
            border-radius: 20px;
        }

        /* ========== 学域卡片网格 ========== */
        .matrix-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }

        .major-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 18px;
            padding: 26px;
            cursor: pointer;
            transition: all 0.35s cubic-bezier(0.22, 0.61, 0.36, 1);
            position: relative;
            overflow: hidden;
            animation: fadeUp 0.5s ease forwards;
            opacity: 0;
            animation-delay: var(--ani-delay, 0s);
        }
        .major-card:hover {
            border-color: var(--border-hover);
            background: var(--bg-card-hover);
            transform: translateY(-6px);
            box-shadow: 0 16px 40px rgba(0,0,0,0.35), 0 0 0 1px var(--cat-color) inset;
        }
        .major-card:active { transform: scale(0.98); }

        /* 顶部光效 */
        .major-card::before {
            content: '';
            position: absolute;
            top: -1px; left: 20px; right: 20px;
            height: 2px;
            border-radius: 2px;
            background: var(--cat-color);
            opacity: 0;
            transition: opacity 0.35s;
        }
        .major-card:hover::before {
            opacity: 0.7;
            left: 0; right: 0;
            box-shadow: 0 0 20px var(--cat-color);
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(24px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* 卡片内容 */
        .card-top {
            display: flex; align-items: flex-start; gap: 16px;
            margin-bottom: 14px;
        }
        .major-icon-wrap {
            width: 54px; height: 54px;
            border-radius: 15px;
            display: flex; align-items: center; justify-content: center;
            font-size: 28px;
            flex-shrink: 0;
            position: relative;
            overflow: hidden;
        }
        .major-icon-wrap::after {
            content: '';
            position: absolute; inset: 0;
            background: linear-gradient(135deg, rgba(255,255,255,0.15) 0%, transparent 50%);
        }
        .card-info { flex: 1; min-width: 0; }
        .major-title {
            font-size: 17px; font-weight: 700; color: var(--text);
            line-height: 1.4; margin-bottom: 2px;
        }
        .major-code {
            font-size: 11px; color: var(--text-muted);
            font-family: "SF Mono", "Fira Code", "Consolas", monospace;
            letter-spacing: 1px;
        }
        .major-desc {
            font-size: 13px; color: var(--text-muted);
            line-height: 1.7; margin-bottom: 16px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .card-footer {
            display: flex; align-items: center; gap: 8px;
            flex-wrap: wrap;
        }
        .tag {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 4px 12px; border-radius: 20px;
            font-size: 11px; font-weight: 500;
            letter-spacing: 0.5px;
            border: 1px solid var(--border);
            color: var(--text-muted);
        }
        .tag-inter {
            border-color: rgba(251,113,133,0.25);
            background: rgba(251,113,133,0.1);
            color: #fb7185;
        }
        .tag-degree {
            border-color: rgba(79,172,254,0.2);
            background: rgba(79,172,254,0.08);
            color: #7dd3fc;
        }
        .card-arrow {
            margin-left: auto;
            display: flex; align-items: center; gap: 4px;
            font-size: 13px; color: var(--text-muted);
            transition: all 0.3s;
            opacity: 0.5;
        }
        .major-card:hover .card-arrow {
            color: var(--cat-color);
            opacity: 1;
            gap: 8px;
        }

        /* ========== 空状态 ========== */
        .empty-state {
            text-align: center; padding: 80px 20px;
        }
        .empty-icon { font-size: 72px; margin-bottom: 20px; opacity: 0.3; }
        .empty-state h3 {
            font-size: 20px; color: var(--text);
            margin-bottom: 8px;
        }
        .empty-state p { color: var(--text-muted); font-size: 14px; }

        /* ========== 底部装饰 ========== */
        .footer-glow {
            text-align: center; padding: 40px 0 0;
            color: var(--text-muted); font-size: 12px;
            letter-spacing: 3px; opacity: 0.3;
        }

        /* ========== 响应式 ========== */
        @media (max-width: 768px) {
            .hero { padding: 40px 16px 30px; }
            .hero h1 { font-size: 26px; letter-spacing: 2px; }
            .hero-ring { display: none; }
            .stats-row { gap: 16px; flex-wrap: wrap; }
            .stat-card { padding: 14px 20px; min-width: 80px; }
            .stat-num { font-size: 24px; }
            .matrix-grid { grid-template-columns: 1fr; gap: 14px; }
            .major-card { padding: 20px; }
        }

    </style>
    <!-- ========== 浅色主题 · 学域矩阵全覆盖 ========== -->
    <style>
        /* ── CSS变量覆写 ── */
        html[data-theme$="-light"]{
            --bg-deep:#e8dfcf;--bg-card:rgba(238,233,222,.88);--bg-card-hover:rgba(243,239,228,.95);
            --text:#3d3929;--text-muted:#7a7360;--border:rgba(139,119,80,.08);--border-hover:rgba(37,99,235,.15);
        }
        /* 基础 + 星空隐藏 */
        html[data-theme$="-light"] body{background:linear-gradient(170deg,#e9e2d2,#ede5d3 40%,#e4dbca)!important;color:#3d3929!important}
        html[data-theme$="-light"] .star-dot{background:rgba(139,119,80,.2)!important}
        /* Hero */
        html[data-theme$="-light"] .hero-ring{border-color:rgba(37,99,235,.08)!important}
        html[data-theme$="-light"] .hero-ring:nth-child(2){border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .hero-icon{background:radial-gradient(circle,rgba(37,99,235,.12) 0%,transparent 70%)!important}
        html[data-theme$="-light"] .hero h1{background:linear-gradient(135deg,#3d3929,#2563eb 35%,#7c3aed 70%,#3d3929)!important;-webkit-background-clip:text!important;background-clip:text!important;-webkit-text-fill-color:transparent!important}
        html[data-theme$="-light"] .hero .subtitle{color:#7a7360!important}
        /* 统计卡片 */
        html[data-theme$="-light"] .stat-card{background:rgba(238,233,222,.7)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .stat-card:hover{border-color:rgba(37,99,235,.15)!important;background:rgba(37,99,235,.03)!important}
        html[data-theme$="-light"] .stat-num{background:linear-gradient(135deg,#2563eb,#7c3aed)!important;-webkit-background-clip:text!important;background-clip:text!important;-webkit-text-fill-color:transparent!important}
        html[data-theme$="-light"] .stat-label{color:#7a7360!important}
        /* 分类区块 */
        html[data-theme$="-light"] .cat-header{border-bottom-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .cat-name{color:#3d3929!important}
        html[data-theme$="-light"] .cat-badge{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.06)!important;color:#7a7360!important}
        /* 学域卡片 */
        html[data-theme$="-light"] .major-card{background:linear-gradient(145deg,rgba(238,233,222,.85),rgba(243,239,228,.9))!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .major-card:hover{background:rgba(243,239,228,.95)!important;border-color:var(--cat-color)!important;box-shadow:0 12px 36px rgba(139,119,80,.12),0 0 0 1px var(--cat-color) inset!important}
        html[data-theme$="-light"] .major-icon-wrap::after{background:linear-gradient(135deg,rgba(255,255,255,.12) 0%,transparent 50%)!important}
        html[data-theme$="-light"] .major-title{color:#3d3929!important}
        html[data-theme$="-light"] .major-code{color:#7a7360!important}
        html[data-theme$="-light"] .major-desc{color:#7a7360!important}
        /* 标签 */
        html[data-theme$="-light"] .tag{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.06)!important;color:#7a7360!important}
        html[data-theme$="-light"] .tag-inter{border-color:rgba(220,60,80,.15)!important;background:rgba(220,60,80,.06)!important;color:#c03850!important}
        html[data-theme$="-light"] .tag-degree{border-color:rgba(37,99,235,.12)!important;background:rgba(37,99,235,.05)!important;color:#2563eb!important}
        /* 箭头 */
        html[data-theme$="-light"] .card-arrow{color:#7a7360!important}
        /* 空状态 */
        html[data-theme$="-light"] .empty-state h3{color:#3d3929!important}
        html[data-theme$="-light"] .empty-state p{color:#7a7360!important}
        /* 底部 */
        html[data-theme$="-light"] .footer-glow{color:#7a7360!important}
        /* 通用 */
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3{color:#3d3929!important}
    </style>
</head>
<body>

<!-- 星空粒子背景 -->
<div class="starfield" id="starfield"></div>

<div class="container">

    <!-- ========== Hero ========== -->
    <div class="hero">
        <div class="hero-ring"></div>
        <div class="hero-ring"></div>
        <div class="hero-icon">🔭</div>
        <h1>学 域 矩 阵</h1>
        <p class="subtitle">跨越学科边界 · 探索知识宇宙</p>
        <div class="stats-row">
            <div class="stat-card">
                <div class="stat-num"><%= majors.size() %></div>
                <div class="stat-label">学 域</div>
            </div>
            <div class="stat-card">
                <div class="stat-num"><%= groups.size() %></div>
                <div class="stat-label">分 类</div>
            </div>
        </div>
    </div>

    <!-- ========== 错误 / 空状态 ========== -->
    <% if (request.getAttribute("error") != null) { %>
    <div class="empty-state">
        <div class="empty-icon">⚠️</div>
        <h3>数据加载失败</h3>
        <p><%= request.getAttribute("error") %></p>
    </div>
    <% } else if (majors.isEmpty()) { %>
    <div class="empty-state">
        <div class="empty-icon">📭</div>
        <h3>暂无学域数据</h3>
        <p>管理员尚未配置学域信息，敬请期待</p>
    </div>
    <% } else { %>

    <!-- ========== 按分类渲染 ========== -->
    <%
        // 分类排序与主题色映射
        String[][] catMeta = {
            {"工学", "⚙️", "#4facfe"},
            {"理学", "🔬", "#2dd4bf"},
            {"人文", "📜", "#f59e0b"},
            {"艺术", "🎨", "#f472b6"},
            {"社科", "🏛️", "#a78bfa"},
            {"交叉", "🔀", "#fb7185"},
            {"医学", "💊", "#34d399"},
            {"农学", "🌾", "#a3e635"},
            {"其他", "📂", "#94a3b8"},
        };

        // 学域图标渐变底色的生成器
        String[] iconGradients = {
            "linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)",
            "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
            "linear-gradient(135deg, #f093fb 0%, #f5576c 100%)",
            "linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)",
            "linear-gradient(135deg, #fa709a 0%, #fee140 100%)",
            "linear-gradient(135deg, #a18cd1 0%, #fbc2eb 100%)",
            "linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)",
            "linear-gradient(135deg, #89f7fe 0%, #66a6ff 100%)",
        };

        int cardIndex = 0;
        for (String[] meta : catMeta) {
            String cat = meta[0], catIcon = meta[1], catColor = meta[2];
            List<Major> list = groups.get(cat);
            if (list == null || list.isEmpty()) continue;
            groups.remove(cat); // 标记已渲染
    %>
    <div class="category-block" style="--cat-color: <%= catColor %>;">
        <div class="cat-header">
            <div class="cat-dot"></div>
            <span class="cat-name"><%= catIcon %>&nbsp;&nbsp;<%= cat %></span>
            <span class="cat-badge"><%= list.size() %> 个学域</span>
        </div>
        <div class="matrix-grid">
            <%
                for (Major m : list) {
                    String grad = iconGradients[cardIndex % iconGradients.length];
                    String icon = m.getIcon() != null ? m.getIcon() : "📚";
                    double delay = 0.06 * (cardIndex % 6);
                    cardIndex++;
            %>
            <div class="major-card"
                 style="--cat-color: <%= catColor %>; --ani-delay: <%= String.format("%.2f", delay) %>s;"
                 onclick="openMajor('<%= m.getId() %>', '<%= m.getName().replace("'", "\\'") %>')">
                <div class="card-top">
                    <div class="major-icon-wrap" style="background: <%= grad %>;">
                        <%= icon %>
                    </div>
                    <div class="card-info">
                        <div class="major-title"><%= m.getName() %></div>
                        <% if (m.getCode() != null && !m.getCode().isEmpty()) { %>
                        <div class="major-code"><%= m.getCode() %></div>
                        <% } %>
                    </div>
                </div>
                <% if (m.getDescription() != null && !m.getDescription().isEmpty()) { %>
                <div class="major-desc"><%= m.getDescription() %></div>
                <% } else { %>
                <div class="major-desc" style="opacity:0.3;">探索 <%= m.getName() %> 的学术版图</div>
                <% } %>
                <div class="card-footer">
                    <% if (m.isInterdisciplinary()) { %>
                    <span class="tag tag-inter">🔀 交叉学科</span>
                    <% } %>
                    <% if (m.getDegreeType() != null && !m.getDegreeType().isEmpty()) { %>
                    <span class="tag tag-degree"><%= m.getDegreeType() %></span>
                    <% } %>
                    <% if (m.getDuration() > 0) { %>
                    <span class="tag"><%= m.getDuration() %>年制</span>
                    <% } %>
                    <span class="card-arrow">探索<span style="font-size:10px;">▶</span></span>
                </div>
            </div>
            <% } %>
        </div>
    </div>
    <%
        }

        // 渲染不在此顺序中的剩余分类
        for (Map.Entry<String, List<Major>> entry : groups.entrySet()) {
            String cat = entry.getKey();
            List<Major> list = entry.getValue();
            if (list == null || list.isEmpty()) continue;
    %>
    <div class="category-block" style="--cat-color: #94a3b8;">
        <div class="cat-header">
            <div class="cat-dot"></div>
            <span class="cat-name">📂&nbsp;&nbsp;<%= cat %></span>
            <span class="cat-badge"><%= list.size() %> 个学域</span>
        </div>
        <div class="matrix-grid">
            <%
                String grad = iconGradients[cardIndex % iconGradients.length];
                for (Major m : list) {
                    double delay = 0.06 * (cardIndex % 6);
                    cardIndex++;
                    String icon = m.getIcon() != null ? m.getIcon() : "📚";
            %>
            <div class="major-card"
                 style="--cat-color: #94a3b8; --ani-delay: <%= String.format("%.2f", delay) %>s;"
                 onclick="openMajor('<%= m.getId() %>', '<%= m.getName().replace("'", "\\'") %>')">
                <div class="card-top">
                    <div class="major-icon-wrap" style="background: <%= grad %>;">
                        <%= icon %>
                    </div>
                    <div class="card-info">
                        <div class="major-title"><%= m.getName() %></div>
                        <% if (m.getCode() != null && !m.getCode().isEmpty()) { %>
                        <div class="major-code"><%= m.getCode() %></div>
                        <% } %>
                    </div>
                </div>
                <% if (m.getDescription() != null && !m.getDescription().isEmpty()) { %>
                <div class="major-desc"><%= m.getDescription() %></div>
                <% } else { %>
                <div class="major-desc" style="opacity:0.3;">探索 <%= m.getName() %> 的学术版图</div>
                <% } %>
                <div class="card-footer">
                    <% if (m.isInterdisciplinary()) { %>
                    <span class="tag tag-inter">🔀 交叉学科</span>
                    <% } %>
                    <% if (m.getDegreeType() != null && !m.getDegreeType().isEmpty()) { %>
                    <span class="tag tag-degree"><%= m.getDegreeType() %></span>
                    <% } %>
                    <% if (m.getDuration() > 0) { %>
                    <span class="tag"><%= m.getDuration() %>年制</span>
                    <% } %>
                    <span class="card-arrow">探索<span style="font-size:10px;">▶</span></span>
                </div>
            </div>
            <% } %>
        </div>
    </div>
    <% } %>

    <% } %>

    <!-- 底部装饰 -->
    <div class="footer-glow">✦&nbsp;&nbsp;B O Y A&nbsp;&nbsp;S C H O L A R&nbsp;&nbsp;✦</div>
</div>

<script>
    var ctx = '<%= ctx %>';

    /**
     * 点击学域卡片 → 跳转到该学域的图书列表页
     */
    function openMajor(majorId, majorName) {
        var url = ctx + '/majorBooks?majorId=' + encodeURIComponent(majorId);
        try {
            window.parent.postMessage({
                type: 'navigate',
                url: 'majorBooks?majorId=' + majorId,
                title: majorName || '学域图书'
            }, '*');
        } catch(e) {
            window.location.href = url;
        }
    }

    /**
     * 生成背景星空粒子
     */
    (function() {
        var field = document.getElementById('starfield');
        var frag = document.createDocumentFragment();
        var count = 60;
        for (var i = 0; i < count; i++) {
            var dot = document.createElement('div');
            dot.className = 'star-dot';
            dot.style.left = Math.random() * 100 + '%';
            dot.style.top = Math.random() * 100 + '%';
            dot.style.animationDuration = (2 + Math.random() * 4) + 's';
            dot.style.animationDelay = Math.random() * 5 + 's';
            frag.appendChild(dot);
        }
        field.appendChild(frag);
    })();
</script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
