<%--
 =============================================================================
 bookTypeList.jsp
 =============================================================================

 用途      数据列表 / 管理页面
 标签库    prefix="c" uri="http://java.sun.com/jsp/jstl/core"

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   EL 表达式 —— ${} 访问后端数据
   JSTL 核心标签 —— <c:forEach> / <c:if> / <c:choose>
   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById
   表单 GET/POST 提交 —— 携带 URL 参数或隐藏字段

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ebookBuy301.pojo.BookType" %>
<%@ page import="java.util.ArrayList" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%!
    // 转义字符串中的特殊字符，防止JS出错
    String escapeJs(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"")
                  .replace("\n", " ").replace("\r", " ");
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书分类管理 - 博雅书院</title>
    <style>
        :root {
            --bg-dark: #0a0c15;
            --bg-card: rgba(20, 28, 45, 0.8);
            --glow-cyan: #00f2ff;
            --glow-purple: #b77eff;
            --accent-blue: #2d7eff;
            --accent-red: #ff6464;
            --accent-green: #4ade80;
            --text-primary: #ffffff;
            --text-secondary: #d0d8e8;
            --border-glow: rgba(0, 242, 255, 0.3);
        }
        
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            background: radial-gradient(ellipse at 50% 0%, rgba(15, 23, 42, 0.9), var(--bg-dark));
            font-family: 'Inter', 'Segoe UI', 'Poppins', system-ui, sans-serif;
            min-height: 100vh;
            color: var(--text-primary);
            padding: 1rem;
            font-size: 13px;
        }
        
        * { scrollbar-width: none !important; }
        
        .page-container { max-width: 1400px; margin: 0 auto; }
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
            padding: 0.8rem 1.2rem;
            background: var(--bg-card);
            border-radius: 12px;
            border: 1px solid var(--border-glow);
            backdrop-filter: blur(12px);
        }
        
        .page-title {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 1rem;
            font-weight: 700;
            background: linear-gradient(135deg, #fff, #88ccff);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }
        
        .header-right {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        /* ---------- 搜索栏 ---------- */
        .search-bar {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-bottom: 1rem;
            padding: 0.7rem 1rem;
            background: var(--bg-card);
            border-radius: 10px;
            border: 1px solid rgba(0, 242, 255, 0.15);
        }
        .search-input {
            flex: 1;
            padding: 8px 14px;
            border-radius: 8px;
            border: 1px solid rgba(0, 242, 255, 0.3);
            background: rgba(10, 15, 25, 0.8);
            color: var(--text-primary);
            font-size: 13px;
            outline: none;
            transition: border-color 0.2s;
            max-width: 320px;
        }
        .search-input:focus {
            border-color: var(--glow-cyan);
            box-shadow: 0 0 12px rgba(0, 242, 255, 0.15);
        }

        .btn {
            padding: 6px 14px;
            border-radius: 8px;
            border: none;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, rgba(45, 126, 255, 0.4), rgba(0, 242, 255, 0.3));
            border: 1px solid rgba(0, 242, 255, 0.4);
            color: var(--glow-cyan);
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, rgba(45, 126, 255, 0.6), rgba(0, 242, 255, 0.5));
            transform: translateY(-1px);
        }
        
        .btn-danger {
            background: rgba(255, 100, 100, 0.2);
            border: 1px solid rgba(255, 100, 100, 0.3);
            color: var(--accent-red);
        }
        .btn-danger:hover {
            background: rgba(255, 100, 100, 0.35);
            transform: translateY(-1px);
        }
        
        .btn-warning {
            background: rgba(255, 193, 7, 0.2);
            border: 1px solid rgba(255, 193, 7, 0.3);
            color: #ffc107;
        }
        .btn-warning:hover {
            background: rgba(255, 193, 7, 0.35);
            transform: translateY(-1px);
        }
        
        .btn-sm { padding: 4px 8px; font-size: 11px; }
        
        .btn-search {
            background: rgba(0, 242, 255, 0.12);
            border: 1px solid rgba(0, 242, 255, 0.3);
            color: var(--glow-cyan);
        }
        .btn-search:hover {
            background: rgba(0, 242, 255, 0.25);
        }
        .btn-reset {
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.15);
            color: var(--text-secondary);
        }
        .btn-reset:hover {
            background: rgba(255, 255, 255, 0.15);
        }

        .table-card {
            background: var(--bg-card);
            border-radius: 12px;
            border: 1px solid var(--border-glow);
            overflow: auto;
            scrollbar-width: none;
            -ms-overflow-style: none;
            max-height: calc(100vh - 210px);
        }
        .table-card::-webkit-scrollbar {
            display: none;
        }
        
        .data-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 780px;
        }
        
        .data-table thead {
            background: linear-gradient(90deg, rgba(0, 242, 255, 0.15), rgba(45, 126, 255, 0.1));
            position: sticky;
            top: 0;
        }
        
        .data-table th {
            padding: 10px 12px;
            text-align: left;
            font-weight: 600;
            color: var(--glow-cyan);
            font-size: 12px;
            border-bottom: 1px solid var(--border-glow);
        }
        
        .data-table td {
            padding: 8px 12px;
            border-bottom: 1px solid rgba(0, 242, 255, 0.08);
            font-size: 12px;
        }
        
        .data-table tbody tr:hover {
            background: rgba(0, 242, 255, 0.08);
        }

        .action-btns {
            display: flex;
            gap: 6px;
            align-items: center;
        }
        
        .empty-state {
            text-align: center;
            padding: 3rem 1rem;
            color: rgba(255, 255, 255, 0.4);
            font-size: 14px;
        }
        .empty-state .icon { font-size: 3rem; margin-bottom: 0.5rem; }

        /* ---------- 模态框 ---------- */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.7);
            z-index: 1000;
            align-items: center;
            justify-content: center;
            backdrop-filter: blur(4px);
        }
        .modal-overlay.active { display: flex; }
        
        .modal {
            background: linear-gradient(145deg, #141c2d, #0f1520);
            border-radius: 16px;
            border: 1px solid var(--border-glow);
            padding: 1.5rem;
            width: 90%;
            max-width: 520px;
            box-shadow: 0 0 40px rgba(0, 242, 255, 0.15), 0 20px 60px rgba(0,0,0,0.5);
            animation: modalIn 0.25s ease;
        }
        
        @keyframes modalIn {
            from { opacity: 0; transform: scale(0.95) translateY(10px); }
            to { opacity: 1; transform: scale(1) translateY(0); }
        }
        
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
            padding-bottom: 0.8rem;
            border-bottom: 1px solid var(--border-glow);
        }
        
        .modal-title {
            font-size: 1rem;
            font-weight: 700;
            background: linear-gradient(135deg, #fff, #88ccff);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }
        
        .modal-close {
            width: 28px; height: 28px;
            border-radius: 50%;
            border: 1px solid rgba(255, 100, 100, 0.3);
            background: rgba(255, 100, 100, 0.1);
            color: var(--accent-red);
            font-size: 1rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
        }
        .modal-close:hover {
            background: rgba(255, 100, 100, 0.3);
            transform: rotate(90deg);
        }
        
        .form-group { margin-bottom: 0.8rem; }
        
        .form-label {
            display: block;
            margin-bottom: 4px;
            font-size: 12px;
            color: var(--text-secondary);
            font-weight: 500;
        }
        .form-label .required {
            color: var(--accent-red);
            margin-left: 2px;
        }
        
        .form-input, .form-select {
            width: 100%;
            padding: 8px 12px;
            border-radius: 8px;
            border: 1px solid rgba(0, 242, 255, 0.3);
            background: rgba(10, 15, 25, 0.8);
            color: var(--text-primary);
            font-size: 13px;
            outline: none;
            transition: border-color 0.2s;
        }
        
        .form-input:focus, .form-select:focus {
            border-color: var(--glow-cyan);
            box-shadow: 0 0 10px rgba(0, 242, 255, 0.12);
        }
        .form-select option { background: #141c2d; color: #fff; }
        
        textarea.form-input { resize: vertical; min-height: 80px; }
        
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 0.8rem;
            margin-top: 1rem;
            padding-top: 0.8rem;
            border-top: 1px solid var(--border-glow);
        }
        
        .hint {
            font-size: 11px;
            color: rgba(255,255,255,0.35);
            margin-top: 3px;
        }
        /* ══════════ 浅色主题 · 图书分类管理全覆盖 ══════════ */
        html[data-theme$="-light"] body {
            background: linear-gradient(170deg, #e9e2d2, #ede5d3 40%, #e4dbca) !important;
            color: #3d3929 !important;
        }
        /* ── 滚动条 ── */
        html[data-theme$="-light"] ::-webkit-scrollbar-track { background: rgba(139, 119, 80, 0.04) !important; }
        html[data-theme$="-light"] ::-webkit-scrollbar-thumb { background: rgba(37, 99, 235, 0.15) !important; }
        html[data-theme$="-light"] * { scrollbar-color: rgba(37, 99, 235, 0.3) rgba(139, 119, 80, 0.04) !important; }
        /* ── 页面头部 ── */
        html[data-theme$="-light"] .page-header {
            background: rgba(238, 233, 222, 0.85) !important;
            border-color: rgba(37, 99, 235, 0.1) !important;
            box-shadow: 0 4px 20px rgba(139, 119, 80, 0.08) !important;
        }
        html[data-theme$="-light"] .page-title {
            background: linear-gradient(135deg, #3d3929, #2563eb) !important;
            -webkit-background-clip: text !important;
            background-clip: text !important;
            color: transparent !important;
        }
        /* ── 搜索栏 ── */
        html[data-theme$="-light"] .search-bar {
            background: rgba(238, 233, 222, 0.85) !important;
            border-color: rgba(139, 119, 80, 0.06) !important;
        }
        html[data-theme$="-light"] .search-input {
            background: rgba(238, 233, 222, 0.85) !important;
            border-color: rgba(139, 119, 80, 0.1) !important;
            color: #3d3929 !important;
        }
        html[data-theme$="-light"] .search-input:focus {
            border-color: rgba(37, 99, 235, 0.25) !important;
            box-shadow: 0 0 10px rgba(37, 99, 235, 0.06) !important;
        }
        html[data-theme$="-light"] .search-input::placeholder {
            color: rgba(61, 57, 41, 0.25) !important;
        }
        /* ── 按钮 ── */
        html[data-theme$="-light"] .btn-primary {
            background: linear-gradient(135deg, rgba(37, 99, 235, 0.1), rgba(124, 58, 237, 0.06)) !important;
            border-color: rgba(37, 99, 235, 0.18) !important;
            color: #2563eb !important;
        }
        html[data-theme$="-light"] .btn-primary:hover {
            background: linear-gradient(135deg, rgba(37, 99, 235, 0.2), rgba(124, 58, 237, 0.12)) !important;
        }
        html[data-theme$="-light"] .btn-danger {
            background: rgba(220, 60, 60, 0.06) !important;
            border-color: rgba(220, 60, 60, 0.15) !important;
            color: #b91c1c !important;
        }
        html[data-theme$="-light"] .btn-danger:hover {
            background: rgba(220, 60, 60, 0.12) !important;
        }
        html[data-theme$="-light"] .btn-warning {
            background: rgba(245, 158, 11, 0.06) !important;
            border-color: rgba(245, 158, 11, 0.15) !important;
            color: #b45309 !important;
        }
        html[data-theme$="-light"] .btn-warning:hover {
            background: rgba(245, 158, 11, 0.12) !important;
        }
        html[data-theme$="-light"] .btn-search {
            background: rgba(37, 99, 235, 0.06) !important;
            border-color: rgba(37, 99, 235, 0.12) !important;
            color: #2563eb !important;
        }
        html[data-theme$="-light"] .btn-search:hover {
            background: rgba(37, 99, 235, 0.15) !important;
        }
        html[data-theme$="-light"] .btn-reset {
            background: rgba(139, 119, 80, 0.04) !important;
            border-color: rgba(139, 119, 80, 0.1) !important;
            color: #7a7360 !important;
        }
        html[data-theme$="-light"] .btn-reset:hover {
            background: rgba(139, 119, 80, 0.1) !important;
            color: #3d3929 !important;
        }
        /* ── 表格 ── */
        html[data-theme$="-light"] .table-card {
            background: rgba(238, 233, 222, 0.85) !important;
            border-color: rgba(139, 119, 80, 0.06) !important;
        }
        html[data-theme$="-light"] .data-table thead {
            background: linear-gradient(90deg, rgba(37, 99, 235, 0.04), rgba(139, 119, 80, 0.02)) !important;
        }
        html[data-theme$="-light"] .data-table th {
            color: #5c5540 !important;
            border-bottom-color: rgba(139, 119, 80, 0.08) !important;
        }
        html[data-theme$="-light"] .data-table td {
            border-bottom-color: rgba(139, 119, 80, 0.05) !important;
        }
        html[data-theme$="-light"] .data-table tbody tr:hover {
            background: rgba(37, 99, 235, 0.04) !important;
        }
        /* ── 空状态 ── */
        html[data-theme$="-light"] .empty-state {
            color: #7a7360 !important;
        }
        html[data-theme$="-light"] .empty-state .icon {
            opacity: 0.35 !important;
        }
        /* ── 模态框 ── */
        html[data-theme$="-light"] .modal-overlay {
            background: rgba(61, 57, 41, 0.35) !important;
        }
        html[data-theme$="-light"] .modal {
            background: linear-gradient(145deg, rgba(238, 233, 222, 0.98), rgba(245, 240, 232, 0.96)) !important;
            border-color: rgba(37, 99, 235, 0.12) !important;
            box-shadow: 0 20px 60px rgba(139, 119, 80, 0.15), 0 0 30px rgba(37, 99, 235, 0.05) !important;
        }
        html[data-theme$="-light"] .modal-header {
            border-bottom-color: rgba(139, 119, 80, 0.06) !important;
        }
        html[data-theme$="-light"] .modal-title {
            background: linear-gradient(135deg, #3d3929, #2563eb) !important;
            -webkit-background-clip: text !important;
            background-clip: text !important;
            color: transparent !important;
        }
        html[data-theme$="-light"] .modal-close {
            background: rgba(220, 60, 60, 0.06) !important;
            border-color: rgba(220, 60, 60, 0.12) !important;
            color: #b91c1c !important;
        }
        html[data-theme$="-light"] .modal-close:hover {
            background: rgba(220, 60, 60, 0.12) !important;
        }
        html[data-theme$="-light"] .modal-footer {
            border-top-color: rgba(139, 119, 80, 0.06) !important;
        }
        /* ── 表单 ── */
        html[data-theme$="-light"] .form-label { color: #5c5540 !important; }
        html[data-theme$="-light"] .form-label .required { color: #b91c1c !important; }
        html[data-theme$="-light"] .form-input, html[data-theme$="-light"] .form-select {
            background: rgba(238, 233, 222, 0.85) !important;
            border-color: rgba(139, 119, 80, 0.1) !important;
            color: #3d3929 !important;
        }
        html[data-theme$="-light"] .form-input:focus, html[data-theme$="-light"] .form-select:focus {
            border-color: rgba(37, 99, 235, 0.25) !important;
            box-shadow: 0 0 10px rgba(37, 99, 235, 0.06) !important;
        }
        html[data-theme$="-light"] .form-select option {
            background: #f0ebe0 !important;
            color: #3d3929 !important;
        }
        /* ── 提示 ── */
        html[data-theme$="-light"] .hint { color: rgba(61, 57, 41, 0.35) !important; }
        /* ── 通用 ── */
        html[data-theme$="-light"] h1, html[data-theme$="-light"] h2, html[data-theme$="-light"] h3 { color: #3d3929 !important; }
        html[data-theme$="-light"] ::selection { background: rgba(37, 99, 235, 0.15) !important; color: #3d3929 !important; }
    </style>
</head>
<body>
<div class="page-container">
    <!-- 页面头部 -->
    <div class="page-header">
        <div class="page-title">📂 图书分类管理</div>
        <div class="header-right">
            <form action="<%=request.getContextPath()%>/bookTypeList" method="get" style="display:flex;gap:10px;align-items:center;">
                <input type="text" class="search-input" name="searchName" placeholder="搜索分类名称..." value="${param.searchName}">
                <button type="submit" class="btn btn-search">🔍 搜索</button>
                <c:if test="${not empty param.searchName}">
                    <a href="<%=request.getContextPath()%>/bookTypeList" class="btn btn-reset">清除</a>
                </c:if>
            </form>
            <button class="btn btn-primary" onclick="openAddModal()">添加分类</button>
        </div>
    </div>
    
    <!-- 数据表格 -->
    <div class="table-card">
        <table class="data-table">
            <thead>
                <tr>
                    <th style="width:90px;">ID</th>
                    <th style="min-width:120px;">分类名称</th>
                    <th style="width:110px;">父分类</th>
                    <th>分类描述</th>
                    <th style="width:130px;">操作</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty types}">
                        <tr>
                            <td colspan="5">
                                <div class="empty-state">
                                    <div class="icon">📂</div>
                                    <c:if test="${not empty param.searchName}">
                                        没有找到匹配 "<strong>${param.searchName}</strong>" 的分类
                                    </c:if>
                                    <c:if test="${empty param.searchName}">
                                        暂无分类数据，点击上方按钮添加
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="type" items="${types}">
                            <%
                                BookType bt = (BookType) pageContext.getAttribute("type");
                                String jsBtid = escapeJs(bt.getbTid());
                                String jsName = escapeJs(bt.getbTypeName());
                                String jsText = escapeJs(bt.getBtText());
                                String jsParent = escapeJs(bt.getbTPerentId());
                                request.setAttribute("_jsBtid", jsBtid);
                                request.setAttribute("_jsName", jsName);
                                request.setAttribute("_jsText", jsText);
                                request.setAttribute("_jsParent", jsParent);
                            %>
                            <tr data-id="${type.bTid}" data-parent="${type.bTPerentId}">
                                <td><strong style="font-size:11px;color:rgba(255,255,255,0.5);">${type.bTid}</strong></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty type.bTPerentId && type.bTPerentId != '0'}">
                                            <span style="padding-left: 20px; color: var(--glow-purple);">└─ ${type.bTypeName}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="font-weight: 600; color: var(--glow-cyan);">📁 ${type.bTypeName}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty type.bTPerentId && type.bTPerentId != '0'}">
                                            <span style="color: var(--text-secondary); font-size: 11px;">${type.parentName}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: var(--accent-green); font-size: 11px;">顶级分类</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="color: rgba(255,255,255,0.65); max-width: 300px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${type.btText}">${type.btText}</td>
                                <td>
                                    <div class="action-btns">
                                        <button class="btn btn-sm btn-warning" onclick='editType("${_jsBtid}","${_jsName}","${_jsText}","${_jsParent}")'>✏️</button>
                                        <form action="<%=request.getContextPath()%>/bookTypeList" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${type.bTid}">
                                            <input type="hidden" name="_csrf" value="<%= com.ebookBuy301.util.CsrfUtil.getToken(request.getSession()) %>">
                                            <button type="submit" class="btn btn-sm btn-danger">🗑️</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>

<!-- 添加/编辑分类模态框 -->
<div class="modal-overlay" id="typeModal">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title" id="modalTitle">添加分类</span>
            <button class="modal-close" onclick="closeModal()">✕</button>
        </div>
        <form action="<%=request.getContextPath()%>/bookTypeList" method="post" id="typeForm">
            <input type="hidden" name="action" id="formAction" value="add">
            <input type="hidden" name="bTid" id="bTid">
            
            <div class="form-group">
                <label class="form-label">分类名称 <span class="required">*</span></label>
                <input type="text" class="form-input" name="bTypeName" id="bTypeName" required placeholder="请输入分类名称">
            </div>
            
            <div class="form-group">
                <label class="form-label">父分类</label>
                <select class="form-select" name="bTPerentId" id="bTPerentId">
                    <option value="">-- 顶级分类（无父分类）--</option>
                    <c:forEach var="topType" items="${topTypes}">
                        <option value="${topType.bTid}">📁 ${topType.bTypeName}</option>
                    </c:forEach>
                </select>
                <div class="hint">选择父分类创建子分类，不选则为顶级分类</div>
            </div>
            
            <div class="form-group">
                <label class="form-label">分类描述</label>
                <textarea class="form-input" name="btText" id="btText" rows="4" placeholder="请输入分类描述（可选）"></textarea>
            </div>
            
            <div class="modal-footer">
                <button type="button" class="btn btn-danger" onclick="closeModal()">取消</button>
                <button type="submit" class="btn btn-primary">保存</button>
            </div>
        </form>
    </div>
</div>

<script>
// 打开添加弹窗
function openAddModal() {
    document.getElementById('modalTitle').textContent = '添加分类';
    document.getElementById('formAction').value = 'add';
    document.getElementById('typeForm').reset();
    document.getElementById('bTid').value = '';
    document.getElementById('bTPerentId').value = '';
    document.getElementById('typeModal').classList.add('active');
}

// 打开编辑弹窗（使用双引号包裹，避免单引号冲突）
function editType(id, name, text, parentId) {
    document.getElementById('modalTitle').textContent = '编辑分类';
    document.getElementById('formAction').value = 'update';
    document.getElementById('bTid').value = id;
    document.getElementById('bTypeName').value = name;
    document.getElementById('btText').value = text || '';
    document.getElementById('bTPerentId').value = parentId || '';
    document.getElementById('typeModal').classList.add('active');
}

// 关闭弹窗
function closeModal() {
    document.getElementById('typeModal').classList.remove('active');
}

// 点击遮罩层关闭
document.getElementById('typeModal').addEventListener('click', function(e) {
    if (e.target === this) closeModal();
});

// ESC键关闭
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeModal();
});
</script>
<!-- ══════════ 主题初始化 ══════════ -->
<script>
(function() {
    var t = 'quantum-matrix';
    try {
        if (window.parent && window.parent !== window) {
            var pt = window.parent.document.documentElement.getAttribute('data-theme');
            if (pt) t = pt;
        }
    } catch (e) {}
    var s = localStorage.getItem('boya-theme');
    if (s) t = s;
    document.documentElement.setAttribute('data-theme', t);
    var l = document.createElement('link');
    l.rel = 'stylesheet';
    l.id = 'boya-light-css';
    l.href = '<%= request.getContextPath() %>/CSS/sub-pages-light.css';
    document.head.appendChild(l);
    window.addEventListener('message', function(e) {
        if (e.data && e.data.type === 'themeChange' && e.data.theme) {
            document.documentElement.setAttribute('data-theme', e.data.theme);
            localStorage.setItem('boya-theme', e.data.theme);
        }
    });
})();
</script>
</body>
</html>