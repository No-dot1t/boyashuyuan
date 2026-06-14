<%--
 =============================================================================
 growth.jsp  ——  成长中心 v3.0 · 数据仪表盘
 =============================================================================

 功能：
   1. 4×ECharts 速度表仪表盘
   2. 2×ECharts 环形图分析（任务完成率 + 成就进度）
   3. ECharts 专注趋势折线图（周/月切换）
   4. 成就徽章网格（服务端渲染 + 玻璃拟态）
   5. 活动时间线（AJAX + 动画）

 路由：/growthPage（GrowthPageServlet 转发）
 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ebookBuy301.pojo.Users" %>
<%@ page import="com.ebookBuy301.pojo.Achievement" %>
<%@ page import="java.util.ArrayList" %>
<%
    Users currentUser = (Users) request.getAttribute("currentUser");
    boolean isLoggedIn = (currentUser != null);
    ArrayList<Achievement> achievements = (ArrayList<Achievement>) request.getAttribute("achievements");
    long achievementCount = request.getAttribute("achievementCount") != null ? (Long) request.getAttribute("achievementCount") : 0L;
    long earnedCount = request.getAttribute("earnedCount") != null ? (Long) request.getAttribute("earnedCount") : 0L;
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <title>博雅书院 | 成长中心</title>
    <style>
