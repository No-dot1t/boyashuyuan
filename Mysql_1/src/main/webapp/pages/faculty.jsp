<%--
 =============================================================================
 faculty.jsp
 =============================================================================

 用途      功能页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ebookBuy301.pojo.Faculty, java.util.ArrayList" %>
<%!
    String h(String s) { if (s == null) return ""; return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#039;"); }
%>
<%
    ArrayList<Faculty> facultyList = (ArrayList<Faculty>) request.getAttribute("facultyList");
    if (facultyList == null) facultyList = new ArrayList<>();
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <title>博雅书院 · 科技风 | 导师光网</title>
    <link rel="stylesheet" href="<%= contextPath %>/CSS/faculty.css?v=1.0">
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
/CSS/faculty.css">
</head>
<body>
    <div class="container">
        <h1>⚛ 导师光网 · 智识引航</h1>
        <div class="search-filter-bar" style="display:flex;gap:10px;margin-bottom:20px;flex-wrap:wrap;justify-content:center">
            <input type="text" class="sf-input" placeholder="搜索导师姓名、研究方向..." oninput="filterList(this.value)" style="padding:8px 16px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:.9rem;outline:none;width:240px">
        </div>
        <style>@keyframes fadeInScale{from{opacity:0;transform:scale(.9)}to{opacity:1;transform:scale(1)}}</style>
        <div class="teacher-grid">
            <% if (facultyList.isEmpty()) { %>
            <div class="teacher-card"><h3>暂无导师信息</h3></div>
            <% } else { int facIdx=0; for (Faculty f : facultyList) { facIdx++;
                String icon = (f.getAvatarIcon() != null && !f.getAvatarIcon().isEmpty()) ? f.getAvatarIcon() : "👨‍🏫";
            %>
            <div class="teacher-card sf-filterable" onclick="openFacultyModal('<%= h(f.getName()) %>','<%= h(f.getTitle()) %>','<%= h(f.getResearchArea()) %>','<%= h(f.getDepartment()) %>','<%= h(f.getBio()) %>','<%= h(f.getEmail()) %>','<%= icon %>')" style="cursor:pointer;animation:fadeInScale .4s ease <%= facIdx*0.07 %>s both">
                <div class="teacher-avatar"><%= icon %></div>
                <h3><%= f.getName() != null ? f.getName() : "" %>
                    <% if (f.getTitle() != null && !f.getTitle().isEmpty()) { %><%= f.getTitle() %><% } %></h3>
                <p><% if (f.getResearchArea() != null && !f.getResearchArea().isEmpty()) { %><%= f.getResearchArea() %>
                    <% } if (f.getDepartment() != null && !f.getDepartment().isEmpty()) { %>（<%= f.getDepartment() %>）<% } %></p>
                <% if (f.getBio() != null && !f.getBio().isEmpty()) { %>
                <p class="teacher-bio"><%= f.getBio() %></p>
                <% } %>
                <% if (f.getEmail() != null && !f.getEmail().isEmpty()) { %>
                <p class="teacher-email">📧 <a href="mailto:<%= f.getEmail() %>" onclick="event.stopPropagation()"><%= f.getEmail() %></a></p>
                <% } %>
            </div>
            <% } } %>
        </div>
        <div class="quote">"师者，智识之引路星也。博雅聚全球慧光，照亮未知疆域。"</div>
    </div>
<!-- 导师详情模态框 -->
<div class="fac-modal-overlay" id="facModalOverlay" onclick="closeFacultyModal()"></div>
<div class="fac-modal" id="facModal">
    <button class="fac-modal-close" onclick="closeFacultyModal()">✕</button>
    <div class="fac-modal-avatar" id="facModalAvatar"></div>
    <h2 id="facModalName"></h2>
    <div class="fac-modal-dept" id="facModalDept"></div>
    <div class="fac-modal-bio" id="facModalBio"></div>
    <div class="fac-modal-email" id="facModalEmail"></div>
</div>
<style>
.fac-modal-overlay {
    position: fixed; top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0,0,0,0.7); backdrop-filter: blur(8px);
    z-index: 9998; opacity: 0; visibility: hidden; transition: all .3s;
}
.fac-modal-overlay.active { opacity: 1; visibility: visible; }
.fac-modal {
    position: fixed; top: 50%; left: 50%; transform: translate(-50%,-50%) scale(0.92);
    background: linear-gradient(145deg, #0f1525, #0a0e18);
    border: 1px solid rgba(0,242,255,0.35); border-radius: 20px;
    padding: 32px; width: 90%; max-width: 480px; z-index: 9999;
    opacity: 0; visibility: hidden; transition: all .35s cubic-bezier(.175,.885,.32,1.275);
    box-shadow: 0 20px 60px rgba(0,0,0,0.5), 0 0 30px rgba(0,242,255,0.1);
    text-align: center;
}
.fac-modal.active { opacity: 1; visibility: visible; transform: translate(-50%,-50%) scale(1); }
.fac-modal-close {
    position: absolute; top: 14px; right: 14px; width: 32px; height: 32px;
    border-radius: 50%; border: 1px solid rgba(255,255,255,0.15);
    background: rgba(255,255,255,0.05); color: #fff; font-size: 1rem;
    cursor: pointer; transition: all .25s; display: flex; align-items: center; justify-content: center;
}
.fac-modal-close:hover { background: rgba(255,71,87,0.3); border-color: #ff4757; transform: rotate(90deg); }
.fac-modal-avatar { font-size: 4rem; margin-bottom: 12px; filter: drop-shadow(0 0 12px #00f2ff); }
.fac-modal h2 { margin: 0 0 6px; font-size: 1.3rem; color: #fff; }
.fac-modal-dept { color: #00f2ff; font-size: 0.85rem; margin-bottom: 16px; }
.fac-modal-bio { color: rgba(255,255,255,0.85); font-size: 0.9rem; line-height: 1.7; margin-bottom: 16px; padding: 14px; background: rgba(0,242,255,0.05); border-radius: 12px; border: 1px solid rgba(0,242,255,0.15); text-align: left; }
.fac-modal-email { font-size: 0.85rem; }
.fac-modal-email a { color: #00f2ff; text-decoration: none; }
.fac-modal-email a:hover { text-decoration: underline; }
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
    window.openFacultyModal = function(name, title, research, dept, bio, email, icon) {
        document.getElementById('facModalName').textContent = (name || '未知') + (title ? ' ' + title : '');
        document.getElementById('facModalAvatar').textContent = icon || '👨‍🏫';
        var deptText = '';
        if (research) deptText += '🔬 ' + research;
        if (dept) deptText += (deptText ? ' · ' : '') + '🏛️ ' + dept;
        document.getElementById('facModalDept').textContent = deptText || '';
        document.getElementById('facModalBio').textContent = bio || '暂无简介';
        document.getElementById('facModalEmail').innerHTML = email ? '📧 <a href="mailto:' + email + '">' + email + '</a>' : '';
        document.getElementById('facModalOverlay').classList.add('active');
        document.getElementById('facModal').classList.add('active');
    };
    window.closeFacultyModal = function() {
        document.getElementById('facModalOverlay').classList.remove('active');
        document.getElementById('facModal').classList.remove('active');
    };
    document.addEventListener('keydown', function(e){ if(e.key==='Escape') closeFacultyModal(); });
})();
</script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
