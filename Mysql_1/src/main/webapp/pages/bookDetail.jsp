<%--
 =============================================================================
 bookDetail.jsp —— 全格式电子书阅读器 v4.0
 =============================================================================
 技术栈：JSP + CDN库（epub.js / mammoth.js / marked.js）+ 原生 fetch
 支持：TXT / EPUB / PDF / DOCX / MD
 v4.0：全新UI设计、分页模式、全文搜索、阅读统计、快捷键面板
 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<%@ page import="com.ebookBuy301.pojo.Book" %>
<%!
    private String escapeHtml(String str) {
        if (str == null) return "";
        return str.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                  .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    Book book = (Book) request.getAttribute("book");
    if (book == null) { response.sendRedirect(request.getContextPath() + "/majorsPage"); return; }
    String ctx = request.getContextPath();

    String title = escapeHtml(book.getBookTitle() != null ? book.getBookTitle() : "");
    String author = escapeHtml(book.getBookAuthor() != null ? book.getBookAuthor() : "");
    String summary = escapeHtml(book.getBookSummary() != null ? book.getBookSummary() : "");
    String format = escapeHtml(book.getBookFormat() != null ? book.getBookFormat() : "");
    String typeName = escapeHtml(book.getTypeName() != null ? book.getTypeName() : "");
    long downloads = book.getDownloadTimes();
    String cover = book.getBookCover();
    String coverSrc;
    if (cover != null && !cover.trim().isEmpty()) {
        coverSrc = cover.startsWith("http") ? cover : ctx + cover;
    } else {
        coverSrc = "data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%22200%22 height=%22300%22><rect fill=%22%23101a30%22 width=%22100%25%22 height=%22100%25%22 rx=%228%22/><text x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 fill=%22%23333%22 font-size=%2236%22>📖</text></svg>";
    }
    java.sql.Date pubYear = book.getBookPubYear();
    String yearStr = pubYear != null ? escapeHtml(pubYear.toString().substring(0, 4)) : "";
    String rawFormat = book.getBookFormat();
    String fmtUpper = rawFormat != null ? rawFormat.trim().toUpperCase() : "";
    String fmtForJs = escapeHtml(fmtUpper);
    // TXT/EPUB/DOCX/MD 通过 DownloadServlet 获取
    String fileUrl = ctx + "/download?bookId=" + book.getId() + "&mode=view";
    // PDF 直接静态 URL（避免 Chrome 拦截 iframe 中的 servlet 响应）
    String pdfUrl = "";
    String bfStr = book.getBookFile();
    if (bfStr != null && !bfStr.trim().isEmpty()) {
        String[] arr = bfStr.split(",");
        for (String s : arr) {
            if (s != null && !s.trim().isEmpty()) { pdfUrl = ctx + s.trim(); break; }
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= title %> · 博雅书院</title>
    <link rel="stylesheet" href="<%= ctx %>/CSS/bookDetail.css?v=4.0">

    <!-- ========== 浅色主题 · 详情页+阅读器全覆盖 ========== -->
    <style>
        /* ═══════════ v4.0 基础样式 ═══════════ */
        .resume-banner{display:flex;align-items:center;justify-content:space-between;padding:10px 14px;margin-top:10px;background:linear-gradient(135deg,rgba(0,242,255,.06),rgba(124,58,237,.04));border:1px solid rgba(0,242,255,.1);border-radius:10px;gap:8px}
        .resume-info{display:flex;align-items:center;gap:6px;flex:1;min-width:0}
        .resume-icon{font-size:1rem}
        .resume-text{font-size:.8rem;color:rgba(0,242,255,.5);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
        .resume-btn{padding:6px 14px;border:none;border-radius:8px;background:linear-gradient(135deg,rgba(0,242,255,.15),rgba(124,58,237,.1));color:#00f2ff;font-size:.78rem;cursor:pointer;white-space:nowrap;transition:all .2s}
        .resume-btn:hover{background:linear-gradient(135deg,rgba(0,242,255,.25),rgba(124,58,237,.18));transform:scale(1.03)}
        /* ── 基础底色 ── */
        html[data-theme$="-light"] body{background:linear-gradient(170deg,#e9e2d2,#ede5d3 40%,#e4dbca)!important;color:#3d3929!important}
        html[data-theme$="-light"] ::selection{background:rgba(37,99,235,.15)!important;color:#3d3929!important}
        /* ── 导航 ── */
        html[data-theme$="-light"] .detail-nav{border-bottom-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .nav-btn{color:rgba(61,57,41,.35)!important}
        html[data-theme$="-light"] .nav-btn:hover{color:rgba(61,57,41,.6)!important;background:rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] .nav-title{color:rgba(61,57,41,.3)!important}
        /* ── 封面 ── */
        html[data-theme$="-light"] .cover-frame{border-color:rgba(139,119,80,.08)!important;box-shadow:0 10px 40px rgba(139,119,80,.15)!important;background:rgba(139,119,80,.05)!important}
        html[data-theme$="-light"] .cover-glow{background:linear-gradient(180deg,transparent 50%,rgba(139,119,80,.2) 100%)!important}
        /* ── 操作按钮 ── */
        html[data-theme$="-light"] .action-primary{background:linear-gradient(135deg,rgba(37,99,235,.12),rgba(124,58,237,.08))!important;border-color:rgba(37,99,235,.2)!important;color:#2563eb!important}
        html[data-theme$="-light"] .action-primary:hover{background:linear-gradient(135deg,rgba(37,99,235,.2),rgba(124,58,237,.14))!important;box-shadow:0 6px 20px rgba(37,99,235,.08)!important}
        html[data-theme$="-light"] .action-secondary{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.06)!important;color:#7a7360!important}
        html[data-theme$="-light"] .action-secondary:hover{background:rgba(139,119,80,.08)!important;border-color:rgba(139,119,80,.12)!important;color:#5c5540!important}
        html[data-theme$="-light"] .action-secondary.bookmarked{background:rgba(37,99,235,.08)!important;border-color:rgba(37,99,235,.15)!important;color:#2563eb!important}
        /* ── 统计卡片 ── */
        html[data-theme$="-light"] .stats-card{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .stat-num{color:#3d3929!important}
        html[data-theme$="-light"] .stat-label{color:rgba(61,57,41,.3)!important}
        html[data-theme$="-light"] .stat-divider{background:rgba(139,119,80,.06)!important}
        /* ── 书籍信息 ── */
        html[data-theme$="-light"] .book-title-main{color:#3d3929!important}
        html[data-theme$="-light"] .book-author-main{color:rgba(61,57,41,.35)!important}
        html[data-theme$="-light"] .mbadge{background:rgba(37,99,235,.05)!important;border-color:rgba(37,99,235,.08)!important;color:rgba(37,99,235,.45)!important}
        /* ── 评分 ── */
        html[data-theme$="-light"] .rating-section{background:rgba(139,119,80,.03)!important;border-color:rgba(139,119,80,.05)!important}
        html[data-theme$="-light"] .star{color:rgba(139,119,80,.1)!important}
        html[data-theme$="-light"] .rating-note{color:rgba(61,57,41,.3)!important}
        /* ── 信息区块 ── */
        html[data-theme$="-light"] .sec-title{color:rgba(61,57,41,.25)!important;border-bottom-color:rgba(139,119,80,.05)!important}
        html[data-theme$="-light"] .sec-text{color:rgba(61,57,41,.5)!important}
        /* ── 目录 ── */
        html[data-theme$="-light"] .toc-item{background:rgba(139,119,80,.02)!important}
        html[data-theme$="-light"] .toc-item:hover{background:rgba(37,99,235,.04)!important}
        html[data-theme$="-light"] .toc-num{color:rgba(37,99,235,.25)!important}
        html[data-theme$="-light"] .toc-name{color:#5c5540!important}
        html[data-theme$="-light"] .toc-page{color:rgba(61,57,41,.15)!important}
        /* ── 标签 ── */
        html[data-theme$="-light"] .tag-pill{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.06)!important;color:rgba(61,57,41,.25)!important}
        /* ══════════ 沉浸阅读器 ══════════ */
        html[data-theme$="-light"] .reader{background:#e8dfcf!important}
        html[data-theme$="-light"] .reader-topbar{background:rgba(238,233,222,.92)!important;border-bottom-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .reader-book-title{color:rgba(61,57,41,.35)!important}
        html[data-theme$="-light"] .reader-content{color:rgba(61,57,41,.75)!important}
        html[data-theme$="-light"] .reader-chapter-label{color:rgba(37,99,235,.25)!important}
        html[data-theme$="-light"] .reader-chapter-title{color:#3d3929!important}
        html[data-theme$="-light"] .reader-sep{color:rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .reader-paragraph:hover{background:rgba(37,99,235,.03)!important}
        html[data-theme$="-light"] .reader-paragraph.reader-highlight{background:rgba(37,99,235,.08)!important}
        html[data-theme$="-light"] .reader-end{color:rgba(61,57,41,.15)!important}
        /* ── 阅读器按钮/控件 ── */
        html[data-theme$="-light"] .rbtn{color:rgba(61,57,41,.35)!important}
        html[data-theme$="-light"] .rbtn:hover{background:rgba(139,119,80,.08)!important;color:rgba(61,57,41,.55)!important}
        html[data-theme$="-light"] .rbtn-active{color:#2563eb!important}
        html[data-theme$="-light"] .reader-timer{color:rgba(61,57,41,.2)!important}
        /* ── 搜索栏浅色 ── */
        html[data-theme$="-light"] .reader-search-panel{background:rgba(240,235,220,.96)!important;border-bottom-color:rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .reader-search-input{border-color:rgba(139,119,80,.1)!important;color:#5a4a3a!important;background:rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] .reader-search-count{color:rgba(61,57,41,.25)!important}
        /* ── 抽屉浅色 ── */
        html[data-theme$="-light"] .reader-drawer{background:rgba(248,242,228,.97)!important;border-left-color:rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .reader-drawer-header{color:rgba(61,57,41,.5)!important;border-bottom-color:rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .reader-drawer-section-title{color:rgba(61,57,41,.3)!important}
        /* ── 浮动控制条浅色 ── */
        html[data-theme$="-light"] .reader-floating-ctrl{background:rgba(240,235,222,.85)!important;border-color:rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .fctrl-btn{color:rgba(61,57,41,.3)!important}
        html[data-theme$="-light"] .fctrl-btn:hover{background:rgba(139,119,80,.06)!important;color:rgba(61,57,41,.5)!important}
        html[data-theme$="-light"] .fctrl-progress{color:rgba(61,57,41,.2)!important}
        /* ── 通用 ── */
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3,html[data-theme$="-light"] h4{color:#3d3929!important}
        html[data-theme$="-light"] svg{color:#7a7360!important}
        /* ── 继续阅读横幅 ── */
        html[data-theme$="-light"] .resume-banner{background:linear-gradient(135deg,rgba(37,99,235,.06),rgba(124,58,237,.04))!important;border-color:rgba(37,99,235,.12)!important}
        html[data-theme$="-light"] .resume-text{color:rgba(37,99,235,.45)!important}
        html[data-theme$="-light"] .resume-btn{background:linear-gradient(135deg,rgba(37,99,235,.12),rgba(124,58,237,.08))!important;color:#2563eb!important}
        html[data-theme$="-light"] .resume-btn:hover{background:linear-gradient(135deg,rgba(37,99,235,.2),rgba(124,58,237,.14))!important}
    </style>
    <!-- CDN 阅读引擎 -->
    <script src="https://cdn.jsdelivr.net/npm/epubjs@0.3.93/dist/epub.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mammoth@1.6.0/mammoth.browser.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/marked@4.3.0/marked.min.js"></script>
    <!-- PDF.js - 纯 JS 渲染 PDF，避免 Chrome 拦截 -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"></script>
</head>
<body>
<div class="page">
    <!-- ===== 顶部导航 ===== -->
    <nav class="detail-nav">
        <a href="javascript:history.back()" class="nav-btn" title="返回">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5"/><polyline points="12 19 5 12 12 5"/></svg>
            <span class="nb-text">返回</span>
        </a>
        <span class="nav-title"><%= title %></span>
        <a href="<%= ctx %>/majorMatrix" class="nav-btn" title="学域矩阵">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
        </a>
    </nav>

    <!-- ===== 主体 ===== -->
    <main class="detail-main">
        <div class="detail-left">
            <div class="cover-frame">
                <div class="cover-glow"></div>
                <img class="cover-img" src="<%= coverSrc %>" alt="<%= title %>"
                     onerror="this.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%22200%22 height=%22300%22><rect fill=%22%23101a30%22 width=%22100%25%22 height=%22100%25%22 rx=%228%22/><text x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 fill=%22%23333%22 font-size=%2236%22>📖</text></svg>'">
            </div>
            <div class="action-group">
                <button class="action-btn action-primary" id="startReadBtn">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/><line x1="12" y1="6" x2="12" y2="12"/><line x1="9" y1="9" x2="15" y2="9"/></svg>
                    <span>开始阅读</span>
                </button>
                <button class="action-btn action-secondary" onclick="toggleBookmark(this)">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
                    收藏
                </button>
                <button class="action-btn action-secondary" onclick="shareBook()">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/></svg>
                    分享
                </button>
                <button class="action-btn action-secondary" onclick="downloadBook()" id="downloadBtn">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                    下载
                </button>
            </div>
            <!-- 继续阅读提示 -->
            <div class="resume-banner" id="resumeBanner" style="display:none">
                <div class="resume-info">
                    <span class="resume-icon">📖</span>
                    <span class="resume-text">上次读到 <span id="resumeChapter">—</span> · 进度 <span id="resumePct">0</span>%</span>
                </div>
                <button class="resume-btn" id="resumeReadBtn">继续阅读</button>
            </div>
            <div class="stats-card">
                <div class="stat-item">
                    <span class="stat-num"><%= format.isEmpty() ? "—" : format %></span>
                    <span class="stat-label">格式</span>
                </div>
                <div class="stat-divider"></div>
                <div class="stat-item">
                    <span class="stat-num"><%= downloads %></span>
                    <span class="stat-label">下载</span>
                </div>
                <div class="stat-divider"></div>
                <div class="stat-item">
                    <span class="stat-num"><%= yearStr.isEmpty() ? "—" : yearStr %></span>
                    <span class="stat-label">年份</span>
                </div>
            </div>
        </div>
        <div class="detail-right">
            <h1 class="book-title-main"><%= title %></h1>
            <p class="book-author-main"><%= author %></p>
            <div class="meta-badges">
                <span class="mbadge"><%= typeName %></span>
                <span class="mbadge"><%= format.isEmpty() ? "未知" : format %></span>
                <% if (!yearStr.isEmpty()) { %><span class="mbadge"><%= yearStr %></span><% } %>
                <span class="mbadge">⬇ <%= downloads %></span>
            </div>
            <div class="rating-section">
                <div class="stars" id="starDisplay">
                    <span class="star" data-v="1">☆</span><span class="star" data-v="2">☆</span><span class="star" data-v="3">☆</span><span class="star" data-v="4">☆</span><span class="star" data-v="5">☆</span>
                </div>
                <span class="rating-note">评分 <span id="ratingValue">—</span> · <span id="ratingCount">0</span> 人评价</span>
            </div>
            <div class="info-section">
                <h3 class="sec-title">📖 内容简介</h3>
                <p class="sec-text"><%= summary.isEmpty() ? "暂无简介" : summary %></p>
            </div>
            <div class="info-section">
                <h3 class="sec-title">📑 目录</h3>
                <div class="toc" id="tocList">
                    <div class="toc-item" style="color:rgba(255,255,255,0.4);justify-content:center">加载中...</div>
                </div>
            </div>
            <div class="tag-section">
                <span class="tag-pill">#<%= typeName %></span>
                <span class="tag-pill">#阅读</span>
                <span class="tag-pill">#<%= author %></span>
            </div>
        </div>
    </main>
</div>

<!-- ===== 沉浸阅读器 v4.0 · 现代极简 ===== -->
<div class="reader" id="reader">
    <!-- 顶部极细进度线 -->
    <div class="reader-top-progress" id="readerTopProgress"></div>
    <!-- 精简顶栏 -->
    <div class="reader-topbar" id="readerTopbar">
        <button class="rbtn" onclick="closeReader()" title="关闭 (ESC)">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/><line x1="19" y1="5" x2="5" y2="19"/></svg>
        </button>
        <span class="reader-book-title"><%= title %></span>
        <span class="reader-timer" id="readerTimer" title="本次阅读时长" style="font-family:'JetBrains Mono',monospace;font-size:0.7rem;color:rgba(255,255,255,0.2);min-width:44px;text-align:center">00:00</span>
        <button class="rbtn" id="bookmarkBtn" onclick="toggleReaderBookmark()" title="书签 (B)">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
        </button>
        <button class="rbtn" id="searchToggleBtn" onclick="toggleSearch()" title="搜索 (Ctrl+F)">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        </button>
        <button class="rbtn" id="tocToggleBtn" onclick="toggleTocDrawer()" title="目录 (T)">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
        </button>
        <button class="rbtn" id="settingsToggleBtn" onclick="toggleSettingsDrawer()" title="设置 (S)">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
        </button>
    </div>

    <!-- 搜索面板 -->
    <div class="reader-search-panel" id="readerSearchPanel">
        <button class="rbtn rbtn-sm" onclick="searchPrev()" title="上一个匹配 (Shift+Enter)">▲</button>
        <input class="reader-search-input" id="readerSearchInput" placeholder="搜索书中内容..." oninput="doSearch(this.value)" onkeydown="searchKeyHandler(event)">
        <span class="reader-search-count" id="readerSearchCount">—</span>
        <button class="rbtn rbtn-sm" onclick="searchNext()" title="下一个匹配 (Enter)">▼</button>
        <button class="rbtn rbtn-sm" onclick="toggleSearch()" title="关闭 (Esc)">✕</button>
    </div>

    <!-- 目录抽屉 -->
    <div class="reader-drawer" id="tocDrawer">
        <div class="reader-drawer-header">
            <span>📑 目录</span>
            <button class="rbtn rbtn-sm" onclick="toggleTocDrawer()">✕</button>
        </div>
        <div class="reader-drawer-body" id="tocDrawerBody">
            <div class="toc-item" style="color:rgba(255,255,255,0.3);padding:20px;text-align:center">加载中...</div>
        </div>
    </div>

    <!-- 设置抽屉 -->
    <div class="reader-drawer" id="settingsDrawer">
        <div class="reader-drawer-header">
            <span>⚙ 阅读设置</span>
            <button class="rbtn rbtn-sm" onclick="toggleSettingsDrawer()">✕</button>
        </div>
        <div class="reader-drawer-body">
            <div class="reader-drawer-section">
                <div class="reader-drawer-section-title">阅读模式</div>
                <div class="reader-mode-switch">
                    <button class="reader-mode-option active" data-mode="scroll" onclick="setReadMode('scroll')">📜 滚动</button>
                    <button class="reader-mode-option" data-mode="paged" onclick="setReadMode('paged')">📖 分页</button>
                </div>
            </div>
            <div class="reader-drawer-section">
                <div class="reader-drawer-section-title">阅读主题</div>
                <div class="reader-theme-grid">
                    <div class="reader-theme-card active" data-theme="dark" onclick="setReaderTheme('dark')"><div class="reader-theme-dot" style="background:#1a1a2e"></div><span class="reader-theme-label">深色</span></div>
                    <div class="reader-theme-card" data-theme="paper" onclick="setReaderTheme('paper')"><div class="reader-theme-dot" style="background:#e8dcc8"></div><span class="reader-theme-label">纸书</span></div>
                    <div class="reader-theme-card" data-theme="sepia" onclick="setReaderTheme('sepia')"><div class="reader-theme-dot" style="background:#3d2a1a"></div><span class="reader-theme-label">护眼</span></div>
                    <div class="reader-theme-card" data-theme="green" onclick="setReaderTheme('green')"><div class="reader-theme-dot" style="background:#1a3a2a"></div><span class="reader-theme-label">绿茵</span></div>
                    <div class="reader-theme-card" data-theme="oled" onclick="setReaderTheme('oled')"><div class="reader-theme-dot" style="background:#000"></div><span class="reader-theme-label">OLED</span></div>
                    <div class="reader-theme-card" data-theme="warm" onclick="setReaderTheme('warm')"><div class="reader-theme-dot" style="background:#2a1f10"></div><span class="reader-theme-label">暖光</span></div>
                </div>
            </div>
            <div class="reader-drawer-section">
                <div class="reader-drawer-section-title">字号</div>
                <div class="reader-slider-group">
                    <label>A−</label>
                    <input type="range" id="fontSizeSlider" min="12" max="28" value="16" step="1" oninput="adjustFontTo(parseInt(this.value))">
                    <label>A+</label>
                    <span class="reader-slider-val" id="fontSizeVal">16</span>
                </div>
            </div>
            <div class="reader-drawer-section">
                <div class="reader-drawer-section-title">行距</div>
                <div class="reader-slider-group">
                    <label>窄</label>
                    <input type="range" id="lineHeightSlider" min="14" max="28" value="18" step="1" oninput="adjustLineHeightTo(parseInt(this.value)/10)">
                    <label>宽</label>
                    <span class="reader-slider-val" id="lineHeightVal">1.8</span>
                </div>
            </div>
            <div class="reader-drawer-section">
                <div class="reader-drawer-section-title">字体</div>
                <select class="reader-font-select" id="readerFontSelect" onchange="setFont(this.value)">
                    <option value="'Inter','Segoe UI','Noto Sans SC',sans-serif">系统默认</option>
                    <option value="'Noto Serif SC','Georgia','STSong',serif">宋体</option>
                    <option value="'Source Han Serif SC','SimSun',serif">仿宋</option>
                    <option value="'LXGW WenKai','KaiTi','STKaiti',cursive">楷体</option>
                    <option value="'JetBrains Mono','Cascadia Code',monospace">等宽</option>
                </select>
            </div>
            <div class="reader-drawer-section">
                <div class="reader-drawer-section-title">快捷操作</div>
                <div style="display:flex;flex-direction:column;gap:6px">
                    <button class="rbtn" style="width:100%;justify-content:center;padding:8px" onclick="toggleFullscreen();toggleSettingsDrawer()">🖥 全屏阅读</button>
                    <button class="rbtn" style="width:100%;justify-content:center;padding:8px" onclick="toggleShortcuts();toggleSettingsDrawer()">⌨ 快捷键帮助</button>
                </div>
            </div>
        </div>
    </div>

    <!-- 阅读内容区 -->
    <div class="reader-body" id="readerBody">
        <div class="reader-content" id="readerContent">
            <p style="color:rgba(255,255,255,0.3);text-align:center;padding:40px 0;">正在加载内容...</p>
        </div>
    </div>

    <!-- 浮动迷你控制条 -->
    <div class="reader-floating-ctrl fctrl-hidden" id="readerFloatingCtrl">
        <button class="fctrl-btn" onclick="readerPrev()" title="上一页 (←)">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
        </button>
        <span class="fctrl-progress" id="fctrlProgress">0%</span>
        <span class="reader-stats-bar">
            <span id="fctrlWords">— 字</span>
            <span>·</span>
            <span id="fctrlTime">—</span>
        </span>
        <button class="fctrl-btn fctrl-primary" onclick="readerNext()" title="下一页 (→)">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
        </button>
    </div>

    <!-- 快捷键面板 -->
    <div class="reader-shortcuts-overlay" id="shortcutsOverlay" onclick="toggleShortcuts()">
        <div class="reader-shortcuts-panel" onclick="event.stopPropagation()">
            <h3>⌨ 键盘快捷键</h3>
            <div class="reader-shortcuts-grid">
                <span class="shortcut-key">←/→</span><span class="shortcut-desc">上一页 / 下一页</span>
                <span class="shortcut-key">Ctrl+F</span><span class="shortcut-desc">搜索</span>
                <span class="shortcut-key">Enter</span><span class="shortcut-desc">下一个匹配</span>
                <span class="shortcut-key">Shift+Enter</span><span class="shortcut-desc">上一个匹配</span>
                <span class="shortcut-key">T</span><span class="shortcut-desc">打开目录</span>
                <span class="shortcut-key">S</span><span class="shortcut-desc">打开设置</span>
                <span class="shortcut-key">B</span><span class="shortcut-desc">添加书签</span>
                <span class="shortcut-key">F</span><span class="shortcut-desc">全屏</span>
                <span class="shortcut-key">ESC</span><span class="shortcut-desc">关闭面板 / 退出阅读</span>
                <span class="shortcut-key">?</span><span class="shortcut-desc">显示此帮助</span>
            </div>
        </div>
    </div>
</div>

<script>
// ═══════════════════════════════════════════════════════════
// v4.0 全局变量
// ═══════════════════════════════════════════════════════════
var BOOK_ID = parseInt('<%= book.getId() %>', 10);
var cp = '<%= ctx %>';
var FILE_URL = '<%= fileUrl %>';
var PDF_URL = '<%= pdfUrl %>';
var FMT = '<%= fmtForJs %>';
var epbRendition = null;
var epbBook = null;
var tocData = [];
var _pdfBlobUrl = null;
var currentFontSize = 16;
var currentLineHeight = 1.8;
var currentTheme = 'dark';
var currentReadMode = 'scroll';
var currentChapterIdx = 0;
var readingTimerSec = 0;
var timerInterval = null;
var _progressSaveTimer = null;
var searchMatches = [];
var currentMatchIdx = -1;
var _searchDebounce = null;
var totalWordCount = 0;
var _fctrlHideTimer = null;
var _rpgSheet = null;

// ═══════════════════════════════════════════════════════════
// 工具函数
// ═══════════════════════════════════════════════════════════
function showToast(msg, duration) {
    duration = duration || 2500;
    var existing = document.querySelector('.toast-notice');
    if (existing) existing.remove();
    var t = document.createElement('div');
    t.className = 'toast-notice';
    t.textContent = msg;
    Object.assign(t.style, {
        position:'fixed', bottom:'100px', left:'50%', transform:'translateX(-50%)',
        background:'rgba(12,16,28,0.92)', color:'rgba(255,255,255,0.7)',
        padding:'8px 20px', borderRadius:'10px', fontSize:'0.78rem',
        border:'1px solid rgba(255,255,255,0.06)',
        zIndex:'100', transition:'opacity 0.3s', pointerEvents:'none'
    });
    document.body.appendChild(t);
    setTimeout(function(){ t.style.opacity='0'; setTimeout(function(){t.remove();},300); }, duration);
}
function escHtml(str) {
    if (str == null) return '';
    return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
}
function lskey(suffix) { return 'boya_reader_' + BOOK_ID + '_' + suffix; }

// ═══════════════════════════════════════════════════════════
// 分享 / 下载
// ═══════════════════════════════════════════════════════════
function shareBook() {
    var url = window.location.href;
    if (navigator.share) { navigator.share({ title: document.title, url: url }).catch(function(){}); }
    else if (navigator.clipboard) { navigator.clipboard.writeText(url).then(function(){showToast('链接已复制');}).catch(function(){showToast('链接已复制');}); }
    else { showToast('链接已复制'); }
}
var _dlIframe = null;
function downloadBook() {
    if (!_dlIframe) {
        _dlIframe = document.createElement('iframe');
        _dlIframe.style.cssText = 'position:fixed;top:-9999px;left:-9999px;width:0;height:0;border:none;visibility:hidden;';
        _dlIframe.setAttribute('aria-hidden', 'true');
        document.body.appendChild(_dlIframe);
    }
    _dlIframe.src = cp + '/download?bookId=' + BOOK_ID + '&_t=' + Date.now();
}

// ═══════════════════════════════════════════════════════════
// 评分
// ═══════════════════════════════════════════════════════════
(function() {
    var stars = document.querySelectorAll('.star'), currentRating = 0;
    fetch(cp + '/api/bookAction?action=ratingInfo&bookId=' + BOOK_ID)
        .then(function(r){return r.json();})
        .then(function(data){
            if(data.avgRating !== undefined) { currentRating = data.avgRating; document.getElementById('ratingValue').textContent = data.avgRating; }
            if(data.ratingCount !== undefined) document.getElementById('ratingCount').textContent = data.ratingCount;
            if(data.userRating) updateStars(data.userRating);
        }).catch(function(){});
    stars.forEach(function(s){
        s.addEventListener('click', function(){
            var v = parseInt(s.getAttribute('data-v')); updateStars(v);
            fetch(cp + '/api/bookAction', {method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=rate&bookId='+BOOK_ID+'&rating='+v})
                .then(function(r){return r.json();}).then(function(d){
                    if(d.success){ currentRating=d.avgRating||v; document.getElementById('ratingValue').textContent=currentRating; if(d.ratingCount) document.getElementById('ratingCount').textContent=d.ratingCount; }
                }).catch(function(){});
        });
        s.addEventListener('mouseenter', function(){ updateStars(parseInt(s.getAttribute('data-v'))); });
        s.addEventListener('mouseleave', function(){ updateStars(Math.round(currentRating)); });
    });
    function updateStars(v){ stars.forEach(function(st, idx){ st.textContent = idx < v ? '★' : '☆'; }); }
})();

// ═══════════════════════════════════════════════════════════
// 收藏
// ═══════════════════════════════════════════════════════════
var bookmarkLoaded = false;
function toggleBookmark(btn) {
    fetch(cp + '/api/bookAction', {method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=toggleBookmark&bookId='+BOOK_ID})
        .then(function(r){return r.json();}).then(function(data){
            if(data.success){
                btn.innerHTML = data.bookmarked ?
                    '<svg width="15" height="15" viewBox="0 0 24 24" fill="#7dd3fc" stroke="#7dd3fc" stroke-width="2"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg> 已收藏' :
                    '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg> 收藏';
                syncReaderBookmarkIcon(data.bookmarked);
            }
        }).catch(function(){});
}
(function(){
    fetch(cp + '/api/bookAction?action=bookmarkStatus&bookId=' + BOOK_ID)
        .then(function(r){ return r.json(); })
        .then(function(data){
            if(data.success && data.bookmarked) {
                var btn = document.querySelector('.action-btn[onclick="toggleBookmark(this)"]');
                if(btn) {
                    btn.innerHTML = '<svg width="15" height="15" viewBox="0 0 24 24" fill="#7dd3fc" stroke="#7dd3fc" stroke-width="2"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg> 已收藏';
                    btn.classList.add('bookmarked');
                }
                syncReaderBookmarkIcon(true);
            }
            bookmarkLoaded = true;
        }).catch(function(){});
})();
function syncReaderBookmarkIcon(isMarked) {
    var rBtn = document.getElementById('bookmarkBtn');
    if (!rBtn) return;
    if (isMarked) rBtn.classList.add('rbtn-active');
    else rBtn.classList.remove('rbtn-active');
}

// ═══════════════════════════════════════════════════════════
// 阅读器核心：打开/关闭
// ═══════════════════════════════════════════════════════════
document.getElementById('startReadBtn').addEventListener('click', function() {
    openReader();
    if (FMT === 'EPUB') loadEpub();
    else if (FMT === 'DOCX' || FMT === 'DOC') loadDocx();
    else if (FMT === 'MD' || FMT === 'MARKDOWN') { currentReadMode = 'scroll'; loadMarkdown(); }
    else if (FMT === 'PDF') loadPdfIframe();
    else loadTxt();
});

function openReader() {
    document.querySelector('.page').style.display = 'none';
    document.getElementById('reader').classList.add('active');
    document.getElementById('readerContent').innerHTML = '<p style="color:rgba(255,255,255,0.3);text-align:center;padding:40px 0;">⏳ 正在加载...</p>';
    startTimer();
    loadReaderSettings();
    updateFloatCtrlVisibility();
    setTimeout(function() { if (tocData.length > 0) renderTocDrawer(); }, 1200);
}
function closeReader() {
    clearSearch();
    if (epbRendition) { try{ epbRendition.destroy(); }catch(e){} epbRendition = null; }
    if (epbBook) { try{ epbBook.destroy(); }catch(e){} epbBook = null; }
    if (_pdfBlobUrl) { try{ URL.revokeObjectURL(_pdfBlobUrl); }catch(e){} _pdfBlobUrl = null; }
    saveReadingProgress(); saveReaderSettings(); stopTimer();
    closeAllPanels();
    document.getElementById('reader').classList.remove('active');
    document.querySelector('.page').style.display = '';
    var rc = document.getElementById('readerContent');
    rc.innerHTML = '<p style="color:rgba(255,255,255,0.3);text-align:center;padding:40px 0;">正在加载内容...</p>';
    rc.style.maxWidth = ''; rc.classList.remove('paged-mode');
    currentReadMode = 'scroll';
    updateReadModeUI();
}

// ═══════════════════════════════════════════════════════════
// 面板管理
// ═══════════════════════════════════════════════════════════
function closeAllPanels() {
    document.getElementById('tocDrawer').classList.remove('open');
    document.getElementById('settingsDrawer').classList.remove('open');
    document.getElementById('readerSearchPanel').classList.remove('active');
    document.getElementById('shortcutsOverlay').classList.remove('active');
}
function toggleTocDrawer() {
    var d = document.getElementById('tocDrawer');
    var isOpen = !d.classList.contains('open');
    document.getElementById('settingsDrawer').classList.remove('open');
    if (isOpen) { d.classList.add('open'); if (tocData.length > 0) renderTocDrawer(); }
    else d.classList.remove('open');
}
function toggleSettingsDrawer() {
    var d = document.getElementById('settingsDrawer');
    var isOpen = !d.classList.contains('open');
    document.getElementById('tocDrawer').classList.remove('open');
    if (isOpen) d.classList.add('open'); else d.classList.remove('open');
}

// ═══════════════════════════════════════════════════════════
// 键盘快捷键
// ═══════════════════════════════════════════════════════════
document.addEventListener('keydown', function(e) {
    if (!document.getElementById('reader').classList.contains('active')) return;
    var tag = (e.target.tagName || '').toLowerCase();
    if (tag === 'input' || tag === 'textarea') {
        if (e.key === 'Escape' && document.getElementById('readerSearchPanel').classList.contains('active')) toggleSearch();
        return;
    }
    switch(e.key) {
        case 'Escape': closeReader(); break;
        case 'ArrowLeft': e.preventDefault(); readerPrev(); break;
        case 'ArrowRight': e.preventDefault(); readerNext(); break;
        case 't': case 'T': e.preventDefault(); toggleTocDrawer(); break;
        case 's': case 'S': e.preventDefault(); toggleSettingsDrawer(); break;
        case 'b': case 'B': e.preventDefault(); toggleReaderBookmark(); break;
        case 'f': case 'F':
            if (!e.ctrlKey && !e.metaKey) { e.preventDefault(); toggleFullscreen(); }
            break;
        case '?': e.preventDefault(); toggleShortcuts(); break;
    }
    if (e.ctrlKey && e.key === 'f') { e.preventDefault(); toggleSearch(); }
});
function toggleShortcuts() {
    document.getElementById('shortcutsOverlay').classList.toggle('active');
}

// ═══════════════════════════════════════════════════════════
// 搜索功能
// ═══════════════════════════════════════════════════════════
function toggleSearch() {
    var panel = document.getElementById('readerSearchPanel');
    var input = document.getElementById('readerSearchInput');
    if (panel.classList.contains('active')) {
        panel.classList.remove('active');
        clearSearch();
        input.value = '';
    } else {
        panel.classList.add('active');
        input.focus(); input.select();
    }
}
function doSearch(query) {
    if (_searchDebounce) clearTimeout(_searchDebounce);
    _searchDebounce = setTimeout(function() { _doSearch(query); }, 200);
}
function _doSearch(query) {
    clearSearch();
    if (!query || query.trim().length < 1) { document.getElementById('readerSearchCount').textContent = '—'; return; }
    var body = document.getElementById('readerContent');
    if (epbRendition && body.querySelector('iframe')) {
        try {
            var iframe = body.querySelector('iframe');
            var iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
            searchInContainer(iframeDoc.body, query);
        } catch(e) { document.getElementById('readerSearchCount').textContent = 'N/A'; }
    } else {
        searchInContainer(body, query);
    }
    updateSearchCount();
    if (searchMatches.length > 0) { currentMatchIdx = 0; scrollToMatch(0); }
}
function searchInContainer(container, query) {
    searchMatches = [];
    if (!container) return;
    var walker = document.createTreeWalker(container, NodeFilter.SHOW_TEXT, null, false);
    var re = new RegExp(escRegex(query), 'gi');
    var textNodes = [];
    while (walker.nextNode()) {
        var node = walker.currentNode;
        if (node.parentElement && node.parentElement.closest('.reader-search-panel,script,style')) continue;
        textNodes.push(node);
    }
    textNodes.forEach(function(node) {
        var text = node.textContent;
        var match; re.lastIndex = 0;
        var matches = []; while ((match = re.exec(text)) !== null) matches.push({idx:match.index, len:match[0].length});
        if (matches.length === 0) return;
        var parent = node.parentElement;
        var frag = document.createDocumentFragment();
        var lastIdx = 0;
        matches.forEach(function(m) {
            if (m.idx > lastIdx) frag.appendChild(document.createTextNode(text.substring(lastIdx, m.idx)));
            var mark = document.createElement('mark');
            mark.className = 'search-highlight';
            mark.textContent = text.substring(m.idx, m.idx + m.len);
            frag.appendChild(mark);
            searchMatches.push(mark);
            lastIdx = m.idx + m.len;
        });
        if (lastIdx < text.length) frag.appendChild(document.createTextNode(text.substring(lastIdx)));
        parent.replaceChild(frag, node);
    });
}
function escRegex(s) { return s.replace(/[.*+?^${()}|[\]\\]/g, '\\$&'); }
function clearSearch() {
    document.querySelectorAll('mark.search-highlight').forEach(function(m) {
        var parent = m.parentElement;
        if (parent) { parent.replaceChild(document.createTextNode(m.textContent), m); parent.normalize(); }
    });
    searchMatches = []; currentMatchIdx = -1;
    updateSearchCount();
}
function searchNext() {
    if (searchMatches.length === 0) return;
    currentMatchIdx = (currentMatchIdx + 1) % searchMatches.length;
    scrollToMatch(currentMatchIdx);
}
function searchPrev() {
    if (searchMatches.length === 0) return;
    currentMatchIdx = (currentMatchIdx - 1 + searchMatches.length) % searchMatches.length;
    scrollToMatch(currentMatchIdx);
}
function scrollToMatch(idx) {
    if (idx < 0 || idx >= searchMatches.length) return;
    searchMatches.forEach(function(m) { m.classList.remove('active-match'); });
    var mark = searchMatches[idx];
    mark.classList.add('active-match');
    mark.scrollIntoView({ behavior: 'smooth', block: 'center' });
    updateSearchCount();
}
function updateSearchCount() {
    var el = document.getElementById('readerSearchCount');
    if (searchMatches.length === 0) el.textContent = '0/0';
    else el.textContent = (currentMatchIdx + 1) + '/' + searchMatches.length;
}
function searchKeyHandler(e) {
    if (e.key === 'Enter') { e.preventDefault(); if (e.shiftKey) searchPrev(); else searchNext(); }
    if (e.key === 'Escape') { e.preventDefault(); toggleSearch(); }
}

// ═══════════════════════════════════════════════════════════
// EPUB 引擎
// ═══════════════════════════════════════════════════════════
function loadEpub() {
    if (typeof ePub === 'undefined') { showToast('epub.js 未加载'); return; }
    var rc = document.getElementById('readerContent');
    rc.innerHTML = '<p style="color:rgba(255,255,255,0.3);text-align:center;padding:60px 0;">⏳ 解析 EPUB...</p>';
    epbBook = ePub(FILE_URL);
    epbRendition = epbBook.renderTo(rc, { width: '100%', height: '100%', flow: 'paginated', spread: 'none' });
    epbRendition.hooks.content.register(function(){});
    epbBook.ready.then(function(){ epbRendition.display(); }).catch(function(err){
        rc.innerHTML = '<p style="color:rgba(255,255,255,0.3);text-align:center;padding:60px 0;">EPUB 解析失败</p>';
    });
    epbBook.loaded.navigation.then(function(nav){
        if (nav.toc && nav.toc.length > 0) { tocData = formatEpubToc(nav.toc); renderTOC(); }
        else { document.getElementById('tocList').innerHTML = '<div style="color:rgba(255,255,255,0.3);text-align:center;padding:10px">无目录</div>'; }
    }).catch(function(){});
    epbRendition.on('relocated', function(loc){
        if (loc && loc.start) _updateProgLine(loc.start.percentage * 100);
    });
    document.getElementById('readerSearchPanel').classList.remove('active');
    document.getElementById('readerFloatingCtrl').classList.add('fctrl-hidden');
}
function formatEpubToc(toc) {
    var result = [], i = 0;
    if (!toc) return result;
    toc.forEach(function(item){
        result.push({ id: i++, title: item.label, href: item.href, subitems: item.subitems });
        if (item.subitems && item.subitems.length > 0) {
            formatEpubToc(item.subitems).forEach(function(s){ s.indent = true; result.push(s); });
        }
    });
    return result;
}

// ═══════════════════════════════════════════════════════════
// TXT 引擎（增强：字数统计）
// ═══════════════════════════════════════════════════════════
function loadTxt() {
    var rc = document.getElementById('readerContent');
    rc.innerHTML = '<p style="color:rgba(255,255,255,0.3);text-align:center;padding:60px 0;">⏳ 加载文本...</p>';
    fetch(FILE_URL)
        .then(function(r){ return r.text(); })
        .then(function(text){
            if (!text || !text.trim()) { rc.innerHTML = '<p style="color:rgba(255,255,255,0.3);text-align:center;padding:60px 0;">文件为空</p>'; return; }
            totalWordCount = countChineseChars(text);
            updateWordStats();
            var chRe = /(?:^|\n)(第[一二三四五六七八九十百零\d]+[章节篇部].*?)(?=\n|$)/gm;
            var matches = [], m;
            while ((m = chRe.exec(text)) !== null) { matches.push({ title: m[1].trim(), index: m.index }); }
            if (matches.length > 0) {
                tocData = []; var html = '';
                for (var i = 0; i < matches.length; i++) {
                    var start = matches[i].index;
                    var end = i + 1 < matches.length ? matches[i + 1].index : text.length;
                    var chunk = text.substring(start, end).trim();
                    tocData.push({ id: i, title: matches[i].title, index: start });
                    html += '<div class="chapter-section" data-ch="'+i+'" id="ch-'+i+'">';
                    html += '<div class="reader-chapter-label">'+escHtml(matches[i].title)+'</div>';
                    html += '<div class="reader-sep">✦ ✦ ✦</div>';
                    var paras = chunk.replace(matches[i].title, '').split('\n').filter(function(p){ return p.trim(); });
                    paras.forEach(function(p){ html += '<p class="reader-paragraph">'+escHtml(p.trim())+'</p>'; });
                    html += '</div><div class="reader-sep">— ✦ —</div>';
                }
                rc.innerHTML = html;
                renderTOC(); renderTocDrawer();
            } else {
                tocData = [];
                var paras = text.split('\n').filter(function(p){ return p.trim(); });
                var chunkSize = Math.max(20, Math.ceil(paras.length / 10));
                var html = '';
                for (var si = 0; si < paras.length; si += chunkSize) {
                    var chunkParas = paras.slice(si, si + chunkSize);
                    var secId = 'sec-' + tocData.length;
                    var secTitle = '第 ' + (tocData.length + 1) + ' 节';
                    tocData.push({ id: tocData.length, title: secTitle, index: si, anchor: secId });
                    html += '<div class="chapter-section" data-ch="'+(tocData.length-1)+'" id="'+secId+'">';
                    html += si === 0 ? '<div class="reader-chapter-label">全文开始</div>' : '<div class="reader-chapter-label">'+escHtml(secTitle)+'</div>';
                    html += '<div class="reader-sep">✦ ✦ ✦</div>';
                    chunkParas.forEach(function(p){ html += '<p class="reader-paragraph">'+escHtml(p.trim())+'</p>'; });
                    html += '</div><div class="reader-sep">— ✦ —</div>';
                }
                rc.innerHTML = html || '<p style="color:rgba(255,255,255,0.3);text-align:center;padding:60px 0;">无效内容</p>';
                renderTOC(); renderTocDrawer();
            }
            applyReadMode();
            document.getElementById('readerBody').scrollTop = 0;
        })
        .catch(function(){ rc.innerHTML = '<p style="color:rgba(255,255,255,0.3);text-align:center;padding:60px 0;">加载失败</p>'; });
}

// ═══════════════════════════════════════════════════════════
// PDF 引擎
// ═══════════════════════════════════════════════════════════
function loadPdfIframe() {
    var rc = document.getElementById('readerContent');
    rc.innerHTML = '<p style="color:rgba(255,255,255,0.3);text-align:center;padding:60px 0;">⏳ 加载 PDF...</p>';
    if (PDF_URL && PDF_URL.toLowerCase().indexOf('.pdf') > 0) { embedPdfUrl(PDF_URL); return; }
    fetch(FILE_URL)
        .then(function(res) { if (!res.ok) throw new Error('HTTP '+res.status); return res.blob(); })
        .then(function(blob) { _pdfBlobUrl = URL.createObjectURL(blob); embedPdfUrl(_pdfBlobUrl); })
        .catch(function(err) { fallbackToObjectTag(FILE_URL); });
}
function embedPdfUrl(url) {
    var rc = document.getElementById('readerContent');
    rc.innerHTML = '';
    var iframe = document.createElement('iframe');
    iframe.src = url;
    iframe.style.cssText = 'width:100%;height:100%;min-height:88vh;border:none;border-radius:8px;background:#fff;';
    iframe.setAttribute('allow', 'fullscreen');
    rc.appendChild(iframe);
    document.getElementById('readerBody').scrollTop = 0;
    document.getElementById('tocList').innerHTML = '<div style="color:rgba(255,255,255,0.3);text-align:center;padding:10px">PDF 已加载</div>';
    _updateProgLine(0);
    rc.style.maxWidth = '100%';
    document.getElementById('readerFloatingCtrl').classList.add('fctrl-hidden');
}
function fallbackToObjectTag(url) {
    var rc = document.getElementById('readerContent');
    rc.innerHTML = '<object data="'+url+'" type="application/pdf" width="100%" height="100%" style="min-height:85vh;">'
        +'<p style="color:rgba(255,255,255,0.3);text-align:center;padding:60px 20px;">无法预览 PDF，请<button onclick="downloadBook()" style="margin-left:8px;padding:8px 16px;border:none;border-radius:6px;background:#00f2ff;color:#0a1628;cursor:pointer;">📥 下载</button></p></object>';
}

// ═══════════════════════════════════════════════════════════
// DOCX 引擎（增强：提取标题目录 + 字数统计）
// ═══════════════════════════════════════════════════════════
function loadDocx() {
    if (typeof mammoth === 'undefined') { showToast('mammoth.js 未加载'); return; }
    var rc = document.getElementById('readerContent');
    fetch(FILE_URL)
        .then(function(r){ return r.arrayBuffer(); })
        .then(function(buf){ return mammoth.convertToHtml({ arrayBuffer: buf }); })
        .then(function(result){
            tocData = extractDocxToc(result.value);
            rc.innerHTML = result.value
                .replace(/<h1/g, '<h1 class="reader-chapter-title"')
                .replace(/<h2/g, '<h2 class="reader-chapter-label"')
                .replace(/<p(\b[^>]*)?>/g, '<p$1 class="reader-paragraph">');
            totalWordCount = countChineseChars(rc.textContent);
            updateWordStats();
            document.getElementById('tocList').innerHTML = renderTocHtml();
            renderTocDrawer();
            applyReadMode();
            document.getElementById('readerBody').scrollTop = 0;
        })
        .catch(function(){ rc.innerHTML = '<p style="color:rgba(255,255,255,0.3);text-align:center;padding:60px 0;">DOCX 解析失败</p>'; });
}
function extractDocxToc(html) {
    var toc = [], tmp = document.createElement('div'); tmp.innerHTML = html;
    tmp.querySelectorAll('h1,h2').forEach(function(h, i) {
        var text = h.textContent.trim();
        if (text) toc.push({ id: i, title: text.substring(0, 50), anchor: '', isH2: h.tagName === 'H2' });
    });
    return toc;
}

// ═══════════════════════════════════════════════════════════
// Markdown 引擎（增强：提取标题目录 + 字数统计）
// ═══════════════════════════════════════════════════════════
function loadMarkdown() {
    if (typeof marked === 'undefined') { showToast('marked.js 未加载'); return; }
    var rc = document.getElementById('readerContent');
    fetch(FILE_URL)
        .then(function(r){ return r.text(); })
        .then(function(text){
            var rawHtml = marked.parse(text);
            tocData = extractMdToc(rawHtml);
            rc.innerHTML = '<div class="md-content">' + rawHtml + '</div>';
            totalWordCount = countChineseChars(rc.textContent);
            updateWordStats();
            document.getElementById('tocList').innerHTML = renderTocHtml();
            renderTocDrawer();
            applyReadMode();
            document.getElementById('readerBody').scrollTop = 0;
        })
        .catch(function(){ rc.innerHTML = '<p style="color:rgba(255,255,255,0.3);text-align:center;padding:60px 0;">MD 加载失败</p>'; });
}
function extractMdToc(html) {
    var toc = [], tmp = document.createElement('div'); tmp.innerHTML = html;
    tmp.querySelectorAll('h1,h2,h3').forEach(function(h, i) {
        var text = h.textContent.trim();
        if (text) toc.push({ id: i, title: text.substring(0, 50), anchor: '', isH2: h.tagName !== 'H1' });
    });
    return toc;
}

// ═══════════════════════════════════════════════════════════
// 目录渲染
// ═══════════════════════════════════════════════════════════
function renderTOC() { document.getElementById('tocList').innerHTML = renderTocHtml(); }
function renderTocHtml() {
    if (tocData.length === 0) return '<div style="color:rgba(255,255,255,0.3);text-align:center;padding:10px">暂无目录</div>';
    var html = '';
    tocData.forEach(function(ch, i) {
        var cls = ch.indent || ch.isH2 ? ' style="padding-left:24px"' : '';
        html += '<div class="toc-item"'+cls+' onclick="jumpToChapter('+i+')"><span class="toc-name">'+escHtml(ch.title)+'</span></div>';
    });
    return html;
}
function renderTocDrawer() { document.getElementById('tocDrawerBody').innerHTML = renderTocHtml(); }
function jumpToChapter(idx) {
    if (!document.getElementById('reader').classList.contains('active')) {
        document.getElementById('startReadBtn').click();
        setTimeout(function(){ doJump(idx); }, 800);
    } else { doJump(idx); }
}
function doJump(idx) {
    if (epbRendition && tocData[idx]) { try{ epbRendition.display(tocData[idx].href); }catch(e){} }
    else if (tocData[idx]) {
        var targetId = tocData[idx].anchor || ('ch-' + idx);
        var el = document.getElementById(targetId);
        if (el) el.scrollIntoView({ behavior: 'smooth' });
    }
    document.getElementById('tocDrawer').classList.remove('open');
}

// ═══════════════════════════════════════════════════════════
// 翻页
// ═══════════════════════════════════════════════════════════
function readerPrev() {
    if (epbRendition) { try{ epbRendition.prev(); }catch(e){} return; }
    if (FMT === 'PDF') return;
    if (currentReadMode === 'paged') {
        var rc = document.getElementById('readerContent');
        rc.scrollBy({ left: -rc.clientWidth * 0.85, behavior: 'smooth' });
    } else {
        var body = document.getElementById('readerBody');
        body.scrollBy({ top: -body.clientHeight * 0.85, behavior: 'smooth' });
    }
}
function readerNext() {
    if (epbRendition) { try{ epbRendition.next(); }catch(e){} return; }
    if (FMT === 'PDF') return;
    if (currentReadMode === 'paged') {
        var rc = document.getElementById('readerContent');
        rc.scrollBy({ left: rc.clientWidth * 0.85, behavior: 'smooth' });
    } else {
        var body = document.getElementById('readerBody');
        body.scrollBy({ top: body.clientHeight * 0.85, behavior: 'smooth' });
    }
}

// ═══════════════════════════════════════════════════════════
// 章节导航
// ═══════════════════════════════════════════════════════════
function detectCurrentChapter() {
    if (epbRendition || tocData.length === 0) return;
    var rb = document.getElementById('readerBody');
    var scrollMid = rb.scrollTop + rb.clientHeight * 0.2;
    for (var i = tocData.length - 1; i >= 0; i--) {
        var targetId = tocData[i].anchor || ('ch-' + i);
        var el = document.getElementById(targetId);
        if (el && el.offsetTop <= scrollMid) { currentChapterIdx = i; return; }
    }
    currentChapterIdx = 0;
}
function prevChapter() {
    if (tocData.length === 0) { readerPrev(); return; }
    if (epbRendition) { try{ epbRendition.prev(); }catch(e){} return; }
    detectCurrentChapter();
    currentChapterIdx = Math.max(0, currentChapterIdx - 1);
    var targetId = tocData[currentChapterIdx].anchor || ('ch-' + currentChapterIdx);
    var el = document.getElementById(targetId);
    if (el) { el.scrollIntoView({ behavior: 'smooth' }); saveReadingProgress(); }
}
function nextChapter() {
    if (tocData.length === 0) { readerNext(); return; }
    if (epbRendition) { try{ epbRendition.next(); }catch(e){} return; }
    detectCurrentChapter();
    currentChapterIdx = Math.min(tocData.length - 1, currentChapterIdx + 1);
    var targetId = tocData[currentChapterIdx].anchor || ('ch-' + currentChapterIdx);
    var el = document.getElementById(targetId);
    if (el) { el.scrollIntoView({ behavior: 'smooth' }); saveReadingProgress(); }
}

// ═══════════════════════════════════════════════════════════
// 进度条（顶部极细线 + 浮动控制条）
// ═══════════════════════════════════════════════════════════
(function() {
    var s = document.createElement('style'); s.id = '_rpgStyle'; document.head.appendChild(s);
    _rpgSheet = s.sheet;
})();
function _updateProgLine(pct) {
    pct = Math.min(100, Math.max(0, Math.round(pct)));
    if (!_rpgSheet) return;
    while (_rpgSheet.cssRules.length > 0) _rpgSheet.deleteRule(0);
    _rpgSheet.insertRule('#readerTopProgress::after{width:'+pct+'%}', 0);
    document.getElementById('fctrlProgress').textContent = pct + '%';
    debouncedSaveProgress();
}

var readerBodyEl = document.getElementById('readerBody');
readerBodyEl.addEventListener('scroll', function() {
    if (epbRendition || FMT === 'PDF') return;
    var el = this;
    if (currentReadMode === 'paged') {
        if (el.scrollWidth - el.clientWidth <= 0) return;
        _updateProgLine((el.scrollLeft / (el.scrollWidth - el.clientWidth)) * 100);
    } else {
        if (el.scrollHeight - el.clientHeight <= 0) return;
        _updateProgLine((el.scrollTop / (el.scrollHeight - el.clientHeight)) * 100);
    }
    if (!epbRendition && FMT !== 'PDF' && tocData.length > 0) detectCurrentChapter();
    updateFloatCtrlVisibility();
    debouncedSaveProgress();
});

// ═══════════════════════════════════════════════════════════
// 浮动控制条自动显隐
// ═══════════════════════════════════════════════════════════
function updateFloatCtrlVisibility() {
    var fctrl = document.getElementById('readerFloatingCtrl');
    if (FMT === 'PDF' || epbRendition) { fctrl.classList.add('fctrl-hidden'); return; }
    fctrl.classList.remove('fctrl-hidden');
    if (_fctrlHideTimer) clearTimeout(_fctrlHideTimer);
    _fctrlHideTimer = setTimeout(function() { fctrl.classList.add('fctrl-hidden'); }, 3000);
}
readerBodyEl.addEventListener('mousemove', updateFloatCtrlVisibility);
readerBodyEl.addEventListener('touchstart', updateFloatCtrlVisibility);

// ═══════════════════════════════════════════════════════════
// 分页模式
// ═══════════════════════════════════════════════════════════
function setReadMode(mode) {
    if (FMT === 'EPUB' || FMT === 'PDF') return;
    currentReadMode = mode;
    applyReadMode();
    updateReadModeUI();
    saveReaderSettings();
}
function applyReadMode() {
    var rc = document.getElementById('readerContent');
    var rb = document.getElementById('readerBody');
    if (currentReadMode === 'paged') {
        rc.classList.add('paged-mode');
        rb.style.overflowY = 'hidden'; rb.style.overflowX = '';
        rb.scrollLeft = 0;
    } else {
        rc.classList.remove('paged-mode');
        rb.style.overflowY = 'auto'; rb.style.overflowX = 'hidden';
        rb.scrollTop = 0;
    }
}
function updateReadModeUI() {
    document.querySelectorAll('.reader-mode-option').forEach(function(b) {
        b.classList.toggle('active', b.getAttribute('data-mode') === currentReadMode);
    });
}

// ═══════════════════════════════════════════════════════════
// 阅读设置（主题 / 字号 / 行距 / 字体）
// ═══════════════════════════════════════════════════════════
var readerContentEl = document.getElementById('readerContent');

function setReaderTheme(theme) {
    var reader = document.getElementById('reader');
    ['reader-theme-paper','reader-theme-dark','reader-theme-sepia','reader-theme-green','reader-theme-oled','reader-theme-warm'].forEach(function(c){
        reader.classList.remove(c);
    });
    if (theme !== 'dark') reader.classList.add('reader-theme-' + theme);
    currentTheme = theme;
    document.querySelectorAll('.reader-theme-card').forEach(function(card) {
        card.classList.toggle('active', card.getAttribute('data-theme') === theme);
    });
    if (epbRendition) {
        try {
            switch(theme) {
                case 'dark': epbRendition.themes.select('dark'); break;
                case 'paper': epbRendition.themes.select('default'); epbRendition.themes.css('body{background:#e8dcc8!important;color:#4a3a2a!important}'); break;
                case 'sepia': epbRendition.themes.select('default'); epbRendition.themes.css('body{background:#2a1a0a!important;color:rgba(232,200,160,0.88)!important}'); break;
                case 'green': epbRendition.themes.select('default'); epbRendition.themes.css('body{background:#0a2015!important;color:rgba(160,220,180,0.82)!important}'); break;
                case 'oled': epbRendition.themes.select('default'); epbRendition.themes.css('body{background:#000!important;color:rgba(255,255,255,0.7)!important}'); break;
                case 'warm': epbRendition.themes.select('default'); epbRendition.themes.css('body{background:#2a1f10!important;color:rgba(240,220,180,0.82)!important}'); break;
                default: epbRendition.themes.select('default');
            }
        } catch(e) {}
    }
    saveReaderSettings();
}
function adjustFontTo(val) {
    currentFontSize = val;
    readerContentEl.style.fontSize = val + 'px';
    document.getElementById('fontSizeVal').textContent = val;
    document.getElementById('fontSizeSlider').value = val;
    if (epbRendition) { try{ epbRendition.themes.fontSize(val + 'px'); }catch(e){} }
    saveReaderSettings();
}
function adjustFont(delta) { adjustFontTo(Math.min(28, Math.max(12, currentFontSize + delta))); }
function adjustLineHeightTo(val) {
    currentLineHeight = val;
    readerContentEl.style.lineHeight = val;
    document.getElementById('lineHeightVal').textContent = val.toFixed(1);
    document.getElementById('lineHeightSlider').value = Math.round(val * 10);
    saveReaderSettings();
}
function adjustLineHeight(delta) { adjustLineHeightTo(Math.round((Math.min(2.8, Math.max(1.4, currentLineHeight + delta))) * 10) / 10); }
function setFont(font) { readerContentEl.style.fontFamily = font; saveReaderSettings(); }

// ═══════════════════════════════════════════════════════════
// 书签切换
// ═══════════════════════════════════════════════════════════
function toggleReaderBookmark() {
    var btn = document.getElementById('bookmarkBtn');
    var isMarked = btn.classList.toggle('rbtn-active');
    fetch(cp + '/api/bookAction', {method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=toggleBookmark&bookId='+BOOK_ID})
        .then(function(r){ return r.json(); })
        .then(function(data){
            if(data.success){
                syncReaderBookmarkIcon(data.bookmarked);
                var detailBtn = document.querySelector('.action-btn[onclick="toggleBookmark(this)"]');
                if(detailBtn) {
                    detailBtn.innerHTML = data.bookmarked ?
                        '<svg width="15" height="15" viewBox="0 0 24 24" fill="#7dd3fc" stroke="#7dd3fc" stroke-width="2"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg> 已收藏' :
                        '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg> 收藏';
                    detailBtn.classList.toggle('bookmarked', data.bookmarked);
                }
                showToast(data.bookmarked ? '已加入书签' : '已取消书签');
            } else { btn.classList.toggle('rbtn-active'); }
        }).catch(function(){ btn.classList.toggle('rbtn-active'); });
}

// ═══════════════════════════════════════════════════════════
// 全屏
// ═══════════════════════════════════════════════════════════
function toggleFullscreen() {
    var reader = document.getElementById('reader');
    if (!document.fullscreenElement) {
        if (reader.requestFullscreen) reader.requestFullscreen();
        else if (reader.webkitRequestFullscreen) reader.webkitRequestFullscreen();
    } else { if (document.exitFullscreen) document.exitFullscreen(); }
}

// ═══════════════════════════════════════════════════════════
// 阅读进度管理
// ═══════════════════════════════════════════════════════════
function saveReadingProgress() {
    try {
        var data = { ts: Date.now(), pct: 0, chIdx: currentChapterIdx, chTitle: '' };
        if (epbRendition) {
            var loc = epbRendition.currentLocation && epbRendition.currentLocation();
            data.pct = loc && loc.start ? Math.round(loc.start.percentage * 100) : 0;
        } else {
            var rb = document.getElementById('readerBody');
            if (currentReadMode === 'paged') {
                if (rb.scrollWidth - rb.clientWidth > 0) data.pct = Math.round((rb.scrollLeft / (rb.scrollWidth - rb.clientWidth)) * 100);
            } else {
                if (rb.scrollHeight - rb.clientHeight > 0) data.pct = Math.round((rb.scrollTop / (rb.scrollHeight - rb.clientHeight)) * 100);
            }
        }
        if (tocData[currentChapterIdx]) data.chTitle = tocData[currentChapterIdx].title;
        localStorage.setItem(lskey('progress'), JSON.stringify(data));
    } catch(e) {}
}
function debouncedSaveProgress() {
    if (_progressSaveTimer) clearTimeout(_progressSaveTimer);
    _progressSaveTimer = setTimeout(saveReadingProgress, 3000);
}

// ═══════════════════════════════════════════════════════════
// 继续阅读横幅
// ═══════════════════════════════════════════════════════════
function loadResumeBanner() {
    try {
        var raw = localStorage.getItem(lskey('progress'));
        if (!raw) return;
        var data = JSON.parse(raw);
        if (!data || data.pct === undefined) return;
        document.getElementById('resumeBanner').style.display = 'flex';
        document.getElementById('resumeChapter').textContent = data.chTitle || '—';
        document.getElementById('resumePct').textContent = data.pct;
        currentChapterIdx = data.chIdx || 0;
        document.getElementById('resumeReadBtn').addEventListener('click', function() {
            openReader();
            if (FMT === 'EPUB') loadEpub(); else if (FMT === 'DOCX' || FMT === 'DOC') loadDocx(); else if (FMT === 'MD' || FMT === 'MARKDOWN') loadMarkdown(); else if (FMT === 'PDF') loadPdfIframe(); else loadTxt();
            var checkLoaded = setInterval(function() {
                var rb = document.getElementById('readerBody');
                if (rb.scrollHeight > 200 || (epbRendition && epbRendition.currentLocation)) {
                    clearInterval(checkLoaded);
                    setTimeout(function() {
                        if (epbRendition && tocData.length > 0) { try{ epbRendition.display(tocData[currentChapterIdx].href); }catch(e){} }
                        else if (tocData[currentChapterIdx]) {
                            var targetId = tocData[currentChapterIdx].anchor || ('ch-' + currentChapterIdx);
                            var el = document.getElementById(targetId);
                            if (el) el.scrollIntoView({ behavior: 'smooth' });
                        } else {
                            var pct = data.pct / 100;
                            if (currentReadMode === 'paged') rb.scrollLeft = pct * (rb.scrollWidth - rb.clientWidth);
                            else rb.scrollTop = pct * (rb.scrollHeight - rb.clientHeight);
                        }
                    }, 300);
                }
            }, 200);
        });
    } catch(e) {}
}

// ═══════════════════════════════════════════════════════════
// 阅读计时器
// ═══════════════════════════════════════════════════════════
function startTimer() { readingTimerSec = 0; updateTimerDisplay(); if (timerInterval) clearInterval(timerInterval);
    timerInterval = setInterval(function(){ readingTimerSec++; updateTimerDisplay(); }, 1000); }
function updateTimerDisplay() { var m = Math.floor(readingTimerSec / 60), s = readingTimerSec % 60;
    document.getElementById('readerTimer').textContent = (m<10?'0':'')+m+':'+(s<10?'0':'')+s; }
function stopTimer() { if (timerInterval) { clearInterval(timerInterval); timerInterval = null; } }

// ═══════════════════════════════════════════════════════════
// 字数统计与阅读时间预估
// ═══════════════════════════════════════════════════════════
function countChineseChars(text) {
    if (!text) return 0;
    var cjk = text.match(/[\u4e00-\u9fff\u3400-\u4dbf]/g);
    var words = text.match(/[a-zA-Z0-9]+/g);
    return (cjk ? cjk.length : 0) + (words ? words.reduce(function(a,w){return a+(w.length>3?1:0.5)},0):0);
}
function updateWordStats() {
    document.getElementById('fctrlWords').textContent = totalWordCount.toLocaleString() + ' 字';
    var wpm = 300, mins = Math.max(1, Math.ceil(totalWordCount / wpm));
    if (mins >= 60) document.getElementById('fctrlTime').textContent = '约 ' + Math.floor(mins/60) + 'h' + (mins%60) + 'm';
    else document.getElementById('fctrlTime').textContent = '约 ' + mins + ' 分钟';
}

// ═══════════════════════════════════════════════════════════
// 设置持久化
// ═══════════════════════════════════════════════════════════
function saveReaderSettings() {
    try {
        var settings = { fontSize: currentFontSize, lineHeight: currentLineHeight, font: readerContentEl.style.fontFamily, theme: currentTheme, readMode: currentReadMode };
        localStorage.setItem(lskey('settings'), JSON.stringify(settings));
    } catch(e) {}
}
function loadReaderSettings() {
    try {
        var raw = localStorage.getItem(lskey('settings'));
        if (!raw) return;
        var s = JSON.parse(raw);
        if (s.fontSize) adjustFontTo(parseInt(s.fontSize));
        if (s.lineHeight) adjustLineHeightTo(parseFloat(s.lineHeight));
        if (s.font) setFont(s.font);
        if (s.theme) setReaderTheme(s.theme);
        if (s.readMode && s.readMode === 'paged') setReadMode('paged');
    } catch(e) {}
}

// ═══════════════════════════════════════════════════════════
// 初始化
// ═══════════════════════════════════════════════════════════
loadResumeBanner();

// ═══════════════════════════════════════════════════════════
// 自动打开阅读器
// ═══════════════════════════════════════════════════════════
<% if ("1".equals(request.getParameter("autoOpen"))) { %>
setTimeout(function() {
    var btn = document.getElementById('startReadBtn');
    if (btn) btn.click();
}, 400);
<% } %>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>