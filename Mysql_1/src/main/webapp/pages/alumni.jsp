<%--
 =============================================================================
 alumni.jsp
 =============================================================================

 用途      功能页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ebookBuy301.pojo.Alumni, java.util.ArrayList" %>
<%!
    String h(String s) { if (s == null) return ""; return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#039;"); }
%>
<%
    ArrayList<Alumni> alumniList = (ArrayList<Alumni>) request.getAttribute("alumniList");
    ArrayList<Alumni> honoraryList = (ArrayList<Alumni>) request.getAttribute("honoraryList");
    if (alumniList == null) alumniList = new ArrayList<>();
    if (honoraryList == null) honoraryList = new ArrayList<>();
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <title>博雅书院 · 科技风 | 星链校友</title>
    <link rel="stylesheet" href="<%= contextPath %>/CSS/alumni.css?v=1.0">
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
/CSS/alumni.css">
</head>
<body>
    <div class="container">
        <h1>✨ 星链校友 · 未来光点</h1>
        <div class="search-filter-bar" style="display:flex;gap:10px;margin-bottom:20px;flex-wrap:wrap;justify-content:center">
            <input type="text" class="sf-input" placeholder="搜索校友姓名、公司、成就..." oninput="filterList(this.value)" style="padding:8px 16px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:.9rem;outline:none;width:240px">
        </div>
        <style>@keyframes fadeInLeft{from{opacity:0;transform:translateX(-20px)}to{opacity:1;transform:translateX(0)}}</style>
        <% if (!honoraryList.isEmpty()) { %>
        <h2 class="sub-title">🏅 荣誉校友</h2>
        <div class="alumni-list">
            <% int honIdx=0; for (Alumni a : honoraryList) { honIdx++; %>
            <div class="alumni-item honorary sf-filterable" onclick="openAlumniModal('<%= h(a.getName()) %>','<%= h(a.getTitle()) %>','<%= h(a.getCompany()) %>','<%= h(a.getAchievement()) %>','<%= a.getGraduationYear() != null ? a.getGraduationYear() : "" %>',true)" style="cursor:pointer;animation:fadeInLeft .4s ease <%= honIdx*0.06 %>s both">
                <span class="alumni-name"><%= a.getName() != null ? a.getName() : "" %>（荣誉）</span>
                <% if (a.getTitle() != null && !a.getTitle().isEmpty()) { %><%= a.getTitle() %><% } %>
                <% if (a.getAchievement() != null && !a.getAchievement().isEmpty()) { %>，<%= a.getAchievement() %><% } %>
            </div>
            <% } %>
        </div>
        <% } %>
        <% if (!alumniList.isEmpty()) { %>
        <h2 class="sub-title">🌟 杰出校友</h2>
        <div class="alumni-list">
            <% int alumIdx=0; for (Alumni a : alumniList) {
                if (a.isHonorary()) continue; alumIdx++;
            %>
            <div class="alumni-item sf-filterable" onclick="openAlumniModal('<%= h(a.getName()) %>','<%= h(a.getTitle()) %>','<%= h(a.getCompany()) %>','<%= h(a.getAchievement()) %>','<%= a.getGraduationYear() != null ? a.getGraduationYear() : "" %>',false)" style="cursor:pointer;animation:fadeInLeft .4s ease <%= alumIdx*0.06 %>s both">
                <span class="alumni-name"><%= a.getName() != null ? a.getName() : "" %></span>
                <% if (a.getTitle() != null && !a.getTitle().isEmpty()) { %><%= a.getTitle() %><% } %>
                <% if (a.getCompany() != null && !a.getCompany().isEmpty()) { %>，<%= a.getCompany() %><% } %>
                <% if (a.getAchievement() != null && !a.getAchievement().isEmpty()) { %>。<%= a.getAchievement() %><% } %>
                <% if (a.getGraduationYear() != null) { %>
                <span class="alumni-year">届：<%= a.getGraduationYear() %></span>
                <% } %>
            </div>
            <% } %>
        </div>
        <% } %>
        <% if (alumniList.isEmpty() && honoraryList.isEmpty()) { %>
        <div class="alumni-list"><div class="alumni-item">暂无校友信息</div></div>
        <% } %>
        <div class="inscription">校友星链计划 · 全球智慧网络，联结创新者与思想者</div>
    </div>
<!-- 校友详情模态框 -->
<div class="alm-modal-overlay" id="almModalOverlay" onclick="closeAlumniModal()"></div>
<div class="alm-modal" id="almModal">
    <button class="alm-modal-close" onclick="closeAlumniModal()">✕</button>
    <div class="alm-modal-avatar" id="almModalAvatar">👤</div>
    <h2 id="almModalName"></h2>
    <div class="alm-modal-badge" id="almModalBadge"></div>
    <div class="alm-modal-info" id="almModalInfo"></div>
    <div class="alm-modal-achieve" id="almModalAchieve"></div>
</div>
<style>
.alm-modal-overlay {
    position: fixed; top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0,0,0,0.7); backdrop-filter: blur(8px);
    z-index: 9998; opacity: 0; visibility: hidden; transition: all .3s;
}
.alm-modal-overlay.active { opacity: 1; visibility: visible; }
.alm-modal {
    position: fixed; top: 50%; left: 50%; transform: translate(-50%,-50%) scale(0.92);
    background: linear-gradient(145deg, #0f1525, #0a0e18);
    border: 1px solid rgba(0,242,255,0.35); border-radius: 20px;
    padding: 32px; width: 90%; max-width: 440px; z-index: 9999;
    opacity: 0; visibility: hidden; transition: all .35s cubic-bezier(.175,.885,.32,1.275);
    box-shadow: 0 20px 60px rgba(0,0,0,0.5), 0 0 30px rgba(0,242,255,0.1);
    text-align: center;
}
.alm-modal.active { opacity: 1; visibility: visible; transform: translate(-50%,-50%) scale(1); }
.alm-modal-close {
    position: absolute; top: 14px; right: 14px; width: 32px; height: 32px;
    border-radius: 50%; border: 1px solid rgba(255,255,255,0.15);
    background: rgba(255,255,255,0.05); color: #fff; font-size: 1rem;
    cursor: pointer; transition: all .25s; display: flex; align-items: center; justify-content: center;
}
.alm-modal-close:hover { background: rgba(255,71,87,0.3); border-color: #ff4757; transform: rotate(90deg); }
.alm-modal-avatar { font-size: 3.5rem; margin-bottom: 12px; }
.alm-modal h2 { margin: 0 0 8px; font-size: 1.3rem; color: #fff; }
.alm-modal-badge { display: inline-block; padding: 3px 12px; border-radius: 10px; font-size: 0.75rem; margin-bottom: 16px; }
.alm-modal-info { color: rgba(255,255,255,0.75); font-size: 0.9rem; line-height: 1.8; margin-bottom: 14px; }
.alm-modal-achieve { color: rgba(255,255,255,0.85); font-size: 0.88rem; line-height: 1.7; padding: 14px; background: rgba(0,242,255,0.05); border-radius: 12px; border: 1px solid rgba(0,242,255,0.15); }
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
    window.openAlumniModal = function(name, title, company, achievement, year, isHonorary) {
        document.getElementById('almModalName').textContent = name || '未知';
        document.getElementById('almModalAvatar').textContent = isHonorary ? '🏅' : '👤';
        var badge = document.getElementById('almModalBadge');
        if (isHonorary) { badge.textContent = '荣誉校友'; badge.style.background = 'rgba(255,215,0,0.15)'; badge.style.color = '#ffd700'; badge.style.border = '1px solid rgba(255,215,0,0.4)'; }
        else { badge.textContent = '杰出校友'; badge.style.background = 'rgba(0,242,255,0.15)'; badge.style.color = '#00f2ff'; badge.style.border = '1px solid rgba(0,242,255,0.4)'; }
        var info = '';
        if (title) info += '<div>🏢 ' + title + '</div>';
        if (company) info += '<div>💼 ' + company + '</div>';
        if (year) info += '<div>🎓 毕业届：' + year + '</div>';
        document.getElementById('almModalInfo').innerHTML = info || '<div>暂无详细信息</div>';
        document.getElementById('almModalAchieve').textContent = achievement || '暂无成就记录';
        document.getElementById('almModalOverlay').classList.add('active');
        document.getElementById('almModal').classList.add('active');
    };
    window.closeAlumniModal = function() {
        document.getElementById('almModalOverlay').classList.remove('active');
        document.getElementById('almModal').classList.remove('active');
    };
    document.addEventListener('keydown', function(e){ if(e.key==='Escape') closeAlumniModal(); });
})();
</script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
