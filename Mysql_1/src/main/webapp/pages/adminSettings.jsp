<%--
 =============================================================================
 adminSettings.jsp
 =============================================================================

 用途      后台管理页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Map" %>
<%
    String ctx = request.getContextPath();
    Map<String, String> settings = (Map<String, String>) request.getAttribute("settings");
    if (settings == null) settings = new java.util.HashMap<>();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>博雅书院 | 系统设置</title>
    <link rel="stylesheet" href="<%= ctx %>/CSS/index.css">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{background:var(--bg-space,#0a0b1a);color:#fff;font-family:'Segoe UI','PingFang SC',sans-serif;min-height:100vh}
        @keyframes fadeInUp{from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)}}
        @keyframes shimmer{0%{background-position:-200% 0}100%{background-position:200% 0}}
        .settings-container{max-width:800px;margin:0 auto;padding:30px 20px}
        .settings-header{margin-bottom:30px;animation:fadeInUp .6s ease-out}
        .settings-header h1{font-size:1.8rem;margin-bottom:10px;background:linear-gradient(135deg,#fff 0%,#f59e0b 50%,#fff 100%);background-size:200% auto;-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;animation:shimmer 3s linear infinite}
        .back-btn{display:inline-flex;align-items:center;gap:8px;padding:10px 24px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:10px;color:rgba(255,255,255,0.7);text-decoration:none;cursor:pointer;transition:all .3s;margin-bottom:20px;font-size:.92rem}
        .back-btn:hover{background:rgba(0,242,255,0.12);border-color:rgba(0,242,255,0.3);color:#fff;transform:translateX(-4px)}
        .settings-group{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:18px;padding:25px;margin-bottom:20px;transition:all .3s;animation:fadeInUp .6s ease-out both;position:relative;overflow:hidden}
        .settings-group:nth-child(3){animation-delay:.1s}.settings-group:nth-child(4){animation-delay:.2s}.settings-group:nth-child(5){animation-delay:.25s}.settings-group:nth-child(6){animation-delay:.3s}
        .settings-group::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,transparent,rgba(245,158,11,0.5),transparent);opacity:0;transition:opacity .4s}
        .settings-group:hover{border-color:rgba(245,158,11,0.2);background:rgba(255,255,255,0.03)}
        .settings-group:hover::before{opacity:1}
        .settings-group h3{font-size:1.05rem;margin-bottom:20px;padding-bottom:10px;border-bottom:1px solid rgba(255,255,255,0.05);display:flex;align-items:center;gap:8px}
        .setting-row{display:flex;justify-content:space-between;align-items:center;padding:13px 0;border-bottom:1px solid rgba(255,255,255,0.03);transition:background .2s}
        .setting-row:last-child{border-bottom:none}
        .setting-row:hover{background:rgba(255,255,255,0.02);margin:0 -12px;padding-left:12px;padding-right:12px;border-radius:8px}
        .setting-label{font-size:.92rem}
        .setting-desc{font-size:.78rem;color:rgba(255,255,255,0.35);margin-top:3px}
        .setting-input{padding:9px 14px;background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.08);border-radius:10px;color:#fff;font-size:.9rem;width:200px;outline:none;transition:all .3s}
        .setting-input:focus{border-color:#f59e0b;box-shadow:0 0 0 3px rgba(245,158,11,0.08)}
        .setting-select{padding:9px 14px;background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.08);border-radius:10px;color:#fff;font-size:.9rem;outline:none;transition:border-color .3s}
        .setting-select:focus{border-color:#f59e0b}
        .toggle{width:48px;height:26px;background:rgba(255,255,255,0.1);border-radius:13px;cursor:pointer;position:relative;transition:all .3s}
        .toggle.active{background:linear-gradient(135deg,#f59e0b,#d97706);box-shadow:0 0 12px rgba(245,158,11,0.3)}
        .toggle::after{content:'';width:22px;height:22px;background:#fff;border-radius:50%;position:absolute;top:2px;left:2px;transition:transform .3s cubic-bezier(.68,-.55,.265,1.55)}
        .toggle.active::after{transform:translateX(22px)}
        .save-btn{width:100%;padding:14px;background:linear-gradient(135deg,#f59e0b,#d97706);border:none;border-radius:12px;color:#fff;font-size:1rem;font-weight:600;cursor:pointer;transition:all .3s;margin-top:10px;animation:fadeInUp .6s ease-out .35s both}
        .save-btn:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(245,158,11,0.3)}
        .save-btn:active{transform:translateY(0)}
        ::-webkit-scrollbar{width:6px}::-webkit-scrollbar-track{background:rgba(255,255,255,0.02)}::-webkit-scrollbar-thumb{background:rgba(245,158,11,0.2);border-radius:3px}
    </style>
    <!-- ========== 浅色主题 · 系统设置全覆盖 ========== -->
    <style>
        /* ── 基础底色 ── */
        html[data-theme$="-light"] body{background:linear-gradient(170deg,#e9e2d2,#ede5d3 40%,#e4dbca)!important;color:#3d3929!important}
        /* ── 容器/头部 ── */
        html[data-theme$="-light"] .settings-header h1{background:linear-gradient(135deg,#3d3929,#f59e0b 50%,#d97706)!important;-webkit-background-clip:text!important;background-clip:text!important;color:transparent!important}
        html[data-theme$="-light"] .settings-header p{color:rgba(61,57,41,.45)!important}
        /* ── 返回按钮 ── */
        html[data-theme$="-light"] .back-btn{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.08)!important;color:rgba(61,57,41,.55)!important}
        html[data-theme$="-light"] .back-btn:hover{background:rgba(245,158,11,.08)!important;border-color:rgba(245,158,11,.2)!important;color:#3d3929!important}
        /* ── 设置分组卡片 ── */
        html[data-theme$="-light"] .settings-group{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .settings-group:hover{background:rgba(243,239,228,.9)!important;border-color:rgba(245,158,11,.15)!important}
        html[data-theme$="-light"] .settings-group::before{background:linear-gradient(90deg,transparent,rgba(245,158,11,.3),transparent)!important}
        html[data-theme$="-light"] .settings-group h3{color:#3d3929!important;border-bottom-color:rgba(139,119,80,.06)!important}
        /* ── 设置行 ── */
        html[data-theme$="-light"] .setting-row{border-bottom-color:rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] .setting-row:hover{background:rgba(139,119,80,.03)!important}
        html[data-theme$="-light"] .setting-label{color:#3d3929!important}
        html[data-theme$="-light"] .setting-desc{color:#7a7360!important}
        /* ── 输入/选择 ── */
        html[data-theme$="-light"] .setting-input{background:rgba(238,233,222,.85)!important;border-color:rgba(139,119,80,.1)!important;color:#3d3929!important}
        html[data-theme$="-light"] .setting-input:focus{border-color:rgba(245,158,11,.3)!important;box-shadow:0 0 0 3px rgba(245,158,11,.06)!important}
        html[data-theme$="-light"] .setting-select{background:rgba(238,233,222,.85)!important;border-color:rgba(139,119,80,.1)!important;color:#3d3929!important}
        html[data-theme$="-light"] .setting-select:focus{border-color:rgba(245,158,11,.3)!important}
        html[data-theme$="-light"] .setting-select option{background:#f0ebe0!important;color:#3d3929!important}
        /* ── Toggle 开关 ── */
        html[data-theme$="-light"] .toggle{background:rgba(139,119,80,.12)!important}
        html[data-theme$="-light"] .toggle.active{background:linear-gradient(135deg,#f59e0b,#d97706)!important;box-shadow:0 0 12px rgba(245,158,11,.2)!important}
        /* ── 保存按钮 ── */
        html[data-theme$="-light"] .save-btn{background:linear-gradient(135deg,#f59e0b,#d97706)!important;color:#fff!important}
        html[data-theme$="-light"] .save-btn:hover{box-shadow:0 8px 25px rgba(245,158,11,.25)!important}
        /* ── 滚动条 ── */
        html[data-theme$="-light"] ::-webkit-scrollbar-track{background:rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] ::-webkit-scrollbar-thumb{background:rgba(245,158,11,.15)!important}
        /* ── 通用 ── */
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3,html[data-theme$="-light"] h4{color:#3d3929!important}
        html[data-theme$="-light"] p,html[data-theme$="-light"] span,html[data-theme$="-light"] label,html[data-theme$="-light"] div{color:inherit!important}
        html[data-theme$="-light"] ::selection{background:rgba(245,158,11,.15)!important;color:#3d3929!important}
    </style>

</head>
<body>
    <div class="settings-container">
        <a class="back-btn" href="<%= ctx %>/adminDashboard">← 返回驾驶舱</a>
        <div class="settings-header">
            <h1>🔧 系统设置</h1>
            <p style="color:rgba(255,255,255,0.5)">配置系统基本参数</p>
        </div>

        <div class="settings-group">
            <h3>🌐 基本设置</h3>
            <div class="setting-row">
                <div><div class="setting-label">站点名称</div><div class="setting-desc">显示在浏览器标签和页面头部</div></div>
                <input class="setting-input" id="siteName" value="博雅书院">
            </div>
            <div class="setting-row">
                <div><div class="setting-label">站点描述</div><div class="setting-desc">用于SEO和页面副标题</div></div>
                <input class="setting-input" id="siteDesc" value="智能校园管理平台">
            </div>
            <div class="setting-row">
                <div><div class="setting-label">默认语言</div></div>
                <select class="setting-select" id="lang"><option value="zh">简体中文</option><option value="en">English</option></select>
            </div>
        </div>

        <div class="settings-group">
            <h3>📊 显示设置</h3>
            <div class="setting-row">
                <div><div class="setting-label">每页显示条数</div></div>
                <select class="setting-select" id="pageSize"><option value="10">10 条</option><option value="20" selected>20 条</option><option value="50">50 条</option></select>
            </div>
            <div class="setting-row">
                <div><div class="setting-label">默认主题</div></div>
                <select class="setting-select" id="theme"><option value="dark" selected>深色模式</option><option value="light">浅色模式</option></select>
            </div>
            <div class="setting-row">
                <div><div class="setting-label">动画效果</div></div>
                <div class="toggle active" onclick="this.classList.toggle('active')"></div>
            </div>
        </div>

        <div class="settings-group">
            <h3>🔒 安全设置</h3>
            <div class="setting-row">
                <div><div class="setting-label">登录失败锁定</div><div class="setting-desc">连续失败5次后锁定账户30分钟</div></div>
                <div class="toggle active" onclick="this.classList.toggle('active')"></div>
            </div>
            <div class="setting-row">
                <div><div class="setting-label">会话超时(分钟)</div></div>
                <input class="setting-input" id="sessionTimeout" type="number" value="30" min="5" max="480">
            </div>
            <div class="setting-row">
                <div><div class="setting-label">操作日志记录</div><div class="setting-desc">记录用户关键操作</div></div>
                <div class="toggle active" onclick="this.classList.toggle('active')"></div>
            </div>
        </div>

        <div class="settings-group">
            <h3>📬 通知设置</h3>
            <div class="setting-row">
                <div><div class="setting-label">邮件通知</div></div>
                <div class="toggle" onclick="this.classList.toggle('active')"></div>
            </div>
            <div class="setting-row">
                <div><div class="setting-label">系统通知</div></div>
                <div class="toggle active" onclick="this.classList.toggle('active')"></div>
            </div>
        </div>

        <button class="save-btn" onclick="saveSettings()">💾 保存设置</button>
    </div>

    <script>
    var cp = '<%= ctx %>';
    // 从服务端加载设置
    function loadSettings(){
        fetch(cp+'/adminSettings').then(function(r){return r.text()}).then(function(html){
            // 页面已由服务端渲染，只需读取属性
        }).catch(function(){});
        // 应用服务端设置到表单
        <% for (Map.Entry<String, String> entry : settings.entrySet()) {
            String key = entry.getKey();
            String val = entry.getValue();
        %>
        try { var el = document.getElementById('<%= key %>'); if(el) el.value = '<%= val.replace("'","\\'") %>'; } catch(e){}
        <% } %>
    }

    function saveSettings(){
        var settings={
            siteName:document.getElementById('siteName').value,
            siteDesc:document.getElementById('siteDesc').value,
            lang:document.getElementById('lang').value,
            pageSize:document.getElementById('pageSize').value,
            theme:document.getElementById('theme').value,
            sessionTimeout:document.getElementById('sessionTimeout').value
        };
        fetch(cp+'/adminSettings',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(settings)})
        .then(function(r){return r.json()}).then(function(d){
            var btn=document.querySelector('.save-btn');
            if(d.success){
                btn.textContent='✅ 设置已保存！';btn.style.background='linear-gradient(135deg,#10b981,#059669)';
            }else{
                btn.textContent='❌ 保存失败';btn.style.background='linear-gradient(135deg,#ef4444,#dc2626)';
            }
            setTimeout(function(){btn.textContent='💾 保存设置';btn.style.background='';},2000);
        }).catch(function(){
            var btn=document.querySelector('.save-btn');
            btn.textContent='❌ 网络错误';btn.style.background='linear-gradient(135deg,#ef4444,#dc2626)';
            setTimeout(function(){btn.textContent='💾 保存设置';btn.style.background='';},2000);
        });
    }
    loadSettings();
    </script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
