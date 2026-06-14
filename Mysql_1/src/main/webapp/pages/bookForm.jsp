<%--
 =============================================================================
 bookForm.jsp
 =============================================================================

 用途      表单 / 编辑页面
 标签库    prefix="c" uri="http://java.sun.com/jsp/jstl/core"

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   EL 表达式 —— ${} 访问后端数据
   JSTL 核心标签 —— <c:forEach> / <c:if> / <c:choose>
   ${pageContext.request.contextPath} —— 获取应用上下文根路径
   DOM 事件处理
   表单 GET/POST 提交 —— 携带 URL 参数或隐藏字段

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${empty book ? '添加' : '编辑'}图书 - 博雅书院</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: radial-gradient(ellipse at 50% 0%, rgba(15, 23, 42, 0.9), #0a0c15);
            font-family: 'Inter', 'Segoe UI', sans-serif;
            min-height: 100vh;
            color: #fff;
            padding: 2rem;
        }
        .form-container { max-width: 600px; margin: 0 auto; background: rgba(20, 28, 45, 0.8); border-radius: 12px; border: 1px solid rgba(0, 242, 255, 0.3); padding: 2rem; }
        .form-title { font-size: 1.2rem; margin-bottom: 1.5rem; background: linear-gradient(135deg, #fff, #88ccff); -webkit-background-clip: text; background-clip: text; color: transparent; }
        .form-group { margin-bottom: 1rem; }
        .form-label { display: block; margin-bottom: 4px; font-size: 12px; color: #aaa; }
        .form-input { width: 100%; padding: 10px 12px; border-radius: 8px; border: 1px solid rgba(0, 242, 255, 0.3); background: rgba(10, 15, 25, 0.8); color: #fff; font-size: 14px; }
        .form-input:focus { outline: none; border-color: #00f2ff; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
        .btn-group { display: flex; gap: 1rem; margin-top: 1.5rem; }
        .btn { padding: 10px 20px; border-radius: 8px; border: none; font-size: 14px; cursor: pointer; }
        .btn-primary { background: linear-gradient(135deg, rgba(45, 126, 255, 0.4), rgba(0, 242, 255, 0.3)); color: #00f2ff; }
        .btn-secondary { background: rgba(100, 100, 100, 0.2); color: #aaa; }
        .btn:hover { transform: translateY(-1px); }
        .error { color: #ff6464; font-size: 12px; margin-bottom: 1rem; }
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
<div class="form-container">
    <h1 class="form-title">📚 ${empty book ? '添加' : '编辑'}图书</h1>
    
    <c:if test="${not empty error}">
        <div class="error">${error}</div>
    </c:if>
    
    <form action="${pageContext.request.contextPath}/booksList" method="post">
        <input type="hidden" name="action" value="${empty book ? 'add' : 'update'}">
        <c:if test="${not empty book}">
            <input type="hidden" name="id" value="${book.id}">
        </c:if>
        
        <div class="form-group">
            <label class="form-label">书名 *</label>
            <input type="text" class="form-input" name="bookTitle" value="${book.bookTitle}" required placeholder="请输入书名">
        </div>
        
        <div class="form-row">
            <div class="form-group">
                <label class="form-label">作者</label>
                <input type="text" class="form-input" name="bookAuthor" value="${book.bookAuthor}" placeholder="作者">
            </div>
            <div class="form-group">
                <label class="form-label">分类</label>
                <select class="form-input" name="typeId">
                    <option value="">-- 选择分类 --</option>
                    <c:forEach var="type" items="${allTypes}">
                        <option value="${type.bTid}" ${book.typeId == type.bTid ? 'selected' : ''}>${type.bTypeName}</option>
                    </c:forEach>
                </select>
            </div>
        </div>
        
        <div class="form-group">
            <label class="form-label">简介</label>
            <textarea class="form-input" name="bookSummary" rows="3" placeholder="图书简介">${book.bookSummary}</textarea>
        </div>
        
        <div class="form-row">
            <div class="form-group">
                <label class="form-label">出版年份</label>
                <input type="date" class="form-input" name="bookPubYear" value="${book.bookPubYear}">
            </div>
            <div class="form-group">
                <label class="form-label">下载次数</label>
                <input type="number" class="form-input" name="downloadTimes" value="${book.downloadTimes}">
            </div>
        </div>
        
        <div class="form-group">
            <label class="form-label">封面图片路径</label>
            <input type="text" class="form-input" name="bookCover" value="${book.bookCover}" placeholder="/images/cover.jpg">
        </div>
        
        <div class="form-group">
            <label class="form-label">文件路径</label>
            <input type="text" class="form-input" name="bookFile" value="${book.bookFile}" placeholder="/files/book.pdf">
        </div>
        
        <div class="form-group">
            <label class="form-label">文件格式</label>
            <input type="text" class="form-input" name="bookFormat" value="${book.bookFormat}" placeholder="PDF, EPUB...">
        </div>
        
        <div class="btn-group">
            <button type="submit" class="btn btn-primary">保存</button>
            <button type="button" class="btn btn-secondary" onclick="location.href='${pageContext.request.contextPath}/booksList'">取消</button>
        </div>
    </form>
</div>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
