<%--
 =============================================================================
 logout.jsp
 =============================================================================

 用途      功能页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   表单 GET/POST 提交 —— 携带 URL 参数或隐藏字段

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // 设置不缓存页面，确保浏览器重新加载
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
    
    // 先清除所有 Session 属性
    session.removeAttribute("currentUser");
    session.removeAttribute("username");
    session.removeAttribute("userRole");
    session.removeAttribute("isLoggedIn");
    
    // 最后使 Session 失效
    session.invalidate();
    
    // 跳转回首页，并强制重新加载
    response.sendRedirect("../index.jsp?logout=true&t=" + System.currentTimeMillis());
%>
