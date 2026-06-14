<%--
 =============================================================================
 resources.jsp  ——  资源中心 v3.0
 =============================================================================
 
 设计：标准 .book-card（与 majorBooks.jsp 一致）
 数据：与图书表完全对齐（封面/书名/作者/简介/年份/格式/下载量/分类/热门）
 功能：分类筛选 / 三字段搜索 / 分页 / XSS安全

 路由：/resourcePage（ResourcePageServlet）
 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ebookBuy301.pojo.Users" %>
<%@ page import="com.ebookBuy301.pojo.Book" %>
<%@ page import="com.ebookBuy301.pojo.BookType" %>
<%@ page import="java.util.ArrayList" %>
<%
    Users currentUser = (Users) request.getAttribute("currentUser");
    ArrayList<BookType> bookTypes = (ArrayList<BookType>) request.getAttribute("bookTypes");
    ArrayList<Book> hotBooks = (ArrayList<Book>) request.getAttribute("hotBooks");
    long totalBooks = request.getAttribute("totalBooks") != null ? (Long) request.getAttribute("totalBooks") : 0L;
    String ctx = request.getContextPath();
%>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>资源中心 · 博雅书院</title>
    <style>
/* === Critical Inline (外联加载前兜底，与 majorBooks.css .book-card 风格一致) === */
html,body{background:#060b14;margin:0;padding:0;min-height:100vh;color:#e2e8f0;font-family:'Inter','Segoe UI','PingFang SC','Microsoft YaHei',sans-serif;overflow-x:hidden}
.rc-container{max-width:1260px;margin:0 auto;padding:28px 32px 48px;position:relative;z-index:1}
.rc-header{display:flex;justify-content:space-between;align-items:center;padding:28px 36px;margin-bottom:24px;background:linear-gradient(135deg,rgba(20,30,60,.55),rgba(30,25,55,.5));border:1px solid rgba(52,211,153,.2);border-radius:24px;backdrop-filter:blur(20px);box-shadow:0 4px 24px rgba(0,0,0,.5);flex-wrap:wrap;gap:16px;position:relative;overflow:hidden}
.rc-header::before{content:'';position:absolute;top:0;left:0;right:0;height:1px;background:linear-gradient(90deg,transparent,rgba(52,211,153,.3),rgba(59,130,246,.2),transparent)}
.rc-title{font-size:1.6rem;font-weight:900;margin:0 0 6px;background:linear-gradient(135deg,#34d399,#3b82f6,#8b5cf6);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
.rc-subtitle{font-size:.82rem;color:#64748b}
.rc-subtitle strong{color:#7dd3fc;font-weight:700}
.rc-search-input{background:rgba(18,28,50,.6);border:1px solid rgba(125,211,252,.15);border-radius:12px;color:#e2e8f0;padding:10px 38px 10px 16px;font-size:.88rem;width:240px;outline:0;transition:all .3s;backdrop-filter:blur(8px)}
.rc-search-input:focus{border-color:rgba(52,211,153,.4);box-shadow:0 0 20px rgba(52,211,153,.08);width:280px}
.rc-search-input::placeholder{color:#475569}
.rc-sort{background:rgba(18,28,50,.6);border:1px solid rgba(125,211,252,.15);border-radius:10px;color:#e2e8f0;padding:9px 14px;font-size:.85rem;outline:0;cursor:pointer;backdrop-filter:blur(8px)}
.rc-categories{display:flex;gap:8px;padding:14px 0 20px;flex-wrap:wrap;overflow-x:auto}
.rc-cat{background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.06);border-radius:10px;color:#94a3b8;padding:7px 16px;font-size:.82rem;font-weight:600;cursor:pointer;transition:all .35s;white-space:nowrap;backdrop-filter:blur(8px)}
.rc-cat:hover{background:rgba(255,255,255,.07);border-color:rgba(52,211,153,.2);color:#cbd5e1}
.rc-cat.active{background:linear-gradient(135deg,rgba(52,211,153,.15),rgba(59,130,246,.1));border-color:rgba(52,211,153,.25);color:#34d399;box-shadow:0 0 14px rgba(52,211,153,.08)}

/* ===== book-card (对齐 majorBooks.css) ===== */
.book-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(230px,1fr));gap:1rem}
.book-card{background:linear-gradient(160deg,rgba(18,28,50,.4),rgba(12,18,35,.55));border:1px solid rgba(125,211,252,.04);border-radius:16px;overflow:hidden;cursor:pointer;transition:all .4s cubic-bezier(.16,1,.3,1);display:flex;flex-direction:column;position:relative;animation:cardIn .5s ease forwards;opacity:0}
@keyframes cardIn{to{opacity:1}}
.book-card:hover{transform:translateY(-6px);box-shadow:0 16px 45px rgba(0,0,0,.5);border-color:rgba(125,211,252,.12)}
.card-cover{position:relative;width:100%;height:200px;overflow:hidden;display:flex;align-items:center;justify-content:center;background:rgba(0,0,0,.4)}
.card-cover img{width:100%;height:100%;object-fit:cover;transition:transform .5s ease}
.book-card:hover .card-cover img{transform:scale(1.08)}
.cover-placeholder{display:flex;align-items:center;justify-content:center;width:100%;height:100%;font-size:3rem;opacity:.25}
.card-hot{position:absolute;top:8px;right:8px;font-size:.6rem;font-weight:700;padding:2px 8px;border-radius:8px;background:rgba(239,68,68,.15);border:1px solid rgba(239,68,68,.25);color:#f87171;backdrop-filter:blur(4px)}
.card-bookmark{position:absolute;top:8px;left:8px;width:28px;height:28px;border-radius:8px;border:1px solid rgba(255,255,255,.08);background:rgba(0,0,0,.35);color:rgba(255,255,255,.25);cursor:pointer;display:flex;align-items:center;justify-content:center;z-index:2;opacity:0;transition:all .25s}
.book-card:hover .card-bookmark{opacity:1}
.card-bookmark:hover{background:rgba(125,211,252,.15);color:#7dd3fc;transform:scale(1.12)}
.card-body{padding:.7rem .8rem .3rem;flex:1;display:flex;flex-direction:column}
.card-title{font-size:.85rem;font-weight:600;color:#e2e8f0;margin-bottom:2px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.card-author{font-size:.68rem;color:rgba(255,255,255,.25);margin-bottom:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.card-summary{font-size:.66rem;color:rgba(255,255,255,.15);line-height:1.5;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;display:-webkit-box;margin:4px 0;flex:1}
.card-meta-line{display:none;gap:6px;flex-wrap:wrap;font-size:.62rem;margin-top:auto;padding-top:6px}
.card-year,.card-format,.card-dl{color:rgba(255,255,255,.15)}
.card-footer{display:flex;align-items:center;padding:.4rem .8rem;border-top:1px solid rgba(125,211,252,.03)}
.cf-type{font-size:.58rem;padding:1px 7px;border-radius:6px;background:rgba(125,211,252,.05);border:1px solid rgba(125,211,252,.06);color:rgba(125,211,252,.35)}
.cf-read{font-size:.62rem;color:rgba(125,211,252,.3);margin-left:auto;padding:2px 8px;border-radius:6px;border:1px solid transparent;cursor:pointer;transition:all .35s;white-space:nowrap}
.book-card:hover .cf-read{color:#7dd3fc;border-color:rgba(125,211,252,.15);background:rgba(125,211,252,.06)}

/* ===== pagination / empty / toast ===== */
.rc-pagination{display:flex;justify-content:center;align-items:center;gap:6px;margin-top:28px;flex-wrap:wrap}
.rc-page-btn{background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.06);border-radius:8px;color:#94a3b8;padding:7px 14px;font-size:.82rem;font-weight:600;cursor:pointer;transition:all .25s;min-width:38px;text-align:center}
.rc-page-btn:hover{background:rgba(255,255,255,.07);border-color:rgba(52,211,153,.2);color:#e2e8f0}
.rc-page-btn.active{background:linear-gradient(135deg,rgba(52,211,153,.2),rgba(59,130,246,.15));border-color:rgba(52,211,153,.25);color:#34d399;box-shadow:0 0 12px rgba(52,211,153,.1)}
.rc-page-dots{color:#475569;padding:0 4px;font-size:.82rem}
.rc-page-info{color:#475569;font-size:.78rem;margin-right:10px}
.rc-empty{text-align:center;padding:80px 20px;color:#64748b;grid-column:1/-1}
.rc-empty-icon{font-size:3.5rem;margin-bottom:14px;opacity:.45}
.rc-loading{text-align:center;padding:80px 20px;color:#64748b;grid-column:1/-1}
.rc-retry-btn{margin-top:16px;padding:9px 24px;background:rgba(52,211,153,.08);border:1px solid rgba(52,211,153,.25);border-radius:8px;color:#34d399;font-size:.82rem;font-weight:600;cursor:pointer;transition:all .25s}
.rc-retry-btn:hover{background:rgba(52,211,153,.18);box-shadow:0 0 20px rgba(52,211,153,.1)}
.rc-spinner{width:36px;height:36px;margin:0 auto 14px;border:3px solid rgba(52,211,153,.12);border-top-color:#34d399;border-radius:50%;animation:spin .8s linear infinite}
@keyframes spin{to{transform:rotate(360deg)}}
.rc-toast{position:fixed;bottom:32px;left:50%;transform:translateX(-50%) translateY(20px);padding:12px 28px;border-radius:50px;font-size:.85rem;font-weight:600;z-index:2000;opacity:0;pointer-events:none;transition:all .4s cubic-bezier(.4,0,.2,1);backdrop-filter:blur(16px);box-shadow:0 8px 30px rgba(0,0,0,.6);white-space:nowrap;background:rgba(10,16,30,.95);border:1px solid rgba(255,255,255,.08);color:#e2e8f0}
.rc-toast.show{opacity:1;transform:translateX(-50%) translateY(0)}
.rc-toast-error{border-color:rgba(239,68,68,.35);color:#f87171;background:rgba(20,10,10,.95)}
@media(max-width:1024px){.book-grid{grid-template-columns:repeat(3,1fr)}}
@media(max-width:768px){.rc-container{padding:16px 14px 32px}.rc-header{padding:22px 20px;border-radius:18px}.rc-search-input{width:100%}.rc-search-input:focus{width:100%}.book-grid{grid-template-columns:repeat(2,1fr);gap:.7rem}.card-cover{height:170px}}
@media(max-width:480px){.book-grid{grid-template-columns:1fr 1fr;gap:.5rem}.card-cover{height:150px}.card-title{font-size:.78rem}}
    </style>
    <link rel="stylesheet" href="<%= ctx %>/CSS/resources.css?v=20260604-v3">
    <style>
/* ══════════ 浅色主题 · 资源中心全覆盖 ══════════ */
/* ── CSS变量覆写（驱动resources.css全部var()）── */
html[data-theme$="-light"]{
    --rc-bg:#e8dfcf;--rc-surface:rgba(238,233,222,.85);--rc-border:rgba(139,119,80,.06);
    --rc-border-glow:rgba(37,99,235,.12);--rc-text:#3d3929;--rc-text-dim:rgba(61,57,41,.3);
    --rc-text-faint:rgba(61,57,41,.18);--rc-accent:#2563eb;--rc-accent2:#2563eb;
    --rc-accent3:#7c3aed;--rc-glow:0 4px 24px rgba(139,119,80,.08);
}
/* ── 基础 + 浮动光球 dim ── */
html[data-theme$="-light"] body{background:linear-gradient(170deg,#e9e2d2,#ede5d3 50%,#e4dbca)!important;color:#3d3929!important}
html[data-theme$="-light"] .rc-orb{opacity:.05!important}
/* ── 头部 ── */
html[data-theme$="-light"] .rc-header{background:linear-gradient(135deg,rgba(238,233,222,.78),rgba(243,239,228,.85))!important;border-color:rgba(37,99,235,.1)!important;box-shadow:0 4px 20px rgba(139,119,80,.08)!important}
html[data-theme$="-light"] .rc-header::before{background:linear-gradient(90deg,transparent,rgba(37,99,235,.15),rgba(37,99,235,.1),transparent)!important}
html[data-theme$="-light"] .rc-title{background:linear-gradient(135deg,#2563eb,#7c3aed)!important;-webkit-background-clip:text!important;background-clip:text!important;-webkit-text-fill-color:transparent!important}
html[data-theme$="-light"] .rc-subtitle{color:#7a7360!important}
html[data-theme$="-light"] .rc-subtitle strong{color:#2563eb!important}
/* ── 搜索/排序 ── */
html[data-theme$="-light"] .rc-search-input{background:rgba(238,233,222,.85)!important;border-color:rgba(139,119,80,.1)!important;color:#3d3929!important}
html[data-theme$="-light"] .rc-search-input:focus{border-color:rgba(37,99,235,.2)!important;box-shadow:0 0 20px rgba(37,99,235,.04)!important}
html[data-theme$="-light"] .rc-search-input::placeholder{color:rgba(61,57,41,.3)!important}
html[data-theme$="-light"] .rc-search-icon{opacity:.35!important}
html[data-theme$="-light"] .rc-sort{background:rgba(238,233,222,.85)!important;border-color:rgba(139,119,80,.1)!important;color:#3d3929!important}
html[data-theme$="-light"] .rc-sort option{background:#f0ebe0!important;color:#3d3929!important}
/* ── 分类 ── */
html[data-theme$="-light"] .rc-cat{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.06)!important;color:#7a7360!important}
html[data-theme$="-light"] .rc-cat:hover{background:rgba(37,99,235,.05)!important;border-color:rgba(37,99,235,.12)!important;color:#5c5540!important}
html[data-theme$="-light"] .rc-cat.active{background:linear-gradient(135deg,rgba(37,99,235,.1),rgba(124,58,237,.06))!important;border-color:rgba(37,99,235,.18)!important;color:#2563eb!important;box-shadow:0 0 12px rgba(37,99,235,.06)!important}
/* ── 图书卡片 ── */
html[data-theme$="-light"] .book-card{background:linear-gradient(160deg,rgba(238,233,222,.82),rgba(243,239,228,.88))!important;border-color:rgba(139,119,80,.06)!important;box-shadow:0 2px 8px rgba(139,119,80,.04)!important}
html[data-theme$="-light"] .book-card::before{background:radial-gradient(circle at center,rgba(37,99,235,.03),transparent 60%)!important}
html[data-theme$="-light"] .book-card:hover{box-shadow:0 12px 36px rgba(139,119,80,.1)!important;border-color:rgba(37,99,235,.1)!important}
html[data-theme$="-light"] .card-cover{background:rgba(139,119,80,.05)!important}
html[data-theme$="-light"] .cover-placeholder{opacity:.3!important}
html[data-theme$="-light"] .card-hot{background:rgba(239,68,68,.6)!important;color:#fff!important}
html[data-theme$="-light"] .card-bookmark{background:rgba(139,119,80,.08)!important;border-color:rgba(139,119,80,.1)!important;color:rgba(61,57,41,.25)!important}
html[data-theme$="-light"] .card-bookmark:hover{background:rgba(37,99,235,.1)!important;color:#2563eb!important}
html[data-theme$="-light"] .card-bookmark.bookmarked{color:#2563eb!important;background:rgba(37,99,235,.08)!important}
html[data-theme$="-light"] .card-bookmark.bookmarked svg{fill:#2563eb!important;stroke:#2563eb!important}
html[data-theme$="-light"] .card-title{color:#3d3929!important}
html[data-theme$="-light"] .card-author{color:rgba(61,57,41,.35)!important}
html[data-theme$="-light"] .card-summary{color:rgba(61,57,41,.2)!important}
html[data-theme$="-light"] .card-year,.card-format,.card-dl{color:rgba(61,57,41,.2)!important}
html[data-theme$="-light"] .card-footer{border-top-color:rgba(139,119,80,.05)!important}
html[data-theme$="-light"] .cf-type{background:rgba(37,99,235,.05)!important;border-color:rgba(37,99,235,.06)!important;color:rgba(37,99,235,.4)!important}
html[data-theme$="-light"] .cf-read{color:rgba(37,99,235,.25)!important}
html[data-theme$="-light"] .book-card:hover .cf-read{color:#2563eb!important;border-color:rgba(37,99,235,.12)!important;background:rgba(37,99,235,.05)!important}
/* ── 分页 ── */
html[data-theme$="-light"] .rc-page-btn{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.06)!important;color:#7a7360!important}
html[data-theme$="-light"] .rc-page-btn:hover{background:rgba(37,99,235,.05)!important;border-color:rgba(37,99,235,.12)!important;color:#5c5540!important}
html[data-theme$="-light"] .rc-page-btn.active{background:linear-gradient(135deg,rgba(37,99,235,.1),rgba(124,58,237,.06))!important;border-color:rgba(37,99,235,.18)!important;color:#2563eb!important;box-shadow:0 0 12px rgba(37,99,235,.06)!important}
html[data-theme$="-light"] .rc-page-dots{color:#7a7360!important}
html[data-theme$="-light"] .rc-page-info{color:#7a7360!important}
/* ── 空/加载/重试 ── */
html[data-theme$="-light"] .rc-empty{color:#7a7360!important}
html[data-theme$="-light"] .rc-empty p{color:#7a7360!important}
html[data-theme$="-light"] .rc-loading{color:#7a7360!important}
html[data-theme$="-light"] .rc-retry-btn{background:rgba(37,99,235,.06)!important;border-color:rgba(37,99,235,.15)!important;color:#2563eb!important}
html[data-theme$="-light"] .rc-retry-btn:hover{background:rgba(37,99,235,.12)!important;box-shadow:0 0 20px rgba(37,99,235,.06)!important}
html[data-theme$="-light"] .rc-spinner{border-color:rgba(37,99,235,.08)!important;border-top-color:#2563eb!important}
/* ── Toast ── */
html[data-theme$="-light"] .rc-toast{background:rgba(238,233,222,.97)!important;border-color:rgba(139,119,80,.08)!important;color:#3d3929!important;box-shadow:0 8px 32px rgba(139,119,80,.15)!important}
html[data-theme$="-light"] .rc-toast-error{border-color:rgba(220,60,60,.2)!important;color:#b91c1c!important;background:rgba(254,242,242,.97)!important}
html[data-theme$="-light"] .rc-toast-info{border-color:rgba(37,99,235,.15)!important;color:#2563eb!important}
/* ── 通用 ── */
html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3{color:#3d3929!important}
html[data-theme$="-light"] p{color:#7a7360!important}
    </style>
</head>
<body>
<div class="rc-orb rc-orb-1"></div>
<div class="rc-orb rc-orb-2"></div>
<div class="rc-orb rc-orb-3"></div>

<div class="rc-container">

    <!-- ===== Header ===== -->
    <header class="rc-header">
        <div class="rc-header-left">
            <h1 class="rc-title">资源中心</h1>
            <span class="rc-subtitle">共 <strong id="rcTotalCount"><%= totalBooks %></strong> 本资源</span>
        </div>
        <div class="rc-header-right">
            <div class="rc-search-wrap">
                <input type="text" class="rc-search-input" id="rcSearch" placeholder="搜索书名、作者、简介..." oninput="onSearch()">
                <span class="rc-search-icon">🔍</span>
            </div>
            <select class="rc-sort" id="rcSort" onchange="loadBooks()">
                <option value="newest">最新</option>
                <option value="popular">最热</option>
            </select>
        </div>
    </header>

    <!-- ===== 分类 ===== -->
    <div class="rc-categories">
        <button class="rc-cat active" data-type="" onclick="filterByType('')">全部</button>
        <% if (bookTypes != null) {
            for (BookType bt : bookTypes) { %>
        <button class="rc-cat" data-type="<%= esc(bt.getbTid()) %>" onclick="filterByType('<%= esc(bt.getbTid()) %>')">
            <%= esc(bt.getbTypeName()) %>
        </button>
        <% }} %>
    </div>

    <!-- ===== 图书网格（对齐 majorBooks.jsp .book-card） ===== -->
    <div class="book-grid" id="rcGrid">
        <% if (hotBooks != null && !hotBooks.isEmpty()) {
            for (Book b : hotBooks) {
                String cover = b.getBookCover();
                String coverSrc;
                if (cover != null && !cover.trim().isEmpty()) {
                    coverSrc = cover.startsWith("http") ? cover : ctx + cover;
                } else {
                    coverSrc = "data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%22200%22 height=%22300%22><rect fill=%22%23101a30%22 width=%22100%25%22 height=%22100%25%22 rx=%228%22/><text x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 fill=%22%23333%22 font-size=%2236%22>📖</text></svg>";
                }
                String title = b.getBookTitle() != null ? b.getBookTitle() : "";
                String author = b.getBookAuthor() != null ? b.getBookAuthor() : "";
                String summary = b.getBookSummary() != null ? b.getBookSummary() : "";
                String typeName = b.getTypeName() != null ? b.getTypeName() : "";
                String fmt = b.getBookFormat() != null ? b.getBookFormat() : "";
                long dl = b.getDownloadTimes();
                String year = b.getBookPubYear() != null ? b.getBookPubYear().toString().substring(0,4) : "";
        %>
        <div class="book-card"
             data-title="<%= esc(title) %>"
             data-author="<%= esc(author) %>"
             data-type="<%= esc(typeName) %>"
             data-year="<%= esc(year) %>"
             data-downloads="<%= dl %>"
             data-book-id="<%= b.getId() %>"
             onclick="openInFrame('<%= ctx %>/bookDetail?bookId=<%= b.getId() %>')">
            <button class="card-bookmark" onclick="event.stopPropagation();toggleBookmark(this,<%= b.getId() %>)" title="收藏">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
            </button>
            <div class="card-cover">
                <img src="<%= coverSrc %>" alt="<%= esc(title) %>" loading="lazy"
                     onerror="this.parentElement.innerHTML='<div class=\'cover-placeholder\'><span>📖</span></div>'">
                <% if (dl > 1000) { %>
                <span class="card-hot">🔥 热门</span>
                <% } %>
            </div>
            <div class="card-body">
                <h3 class="card-title"><%= esc(title) %></h3>
                <p class="card-author"><%= esc(author) %></p>
                <p class="card-summary"><%= esc(summary) %></p>
                <div class="card-meta-line">
                    <% if (!year.isEmpty()) { %><span class="card-year"><%= esc(year) %></span><% } %>
                    <span class="card-format"><%= esc(fmt.isEmpty() ? "未知" : fmt) %></span>
                    <span class="card-dl">⬇ <%= dl %></span>
                </div>
            </div>
            <div class="card-footer">
                <span class="cf-type"><%= esc(typeName) %></span>
                <span class="cf-read" onclick="openInFrame('<%= ctx %>/bookDetail?bookId=<%= b.getId() %>')">开始阅读 →</span>
            </div>
        </div>
        <% }} else { %>
        <div class="rc-empty"><div class="rc-empty-icon">📭</div><p>暂无资源</p></div>
        <% } %>
    </div>

    <div class="rc-pagination" id="rcPagination"></div>
</div>

<!-- Toast -->
<div class="rc-toast" id="rcToast"></div>

<script>
var ctx = '<%= ctx %>';
var currentType = '';
var currentPage = 1;
var totalPages = 1;
var searchTimer = null;

/** 在父框架（index.jsp）的右侧内容区加载页面，避免整体跳转 */
function openInFrame(url) {
    try {
        // 更新 index.jsp 的 academicFrame
        var topIframe = window.top.document.getElementById('academicFrame');
        if (topIframe) { topIframe.src = url; return; }
    } catch(e) {}
    // 回退：直接跳转
    window.top.location.href = url;
}

// ══════════ 主题同步：页面加载时从父窗口恢复主题 ══════════
(function syncTheme() {
    var theme = 'quantum-matrix';
    // 优先从父窗口读（最准确）
    try {
        if (window.parent && window.parent !== window) {
            var pt = window.parent.document.documentElement.getAttribute('data-theme');
            if (pt) theme = pt;
        }
    } catch(e){}
    // 兜底：localStorage
    var saved = localStorage.getItem('boya-theme');
    if (saved) theme = saved;
    document.documentElement.setAttribute('data-theme', theme);
    // 加载浅色主题CSS
    var link = document.createElement('link');
    link.rel = 'stylesheet';
    link.id = 'boya-light-css';
    link.href = '<%= request.getContextPath() %>/CSS/sub-pages-light.css';
    document.head.appendChild(link);
    // 监听父窗口发来的主题切换消息
    window.addEventListener('message', function(e) {
        if (e.data && e.data.type === 'themeChange' && e.data.theme) {
            document.documentElement.setAttribute('data-theme', e.data.theme);
            localStorage.setItem('boya-theme', e.data.theme);
        }
    });
})();

// 首屏卡片动画延迟
document.querySelectorAll('.book-card').forEach(function(card, i) {
    card.style.animationDelay = (i * 0.06) + 's';
});

function filterByType(typeId) {
    currentType = typeId;
    currentPage = 1;
    document.querySelectorAll('.rc-cat').forEach(function(c){c.classList.remove('active')});
    var t = document.querySelector('.rc-cat[data-type="' + typeId + '"]');
    if(t) t.classList.add('active');
    loadBooks();
}

function onSearch() {
    currentPage = 1;
    clearTimeout(searchTimer);
    searchTimer = setTimeout(loadBooks, 300);
}

function goPage(page) {
    if (page<1||page>totalPages||page===currentPage) return;
    currentPage = page;
    loadBooks();
    document.getElementById('rcGrid').scrollIntoView({behavior:'smooth',block:'start'});
}

// 收藏按钮
function toggleBookmark(btn, bookId) {
    var bookmarked = btn.classList.toggle('bookmarked');
    fetch(ctx + '/api/bookAction', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=' + (bookmarked ? 'addBookmark' : 'removeBookmark') + '&bookId=' + bookId
    }).catch(function(){});
    showToast(bookmarked ? '已收藏' : '已取消收藏', 'info');
}

function loadBooks() {
    var keyword = document.getElementById('rcSearch').value.trim();
    var sort = document.getElementById('rcSort').value;
    var params = 'action=list&sort=' + sort + '&page=' + currentPage;
    if (keyword) params += '&keyword=' + encodeURIComponent(keyword);
    else if (currentType) params += '&typeId=' + encodeURIComponent(currentType);

    var grid = document.getElementById('rcGrid');
    var pag = document.getElementById('rcPagination');
    grid.innerHTML = '<div class="rc-loading"><div class="rc-spinner"></div><p>加载中...</p></div>';
    pag.innerHTML = '';

    fetch(ctx + '/resourcePage?' + params)
        .then(function(r){if(!r.ok)throw new Error('HTTP '+r.status);return r.json()})
        .then(function(d){
            if(!d.success){showToast(d.message||'加载失败','error');grid.innerHTML='<div class="rc-empty"><div class="rc-empty-icon">⚠️</div><p>'+escHtml(d.message||'加载失败')+'</p></div>';return}
            document.getElementById('rcTotalCount').textContent = d.total || 0;
            if(!d.books||!d.books.length){grid.innerHTML='<div class="rc-empty"><div class="rc-empty-icon">📭</div><p>没有找到资源</p></div>';return}

            var h = '';
            d.books.forEach(function(b, i) {
                var coverHtml = b.cover
                    ? '<img src="' + (b.cover.startsWith('http') ? escHtml(b.cover) : ctx + escHtml(b.cover)) + '" alt="' + escHtml(b.title) + '" loading="lazy" onerror="this.parentElement.innerHTML=\'<div class=&#92;\'cover-placeholder&#92;\'><span>📖</span></div>\'">'
                    : '';
                var placeholder = !b.cover ? '<div class="cover-placeholder"><span>📖</span></div>' : '';
                var hotBadge = b.isHot ? '<span class="card-hot">🔥 热门</span>' : '';
                var yearSpan = b.year ? '<span class="card-year">' + escHtml(b.year) + '</span>' : '';

                h += '<div class="book-card" data-title="' + escHtml(b.title) + '" data-author="' + escHtml(b.author||'') + '" data-type="' + escHtml(b.typeName||'') + '" data-year="' + escHtml(b.year||'') + '" data-downloads="' + (b.downloads||0) + '" data-book-id="' + b.id + '" onclick="openInFrame(\'' + ctx + '/bookDetail?bookId=' + b.id + '\')" style="animation-delay:' + (i*0.03) + 's">';
                h += '<button class="card-bookmark" onclick="event.stopPropagation();toggleBookmark(this,' + b.id + ')" title="收藏"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg></button>';
                h += '<div class="card-cover">' + coverHtml + placeholder + hotBadge + '</div>';
                h += '<div class="card-body">';
                h += '<h3 class="card-title">' + escHtml(b.title) + '</h3>';
                h += '<p class="card-author">' + escHtml(b.author||'') + '</p>';
                h += '<p class="card-summary">' + escHtml(b.summary||'') + '</p>';
                h += '<div class="card-meta-line">' + yearSpan + '<span class="card-format">' + escHtml(b.format||'未知') + '</span><span class="card-dl">⬇ ' + (b.downloads||0) + '</span></div>';
                h += '</div>';
                h += '<div class="card-footer"><span class="cf-type">' + escHtml(b.typeName||'') + '</span><span class="cf-read" onclick="openInFrame(\'' + ctx + '/bookDetail?bookId=' + b.id + '\')">开始阅读 →</span></div>';
                h += '</div>';
            });
            grid.innerHTML = h;

            totalPages = d.totalPages || 1;
            if (totalPages > 1) {
                var ph = '<span class="rc-page-info">共 ' + (d.total||0) + ' 本</span>';
                if (currentPage > 1) ph += '<button class="rc-page-btn" onclick="goPage(' + (currentPage-1) + ')">◀</button>';
                var s = Math.max(1, currentPage-2), e = Math.min(totalPages, currentPage+2);
                if (s > 1) ph += '<button class="rc-page-btn" onclick="goPage(1)">1</button><span class="rc-page-dots">...</span>';
                for (var p = s; p <= e; p++) ph += '<button class="rc-page-btn' + (p===currentPage?' active':'') + '" onclick="goPage(' + p + ')">' + p + '</button>';
                if (e < totalPages) ph += '<span class="rc-page-dots">...</span><button class="rc-page-btn" onclick="goPage(' + totalPages + ')">' + totalPages + '</button>';
                if (currentPage < totalPages) ph += '<button class="rc-page-btn" onclick="goPage(' + (currentPage+1) + ')">▶</button>';
                pag.innerHTML = ph;
            }
        })
        .catch(function(e){console.error('[resources]',e);showToast('网络异常，请稍后重试','error');grid.innerHTML='<div class="rc-empty"><div class="rc-empty-icon">⚠️</div><p>加载失败，请检查网络后重试</p><button class="rc-retry-btn" onclick="loadBooks()">重新加载</button></div>'});
}

function escHtml(s){return s?String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;'):''}

function showToast(msg, type) {
    var t = document.getElementById('rcToast');
    t.textContent = msg; t.className = 'rc-toast rc-toast-' + (type||'info') + ' show';
    clearTimeout(t._timer); t._timer = setTimeout(function(){t.classList.remove('show')}, 3000);
}
</script>
</body>
</html>
