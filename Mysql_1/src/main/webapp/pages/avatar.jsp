<%--
 =============================================================================
 avatar.jsp
 =============================================================================

 用途      功能页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   Ajax 异步请求 —— fetch
   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById
   表单 GET/POST 提交 —— 携带 URL 参数或隐藏字段

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String username = (String) request.getAttribute("username");
    if (username == null) username = "访客";
    String userId = (String) request.getAttribute("userId");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>博雅书院 | 虚拟形象</title>
    <link rel="stylesheet" href="<%= ctx %>/CSS/index.css">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{background:var(--bg-space,#0a0b1a);color:#fff;font-family:'Segoe UI','PingFang SC',sans-serif;min-height:100vh}
        @keyframes fadeInUp{from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)}}
        @keyframes floatY{0%,100%{transform:translateY(0)}50%{transform:translateY(-8px)}}
        @keyframes glowRing{0%,100%{box-shadow:0 0 20px rgba(0,242,255,0.15),inset 0 0 20px rgba(0,242,255,0.05)}50%{box-shadow:0 0 40px rgba(0,242,255,0.3),inset 0 0 30px rgba(0,242,255,0.1)}}
        @keyframes shimmer{0%{background-position:-200% 0}100%{background-position:200% 0}}
        @keyframes spin{to{transform:rotate(360deg)}}
        .avatar-container{max-width:900px;margin:0 auto;padding:30px 20px}
        .avatar-header{text-align:center;margin-bottom:40px;animation:fadeInUp .6s ease-out}
        .avatar-header h1{font-size:2.2rem;margin-bottom:10px;background:linear-gradient(135deg,#fff 0%,var(--glow-primary,#00f2ff) 50%,#fff 100%);background-size:200% auto;-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;animation:shimmer 3s linear infinite}
        .avatar-header p{color:rgba(255,255,255,0.5);font-size:1rem;letter-spacing:.5px}
        .back-btn{display:inline-flex;align-items:center;gap:8px;padding:10px 24px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:10px;color:rgba(255,255,255,0.7);text-decoration:none;cursor:pointer;transition:all .3s;margin-bottom:20px;font-size:.92rem}
        .back-btn:hover{background:rgba(0,242,255,0.12);border-color:rgba(0,242,255,0.3);color:#fff;transform:translateX(-4px)}
        .avatar-main{display:flex;gap:40px;align-items:flex-start;flex-wrap:wrap;justify-content:center}
        .avatar-preview{flex:0 0 300px;background:linear-gradient(145deg,rgba(17,27,46,0.9),rgba(15,26,46,0.7));border:1px solid rgba(0,242,255,0.15);border-radius:24px;padding:30px;text-align:center;animation:fadeInUp .7s ease-out .1s both;backdrop-filter:blur(10px);position:relative;overflow:hidden}
        .avatar-preview::before{content:'';position:absolute;top:-50%;left:-50%;width:200%;height:200%;background:radial-gradient(circle at 50% 30%,rgba(0,242,255,0.06),transparent 60%);pointer-events:none}
        .avatar-figure{width:150px;height:150px;border-radius:50%;background:linear-gradient(145deg,#1a3a5c,#0f2847);border:3px solid var(--glow-primary,#00f2ff);margin:0 auto 20px;display:flex;align-items:center;justify-content:center;font-size:4rem;position:relative;overflow:hidden;animation:glowRing 3s ease-in-out infinite,floatY 4s ease-in-out infinite}
        .avatar-figure .avatar-frame{position:absolute;inset:-5px;border:3px dashed rgba(0,242,255,0.25);border-radius:50%;animation:spin 20s linear infinite}
        .avatar-figure .avatar-frame2{position:absolute;inset:-12px;border:1px solid rgba(168,85,247,0.15);border-radius:50%;animation:spin 30s linear infinite reverse}
        .avatar-name{font-size:1.5rem;font-weight:700;margin-bottom:5px;position:relative;z-index:1}
        .avatar-title{font-size:.9rem;color:var(--glow-primary,#00f2ff);margin-bottom:15px;transition:color .3s}
        .avatar-level{display:inline-flex;align-items:center;gap:6px;padding:5px 14px;border-radius:10px;background:rgba(0,242,255,0.1);color:var(--glow-primary,#00f2ff);font-size:.85rem;margin-bottom:15px;border:1px solid rgba(0,242,255,0.15);transition:all .3s}
        .avatar-stats{display:grid;grid-template-columns:1fr 1fr;gap:10px;text-align:center}
        .avatar-stat{background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.05);border-radius:12px;padding:12px 10px;transition:all .3s}
        .avatar-stat:hover{border-color:rgba(0,242,255,0.2);background:rgba(0,242,255,0.05)}
        .avatar-stat .val{font-size:1.2rem;font-weight:700;color:var(--glow-primary,#00f2ff)}
        .avatar-stat .label{font-size:.72rem;color:rgba(255,255,255,0.45);margin-top:2px}
        .avatar-editor{flex:1;min-width:300px;animation:fadeInUp .7s ease-out .25s both}
        .editor-section{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:16px;padding:22px;margin-bottom:18px;transition:all .3s;position:relative;overflow:hidden}
        .editor-section::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,transparent,var(--glow-primary,#00f2ff),transparent);opacity:0;transition:opacity .4s}
        .editor-section:hover::before{opacity:.5}
        .editor-section:hover{border-color:rgba(0,242,255,0.15);background:rgba(255,255,255,0.03)}
        .editor-section h3{font-size:1.05rem;margin-bottom:15px;padding-bottom:10px;border-bottom:1px solid rgba(255,255,255,0.06);display:flex;align-items:center;gap:8px}
        .editor-section h3::before{content:'';width:3px;height:16px;background:var(--glow-primary,#00f2ff);border-radius:2px}
        .editor-row{margin-bottom:15px}
        .editor-row label{display:block;font-size:.82rem;color:rgba(255,255,255,0.5);margin-bottom:6px}
        .editor-row input{width:100%;padding:10px 14px;background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.08);border-radius:10px;color:#fff;font-size:.95rem;outline:none;transition:all .3s}
        .editor-row input:focus{border-color:var(--glow-primary,#00f2ff);box-shadow:0 0 0 3px rgba(0,242,255,0.1)}
        .frame-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:10px}
        .frame-option{aspect-ratio:1;background:rgba(255,255,255,0.03);border:2px solid transparent;border-radius:14px;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:1.5rem;transition:all .3s}
        .frame-option:hover{border-color:rgba(0,242,255,0.3);background:rgba(0,242,255,0.08);transform:scale(1.08)}
        .frame-option.active{border-color:var(--glow-primary,#00f2ff);background:rgba(0,242,255,0.12);box-shadow:0 0 15px rgba(0,242,255,0.15)}
        .color-grid{display:grid;grid-template-columns:repeat(6,1fr);gap:10px}
        .color-option{aspect-ratio:1;width:100%;border-radius:50%;border:3px solid transparent;cursor:pointer;transition:all .3s;box-shadow:0 2px 8px rgba(0,0,0,0.3)}
        .color-option:hover{transform:scale(1.2)}
        .color-option.active{border-color:#fff;box-shadow:0 0 12px currentColor,0 0 25px currentColor;transform:scale(1.15)}
        .outfit-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:10px}
        .outfit-option{padding:12px;background:rgba(255,255,255,0.03);border:2px solid transparent;border-radius:12px;cursor:pointer;text-align:center;font-size:.85rem;transition:all .3s}
        .outfit-option:hover{border-color:rgba(0,242,255,0.3);background:rgba(0,242,255,0.06);transform:translateY(-3px)}
        .outfit-option.active{border-color:var(--glow-primary,#00f2ff);background:rgba(0,242,255,0.1);box-shadow:0 4px 15px rgba(0,242,255,0.1)}
        .outfit-option .outfit-icon{font-size:1.8rem;margin-bottom:5px;transition:transform .3s}
        .outfit-option:hover .outfit-icon{transform:scale(1.1)}
        .save-btn{width:100%;padding:14px;background:linear-gradient(135deg,#00d4e0,#00a8b5);border:none;border-radius:12px;color:#fff;font-size:1rem;font-weight:600;cursor:pointer;transition:all .3s;margin-top:10px;position:relative;overflow:hidden}
        .save-btn:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(0,212,224,0.35)}
        .save-btn:active{transform:translateY(0)}
    </style>
    <!-- ========== 浅色主题全局兜底覆盖 ========== -->
    <style>
        html[data-theme$="-light"],html[data-theme$="-light"] body{background:#e8dfcf!important;color:#3d3929!important}
        html[data-theme$="-light"] [class*="card"],html[data-theme$="-light"] [class*="box"],html[data-theme$="-light"] [class*="module"]{background:rgba(238,233,222,.92)!important;border-color:rgba(139,119,80,.07)!important}
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3,html[data-theme$="-light"] [class*="title"]{color:#3d3929!important}
        html[data-theme$="-light"] p,html[data-theme$="-light"] li,html[data-theme$="-light"] [class*="desc"],html[data-theme$="-light"] [class*="muted"]{color:#7a7360!important}
        html[data-theme$="-light"] a{color:#0071e3!important}
        html[data-theme$="-light"] input,html[data-theme$="-light"] textarea,html[data-theme$="-light"] select{background:rgba(238,233,222,.94)!important;border-color:rgba(139,119,80,.12)!important;color:#3d3929!important}
        html[data-theme$="-light"] [class*="header"],html[data-theme$="-light"] [class*="navbar"]{background:rgba(238,233,222,.94)!important;border-color:rgba(139,119,80,.07)!important}
        html[data-theme$="-light"] [class*="item"]{background:rgba(238,233,222,.72)!important}
        html[data-theme$="-light"] [class*="particle"],html[data-theme$="-light"] [class*="star"]{opacity:.15!important}
        html[data-theme$="-light"] span,html[data-theme$="-light"] label,html[data-theme$="-light"] div{color:#3d3929!important}
        html[data-theme$="-light"] button:not([class*="primary"]){color:#3d3929!important}
        html[data-theme$="-light"] svg,html[data-theme$="-light"] [class*="icon"]{color:#5c5540!important;fill:#5c5540!important}
        html[data-theme$="-light"] input::placeholder,html[data-theme$="-light"] textarea::placeholder{color:#968e78!important}
        html[data-theme$="-light"] [class*="tag"],html[data-theme$="-light"] [class*="badge"]{color:#3d3929!important;background:rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] [class*="toast"],[class*="notification"]{color:#3d3929!important;background:rgba(248,243,230,.96)!important}
        html[data-theme$="-light"] a{color:#2563eb!important}
    </style>

</head>
<body>
    <div class="avatar-container">
        <a class="back-btn" href="<%= ctx %>/campus3d">← 返回元宇宙校园</a>
        <div class="avatar-header">
            <h1><span class="glow-text">👨‍🎓</span> 虚拟形象</h1>
            <p>打造你的专属元宇宙身份</p>
        </div>

        <div class="avatar-main">
            <div class="avatar-preview">
                <div class="avatar-figure" id="avatarFigure">
                    🧑‍🎓
                    <div class="avatar-frame"></div>
                    <div class="avatar-frame2"></div>
                </div>
                <div class="avatar-name" id="displayName"><%= username %></div>
                <div class="avatar-title" id="displayTitle">博雅学子</div>
                <div class="avatar-level" id="displayLevel">Lv.12 探索者</div>
                <div class="avatar-stats">
                    <div class="avatar-stat"><div class="val">156</div><div class="label">学习时长(h)</div></div>
                    <div class="avatar-stat"><div class="val">42</div><div class="label">完成任务</div></div>
                    <div class="avatar-stat"><div class="val">8</div><div class="label">获得成就</div></div>
                    <div class="avatar-stat"><div class="val">3</div><div class="label">加入小组</div></div>
                </div>
            </div>

            <div class="avatar-editor">
                <div class="editor-section">
                    <h3>✏️ 基本信息</h3>
                    <div class="editor-row">
                        <label>显示名称</label>
                        <input type="text" id="nameInput" value="<%= username %>" maxlength="20" oninput="document.getElementById('displayName').textContent=this.value||'<%= username %>'">
                    </div>
                    <div class="editor-row">
                        <label>个性签名</label>
                        <input type="text" id="titleInput" value="博雅学子" maxlength="30" oninput="document.getElementById('displayTitle').textContent=this.value||'博雅学子'">
                    </div>
                </div>

                <div class="editor-section">
                    <h3>🖼️ 头像框</h3>
                    <div class="frame-grid">
                        <div class="frame-option active" onclick="selectFrame(this,'none')">0️⃣</div>
                        <div class="frame-option" onclick="selectFrame(this,'cyan')">💠</div>
                        <div class="frame-option" onclick="selectFrame(this,'gold')">👑</div>
                        <div class="frame-option" onclick="selectFrame(this,'fire')">🔥</div>
                    </div>
                </div>

                <div class="editor-section">
                    <h3>🎨 主题色</h3>
                    <div class="color-grid">
                        <div class="color-option active" style="background:#00f2ff" onclick="selectColor(this,'#00f2ff')"></div>
                        <div class="color-option" style="background:#a855f7" onclick="selectColor(this,'#a855f7')"></div>
                        <div class="color-option" style="background:#f59e0b" onclick="selectColor(this,'#f59e0b')"></div>
                        <div class="color-option" style="background:#10b981" onclick="selectColor(this,'#10b981')"></div>
                        <div class="color-option" style="background:#ef4444" onclick="selectColor(this,'#ef4444')"></div>
                        <div class="color-option" style="background:#ec4899" onclick="selectColor(this,'#ec4899')"></div>
                    </div>
                </div>

                <div class="editor-section">
                    <h3>👔 服装风格</h3>
                    <div class="outfit-grid">
                        <div class="outfit-option active" onclick="selectOutfit(this,'🧑‍🎓')"><div class="outfit-icon">🧑‍🎓</div>学士服</div>
                        <div class="outfit-option" onclick="selectOutfit(this,'👨‍💻')"><div class="outfit-icon">👨‍💻</div>程序员</div>
                        <div class="outfit-option" onclick="selectOutfit(this,'🧙‍♂️')"><div class="outfit-icon">🧙‍♂️</div>法师</div>
                        <div class="outfit-option" onclick="selectOutfit(this,'🥷')"><div class="outfit-icon">🥷</div>忍者</div>
                        <div class="outfit-option" onclick="selectOutfit(this,'🧑‍🚀')"><div class="outfit-icon">🧑‍🚀</div>宇航员</div>
                        <div class="outfit-option" onclick="selectOutfit(this,'🦸')"><div class="outfit-icon">🦸</div>英雄</div>
                    </div>
                </div>

                <button class="save-btn" onclick="saveAvatar()">💾 保存形象设置</button>
            </div>
        </div>
    </div>

    <script>
    function selectFrame(el, type) {
        el.parentElement.querySelectorAll('.frame-option').forEach(function(e){e.classList.remove('active')});
        el.classList.add('active');
        var figure = document.getElementById('avatarFigure');
        figure.style.borderColor = type==='none' ? 'var(--glow-primary,#00f2ff)' :
            type==='cyan' ? '#00f2ff' : type==='gold' ? '#f59e0b' : '#ef4444';
    }
    function selectColor(el, color) {
        el.parentElement.querySelectorAll('.color-option').forEach(function(e){e.classList.remove('active')});
        el.classList.add('active');
        document.getElementById('avatarFigure').style.borderColor = color;
        document.querySelector('.avatar-title').style.color = color;
        document.querySelector('.avatar-level').style.background = color + '22';
        document.querySelector('.avatar-level').style.color = color;
    }
    function selectOutfit(el, emoji) {
        el.parentElement.querySelectorAll('.outfit-option').forEach(function(e){e.classList.remove('active')});
        el.classList.add('active');
        document.querySelector('.avatar-figure').firstChild.textContent = emoji + '\n';
    }
    function saveAvatar() {
        var name = document.getElementById('nameInput').value;
        var title = document.getElementById('titleInput').value;
        var cp = '<%= request.getContextPath() %>';
        var btn = document.querySelector('.save-btn');
        btn.textContent = '✅ 已保存！';
        btn.style.background = 'linear-gradient(135deg,#10b981,#059669)';
        setTimeout(function(){btn.textContent='💾 保存形象设置';btn.style.background='';},2000);
    }
    </script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
