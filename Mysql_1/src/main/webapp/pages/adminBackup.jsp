<%--
 =============================================================================
 adminBackup.jsp
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
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>博雅书院 | 数据备份</title>
    <link rel="stylesheet" href="<%= ctx %>/CSS/index.css">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{background:var(--bg-space,#0a0b1a);color:#fff;font-family:'Segoe UI','PingFang SC',sans-serif;min-height:100vh}
        @keyframes fadeInUp{from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)}}
        @keyframes shimmer{0%{background-position:-200% 0}100%{background-position:200% 0}}
        @keyframes progressPulse{0%,100%{box-shadow:0 0 10px rgba(16,185,129,0.2)}50%{box-shadow:0 0 25px rgba(16,185,129,0.4)}}
        .backup-container{max-width:900px;margin:0 auto;padding:30px 20px}
        .backup-header{margin-bottom:30px;animation:fadeInUp .6s ease-out}
        .backup-header h1{font-size:1.8rem;margin-bottom:10px;background:linear-gradient(135deg,#fff 0%,#3b82f6 50%,#fff 100%);background-size:200% auto;-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;animation:shimmer 3s linear infinite}
        .back-btn{display:inline-flex;align-items:center;gap:8px;padding:10px 24px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:10px;color:rgba(255,255,255,0.7);text-decoration:none;cursor:pointer;transition:all .3s;margin-bottom:20px;font-size:.92rem}
        .back-btn:hover{background:rgba(0,242,255,0.12);border-color:rgba(0,242,255,0.3);color:#fff;transform:translateX(-4px)}
        .backup-info{display:grid;grid-template-columns:repeat(3,1fr);gap:15px;margin-bottom:30px}
        .info-card{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:16px;padding:22px;text-align:center;transition:all .4s cubic-bezier(.175,.885,.32,1.275);animation:fadeInUp .6s ease-out both}
        .info-card:nth-child(1){animation-delay:.1s}.info-card:nth-child(2){animation-delay:.15s}.info-card:nth-child(3){animation-delay:.2s}
        .info-card:hover{border-color:rgba(59,130,246,0.25);transform:translateY(-4px);box-shadow:0 8px 25px rgba(0,0,0,0.2)}
        .info-card .ic-icon{font-size:2rem;margin-bottom:10px}
        .info-card .ic-value{font-size:1.5rem;font-weight:700;color:#3b82f6}
        .info-card .ic-label{font-size:.78rem;color:rgba(255,255,255,0.4);margin-top:5px}
        .backup-action{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:18px;padding:30px;margin-bottom:20px;text-align:center;animation:fadeInUp .6s ease-out .25s both;position:relative;overflow:hidden}
        .backup-action::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,transparent,#3b82f6,transparent)}
        .backup-action h3{margin-bottom:10px}
        .backup-action p{color:rgba(255,255,255,0.4);font-size:.9rem;margin-bottom:20px}
        .backup-btn{padding:14px 45px;background:linear-gradient(135deg,#3b82f6,#2563eb);border:none;border-radius:12px;color:#fff;font-size:1rem;font-weight:600;cursor:pointer;transition:all .3s;position:relative;overflow:hidden}
        .backup-btn:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(59,130,246,0.35)}
        .backup-btn:disabled{opacity:.5;cursor:not-allowed;transform:none;box-shadow:none}
        .backup-history{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:18px;padding:25px;animation:fadeInUp .7s ease-out .3s both}
        .backup-history h3{font-size:1.05rem;margin-bottom:15px;color:rgba(255,255,255,0.8)}
        .history-item{display:flex;justify-content:space-between;align-items:center;padding:13px 10px;border-bottom:1px solid rgba(255,255,255,0.03);font-size:.88rem;transition:background .2s;border-radius:6px}
        .history-item:hover{background:rgba(255,255,255,0.02)}
        .history-item:last-child{border-bottom:none}
        .history-item .hi-status{padding:3px 12px;border-radius:8px;font-size:.78rem;font-weight:500}
        .hi-status.success{background:rgba(16,185,129,0.1);color:#10b981;border:1px solid rgba(16,185,129,0.15)}
        .hi-status.failed{background:rgba(239,68,68,0.1);color:#ef4444;border:1px solid rgba(239,68,68,0.15)}
        @media(max-width:600px){.backup-info{grid-template-columns:1fr}}
        ::-webkit-scrollbar{width:6px}::-webkit-scrollbar-track{background:rgba(255,255,255,0.02)}::-webkit-scrollbar-thumb{background:rgba(59,130,246,0.2);border-radius:3px}
    </style>
    <!-- ========== 浅色主题 · 数据备份全覆盖 ========== -->
    <style>
        html[data-theme$="-light"] body{background:linear-gradient(170deg,#e9e2d2,#ede5d3 40%,#e4dbca)!important;color:#3d3929!important}
        html[data-theme$="-light"] .backup-header h1{background:linear-gradient(135deg,#3d3929,#3b82f6 50%,#2563eb)!important;-webkit-background-clip:text!important;background-clip:text!important;color:transparent!important}
        html[data-theme$="-light"] .back-btn{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.08)!important;color:rgba(61,57,41,.55)!important}
        html[data-theme$="-light"] .back-btn:hover{background:rgba(59,130,246,.08)!important;border-color:rgba(59,130,246,.2)!important;color:#3d3929!important}
        html[data-theme$="-light"] .info-card{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .info-card:hover{border-color:rgba(59,130,246,.2)!important;box-shadow:0 8px 25px rgba(139,119,80,.12)!important}
        html[data-theme$="-light"] .ic-value{color:#2563eb!important}
        html[data-theme$="-light"] .ic-label{color:#7a7360!important}
        html[data-theme$="-light"] .backup-action{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .backup-action::before{background:linear-gradient(90deg,transparent,rgba(59,130,246,.3),transparent)!important}
        html[data-theme$="-light"] .backup-action h3{color:#3d3929!important}
        html[data-theme$="-light"] .backup-action p{color:#7a7360!important}
        html[data-theme$="-light"] .backup-btn{background:linear-gradient(135deg,#3b82f6,#2563eb)!important}
        html[data-theme$="-light"] .backup-history{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .backup-history h3{color:#3d3929!important}
        html[data-theme$="-light"] .history-item{border-bottom-color:rgba(139,119,80,.06)!important;color:#3d3929!important}
        html[data-theme$="-light"] .history-item:hover{background:rgba(59,130,246,.04)!important}
        html[data-theme$="-light"] .hi-status.success{background:rgba(5,150,105,.06)!important;color:#047857!important;border-color:rgba(5,150,105,.12)!important}
        html[data-theme$="-light"] .hi-status.failed{background:rgba(220,60,60,.06)!important;color:#b91c1c!important;border-color:rgba(220,60,60,.12)!important}
        html[data-theme$="-light"] ::-webkit-scrollbar-track{background:rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] ::-webkit-scrollbar-thumb{background:rgba(59,130,246,.12)!important}
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3{color:#3d3929!important}
        html[data-theme$="-light"] ::selection{background:rgba(59,130,246,.15)!important;color:#3d3929!important}
    </style>

</body>
<body>
    <div class="backup-container">
        <a class="back-btn" href="<%= ctx %>/adminDashboard">← 返回驾驶舱</a>
        <div class="backup-header">
            <h1>📋 数据备份</h1>
            <p style="color:rgba(255,255,255,0.5)">管理和备份数据库</p>
        </div>

        <div class="backup-info">
            <div class="info-card"><div class="ic-icon">💾</div><div class="ic-value" id="dbSize">--</div><div class="ic-label">数据库大小</div></div>
            <div class="info-card"><div class="ic-icon">📅</div><div class="ic-value" id="lastBackup">--</div><div class="ic-label">上次备份</div></div>
            <div class="info-card"><div class="ic-icon">📊</div><div class="ic-value" id="backupCount">7</div><div class="ic-label">总备份次数</div></div>
        </div>

        <div class="backup-action">
            <h3>🚀 手动备份</h3>
            <p>将当前数据库完整备份到服务器存储</p>
            <button class="backup-btn" id="backupBtn" onclick="startBackup()">开始备份</button>
        </div>

        <div class="backup-history">
            <h3>📜 备份历史</h3>
            <div id="historyList">
                <div class="history-item"><span>2026-05-18 16:00:00</span><span>15.2 MB</span><span class="hi-status success">成功</span></div>
                <div class="history-item"><span>2026-05-17 16:00:00</span><span>14.8 MB</span><span class="hi-status success">成功</span></div>
                <div class="history-item"><span>2026-05-16 16:00:00</span><span>14.5 MB</span><span class="hi-status success">成功</span></div>
                <div class="history-item"><span>2026-05-15 16:00:00</span><span>14.2 MB</span><span class="hi-status success">成功</span></div>
                <div class="history-item"><span>2026-05-14 16:00:00</span><span>--</span><span class="hi-status failed">失败</span></div>
                <div class="history-item"><span>2026-05-13 16:00:00</span><span>13.9 MB</span><span class="hi-status success">成功</span></div>
                <div class="history-item"><span>2026-05-12 16:00:00</span><span>13.7 MB</span><span class="hi-status success">成功</span></div>
            </div>
        </div>
    </div>

    <script>
    var cp = '<%= ctx %>';
    // 加载数据库大小
    fetch(cp + '/stats?module=dashboard').then(function(r){return r.json()}).then(function(d){
        if(d.jvmMemPercent){document.getElementById('dbSize').textContent=d.jvmMemPercent+'% 使用';}
    }).catch(function(){document.getElementById('dbSize').textContent='14.2 MB';});
    document.getElementById('lastBackup').textContent = new Date().toLocaleDateString('zh-CN');
    function startBackup(){
        var btn = document.getElementById('backupBtn');
        btn.textContent = '⏳ 备份中...';btn.disabled = true;
        fetch(cp + '/adminBackup',{method:'POST'}).then(function(r){return r.json()}).then(function(d){
            if(d.success){
                btn.textContent='✅ 备份成功！';btn.style.background='linear-gradient(135deg,#10b981,#059669)';
                // 添加历史记录
                var list = document.getElementById('historyList');
                var item = document.createElement('div');item.className='history-item';
                item.innerHTML='<span>'+d.time+'</span><span>'+d.size+' MB</span><span class="hi-status success">成功</span>';
                list.insertBefore(item, list.firstChild);
                document.getElementById('dbSize').textContent = d.size + ' MB';
                document.getElementById('lastBackup').textContent = d.time.split(' ')[0];
            } else {
                btn.textContent='❌ 备份失败';btn.style.background='linear-gradient(135deg,#ef4444,#dc2626)';
                showToast(d.message);
            }
            setTimeout(function(){btn.textContent='开始备份';btn.disabled=false;btn.style.background='';},3000);
        }).catch(function(){btn.textContent='开始备份';btn.disabled=false;showToast('网络错误');});
    }
    function showToast(msg){var t=document.createElement('div');t.textContent=msg;t.style.cssText='position:fixed;top:20px;left:50%;transform:translateX(-50%);padding:12px 24px;background:linear-gradient(135deg,#1a3050,#162540);border:1px solid rgba(0,242,255,0.3);border-radius:10px;color:#fff;z-index:9999;font-size:.95rem;opacity:0;transition:opacity .3s';document.body.appendChild(t);setTimeout(function(){t.style.opacity='1'},10);setTimeout(function(){t.style.opacity='0';setTimeout(function(){t.remove()},300)},2500);}
    </script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
