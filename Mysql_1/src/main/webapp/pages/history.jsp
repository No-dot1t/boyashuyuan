<%--
 =============================================================================
 history.jsp
 =============================================================================

 用途      功能页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   标准 HTML + JSP 语法

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ebookBuy301.pojo.HistoryRecord, java.util.ArrayList" %>
<%
    // 数据由 HistoryServlet 注入，此处只负责展示
    ArrayList<HistoryRecord> records = (ArrayList<HistoryRecord>) request.getAttribute("records");
    if (records == null) records = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <title>博雅书院 · 数字史册</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/history.css?v=2.0">
    <!-- ========== 浅色主题 · 历史轴线全覆盖 ========== -->
    <style>
        /* 基础底色 */
        html[data-theme$="-light"] body{background:linear-gradient(160deg,#e9e2d2,#ede5d3 50%,#e4dbca)!important;color:#3d3929!important}
        /* 标题 */
        html[data-theme$="-light"] .title-deco h1{background:linear-gradient(135deg,#3d3929,#2563eb 40%,#7c3aed)!important;-webkit-background-clip:text!important;background-clip:text!important;color:transparent!important}
        html[data-theme$="-light"] .title-deco h1::after{background:linear-gradient(90deg,transparent,rgba(37,99,235,.25),transparent)!important}
        html[data-theme$="-light"] .subtitle{color:rgba(61,57,41,.35)!important}
        /* 时间线 */
        html[data-theme$="-light"] .timeline::before{background:linear-gradient(180deg,rgba(37,99,235,.2) 0%,rgba(139,119,80,.15) 50%,rgba(37,99,235,.06) 100%)!important}
        /* 圆点 */
        html[data-theme$="-light"] .timeline-dot{background:linear-gradient(135deg,#2563eb,#7c3aed)!important;border-color:rgba(37,99,235,.25)!important;box-shadow:0 0 12px rgba(37,99,235,.15)!important}
        html[data-theme$="-light"] .timeline-item:hover .timeline-dot{box-shadow:0 0 22px rgba(37,99,235,.3)!important;border-color:rgba(37,99,235,.5)!important}
        /* 卡片 */
        html[data-theme$="-light"] .timeline-card{background:linear-gradient(145deg,rgba(238,233,222,.82),rgba(243,239,228,.9))!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .timeline-card::before{background:linear-gradient(180deg,rgba(37,99,235,.2),rgba(139,119,80,.1))!important}
        html[data-theme$="-light"] .timeline-item:hover .timeline-card{border-color:rgba(37,99,235,.12)!important;box-shadow:0 6px 24px rgba(139,119,80,.12),0 0 30px rgba(37,99,235,.02)!important}
        /* 年份 */
        html[data-theme$="-light"] .timeline-year{color:#2563eb!important;background:rgba(37,99,235,.06)!important;border-color:rgba(37,99,235,.12)!important}
        /* 内容 */
        html[data-theme$="-light"] .timeline-title{color:#3d3929!important}
        html[data-theme$="-light"] .timeline-desc{color:#7a7360!important}
        html[data-theme$="-light"] .timeline-img{border-color:rgba(139,119,80,.08)!important}
        /* 空状态 */
        html[data-theme$="-light"] .empty-state{color:#7a7360!important}
        /* 底部引用 */
        html[data-theme$="-light"] .quote{color:#7a7360!important;border-top-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .quote::before{color:rgba(37,99,235,.1)!important}
        /* 通用 */
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3{color:#3d3929!important}
        html[data-theme$="-light"] p{color:#7a7360!important}
    </style>
</head>
<body>
    <div class="container">
        <div class="title-deco">
            <h1>◈ 数字史册 · 博雅编年</h1>
            <p class="subtitle">从创始到未来，每一步都值得铭记</p>
        </div>
        <div class="timeline">
            <% 
            int recCount = 0;
            for (HistoryRecord record : records) {
                recCount++;
                String year = record.getYear() != null ? record.getYear() : "待定";
                String title = record.getTitle() != null ? record.getTitle() : "";
                String desc = record.getDescription() != null ? record.getDescription() : "";
                boolean hasImage = record.getImageUrl() != null && !record.getImageUrl().isEmpty();
            %>
            <div class="timeline-item">
                <div class="timeline-dot"><span><%= recCount %></span></div>
                <div class="timeline-card">
                    <div class="timeline-year"><%= year %></div>
                    <h3 class="timeline-title"><%= title %></h3>
                    <p class="timeline-desc"><%= desc %></p>
                    <% if (hasImage) { %>
                    <img class="timeline-img" src="<%= record.getImageUrl() %>" alt="<%= title %>">
                    <% } %>
                </div>
            </div>
            <% } %>
            <% if (recCount == 0) { %>
            <div class="empty-state"><p>暂无历史记录</p></div>
            <% } %>
        </div>
        <div class="quote">"数据为翼，人文为魂" —— 博雅院训·数字铭文</div>
    </div>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
