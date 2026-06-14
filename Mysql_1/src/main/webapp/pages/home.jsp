<%--
 =============================================================================
 home.jsp  ——  智识首页（聚合门户）

 四层布局：
   Layer 1  欢迎与任务层    Hero Banner + 今日任务 + 快捷入口 + 节点快讯
   Layer 2  学习内容层      学域矩阵（全宽） + 为你推荐（全宽横向滚动） + 前沿讲坛/导师光网（2列）
   Layer 3  互动与社交层    星链校友/沉浸自习室（2列） + 元宇宙校园（3列独立行）
   Layer 4  文化与历史层    元文化/数字史册（2列 + 时间轴 + 横向滚动）

 视觉规范：
   - 模块间距：顶部 40~60px，底部 20~30px
   - Hero Banner：渐变 + 背景插画装饰
   - 卡片：浅色卡片 + 微阴影 + 圆角
   - PC端 3~4 列网格，移动端单列 + 横向滚动
   - 数据图表用蓝色高亮 + 渐变线条
 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ebookBuy301.pojo.HomeNews, java.util.ArrayList" %>
<%
    HomeNews topNews = (HomeNews) request.getAttribute("topNews");
    ArrayList<HomeNews> otherNews = (ArrayList<HomeNews>) request.getAttribute("otherNews");
    String contextPath = request.getContextPath();
    String username = "";
    Object currentUser = session.getAttribute("currentUser");
    if (currentUser != null) {
        username = ((com.ebookBuy301.pojo.Users) currentUser).getNickname();
        if (username == null || username.isEmpty()) {
            username = ((com.ebookBuy301.pojo.Users) currentUser).getUsername();
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>博雅书院 · 智识首页</title>
    <link rel="stylesheet" href="<%= contextPath %>/CSS/home.css?v=5.0">
    <style>
        /* ================================================================
           聚合首页专用样式体系
        ================================================================ */

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --holo: #00f5ff;
            --holo-dim: rgba(0,245,255,0.35);
            --holo-faint: rgba(0,245,255,0.08);
            --holo-glow: rgba(0,245,255,0.16);
            --purple: #8a2be2;
            --pink: #ff6b9d;
            --gold: #f7971e;
            --text: #e8f4ff;
            --text-dim: rgba(232,244,255,0.55);
            --text-faint: rgba(232,244,255,0.35);
            --bg-deep: #0a0e1a;
            --bg-card: rgba(255,255,255,0.035);
            --border-card: rgba(255,255,255,0.08);
            --border-hover: rgba(0,245,255,0.3);
            --shadow-card: 0 6px 24px rgba(0,0,0,0.25);
            --radius-lg: 20px;
            --radius-md: 14px;
            --radius-sm: 12px;
            --radius-pill: 40px;
            --gap-lg: 16px;
            --gap-md: 14px;
            --gap-sm: 10px;
            --section-top: 48px;
            --section-bottom: 24px;
            --module-top: 20px;
            --module-bottom: 16px;
        }

        body {
            background: var(--bg-deep);
            color: var(--text);
            font-family: 'PingFang SC', 'Microsoft YaHei', system-ui, -apple-system, sans-serif;
            min-height: 100vh;
            overflow-x: hidden;
            -webkit-font-smoothing: antialiased;
        }

        .home-wrap { max-width: 1280px; margin: 0 auto; padding: 28px 24px 80px; }

        /* ======== 通用标题 ======== */
        .section-title {
            font-size: 18px;
            font-weight: 700;
            color: var(--holo);
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
            letter-spacing: 0.5px;
        }
        .section-title::after {
            content: '';
            flex: 1;
            height: 1px;
            background: linear-gradient(90deg, var(--holo-dim) 0%, transparent 100%);
            opacity: 0.4;
            margin-left: 10px;
        }

        .section-block { margin-top: var(--section-top); margin-bottom: var(--section-bottom); }
        .section-block:first-child { margin-top: 0; }

        /* ======== 层分隔线 ======== */
        .layer-divider {
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.06), transparent);
            margin: 36px 0 40px;
            position: relative;
        }
        .layer-divider::after {
            content: '';
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translate(-50%, -50%);
            width: 6px; height: 6px;
            border-radius: 50%;
            background: var(--holo-dim);
            box-shadow: 0 0 10px var(--holo-glow);
        }

        /* ================================================================
           Layer 1  Hero Banner
        ================================================================ */
        .hero-banner {
            background: var(--hero-bg);
            border: 1px solid var(--hero-border);
            border-radius: var(--radius-lg);
            padding: 44px 48px;
            position: relative;
            overflow: hidden;
        }
        /* 背景插画装饰 */
        .hero-banner::before {
            content: '';
            position: absolute;
            top: -80px; right: -40px;
            width: 320px; height: 320px;
            background: var(--hero-glow);
            pointer-events: none;
        }
        .hero-banner::after {
            content: '';
            position: absolute;
            bottom: -60px; left: 20%;
            width: 240px; height: 240px;
            background: var(--hero-glow2);
            pointer-events: none;
        }
        /* 几何装饰线 */
        .hero-geo {
            position: absolute;
            top: 24px; right: 100px;
            width: 80px; height: 80px;
            border: 1px solid var(--hero-geo);
            border-radius: 50%;
            pointer-events: none;
            animation: heroGeoFloat 8s ease-in-out infinite;
        }
        .hero-geo-2 {
            top: auto; bottom: 30px; right: 60px;
            width: 50px; height: 50px;
            animation-delay: 2s;
            border-color: var(--hero-geo2);
        }
        .hero-dots {
            position: absolute;
            top: 50px; right: 180px;
            display: grid;
            grid-template-columns: repeat(3,6px);
            gap: 8px;
            pointer-events: none;
            opacity: 0.35;
        }
        .hero-dots span {
            width: 4px; height: 4px;
            border-radius: 50%;
            background: var(--holo);
        }
        @keyframes heroGeoFloat {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(-8px) rotate(3deg); }
        }

        .hero-greeting {
            font-size: 13px;
            color: var(--hero-greeting);
            letter-spacing: 3px;
            text-transform: uppercase;
            margin-bottom: 10px;
            position: relative;
            z-index: 1;
        }
        .hero-title {
            font-size: 32px;
            font-weight: 800;
            background: var(--hero-title-grad);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 12px;
            position: relative;
            z-index: 1;
            line-height: 1.3;
        }
        .hero-sub {
            font-size: 14px;
            color: var(--hero-sub);
            line-height: 1.8;
            max-width: 540px;
            position: relative;
            z-index: 1;
        }
        .hero-news {
            margin-top: 20px;
            padding: 10px 18px;
            background: var(--hero-news-bg);
            border-left: 3px solid var(--holo);
            border-radius: 0 10px 10px 0;
            font-size: 13px;
            color: var(--hero-news-text);
            position: relative;
            z-index: 1;
        }
        .hero-news strong { color: var(--holo); margin-right: 6px; font-weight: 600; }

        /* ======== 今日任务 ======== */
        .task-row {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: var(--gap-md);
        }
        .task-card {
            background: var(--bg-card);
            border: 1px solid var(--border-card);
            border-radius: var(--radius-sm);
            padding: 18px 20px;
            display: flex;
            align-items: center;
            gap: 14px;
            cursor: default;
            transition: border-color 0.25s, box-shadow 0.25s;
        }
        .task-card:hover {
            border-color: rgba(0,245,255,0.22);
            box-shadow: 0 4px 16px rgba(0,245,255,0.06);
        }
        .task-icon {
            font-size: 26px;
            line-height: 1;
            flex-shrink: 0;
            opacity: 0.9;
        }
        .task-info { flex: 1; min-width: 0; }
        .task-name {
            font-size: 14px;
            font-weight: 600;
            color: rgba(232,244,255,0.88);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .task-desc {
            font-size: 12px;
            color: var(--text-faint);
            margin-top: 3px;
        }
        .task-badge {
            font-size: 11px;
            padding: 3px 10px;
            border-radius: var(--radius-pill);
            background: rgba(0,245,255,0.12);
            color: var(--holo);
            flex-shrink: 0;
            font-weight: 500;
        }

        /* ======== 快捷入口胶囊 ======== */
        .quick-links {
            display: flex;
            gap: var(--gap-sm);
            flex-wrap: wrap;
        }
        .quick-btn {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 10px 22px;
            border-radius: var(--radius-pill);
            background: rgba(0,245,255,0.07);
            border: 1px solid rgba(0,245,255,0.20);
            color: var(--holo);
            font-size: 13px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.22s cubic-bezier(0.25, 0.1, 0.25, 1);
            text-decoration: none;
            letter-spacing: 0.3px;
        }
        .quick-btn:hover {
            background: rgba(0,245,255,0.16);
            border-color: rgba(0,245,255,0.45);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0,245,255,0.18);
        }
        .quick-btn:active { transform: translateY(0); }

        /* ======== 节点快讯 ======== */
        .news-list { list-style: none; }
        .news-list li {
            font-size: 12px;
            color: var(--text-dim);
            padding: 5px 0;
            border-bottom: 1px solid rgba(255,255,255,0.03);
        }
        .news-list li::before { content: '· '; color: var(--holo); font-weight: 700; margin-right: 4px; }
        .news-type {
            font-size: 11px;
            color: rgba(0,245,255,0.55);
            margin-right: 6px;
            font-weight: 500;
        }

        /* ================================================================
           Layer 2  全宽模块 + 2列网格
        ================================================================ */

        /* 全宽卡片 */
        .fullwidth-module {
            background: var(--bg-card);
            border: 1px solid var(--border-card);
            border-radius: var(--radius-md);
            overflow: hidden;
            cursor: pointer;
            transition: border-color 0.3s, box-shadow 0.3s, transform 0.25s;
        }
        .fullwidth-module:hover {
            border-color: var(--border-hover);
            box-shadow: 0 8px 32px rgba(0,245,255,0.07);
            transform: translateY(-1px);
        }
        .module-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 22px 26px 0;
        }
        .module-title {
            font-size: 17px;
            font-weight: 700;
            color: rgba(232,244,255,0.90);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .module-title .icon { font-size: 22px; }
        .module-arrow {
            font-size: 12px;
            color: var(--holo);
            opacity: 0.55;
            font-weight: 500;
            letter-spacing: 0.5px;
        }
        .module-desc {
            padding: 10px 26px 22px;
            font-size: 13px;
            color: var(--text-dim);
            line-height: 1.7;
        }
        .module-preview {
            padding: 0 26px 22px;
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        .preview-tag {
            font-size: 12px;
            padding: 5px 14px;
            border-radius: var(--radius-pill);
            background: rgba(0,245,255,0.06);
            border: 1px solid rgba(0,245,255,0.13);
            color: rgba(232,244,255,0.60);
            transition: all 0.2s;
        }
        .preview-tag:hover {
            background: rgba(0,245,255,0.12);
            color: var(--holo);
        }

        /* 2列网格 */
        .grid-2col {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: var(--gap-md);
        }

        /* 3列网格 */
        .grid-3col {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: var(--gap-md);
        }

        /* ======== 模块卡片（2/3列用） ======== */
        .module-card {
            background: var(--bg-card);
            border: 1px solid var(--border-card);
            border-radius: var(--radius-md);
            padding: 24px 22px;
            cursor: pointer;
            transition: all 0.28s cubic-bezier(0.25, 0.1, 0.25, 1);
            position: relative;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        /* 顶部彩色装饰线 */
        .module-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 2px;
            background: var(--card-accent, linear-gradient(90deg, #00f5ff, #8a2be2));
            opacity: 0;
            transition: opacity 0.3s;
        }
        .module-card:hover {
            border-color: var(--border-hover);
            box-shadow: 0 8px 28px rgba(0,245,255,0.08);
            transform: translateY(-2px);
        }
        .module-card:hover::before { opacity: 1; }

        .card-icon { font-size: 30px; margin-bottom: 12px; line-height: 1; }
        .card-title {
            font-size: 16px;
            font-weight: 700;
            color: rgba(232,244,255,0.90);
            margin-bottom: 7px;
        }
        .card-desc {
            font-size: 12px;
            color: var(--text-dim);
            line-height: 1.7;
        }
        .card-footer {
            margin-top: 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .card-tag {
            font-size: 11px;
            padding: 3px 10px;
            border-radius: var(--radius-pill);
            background: rgba(255,255,255,0.06);
            color: rgba(232,244,255,0.45);
            font-weight: 500;
        }
        .card-go {
            font-size: 13px;
            color: var(--holo);
            opacity: 0.65;
            font-weight: 600;
        }

        /* 文化/历史卡片特殊色 */
        .card-culture { --card-accent: linear-gradient(90deg, #ff6b9d, #c44dff); }
        .card-culture:hover { border-color: rgba(255,107,157,0.35); box-shadow: 0 8px 28px rgba(255,107,157,0.08); }
        .card-history { --card-accent: linear-gradient(90deg, #f7971e, #ffd200); }
        .card-history:hover { border-color: rgba(247,151,30,0.35); box-shadow: 0 8px 28px rgba(247,151,30,0.08); }

        /* ================================================================
           为你推荐 —— 横向滚动
        ================================================================ */
        .scroll-row {
            display: flex;
            gap: var(--gap-md);
            overflow-x: auto;
            padding: 2px 0 18px;
            scroll-behavior: smooth;
            -webkit-overflow-scrolling: touch;
            scrollbar-width: none;
            scrollbar-color: transparent transparent;
        }
        .scroll-row::-webkit-scrollbar { display: none; }
        .scroll-row::-webkit-scrollbar-track { background: transparent; }
        .scroll-row::-webkit-scrollbar-thumb {
            background: rgba(0,245,255,0.15);
            border-radius: 10px;
        }
        .scroll-card {
            flex: 0 0 280px;
            background: var(--bg-card);
            border: 1px solid var(--border-card);
            border-radius: var(--radius-md);
            padding: 20px;
            cursor: pointer;
            transition: all 0.28s;
            position: relative;
            overflow: hidden;
        }
        .scroll-card:hover {
            border-color: var(--border-hover);
            box-shadow: 0 6px 22px rgba(0,245,255,0.08);
            transform: translateY(-2px);
        }
        .scroll-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 2px;
            background: linear-gradient(90deg, var(--holo), var(--purple));
            opacity: 0;
            transition: opacity 0.3s;
        }
        .scroll-card:hover::before { opacity: 1; }
        .scroll-card-icon { font-size: 26px; margin-bottom: 10px; }
        .scroll-card-title { font-size: 14px; font-weight: 700; color: rgba(232,244,255,0.88); margin-bottom: 5px; }
        .scroll-card-desc { font-size: 12px; color: var(--text-faint); line-height: 1.6; }
        .scroll-card-tag {
            display: inline-block;
            margin-top: 10px;
            font-size: 11px;
            padding: 2px 10px;
            border-radius: var(--radius-pill);
            background: rgba(0,245,255,0.10);
            color: var(--holo);
        }

        /* ================================================================
           Layer 4  时间轴装饰
        ================================================================ */
        .timeline-strip {
            display: flex;
            align-items: center;
            gap: 0;
            margin-bottom: 24px;
            padding: 0 10px;
            overflow-x: auto;
            scrollbar-width: none;
        }
        .timeline-strip::-webkit-scrollbar { display: none; }
        .tl-dot {
            flex-shrink: 0;
            width: 12px; height: 12px;
            border-radius: 50%;
            background: var(--holo);
            box-shadow: 0 0 12px var(--holo-glow);
        }
        .tl-line {
            flex: 0 0 40px;
            height: 1px;
            background: linear-gradient(90deg, var(--holo-dim), transparent);
        }
        .tl-node {
            flex-shrink: 0;
            text-align: center;
            min-width: 80px;
        }
        .tl-year {
            font-size: 11px;
            color: var(--holo);
            font-weight: 700;
            letter-spacing: 1px;
        }
        .tl-event {
            font-size: 10px;
            color: var(--text-faint);
            margin-top: 2px;
            white-space: nowrap;
        }

        /* ======== 页脚 ======== */
        .home-footer {
            text-align: center;
            margin-top: 56px;
            padding-top: 28px;
            border-top: 1px solid rgba(255,255,255,0.05);
        }
        .home-footer-quote {
            font-size: 12px;
            color: rgba(232,244,255,0.22);
            letter-spacing: 4px;
            margin-bottom: 6px;
        }
        .home-footer-ver {
            font-size: 11px;
            color: rgba(232,244,255,0.12);
        }

        /* ================================================================
           响应式
        ================================================================ */

        /* 平板 */
        @media (max-width: 1024px) {
            .hero-banner { padding: 32px 28px; }
            .hero-title { font-size: 26px; }
            .grid-3col { grid-template-columns: repeat(2, 1fr); }
            .task-row { grid-template-columns: repeat(2, 1fr); }
            .scroll-card { flex: 0 0 240px; }
        }

        /* 手机 */
        @media (max-width: 768px) {
            .home-wrap { padding: 16px 12px 60px; }
            .hero-banner { padding: 24px 20px; border-radius: var(--radius-md); }
            .hero-title { font-size: 22px; }
            .hero-sub { font-size: 13px; }
            .hero-geo, .hero-geo-2, .hero-dots { display: none; }

            .grid-2col, .grid-3col { grid-template-columns: 1fr; }
            .task-row { grid-template-columns: 1fr; gap: 10px; }

            .quick-links { gap: 8px; }
            .quick-btn { padding: 8px 14px; font-size: 12px; }

            .scroll-row {
                gap: 12px;
                padding-bottom: 12px;
            }
            .scroll-card { flex: 0 0 220px; padding: 16px; }

            .module-header { padding: 16px 18px 0; }
            .module-desc, .module-preview { padding-left: 18px; padding-right: 18px; }

            .section-block { margin-top: 32px; margin-bottom: 16px; }
            .layer-divider { margin: 28px 0 32px; }
        }

        /* 大屏 */
        @media (min-width: 1440px) {
            .home-wrap { max-width: 1400px; }
            .grid-3col { grid-template-columns: repeat(4, 1fr); }
            .scroll-card { flex: 0 0 300px; }
        }

        /* ══════════ 浅色主题 · CSS变量覆写（自动驱动所有var()引用） ══════════ */
        html[data-theme$="-light"] {
            --holo: #2563eb;
            --holo-dim: rgba(37,99,235,.2);
            --holo-faint: rgba(37,99,235,.05);
            --holo-glow: rgba(37,99,235,.06);
            --text: #3d3929;
            --text-dim: rgba(61,57,41,.5);
            --text-faint: rgba(61,57,41,.3);
            --bg-deep: #e8dfcf;
            --bg-card: rgba(139,119,80,.04);
            --border-card: rgba(139,119,80,.08);
            --border-hover: rgba(37,99,235,.15);
            --shadow-card: 0 6px 24px rgba(139,119,80,.08);
        }

        /* ══════════ 各主题品牌色差异化 ══════════ */
        /* 🍎 Apple */
        html[data-theme="apple-light"]{--holo:#0071e3;--holo-dim:rgba(0,113,227,.2);--holo-faint:rgba(0,113,227,.05);--holo-glow:rgba(0,113,227,.06);--border-hover:rgba(0,113,227,.15)}
        html[data-theme="apple-light"] .section-title{color:#0071e3!important}
        html[data-theme="apple-light"] .section-title::after{background:linear-gradient(90deg,rgba(0,113,227,.15),transparent)!important}
        html[data-theme="apple-light"] .layer-divider{background:linear-gradient(90deg,transparent,rgba(139,119,80,.04),transparent)!important}
        /* 📝 Notion */
        html[data-theme="notion-light"]{--holo:#2f80ed;--holo-dim:rgba(47,128,237,.2);--holo-faint:rgba(47,128,237,.05);--holo-glow:rgba(47,128,237,.06);--border-hover:rgba(47,128,237,.13)}
        html[data-theme="notion-light"] .section-title{color:#2f80ed!important}
        html[data-theme="notion-light"] .section-title::after{background:linear-gradient(90deg,rgba(47,128,237,.13),transparent)!important}
        html[data-theme="notion-light"] .layer-divider{background:linear-gradient(90deg,transparent,rgba(139,119,80,.03),transparent)!important}
        /* 📖 微信读书 */
        html[data-theme="weread-light"]{--holo:#07c160;--holo-dim:rgba(7,193,96,.18);--holo-faint:rgba(7,193,96,.04);--holo-glow:rgba(7,193,96,.05);--border-hover:rgba(7,193,96,.15)}
        html[data-theme="weread-light"] .section-title{color:#07c160!important}
        html[data-theme="weread-light"] .section-title::after{background:linear-gradient(90deg,rgba(7,193,96,.15),transparent)!important}
        html[data-theme="weread-light"] .layer-divider{background:linear-gradient(90deg,transparent,rgba(139,119,80,.06),transparent)!important}
        /* 🏫 智慧校园 */
        html[data-theme="campus-light"]{--holo:#3182ce;--holo-dim:rgba(49,130,206,.18);--holo-faint:rgba(49,130,206,.05);--holo-glow:rgba(49,130,206,.06);--border-hover:rgba(49,130,206,.15)}
        html[data-theme="campus-light"] .section-title{color:#3182ce!important}
        html[data-theme="campus-light"] .section-title::after{background:linear-gradient(90deg,rgba(49,130,206,.15),transparent)!important}
        html[data-theme="campus-light"] .layer-divider{background:linear-gradient(90deg,transparent,rgba(139,119,80,.05),transparent)!important}
    </style>
    <!-- ========== 8套主题 · Hero Banner 各色独立 + 浅色主题通用覆盖 ========== -->
    <style>
        /* ══════════ 默认（深色主题通用，作为 fallback）══════════ */
        :root{
            --hero-bg: linear-gradient(145deg, rgba(0,245,255,.10) 0%, rgba(138,43,226,.16) 45%, rgba(0,180,255,.08) 100%);
            --hero-border: rgba(0,245,255,.20);
            --hero-glow: radial-gradient(circle at 30% 40%, rgba(0,245,255,.12) 0%, transparent 65%);
            --hero-glow2: radial-gradient(circle at 60% 30%, rgba(138,43,226,.10) 0%, transparent 65%);
            --hero-geo: rgba(0,245,255,.12);
            --hero-geo2: rgba(138,43,226,.14);
            --hero-dots: var(--holo);
            --hero-greeting: rgba(0,245,255,.65);
            --hero-title-grad: linear-gradient(135deg, #fff 0%, var(--holo) 60%, #8a2be2 100%);
            --hero-sub: var(--text-dim);
            --hero-news-bg: rgba(0,245,255,.06);
            --hero-news-text: rgba(232,244,255,.70);
        }
        /* 🍎 苹果浅色 */
        html[data-theme="apple-light"]{
            --hero-bg: linear-gradient(145deg, rgba(10,122,214,.06) 0%, rgba(10,122,214,.10) 50%, rgba(10,122,214,.04) 100%);
            --hero-border: rgba(10,122,214,.14);
            --hero-glow: radial-gradient(circle at 30% 40%, rgba(10,122,214,.08) 0%, transparent 65%);
            --hero-glow2: radial-gradient(circle at 60% 30%, rgba(10,122,214,.05) 0%, transparent 65%);
            --hero-geo: rgba(10,122,214,.10);
            --hero-geo2: rgba(10,122,214,.08);
            --hero-greeting: rgba(10,122,214,.50);
            --hero-title-grad: linear-gradient(135deg, #2c2c2e 0%, #0a7ad6 60%, #4094e0 100%);
            --hero-sub: #5c5c60;
            --hero-news-bg: rgba(10,122,214,.05);
            --hero-news-text: #5c5540;
        }
        /* 📝 Notion 浅色 */
        html[data-theme="notion-light"]{
            --hero-bg: linear-gradient(145deg, rgba(200,128,16,.06) 0%, rgba(200,128,16,.10) 50%, rgba(200,128,16,.04) 100%);
            --hero-border: rgba(200,128,16,.14);
            --hero-glow: radial-gradient(circle at 30% 40%, rgba(200,128,16,.08) 0%, transparent 65%);
            --hero-glow2: radial-gradient(circle at 60% 30%, rgba(200,128,16,.05) 0%, transparent 65%);
            --hero-geo: rgba(200,128,16,.10);
            --hero-geo2: rgba(200,128,16,.08);
            --hero-greeting: rgba(180,120,16,.50);
            --hero-title-grad: linear-gradient(135deg, #3d3929 0%, #c88010 60%, #e0a030 100%);
            --hero-sub: #5c5540;
            --hero-news-bg: rgba(200,128,16,.05);
            --hero-news-text: #5c5540;
        }
        /* 📖 微信读书浅色 */
        html[data-theme="weread-light"]{
            --hero-bg: linear-gradient(145deg, rgba(74,120,32,.06) 0%, rgba(74,120,32,.10) 50%, rgba(74,120,32,.04) 100%);
            --hero-border: rgba(74,120,32,.14);
            --hero-glow: radial-gradient(circle at 30% 40%, rgba(74,120,32,.08) 0%, transparent 65%);
            --hero-glow2: radial-gradient(circle at 60% 30%, rgba(74,120,32,.05) 0%, transparent 65%);
            --hero-geo: rgba(74,120,32,.10);
            --hero-geo2: rgba(74,120,32,.08);
            --hero-greeting: rgba(64,110,28,.50);
            --hero-title-grad: linear-gradient(135deg, #3d3929 0%, #4a7820 60%, #6a9828 100%);
            --hero-sub: #5c5540;
            --hero-news-bg: rgba(74,120,32,.05);
            --hero-news-text: #5c5540;
        }
        /* 🏫 校园浅色 */
        html[data-theme="campus-light"]{
            --hero-bg: linear-gradient(145deg, rgba(80,104,200,.06) 0%, rgba(80,104,200,.10) 50%, rgba(80,104,200,.04) 100%);
            --hero-border: rgba(80,104,200,.14);
            --hero-glow: radial-gradient(circle at 30% 40%, rgba(80,104,200,.08) 0%, transparent 65%);
            --hero-glow2: radial-gradient(circle at 60% 30%, rgba(80,104,200,.05) 0%, transparent 65%);
            --hero-geo: rgba(80,104,200,.10);
            --hero-geo2: rgba(80,104,200,.08);
            --hero-greeting: rgba(70,90,180,.50);
            --hero-title-grad: linear-gradient(135deg, #3d3929 0%, #5068c8 60%, #7088e0 100%);
            --hero-sub: #5c5540;
            --hero-news-bg: rgba(80,104,200,.05);
            --hero-news-text: #5c5540;
        }
        /* 🌌 量子矩阵深色 */
        html[data-theme="quantum-matrix"]{
            --hero-bg: linear-gradient(145deg, rgba(74,158,255,.08) 0%, rgba(74,158,255,.14) 50%, rgba(74,158,255,.06) 100%);
            --hero-border: rgba(74,158,255,.18);
            --hero-glow: radial-gradient(circle at 30% 40%, rgba(74,158,255,.10) 0%, transparent 65%);
            --hero-glow2: radial-gradient(circle at 60% 30%, rgba(74,158,255,.08) 0%, transparent 65%);
            --hero-geo: rgba(74,158,255,.12);
            --hero-geo2: rgba(74,158,255,.10);
            --hero-greeting: rgba(74,158,255,.60);
            --hero-title-grad: linear-gradient(135deg, #ffffff 0%, #4a9eff 50%, #80c0ff 100%);
            --hero-sub: var(--text-dim);
            --hero-news-bg: rgba(74,158,255,.07);
            --hero-news-text: rgba(190,220,255,.70);
        }
        /* 💫 星云之梦深色 */
        html[data-theme="nebula-dream"]{
            --hero-bg: linear-gradient(145deg, rgba(224,80,96,.08) 0%, rgba(224,80,96,.14) 50%, rgba(224,80,96,.06) 100%);
            --hero-border: rgba(224,80,96,.18);
            --hero-glow: radial-gradient(circle at 30% 40%, rgba(224,80,96,.10) 0%, transparent 65%);
            --hero-glow2: radial-gradient(circle at 60% 30%, rgba(224,80,96,.08) 0%, transparent 65%);
            --hero-geo: rgba(224,80,96,.12);
            --hero-geo2: rgba(224,80,96,.10);
            --hero-greeting: rgba(224,80,96,.60);
            --hero-title-grad: linear-gradient(135deg, #ffffff 0%, #e05060 50%, #f08098 100%);
            --hero-sub: var(--text-dim);
            --hero-news-bg: rgba(224,80,96,.07);
            --hero-news-text: rgba(255,200,212,.70);
        }
        /* ⚡ 赛博霓虹深色 */
        html[data-theme="cyber-neon"]{
            --hero-bg: linear-gradient(145deg, rgba(255,96,48,.08) 0%, rgba(255,96,48,.14) 50%, rgba(255,96,48,.06) 100%);
            --hero-border: rgba(255,96,48,.18);
            --hero-glow: radial-gradient(circle at 30% 40%, rgba(255,96,48,.10) 0%, transparent 65%);
            --hero-glow2: radial-gradient(circle at 60% 30%, rgba(255,96,48,.08) 0%, transparent 65%);
            --hero-geo: rgba(255,96,48,.12);
            --hero-geo2: rgba(255,96,48,.10);
            --hero-greeting: rgba(255,96,48,.60);
            --hero-title-grad: linear-gradient(135deg, #ffffff 0%, #ff6030 50%, #ff9060 100%);
            --hero-sub: var(--text-dim);
            --hero-news-bg: rgba(255,96,48,.07);
            --hero-news-text: rgba(255,210,190,.70);
        }
        /* 💹 数据洪流深色 */
        html[data-theme="data-stream"]{
            --hero-bg: linear-gradient(145deg, rgba(48,200,160,.08) 0%, rgba(48,200,160,.14) 50%, rgba(48,200,160,.06) 100%);
            --hero-border: rgba(48,200,160,.18);
            --hero-glow: radial-gradient(circle at 30% 40%, rgba(48,200,160,.10) 0%, transparent 65%);
            --hero-glow2: radial-gradient(circle at 60% 30%, rgba(48,200,160,.08) 0%, transparent 65%);
            --hero-geo: rgba(48,200,160,.12);
            --hero-geo2: rgba(48,200,160,.10);
            --hero-greeting: rgba(48,200,160,.60);
            --hero-title-grad: linear-gradient(135deg, #ffffff 0%, #30c8a0 50%, #70e8c0 100%);
            --hero-sub: var(--text-dim);
            --hero-news-bg: rgba(48,200,160,.07);
            --hero-news-text: rgba(190,240,228,.70);
        }

        /* ────── 浅色主题通用覆盖（非Hero部分）────── */
        html[data-theme$="-light"] body,html[data-theme$="-light"] html{background:#e8dfcf!important;color:#3d3929!important}
        html[data-theme$="-light"] .hero-dots span{background:rgba(139,119,80,.25)!important}
        html[data-theme$="-light"] .module-card:hover::before{opacity:0!important}
        html[data-theme$="-light"] .scroll-card::before{background:linear-gradient(90deg,#2563eb,#8a2be2)!important}
        html[data-theme$="-light"] .layer-divider{background:linear-gradient(90deg,transparent,rgba(139,119,80,.05),transparent)!important}
        html[data-theme$="-light"] .layer-divider::after{background:rgba(37,99,235,.2)!important;box-shadow:0 0 10px rgba(37,99,235,.06)!important}
        /* 任务卡片 */
        html[data-theme$="-light"] .task-card{background:rgba(238,233,222,.88)!important;border-color:rgba(139,119,80,.06)!important;box-shadow:0 2px 8px rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] .task-card:hover{border-color:rgba(37,99,235,.12)!important;box-shadow:0 4px 16px rgba(37,99,235,.04)!important}
        html[data-theme$="-light"] .task-name{color:#3d3929!important}
        html[data-theme$="-light"] .task-desc{color:#7a7360!important}
        html[data-theme$="-light"] .task-badge{background:rgba(37,99,235,.08)!important;color:#2563eb!important}
        /* 快捷入口 */
        html[data-theme$="-light"] .quick-btn{background:rgba(139,119,80,.04)!important;border-color:rgba(37,99,235,.12)!important;color:#2563eb!important}
        html[data-theme$="-light"] .quick-btn:hover{background:rgba(37,99,235,.08)!important;border-color:rgba(37,99,235,.25)!important;box-shadow:0 4px 16px rgba(37,99,235,.08)!important}
        /* 快讯 */
        html[data-theme$="-light"] .news-list li{color:#7a7360!important;border-bottom-color:rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] .news-list li::before{color:#2563eb!important}
        html[data-theme$="-light"] .news-type{color:rgba(37,99,235,.4)!important}
        /* 全宽模块 */
        html[data-theme$="-light"] .fullwidth-module{background:rgba(238,233,222,.84)!important;border-color:rgba(139,119,80,.06)!important;box-shadow:0 2px 8px rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] .fullwidth-module:hover{border-color:rgba(37,99,235,.12)!important;box-shadow:0 8px 24px rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .module-title{color:#3d3929!important}
        html[data-theme$="-light"] .module-desc{color:#7a7360!important}
        html[data-theme$="-light"] .module-arrow{color:#2563eb!important}
        /* 标签 */
        html[data-theme$="-light"] .preview-tag{color:#5c5540!important;background:rgba(139,119,80,.05)!important;border-color:rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .preview-tag:hover{background:rgba(37,99,235,.07)!important;color:#2563eb!important}
        /* 模块卡片 */
        html[data-theme$="-light"] .module-card{background:rgba(238,233,222,.88)!important;border-color:rgba(139,119,80,.06)!important;box-shadow:0 2px 8px rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] .module-card:hover{border-color:rgba(37,99,235,.1)!important;box-shadow:0 8px 24px rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .card-title{color:#3d3929!important}
        html[data-theme$="-light"] .card-desc{color:#7a7360!important}
        html[data-theme$="-light"] .card-tag{color:#7a7360!important;background:rgba(139,119,80,.05)!important}
        html[data-theme$="-light"] .card-go{color:#2563eb!important}
        /* 文化/历史特殊卡 */
        html[data-theme$="-light"] .card-culture:hover{border-color:rgba(255,107,157,.2)!important;box-shadow:0 8px 24px rgba(255,107,157,.05)!important}
        html[data-theme$="-light"] .card-history:hover{border-color:rgba(247,151,30,.2)!important;box-shadow:0 8px 24px rgba(247,151,30,.05)!important}
        /* 横向滚动推荐卡 */
        html[data-theme$="-light"] .scroll-card{background:rgba(238,233,222,.88)!important;border-color:rgba(139,119,80,.06)!important;box-shadow:0 2px 8px rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] .scroll-card:hover{border-color:rgba(37,99,235,.1)!important;box-shadow:0 6px 20px rgba(139,119,80,.07)!important}
        html[data-theme$="-light"] .scroll-card-title{color:#3d3929!important}
        html[data-theme$="-light"] .scroll-card-desc{color:#7a7360!important}
        html[data-theme$="-light"] .scroll-card-tag{background:rgba(37,99,235,.07)!important;color:#2563eb!important}
        /* 时间轴 */
        html[data-theme$="-light"] .tl-dot{background:#2563eb!important;box-shadow:0 0 12px rgba(37,99,235,.08)!important}
        html[data-theme$="-light"] .tl-year{color:#2563eb!important}
        html[data-theme$="-light"] .tl-event{color:rgba(61,57,41,.3)!important}
        html[data-theme$="-light"] .tl-line{background:linear-gradient(90deg,rgba(37,99,235,.12),transparent)!important}
        /* 页脚 */
        html[data-theme$="-light"] .home-footer{border-top-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .home-footer-quote{color:rgba(61,57,41,.2)!important}
        html[data-theme$="-light"] .home-footer-ver{color:rgba(61,57,41,.1)!important}
        /* 滚动条 */
        html[data-theme$="-light"] .scroll-row{scrollbar-color:rgba(139,119,80,.1) transparent!important}
        html[data-theme$="-light"] .scroll-row::-webkit-scrollbar-thumb{background:rgba(139,119,80,.1)!important}
    </style>

</head>
<body>
<div class="home-wrap">

    <!-- ================================================================
         Layer 1  欢迎与任务层
    ================================================================ -->

    <!-- Hero Banner -->
    <div class="hero-banner">
        <!-- 几何装饰 -->
        <div class="hero-geo"></div>
        <div class="hero-geo hero-geo-2"></div>
        <div class="hero-dots">
            <span></span><span></span><span></span>
            <span></span><span></span><span></span>
            <span></span><span></span><span></span>
        </div>

        <div class="hero-greeting">BOYA ACADEMY · 智联万象</div>
        <div class="hero-title">
            欢迎回来<% if (!username.isEmpty()) { %>，<%= username %><% } %> ⚡
        </div>
        <div class="hero-sub">
            博学明辨，求是创新 —— 融合文理工艺，构建跨学科智能学域。
            以数字人文、AI 伦理、智慧设计为支点，培育未来领军者。
        </div>
        <div class="hero-news">
            <strong>📡 实时动态</strong>
            <% if (topNews != null) { %><%= topNews.getTitle() %><% } else { %>暂无最新资讯<% } %>
        </div>
    </div>

    <!-- 今日任务 -->
    <div class="section-block">
        <div class="section-title">📋 今日任务</div>
        <div class="task-row">
            <div class="task-card" onclick="navigateTo('majorMatrix','学域矩阵')" style="cursor:pointer;">
                <div class="task-icon">📚</div>
                <div class="task-info">
                    <div class="task-name">探索学域矩阵</div>
                    <div class="task-desc">浏览今日推荐学域</div>
                </div>
                <div class="task-badge">待完成</div>
            </div>
            <div class="task-card" onclick="navigateTo('forYou','为你推荐')" style="cursor:pointer;">
                <div class="task-icon">🎯</div>
                <div class="task-info">
                    <div class="task-name">个性化推荐阅读</div>
                    <div class="task-desc">为你推荐 3 本好书</div>
                </div>
                <div class="task-badge">待完成</div>
            </div>
            <div class="task-card">
                <div class="task-icon">🏛</div>
                <div class="task-info">
                    <div class="task-name">自习室打卡</div>
                    <div class="task-desc">进入沉浸自习室</div>
                </div>
                <div class="task-badge">待完成</div>
            </div>
        </div>
    </div>

    <!-- 快捷入口 -->
    <div class="section-block" style="margin-top: 20px;">
        <div class="quick-links">
            <button class="quick-btn" onclick="navigateTo('majorMatrix','学域矩阵')">🔭 学域矩阵</button>
            <button class="quick-btn" onclick="navigateTo('forYou','为你推荐')">🎯 为你推荐</button>
            <button class="quick-btn" onclick="navigateTo('lecturePage','前沿讲坛')">🚀 前沿讲坛</button>
            <button class="quick-btn" onclick="navigateTo('facultyPage','导师光网')">🧑‍🏫 导师光网</button>
        </div>
    </div>

    <!-- 节点快讯 -->
    <% if (otherNews != null && otherNews.size() > 0) { %>
    <div class="section-block" style="margin-top: 16px; margin-bottom: 0;">
        <div class="section-title">📰 节点快讯</div>
        <ul class="news-list">
            <% for (HomeNews news : otherNews) {
                String typeText = "新闻";
                if ("announcement".equals(news.getNewsType())) typeText = "通知公告";
                else if ("event".equals(news.getNewsType())) typeText = "活动速递";
            %>
            <li><span class="news-type">[<%= typeText %>]</span><%= news.getTitle() %></li>
            <% } %>
        </ul>
    </div>
    <% } %>

    <div class="layer-divider"></div>

    <!-- ================================================================
         Layer 2  学习内容层
    ================================================================ -->

    <div class="section-title">🧠 学习内容</div>

    <!-- 学域矩阵（全宽） -->
    <div class="fullwidth-module" onclick="navigateTo('majorMatrix','学域矩阵')" style="margin-bottom: var(--module-bottom);">
        <div class="module-header">
            <div class="module-title"><span class="icon">🔭</span> 学域矩阵</div>
            <div class="module-arrow">进入 →</div>
        </div>
        <div class="module-desc">
            探索跨学科知识网络，发现你的学习宇宙。人文、理工、艺术、社科——每个学域都是一扇通往未来的大门。
        </div>
        <div class="module-preview">
            <span class="preview-tag">数字人文</span>
            <span class="preview-tag">AI 伦理</span>
            <span class="preview-tag">智慧设计</span>
            <span class="preview-tag">量子计算</span>
            <span class="preview-tag">脑科学</span>
            <span class="preview-tag">区块链</span>
            <span class="preview-tag">生命科学</span>
            <span class="preview-tag">+ 更多学域</span>
        </div>
    </div>

    <!-- 为你推荐（全宽 + 横向滚动） -->
    <div class="fullwidth-module" onclick="navigateTo('forYou','为你推荐')" style="margin-bottom: var(--module-bottom);">
        <div class="module-header">
            <div class="module-title"><span class="icon">🎯</span> 为你推荐</div>
            <div class="module-arrow">查看全部 →</div>
        </div>
        <div class="module-desc" style="padding-bottom: 4px;">
            基于你的阅读历史与偏好，AI 智能推荐最适合你的书籍、课程与讲坛内容。
        </div>
        <!-- 横向滚动推荐卡片 -->
        <div class="scroll-row" style="padding: 8px 26px 22px;" onclick="event.stopPropagation();">
            <div class="scroll-card" onclick="navigateTo('forYou','为你推荐')">
                <div class="scroll-card-icon">📖</div>
                <div class="scroll-card-title">《数字人文导论》</div>
                <div class="scroll-card-desc">跨学科视角下的数字人文研究范式与方法论</div>
                <span class="scroll-card-tag">AI 精选</span>
            </div>
            <div class="scroll-card" onclick="navigateTo('forYou','为你推荐')">
                <div class="scroll-card-icon">🧬</div>
                <div class="scroll-card-title">《生命科学与伦理》</div>
                <div class="scroll-card-desc">基因编辑、合成生物学与人类未来</div>
                <span class="scroll-card-tag">热门</span>
            </div>
            <div class="scroll-card" onclick="navigateTo('forYou','为你推荐')">
                <div class="scroll-card-icon">💻</div>
                <div class="scroll-card-title">《量子计算入门》</div>
                <div class="scroll-card-desc">从量子比特到量子算法的完整学习路径</div>
                <span class="scroll-card-tag">新课</span>
            </div>
            <div class="scroll-card" onclick="navigateTo('forYou','为你推荐')">
                <div class="scroll-card-icon">🎨</div>
                <div class="scroll-card-title">《智慧设计实践》</div>
                <div class="scroll-card-desc">AI 驱动的设计方法论与工具链</div>
                <span class="scroll-card-tag">推荐</span>
            </div>
            <div class="scroll-card" onclick="navigateTo('forYou','为你推荐')">
                <div class="scroll-card-icon">🧠</div>
                <div class="scroll-card-title">《认知科学前沿》</div>
                <div class="scroll-card-desc">大脑、心智与人工智能的交汇探索</div>
                <span class="scroll-card-tag">大师课</span>
            </div>
        </div>
    </div>

    <!-- 前沿讲坛 + 导师光网（2列） -->
    <div class="grid-2col">
        <div class="module-card" onclick="navigateTo('lecturePage','前沿讲坛')">
            <div class="card-icon">🚀</div>
            <div class="card-title">前沿讲坛</div>
            <div class="card-desc">
                汇聚顶尖学者、行业领袖的思想盛宴。从 AI 前沿到人文哲思，聆听改变世界的声音。
            </div>
            <div class="card-footer">
                <span class="card-tag">讲座 · 论坛</span>
                <span class="card-go">→</span>
            </div>
        </div>
        <div class="module-card" onclick="navigateTo('facultyPage','导师光网')">
            <div class="card-icon">✨</div>
            <div class="card-title">导师光网</div>
            <div class="card-desc">
                连接博雅书院优秀导师资源，一对一指导、学术交流、研究合作，点亮你的学术之路。
            </div>
            <div class="card-footer">
                <span class="card-tag">导师 · 研究</span>
                <span class="card-go">→</span>
            </div>
        </div>
    </div>

    <div class="layer-divider"></div>

    <!-- ================================================================
         Layer 3  互动与社交层
    ================================================================ -->

    <div class="section-title">🌟 互动与社交</div>

    <!-- 星链校友 + 沉浸自习室（2列） -->
    <div class="grid-2col" style="margin-bottom: var(--gap-md);">
        <div class="module-card" onclick="navigateTo('alumniPage','星链校友')">
            <div class="card-icon">⭐</div>
            <div class="card-title">星链校友</div>
            <div class="card-desc">
                连接遍布全球的博雅校友网络，分享职业经验、建立合作关系，让每一份缘分持续发光。
            </div>
            <div class="card-footer">
                <span class="card-tag">校友 · 社群</span>
                <span class="card-go">→</span>
            </div>
        </div>
        <div class="module-card" onclick="navigateTo('pages/studyRoom.jsp','沉浸自习室')">
            <div class="card-icon">🏛</div>
            <div class="card-title">沉浸自习室</div>
            <div class="card-desc">
                专注模式 · 番茄钟 · 学习小组 · 成就系统，打造沉浸式学习体验，让专注成为习惯。
            </div>
            <div class="card-footer">
                <span class="card-tag">自习 · 专注</span>
                <span class="card-go">→</span>
            </div>
        </div>
    </div>

    <!-- 元宇宙校园（3列独立行） -->
    <div class="section-title" style="margin-top: 8px;">🌐 元宇宙校园</div>
    <div class="grid-3col" style="margin-bottom: 0;">
        <div class="module-card" onclick="navigateTo('campus3d','元宇宙校园')">
            <div class="card-icon">🏫</div>
            <div class="card-title">3D 校园漫游</div>
            <div class="card-desc">在沉浸式三维空间中探索博雅校园的每一个角落。</div>
            <div class="card-footer">
                <span class="card-tag">3D · 探索</span>
                <span class="card-go">→</span>
            </div>
        </div>
        <div class="module-card" onclick="navigateTo('campus3d','元宇宙校园')">
            <div class="card-icon">👥</div>
            <div class="card-title">虚拟社交</div>
            <div class="card-desc">与同窗在虚拟空间中相遇、交流，打破物理边界。</div>
            <div class="card-footer">
                <span class="card-tag">社交 · 互动</span>
                <span class="card-go">→</span>
            </div>
        </div>
        <div class="module-card" onclick="navigateTo('campus3d','元宇宙校园')">
            <div class="card-icon">🎪</div>
            <div class="card-title">线上活动</div>
            <div class="card-desc">参加元宇宙中的展览、讲座、庆典等线上活动。</div>
            <div class="card-footer">
                <span class="card-tag">活动 · 事件</span>
                <span class="card-go">→</span>
            </div>
        </div>
    </div>

    <div class="layer-divider" style="margin-top: 32px;"></div>

    <!-- ================================================================
         Layer 4  文化与历史层
    ================================================================ -->

    <div class="section-title">🏛 文化与历史</div>

    <!-- 时间轴装饰条 -->
    <div class="timeline-strip">
        <div class="tl-node">
            <div class="tl-year">2001</div>
            <div class="tl-event">书院创立</div>
        </div>
        <div class="tl-line" style="flex: 0 0 30px;"></div>
        <div class="tl-dot"></div>
        <div class="tl-line" style="flex: 0 0 30px;"></div>
        <div class="tl-node">
            <div class="tl-year">2008</div>
            <div class="tl-event">学域体系确立</div>
        </div>
        <div class="tl-line" style="flex: 0 0 30px;"></div>
        <div class="tl-dot"></div>
        <div class="tl-line" style="flex: 0 0 30px;"></div>
        <div class="tl-node">
            <div class="tl-year">2015</div>
            <div class="tl-event">数字人文中心成立</div>
        </div>
        <div class="tl-line" style="flex: 0 0 30px;"></div>
        <div class="tl-dot"></div>
        <div class="tl-line" style="flex: 0 0 30px;"></div>
        <div class="tl-node">
            <div class="tl-year">2021</div>
            <div class="tl-event">元宇宙校园上线</div>
        </div>
        <div class="tl-line" style="flex: 0 0 30px;"></div>
        <div class="tl-dot"></div>
        <div class="tl-line" style="flex: 0 0 30px;"></div>
        <div class="tl-node">
            <div class="tl-year">2025</div>
            <div class="tl-event">智联万象 2.0</div>
        </div>
    </div>

    <!-- 元文化 + 数字史册（2列） -->
    <div class="grid-2col">
        <div class="module-card card-culture" onclick="navigateTo('culturePage','元·文化')">
            <div class="card-icon">🔮</div>
            <div class="card-title">元·文化</div>
            <div class="card-desc">
                探索博雅文化底蕴，传统与现代交融，艺术与科技共鸣。文化活动、创意展览、数字艺术——文明的下一个形态。
            </div>
            <div class="card-footer">
                <span class="card-tag">文化 · 艺术</span>
                <span class="card-go">→</span>
            </div>
        </div>
        <div class="module-card card-history" onclick="navigateTo('history','数字史册')">
            <div class="card-icon">📜</div>
            <div class="card-title">数字史册</div>
            <div class="card-desc">
                以数字形式记录博雅历史，横跨时间轴浏览重要事件，感受书院从草创到辉煌的每一个节点。
            </div>
            <div class="card-footer">
                <span class="card-tag">历史 · 时间轴</span>
                <span class="card-go">→</span>
            </div>
        </div>
    </div>

    <!-- 页脚 -->
    <div class="home-footer">
        <div class="home-footer-quote">—— 智联万象，生生不息 ——</div>
        <div class="home-footer-ver">BOYA ACADEMY v2.5.0</div>
    </div>

</div>

<script>
    /**
     * 向父窗口（index.jsp）发送跳转消息，由父窗口切换 iframe 内容并高亮导航项。
     */
    function navigateTo(url, title) {
        try {
            window.parent.postMessage({ type: 'navigate', url: url, title: title }, '*');
        } catch(e) {
            window.location.href = url;
        }
    }

    // ══════════ 主题同步：加载时从父窗口恢复 + 监听 postMessage ══════════
    (function syncTheme() {
        var theme = 'quantum-matrix';
        try {
            if (window.parent && window.parent !== window) {
                var pt = window.parent.document.documentElement.getAttribute('data-theme');
                if (pt) theme = pt;
            }
        } catch(e){}
        var saved = localStorage.getItem('boya-theme');
        if (saved) theme = saved;
        document.documentElement.setAttribute('data-theme', theme);
        // 加载浅色主题CSS
        var link = document.createElement('link');
        link.rel = 'stylesheet';
        link.id = 'boya-light-css';
        link.href = '<%= request.getContextPath() %>/CSS/sub-pages-light.css';
        document.head.appendChild(link);
        // 监听父窗口主题切换
        window.addEventListener('message', function(e) {
            if (e.data && e.data.type === 'themeChange' && e.data.theme) {
                document.documentElement.setAttribute('data-theme', e.data.theme);
                localStorage.setItem('boya-theme', e.data.theme);
            }
        });
    })();
</script>
</body>
</html>
