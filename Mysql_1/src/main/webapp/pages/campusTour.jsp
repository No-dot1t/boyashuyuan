<%--
 =============================================================================
 campusTour.jsp
 =============================================================================

 用途      功能页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ebookBuy301.pojo.CampusScene, java.util.ArrayList" %>
<%
    ArrayList<CampusScene> scenes = (ArrayList<CampusScene>) request.getAttribute("scenes");
    if (scenes == null) scenes = new ArrayList<>();
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>博雅书院 | 虚拟校园导览</title>
    <link rel="stylesheet" href="<%= ctx %>/CSS/index.css">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{background:var(--bg-space,#0a0b1a);color:#fff;font-family:'Segoe UI','PingFang SC',sans-serif;min-height:100vh}
        /* 入场动画 */
        @keyframes fadeInUp{from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)}}
        @keyframes glowPulse{0%,100%{box-shadow:0 0 15px rgba(0,242,255,0.08)}50%{box-shadow:0 0 30px rgba(0,242,255,0.18)}}
        @keyframes shimmer{0%{background-position:-200% 0}100%{background-position:200% 0}}
        @keyframes floatY{0%,100%{transform:translateY(0)}50%{transform:translateY(-6px)}}
        .tour-container{max-width:1200px;margin:0 auto;padding:30px 20px}
        .tour-header{text-align:center;margin-bottom:40px;animation:fadeInUp .6s ease-out}
        .tour-header h1{font-size:2.2rem;margin-bottom:10px;background:linear-gradient(135deg,#fff 0%,var(--glow-primary,#00f2ff) 50%,#fff 100%);background-size:200% auto;-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;animation:shimmer 3s linear infinite}
        .tour-header p{color:rgba(255,255,255,0.55);font-size:1.05rem;letter-spacing:.5px}
        .campus-map{background:linear-gradient(145deg,rgba(15,26,46,0.9),rgba(26,40,64,0.7));border:1px solid var(--border-glow,rgba(0,242,255,0.18));border-radius:20px;padding:30px;margin-bottom:40px;position:relative;overflow:hidden;animation:fadeInUp .7s ease-out .1s both;backdrop-filter:blur(10px)}
        .campus-map::before{content:'';position:absolute;top:-50%;left:-50%;width:200%;height:200%;background:radial-gradient(circle at 30% 40%,rgba(0,242,255,0.04) 0%,transparent 50%),radial-gradient(circle at 70% 60%,rgba(168,85,247,0.03) 0%,transparent 50%);pointer-events:none}
        .campus-map h2{margin-bottom:20px;font-size:1.3rem;display:flex;align-items:center;gap:8px}
        .campus-map h2::before{content:'';width:4px;height:20px;background:var(--glow-primary,#00f2ff);border-radius:2px}
        .map-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:20px}
        .map-building{background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.08);border-radius:16px;padding:22px;cursor:pointer;transition:all .4s cubic-bezier(.175,.885,.32,1.275);text-align:center;position:relative;overflow:hidden;animation:fadeInUp .7s ease-out both}
        .map-building:nth-child(1){animation-delay:.15s}.map-building:nth-child(2){animation-delay:.2s}.map-building:nth-child(3){animation-delay:.25s}.map-building:nth-child(4){animation-delay:.3s}.map-building:nth-child(5){animation-delay:.35s}.map-building:nth-child(6){animation-delay:.4s}.map-building:nth-child(7){animation-delay:.45s}.map-building:nth-child(8){animation-delay:.5s}
        .map-building::after{content:'';position:absolute;inset:0;background:radial-gradient(circle at 50% 0%,rgba(0,242,255,0.1),transparent 70%);opacity:0;transition:opacity .4s}
        .map-building:hover{transform:translateY(-8px) scale(1.02);border-color:var(--glow-primary,#00f2ff);box-shadow:0 12px 40px rgba(0,242,255,0.15),0 0 0 1px rgba(0,242,255,0.1)}
        .map-building:hover::after{opacity:1}
        .map-building .building-icon{font-size:2.5rem;margin-bottom:10px;transition:transform .4s;filter:drop-shadow(0 0 8px rgba(0,242,255,0.3))}
        .map-building:hover .building-icon{transform:scale(1.15) rotate(-3deg)}
        .map-building .building-name{font-size:1rem;font-weight:600;margin-bottom:5px;position:relative;z-index:1}
        .map-building .building-desc{font-size:.82rem;color:rgba(255,255,255,0.45);position:relative;z-index:1}
        .building-detail{display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.75);z-index:1000;justify-content:center;align-items:center;backdrop-filter:blur(8px)}
        .building-detail.active{display:flex}
        .detail-panel{background:linear-gradient(145deg,#131d30,#0e1728);border:1px solid rgba(0,242,255,0.25);border-radius:20px;padding:40px;max-width:600px;width:90%;max-height:80vh;overflow-y:auto;position:relative;box-shadow:0 25px 60px rgba(0,0,0,0.5),0 0 80px rgba(0,242,255,0.08);animation:fadeInUp .35s ease-out}
        .detail-panel h3{font-size:1.5rem;margin-bottom:15px}
        .detail-panel .detail-icon{font-size:3rem;margin-bottom:15px;animation:floatY 3s ease-in-out infinite;filter:drop-shadow(0 0 12px rgba(0,242,255,0.4))}
        .detail-panel p{color:rgba(255,255,255,0.65);line-height:1.8;margin-bottom:15px}
        .detail-close{position:absolute;top:15px;right:20px;background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.1);border-radius:50%;width:36px;height:36px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:1.2rem;cursor:pointer;transition:all .3s}
        .detail-close:hover{background:rgba(239,68,68,0.2);border-color:rgba(239,68,68,0.4);transform:rotate(90deg)}
        .scene-list{margin-top:30px;animation:fadeInUp .7s ease-out .55s both}
        .scene-list h2{font-size:1.3rem;margin-bottom:20px;display:flex;align-items:center;gap:8px}
        .scene-list h2::before{content:'';width:4px;height:20px;background:#a855f7;border-radius:2px}
        .scene-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:20px}
        .scene-card{background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.06);border-radius:15px;padding:20px;transition:all .4s cubic-bezier(.175,.885,.32,1.275);position:relative;overflow:hidden}
        .scene-card::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,transparent,var(--glow-primary,#00f2ff),transparent);opacity:0;transition:opacity .4s}
        .scene-card:hover{border-color:rgba(0,242,255,0.3);transform:translateY(-4px);box-shadow:0 8px 25px rgba(0,0,0,0.3)}
        .scene-card:hover::before{opacity:1}
        .scene-card .scene-icon{font-size:2rem;margin-bottom:10px}
        .scene-card h4{font-size:1.05rem;margin-bottom:8px}
        .scene-card p{color:rgba(255,255,255,0.5);font-size:.88rem;line-height:1.5}
        .scene-card .scene-status{display:inline-flex;align-items:center;gap:5px;padding:4px 12px;border-radius:10px;font-size:.78rem;margin-top:10px;background:rgba(16,185,129,0.12);color:#10b981;border:1px solid rgba(16,185,129,0.2)}
        .scene-card .scene-status::before{content:'';width:6px;height:6px;background:#10b981;border-radius:50%;animation:glowPulse 2s infinite}
        .back-btn{display:inline-flex;align-items:center;gap:8px;padding:10px 24px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:10px;color:rgba(255,255,255,0.7);text-decoration:none;cursor:pointer;transition:all .3s;margin-bottom:20px;font-size:.92rem}
        .back-btn:hover{background:rgba(0,242,255,0.12);border-color:rgba(0,242,255,0.3);color:#fff;transform:translateX(-4px)}
        /* 滚动条美化 */
        ::-webkit-scrollbar{width:6px}::-webkit-scrollbar-track{background:rgba(255,255,255,0.02)}::-webkit-scrollbar-thumb{background:rgba(0,242,255,0.2);border-radius:3px}::-webkit-scrollbar-thumb:hover{background:rgba(0,242,255,0.4)}
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
    <div class="tour-container">
        <a class="back-btn" href="<%= ctx %>/campus3d">← 返回元宇宙校园</a>
        <div class="tour-header">
            <h1><span class="glow-text">🏛️</span> 虚拟校园导览</h1>
            <p>探索博雅书院的每一个角落，发现知识的无限可能</p>
        </div>

        <div class="campus-map">
            <h2>📍 校园地图</h2>
            <div class="map-grid">
                <div class="map-building" onclick="showDetail('library')">
                    <div class="building-icon">📚</div>
                    <div class="building-name">博雅图书馆</div>
                    <div class="building-desc">藏书10万+ · 24h自习室</div>
                </div>
                <div class="map-building" onclick="showDetail('teaching')">
                    <div class="building-icon">🏫</div>
                    <div class="building-name">教学楼群</div>
                    <div class="building-desc">A/B/C/D栋 · 智慧教室</div>
                </div>
                <div class="map-building" onclick="showDetail('lab')">
                    <div class="building-icon">🔬</div>
                    <div class="building-name">科学实验中心</div>
                    <div class="building-desc">物理/化学/生物实验室</div>
                </div>
                <div class="map-building" onclick="showDetail('stadium')">
                    <div class="building-icon">🏟️</div>
                    <div class="building-name">体育中心</div>
                    <div class="building-desc">游泳馆 · 篮球馆 · 健身房</div>
                </div>
                <div class="map-building" onclick="showDetail('art')">
                    <div class="building-icon">🎨</div>
                    <div class="building-name">艺术中心</div>
                    <div class="building-desc">画室 · 音乐厅 · 展览馆</div>
                </div>
                <div class="map-building" onclick="showDetail('dorm')">
                    <div class="building-icon">🏠</div>
                    <div class="building-name">学生公寓</div>
                    <div class="building-desc">智慧宿舍 · 4人间</div>
                </div>
                <div class="map-building" onclick="showDetail('canteen')">
                    <div class="building-icon">🍽️</div>
                    <div class="building-name">膳食中心</div>
                    <div class="building-desc">3层食堂 · 多国美食</div>
                </div>
                <div class="map-building" onclick="showDetail('admin')">
                    <div class="building-icon">🏢</div>
                    <div class="building-name">行政服务中心</div>
                    <div class="building-desc">一站式服务大厅</div>
                </div>
            </div>
        </div>

        <div class="scene-list">
            <h2>🌐 在线场景</h2>
            <div class="scene-grid">
                <% if (scenes.isEmpty()) { %>
                <p style="color:rgba(255,255,255,0.5);text-align:center;grid-column:1/-1;">暂无在线场景</p>
                <% } else { %>
                <% for (com.ebookBuy301.pojo.CampusScene sc : scenes) { %>
                <div class="scene-card">
                    <div class="scene-icon"><%= sc.getIcon() != null ? sc.getIcon() : "🌐" %></div>
                    <h4><%= sc.getName() %></h4>
                    <p><%= sc.getDescription() %></p>
                    <span class="scene-status">● 在线</span>
                </div>
                <% } } %>
            </div>
        </div>
    </div>

    <div class="building-detail" id="buildingDetail">
        <div class="detail-panel">
            <button class="detail-close" onclick="closeDetail()">&times;</button>
            <div class="detail-icon" id="detailIcon">📚</div>
            <h3 id="detailName">博雅图书馆</h3>
            <p id="detailDesc"></p>
            <p id="detailInfo"></p>
        </div>
    </div>

    <script>
    var buildings = {
        library: {icon:'📚', name:'博雅图书馆', desc:'博雅书院的核心知识殿堂，拥有超过10万册藏书，涵盖文学、理学、工学、艺术等多个学科领域。馆内设有24小时自习室、电子阅览室、研讨室和休闲阅读区。', info:'楼层：5层 | 座位：2000+ | 开放时间：7:00-23:00'},
        teaching: {icon:'🏫', name:'教学楼群', desc:'现代化智慧教学楼群，共4栋（A/B/C/D），配备多媒体教室、互动黑板和远程教学系统。支持线上线下混合式教学，打造沉浸式学习体验。', info:'教室：120间 | 最大容量：300人 | Wi-Fi全覆盖'},
        lab: {icon:'🔬', name:'科学实验中心', desc:'集物理、化学、生物、计算机等学科实验于一体的综合实验中心。配备先进的实验设备和虚拟仿真系统，支持线上线下融合实验。', info:'实验室：45间 | 虚拟仿真位：200 | 开放时间：8:00-22:00'},
        stadium: {icon:'🏟️', name:'体育中心', desc:'综合体育设施，包括标准游泳馆、室内篮球馆、健身房、羽毛球场和塑胶跑道。定期举办校际体育赛事。', info:'游泳馆：50m标准池 | 篮球馆：4片场地 | 健身房：500㎡'},
        art: {icon:'🎨', name:'艺术中心', desc:'艺术创作与展示的殿堂，设有画室、琴房、舞蹈教室、音乐厅和数字艺术实验室。定期举办学生作品展和艺术讲座。', info:'展厅：3个 | 琴房：20间 | 音乐厅：800座'},
        dorm: {icon:'🏠', name:'学生公寓', desc:'现代化智慧学生公寓，4人间标准配置，配备独立卫浴、空调、高速网络和学习桌。公寓管理智能化，支持人脸识别门禁。', info:'楼栋：12栋 | 容纳：6000人 | 智能门禁'},
        canteen: {icon:'🍽️', name:'膳食中心', desc:'3层现代化食堂，汇集全国各系美食，设有清真窗口、西餐区和咖啡厅。引入智慧点餐系统，支持手机点餐和送餐到桌。', info:'餐位：3000+ | 窗口：60+ | 营业时间：6:30-21:30'},
        admin: {icon:'🏢', name:'行政服务中心', desc:'一站式行政服务中心，涵盖教务、学务、财务、后勤等业务办理。采用智慧排队系统，大幅缩短办事时间。', info:'窗口：20个 | 自助终端：10台 | 工作时间：8:30-17:30'}
    };
    function showDetail(key) {
        var b = buildings[key];
        document.getElementById('detailIcon').textContent = b.icon;
        document.getElementById('detailName').textContent = b.name;
        document.getElementById('detailDesc').textContent = b.desc;
        document.getElementById('detailInfo').textContent = b.info;
        document.getElementById('buildingDetail').classList.add('active');
    }
    function closeDetail() {
        document.getElementById('buildingDetail').classList.remove('active');
    }
    document.getElementById('buildingDetail').addEventListener('click', function(e) {
        if (e.target === this) closeDetail();
    });
    </script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
