<%--
 =============================================================================
 majorBooks.jsp
 =============================================================================

 用途      功能页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ebookBuy301.pojo.Book, com.ebookBuy301.pojo.Major, com.ebookBuy301.pojo.BookType, java.util.ArrayList" %>
<%!
    // XSS 转义
    private String escapeHtml(String str) {
        if (str == null) return "";
        return str.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                  .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    Major major = (Major) request.getAttribute("major");
    ArrayList<Book> books = (ArrayList<Book>) request.getAttribute("books");
    ArrayList<BookType> linkedTypes = (ArrayList<BookType>) request.getAttribute("linkedTypes");
    if (major == null) { response.sendRedirect(request.getContextPath() + "/majorMatrix"); return; }
    if (books == null) books = new ArrayList<>();
    if (linkedTypes == null) linkedTypes = new ArrayList<>();
    String ctx = request.getContextPath();

    String icon = major.getIcon() != null ? major.getIcon() : "📚";
    String name = major.getName() != null ? major.getName() : "";
    String desc = major.getDescription() != null ? major.getDescription() : "";
    String cat = major.getCategory() != null ? major.getCategory() : "";
    int count = books.size();

    // 分类色彩（与 majors.jsp 完全一致）
    String catColor, catBg, catBorder;
    if ("人文".equals(cat)) { catColor="#f59e0b"; catBg="rgba(245,158,11,0.08)"; catBorder="rgba(245,158,11,0.20)"; }
    else if ("艺术".equals(cat)) { catColor="#ec4899"; catBg="rgba(236,72,153,0.08)"; catBorder="rgba(236,72,153,0.20)"; }
    else if ("工学".equals(cat)) { catColor="#3b82f6"; catBg="rgba(59,130,246,0.08)"; catBorder="rgba(59,130,246,0.20)"; }
    else if ("理学".equals(cat)) { catColor="#10b981"; catBg="rgba(16,185,129,0.08)"; catBorder="rgba(16,185,129,0.20)"; }
    else if ("交叉".equals(cat)) { catColor="#8b5cf6"; catBg="rgba(139,92,246,0.08)"; catBorder="rgba(139,92,246,0.20)"; }
    else { catColor="#7dd3fc"; catBg="rgba(125,211,252,0.06)"; catBorder="rgba(125,211,252,0.15)"; }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= escapeHtml(name) %> · 书阁｜博雅书院</title>
    <link rel="stylesheet" href="<%= ctx %>/CSS/majorBooks.css?v=2.1">
    <!-- ========== 浅色主题 · 书阁全覆盖 ========== -->
    <style>
        html[data-theme$="-light"],html[data-theme$="-light"] body{background:linear-gradient(170deg,#e9e2d2,#ede5d3 40%,#e4dbca)!important;color:#3d3929!important}
        html[data-theme$="-light"] ::selection{background:rgba(37,99,235,.15)!important;color:#3d3929!important}
        html[data-theme$="-light"] .top-nav{border-bottom-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .nav-back{color:rgba(61,57,41,.35)!important}
        html[data-theme$="-light"] .nav-back:hover{color:rgba(61,57,41,.6)!important;background:rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] .nav-title{color:rgba(61,57,41,.45)!important}
        html[data-theme$="-light"] .nav-count{color:#2563eb!important}
        html[data-theme$="-light"] .nav-count-label{color:rgba(61,57,41,.2)!important}
        html[data-theme$="-light"] .domain-banner{background:linear-gradient(160deg,rgba(238,233,222,.82),rgba(243,239,228,.9))!important}
        html[data-theme$="-light"] .banner-title{color:#3d3929!important;text-shadow:none!important}
        html[data-theme$="-light"] .banner-desc{color:rgba(61,57,41,.35)!important}
        html[data-theme$="-light"] .btag-sub{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.06)!important;color:rgba(61,57,41,.35)!important}
        html[data-theme$="-light"] .search-icon{color:rgba(61,57,41,.2)!important}
        html[data-theme$="-light"] .search-input{background:rgba(238,233,222,.85)!important;border-color:rgba(139,119,80,.08)!important;color:#3d3929!important}
        html[data-theme$="-light"] .search-input:focus{border-color:rgba(37,99,235,.2)!important;background:rgba(245,240,232,.95)!important}
        html[data-theme$="-light"] .search-input::placeholder{color:rgba(61,57,41,.2)!important}
        html[data-theme$="-light"] .search-clear{background:rgba(139,119,80,.06)!important;color:rgba(61,57,41,.3)!important}
        html[data-theme$="-light"] .search-clear:hover{background:rgba(139,119,80,.1)!important;color:rgba(61,57,41,.5)!important}
        html[data-theme$="-light"] .sort-select{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.08)!important;color:rgba(61,57,41,.4)!important}
        html[data-theme$="-light"] .sort-select:focus{border-color:rgba(37,99,235,.15)!important}
        html[data-theme$="-light"] .sort-select option{background:#f0ebe0!important;color:#3d3929!important}
        html[data-theme$="-light"] .view-toggle{border-color:rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .vt-btn{color:rgba(61,57,41,.25)!important}
        html[data-theme$="-light"] .vt-btn:hover{color:rgba(61,57,41,.45)!important}
        html[data-theme$="-light"] .vt-active{background:rgba(37,99,235,.07)!important;color:#2563eb!important}
        html[data-theme$="-light"] .fb{border-color:rgba(139,119,80,.06)!important;color:rgba(61,57,41,.25)!important}
        html[data-theme$="-light"] .fb:hover{border-color:rgba(37,99,235,.1)!important;color:rgba(61,57,41,.45)!important}
        html[data-theme$="-light"] .fb-active{background:rgba(37,99,235,.06)!important;border-color:rgba(37,99,235,.15)!important;color:#2563eb!important}
        html[data-theme$="-light"] .result-hint{color:rgba(61,57,41,.15)!important}
        html[data-theme$="-light"] .result-hint strong{color:rgba(61,57,41,.3)!important}
        html[data-theme$="-light"] .book-card{background:linear-gradient(160deg,rgba(238,233,222,.8),rgba(243,239,228,.86))!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .book-card::before{background:radial-gradient(circle at center,rgba(37,99,235,.02),transparent 60%)!important}
        html[data-theme$="-light"] .book-card:hover{box-shadow:0 12px 36px rgba(139,119,80,.12)!important;border-color:rgba(37,99,235,.1)!important}
        html[data-theme$="-light"] .card-cover{background:rgba(139,119,80,.05)!important}
        html[data-theme$="-light"] .cover-placeholder{background:linear-gradient(135deg,#e0d8c5,#d8cfb8)!important}
        html[data-theme$="-light"] .card-bookmark{background:rgba(139,119,80,.1)!important;color:rgba(61,57,41,.35)!important}
        html[data-theme$="-light"] .card-bookmark:hover{background:rgba(37,99,235,.12)!important;color:#2563eb!important}
        html[data-theme$="-light"] .card-bookmark.bookmarked{color:#2563eb!important;background:rgba(37,99,235,.1)!important}
        html[data-theme$="-light"] .card-bookmark.bookmarked svg{fill:#2563eb!important;stroke:#2563eb!important}
        html[data-theme$="-light"] .card-title{color:#3d3929!important}
        html[data-theme$="-light"] .card-author{color:rgba(61,57,41,.3)!important}
        html[data-theme$="-light"] .card-summary{color:rgba(61,57,41,.2)!important}
        html[data-theme$="-light"] .card-meta-line,.card-year,.card-format,.card-dl{color:rgba(61,57,41,.2)!important}
        html[data-theme$="-light"] .cf-type{background:rgba(37,99,235,.05)!important;border-color:rgba(37,99,235,.06)!important;color:rgba(37,99,235,.4)!important}
        html[data-theme$="-light"] .cf-read{color:rgba(37,99,235,.25)!important}
        html[data-theme$="-light"] .book-card:hover .cf-read{color:rgba(37,99,235,.5)!important}
        html[data-theme$="-light"] .empty-icon{opacity:.15!important}
        html[data-theme$="-light"] .empty-msg{color:rgba(61,57,41,.2)!important}
        html[data-theme$="-light"] .back-top{background:rgba(238,233,222,.9)!important;border-color:rgba(37,99,235,.1)!important;color:rgba(37,99,235,.4)!important}
        html[data-theme$="-light"] .back-top:hover{border-color:rgba(37,99,235,.25)!important;color:#2563eb!important;background:rgba(243,239,228,.95)!important}
        html[data-theme$="-light"] .page-footer{color:rgba(61,57,41,.08)!important}
        html[data-theme$="-light"] svg,html[data-theme$="-light"] [class*="icon"]{color:#5c5540!important;fill:#5c5540!important}
        html[data-theme$="-light"] input::placeholder{color:rgba(61,57,41,.2)!important}
    </style>
</head>
<body>
<div class="page">
    <!-- 顶部导航 -->
    <nav class="top-nav">
        <a href="<%= ctx %>/majorMatrix" class="nav-back">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5"/><polyline points="12 19 5 12 12 5"/></svg>
            <span class="nav-back-text">学域矩阵</span>
        </a>
        <span class="nav-title">书阁 · <%= escapeHtml(name) %></span>
        <div class="nav-right">
            <span class="nav-count" id="bookCount"><%= count %></span>
            <span class="nav-count-label">册</span>
        </div>
    </nav>

    <!-- 学域头部 (视觉 banner) -->
    <header class="domain-banner" style="--c-color:<%= catColor %>;--c-bg:<%= catBg %>;--c-border:<%= catBorder %>">
        <div class="banner-glow"></div>
        <div class="banner-content">
            <div class="banner-icon"><%= escapeHtml(icon) %></div>
            <div class="banner-info">
                <h1 class="banner-title"><%= escapeHtml(name) %></h1>
                <p class="banner-desc"><%= escapeHtml(desc) %></p>
                <div class="banner-tags">
                    <span class="btag"><%= escapeHtml(cat) %></span>
                    <% for (BookType bt : linkedTypes) { %>
                    <span class="btag btag-sub"><%= escapeHtml(bt.getbTypeName()) %></span>
                    <% } %>
                </div>
            </div>
        </div>
    </header>

    <!-- 工具栏：搜索 + 排序 + 视图切换 -->
    <div class="toolbar">
        <div class="toolbar-search">
            <svg class="search-icon" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
            <input type="text" id="searchInput" class="search-input" placeholder="搜索书名、作者..." oninput="filterBooks()">
            <button class="search-clear" id="searchClear" onclick="clearSearch()">✕</button>
        </div>
        <div class="toolbar-actions">
            <select id="sortSelect" class="sort-select" onchange="sortBooks()">
                <option value="downloads">按热度</option>
                <option value="title">按书名</option>
                <option value="year">按年份</option>
            </select>
            <div class="view-toggle">
                <button class="vt-btn vt-active" id="gridView" onclick="setView('grid')" title="网格视图">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg>
                </button>
                <button class="vt-btn" id="listView" onclick="setView('list')" title="列表视图">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
                </button>
            </div>
        </div>
    </div>

    <!-- 分类筛选 pills -->
    <div class="filter-strip" id="filterStrip">
        <button class="fb fb-active" data-type="all">全部 <sup><%= count %></sup></button>
        <% 
            java.util.LinkedHashMap<String, Integer> typeCount = new java.util.LinkedHashMap<>();
            for (Book b : books) {
                String tn = b.getTypeName();
                if (tn == null || tn.isEmpty()) tn = "未分类";
                typeCount.put(tn, typeCount.getOrDefault(tn, 0) + 1);
            }
            for (java.util.Map.Entry<String, Integer> e : typeCount.entrySet()) {
        %>
        <button class="fb" data-type="<%= escapeHtml(e.getKey()) %>"><%= escapeHtml(e.getKey()) %> <sup><%= e.getValue() %></sup></button>
        <% } %>
    </div>

    <!-- 结果数提示 -->
    <div class="result-hint" id="resultHint">共 <strong><%= count %></strong> 册图书</div>

    <!-- 图书容器 -->
    <div class="book-grid" id="bookGrid" data-view="grid">
        <% if (books.isEmpty()) { %>
        <div class="empty-state">
            <div class="empty-icon">📖</div>
            <p class="empty-msg">该学域暂无关联图书</p>
        </div>
        <% } else {
            for (Book book : books) {
                String cover = book.getBookCover();
                String coverSrc;
                if (cover != null && !cover.trim().isEmpty()) {
                    coverSrc = cover.startsWith("http") ? cover : ctx + cover;
                } else {
                    coverSrc = "data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%22200%22 height=%22300%22><rect fill=%22%23101a30%22 width=%22100%25%22 height=%22100%25%22 rx=%228%22/><text x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 fill=%22%23333%22 font-size=%2236%22>📖</text></svg>";
                }
                String title = book.getBookTitle() != null ? book.getBookTitle() : "";
                String author = book.getBookAuthor() != null ? book.getBookAuthor() : "";
                String summary = book.getBookSummary() != null ? book.getBookSummary() : "";
                String typeName = book.getTypeName() != null ? book.getTypeName() : "";
                String format = book.getBookFormat() != null ? book.getBookFormat() : "";
                long downloads = book.getDownloadTimes();
                String year = book.getBookPubYear() != null ? book.getBookPubYear().toString().substring(0,4) : "";
        %>
        <div class="book-card"
             data-title="<%= escapeHtml(title) %>"
             data-author="<%= escapeHtml(author) %>"
             data-type="<%= escapeHtml(typeName) %>"
             data-year="<%= escapeHtml(year) %>"
             data-downloads="<%= downloads %>"
             data-book-id="<%= book.getId() %>"
             onclick="openInFrame('<%= ctx %>/bookDetail?bookId=<%= book.getId() %>')">
            <button class="card-bookmark" onclick="event.stopPropagation();toggleCardBookmark(this,<%= book.getId() %>)" title="收藏">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
            </button>
            <div class="card-cover">
                <img src="<%= coverSrc %>" alt="<%= escapeHtml(title) %>" loading="lazy"
                     onerror="this.parentElement.innerHTML='<div class=\'cover-placeholder\'><span>📖</span></div>'">
                <% if (downloads > 1000) { %>
                <span class="card-hot">🔥 热门</span>
                <% } %>
            </div>
            <div class="card-body">
                <h3 class="card-title"><%= escapeHtml(title) %></h3>
                <p class="card-author"><%= escapeHtml(author) %></p>
                <p class="card-summary"><%= escapeHtml(summary) %></p>
                <div class="card-meta-line">
                    <% if (!year.isEmpty()) { %><span class="card-year"><%= escapeHtml(year) %></span><% } %>
                    <span class="card-format"><%= escapeHtml(format.isEmpty() ? "未知" : format) %></span>
                    <span class="card-dl">⬇ <%= downloads %></span>
                </div>
            </div>
            <div class="card-footer">
                <span class="cf-type"><%= escapeHtml(typeName) %></span>
                <span class="cf-read" onclick="event.stopPropagation();openInFrame('<%= ctx %>/bookDetail?bookId=<%= book.getId() %>');event.preventDefault();">开始阅读 →</span>
            </div>
        </div>
        <% }} %>
    </div>

    <!-- 回到顶部 -->
    <button class="back-top" id="backTop" onclick="window.scrollTo({top:0,behavior:'smooth'})">↑</button>

    <!-- 底部 -->
    <footer class="page-footer">博雅书院 · 智识无界</footer>
</div>

<script>
/** 在父框架右侧内容区加载页面，避免整体跳转 */
function openInFrame(url) {
    try { var f = window.top.document.getElementById('academicFrame'); if (f) { f.src = url; return; } } catch(e) {}
    window.top.location.href = url;
}
(function() {
    // ===== 动态动画延迟（支持任意数量卡片） =====
    document.querySelectorAll('.book-card').forEach(function(card, index) {
        card.style.animationDelay = (index * 0.06) + 's';
    });

    // ===== 分类筛选 =====
    document.querySelectorAll('.fb').forEach(function(btn) {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.fb').forEach(function(b) { b.classList.remove('fb-active'); });
            btn.classList.add('fb-active');
            filterBooks();
        });
    });

    // ===== 搜索+筛选 =====
    window.filterBooks = function() {
        var q = document.getElementById('searchInput').value.trim().toLowerCase();
        var activeType = document.querySelector('.fb.fb-active');
        var typeFilter = activeType ? activeType.getAttribute('data-type') : 'all';
        var visibleCount = 0;

        document.querySelectorAll('.book-card').forEach(function(card) {
            var title = card.getAttribute('data-title').toLowerCase();
            var author = card.getAttribute('data-author').toLowerCase();
            var cardType = card.getAttribute('data-type');
            var matchSearch = !q || title.indexOf(q) !== -1 || author.indexOf(q) !== -1;
            var matchType = typeFilter === 'all' || cardType === typeFilter;

            if (matchSearch && matchType) {
                card.style.display = '';
                visibleCount++;
            } else {
                card.style.display = 'none';
            }
        });
        document.getElementById('resultHint').innerHTML = '共 <strong>' + visibleCount + '</strong> 册图书';
        document.getElementById('searchClear').style.display = q ? 'flex' : 'none';
    };

    window.clearSearch = function() {
        document.getElementById('searchInput').value = '';
        filterBooks();
        document.getElementById('searchInput').focus();
    };

    // ===== 排序 =====
    window.sortBooks = function() {
        var sortBy = document.getElementById('sortSelect').value;
        var grid = document.getElementById('bookGrid');
        var cards = Array.from(grid.querySelectorAll('.book-card'));

        cards.sort(function(a, b) {
            if (sortBy === 'title') {
                return a.getAttribute('data-title').localeCompare(b.getAttribute('data-title'));
            } else if (sortBy === 'year') {
                return (b.getAttribute('data-year') || '').localeCompare(a.getAttribute('data-year') || '');
            } else {
                return parseInt(b.getAttribute('data-downloads')) - parseInt(a.getAttribute('data-downloads'));
            }
        });

        // 动画移除再追加
        cards.forEach(function(c) { c.style.animation = 'none'; grid.appendChild(c); });
        setTimeout(function() {
            cards.forEach(function(c, i) {
                c.style.animation = '';
                c.style.animationDelay = (i * 0.04) + 's';
            });
        }, 50);
    };

    // ===== 视图切换 =====
    window.setView = function(view) {
        document.getElementById('bookGrid').setAttribute('data-view', view);
        document.getElementById('gridView').classList.toggle('vt-active', view === 'grid');
        document.getElementById('listView').classList.toggle('vt-active', view === 'list');
    };

    // ===== 回到顶部按钮 =====
    window.addEventListener('scroll', function() {
        document.getElementById('backTop').classList.toggle('show', window.scrollY > 400);
    });

    // ===== 统计数字动画 =====
    var countEl = document.getElementById('bookCount');
    var target = parseInt(countEl.textContent);
    if (target > 0) {
        var current = 0;
        var step = Math.max(1, Math.floor(target / 30));
        var timer = setInterval(function() {
            current += step;
            if (current >= target) { current = target; clearInterval(timer); }
            countEl.textContent = current;
        }, 30);
    }

    // ===== ESC 清除搜索 =====
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') clearSearch();
    });

    // ===== 收藏功能 =====
    window.toggleCardBookmark = function(btn, bookId) {
        fetch('<%= ctx %>/api/bookAction', {method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=toggleBookmark&bookId='+bookId})
            .then(function(r){ return r.json(); })
            .then(function(data){
                if(data.success) {
                    var isMarked = data.bookmarked;
                    btn.classList.toggle('bookmarked', isMarked);
                    var svg = btn.querySelector('svg');
                    svg.setAttribute('fill', isMarked ? '#7dd3fc' : 'none');
                    svg.setAttribute('stroke', isMarked ? '#7dd3fc' : 'currentColor');
                }
            }).catch(function(){});
    };

    // 页面加载时查询用户收藏列表，标记已收藏的书籍
    (function(){
        fetch('<%= ctx %>/api/bookAction?action=userBookmarks')
            .then(function(r){ return r.json(); })
            .then(function(data){
                if(data.success && data.books && data.books.length > 0) {
                    // 构建已收藏 bookId 集合
                    var bmSet = {};
                    data.books.forEach(function(b){ bmSet[b.bookId] = true; });
                    // 标记卡片上的收藏按钮
                    document.querySelectorAll('.card-bookmark').forEach(function(btn){
                        var card = btn.closest('.book-card');
                        var bid = card ? card.getAttribute('data-book-id') : null;
                        if(bid && bmSet[bid]) {
                            btn.classList.add('bookmarked');
                            var svg = btn.querySelector('svg');
                            svg.setAttribute('fill', '#7dd3fc');
                            svg.setAttribute('stroke', '#7dd3fc');
                        }
                    });
                }
            }).catch(function(){});
    })();
})();
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
