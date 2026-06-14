<%--
 =============================================================================
 culture.jsp
 =============================================================================

 用途      功能页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ebookBuy301.pojo.CultureEvent, java.util.ArrayList, java.text.SimpleDateFormat" %>
<%!
    String h(String s) { if (s == null) return ""; return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#039;"); }
%>
<%
    ArrayList<CultureEvent> events = (ArrayList<CultureEvent>) request.getAttribute("cultureEvents");
    if (events == null) events = new ArrayList<>();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <title>博雅书院 · 科技风 | 元·文化</title>
    <link rel="stylesheet" href="<%= contextPath %>/CSS/culture.css">
    <!-- ========== 浅色主题 · 文化长廊全覆盖 ========== -->
    <style>
        /* 基础底色 */
        html[data-theme$="-light"] body{background:linear-gradient(145deg,#e9e2d2,#ede5d3 50%,#e4dbca)!important;color:#3d3929!important}
        /* 标题 */
        html[data-theme$="-light"] h1{background:linear-gradient(135deg,#3d3929,#2563eb)!important;-webkit-background-clip:text!important;background-clip:text!important;color:transparent!important;border-bottom-color:rgba(37,99,235,.15)!important}
        /* 诗卡 */
        html[data-theme$="-light"] .poem{background:rgba(37,99,235,.04)!important}
        html[data-theme$="-light"] .poem:hover{background:rgba(37,99,235,.08)!important}
        /* 搜索框 */
        html[data-theme$="-light"] .sf-input{background:rgba(238,233,222,.85)!important;border-color:rgba(139,119,80,.1)!important;color:#3d3929!important}
        html[data-theme$="-light"] .sf-input::placeholder{color:rgba(61,57,41,.3)!important}
        /* 事件列表 */
        html[data-theme$="-light"] .event-item{border-bottom-color:rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .event-item:hover{background:rgba(37,99,235,.04)!important;border-bottom-color:rgba(37,99,235,.15)!important}
        html[data-theme$="-light"] .event-date{color:#3d3929!important}
        html[data-theme$="-light"] .event-date::before{filter:none!important;opacity:.5!important}
        html[data-theme$="-light"] .event-name,.event-desc,.event-location{color:#3d3929!important}
        /* 画廊卡片 */
        html[data-theme$="-light"] .art-card{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .art-card:hover{background:rgba(37,99,235,.06)!important;border-color:rgba(37,99,235,.2)!important;box-shadow:0 0 12px rgba(37,99,235,.08)!important}
        /* 页脚 */
        html[data-theme$="-light"] .footer-text{color:#7a7360!important;border-top-color:rgba(139,119,80,.08)!important}
        /* ── 模态框（内联CSS硬编码）── */
        html[data-theme$="-light"] .cul-modal-overlay{background:rgba(61,57,41,.35)!important}
        html[data-theme$="-light"] .cul-modal{background:linear-gradient(145deg,rgba(238,233,222,.97),rgba(243,239,228,.97))!important;border-color:rgba(37,99,235,.15)!important;box-shadow:0 20px 60px rgba(139,119,80,.15),0 0 30px rgba(37,99,235,.04)!important}
        html[data-theme$="-light"] .cul-modal-close{background:rgba(139,119,80,.06)!important;border-color:rgba(139,119,80,.1)!important;color:#3d3929!important}
        html[data-theme$="-light"] .cul-modal-close:hover{background:rgba(220,60,60,.15)!important;border-color:rgba(220,60,60,.3)!important;color:#b91c1c!important}
        html[data-theme$="-light"] .cul-modal-icon{filter:drop-shadow(0 0 8px rgba(37,99,235,.15))!important}
        html[data-theme$="-light"] .cul-modal h2{color:#3d3929!important}
        html[data-theme$="-light"] .cul-modal-date{color:#2563eb!important}
        html[data-theme$="-light"] .cul-modal-desc{color:#3d3929!important;background:rgba(37,99,235,.03)!important;border-color:rgba(37,99,235,.08)!important}
        html[data-theme$="-light"] .cul-modal-loc{color:#7a7360!important}
        /* 通用 */
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3{color:#3d3929!important}
        html[data-theme$="-light"] p,html[data-theme$="-light"] span{color:#3d3929!important}
    </style>
</head>
<body>
    <div class="container">
        <h1>⌬ 元·文化 数字雅集</h1>
        <div class="poem">"数据流觞，算法曲水。<br>智思如泉，文心雕龙。"<br>—— 博雅·数字诗笺</div>
        <div class="search-filter-bar" style="display:flex;gap:10px;margin-bottom:20px;flex-wrap:wrap;justify-content:center">
            <input type="text" class="sf-input" placeholder="搜索文化活动..." oninput="filterList(this.value)" style="padding:8px 16px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:.9rem;outline:none;width:240px">
        </div>
        <style>@keyframes fadeInRight{from{opacity:0;transform:translateX(20px)}to{opacity:1;transform:translateX(0)}}</style>
        <div class="event-list">
            <% if (events.isEmpty()) { %>
            <div class="event-item"><span class="event-name">暂无文化活动，敬请期待</span></div>
            <% } else { int evtIdx=0; for (CultureEvent e : events) { evtIdx++;
                String seasonStr = (e.getSeason() != null && !e.getSeason().isEmpty()) ? e.getSeason() :
                                   (e.getEventDate() != null ? sdf.format(e.getEventDate()) : "");
            %>
            <div class="event-item sf-filterable" onclick="openCultureModal('<%= h(e.getEventName()) %>','<%= seasonStr %>','<%= h(e.getDescription()) %>','<%= h(e.getLocation()) %>')" style="cursor:pointer;animation:fadeInRight .4s ease <%= evtIdx*0.06 %>s both">
                <span class="event-date"><%= seasonStr %></span>
                <span class="event-name"><%= e.getEventName() != null ? e.getEventName() : "" %></span>
                <% if (e.getDescription() != null && !e.getDescription().isEmpty()) { %>
                <span class="event-desc"><%= e.getDescription() %></span>
                <% } %>
                <% if (e.getLocation() != null && !e.getLocation().isEmpty()) { %>
                <span class="event-location">📍 <%= e.getLocation() %></span>
                <% } %>
            </div>
            <% } } %>
        </div>
        <div class="footer-text">✨ 科技赋能文化，智识照亮未来 ✨</div>
    </div>
<!-- 文化活动详情模态框 -->
<div class="cul-modal-overlay" id="culModalOverlay" onclick="closeCultureModal()"></div>
<div class="cul-modal" id="culModal">
    <button class="cul-modal-close" onclick="closeCultureModal()">✕</button>
    <div class="cul-modal-icon">⌬</div>
    <h2 id="culModalTitle"></h2>
    <div class="cul-modal-date" id="culModalDate"></div>
    <div class="cul-modal-desc" id="culModalDesc"></div>
    <div class="cul-modal-loc" id="culModalLoc"></div>
</div>
<style>
.cul-modal-overlay {
    position: fixed; top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0,0,0,0.7); backdrop-filter: blur(8px);
    z-index: 9998; opacity: 0; visibility: hidden; transition: all .3s;
}
.cul-modal-overlay.active { opacity: 1; visibility: visible; }
.cul-modal {
    position: fixed; top: 50%; left: 50%; transform: translate(-50%,-50%) scale(0.92);
    background: linear-gradient(145deg, #0f1525, #0a0e18);
    border: 1px solid rgba(0,242,255,0.35); border-radius: 20px;
    padding: 32px; width: 90%; max-width: 460px; z-index: 9999;
    opacity: 0; visibility: hidden; transition: all .35s cubic-bezier(.175,.885,.32,1.275);
    box-shadow: 0 20px 60px rgba(0,0,0,0.5), 0 0 30px rgba(0,242,255,0.1);
    text-align: center;
}
.cul-modal.active { opacity: 1; visibility: visible; transform: translate(-50%,-50%) scale(1); }
.cul-modal-close {
    position: absolute; top: 14px; right: 14px; width: 32px; height: 32px;
    border-radius: 50%; border: 1px solid rgba(255,255,255,0.15);
    background: rgba(255,255,255,0.05); color: #fff; font-size: 1rem;
    cursor: pointer; transition: all .25s; display: flex; align-items: center; justify-content: center;
}
.cul-modal-close:hover { background: rgba(255,71,87,0.3); border-color: #ff4757; transform: rotate(90deg); }
.cul-modal-icon { font-size: 3rem; margin-bottom: 10px; filter: drop-shadow(0 0 8px #00f2ff); }
.cul-modal h2 { margin: 0 0 8px; font-size: 1.25rem; color: #fff; }
.cul-modal-date { color: #00f2ff; font-size: 0.85rem; margin-bottom: 14px; }
.cul-modal-desc { color: rgba(255,255,255,0.85); font-size: 0.9rem; line-height: 1.7; margin-bottom: 14px; padding: 14px; background: rgba(0,242,255,0.05); border-radius: 12px; border: 1px solid rgba(0,242,255,0.15); }
.cul-modal-loc { color: rgba(255,255,255,0.7); font-size: 0.85rem; }
</style>
<script>
(function(){
    function filterList(query){
        query = query.toLowerCase();
        document.querySelectorAll('.sf-filterable').forEach(function(el){
            var text = el.textContent.toLowerCase();
            el.style.display = (!query || text.indexOf(query) >= 0) ? '' : 'none';
        });
    }
    window.filterList = filterList;
    window.openCultureModal = function(name, date, desc, loc) {
        document.getElementById('culModalTitle').textContent = name || '文化活动';
        document.getElementById('culModalDate').textContent = date ? '📅 ' + date : '';
        document.getElementById('culModalDesc').textContent = desc || '暂无详细描述';
        document.getElementById('culModalLoc').textContent = loc ? '📍 地点：' + loc : '';
        document.getElementById('culModalOverlay').classList.add('active');
        document.getElementById('culModal').classList.add('active');
    };
    window.closeCultureModal = function() {
        document.getElementById('culModalOverlay').classList.remove('active');
        document.getElementById('culModal').classList.remove('active');
    };
    document.addEventListener('keydown', function(e){ if(e.key==='Escape') closeCultureModal(); });
})();
</script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
