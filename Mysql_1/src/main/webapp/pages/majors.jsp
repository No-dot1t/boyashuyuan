<%--=============================================================================majors.jsp ——
    我的书架（主导航项2）=============================================================================功能： 1. 未登录：显示登录引导 2. 已登录： -
    Tab 1：我的收藏（从 /api/bookAction?action=bookmarks 加载） - Tab 2：最近阅读（从 UserActivity 加载，前端 fetch /api/studyroom 扩展） - Tab
    3：下载历史（从 UserActivity download 加载） 3. 每本图书卡片显示封面/标题/作者/操作（继续阅读/取消收藏） 4. 支持搜索过滤 路由：/majorsPage（MajorPageServlet
    转发，后端仅传递 isLoggedIn）=============================================================================--%>
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
        <%@ page import="com.ebookBuy301.pojo.Users" %>
<%
    // 从 session 判断登录状态，传递给 JS
    Object sessUser = session.getAttribute("currentUser");
    boolean isLoggedIn = (sessUser != null);
    String userId = "";
    String username = "";
    if (isLoggedIn) {
        Users u = (Users) sessUser;
        userId = u.getId() != null ? u.getId().toString() : "";
        username = u.getNickname() != null && !u.getNickname().isEmpty() ? u.getNickname() : u.getUsername();
    }
