<%-- ============================================================================
 adminDashboard.jsp v3.0 — 管理驾驶舱（ECharts + 主题自适应）

 数据来源：AdminDashboardServlet（首次加载）+ StatsServlet（异步刷新）
 图表引擎：Apache ECharts 5.5
 主题支持：全量跟随 index.jsp 主题切换（CSS变量 + postMessage 同步）
 ============================================================================ --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    // ── 从 Servlet 传递的初始数据 ──
    String activeUsers    = request.getAttribute("activeUsers") != null ? String.valueOf(request.getAttribute("activeUsers")) : "加载中";
    String todayVisits    = request.getAttribute("todayVisits") != null ? String.valueOf(request.getAttribute("todayVisits")) : "加载中";
    String completionRate = request.getAttribute("courseCompletion") != null ? String.valueOf(request.getAttribute("courseCompletion")) : "加载中";
    String systemHealth   = request.getAttribute("systemHealth") != null ? String.valueOf(request.getAttribute("systemHealth")) : "加载中";

    Map<String, Object> sysInfo = (Map<String, Object>) request.getAttribute("sysInfo");
    Map<String, Object> dbInfo  = (Map<String, Object>) request.getAttribute("dbInfo");
    List<Map<String, Object>> alerts = (List<Map<String, Object>>) request.getAttribute("alerts");
    Map<String, Object> contentStats = (Map<String, Object>) request.getAttribute("contentStats");
    int alertCount = request.getAttribute("alertCount") != null ? (Integer) request.getAttribute("alertCount") : 0;

    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>博雅书院 · 管理驾驶舱</title>
    <link rel="stylesheet" href="<%= ctx %>/CSS/adminDashboard.css?v=3">
    <script>window.CONTEXT_PATH = '<%= ctx %>';</script>
    <script src="https://cdn.jsdelivr.net/npm/echarts@5.5.0/dist/echarts.min.js">
    </script>
    <!-- ========== 浅色主题 · 管理驾驶舱补充覆盖 ========== -->
    <style>
        /* ── 基础底色 ── */
        html[data-theme$="-light"] body{background:linear-gradient(170deg,#e9e2d2,#ede5d3 40%,#e4dbca)!important;color:#3d3929!important}
        /* ── KPI卡片图标 ── */
        html[data-theme$="-light"] .kpi-icon{opacity:.85!important}
        html[data-theme$="-light"] .kpi-label{color:#7a7360!important}
        html[data-theme$="-light"] .kpi-spark{opacity:.3!important}
        /* ── 区块标题 ── */
        html[data-theme$="-light"] .section-title{color:#3d3929!important}
        html[data-theme$="-light"] .section-title::before{background:linear-gradient(180deg,#2563eb,#7c3aed)!important}
        /* ── 图表标题 ── */
        html[data-theme$="-light"] .chart-head h3{color:#3d3929!important}
        html[data-theme$="-light"] .content-head h3{color:#3d3929!important}
        html[data-theme$="-light"] .monitor-head h3{color:#3d3929!important}
        /* ── 进度条文字 ── */
        html[data-theme$="-light"] .mbar-label{color:#7a7360!important}
        html[data-theme$="-light"] .mbar-label span:last-child{color:#3d3929!important}
        /* ── 内容统计 ── */
        html[data-theme$="-light"] .clabel{color:#7a7360!important}
        /* ── 告警 ── */
        html[data-theme$="-light"] .alert-time{color:#7a7360!important}
        html[data-theme$="-light"] .alert-list::-webkit-scrollbar-thumb{background:rgba(139,119,80,.15)!important}
        /* ── 状态标签 ── */
        html[data-theme$="-light"] .status-badge.healthy{background:rgba(5,150,105,.08)!important;color:#047857!important}
        html[data-theme$="-light"] .status-badge.normal{background:rgba(37,99,235,.06)!important;color:#2563eb!important}
        html[data-theme$="-light"] .status-badge.warning{background:rgba(217,119,6,.08)!important;color:#b45309!important}
        html[data-theme$="-light"] .status-badge.danger{background:rgba(220,60,60,.08)!important;color:#b91c1c!important}
        /* ── 快捷按钮文字 ── */
        html[data-theme$="-light"] .quick-btn{color:#3d3929!important}
        /* ── 通用文字 + 选中 ── */
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3,html[data-theme$="-light"] h4{color:#3d3929!important}
        html[data-theme$="-light"] ::selection{background:rgba(37,99,235,.15)!important;color:#3d3929!important}
    </style>
</head>
<body>
<div class="dash-wrap">

    <!-- ════════════ 顶部 KPI 卡片 ════════════ -->
    <section class="dash-kpis">
        <div class="kpi-card kpi-users">
            <div class="kpi-icon"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 4-7 8-7s8 3 8 7"/></svg></div>
            <div class="kpi-body">
                <div class="kpi-value" id="kpiActiveUsers"><%= activeUsers %></div>
                <div class="kpi-label">活跃用户</div>
                <div class="kpi-change up" id="kpiActiveUsersChange"><%= request.getAttribute("activeUsersChange") != null ? request.getAttribute("activeUsersChange") : "+12%" %></div>
            </div>
            <div class="kpi-spark" id="sparkUsers"></div>
        </div>
        <div class="kpi-card kpi-visits">
            <div class="kpi-icon"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></div>
            <div class="kpi-body">
                <div class="kpi-value" id="kpiTodayVisits"><%= todayVisits %></div>
                <div class="kpi-label">今日访问</div>
                <div class="kpi-change up" id="kpiTodayVisitsChange"><%= request.getAttribute("todayVisitsChange") != null ? request.getAttribute("todayVisitsChange") : "+8%" %></div>
            </div>
            <div class="kpi-spark" id="sparkVisits"></div>
        </div>
        <div class="kpi-card kpi-completion">
            <div class="kpi-icon"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div>
            <div class="kpi-body">
                <div class="kpi-value" id="kpiCompletion"><%= completionRate %></div>
                <div class="kpi-label">课程完成率</div>
                <div class="kpi-change up" id="kpiCompletionChange"><%= request.getAttribute("courseCompletionChange") != null ? request.getAttribute("courseCompletionChange") : "+2.3%" %></div>
            </div>
            <div class="kpi-spark" id="sparkCompletion"></div>
        </div>
        <div class="kpi-card kpi-health">
            <div class="kpi-icon"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18.36 6.64a9 9 0 1 1-12.73 0"/><line x1="12" y1="2" x2="12" y2="12"/></svg></div>
            <div class="kpi-body">
                <div class="kpi-value" id="kpiHealth"><%= systemHealth %></div>
                <div class="kpi-label">系统健康度</div>
                <div class="kpi-change up" id="kpiHealthChange"><%= request.getAttribute("systemHealthChange") != null ? request.getAttribute("systemHealthChange") : "+1.5%" %></div>
            </div>
            <div class="kpi-spark" id="sparkHealth"></div>
        </div>
    </section>

    <!-- ════════════ 图表区 ════════════ -->
    <section class="dash-charts">
        <div class="chart-card chart-large">
            <div class="chart-head">
                <h3>用户增长趋势</h3>
                <div class="chart-periods">
                    <button class="period-btn active" data-period="week">本周</button>
                    <button class="period-btn" data-period="month">本月</button>
                    <button class="period-btn" data-period="quarter">本季</button>
                </div>
            </div>
            <div class="chart-box" id="chartGrowth"></div>
        </div>
        <div class="chart-card">
            <div class="chart-head"><h3>访问来源分布</h3></div>
            <div class="chart-box" id="chartTraffic"></div>
        </div>
        <div class="chart-card">
            <div class="chart-head"><h3>学习活跃时段</h3></div>
            <div class="chart-box" id="chartHourly"></div>
        </div>
        <div class="chart-card">
            <div class="chart-head"><h3>内容类型分布</h3></div>
            <div class="chart-box" id="chartContent"></div>
        </div>
    </section>

    <!-- ════════════ 系统监控 ════════════ -->
    <section class="dash-section">
        <h2 class="section-title">系统实时监控</h2>
        <div class="monitor-grid">
            <div class="monitor-card">
                <div class="monitor-head">
                    <h3>服务器状态</h3>
                    <span class="status-badge healthy">
                        <%= sysInfo != null ? sysInfo.getOrDefault("serverStatus", "healthy") : "healthy" %>
                    </span>
                </div>
                <div class="monitor-bars">
                    <div class="mbar-item">
                        <div class="mbar-label"><span>CPU</span><span id="cpuVal"><%= sysInfo != null ? sysInfo.getOrDefault("cpuUsage", 0) : 0 %>%</span></div>
                        <div class="mbar-track"><div class="mbar-fill cpu" id="cpuBar" style="width:<%= sysInfo != null ? sysInfo.getOrDefault("cpuUsage", 0) : 0 %>%;"></div></div>
                    </div>
                    <div class="mbar-item">
                        <div class="mbar-label"><span>内存</span><span id="memVal"><%= sysInfo != null ? sysInfo.getOrDefault("memoryUsage", 0) : 0 %>%</span></div>
                        <div class="mbar-track"><div class="mbar-fill mem" id="memBar" style="width:<%= sysInfo != null ? sysInfo.getOrDefault("memoryUsage", 0) : 0 %>%;"></div></div>
                    </div>
                    <div class="mbar-item">
                        <div class="mbar-label"><span>磁盘</span><span id="diskVal"><%= sysInfo != null ? sysInfo.getOrDefault("diskUsage", 0) : 0 %>%</span></div>
                        <div class="mbar-track"><div class="mbar-fill disk" id="diskBar" style="width:<%= sysInfo != null ? sysInfo.getOrDefault("diskUsage", 0) : 0 %>%;"></div></div>
                    </div>
                    <div class="mbar-item">
                        <div class="mbar-label"><span>网络</span><span id="netVal"><%= sysInfo != null ? sysInfo.getOrDefault("networkTraffic", "2.4 MB/s") : "2.4 MB/s" %></span></div>
                        <div class="mbar-track"><div class="mbar-fill net" id="netBar" style="width:<%= sysInfo != null ? sysInfo.getOrDefault("networkUsage", 45) : 45 %>%;"></div></div>
                    </div>
                </div>
            </div>
            <div class="monitor-card">
                <div class="monitor-head">
                    <h3>数据库性能</h3>
                    <span class="status-badge normal">
                        <%= dbInfo != null ? dbInfo.getOrDefault("dbStatus", "normal") : "normal" %>
                    </span>
                </div>
                <div class="monitor-bars">
                    <div class="mbar-item">
                        <div class="mbar-label"><span>查询响应</span><span id="dbQueryVal"><%= dbInfo != null ? dbInfo.getOrDefault("dbQueryTime", "N/A") : "N/A" %>ms</span></div>
                        <div class="mbar-track"><div class="mbar-fill db" style="width:<%= dbInfo != null ? dbInfo.getOrDefault("dbQueryPercent", 10) : 10 %>%;"></div></div>
                    </div>
                    <div class="mbar-item">
                        <div class="mbar-label"><span>连接数</span><span id="dbConnVal"><%= dbInfo != null ? dbInfo.getOrDefault("dbConnections", "8/20") : "8/20" %></span></div>
                        <div class="mbar-track"><div class="mbar-fill db" style="width:<%= dbInfo != null ? dbInfo.getOrDefault("dbConnPercent", 40) : 40 %>%;"></div></div>
                    </div>
                    <div class="mbar-item">
                        <div class="mbar-label"><span>缓存命中</span><span id="cacheVal"><%= dbInfo != null ? dbInfo.getOrDefault("cacheHitRate", "94") : "94" %>%</span></div>
                        <div class="mbar-track"><div class="mbar-fill db good" style="width:<%= dbInfo != null ? dbInfo.getOrDefault("cacheHitRate", 94) : 94 %>%;"></div></div>
                    </div>
                    <div class="mbar-item">
                        <div class="mbar-label"><span>存储增长</span><span id="storageVal"><%= dbInfo != null ? dbInfo.getOrDefault("storageGrowth", "+12.5%") : "+12.5%" %></span></div>
                        <div class="mbar-track"><div class="mbar-fill db" style="width:<%= dbInfo != null ? dbInfo.getOrDefault("storageGrowthPercent", 65) : 65 %>%;"></div></div>
                    </div>
                </div>
            </div>
            <div class="monitor-card alerts-card">
                <div class="monitor-head">
                    <h3>实时告警</h3>
                    <span class="alert-badge" id="alertBadge"><%= alertCount %></span>
                </div>
                <div class="alert-list" id="alertList">
                    <%
                        if (alerts != null) {
                            for (Map<String, Object> alert : alerts) {
                    %>
                    <div class="alert-item <%= alert.get("type") %>">
                        <span class="alert-icon"><%= alert.get("icon") %></span>
                        <div class="alert-body">
                            <div class="alert-text"><%= alert.get("title") %></div>
                            <div class="alert-time"><%= alert.get("time") %></div>
                        </div>
                    </div>
                    <%
                            }
                        }
                    %>
                </div>
            </div>
        </div>
    </section>

    <!-- ════════════ 内容管理概览 ════════════ -->
    <section class="dash-section">
        <h2 class="section-title">内容管理概览</h2>
        <div class="content-grid">
            <div class="content-card">
                <div class="content-head">
                    <h3>课程管理</h3>
                    <button class="btn-sm" onclick="location.href='<%= ctx %>/booksList?action=add'">新增</button>
                </div>
                <div class="content-row">
                    <div class="cstat"><div class="cval" id="cTotalCourses"><%= contentStats != null ? contentStats.getOrDefault("totalCourses", "--") : "--" %></div><div class="clabel">课程总数</div></div>
                    <div class="cstat"><div class="cval" id="cPending"><%= contentStats != null ? contentStats.getOrDefault("pendingReviews", "--") : "--" %></div><div class="clabel">待审核</div></div>
                    <div class="cstat"><div class="cval" id="cRating"><%= contentStats != null ? contentStats.getOrDefault("averageRating", "--") : "--" %></div><div class="clabel">平均评分</div></div>
                </div>
            </div>
            <div class="content-card">
                <div class="content-head">
                    <h3>用户管理</h3>
                    <button class="btn-sm" onclick="location.href='<%= ctx %>/usersList'">查看</button>
                </div>
                <div class="content-row">
                    <div class="cstat"><div class="cval" id="cTotalUsers"><%= contentStats != null ? contentStats.getOrDefault("totalUsers", "--") : "--" %></div><div class="clabel">总用户数</div></div>
                    <div class="cstat"><div class="cval" id="cNewUsers"><%= contentStats != null ? contentStats.getOrDefault("todayNewUsers", "--") : "--" %></div><div class="clabel">今日新增</div></div>
                    <div class="cstat"><div class="cval" id="cAdmins"><%= contentStats != null ? contentStats.getOrDefault("adminCount", "--") : "--" %></div><div class="clabel">管理员</div></div>
                </div>
            </div>
            <div class="content-card">
                <div class="content-head">
                    <h3>通知管理</h3>
                    <button class="btn-sm" onclick="location.href='<%= ctx %>/notifications'">发送</button>
                </div>
                <div class="content-row">
                    <div class="cstat"><div class="cval" id="cSentNotif"><%= contentStats != null ? contentStats.getOrDefault("sentNotifications", "--") : "--" %></div><div class="clabel">已发送</div></div>
                    <div class="cstat"><div class="cval" id="cDraftNotif"><%= contentStats != null ? contentStats.getOrDefault("draftNotifications", "--") : "--" %></div><div class="clabel">草稿</div></div>
                    <div class="cstat"><div class="cval" id="cReadRate"><%= contentStats != null ? contentStats.getOrDefault("readRate", "--") : "--" %>%</div><div class="clabel">阅读率</div></div>
                </div>
            </div>
        </div>
    </section>

    <!-- ════════════ 快捷操作 ════════════ -->
    <section class="dash-section">
        <h2 class="section-title">快捷操作</h2>
        <div class="quick-grid">
            <button class="quick-btn" data-route="/adminReport"><span class="qicon">📊</span><span>生成报表</span></button>
            <button class="quick-btn" data-route="/adminSettings"><span class="qicon">🔧</span><span>系统设置</span></button>
            <button class="quick-btn" data-route="/adminBackup"><span class="qicon">📋</span><span>数据备份</span></button>
            <button class="quick-btn" data-route="/adminUserAnalysis"><span class="qicon">👥</span><span>用户分析</span></button>
            <button class="quick-btn" data-route="/adminLogs"><span class="qicon">🔍</span><span>日志查看</span></button>
            <button class="quick-btn" data-route="/adminSecurity"><span class="qicon">🛡️</span><span>安全检查</span></button>
        </div>
    </section>

</div>

<script>
// ═══════════════════════════════════════════════════
//  ECharts 主题颜色（从 CSS 变量读取，支持主题切换）
// ═══════════════════════════════════════════════════
var echartsInstances = {};

function getCssVar(name, fallback) {
    var v = getComputedStyle(document.documentElement).getPropertyValue(name).trim();
    return v || fallback;
}

function isLightTheme() {
    var t = document.documentElement.getAttribute('data-theme') || '';
    // ★ 也检查 parent 的主题（iframe 场景）
    try { if (window.parent && window.parent.document) { var pt = window.parent.document.documentElement.getAttribute('data-theme'); if (pt) t = pt; } } catch(e){}
    var isLight = t.indexOf('-light') > -1;
    // ★ fallback：data-theme 为空时，用背景色亮度判断
    if (!isLight && !t) { try { var bg = getComputedStyle(document.body).backgroundColor; var m = bg.match(/(\d+),\s*(\d+),\s*(\d+)/); if (m) { var br = (parseInt(m[1])*299+parseInt(m[2])*587+parseInt(m[3])*114)/1000; if (br > 150) isLight = true; } } catch(e){} }
    return isLight;
}

function getThemeColors() {
    var l = isLightTheme();
    // 浅色主题：暴力加深版 — 近黑文字 + 深网格 + 高饱和数据色
    // 深色主题：高亮霓虹系配色
    return {
        primary:   getCssVar('--primary-holo', l ? '#1d4ed8' : '#00f5ff'),
        secondary: getCssVar('--secondary-holo', l ? '#7c3aed' : '#a855f7'),
        accent:    getCssVar('--accent-cyber', l ? '#059669' : '#00ff9d'),
        danger:    '#ef4444',
        warning:   '#f59e0b',
        // ★ 坐标轴文字 — 浅色用近黑确保可读
        axis:      l ? '#1a1815' : '#94a3b8',
        axisLight: l ? '#3d3929' : '#64748b',
        // ★ 网格线 — 不透明度翻倍
        grid:      l ? 'rgba(26,24,20,0.30)' : 'rgba(148,163,184,0.12)',
        bg:        l ? '#fafaf7' : 'transparent',
        tooltipBg: l ? 'rgba(255,255,255,0.98)' : 'rgba(20,25,45,0.95)',
        tooltipBorder: l ? 'rgba(37,99,235,0.40)' : 'rgba(0,245,255,0.30)',
        tooltipText: l ? '#1a1815' : '#eee',
        dark:      l,
        // ★ 图表数据系列专用高饱和深色（浅色模式）
        seriesColors: l
            ? ['#1d4ed8','#7c3aed','#059669','#dc2626','#0891b2','#4f46e5','#16a34a','#db2777']
            : ['#00f5ff','#a855f7','#00ff9d','#ff6030','#ff4060','#38bdf8','#818cf8','#34d399'],
        // ★ 面积填充 — 浅色不透明度提升到 0.50
        areaFrom:  l ? 'rgba(29,78,216,0.50)' : 'rgba(0,245,255,0.30)',
        areaTo:    l ? 'rgba(29,78,216,0.08)' : 'rgba(0,245,255,0.02)',
        // ★ 柱状渐变起止色
        barTop:     l ? '#1d4ed8' : '#00f5ff',
        barBottom:  l ? '#7c3aed' : '#a855f7'
    };
}

function eChartBaseOptions() {
    var c = getThemeColors();
    return {
        backgroundColor: c.bg,
        grid: { top: 10, right: 20, bottom: 24, left: 45 },
        textStyle: { color: c.axis, fontSize: 11, fontWeight: 600 },
        xAxis: {
            type: 'category',
            axisLine: { lineStyle: { color: c.grid, width: 1 } },
            axisTick: { show: false },
            axisLabel: { color: c.axis, fontSize: 10, fontWeight: 600 },
            splitLine: { show: false }
        },
        yAxis: {
            type: 'value',
            axisLine: { show: false },
            axisTick: { show: false },
            axisLabel: { color: c.axis, fontSize: 10, fontWeight: 600 },
            splitLine: { lineStyle: { color: c.grid, type: 'dashed' } }
        }
    };
}

// ── 1. 用户增长趋势 ──
function initGrowthChart(accessTrend) {
    var dom = document.getElementById('chartGrowth');
    if (!dom) return;
    if (echartsInstances.growth) echartsInstances.growth.dispose();
    var chart = echarts.init(dom);
    echartsInstances.growth = chart;
    var c = getThemeColors();

    var labels = accessTrend && accessTrend.length > 0
        ? accessTrend.map(function(d){ return d.statDate; })
        : ['周一','周二','周三','周四','周五','周六','周日'];
    var values = accessTrend && accessTrend.length > 0
        ? accessTrend.map(function(d){ return d.totalVisits; })
        : [120, 200, 150, 180, 220, 180, 160];

    var opt = eChartBaseOptions();
    opt.tooltip = { trigger: 'axis', backgroundColor: c.tooltipBg, borderColor: c.tooltipBorder, textStyle: { color: c.tooltipText, fontSize: 12 } };
    opt.xAxis.data = labels;
    opt.yAxis.min = function(v){ return v.min - 20; };
    opt.series = [{
        type: 'line',
        data: values,
        smooth: true,
        symbol: 'circle',
        symbolSize: 6,
        lineStyle: { width: 3, color: new echarts.graphic.LinearGradient(0,0,1,0,[
            {offset:0, color:c.primary}, {offset:1, color:c.secondary}
        ]) },
        itemStyle: { color: c.primary, borderColor: c.dark ? '#fff' : '#3d3929', borderWidth: 2 },
        areaStyle: {
            color: new echarts.graphic.LinearGradient(0,0,0,1,[
                {offset:0, color: c.areaFrom},
                {offset:1, color: c.areaTo}
            ])
        }
    }];
    chart.setOption(opt);
    window.addEventListener('resize', function(){ chart.resize(); });
}

// ── 2. 访问来源分布（饼图） ──
function initTrafficChart(trafficSources) {
    var dom = document.getElementById('chartTraffic');
    if (!dom) return;
    if (echartsInstances.traffic) echartsInstances.traffic.dispose();
    var chart = echarts.init(dom);
    echartsInstances.traffic = chart;
    var c = getThemeColors();

    var data = trafficSources && trafficSources.length > 0
        ? trafficSources.map(function(d){ return { name: d.source || d.name, value: d.count || d.value }; })
        : [
            { name: '直接访问', value: 335 },
            { name: '搜索引擎', value: 310 },
            { name: '社交媒体', value: 234 },
            { name: '内部链接', value: 135 },
            { name: '其它', value: 86 }
        ];

    chart.setOption({
        backgroundColor: c.bg,
        tooltip: { trigger: 'item', backgroundColor: c.tooltipBg, borderColor: c.tooltipBorder, textStyle: { color: c.tooltipText, fontSize: 12 } },
        legend: { bottom: 0, textStyle: { color: c.axis, fontSize: 11 }, itemWidth: 10, itemHeight: 10 },
        series: [{
            type: 'pie',
            radius: ['45%', '75%'],
            center: ['50%', '45%'],
            avoidLabelOverlap: false,
            itemStyle: { borderRadius: 6, borderColor: 'transparent', borderWidth: 2 },
            label: { show: false },
            emphasis: { label: { show: true, fontSize: 14, fontWeight: 'bold' }, scaleSize: 8 },
            data: data,
            color: c.seriesColors
        }]
    });
    window.addEventListener('resize', function(){ chart.resize(); });
}

// ── 3. 学习活跃时段（柱状图） ──
function initHourlyChart(hourlyActivity) {
    var dom = document.getElementById('chartHourly');
    if (!dom) return;
    if (echartsInstances.hourly) echartsInstances.hourly.dispose();
    var chart = echarts.init(dom);
    echartsInstances.hourly = chart;
    var c = getThemeColors();

    var labels = [], values = [];
    if (hourlyActivity && hourlyActivity.length > 0) {
        hourlyActivity.forEach(function(d){
            labels.push((d.hour < 10 ? '0' : '') + d.hour + ':00');
            values.push(d.users);
        });
    } else {
        for (var h = 0; h < 24; h += 2) {
            labels.push((h < 10 ? '0' : '') + h + ':00');
            values.push(Math.floor(Math.random() * 80 + 10));
        }
    }

    var opt = eChartBaseOptions();
    opt.tooltip = { trigger: 'axis', backgroundColor: c.tooltipBg, borderColor: c.tooltipBorder, textStyle: { color: c.tooltipText, fontSize: 12 } };
    opt.xAxis.data = labels;
    opt.xAxis.axisLabel = { color: c.axisLight, fontSize: 10, rotate: 45 };
    opt.yAxis.min = 0;
    opt.series = [{
        type: 'bar',
        data: values,
        barWidth: '60%',
        itemStyle: {
            borderRadius: [6, 6, 0, 0],
            color: new echarts.graphic.LinearGradient(0,0,0,1,[
                {offset:0, color: c.barTop}, {offset:1, color: c.barBottom}
            ])
        }
    }];
    chart.setOption(opt);
    window.addEventListener('resize', function(){ chart.resize(); });
}

// ── 4. 内容类型分布（雷达图） ──
function initContentChart(contentStats) {
    var dom = document.getElementById('chartContent');
    if (!dom) return;
    if (echartsInstances.content) echartsInstances.content.dispose();
    var chart = echarts.init(dom);
    echartsInstances.content = chart;
    var c = getThemeColors();

    var vals = contentStats ? [
        contentStats.totalCourses || 25,
        contentStats.totalUsers || 1200,
        contentStats.sentNotifications || 45,
        contentStats.pendingReviews || 12,
        contentStats.todayNewUsers || 8
    ] : [25, 1200, 45, 12, 8];

    chart.setOption({
        backgroundColor: c.bg,
        tooltip: { trigger: 'item', backgroundColor: c.tooltipBg, borderColor: c.tooltipBorder, textStyle: { color: c.tooltipText } },
        legend: { bottom: 0, textStyle: { color: c.axis, fontSize: 10 }, itemWidth: 8, itemHeight: 8, itemGap: 12 },
        radar: {
            center: ['50%', '45%'],
            radius: '65%',
            indicator: [
                { name: '课程', max: Math.max(vals[0] * 1.5, 50) },
                { name: '用户', max: Math.max(vals[1] * 1.5, 2000) },
                { name: '通知', max: Math.max(vals[2] * 1.5, 100) },
                { name: '待审', max: Math.max(vals[3] * 1.5, 30) },
                { name: '新增', max: Math.max(vals[4] * 1.5, 20) }
            ],
            axisName: { color: c.axis, fontSize: 10 },
            splitArea: { areaStyle: { color: [
                c.dark ? 'rgba(139,119,80,0.06)' : 'rgba(37,99,235,0.06)',
                c.dark ? 'rgba(139,119,80,0.03)' : 'rgba(37,99,235,0.03)'
            ] } },
            splitLine: { lineStyle: { color: c.grid } },
            axisLine: { lineStyle: { color: c.grid } }
        },
        series: [{
            type: 'radar',
            data: [{
                value: vals,
                name: '数据概览',
                areaStyle: { color: c.dark ? 'rgba(0,245,255,0.20)' : 'rgba(37,99,235,0.18)' },
                lineStyle: { color: c.primary, width: 2 },
                itemStyle: { color: c.primary },
                symbol: 'circle',
                symbolSize: 5
            }]
        }]
    });
    window.addEventListener('resize', function(){ chart.resize(); });
}

// ── 统一初始化所有图表 ──
function initAllCharts() {
    fetch(window.CONTEXT_PATH + '/stats?module=dashboard')
        .then(function(r){ return r.json(); })
        .then(function(data){
            // KPI 数据更新
            if (data.activeUsers !== undefined) updateKPI('kpiActiveUsers', Number(data.activeUsers).toLocaleString());
            if (data.todayVisits !== undefined) updateKPI('kpiTodayVisits', Number(data.todayVisits).toLocaleString());
            if (data.courseCompletionRate !== undefined) updateKPI('kpiCompletion', data.courseCompletionRate + '%');
            if (data.systemHealth !== undefined) updateKPI('kpiHealth', data.systemHealth + '%');

            // 图表初始化
            initGrowthChart(data.accessTrend);
            initTrafficChart(data.trafficSources);
            initHourlyChart(data.hourlyActivity);
            initContentChart(data.contentStats);

            // 内容管理更新
            if (data.contentStats) {
                updateEl('cTotalCourses', data.contentStats.totalCourses);
                updateEl('cPending', data.contentStats.pendingReviews);
                updateEl('cRating', data.contentStats.averageRating);
                updateEl('cTotalUsers', Number(data.contentStats.totalUsers || 0).toLocaleString());
                updateEl('cNewUsers', data.contentStats.todayNewUsers);
                updateEl('cAdmins', data.contentStats.adminCount);
                updateEl('cSentNotif', data.contentStats.sentNotifications);
                updateEl('cDraftNotif', data.contentStats.draftNotifications);
                updateEl('cReadRate', (data.contentStats.readRate || 0) + '%');
            }

            // JVM 监控更新
            if (data.jvmMemPercent !== undefined) {
                updateBar('cpuBar', 'cpuVal', data.jvmCpuUsage || 23, '%');
                updateBar('memBar', 'memVal', data.jvmMemPercent, '%');
            }
        })
        .catch(function(e){
            console.warn('[Dashboard] Stats API failed, using defaults:', e);
            // 使用模拟数据初始化
            initGrowthChart(null);
            initTrafficChart(null);
            initHourlyChart(null);
            initContentChart(null);
        });
}

function updateKPI(id, val) {
    var el = document.getElementById(id);
    if (el) el.textContent = val;
}
function updateEl(id, val) {
    var el = document.getElementById(id);
    if (el && val !== undefined && val !== null) el.textContent = val;
}
function updateBar(barId, valId, value, suffix) {
    var bar = document.getElementById(barId), val = document.getElementById(valId);
    if (bar) bar.style.width = value + '%';
    if (val) val.textContent = value + (suffix || '');
}

// ── 时间周期切换 ──
document.addEventListener('DOMContentLoaded', function(){
    initAllCharts();

    // 周期按钮
    document.querySelectorAll('.period-btn').forEach(function(btn){
        btn.addEventListener('click', function(){
            var period = this.getAttribute('data-period');
            document.querySelectorAll('.period-btn').forEach(function(b){ b.classList.remove('active'); });
            this.classList.add('active');

            fetch(window.CONTEXT_PATH + '/stats?module=dashboard&period=' + period)
                .then(function(r){ return r.json(); })
                .then(function(data){
                    if (data.accessTrend) initGrowthChart(data.accessTrend);
                })
                .catch(function(e){ console.warn('[Dashboard] Period change failed:', e); });
        });
    });

    // 快捷操作按钮
    document.querySelectorAll('.quick-btn').forEach(function(btn){
        btn.addEventListener('click', function(){
            var route = this.getAttribute('data-route');
            if (route) location.href = window.CONTEXT_PATH + route;
        });
    });

    // 数字滚动动画
    animateNumbers();
});

function animateNumbers() {
    var targets = document.querySelectorAll('.kpi-value');
    targets.forEach(function(el){
        var text = el.textContent.trim();
        var isPercent = text.includes('%');
        var num = parseFloat(text.replace(/[^0-9.]/g, ''));
        if (isNaN(num)) return;
        el.textContent = '0' + (isPercent ? '%' : '');
        var step = Math.ceil(num / 40);
        var cur = 0;
        var timer = setInterval(function(){
            cur += step;
            if (cur >= num) { cur = num; clearInterval(timer); }
            el.textContent = (isPercent ? cur.toFixed(1) : Math.floor(cur).toLocaleString()) + (isPercent ? '%' : '');
        }, 30);
    });
}

// ── 主题变化时重新渲染 ECharts ──
window.addEventListener('message', function(e){
    if (e.data && e.data.type === 'themeChange' && e.data.theme) {
        // 延迟执行让 CSS 变量生效
        setTimeout(function(){
            Object.keys(echartsInstances).forEach(function(key){
                if (echartsInstances[key] && !echartsInstances[key].isDisposed()) {
                    echartsInstances[key].dispose();
                }
            });
            echartsInstances = {};
            initAllCharts();
        }, 300);
    }
});
</script>

<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= ctx %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
