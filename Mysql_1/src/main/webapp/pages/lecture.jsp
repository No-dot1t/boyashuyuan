<%--
 =============================================================================
 lecture.jsp
 =============================================================================

 用途      功能页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ebookBuy301.pojo.Lecture, java.util.ArrayList, java.text.SimpleDateFormat" %>
<%!
    String h(String s) { if (s == null) return ""; return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#039;"); }
%>
<%
    ArrayList<Lecture> lectures = (ArrayList<Lecture>) request.getAttribute("lectures");
    ArrayList<Lecture> upcoming = (ArrayList<Lecture>) request.getAttribute("upcoming");
    if (lectures == null) lectures = new ArrayList<>();
    if (upcoming == null) upcoming = new ArrayList<>();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd");
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <title>博雅书院 · 科技风 | 前沿讲坛</title>
    <link rel="stylesheet" href="<%= contextPath %>/CSS/lecture.css?v=1.0">
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
/CSS/lecture.css">
</head>
<body>
    <div class="container">
        <h1>📡 前沿讲坛 · 智识脉冲</h1>
        <div class="search-filter-bar" style="display:flex;gap:10px;margin-bottom:20px;flex-wrap:wrap;justify-content:center">
            <input type="text" class="sf-input" placeholder="搜索讲座标题、主讲人..." oninput="filterList(this.value)" style="padding:8px 16px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:.9rem;outline:none;width:240px">
        </div>
        <div class="lecture-grid">
            <% if (lectures.isEmpty()) { %>
            <div class="lecture-card"><h3>暂无讲座信息</h3><p>敬请期待</p></div>
            <% } else {
                int lecIdx = 0;
                for (Lecture lec : lectures) {
                    lecIdx++;
                    String dateStr = lec.getLectureDate() != null ? sdf.format(lec.getLectureDate()) : "待定";
                    String statusBadge = "upcoming".equals(lec.getStatus()) ? "🔜 即将开始" :
                                         "ongoing".equals(lec.getStatus()) ? "🔴 进行中" :
                                         "completed".equals(lec.getStatus()) ? "✅ 已完成" : "📢";
                    String statusColor = "upcoming".equals(lec.getStatus()) ? "#ffa502" :
                                         "ongoing".equals(lec.getStatus()) ? "#ff4757" :
                                         "completed".equals(lec.getStatus()) ? "#2ed573" : "#00f2ff";
            %>
            <div class="lecture-card sf-filterable" onclick="openLectureModal(<%= lecIdx %>,'<%= h(lec.getTitle()) %>','<%= h(lec.getSpeaker()) %>','<%= h(lec.getSpeakerTitle()) %>','<%= dateStr %>','<%= statusBadge %>','<%= h(lec.getDescription()) %>','<%= lec.isOnline() && lec.getMeetingUrl() != null ? lec.getMeetingUrl() : "" %>','<%= statusColor %>')" style="animation: fadeInUp 0.5s ease <%= lecIdx * 0.08 %>s both; cursor:pointer">
                <span class="lec-date"><%= dateStr %></span>
                <h3><%= lec.getTitle() != null ? lec.getTitle() : "" %></h3>
                <p>主讲：<%= lec.getSpeaker() != null ? lec.getSpeaker() : "" %>
                    <% if (lec.getSpeakerTitle() != null && !lec.getSpeakerTitle().isEmpty()) { %>
                    · <%= lec.getSpeakerTitle() %>
                    <% } %></p>
                <% if (lec.getDescription() != null && !lec.getDescription().isEmpty()) { %>
                <p class="lec-desc"><%= lec.getDescription() %></p>
                <% } %>
                <span class="lec-status" style="color:<%= statusColor %>;border-color:<%= statusColor %>"><%= statusBadge %></span>
                <% if (lec.isOnline() && lec.getMeetingUrl() != null && !lec.getMeetingUrl().isEmpty()) { %>
                <a class="lec-link" href="<%= lec.getMeetingUrl() %>" target="_blank" onclick="event.stopPropagation()">🌐 在线参加</a>
                <% } %>
            </div>
            <% } } %>
        </div>
        <div class="note">所有讲座开放元宇宙同步直播，欢迎参与线上智识共振。</div>
    </div>
<!-- 讲座详情模态框 -->
<div class="lec-modal-overlay" id="lecModalOverlay" onclick="closeLectureModal()"></div>
<div class="lec-modal" id="lecModal">
    <button class="lec-modal-close" onclick="closeLectureModal()">✕</button>
    <div class="lec-modal-status" id="lecModalStatus"></div>
    <h2 id="lecModalTitle"></h2>
    <div class="lec-modal-meta">
        <span id="lecModalDate"></span>
        <span id="lecModalSpeaker"></span>
    </div>
    <div class="lec-modal-desc" id="lecModalDesc"></div>
    <div class="lec-modal-actions" id="lecModalActions"></div>
</div>

<style>
@keyframes fadeInUp {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}
.lec-status {
    display: inline-block; padding: 3px 10px; border-radius: 8px; font-size: 0.75rem;
    border: 1px solid; margin-top: 8px;
}
.lec-modal-overlay {
    position: fixed; top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0,0,0,0.7); backdrop-filter: blur(8px);
    z-index: 9998; opacity: 0; visibility: hidden; transition: all .3s;
}
.lec-modal-overlay.active { opacity: 1; visibility: visible; }
.lec-modal {
    position: fixed; top: 50%; left: 50%; transform: translate(-50%,-50%) scale(0.92);
    background: linear-gradient(145deg, #0f1525, #0a0e18);
    border: 1px solid rgba(0,242,255,0.35); border-radius: 20px;
    padding: 32px; width: 90%; max-width: 520px; z-index: 9999;
    opacity: 0; visibility: hidden; transition: all .35s cubic-bezier(.175,.885,.32,1.275);
    box-shadow: 0 20px 60px rgba(0,0,0,0.5), 0 0 30px rgba(0,242,255,0.1);
}
.lec-modal.active { opacity: 1; visibility: visible; transform: translate(-50%,-50%) scale(1); }
.lec-modal-close {
    position: absolute; top: 14px; right: 14px; width: 32px; height: 32px;
    border-radius: 50%; border: 1px solid rgba(255,255,255,0.15);
    background: rgba(255,255,255,0.05); color: #fff; font-size: 1rem;
    cursor: pointer; transition: all .25s; display: flex; align-items: center; justify-content: center;
}
.lec-modal-close:hover { background: rgba(255,71,87,0.3); border-color: #ff4757; transform: rotate(90deg); }
.lec-modal-status { display: inline-block; padding: 4px 12px; border-radius: 10px; font-size: 0.8rem; margin-bottom: 12px; border: 1px solid; }
.lec-modal h2 { margin: 0 0 12px; font-size: 1.3rem; color: #fff; }
.lec-modal-meta { display: flex; gap: 16px; margin-bottom: 16px; font-size: 0.85rem; color: rgba(255,255,255,0.7); }
.lec-modal-desc { color: rgba(255,255,255,0.85); line-height: 1.7; font-size: 0.92rem; margin-bottom: 20px; max-height: 200px; overflow-y: auto; }
.lec-modal-actions { display: flex; gap: 10px; }
.lec-modal-actions a, .lec-modal-actions button {
    flex: 1; padding: 10px; border-radius: 10px; text-align: center; text-decoration: none;
    font-size: 0.85rem; font-weight: 600; cursor: pointer; transition: all .25s; border: none;
}
.lec-modal-actions a { background: linear-gradient(135deg,#00f2ff,#0099ff); color: #0a0e18; }
.lec-modal-actions a:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,242,255,0.3); }
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
    window.openLectureModal = function(idx, title, speaker, speakerTitle, date, status, desc, url, color) {
        document.getElementById('lecModalTitle').textContent = title || '未命名讲座';
        document.getElementById('lecModalStatus').textContent = status || '';
        document.getElementById('lecModalStatus').style.color = color || '#00f2ff';
        document.getElementById('lecModalStatus').style.borderColor = color || '#00f2ff';
        document.getElementById('lecModalDate').textContent = '📅 ' + (date || '待定');
        document.getElementById('lecModalSpeaker').textContent = '🎤 ' + (speaker || '待定') + (speakerTitle ? ' · ' + speakerTitle : '');
        document.getElementById('lecModalDesc').textContent = desc || '暂无详细描述';
        var actions = document.getElementById('lecModalActions');
        if (url) {
            actions.innerHTML = '<a href="' + url + '" target="_blank">🌐 在线参加</a>';
        } else {
            actions.innerHTML = '<button style="background:rgba(255,255,255,0.08);color:#fff;border:1px solid rgba(255,255,255,0.15);">暂无在线链接</button>';
        }
        document.getElementById('lecModalOverlay').classList.add('active');
        document.getElementById('lecModal').classList.add('active');
    };
    window.closeLectureModal = function() {
        document.getElementById('lecModalOverlay').classList.remove('active');
        document.getElementById('lecModal').classList.remove('active');
    };
    document.addEventListener('keydown', function(e){ if(e.key==='Escape') closeLectureModal(); });
})();
</script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
