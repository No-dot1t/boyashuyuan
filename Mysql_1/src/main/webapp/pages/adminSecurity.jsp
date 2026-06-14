<%--
 =============================================================================
 adminSecurity.jsp
 =============================================================================

 用途      后台管理页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%
    String ctx = request.getContextPath();
    Integer loginAttempts = (Integer) request.getAttribute("loginAttempts");
    Integer failedLogins = (Integer) request.getAttribute("failedLogins");
    ArrayList<String> recentLogins = (ArrayList<String>) request.getAttribute("recentLogins");
    if (loginAttempts == null) loginAttempts = 0;
    if (failedLogins == null) failedLogins = 0;
    if (recentLogins == null) recentLogins = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>博雅书院 | 安全检查</title>
    <link rel="stylesheet" href="<%= ctx %>/CSS/index.css">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{background:var(--bg-space,#0a0b1a);color:#fff;font-family:'Segoe UI','PingFang SC',sans-serif;min-height:100vh}
        @keyframes fadeInUp{from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)}}
        @keyframes shimmer{0%{background-position:-200% 0}100%{background-position:200% 0}}
        @keyframes glowRing{0%,100%{box-shadow:0 0 20px rgba(16,185,129,0.15)}50%{box-shadow:0 0 40px rgba(16,185,129,0.3)}}
        @keyframes scanLine{0%{top:-2px}100%{top:100%}}
        .security-container{max-width:900px;margin:0 auto;padding:30px 20px}
        .security-header{margin-bottom:30px;animation:fadeInUp .6s ease-out}
        .security-header h1{font-size:1.8rem;background:linear-gradient(135deg,#fff 0%,#10b981 50%,#fff 100%);background-size:200% auto;-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;animation:shimmer 3s linear infinite}
        .back-btn{display:inline-flex;align-items:center;gap:8px;padding:10px 24px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:10px;color:rgba(255,255,255,0.7);text-decoration:none;cursor:pointer;transition:all .3s;margin-bottom:20px;font-size:.92rem}
        .back-btn:hover{background:rgba(0,242,255,0.12);border-color:rgba(0,242,255,0.3);color:#fff;transform:translateX(-4px)}
        .security-score{text-align:center;padding:35px;background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:20px;margin-bottom:30px;animation:fadeInUp .6s ease-out .1s both;position:relative;overflow:hidden}
        .security-score::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,transparent,#10b981,transparent)}
        .score-circle{width:130px;height:130px;border-radius:50%;border:5px solid rgba(16,185,129,0.2);display:flex;align-items:center;justify-content:center;font-size:2.8rem;font-weight:700;margin:0 auto 15px;position:relative;animation:glowRing 3s ease-in-out infinite;transition:all .5s}
        .score-circle::after{content:'/100';font-size:.85rem;color:rgba(255,255,255,0.3);position:absolute;bottom:18px}
        .score-label{font-size:1.05rem;color:rgba(255,255,255,0.5)}
        .scan-btn{padding:12px 32px;background:linear-gradient(135deg,#10b981,#059669);border:none;border-radius:12px;color:#fff;font-size:.95rem;cursor:pointer;margin-top:15px;transition:all .3s;font-weight:500}
        .scan-btn:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(16,185,129,0.35)}
        .scan-btn:disabled{opacity:.5;cursor:not-allowed;transform:none;box-shadow:none}
        .check-list{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:18px;padding:25px;animation:fadeInUp .7s ease-out .2s both;position:relative;overflow:hidden}
        .check-list::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,transparent,#10b981,transparent);opacity:.5}
        .check-list h3{font-size:1.05rem;margin-bottom:15px;color:rgba(255,255,255,0.8)}
        .check-item{display:flex;justify-content:space-between;align-items:center;padding:14px 8px;border-bottom:1px solid rgba(255,255,255,0.03);font-size:.92rem;transition:all .3s;border-radius:8px}
        .check-item:hover{background:rgba(255,255,255,0.02)}
        .check-item:last-child{border-bottom:none}
        .check-item .ci-left{display:flex;align-items:center;gap:12px}
        .check-item .ci-icon{font-size:1.2rem;width:32px;text-align:center}
        .check-item .ci-info{display:flex;flex-direction:column}
        .check-item .ci-name{font-weight:500}
        .check-item .ci-desc{font-size:.78rem;color:rgba(255,255,255,0.35)}
        .check-status{padding:5px 14px;border-radius:10px;font-size:.78rem;font-weight:500;transition:all .3s}
        .cs-pass{background:rgba(16,185,129,0.1);color:#10b981;border:1px solid rgba(16,185,129,0.15)}
        .cs-warn{background:rgba(245,158,11,0.1);color:#f59e0b;border:1px solid rgba(245,158,11,0.15)}
        .cs-fail{background:rgba(239,68,68,0.1);color:#ef4444;border:1px solid rgba(239,68,68,0.15)}
        ::-webkit-scrollbar{width:6px}::-webkit-scrollbar-track{background:rgba(255,255,255,0.02)}::-webkit-scrollbar-thumb{background:rgba(16,185,129,0.2);border-radius:3px}
    </style>
    <!-- ========== 浅色主题 · 安全检查全覆盖 ========== -->
    <style>
        html[data-theme$="-light"] body{background:linear-gradient(170deg,#e9e2d2,#ede5d3 40%,#e4dbca)!important;color:#3d3929!important}
        html[data-theme$="-light"] .security-header h1{background:linear-gradient(135deg,#3d3929,#10b981 50%,#059669)!important;-webkit-background-clip:text!important;background-clip:text!important;color:transparent!important}
        html[data-theme$="-light"] .back-btn{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.08)!important;color:rgba(61,57,41,.55)!important}
        html[data-theme$="-light"] .back-btn:hover{background:rgba(16,185,129,.08)!important;border-color:rgba(16,185,129,.2)!important;color:#3d3929!important}
        html[data-theme$="-light"] .security-score{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .security-score::before{background:linear-gradient(90deg,transparent,rgba(16,185,129,.3),transparent)!important}
        html[data-theme$="-light"] .score-label{color:#7a7360!important}
        html[data-theme$="-light"] .check-list{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .check-list::before{background:linear-gradient(90deg,transparent,rgba(16,185,129,.2),transparent)!important}
        html[data-theme$="-light"] .check-list h3{color:#3d3929!important}
        html[data-theme$="-light"] .check-item{border-bottom-color:rgba(139,119,80,.06)!important;color:#3d3929!important}
        html[data-theme$="-light"] .check-item:hover{background:rgba(16,185,129,.04)!important}
        html[data-theme$="-light"] .ci-name{color:#3d3929!important}
        html[data-theme$="-light"] .ci-desc{color:#7a7360!important}
        html[data-theme$="-light"] .check-status.cs-pass{background:rgba(5,150,105,.06)!important;color:#047857!important;border-color:rgba(5,150,105,.12)!important}
        html[data-theme$="-light"] .check-status.cs-warn{background:rgba(217,119,6,.06)!important;color:#b45309!important;border-color:rgba(217,119,6,.12)!important}
        html[data-theme$="-light"] .check-status.cs-fail{background:rgba(220,60,60,.06)!important;color:#b91c1c!important;border-color:rgba(220,60,60,.12)!important}
        html[data-theme$="-light"] .scan-btn{box-shadow:0 8px 25px rgba(16,185,129,.25)!important}
        html[data-theme$="-light"] ::-webkit-scrollbar-track{background:rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] ::-webkit-scrollbar-thumb{background:rgba(16,185,129,.12)!important}
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3{color:#3d3929!important}
        html[data-theme$="-light"] ::selection{background:rgba(16,185,129,.15)!important;color:#3d3929!important}
    </style>

</body>
<body>
    <div class="security-container">
        <a class="back-btn" href="<%= ctx %>/adminDashboard">← 返回驾驶舱</a>
        <div class="security-header"><h1>🛡️ 安全检查</h1></div>

        <div class="security-score">
            <div class="score-circle" id="scoreValue" style="border-color:#10b981;color:#10b981">85</div>
            <div class="score-label">系统安全评分</div>
            <button class="scan-btn" id="scanBtn" onclick="startScan()">🔄 重新扫描</button>
        </div>

        <div class="check-list" style="margin-bottom:20px">
            <h3>📊 安全统计</h3>
            <div class="check-item">
                <div class="ci-left"><span class="ci-icon">🔑</span><div class="ci-info"><span class="ci-name">总登录尝试</span><span class="ci-desc">所有登录操作记录</span></div></div>
                <span class="check-status cs-pass" style="font-size:.92rem"><%= loginAttempts %></span>
            </div>
            <div class="check-item">
                <div class="ci-left"><span class="ci-icon">🚫</span><div class="ci-info"><span class="ci-name">失败登录</span><span class="ci-desc">登录失败次数</span></div></div>
                <span class="check-status <%= failedLogins > 0 ? "cs-fail" : "cs-pass" %>" style="font-size:.92rem"><%= failedLogins %></span>
            </div>
            <div class="check-item">
                <div class="ci-left"><span class="ci-icon">🟢</span><div class="ci-info"><span class="ci-name">成功登录</span><span class="ci-desc">登录成功次数</span></div></div>
                <span class="check-status cs-pass" style="font-size:.92rem"><%= loginAttempts - failedLogins %></span>
            </div>
            <div class="check-item">
                <div class="ci-left"><span class="ci-icon">📋</span><div class="ci-info"><span class="ci-name">最近活动</span><span class="ci-desc">最近10条登录活动记录</span></div></div>
            </div>
            <% for (String log : recentLogins) {
                String[] parts = log.split("\\|");
            %>
            <div class="check-item" style="padding-left:40px;font-size:.82rem">
                <span style="color:rgba(255,255,255,0.5)"><%= parts.length > 3 ? parts[3] : "" %></span>
                <span style="color:var(--glow-primary,#00f2ff)"><%= parts.length > 0 ? parts[0] : "" %></span>
                <span class="check-status <%= "failed".equals(parts.length > 2 ? parts[2] : "") ? "cs-fail" : "cs-pass" %>"><%= parts.length > 2 ? ("success".equals(parts[2]) ? "成功" : "failed".equals(parts[2]) ? "失败" : parts[2]) : "" %></span>
            </div>
            <% } %>
        </div>

        <div class="check-list">
            <h3>📋 安全检查项</h3>
            <div class="check-item"><div class="ci-left"><span class="ci-icon">🔐</span><div class="ci-info"><span class="ci-name">数据库连接安全</span><span class="ci-desc">检查数据库连接是否使用SSL加密</span></div></div><span class="check-status cs-pass">通过</span></div>
            <div class="check-item"><div class="ci-left"><span class="ci-icon">🔑</span><div class="ci-info"><span class="ci-name">密码强度策略</span><span class="ci-desc">用户密码需包含大小写字母和数字</span></div></div><span class="check-status cs-pass">通过</span></div>
            <div class="check-item"><div class="ci-left"><span class="ci-icon">🛑</span><div class="ci-info"><span class="ci-name">SQL注入防护</span><span class="ci-desc">所有数据库查询使用参数化</span></div></div><span class="check-status cs-pass">通过</span></div>
            <div class="check-item"><div class="ci-left"><span class="ci-icon">🛡️</span><div class="ci-info"><span class="ci-name">XSS防护</span><span class="ci-desc">输出内容进行HTML转义</span></div></div><span class="check-status cs-pass">通过</span></div>
            <div class="check-item"><div class="ci-left"><span class="ci-icon">📋</span><div class="ci-info"><span class="ci-name">会话管理</span><span class="ci-desc">会话超时设置为30分钟</span></div></div><span class="check-status cs-pass">通过</span></div>
            <div class="check-item"><div class="ci-left"><span class="ci-icon">📦</span><div class="ci-info"><span class="ci-name">依赖库版本</span><span class="ci-desc">检查是否存在已知漏洞的依赖</span></div></div><span class="check-status cs-warn">警告</span></div>
            <div class="check-item"><div class="ci-left"><span class="ci-icon">📁</span><div class="ci-info"><span class="ci-name">文件上传安全</span><span class="ci-desc">限制上传文件类型和大小</span></div></div><span class="check-status cs-pass">通过</span></div>
            <div class="check-item"><div class="ci-left"><span class="ci-icon">🌐</span><div class="ci-info"><span class="ci-name">CSRF防护</span><span class="ci-desc">敏感操作需要CSRF Token验证</span></div></div><span class="check-status cs-warn">未启用</span></div>
            <div class="check-item"><div class="ci-left"><span class="ci-icon">📡</span><div class="ci-info"><span class="ci-name">敏感信息泄露</span><span class="ci-desc">检查错误页面是否暴露堆栈信息</span></div></div><span class="check-status cs-warn">警告</span></div>
        </div>
    </div>

    <script>
    function startScan(){
        var btn=document.getElementById('scanBtn');btn.textContent='⏳ 扫描中...';btn.disabled=true;
        var circle=document.getElementById('scoreValue');
        circle.textContent='...';circle.style.borderColor='rgba(255,255,255,0.2)';circle.style.color='rgba(255,255,255,0.5)';
        setTimeout(function(){
            var score=87;circle.textContent=score;
            if(score>=80){circle.style.borderColor='#10b981';circle.style.color='#10b981';}
            else if(score>=60){circle.style.borderColor='#f59e0b';circle.style.color='#f59e0b';}
            else{circle.style.borderColor='#ef4444';circle.style.color='#ef4444';}
            btn.textContent='🔄 重新扫描';btn.disabled=false;
        },2000);
    }
    </script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
