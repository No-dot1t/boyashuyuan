<%--
 =============================================================================
 adminLogs.jsp
 =============================================================================

 用途      后台管理页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%
    String ctx = request.getContextPath();
    ArrayList<Map<String, Object>> logList = (ArrayList<Map<String, Object>>) request.getAttribute("logList");
    Integer logCount = (Integer) request.getAttribute("logCount");
    if (logList == null) logList = new ArrayList<>();
    if (logCount == null) logCount = 0;
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>博雅书院 | 操作日志</title>
    <link rel="stylesheet" href="<%= ctx %>/CSS/index.css">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{background:var(--bg-space,#0a0b1a);color:#fff;font-family:'Segoe UI','PingFang SC',sans-serif;min-height:100vh}
        @keyframes fadeInUp{from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)}}
        @keyframes shimmer{0%{background-position:-200% 0}100%{background-position:200% 0}}
        .logs-container{max-width:1200px;margin:0 auto;padding:30px 20px}
        .logs-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;flex-wrap:wrap;gap:15px;animation:fadeInUp .6s ease-out}
        .logs-header h1{font-size:1.8rem;background:linear-gradient(135deg,#fff 0%,#f59e0b 50%,#fff 100%);background-size:200% auto;-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;animation:shimmer 3s linear infinite}
        .back-btn{display:inline-flex;align-items:center;gap:8px;padding:10px 24px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:10px;color:rgba(255,255,255,0.7);text-decoration:none;cursor:pointer;transition:all .3s;font-size:.92rem}
        .back-btn:hover{background:rgba(0,242,255,0.12);border-color:rgba(0,242,255,0.3);color:#fff;transform:translateX(-4px)}
        .filter-bar{display:flex;gap:10px;margin-bottom:20px;flex-wrap:wrap;animation:fadeInUp .6s ease-out .1s both}
        .filter-input{padding:9px 14px;background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.08);border-radius:10px;color:#fff;font-size:.88rem;outline:none;transition:all .3s}
        .filter-input:focus{border-color:#f59e0b;box-shadow:0 0 0 3px rgba(245,158,11,0.08)}
        .filter-select{padding:9px 14px;background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.08);border-radius:10px;color:#fff;font-size:.88rem;outline:none;transition:border-color .3s}
        .filter-select:focus{border-color:#f59e0b}
        .log-table{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:18px;overflow:hidden;animation:fadeInUp .7s ease-out .2s both}
        table{width:100%;border-collapse:collapse}
        th,td{padding:13px 16px;text-align:left;border-bottom:1px solid rgba(255,255,255,0.03);font-size:.88rem}
        th{background:rgba(0,0,0,0.15);color:rgba(255,255,255,0.45);font-weight:500;font-size:.78rem;text-transform:uppercase;letter-spacing:.3px}
        td{color:rgba(255,255,255,0.7)}
        tbody tr{transition:background .2s}
        tbody tr:hover{background:rgba(255,255,255,0.03)}
        .log-type{padding:4px 10px;border-radius:8px;font-size:.72rem;display:inline-block;font-weight:500}
        .log-type.login{background:rgba(16,185,129,0.1);color:#10b981;border:1px solid rgba(16,185,129,0.15)}
        .log-type.action{background:rgba(59,130,246,0.1);color:#3b82f6;border:1px solid rgba(59,130,246,0.15)}
        .log-type.system{background:rgba(245,158,11,0.1);color:#f59e0b;border:1px solid rgba(245,158,11,0.15)}
        .log-type.error{background:rgba(239,68,68,0.1);color:#ef4444;border:1px solid rgba(239,68,68,0.15)}
        .log-user{color:var(--glow-primary,#00f2ff);font-weight:500}
        .pagination{display:flex;justify-content:center;gap:8px;margin-top:20px;animation:fadeInUp .6s ease-out .3s both}
        .page-btn{padding:8px 14px;background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.07);border-radius:10px;color:rgba(255,255,255,0.5);cursor:pointer;font-size:.85rem;transition:all .3s}
        .page-btn.active,.page-btn:hover{background:rgba(245,158,11,0.12);border-color:rgba(245,158,11,0.3);color:#fff}
        .empty-msg{text-align:center;padding:40px;color:rgba(255,255,255,0.35)}
        ::-webkit-scrollbar{width:6px}::-webkit-scrollbar-track{background:rgba(255,255,255,0.02)}::-webkit-scrollbar-thumb{background:rgba(245,158,11,0.2);border-radius:3px}
    </style>
    <!-- ========== 浅色主题 · 操作日志全覆盖 ========== -->
    <style>
        html[data-theme$="-light"] body{background:linear-gradient(170deg,#e9e2d2,#ede5d3 40%,#e4dbca)!important;color:#3d3929!important}
        html[data-theme$="-light"] .logs-header h1{background:linear-gradient(135deg,#3d3929,#f59e0b 50%,#d97706)!important;-webkit-background-clip:text!important;background-clip:text!important;color:transparent!important}
        html[data-theme$="-light"] .back-btn{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.08)!important;color:rgba(61,57,41,.55)!important}
        html[data-theme$="-light"] .back-btn:hover{background:rgba(245,158,11,.08)!important;border-color:rgba(245,158,11,.2)!important;color:#3d3929!important}
        html[data-theme$="-light"] .filter-input{background:rgba(238,233,222,.85)!important;border-color:rgba(139,119,80,.1)!important;color:#3d3929!important}
        html[data-theme$="-light"] .filter-input:focus{border-color:rgba(245,158,11,.3)!important;box-shadow:0 0 0 3px rgba(245,158,11,.06)!important}
        html[data-theme$="-light"] .filter-select{background:rgba(238,233,222,.85)!important;border-color:rgba(139,119,80,.1)!important;color:#3d3929!important}
        html[data-theme$="-light"] .filter-select:focus{border-color:rgba(245,158,11,.3)!important}
        html[data-theme$="-light"] .log-table{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] th{background:rgba(139,119,80,.04)!important;color:#7a7360!important}
        html[data-theme$="-light"] td{color:#3d3929!important;border-bottom-color:rgba(139,119,80,.05)!important}
        html[data-theme$="-light"] tbody tr:hover{background:rgba(245,158,11,.04)!important}
        html[data-theme$="-light"] .log-type.login{background:rgba(5,150,105,.06)!important;color:#047857!important;border-color:rgba(5,150,105,.12)!important}
        html[data-theme$="-light"] .log-type.action{background:rgba(37,99,235,.06)!important;color:#2563eb!important;border-color:rgba(37,99,235,.12)!important}
        html[data-theme$="-light"] .log-type.system{background:rgba(217,119,6,.06)!important;color:#b45309!important;border-color:rgba(217,119,6,.12)!important}
        html[data-theme$="-light"] .log-type.error{background:rgba(220,60,60,.06)!important;color:#b91c1c!important;border-color:rgba(220,60,60,.12)!important}
        html[data-theme$="-light"] .log-user{color:#2563eb!important}
        html[data-theme$="-light"] .page-btn{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.06)!important;color:#7a7360!important}
        html[data-theme$="-light"] .page-btn.active,.page-btn:hover{background:rgba(245,158,11,.1)!important;border-color:rgba(245,158,11,.2)!important;color:#3d3929!important}
        html[data-theme$="-light"] .empty-msg{color:#7a7360!important}
        html[data-theme$="-light"] ::-webkit-scrollbar-track{background:rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] ::-webkit-scrollbar-thumb{background:rgba(245,158,11,.12)!important}
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3{color:#3d3929!important}
        html[data-theme$="-light"] ::selection{background:rgba(245,158,11,.15)!important;color:#3d3929!important}
    </style>

</head>
<body>
    <div class="logs-container">
        <a class="back-btn" href="<%= ctx %>/adminDashboard">← 返回驾驶舱</a>
        <div class="logs-header"><h1>🔍 操作日志</h1></div>

        <div class="filter-bar">
            <input class="filter-input" placeholder="搜索用户/操作..." id="logSearch" oninput="filterLogs()">
            <select class="filter-select" id="logTypeFilter" onchange="filterLogs()">
                <option value="all">全部类型</option>
                <option value="login">登录</option>
                <option value="action">操作</option>
                <option value="system">系统</option>
                <option value="error">错误</option>
            </select>
            <input class="filter-input" type="date" id="logDate" onchange="filterLogs()">
        </div>

        <div class="log-table">
            <table>
                <thead><tr><th>时间</th><th>用户</th><th>类型</th><th>操作</th><th>IP</th><th>状态</th></tr></thead>
                <tbody id="logBody"></tbody>
            </table>
        </div>

        <div class="pagination" id="pagination"></div>
    </div>

    <script>
    var logs = [
        <% for (int i = 0; i < logList.size(); i++) {
            Map<String, Object> log = logList.get(i);
            String time = (String) log.get("createdAt");
            String user = (String) log.get("username");
            String type = (String) log.get("actionType");
            String action = (String) log.get("action");
            String ip = (String) log.get("ipAddress");
            String status = (String) log.get("status");
            String statusText = "success".equals(status) ? "成功" : "failed".equals(status) ? "失败" : "拒绝".equals(status) ? "拒绝" : (status != null ? status : "");
        %>
        {time:'<%= time != null ? time.replace("'","\\'") : "" %>',user:'<%= user != null ? user.replace("'","\\'") : "" %>',type:'<%= type != null ? type : "" %>',action:'<%= action != null ? action.replace("'","\\'") : "" %>',ip:'<%= ip != null ? ip : "" %>',status:'<%= statusText %>'}<%= i < logList.size() - 1 ? "," : "" %>
        <% } %>
    ];
    var pageSize = 10, currentPage = 1;
    function filterLogs() {
        var search = document.getElementById('logSearch').value.toLowerCase();
        var typeFilter = document.getElementById('logTypeFilter').value;
        var dateFilter = document.getElementById('logDate').value;
        var filtered = logs.filter(function(l) {
            if (search && (l.user+ l.action).toLowerCase().indexOf(search) < 0) return false;
            if (typeFilter !== 'all' && l.type !== typeFilter) return false;
            if (dateFilter && !l.time.startsWith(dateFilter)) return false;
            return true;
        });
        currentPage = 1;
        renderLogs(filtered);
    }
    function renderLogs(data) {
        var body = document.getElementById('logBody');
        var start = (currentPage - 1) * pageSize;
        var page = data.slice(start, start + pageSize);
        if (page.length === 0) { body.innerHTML = '<tr><td colspan="6" class="empty-msg">暂无匹配日志</td></tr>'; }
        else {
            body.innerHTML = page.map(function(l) {
                return '<tr><td>' + l.time + '</td><td class="log-user">' + l.user + '</td><td><span class="log-type ' + l.type + '">' + ({login:'登录',action:'操作',system:'系统',error:'错误'}[l.type]) + '</span></td><td>' + l.action + '</td><td style="color:rgba(255,255,255,0.4)">' + l.ip + '</td><td style="color:' + (l.status==='成功'?'#10b981':'#ef4444') + '">' + l.status + '</td></tr>';
            }).join('');
        }
        var total = Math.ceil(data.length / pageSize);
        var pg = document.getElementById('pagination');
        pg.innerHTML = '';
        for (var i = 1; i <= total; i++) {
            pg.innerHTML += '<span class="page-btn' + (i===currentPage?' active':'') + '" onclick="currentPage=' + i + ';filterLogs()">' + i + '</span>';
        }
    }
    filterLogs();
    </script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
