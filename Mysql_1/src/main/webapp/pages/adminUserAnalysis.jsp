<%--
 =============================================================================
 adminUserAnalysis.jsp
 =============================================================================

 用途      用户个人中心

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   DOM 选择器 —— querySelector / getElementById

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Map" %>
<%
    String ctx = request.getContextPath();
    Integer totalUsers = (Integer) request.getAttribute("totalUsers");
    Integer newUsers7Days = (Integer) request.getAttribute("newUsers7Days");
    Map<String, Integer> roleDistribution = (Map<String, Integer>) request.getAttribute("roleDistribution");
    if (totalUsers == null) totalUsers = 0;
    if (newUsers7Days == null) newUsers7Days = 0;
    if (roleDistribution == null) roleDistribution = new java.util.HashMap<>();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>博雅书院 | 用户分析</title>
    <link rel="stylesheet" href="<%= ctx %>/CSS/index.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{background:var(--bg-space,#0a0b1a);color:#fff;font-family:'Segoe UI','PingFang SC',sans-serif;min-height:100vh}
        @keyframes fadeInUp{from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)}}
        @keyframes shimmer{0%{background-position:-200% 0}100%{background-position:200% 0}}
        .analysis-container{max-width:1200px;margin:0 auto;padding:30px 20px}
        .analysis-header{margin-bottom:30px;animation:fadeInUp .6s ease-out}
        .analysis-header h1{font-size:1.8rem;background:linear-gradient(135deg,#fff 0%,#a855f7 50%,#fff 100%);background-size:200% auto;-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;animation:shimmer 3s linear infinite}
        .back-btn{display:inline-flex;align-items:center;gap:8px;padding:10px 24px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:10px;color:rgba(255,255,255,0.7);text-decoration:none;cursor:pointer;transition:all .3s;margin-bottom:20px;font-size:.92rem}
        .back-btn:hover{background:rgba(0,242,255,0.12);border-color:rgba(0,242,255,0.3);color:#fff;transform:translateX(-4px)}
        .summary-row{display:grid;grid-template-columns:repeat(4,1fr);gap:15px;margin-bottom:30px}
        .summary-card{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:16px;padding:22px;text-align:center;transition:all .4s cubic-bezier(.175,.885,.32,1.275);animation:fadeInUp .6s ease-out both}
        .summary-card:nth-child(1){animation-delay:.1s}.summary-card:nth-child(2){animation-delay:.15s}.summary-card:nth-child(3){animation-delay:.2s}.summary-card:nth-child(4){animation-delay:.25s}
        .summary-card:hover{border-color:rgba(168,85,247,0.25);transform:translateY(-4px);box-shadow:0 8px 25px rgba(0,0,0,0.2)}
        .summary-card .sv{font-size:1.8rem;font-weight:700;color:#a855f7}
        .summary-card .sl{font-size:.78rem;color:rgba(255,255,255,0.4);margin-top:5px}
        .chart-row{display:grid;grid-template-columns:2fr 1fr;gap:20px;margin-bottom:30px;animation:fadeInUp .7s ease-out .3s both}
        .chart-card{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:18px;padding:25px;transition:all .3s}
        .chart-card:hover{border-color:rgba(255,255,255,0.1)}
        .chart-card h3{font-size:1.05rem;margin-bottom:15px;color:rgba(255,255,255,0.8)}
        .chart-wrap{height:280px}
        .rank-list{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:18px;padding:25px;animation:fadeInUp .7s ease-out .4s both}
        .rank-list h3{font-size:1.05rem;margin-bottom:15px;color:rgba(255,255,255,0.8)}
        .rank-item{display:flex;align-items:center;gap:12px;padding:11px 8px;border-bottom:1px solid rgba(255,255,255,0.03);font-size:.9rem;transition:all .3s;border-radius:8px}
        .rank-item:hover{background:rgba(255,255,255,0.03)}
        .rank-item:last-child{border-bottom:none}
        .rank-num{width:30px;height:30px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:.82rem;flex-shrink:0}
        .rank-num.top{background:linear-gradient(135deg,#f59e0b,#d97706);color:#000;box-shadow:0 2px 8px rgba(245,158,11,0.3)}
        .rank-num.normal{background:rgba(255,255,255,0.06)}
        .rank-name{flex:1}.rank-val{color:#a855f7;font-weight:600}
        @media(max-width:768px){.summary-row{grid-template-columns:1fr 1fr}.chart-row{grid-template-columns:1fr}}
        ::-webkit-scrollbar{width:6px}::-webkit-scrollbar-track{background:rgba(255,255,255,0.02)}::-webkit-scrollbar-thumb{background:rgba(168,85,247,0.2);border-radius:3px}
    </style>
    <!-- ========== 浅色主题 · 用户分析全覆盖 ========== -->
    <style>
        html[data-theme$="-light"] body{background:linear-gradient(170deg,#e9e2d2,#ede5d3 40%,#e4dbca)!important;color:#3d3929!important}
        html[data-theme$="-light"] .analysis-header h1{background:linear-gradient(135deg,#3d3929,#a855f7 50%,#7c3aed)!important;-webkit-background-clip:text!important;background-clip:text!important;color:transparent!important}
        html[data-theme$="-light"] .back-btn{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.08)!important;color:rgba(61,57,41,.55)!important}
        html[data-theme$="-light"] .back-btn:hover{background:rgba(168,85,247,.08)!important;border-color:rgba(168,85,247,.2)!important;color:#3d3929!important}
        html[data-theme$="-light"] .summary-card{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .summary-card:hover{border-color:rgba(168,85,247,.2)!important;box-shadow:0 8px 25px rgba(139,119,80,.12)!important}
        html[data-theme$="-light"] .sv{color:#7c3aed!important}
        html[data-theme$="-light"] .sl{color:#7a7360!important}
        html[data-theme$="-light"] .chart-card{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .chart-card:hover{border-color:rgba(168,85,247,.15)!important}
        html[data-theme$="-light"] .chart-card h3{color:#3d3929!important}
        html[data-theme$="-light"] .rank-list{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .rank-list h3{color:#3d3929!important}
        html[data-theme$="-light"] .rank-item{border-bottom-color:rgba(139,119,80,.06)!important;color:#3d3929!important}
        html[data-theme$="-light"] .rank-item:hover{background:rgba(168,85,247,.04)!important}
        html[data-theme$="-light"] .rank-num.normal{background:rgba(139,119,80,.06)!important;color:#3d3929!important}
        html[data-theme$="-light"] .rank-val{color:#7c3aed!important}
        html[data-theme$="-light"] ::-webkit-scrollbar-track{background:rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] ::-webkit-scrollbar-thumb{background:rgba(168,85,247,.12)!important}
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3{color:#3d3929!important}
        html[data-theme$="-light"] ::selection{background:rgba(168,85,247,.15)!important;color:#3d3929!important}
    </style>

</body>
<body>
    <div class="analysis-container">
        <a class="back-btn" href="<%= ctx %>/adminDashboard">← 返回驾驶舱</a>
        <div class="analysis-header"><h1>👥 用户分析</h1></div>

        <div class="summary-row">
            <div class="summary-card"><div class="sv"><%= totalUsers %></div><div class="sl">总用户数</div></div>
            <div class="summary-card"><div class="sv"><%= newUsers7Days %></div><div class="sl">7天新增</div></div>
            <div class="summary-card"><div class="sv"><%= totalUsers > 0 ? String.format("%.1f%%", (double) newUsers7Days / totalUsers * 100) : "0%" %></div><div class="sl">新增率</div></div>
            <div class="summary-card"><div class="sv"><%= roleDistribution.size() %></div><div class="sl">角色种类</div></div>
        </div>

        <div class="chart-row">
            <div class="chart-card"><h3>📈 用户注册趋势</h3><div class="chart-wrap"><canvas id="regChart"></canvas></div></div>
            <div class="chart-card"><h3>🎯 用户角色分布</h3><div class="chart-wrap"><canvas id="roleChart"></canvas></div></div>
        </div>

        <div class="rank-list">
            <h3>🏆 活跃度排行 TOP10</h3>
            <div class="rank-item"><div class="rank-num top">1</div><div class="rank-name">张同学</div><div class="rank-val">1,245 积分</div></div>
            <div class="rank-item"><div class="rank-num top">2</div><div class="rank-name">李同学</div><div class="rank-val">1,180 积分</div></div>
            <div class="rank-item"><div class="rank-num top">3</div><div class="rank-name">王同学</div><div class="rank-val">1,056 积分</div></div>
            <div class="rank-item"><div class="rank-num normal">4</div><div class="rank-name">赵同学</div><div class="rank-val">987 积分</div></div>
            <div class="rank-item"><div class="rank-num normal">5</div><div class="rank-name">孙同学</div><div class="rank-val">923 积分</div></div>
            <div class="rank-item"><div class="rank-num normal">6</div><div class="rank-name">周同学</div><div class="rank-val">876 积分</div></div>
            <div class="rank-item"><div class="rank-num normal">7</div><div class="rank-name">吴同学</div><div class="rank-val">812 积分</div></div>
            <div class="rank-item"><div class="rank-num normal">8</div><div class="rank-name">郑同学</div><div class="rank-val">756 积分</div></div>
            <div class="rank-item"><div class="rank-num normal">9</div><div class="rank-name">陈同学</div><div class="rank-val">698 积分</div></div>
            <div class="rank-item"><div class="rank-num normal">10</div><div class="rank-name">林同学</div><div class="rank-val">645 积分</div></div>
        </div>
    </div>

    <script>

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
    new Chart(document.getElementById('regChart').getContext('2d'),{type:'bar',data:{labels:['1月','2月','3月','4月','5月','6月'],datasets:[{label:'新注册',data:[120,180,240,310,280,350],backgroundColor:_ct().priBg,borderColor:_ct().pri,borderWidth:1}]},options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}},scales:{y:{beginAtZero:true,ticks:{color:_ct().ax}},x:{ticks:{color:_ct().ax}}}}});
    new Chart(document.getElementById('roleChart').getContext('2d'),{type:'pie',data:{labels:[<% 
        int ri = 0;
        for (Map.Entry<String, Integer> e : roleDistribution.entrySet()) {
            String roleName = e.getKey();
            if ("admin".equals(roleName)) roleName = "管理员";
            else if ("user".equals(roleName)) roleName = "普通用户";
            else if ("teacher".equals(roleName)) roleName = "教师";
            else if ("student".equals(roleName)) roleName = "学生";
        %>'<%= roleName %>'<%= (++ri < roleDistribution.size()) ? "," : "" %><% } %>],datasets:[{data:[<%
        int di = 0;
        for (Map.Entry<String, Integer> e : roleDistribution.entrySet()) {
        %><%= e.getValue() %><%= (++di < roleDistribution.size()) ? "," : "" %><% } %>],backgroundColor:[_ct().pri,'#a855f7','#f59e0b',_ct().dim,'#10b981','#ef4444']}]},options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{labels:{color:_ct().axL}}}}});
    </script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);setTimeout(function(){location.reload()},250);}});})();
</script>
</body>
</html>