%>
                <!DOCTYPE html>
                <html lang="zh-CN">

                <head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>博雅书院 · 我的书架</title>
                    <link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/majors.css?v=5.0">
    <!-- ========== 浅色主题 · 我的书架全覆盖 ========== -->
    <style>
        /* 基础底色 */
        html[data-theme$="-light"],html[data-theme$="-light"] body{background:linear-gradient(160deg,#e9e2d2,#ede5d3 50%,#e4dbca)!important;color:#3d3929!important}
        /* 头部 */
        html[data-theme$="-light"] .bs-header{background:rgba(238,233,222,.88)!important;border-color:rgba(139,119,80,.07)!important}
        html[data-theme$="-light"] .bs-header-icon{background:linear-gradient(135deg,rgba(37,99,235,.08),rgba(139,119,80,.05))!important;border-color:rgba(37,99,235,.12)!important}
        html[data-theme$="-light"] .bs-header-text h1{background:linear-gradient(135deg,#3d3929,#2563eb,#7c3aed)!important;-webkit-background-clip:text!important;background-clip:text!important;color:transparent!important}
        html[data-theme$="-light"] .bs-subtitle{color:rgba(61,57,41,.4)!important}
        /* 搜索框 */
        html[data-theme$="-light"] .bs-search-input{background:rgba(238,233,222,.9)!important;border-color:rgba(139,119,80,.1)!important;color:#3d3929!important}
        html[data-theme$="-light"] .bs-search-input::placeholder{color:rgba(61,57,41,.3)!important}
        html[data-theme$="-light"] .bs-search-input:focus{border-color:rgba(37,99,235,.3)!important;background:rgba(245,240,232,.95)!important;box-shadow:0 0 16px rgba(37,99,235,.04)!important}
        html[data-theme$="-light"] .bs-search-icon{opacity:.35!important}
        /* 统计条 */
        html[data-theme$="-light"] .bs-stat{background:rgba(238,233,222,.7)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .bs-stat:hover{background:rgba(238,233,222,.9)!important;border-color:rgba(37,99,235,.12)!important}
        html[data-theme$="-light"] .bs-stat-num{color:#2563eb!important;text-shadow:none!important}
        html[data-theme$="-light"] .bs-stat-label{color:rgba(61,57,41,.35)!important}
        /* Tab切换 */
        html[data-theme$="-light"] .bs-tabs{background:rgba(238,233,222,.6)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .bs-tab{color:rgba(61,57,41,.4)!important}
        html[data-theme$="-light"] .bs-tab:hover{color:rgba(61,57,41,.6)!important;background:rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] .bs-tab.active{color:#2563eb!important;background:rgba(37,99,235,.08)!important;box-shadow:0 2px 8px rgba(37,99,235,.06)!important}
        /* 图书卡片 */
        html[data-theme$="-light"] .bs-book-card{background:linear-gradient(160deg,rgba(238,233,222,.82),rgba(243,239,228,.88))!important;border-color:rgba(139,119,80,.07)!important}
        html[data-theme$="-light"] .bs-book-card:hover{border-color:rgba(37,99,235,.12)!important;box-shadow:0 8px 28px rgba(139,119,80,.08),0 0 20px rgba(37,99,235,.03)!important}
        html[data-theme$="-light"] .bs-book-card::before{background:linear-gradient(90deg,transparent,rgba(37,99,235,.25),transparent)!important}
        html[data-theme$="-light"] .bs-book-card:hover::before{background:linear-gradient(90deg,transparent,#2563eb,transparent)!important}
        html[data-theme$="-light"] .bs-book-cover-wrap{background:linear-gradient(135deg,rgba(139,119,80,.04),rgba(37,99,235,.03))!important}
        html[data-theme$="-light"] .bs-book-cover-placeholder{background:linear-gradient(135deg,#e0d8c5,#d8cfb8)!important}
        /* 图书信息 */
        html[data-theme$="-light"] .bs-book-title{color:#3d3929!important}
        html[data-theme$="-light"] .bs-book-author{color:rgba(61,57,41,.35)!important}
        /* 按钮 */
        html[data-theme$="-light"] .bs-btn-primary{background:linear-gradient(135deg,rgba(37,99,235,.1),rgba(139,92,246,.06))!important;color:#2563eb!important;border-color:rgba(37,99,235,.18)!important}
        html[data-theme$="-light"] .bs-btn-primary:hover{background:linear-gradient(135deg,rgba(37,99,235,.18),rgba(139,92,246,.12))!important;box-shadow:0 0 14px rgba(37,99,235,.06)!important}
        html[data-theme$="-light"] .bs-btn-danger{background:rgba(255,100,100,.06)!important;color:#e05555!important;border-color:rgba(255,100,100,.1)!important}
        html[data-theme$="-light"] .bs-btn-danger:hover{background:rgba(255,100,100,.12)!important;box-shadow:0 0 14px rgba(255,100,100,.04)!important}
        /* 空状态 */
        html[data-theme$="-light"] .bs-empty{color:rgba(61,57,41,.25)!important}
        html[data-theme$="-light"] .bs-empty p{color:rgba(61,57,41,.35)!important}
        html[data-theme$="-light"] .bs-go-btn{background:linear-gradient(135deg,rgba(37,99,235,.08),rgba(139,119,80,.05))!important;border-color:rgba(37,99,235,.15)!important;color:#2563eb!important}
        html[data-theme$="-light"] .bs-go-btn:hover{background:linear-gradient(135deg,rgba(37,99,235,.15),rgba(139,119,80,.1))!important;box-shadow:0 0 16px rgba(37,99,235,.05)!important}
        /* 未登录 */
        html[data-theme$="-light"] .bs-not-login{background:rgba(238,233,222,.6)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .bs-not-login h2{color:rgba(61,57,41,.5)!important}
        html[data-theme$="-light"] .bs-not-login p{color:rgba(61,57,41,.3)!important}
        html[data-theme$="-light"] .bs-login-btn{background:linear-gradient(135deg,rgba(37,99,235,.1),rgba(139,92,246,.06))!important;border-color:rgba(37,99,235,.2)!important;color:#2563eb!important}
        html[data-theme$="-light"] .bs-login-btn:hover{background:linear-gradient(135deg,rgba(37,99,235,.18),rgba(139,92,246,.12))!important;box-shadow:0 0 20px rgba(37,99,235,.06)!important}
        /* 加载/错误 */
        html[data-theme$="-light"] .bs-loading{color:rgba(61,57,41,.3)!important}
        html[data-theme$="-light"] .bs-error{color:#e05555!important}
        /* Toast */
        html[data-theme$="-light"] .bs-toast-success{background:rgba(0,180,130,.08)!important;border-color:rgba(0,180,130,.2)!important;color:#00a070!important}
        html[data-theme$="-light"] .bs-toast-error{background:rgba(255,100,100,.08)!important;border-color:rgba(255,100,100,.2)!important;color:#e05555!important}
        /* 通用兜底 */
        html[data-theme$="-light"] svg,html[data-theme$="-light"] [class*="icon"]{color:#5c5540!important;fill:#5c5540!important}
        html[data-theme$="-light"] input::placeholder,html[data-theme$="-light"] textarea::placeholder{color:rgba(61,57,41,.3)!important}
    </style>
                </head>

                <body>
                    <div class="bs-container">
                        <!-- ===== 页面头部 ===== -->
                        <div class="bs-header">
                            <div class="bs-header-icon">📚</div>
                            <div class="bs-header-text">
                                <h1>我的书架</h1>
                                <p class="bs-subtitle">收藏 · 最近阅读 · 下载历史</p>
                            </div>
                            <!-- 搜索框 -->
                            <div class="bs-search-wrap">
                                <input type="text" id="bsSearchInput" placeholder="在书架中搜索图书..." class="bs-search-input">
                                <span class="bs-search-icon">🔍</span>
                            </div>
                        </div>

                        <!-- ===== 未登录提示 ===== -->
                        <div class="bs-not-login" id="bsNotLogin" style="display:<%= isLoggedIn ? " none" : "flex" %>">
                            <div class="bs-not-login-icon">🔐</div>
                            <h2>请先登录</h2>
                            <p>登录后即可查看您的收藏、阅读历史和下载记录</p>
                            <button class="bs-login-btn"
                                onclick="location.href='<%= request.getContextPath() %>/LOGIN/login.jsp'">去登录</button>
                        </div>

                        <!-- ===== 已登录内容 ===== -->
                        <div class="bs-content" id="bsContent" style="display:<%= isLoggedIn ? " block" : "none" %>">

                            <!-- 统计条 -->
                            <div class="bs-stats">
                                <div class="bs-stat" id="statBookmarks">
                                    <span class="bs-stat-num">–</span>
                                    <span class="bs-stat-label">收藏</span>
                                </div>
                                <div class="bs-stat" id="statRecent">
                                    <span class="bs-stat-num">–</span>
                                    <span class="bs-stat-label">最近阅读</span>
                                </div>
                                <div class="bs-stat" id="statDownloads">
                                    <span class="bs-stat-num">–</span>
                                    <span class="bs-stat-label">下载</span>
                                </div>
                            </div>

                            <!-- Tab 切换 -->
                            <div class="bs-tabs">
                                <button class="bs-tab active" data-tab="bookmarks">📑 我的收藏</button>
                                <button class="bs-tab" data-tab="recent">📖 最近阅读</button>
                                <button class="bs-tab" data-tab="downloads">⬇️ 下载历史</button>
                            </div>

                            <!-- 收藏列表 -->
                            <div class="bs-tab-panel active" id="panel-bookmarks">
                                <div class="bs-book-grid" id="bookmarkGrid">
                                    <div class="bs-loading">加载中...</div>
                                </div>
                                <div class="bs-empty" id="bookmarkEmpty" style="display:none;">
                                    <div class="bs-empty-icon">📭</div>
                                    <p>暂无收藏图书</p>
                                    <button class="bs-go-btn"
                                        onclick="parent.location.hash=''; parent.document.getElementById('academicFrame').src='<%= request.getContextPath() %>/recommend'">去发现好书
                                        →</button>
                                </div>
                            </div>

                            <!-- 最近阅读 -->
                            <div class="bs-tab-panel" id="panel-recent">
                                <div class="bs-book-grid" id="recentGrid">
                                    <div class="bs-loading">加载中...</div>
                                </div>
                                <div class="bs-empty" id="recentEmpty" style="display:none;">
                                    <div class="bs-empty-icon">📖</div>
                                    <p>暂无阅读记录</p>
                                </div>
                            </div>

                            <!-- 下载历史 -->
                            <div class="bs-tab-panel" id="panel-downloads">
                                <div class="bs-book-grid" id="downloadGrid">
                                    <div class="bs-loading">加载中...</div>
                                </div>
                                <div class="bs-empty" id="downloadEmpty" style="display:none;">
                                    <div class="bs-empty-icon">⬇️</div>
                                    <p>暂无下载记录</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <script>
                        (function () {
                            var cp = '<%= request.getContextPath() %>';
                            var isLoggedIn = <%= isLoggedIn ? "true" : "false" %>;
                            var userId = '<%= userId %>';

                            /** 在父框架右侧内容区加载页面，避免整体跳转 */
                            window.openInFrame = function(url) {
                                try { var f = window.top.document.getElementById('academicFrame'); if (f) { f.src = url; return; } } catch(e) {}
                                window.top.location.href = url;
                            };

                            // ===== Tab 切换 =====
                            var tabs = document.querySelectorAll('.bs-tab');
                            var panels = document.querySelectorAll('.bs-tab-panel');
                            tabs.forEach(function (tab) {
                                tab.addEventListener('click', function () {
                                    tabs.forEach(function (t) { t.classList.remove('active'); });
                                    tab.classList.add('active');
                                    var target = tab.getAttribute('data-tab');
                                    panels.forEach(function (p) {
                                        p.classList.toggle('active', p.id === 'panel-' + target);
                                    });
                                    // 惰性加载
                                    if (target === 'recent' && !window._recentLoaded) { loadRecent(); window._recentLoaded = true; }
                                    if (target === 'downloads' && !window._downloadsLoaded) { loadDownloads(); window._downloadsLoaded = true; }
                                });
                            });

                            // ===== 搜索过滤 =====
                            var searchInput = document.getElementById('bsSearchInput');
                            if (searchInput) {
                                searchInput.addEventListener('input', function () {
                                    var kw = this.value.trim().toLowerCase();
                                    document.querySelectorAll('.bs-book-card').forEach(function (card) {
                                        if (card.classList.contains('bs-removed')) return;
                                        var title = (card.getAttribute('data-title') || '').toLowerCase();
                                        var author = (card.getAttribute('data-author') || '').toLowerCase();
                                        card.style.display = (!kw || title.indexOf(kw) >= 0 || author.indexOf(kw) >= 0) ? '' : 'none';
                                    });
                                });
                            }

                            // ===== 数据加载函数 =====
                            function fetchBooks(action, grid, empty, statEl, cardType) {
                                grid.innerHTML = '<div class="bs-loading">加载中...</div>';
                                fetch(cp + '/api/bookAction?action=' + action + '&t=' + Date.now(), {
                                    credentials: 'include'
                                })
                                    .then(function (r) { return r.json(); })
                                    .then(function (data) {
                                        var list = data.books || data.bookmarks || [];
                                        if (statEl) statEl.textContent = list.length;
                                        if (!list.length) {
                                            grid.innerHTML = '';
                                            if (empty) empty.style.display = 'block';
                                            return;
                                        }
                                        if (empty) empty.style.display = 'none';
                                        grid.innerHTML = '';
                                        list.forEach(function (b) { grid.appendChild(createBookCard(b, cardType)); });
                                    })
                                    .catch(function () {
                                        grid.innerHTML = '<div class="bs-error">加载失败，请重试</div>';
                                    });
                            }

                            function loadBookmarks() {
                                fetchBooks('bookmarks',
                                    document.getElementById('bookmarkGrid'),
                                    document.getElementById('bookmarkEmpty'),
                                    document.getElementById('statBookmarks').querySelector('.bs-stat-num'),
                                    'bookmark');
                            }

                            window.loadRecent = function () {
                                fetchBooks('recentReads',
                                    document.getElementById('recentGrid'),
                                    document.getElementById('recentEmpty'),
                                    document.getElementById('statRecent').querySelector('.bs-stat-num'),
                                    'recent');
                            };

                            window.loadDownloads = function () {
                                fetchBooks('downloadHistory',
                                    document.getElementById('downloadGrid'),
                                    document.getElementById('downloadEmpty'),
                                    document.getElementById('statDownloads').querySelector('.bs-stat-num'),
                                    'download');
                            };

                            // ===== 创建图书卡片 =====
                            function createBookCard(b, type) {
                                var card = document.createElement('div');
                                card.className = 'bs-book-card';
                                card.setAttribute('data-title', b.bookTitle || b.title || '');
                                card.setAttribute('data-author', b.bookAuthor || b.author || '');
                                var cover = b.bookCover || b.cover || '';
                                var bookId = b.bookId || b.id || '';
                                var title = escapeHtml(b.bookTitle || b.title || '未知图书');
                                var author = escapeHtml(b.bookAuthor || b.author || '未知作者');
                                var coverHtml = cover
                                    ? '<img class="bs-book-cover" src="' + cp + '/' + cover.replace(/^(\.\/|\/)/, '') + '" onerror="this.outerHTML=\'<div class=bs-book-cover-placeholder>📕</div>\'">'
                                    : '<div class="bs-book-cover-placeholder">📕</div>';

                                card.innerHTML =
                                    '<div class="bs-book-cover-wrap">' + coverHtml + '</div>'
                                    + '<div class="bs-book-info">'
                                    + '<div class="bs-book-title">' + title + '</div>'
                                    + '<div class="bs-book-author">' + author + '</div>'
                                    + '<div class="bs-book-actions">'
                                    + '<button class="bs-btn bs-btn-primary" onclick="readBook(\'' + bookId + '\')">阅读</button>'
                                        + (type === 'bookmark'
                                            ? '<button class="bs-btn bs-btn-danger" onclick="removeBookmark(\'' + bookId + '\', this)">取消收藏</button>'
                : '')
                                + '</div>'
                                    + '</div>';

                                card.style.cursor = 'pointer';
                                card.addEventListener('click', function (e) {
                                    if (e.target.closest('.bs-book-actions')) return;
                                    readBook(bookId);
                                });
                                return card;
                            }

                            // ===== 阅读图书 =====
                            window.readBook = function (bookId) {
                                if (!bookId) return;
                                // 记录阅读活动
                                fetch(cp + '/api/bookAction', {
                                    method: 'POST',
                                    credentials: 'include',
                                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                                    body: 'action=logRead&bookId=' + encodeURIComponent(bookId)
                                }).catch(function () { });
                                openInFrame(cp + '/bookDetail?bookId=' + encodeURIComponent(bookId));
                            };

                            // ===== 取消收藏 =====
                            window.removeBookmark = function (bookId, btn) {
                                if (!confirm('确定从收藏中移除？')) return;
                                fetch(cp + '/api/bookAction', {
                                    method: 'POST',
                                    credentials: 'include',
                                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                                    body: 'action=toggleBookmark&bookId=' + encodeURIComponent(bookId)
                                }).then(function (r) { return r.json(); })
                                    .then(function (data) {
                                        if (data.success) {
                                            var card = btn.closest('.bs-book-card');
                                            if (card) {
                                                card.style.display = 'none';
                                                card.classList.add('bs-removed');
                                            }
                                            // 更新统计数字
                                            var statEl = document.getElementById('statBookmarks').querySelector('.bs-stat-num');
                                            var currentCount = parseInt(statEl.textContent, 10) || 0;
                                            statEl.textContent = Math.max(0, currentCount - 1);
                                            showToast('已取消收藏');
                                        }
                                    }).catch(function () { showToast('操作失败', 'error'); });
                            };

                            // ===== Toast =====
                            function showToast(msg, type) {
                                type = type || 'success';
                                var t = document.createElement('div');
                                t.className = 'bs-toast bs-toast-' + type;
                                t.textContent = msg;
                                document.body.appendChild(t);
                                setTimeout(function () { t.classList.add('show'); }, 10);
                                setTimeout(function () { t.classList.remove('show'); setTimeout(function () { t.remove(); }, 300); }, 2500);
                            }

                            // ===== XSS 转义 =====
                            function escapeHtml(s) {
                                if (!s) return '';
                                return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
                            }

                            // ===== 自动加载 =====
                            if (isLoggedIn) {
                                loadBookmarks();
                                // 预加载其他统计
                                fetch(cp + '/api/bookAction?action=recentReads', { credentials: 'include' })
                                    .then(function (r) { return r.json(); })
                                    .then(function (d) {
                                        var n = (d.books || []).length;
                                        document.getElementById('statRecent').querySelector('.bs-stat-num').textContent = n;
                                    }).catch(function () { });
                                fetch(cp + '/api/bookAction?action=downloadHistory', { credentials: 'include' })
                                    .then(function (r) { return r.json(); })
                                    .then(function (d) {
                                        var n = (d.books || []).length;
                                        document.getElementById('statDownloads').querySelector('.bs-stat-num').textContent = n;
                                    }).catch(function () { });
                            }
                        })();
                    </script>
                    <script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
                </body>

                </html>