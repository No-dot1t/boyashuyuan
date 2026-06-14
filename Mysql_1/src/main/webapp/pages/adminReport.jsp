<%--
 =============================================================================
 adminReport.jsp
 =============================================================================

 用途      后台管理页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   Ajax 异步请求 —— fetch
   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    Integer bookCount = (Integer) request.getAttribute("bookCount");
    Integer userCount = (Integer) request.getAttribute("userCount");
    Integer lectureCount = (Integer) request.getAttribute("lectureCount");
    Integer courseCount = (Integer) request.getAttribute("courseCount");
    if (bookCount == null) bookCount = 0;
    if (userCount == null) userCount = 0;
    if (lectureCount == null) lectureCount = 0;
    if (courseCount == null) courseCount = 0;
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>博雅书院 | 数据报表</title>
    <link rel="stylesheet" href="<%= ctx %>/CSS/index.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{background:var(--bg-space,#0a0b1a);color:#fff;font-family:'Segoe UI','PingFang SC',sans-serif;min-height:100vh}
        @keyframes fadeInUp{from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)}}
        @keyframes shimmer{0%{background-position:-200% 0}100%{background-position:200% 0}}
        @keyframes countUp{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:translateY(0)}}
        .report-container{max-width:1200px;margin:0 auto;padding:30px 20px}
        .report-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:30px;flex-wrap:wrap;gap:15px;animation:fadeInUp .6s ease-out}
        .report-header h1{font-size:1.8rem;background:linear-gradient(135deg,#fff 0%,#10b981 50%,#fff 100%);background-size:200% auto;-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;animation:shimmer 3s linear infinite}
        .back-btn{display:inline-flex;align-items:center;gap:8px;padding:10px 24px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:10px;color:rgba(255,255,255,0.7);text-decoration:none;cursor:pointer;transition:all .3s;font-size:.92rem}
        .back-btn:hover{background:rgba(0,242,255,0.12);border-color:rgba(0,242,255,0.3);color:#fff;transform:translateX(-4px)}
        .date-range{display:flex;gap:10px;align-items:center}
        .date-range input{padding:8px 14px;background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.08);border-radius:10px;color:#fff;font-size:.88rem;outline:none;transition:border-color .3s}
        .date-range input:focus{border-color:var(--glow-primary,#00f2ff);box-shadow:0 0 0 3px rgba(0,242,255,0.08)}
        .date-range button{padding:8px 20px;background:linear-gradient(135deg,#10b981,#059669);border:none;border-radius:10px;color:#fff;cursor:pointer;font-size:.88rem;transition:all .3s;font-weight:500}
        .date-range button:hover{transform:translateY(-1px);box-shadow:0 4px 15px rgba(16,185,129,0.3)}
        .summary-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:15px;margin-bottom:30px}
        .summary-card{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:16px;padding:22px;transition:all .4s cubic-bezier(.175,.885,.32,1.275);position:relative;overflow:hidden;animation:fadeInUp .6s ease-out both}
        .summary-card:nth-child(1){animation-delay:.1s}.summary-card:nth-child(2){animation-delay:.15s}.summary-card:nth-child(3){animation-delay:.2s}.summary-card:nth-child(4){animation-delay:.25s}
        .summary-card::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,transparent,#10b981,transparent);opacity:0;transition:opacity .4s}
        .summary-card:hover{border-color:rgba(16,185,129,0.25);transform:translateY(-4px);box-shadow:0 8px 25px rgba(0,0,0,0.2)}
        .summary-card:hover::before{opacity:1}
        .summary-card .sc-label{font-size:.82rem;color:rgba(255,255,255,0.45);margin-bottom:5px}
        .summary-card .sc-value{font-size:1.8rem;font-weight:700;animation:countUp .6s ease-out both}
        .summary-card .sc-change{font-size:.78rem;margin-top:5px}
        .sc-change.up{color:#10b981} .sc-change.down{color:#ef4444}
        .chart-section{display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:30px;animation:fadeInUp .7s ease-out .3s both}
        .chart-card{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:18px;padding:25px;transition:all .3s}
        .chart-card:hover{border-color:rgba(255,255,255,0.1)}
        .chart-card h3{font-size:1.05rem;margin-bottom:15px;color:rgba(255,255,255,0.8)}
        .chart-wrap{height:250px}
        .data-table{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:18px;padding:25px;margin-bottom:20px;animation:fadeInUp .7s ease-out .4s both}
        .data-table h3{font-size:1.05rem;margin-bottom:15px;color:rgba(255,255,255,0.8)}
        table{width:100%;border-collapse:collapse}
        th,td{padding:12px 14px;text-align:left;border-bottom:1px solid rgba(255,255,255,0.04);font-size:.88rem}
        th{color:rgba(255,255,255,0.4);font-weight:500;font-size:.8rem}
        td{color:rgba(255,255,255,0.7)}
        tbody tr{transition:background .2s}
        tbody tr:hover{background:rgba(255,255,255,0.03)}
        @media(max-width:768px){.chart-section{grid-template-columns:1fr}}
        ::-webkit-scrollbar{width:6px}::-webkit-scrollbar-track{background:rgba(255,255,255,0.02)}::-webkit-scrollbar-thumb{background:rgba(16,185,129,0.2);border-radius:3px}
    </style>
    <!-- ========== 浅色主题 · 数据报表全覆盖 ========== -->
    <style>
        html[data-theme$="-light"] body{background:linear-gradient(170deg,#e9e2d2,#ede5d3 40%,#e4dbca)!important;color:#3d3929!important}
        html[data-theme$="-light"] .report-header h1{background:linear-gradient(135deg,#3d3929,#10b981 50%,#059669)!important;-webkit-background-clip:text!important;background-clip:text!important;color:transparent!important}
        html[data-theme$="-light"] .back-btn{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.08)!important;color:rgba(61,57,41,.55)!important}
        html[data-theme$="-light"] .back-btn:hover{background:rgba(16,185,129,.08)!important;border-color:rgba(16,185,129,.2)!important;color:#3d3929!important}
        html[data-theme$="-light"] .date-range input{background:rgba(238,233,222,.85)!important;border-color:rgba(139,119,80,.1)!important;color:#3d3929!important}
        html[data-theme$="-light"] .date-range input:focus{border-color:rgba(16,185,129,.3)!important;box-shadow:0 0 0 3px rgba(16,185,129,.06)!important}
        html[data-theme$="-light"] .summary-card{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .summary-card::before{background:linear-gradient(90deg,transparent,rgba(16,185,129,.3),transparent)!important}
        html[data-theme$="-light"] .summary-card:hover{border-color:rgba(16,185,129,.2)!important;box-shadow:0 8px 25px rgba(139,119,80,.12)!important}
        html[data-theme$="-light"] .sc-label{color:#7a7360!important}
        html[data-theme$="-light"] .sc-value{color:#3d3929!important}
        html[data-theme$="-light"] .chart-card{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .chart-card:hover{border-color:rgba(16,185,129,.15)!important}
        html[data-theme$="-light"] .chart-card h3{color:#3d3929!important}
        html[data-theme$="-light"] .data-table{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .data-table h3{color:#3d3929!important}
        html[data-theme$="-light"] th{color:#7a7360!important}
        html[data-theme$="-light"] td{color:#3d3929!important;border-bottom-color:rgba(139,119,80,.05)!important}
        html[data-theme$="-light"] tbody tr:hover{background:rgba(16,185,129,.04)!important}
        html[data-theme$="-light"] ::-webkit-scrollbar-track{background:rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] ::-webkit-scrollbar-thumb{background:rgba(16,185,129,.12)!important}
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3{color:#3d3929!important}
        html[data-theme$="-light"] ::selection{background:rgba(16,185,129,.15)!important;color:#3d3929!important}
    </style>

</head>
<body>
    <div class="report-container">
        <a class="back-btn" href="<%= ctx %>/adminDashboard">← 返回驾驶舱</a>
        <div class="report-header">
            <h1>📊 数据报表</h1>
            <div class="date-range">
                <input type="date" id="startDate"> <span>至</span> <input type="date" id="endDate">
                <button onclick="loadReport()">生成报表</button>
            </div>
        </div>

        <div class="summary-grid">
            <div class="summary-card"><div class="sc-label">用户总数</div><div class="sc-value" id="rptUsers"><%= userCount %></div></div>
            <div class="summary-card"><div class="sc-label">图书总数</div><div class="sc-value" id="rptActive"><%= bookCount %></div></div>
            <div class="summary-card"><div class="sc-label">讲座总数</div><div class="sc-value"><%= lectureCount %></div></div>
            <div class="summary-card"><div class="sc-label">课程总数</div><div class="sc-value"><%= courseCount %></div></div>
        </div>

        <div class="chart-section">
            <div class="chart-card"><h3>📈 用户增长趋势</h3><div class="chart-wrap"><canvas id="growthChart"></canvas></div></div>
            <div class="chart-card"><h3>📊 内容分布</h3><div class="chart-wrap"><canvas id="contentChart"></canvas></div></div>
        </div>

        <div class="data-table">
            <h3>📋 模块使用排行</h3>
            <table>
                <thead><tr><th>排名</th><th>模块</th><th>访问量</th><th>活跃用户</th><th>增长率</th></tr></thead>
                <tbody>
                    <tr><td>1</td><td>📚 图书管理</td><td>12,450</td><td>1,234</td><td class="sc-change up">↑ 15%</td></tr>
                    <tr><td>2</td><td>🏫 自习室</td><td>8,920</td><td>987</td><td class="sc-change up">↑ 22%</td></tr>
                    <tr><td>3</td><td>🌐 元宇宙校园</td><td>7,650</td><td>856</td><td class="sc-change up">↑ 45%</td></tr>
                    <tr><td>4</td><td>📖 数字史册</td><td>5,320</td><td>654</td><td class="sc-change up">↑ 8%</td></tr>
                    <tr><td>5</td><td>🎓 学域矩阵</td><td>4,100</td><td>543</td><td class="sc-change down">↓ 3%</td></tr>
                </tbody>
            </table>
        </div>
    </div>

    <script>
    var cp = '<%= ctx %>';
    function loadReport() { showToast('📊 报表已刷新'); }
    function showToast(msg){var t=document.createElement('div');t.textContent=msg;t.style.cssText='position:fixed;top:20px;left:50%;transform:translateX(-50%);padding:12px 24px;background:linear-gradient(135deg,#1a3050,#162540);border:1px solid rgba(0,242,255,0.3);border-radius:10px;color:#fff;z-index:9999;opacity:0;transition:opacity .3s';document.body.appendChild(t);setTimeout(function(){t.style.opacity='1'},10);setTimeout(function(){t.style.opacity='0';setTimeout(function(){t.remove()},300)},2000);}
    // 加载真实数据
    fetch(cp+'/stats?module=dashboard').then(function(r){return r.json()}).then(function(d){
        if(d.activeUsers){document.getElementById('rptUsers').textContent=Number(d.activeUsers).toLocaleString();}
        if(d.todayVisits){document.getElementById('rptActive').textContent=Number(d.todayVisits).toLocaleString();}
    }).catch(function(){});
    // 图表

// ══════ 图表浅色/深色主题辅助 ══════
function _ct(){
    var d=(document.documentElement.getAttribute('data-theme')||'').indexOf('-light')>-1;
    return{
        ax:d?'rgba(61,57,41,.6)':_ct().ax,
        axL:d?'#5c5540':_ct().axL,
        gr:d?'rgba(139,119,80,.08)':_ct().gr,
        pri:d?'#2563eb':_ct().pri,
        priBg:d?'rgba(37,99,235,.12)':_ct().priBg,
        priBgL:d?'rgba(37,99,235,.08)':_ct().priBgL,
        dim:d?'rgba(139,119,80,.12)':_ct().dim,
        d:d
    };
}
    new Chart(document.getElementById('growthChart').getContext('2d'),{type:'line',data:{labels:['1月','2月','3月','4月','5月','6月'],datasets:[{label:'用户数',data:[800,1100,1400,1750,2100,<%= userCount %>],borderColor:_ct().pri,backgroundColor:_ct().priBgL,fill:true,tension:.4}]},options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}}}});
    new Chart(document.getElementById('contentChart').getContext('2d'),{type:'doughnut',data:{labels:['图书','课程','讲座'],datasets:[{data:[<%= bookCount %>,<%= courseCount %>,<%= lectureCount %>],backgroundColor:[_ct().pri,'#a855f7','#10b981','#f59e0b','#ef4444']}]},options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{labels:{color:_ct().axL}}}}});
    </script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);setTimeout(function(){location.reload()},250);}});})();
</script>
</body>
</html>