/* === 关键内嵌样式（CSS 加载前兜底） === */
html,body{background:#060b14;margin:0;padding:0;min-height:100vh;color:#e2e8f0;font-family:'Inter','Segoe UI','PingFang SC','Microsoft YaHei',sans-serif;overflow-x:hidden}
.gr-container{max-width:1260px;margin:0 auto;padding:28px 32px 48px;position:relative;z-index:1}
.gr-header{background:linear-gradient(135deg,rgba(20,30,60,.7),rgba(30,20,50,.6));border:1px solid rgba(245,158,11,.2);border-radius:24px;padding:32px 36px;margin-bottom:28px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:16px}
.gr-badge-count{font-size:.8rem;font-weight:700;border-radius:50px;padding:8px 20px;color:#f59e0b;border:1px solid rgba(245,158,11,.25)}
.gr-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:28px}
.gr-stat-card{border-radius:18px;padding:18px 14px 12px;text-align:center;transition:all .4s;background:rgba(255,255,255,.025);border:1px solid rgba(255,255,255,.06)}
.gr-gauge-box{width:100%;height:130px}
.gr-stat-num{font-size:1.4rem;font-weight:800}
.gr-achievements{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:16px}
.gr-card{border-radius:20px;padding:24px 28px;background:rgba(255,255,255,.025);border:1px solid rgba(255,255,255,.06);backdrop-filter:blur(16px)}
.gr-donut-row{display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:28px}
.gr-donut-box{width:100%;height:280px}
.gr-chart-box{width:100%;height:300px}
.gr-timeline-wrap{padding-left:20px;border-left:2px solid rgba(245,158,11,.08)}
.gr-section{margin-bottom:28px}
.gr-section-title{font-size:1.05rem;font-weight:700;color:#e2e8f0;margin:0 0 16px 0}
@media(max-width:1024px){.gr-stats{grid-template-columns:repeat(2,1fr)}.gr-donut-row{grid-template-columns:1fr}}
@media(max-width:768px){.gr-container{padding:16px 14px 28px}.gr-header{padding:24px 20px}.gr-stats{grid-template-columns:repeat(2,1fr);gap:10px}.gr-gauge-box{height:110px}.gr-achievements{grid-template-columns:repeat(2,1fr)}}
@media(max-width:480px){.gr-achievements{grid-template-columns:1fr}.gr-gauge-box{height:95px}}
    </style>
<link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/growth.css?v=20260605-v3">
    <!-- ========== 浅色主题 · 成长中心全覆盖 ========== -->
    <style>
        /* ── CSS变量覆写（驱动growth.css全部var()引用）── */
        html[data-theme$="-light"]{
            --bg-deep:#e8dfcf;--bg-card:rgba(238,233,222,.85);--border-subtle:rgba(139,119,80,.07);
            --border-accent:rgba(37,99,235,.15);--text-primary:#3d3929;--text-secondary:#5c5540;
            --text-muted:#7a7360;--accent:#2563eb;--accent-glow:rgba(37,99,235,.1);
            --green:#059669;--blue:#2563eb;--purple:#7c3aed;--red:#dc2626;
            --glass:rgba(139,119,80,.03);--glow-card:0 4px 24px rgba(139,119,80,.08);
            --glow-hover:0 12px 48px rgba(139,119,80,.12),0 0 40px rgba(37,99,235,.03);
        }
        /* ── Base（处理内联CSS + growth.css双源）── */
        html[data-theme$="-light"] body{background:linear-gradient(170deg,#e9e2d2,#ede5d3 40%,#e4dbca)!important;color:#3d3929!important}
        html[data-theme$="-light"] body::before{opacity:.25!important;background-image:radial-gradient(ellipse 800px 600px at 20% 20%,rgba(37,99,235,.03),transparent 70%),radial-gradient(ellipse 600px 500px at 75% 30%,rgba(124,58,237,.03),transparent 70%),radial-gradient(ellipse 700px 500px at 50% 70%,rgba(37,99,235,.03),transparent 70%),radial-gradient(ellipse 500px 400px at 85% 80%,rgba(139,119,80,.03),transparent 70%)!important}
        html[data-theme$="-light"] body::after{background-image:linear-gradient(rgba(139,119,80,.04) 1px,transparent 1px),linear-gradient(90deg,rgba(139,119,80,.04) 1px,transparent 1px)!important}
        /* 浮动光球 dimmed */
        html[data-theme$="-light"] .gr-orb{opacity:.06!important}
        html[data-theme$="-light"] .gr-orb-1{background:rgba(37,99,235,.3)!important}
        html[data-theme$="-light"] .gr-orb-2{background:rgba(124,58,237,.25)!important}
        html[data-theme$="-light"] .gr-orb-3{background:rgba(37,99,235,.2)!important}
        /* ── Hero 头部 ── */
        html[data-theme$="-light"] .gr-header{background:linear-gradient(135deg,rgba(238,233,222,.78),rgba(243,239,228,.85))!important;border-color:rgba(37,99,235,.12)!important;box-shadow:0 4px 24px rgba(139,119,80,.08),inset 0 1px 0 rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] .gr-header::before{background:linear-gradient(90deg,transparent,rgba(37,99,235,.25),rgba(220,60,60,.15),rgba(124,58,237,.15),transparent)!important}
        html[data-theme$="-light"] .gr-title{background:linear-gradient(135deg,#2563eb,#7c3aed 50%,#dc2626)!important;-webkit-background-clip:text!important;background-clip:text!important;-webkit-text-fill-color:transparent!important;filter:none!important}
        html[data-theme$="-light"] .gr-subtitle{color:#7a7360!important}
        html[data-theme$="-light"] .gr-badge-count{background:linear-gradient(135deg,rgba(37,99,235,.08),rgba(124,58,237,.05))!important;color:#2563eb!important;box-shadow:0 0 20px rgba(37,99,235,.04)!important}
        /* ── 区块标题 ── */
        html[data-theme$="-light"] .gr-section-title{color:#3d3929!important}
        html[data-theme$="-light"] .gr-section-desc{color:#7a7360!important}
        /* ── 速度表卡片 ── */
        html[data-theme$="-light"] .gr-stat-card{background:linear-gradient(160deg,rgba(238,233,222,.8),rgba(243,239,228,.85))!important;border-color:rgba(139,119,80,.06)!important;box-shadow:0 4px 16px rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .gr-stat-card::before{background:linear-gradient(90deg,transparent,rgba(37,99,235,.15),transparent)!important}
        html[data-theme$="-light"] .gr-stat-card:hover{border-color:rgba(37,99,235,.12)!important;box-shadow:0 12px 40px rgba(139,119,80,.1)!important}
        html[data-theme$="-light"] .gr-stat-num{background:linear-gradient(135deg,#2563eb,#7c3aed)!important;-webkit-background-clip:text!important;background-clip:text!important;-webkit-text-fill-color:transparent!important}
        html[data-theme$="-light"] .gr-stat-label{color:#7a7360!important}
        /* ── 通用卡片 ── */
        html[data-theme$="-light"] .gr-card{background:linear-gradient(160deg,rgba(238,233,222,.82),rgba(243,239,228,.88))!important;border-color:rgba(139,119,80,.06)!important;box-shadow:0 4px 20px rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .gr-card:hover{border-color:rgba(37,99,235,.1)!important;box-shadow:0 12px 36px rgba(139,119,80,.1)!important}
        html[data-theme$="-light"] .gr-card::after{background:linear-gradient(135deg,transparent 60%,rgba(37,99,235,.02) 100%)!important}
        html[data-theme$="-light"] .gr-card-head h3{color:#3d3929!important}
        /* ── 周期切换按钮 ── */
        html[data-theme$="-light"] .gr-period{background:rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] .gr-period-btn{color:#7a7360!important}
        html[data-theme$="-light"] .gr-period-btn:hover{color:#5c5540!important;background:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .gr-period-btn.active{background:linear-gradient(135deg,rgba(37,99,235,.12),rgba(124,58,237,.08))!important;color:#2563eb!important;box-shadow:0 0 12px rgba(37,99,235,.06)!important}
        /* ── 成就网格 ── */
        html[data-theme$="-light"] .gr-achievement-card{background:linear-gradient(160deg,rgba(238,233,222,.78),rgba(243,239,228,.84))!important;border-color:rgba(139,119,80,.06)!important;box-shadow:0 4px 16px rgba(139,119,80,.05)!important}
        html[data-theme$="-light"] .gr-achievement-card::after{background:linear-gradient(135deg,transparent 50%,rgba(139,119,80,.03) 100%)!important}
        html[data-theme$="-light"] .gr-achievement-card:hover{border-color:rgba(37,99,235,.1)!important;box-shadow:0 12px 32px rgba(139,119,80,.1)!important}
        html[data-theme$="-light"] .gr-achievement-card.gr-earned{background:linear-gradient(160deg,rgba(37,99,235,.06),rgba(124,58,237,.04))!important;border-color:rgba(37,99,235,.15)!important;box-shadow:0 0 30px rgba(37,99,235,.04),0 4px 16px rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .gr-achievement-card.gr-earned::after{background:linear-gradient(135deg,transparent 50%,rgba(37,99,235,.04) 100%)!important}
        html[data-theme$="-light"] .gr-achievement-card.gr-locked{opacity:.45!important;filter:grayscale(.5)!important}
        html[data-theme$="-light"] .gr-achievement-name{color:#5c5540!important}
        html[data-theme$="-light"] .gr-achievement-card.gr-earned .gr-achievement-name{color:#2563eb!important}
        html[data-theme$="-light"] .gr-achievement-desc{color:#7a7360!important}
        html[data-theme$="-light"] .gr-achievement-date{color:#2563eb!important}
        html[data-theme$="-light"] .gr-achievement-hint{color:#b8b0a0!important}
        /* ── 进度条 ── */
        html[data-theme$="-light"] .gr-progress-bar{background:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .gr-progress-fill{background:linear-gradient(90deg,#2563eb,#dc2626,#7c3aed)!important}
        /* ── 时间线 ── */
        html[data-theme$="-light"] .gr-timeline-wrap{border-left-color:rgba(37,99,235,.1)!important}
        html[data-theme$="-light"] .gr-timeline-dot{background:linear-gradient(135deg,rgba(238,233,222,.92),rgba(243,239,228,.9))!important;border-color:rgba(37,99,235,.15)!important;box-shadow:0 0 16px rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .gr-timeline-item:hover .gr-timeline-dot{border-color:rgba(37,99,235,.25)!important;box-shadow:0 0 20px rgba(37,99,235,.06)!important}
        html[data-theme$="-light"] .gr-timeline-content{background:linear-gradient(160deg,rgba(238,233,222,.7),rgba(243,239,228,.76))!important;border-color:rgba(139,119,80,.05)!important}
        html[data-theme$="-light"] .gr-timeline-item:hover .gr-timeline-content{border-color:rgba(37,99,235,.08)!important;background:linear-gradient(160deg,rgba(238,233,222,.8),rgba(243,239,228,.86))!important}
        html[data-theme$="-light"] .gr-timeline-text{color:#5c5540!important}
        html[data-theme$="-light"] .gr-timeline-time{color:#7a7360!important}
        /* ── 空状态 ── */
        html[data-theme$="-light"] .gr-empty{color:#7a7360!important}
        /* ── Toast ── */
        html[data-theme$="-light"] .gr-toast{background:rgba(238,233,222,.97)!important;border-color:rgba(37,99,235,.12)!important;color:#3d3929!important;box-shadow:0 8px 40px rgba(139,119,80,.2)!important}
        html[data-theme$="-light"] .gr-toast-success{border-color:rgba(5,150,105,.2)!important;color:#047857!important;box-shadow:0 8px 40px rgba(139,119,80,.15),0 0 30px rgba(5,150,105,.06)!important}
        html[data-theme$="-light"] .gr-toast-error{border-color:rgba(220,60,60,.2)!important;color:#b91c1c!important;box-shadow:0 8px 40px rgba(139,119,80,.15),0 0 30px rgba(220,60,60,.06)!important}
        html[data-theme$="-light"] .gr-toast-warning{border-color:rgba(217,119,6,.2)!important;color:#b45309!important;box-shadow:0 8px 40px rgba(139,119,80,.15),0 0 30px rgba(217,119,6,.06)!important}
        html[data-theme$="-light"] .gr-toast-info{border-color:rgba(37,99,235,.15)!important;color:#2563eb!important;box-shadow:0 8px 40px rgba(139,119,80,.15),0 0 30px rgba(37,99,235,.06)!important}
        /* ── 通用 ── */
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3,h4{color:#3d3929!important}
        html[data-theme$="-light"] button{color:inherit!important}
    </style>
    <script defer src="${pageContext.request.contextPath}/js/echarts.js"></script>
</head>
<body>
<!-- 浮动光球背景 -->
<div class="gr-orb gr-orb-1"></div>
<div class="gr-orb gr-orb-2"></div>
<div class="gr-orb gr-orb-3"></div>

<div class="gr-container">
    <!-- ==================== 头部 Hero ==================== -->
    <header class="gr-header">
        <div class="gr-header-left">
            <h1 class="gr-title">🏆 成长中心</h1>
            <div class="gr-subtitle">见证每一步成长，记录每一份努力</div>
        </div>
        <span class="gr-badge-count"><%= earnedCount %> / <%= achievementCount %> 成就</span>
    </header>

    <!-- ==================== 数据统计仪表盘（ECharts 速度表） ==================== -->
    <section class="gr-stats" id="grStats">
        <div class="gr-stat-card gr-gauge-card">
            <div class="gr-gauge-box" id="gaugeTasks"></div>
            <div class="gr-stat-num" id="statTasks">—</div>
            <div class="gr-stat-label">📚 总任务数</div>
        </div>
        <div class="gr-stat-card gr-gauge-card">
            <div class="gr-gauge-box" id="gaugeCompleted"></div>
            <div class="gr-stat-num" id="statCompleted">—</div>
            <div class="gr-stat-label">✅ 今日完成</div>
        </div>
        <div class="gr-stat-card gr-gauge-card">
            <div class="gr-gauge-box" id="gaugeFocus"></div>
            <div class="gr-stat-num" id="statFocus">—</div>
            <div class="gr-stat-label">⏱️ 总专注(分钟)</div>
        </div>
        <div class="gr-stat-card gr-gauge-card">
            <div class="gr-gauge-box" id="gaugeStreak"></div>
            <div class="gr-stat-num" id="statStreak">—</div>
            <div class="gr-stat-label">🔥 连续学习(天)</div>
        </div>
    </section>

    <!-- ==================== 成就徽章 ==================== -->
    <section class="gr-section">
        <div class="gr-section-header">
            <h2 class="gr-section-title">🎖️ 成就徽章</h2>
            <span class="gr-section-desc">努力看得见 · 坚持有回报</span>
        </div>
        <div class="gr-achievements" id="grAchievements">
            <% if (achievements != null && !achievements.isEmpty()) {
                for (Achievement a : achievements) { %>
            <div class="gr-achievement-card <%= a.isEarned() ? "gr-earned" : "gr-locked" %>">
                <div class="gr-achievement-icon"><%= a.getIcon() != null ? a.getIcon() : "🏆" %></div>
                <div class="gr-achievement-name"><%= a.getName() != null ? a.getName() : "" %></div>
                <div class="gr-achievement-desc"><%= a.getDescription() != null ? a.getDescription() : "" %></div>
                <% if (a.isEarned() && a.getEarnedAt() != null) { %>
                <div class="gr-achievement-date">获得于 <%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(a.getEarnedAt()) %></div>
                <% } else { %>
                <div class="gr-achievement-hint">🔒 尚未解锁</div>
                <% } %>
                <div class="gr-progress-bar">
                    <div class="gr-progress-fill" style="width: <%= a.isEarned() ? "100" : "0" %>%"></div>
                </div>
            </div>
            <% }} else { %>
            <div class="gr-empty" style="grid-column:1/-1">暂无成就数据</div>
            <% } %>
        </div>
    </section>

    <!-- ==================== 数据分析面板（ECharts 环形图） ==================== -->
    <section class="gr-section" id="grAnalysisSection">
        <div class="gr-donut-row">
            <div class="gr-card">
                <div class="gr-card-head"><h3>📊 任务完成率分析</h3></div>
                <div class="gr-donut-box" id="chartDonut"></div>
            </div>
            <div class="gr-card">
                <div class="gr-card-head"><h3>🎯 成就获取进度</h3></div>
                <div class="gr-donut-box" id="chartAchieve"></div>
            </div>
        </div>
    </section>

    <!-- ==================== 专注趋势图 ==================== -->
    <section class="gr-section">
        <div class="gr-card">
            <div class="gr-card-head">
                <h3>📈 专注度趋势</h3>
                <div class="gr-period">
                    <button class="gr-period-btn active" data-period="week">本周</button>
                    <button class="gr-period-btn" data-period="month">本月</button>
                    <button class="gr-period-btn" data-period="day">近30天</button>
                </div>
            </div>
            <div class="gr-chart-box" id="chartFocusTrend"></div>
        </div>
    </section>

    <!-- ==================== 活动时间线 ==================== -->
    <section class="gr-section">
        <div class="gr-section-header">
            <h2 class="gr-section-title">📜 学习活动时间线</h2>
            <span class="gr-section-desc">每一步足迹，都是成长的印记</span>
        </div>
        <div class="gr-timeline-wrap" id="grTimeline">
            <div class="gr-empty">加载中...</div>
        </div>
    </section>
</div>

<!-- Toast -->
<div class="gr-toast" id="grToast"></div>

<script>
    var cp = '<%= request.getContextPath() %>';

    // 全局错误捕获
    window.addEventListener('error', function(e) {
        console.error('[growth] Uncaught error:', e.message);
    });

    function showToast(msg, type, dur) {
        try {
            type = type || 'info'; dur = dur || 3000;
            var el = document.getElementById('grToast');
            if (!el) return;
            el.textContent = msg;
            el.className = 'gr-toast gr-toast-' + type + ' show';
            clearTimeout(el._timer);
            el._timer = setTimeout(function() {
                el.classList.remove('show');
            }, dur);
        } catch(e) {}
    }

    function escHtml(s) {
        if (!s) return '';
        return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    // ==================== DOMContentLoaded 入口 ====================
    document.addEventListener('DOMContentLoaded', function() {
        <% if (isLoggedIn) { %>
        // 数据统计（仪表盘 + 环形图）
        try { initDataCharts(); } catch(e) { console.error('[growth] initDataCharts error:', e); }
        // 趋势图
        try { initFocusTrend(); } catch(e) { console.error('[growth] initFocusTrend error:', e); }
        // 时间线
        try { loadTimeline(); } catch(e) { console.error('[growth] loadTimeline error:', e); }
        <% } else { %>
        // 未登录时显示占位
        ['gaugeTasks','gaugeCompleted','gaugeFocus','gaugeStreak'].forEach(function(id){
            var el = document.getElementById(id); if(el) el.innerHTML = '<div class="gr-empty" style="padding:30px 0">请先登录</div>';
        });
        ['chartDonut','chartAchieve'].forEach(function(id){
            var el = document.getElementById(id); if(el) el.innerHTML = '<div class="gr-empty" style="padding:30px 0">请先登录</div>';
        });
        document.getElementById('grTimeline').innerHTML = '<div class="gr-empty">请先登录以查看成长数据</div>';
        var chartDom = document.getElementById('chartFocusTrend');
        if(chartDom) chartDom.innerHTML = '<div class="gr-empty">请先登录后查看</div>';
        <% } %>
    });

    // ==================== ECharts 仪表盘 + 环形图（统一入口） ====================

// ══════ 图表主题辅助（区分浅色/深色，高对比度 · 暴力加深版） ══════
function _ct(){
    // ★ 多层判断，避免 iframe 环境下 data-theme 未传递到子页面
    var _theme = (document.documentElement.getAttribute('data-theme')||'');
    try { if (window.parent && window.parent.document) { var _pt = window.parent.document.documentElement.getAttribute('data-theme'); if (_pt) _theme = _pt; } } catch(e){}
    var isLight = _theme.indexOf('-light') > -1;
    // ★ fallback：data-theme 为空时，用背景色亮度判断
    if (!isLight && !_theme) { try { var _bg = getComputedStyle(document.body).backgroundColor; var _m = _bg.match(/(\d+),\s*(\d+),\s*(\d+)/); if (_m) { var _br = (parseInt(_m[1])*299+parseInt(_m[2])*587+parseInt(_m[3])*114)/1000; if (_br > 150) isLight = true; } } catch(e){} }
    var cs = getComputedStyle(document.documentElement);
    function g(p){var v=cs.getPropertyValue(p).trim();return v;}
    function fallback(){for(var i=0;i<arguments.length;i++){var v=arguments[i];if(v)return v;}return'';}
    if (isLight) {
        return {
            ttBg: fallback(g('--ui-card-solid'),g('--bg-surface'),'#ffffff'),
            ttBd: fallback(g('--border-glow'),'rgba(37,99,235,.40)'),
            ttTx: fallback(g('--text-primary'),'#1a1815'),
            ax1: fallback(g('--text-primary'),'#1a1815'),
            ax2: fallback(g('--text-secondary'),'#3d3929'),
            ax3: fallback(g('--text-muted'),'#6a6358'),
            gr:  'rgba(26,24,20,.28)',
            gr2: 'rgba(26,24,20,.38)',
            pb:  '#ffffff',
            gt:  'rgba(26,24,20,.12)',
            dr:  'rgba(26,24,20,.08)',
            mu:  '#3d3929'
        };
    }
    return{
        ttBg:fallback(g('--ui-card-solid'),g('--bg-surface'),'#1e2228'),
        ttBd:fallback(g('--border-glow'),g('--glow-primary'),'rgba(74,158,255,.25)'),
        ttTx:fallback(g('--text-primary'),'#e5e9f0'),
        ax1:fallback(g('--text-primary'),'#e5e9f0'),
        ax2:fallback(g('--text-secondary'),'#8a8370'),
        ax3:fallback(g('--text-muted'),'#7a7360'),
        gr:'rgba(255,255,255,.08)',
        gr2:'rgba(255,255,255,.12)',
        pb:'#0d1525',
        gt:'rgba(255,255,255,.06)',
        dr:'rgba(255,255,255,.04)',
        mu:'#8a8370'
    };
}
    function initDataCharts() {
        if (typeof echarts === 'undefined' || typeof echarts.init !== 'function') {
            setTimeout(initDataCharts, 300); // echarts defer 未就绪则重试
            return;
        }
        fetch(cp + '/growthPage?action=stats')
            .then(function(r) { return r.json(); })
            .then(function(d) {
                if (!d.success) { showToast(d.message || '统计数据加载失败', 'warning', 3000); return; }
                var tasks = d.totalTasks || 0;
                var completed = d.completedToday || 0;
                var focus = d.totalFocusMinutes || 0;
                var streak = d.streakDays || 0;
                initGauges(tasks, completed, focus, streak);
                initDonuts(tasks, completed, d.totalAchievements || 0, d.earnedAchievements || 0);
            })
            .catch(function() { showToast('网络异常，数据加载失败', 'error', 3000); });
    }

    // ---- 4个速度表（精致暗色风格） ----
    function initGauges(tasks, completed, focus, streak) {
        var styleCs = getComputedStyle(document.documentElement);
        function gg(p){ var v=styleCs.getPropertyValue(p).trim();return v; }
        var gc1 = gg('--chart-1')||'#3b82f6';
        var gc2 = gg('--chart-2')||'#34d399';
        var gc3 = gg('--chart-3')||'#f59e0b';
        var gc4 = gg('--chart-4')||'#ef4444';
        var gaugeDefs = [
            { id: 'gaugeTasks',     val: tasks,     max: Math.max(tasks * 2, 20),     label: '总任务',   bg: gc1 },
            { id: 'gaugeCompleted', val: completed, max: Math.max(completed * 3, 10), label: '今日完成', bg: gc2 },
            { id: 'gaugeFocus',     val: focus,     max: Math.max(focus * 1.5, 120),  label: '专注分钟', bg: gc3 },
            { id: 'gaugeStreak',    val: streak,    max: Math.max(streak * 3, 30),    label: '连续天数', bg: gc4 }
        ];
        gaugeDefs.forEach(function(g) {
            var dom = document.getElementById(g.id);
            if (!dom) return;
            try { if (!echarts.getInstanceByDom(dom)) { echarts.init(dom, null, { devicePixelRatio: window.devicePixelRatio||1, renderer:'canvas' }); } } catch(e) {}
            var chart = echarts.getInstanceByDom(dom);
            if (!chart) return;
            var progress = g.max > 0 ? g.val / g.max : 0;
            chart.setOption({
                series: [{
                    type: 'gauge',
                    startAngle: 220, endAngle: -40, center: ['50%','55%'], radius: '92%',
                    min: 0, max: g.max,
                    splitNumber: 5,
                    progress: { show: true, width: 12, roundCap: true,
                        itemStyle: { color: g.bg } },
                    axisLine: { lineStyle: { width: 12, color: [[1,_ct().gt]] } },
                    axisTick: { show: false },
                    splitLine: { show: false },
                    axisLabel: { distance: 22, fontSize: 9, color: _ct().mu, fontWeight:600 },
                    pointer: { show: false },
                    detail: { valueAnimation: true, fontSize: 18, fontWeight: 'bold',
                        color: g.bg, offsetCenter: [0,'65%'],
                        formatter: function(v){ return v > 999 ? (v/1000).toFixed(1)+'k' : v; } },
                    title: { offsetCenter: [0,'85%'], color: _ct().ax1, fontSize: 9, fontWeight:600 },
                    data: [{ value: g.val, name: g.label }]
                }]
            });
            document.getElementById(g.id.replace('gauge','stat')).textContent = g.val.toLocaleString();
        });
    }

    // ---- 2个环形图（精致暗色风格） ----
    function initDonuts(tasks, completed, totalAch, earnedAch) {
        var ds = getComputedStyle(document.documentElement);
        function dg(p){ var v=ds.getPropertyValue(p).trim();return v; }
        var dc1 = dg('--chart-1')||'#3b82f6';
        var dc2 = dg('--chart-2')||'#34d399';
        var donutDefs = [
            { id: 'chartDonut',  val: completed, total: Math.max(tasks,completed,1), cl: dc2, label:'任务' },
            { id: 'chartAchieve',val: earnedAch, total: Math.max(totalAch,earnedAch,1), cl: dc1, label:'成就' }
        ];
        donutDefs.forEach(function(d) {
            var dom = document.getElementById(d.id);
            if (!dom) return;
            try { if (!echarts.getInstanceByDom(dom)) { echarts.init(dom, null, { devicePixelRatio: window.devicePixelRatio||1, renderer:'canvas' }); } } catch(e) {}
            var chart = echarts.getInstanceByDom(dom);
            if (!chart) return;
            var pct = d.total===0 ? 0 : Math.round(d.val/d.total*100);
            chart.setOption({
                title: [{ text: pct+'%', left:'center', top:'40%',
                    textStyle:{color:d.cl,fontSize:24,fontWeight:'bold'} }],
                series: [{
                    type: 'pie', radius: ['60%','82%'], center: ['50%','46%'],
                    avoidLabelOverlap: false, silent: true,
                    label: { show: false },
                    emphasis: { disabled: true },
                    data: [
                        { value:d.val, name:'已完成',
                            itemStyle:{ color:{type:'linear',x:0,y:0,x2:0,y2:1,
                                colorStops:[{offset:0,color:d.cl},{offset:1,color:d.cl}] }, borderRadius:6 } },
                        { value:Math.max(0,d.total-d.val), name:'剩余',
                            itemStyle:{ color:_ct().gt } }
                    ]
                }],
                graphic: [{ type:'text', left:'center', top:'53%',
                    style:{ text:d.val+'/'+d.total, fill:_ct().ax1, fontSize:12, fontWeight:600 } },
                    { type:'text', left:'center', top:'62%',
                    style:{ text:d.label, fill:_ct().mu, fontSize:10, fontWeight:500 } }]
            });
        });
    }

    // ==================== 专注趋势图 ====================
    var chartFocusTrend = null;

    function initFocusTrend() {
        var dom = document.getElementById('chartFocusTrend');
        if (!dom) return;
        if (typeof echarts === 'undefined' || typeof echarts.init !== 'function') {
            dom.innerHTML = '<div class="gr-empty">图表组件加载中...</div>';
            return;
        }
        chartFocusTrend = echarts.init(dom, null, {
            devicePixelRatio: window.devicePixelRatio || 1,
            renderer: 'canvas'
        });
        loadFocusTrend('week');

        document.querySelectorAll('.gr-period-btn').forEach(function(b) {
            b.addEventListener('click', function() {
                document.querySelectorAll('.gr-period-btn').forEach(function(x) { x.classList.remove('active'); });
                this.classList.add('active');
                loadFocusTrend(this.getAttribute('data-period'));
            });
        });
    }

    function loadFocusTrend(period) {
        var tcs = getComputedStyle(document.documentElement);
        function tg(p){ return tcs.getPropertyValue(p).trim(); }
        // ★ 多层判断，避免 iframe 环境下 data-theme 未传递到子页面
    var _theme = (document.documentElement.getAttribute('data-theme')||'');
    try { if (window.parent && window.parent.document) { var _pt = window.parent.document.documentElement.getAttribute('data-theme'); if (_pt) _theme = _pt; } } catch(e){}
    var isLight = _theme.indexOf('-light') > -1;
    // ★ fallback：data-theme 为空时，用背景色亮度判断
    if (!isLight && !_theme) { try { var _bg = getComputedStyle(document.body).backgroundColor; var _m = _bg.match(/(\d+),\s*(\d+),\s*(\d+)/); if (_m) { var _br = (parseInt(_m[1])*299+parseInt(_m[2])*587+parseInt(_m[3])*114)/1000; if (_br > 150) isLight = true; } } catch(e){} }
        var focusColor = tg('--chart-3')||'#f59e0b';
        var dangerColor = tg('--chart-4')||'#ef4444';
        // ★ 浅色主题用更高的面积不透明度（70%→35%渐变）
        var areaTop = isLight ? focusColor + 'B3' : focusColor + '40';   // 浅色70% / 深色25%
        var areaMid = isLight ? focusColor + '2A' : focusColor + '14';   // 浅色16% / 深色8%
        fetch(cp + '/growthPage?action=trend&period=' + period)
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (!chartFocusTrend) return;
                if (!data.success) {
                    chartFocusTrend.setOption({
                        title: { text: data.message || '暂无数据', left: 'center', top: '40%',
                            textStyle: { color: _ct().ax1, fontSize: 13, fontWeight: 400 } }
                    });
                    return;
                }
                var labels = [], values = [];
                if (data.trend && data.trend.length > 0) {
                    data.trend.forEach(function(d) {
                        labels.push(d.label || '');
                        values.push(d.minutes || 0);
                    });
                }
                chartFocusTrend.setOption({
                    backgroundColor: 'transparent',
                    tooltip: {
                        backgroundColor: _ct().ttBg,
                        borderColor: _ct().ttBd,
                        borderWidth: 1,
                        textStyle: { color: _ct().ttTx, fontSize: 13 },
                        trigger: 'axis',
                        axisPointer: { type: 'line', lineStyle: { color: _ct().gr, type: 'dashed' } },
                        formatter: function(p) { return '<b>' + p[0].axisValue + '</b><br/>⏱️ 专注 <span style="color:' + focusColor + ';font-weight:bold">' + p[0].value + '</span> 分钟'; }
                    },
                    grid: { top: 15, right: 30, bottom: 30, left: 55 },
                    xAxis: {
                        type: 'category', data: labels, boundaryGap: false,
                        axisLine: { lineStyle: { color: _ct().gr } },
                        axisTick: { show: false },
                        axisLabel: { color: _ct().ax1, fontSize: 11, fontWeight: 600, rotate: period === 'week' ? 0 : 30 },
                        splitLine: { show: false }
                    },
                    yAxis: {
                        type: 'value', name: '分钟',
                        nameTextStyle: { color: _ct().ax1, fontSize: 10, fontWeight: 600 },
                        splitLine: { lineStyle: { color: _ct().gt, type: 'dashed' } },
                        axisLabel: { color: _ct().ax1, fontSize: 11 }
                    },
                    series: [{
                        type: 'line', data: values, smooth: true, symbol: 'circle', symbolSize: 8,
                        lineStyle: { color: focusColor, width: 3, shadowBlur: 12, shadowColor: focusColor },
                        itemStyle: { color: focusColor, borderColor: _ct().pb, borderWidth: 2 },
                        emphasis: { focus: 'series', itemStyle: { borderWidth: 3, shadowBlur: 20 } },
                        areaStyle: {
                            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                                { offset: 0, color: areaTop },
                                { offset: 0.5, color: areaMid },
                                { offset: 1, color: 'transparent' }
                            ])
                        },
                        markLine: {
                            silent: true, symbol: 'none',
                            data: [{ type: 'average', name: '平均值',
                                label: { color: dangerColor, fontSize: 10, fontWeight: 'bold', formatter: '均值 {c}分' } }],
                            lineStyle: { color: dangerColor, type: 'dashed', width: 1.5 }
                        }
                    }]
                }, true);
            })
            .catch(function() {
                showToast('趋势数据加载失败', 'warning', 3000);
            });
    }

    // resize
    window.addEventListener('resize', function() {
        if (chartFocusTrend && !chartFocusTrend.isDisposed()) chartFocusTrend.resize();
    });

    // ==================== 活动时间线 ====================
    function loadTimeline() {
        fetch(cp + '/growthPage?action=timeline')
            .then(function(r) { return r.json(); })
            .then(function(d) {
                var container = document.getElementById('grTimeline');
                if (!d.activities || d.activities.length === 0) {
                    container.innerHTML = '<div class="gr-empty">暂无活动记录，开始你的学习之旅吧 ✨</div>';
                    return;
                }
                var html = '';
                d.activities.forEach(function(act) {
                    var icon = getActivityIcon(act.type);
                    html += '<div class="gr-timeline-item">';
                    html += '<div class="gr-timeline-dot">' + icon + '</div>';
                    html += '<div class="gr-timeline-content">';
                    html += '<div class="gr-timeline-text">' + escHtml(act.detail || '未知活动') + '</div>';
                    html += '<div class="gr-timeline-time">' + formatTime(act.time) + '</div>';
                    html += '</div></div>';
                });
                container.innerHTML = html;
            })
            .catch(function() {
                var container = document.getElementById('grTimeline');
                if (container) {
                    container.innerHTML = '<div class="gr-empty">时间线加载失败，请刷新重试</div>';
                }
                showToast('活动时间线加载失败', 'warning', 3000);
            });
    }

    function getActivityIcon(type) {
        var map = {
            'login': '🔑', 'read': '📖', 'view_book': '📚',
            'start_pomodoro': '⏱️', 'complete_pomodoro': '✅',
            'complete_task': '🎯', 'register': '🎉',
            'visit_scene': '🏫', 'download': '⬇️',
            'earn_achievement': '🏆'
        };
        return map[type] || '📌';
    }

    function formatTime(timeStr) {
        if (!timeStr) return '';
        var d = new Date(timeStr);
        var now = new Date();
        var diff = now - d;
        if (diff < 60000) return '刚刚';
        if (diff < 3600000) return Math.floor(diff / 60000) + '分钟前';
        if (diff < 86400000) return Math.floor(diff / 3600000) + '小时前';
        var year = d.getFullYear(), month = d.getMonth() + 1, day = d.getDate();
        return year + '-' + (month < 10 ? '0' : '') + month + '-' + (day < 10 ? '0' : '') + day;
    }
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);setTimeout(function(){location.reload()},250);}});})();
</script>
</body>
</html>
