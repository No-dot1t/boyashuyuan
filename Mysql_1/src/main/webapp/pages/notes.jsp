<%--
 =============================================================================
 notes.jsp  ——  笔记中心
 =============================================================================

 功能：
   1. 创建/编辑/删除笔记
   2. 笔记置顶/搜索
   3. 标签管理

 路由：/notesPage（NotePageServlet 转发）
 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ebookBuy301.pojo.Users" %>
<%
    Users currentUser = (Users) request.getAttribute("currentUser");
    boolean isLoggedIn = (currentUser != null);
    String csrfToken = (String) request.getAttribute("csrfToken");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>笔记中心</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/notes.css?v=20260604">
    <!-- ========== 浅色主题 · 笔记中心全覆盖 ========== -->
    <style>
        /* 容器 + body 底色 */
        html[data-theme$="-light"] body{background:linear-gradient(160deg,#e9e2d2,#ede5d3 40%,#e4dbca)!important;color:#3d3929!important}
        html[data-theme$="-light"] .nt-container{background:linear-gradient(160deg,#e9e2d2,#ede5d3 40%,#e4dbca)!important;color:#3d3929!important}
        /* 头部 */
        html[data-theme$="-light"] .nt-header{background:rgba(238,233,222,.75)!important;border-bottom-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .nt-title{background:linear-gradient(135deg,#3d3929,#2563eb)!important;-webkit-background-clip:text!important;background-clip:text!important;-webkit-text-fill-color:transparent!important}
        html[data-theme$="-light"] .nt-subtitle{color:#7a7360!important}
        /* 搜索 */
        html[data-theme$="-light"] .nt-search-input{background:rgba(238,233,222,.85)!important;border-color:rgba(139,119,80,.1)!important;color:#3d3929!important}
        html[data-theme$="-light"] .nt-search-input:focus{border-color:rgba(37,99,235,.25)!important;background:rgba(245,240,232,.95)!important}
        html[data-theme$="-light"] .nt-search-input::placeholder{color:rgba(61,57,41,.3)!important}
        /* 按钮 */
        html[data-theme$="-light"] .nt-btn-primary{box-shadow:0 2px 8px rgba(37,99,235,.15)!important}
        html[data-theme$="-light"] .nt-btn-primary:hover{box-shadow:0 4px 16px rgba(37,99,235,.25)!important}
        html[data-theme$="-light"] .nt-btn-cancel{background:rgba(139,119,80,.06)!important;color:#7a7360!important;border-color:rgba(139,119,80,.1)!important}
        /* 统计卡片 */
        html[data-theme$="-light"] .nt-stat-item{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .nt-stat-item::before{background:radial-gradient(ellipse at top left,rgba(37,99,235,.05),transparent 60%)!important}
        html[data-theme$="-light"] .nt-stat-item:hover{border-color:rgba(37,99,235,.15)!important;box-shadow:0 6px 24px rgba(139,119,80,.1)!important}
        html[data-theme$="-light"] .nt-stat-val{color:#3d3929!important}
        html[data-theme$="-light"] .nt-stat-lbl{color:#7a7360!important}
        /* 图表卡片 */
        html[data-theme$="-light"] .nt-chart-card{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .nt-chart-card:hover{border-color:rgba(37,99,235,.12)!important}
        html[data-theme$="-light"] .nt-chart-card h3{color:#3d3929!important}
        html[data-theme$="-light"] .nt-chart-sub{color:#7a7360!important}
        /* 分隔标题 */
        html[data-theme$="-light"] .nt-section-title{color:#5c5540!important}
        /* 笔记卡片 */
        html[data-theme$="-light"] .nt-card{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .nt-card::before{background:linear-gradient(90deg,#2563eb,#7c3aed)!important}
        html[data-theme$="-light"] .nt-card:hover{border-color:rgba(37,99,235,.15)!important;box-shadow:0 8px 32px rgba(139,119,80,.12),0 0 20px rgba(37,99,235,.03)!important}
        html[data-theme$="-light"] .nt-card.nt-pinned{background:rgba(37,99,235,.04)!important;border-color:rgba(37,99,235,.15)!important}
        html[data-theme$="-light"] .nt-card-title{color:#3d3929!important}
        html[data-theme$="-light"] .nt-card-preview{color:#7a7360!important}
        /* 卡片操作按钮 */
        html[data-theme$="-light"] .nt-card-btn{background:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .nt-card-btn:hover{background:rgba(139,119,80,.1)!important}
        html[data-theme$="-light"] .nt-card-btn-danger:hover{background:rgba(220,60,60,.12)!important}
        /* 标签 */
        html[data-theme$="-light"] .nt-tag{background:rgba(37,99,235,.07)!important;color:#2563eb!important}
        html[data-theme$="-light"] .nt-card-date{color:rgba(61,57,41,.3)!important}
        /* 空状态/加载 */
        html[data-theme$="-light"] .nt-empty{color:#5c5540!important}
        html[data-theme$="-light"] .nt-empty-hint{color:rgba(61,57,41,.3)!important}
        html[data-theme$="-light"] .nt-loading{color:#5c5540!important}
        /* 弹窗 */
        html[data-theme$="-light"] .nt-modal-content{background:rgba(238,233,222,.97)!important;border-color:rgba(139,119,80,.08)!important;box-shadow:0 20px 60px rgba(139,119,80,.15)!important}
        html[data-theme$="-light"] .nt-modal-header{border-bottom-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .nt-modal-header h2{color:#3d3929!important}
        html[data-theme$="-light"] .nt-modal-footer{border-top-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .nt-modal-close{color:#7a7360!important}
        html[data-theme$="-light"] .nt-modal-close:hover{color:#3d3929!important}
        /* 表单 */
        html[data-theme$="-light"] .nt-field label{color:#5c5540!important}
        html[data-theme$="-light"] .nt-field input,.nt-field textarea{background:rgba(238,233,222,.85)!important;border-color:rgba(139,119,80,.1)!important;color:#3d3929!important}
        html[data-theme$="-light"] .nt-field input:focus,.nt-field textarea:focus{border-color:rgba(37,99,235,.2)!important}
        html[data-theme$="-light"] .nt-field input::placeholder,.nt-field textarea::placeholder{color:rgba(61,57,41,.3)!important}
        /* Toast */
        html[data-theme$="-light"] .nt-toast-success{background:rgba(5,150,105,.1)!important;color:#047857!important;border-color:rgba(5,150,105,.25)!important}
        html[data-theme$="-light"] .nt-toast-error{background:rgba(220,60,60,.1)!important;color:#b91c1c!important;border-color:rgba(220,60,60,.25)!important}
        html[data-theme$="-light"] .nt-toast-info{background:rgba(37,99,235,.1)!important;color:#1d4ed8!important;border-color:rgba(37,99,235,.25)!important}
        /* 通用 */
        html[data-theme$="-light"] svg,html[data-theme$="-light"] [class*="icon"]{color:#5c5540!important;fill:#5c5540!important}
    </style>

    <script src="${pageContext.request.contextPath}/js/echarts.js"></script>
    <script>window.CONTEXT_PATH = '${pageContext.request.contextPath}';</script>
</head>
<body>
<div class="nt-container">
    <!-- 头部 -->
    <header class="nt-header">
        <div class="nt-header-left">
            <h1 class="nt-title">📝 笔记中心</h1>
            <span class="nt-subtitle">记录思考，积累知识</span>
        </div>
        <div class="nt-header-right">
            <div class="nt-search-wrap">
                <input type="text" class="nt-search-input" id="searchInput" placeholder="搜索笔记..." oninput="onSearch()">
                <span class="nt-search-icon">🔍</span>
            </div>
            <button class="nt-btn nt-btn-primary" onclick="openEditor()">+ 新建笔记</button>
        </div>
    </header>

    <!-- 内容区 -->
    <div class="nt-content">
        <% if (!isLoggedIn) { %>
        <div class="nt-empty">
            <div class="nt-empty-icon">🔒</div>
            <p>请先登录后查看笔记</p>
        </div>
        <% } else { %>
        <!-- ═══ 统计仪表盘 ═══ -->
        <div class="nt-stats-bar" id="statsBar" style="display:none;">
            <div class="nt-stat-item">
                <div class="nt-stat-icon" style="background:rgba(125,211,252,.12);color:#7dd3fc;">📝</div>
                <div class="nt-stat-body">
                    <div class="nt-stat-val" id="statTotal">–</div>
                    <div class="nt-stat-lbl">笔记总数</div>
                </div>
            </div>
            <div class="nt-stat-item">
                <div class="nt-stat-icon" style="background:rgba(167,139,250,.12);color:#a78bfa;">📌</div>
                <div class="nt-stat-body">
                    <div class="nt-stat-val" id="statPinned">–</div>
                    <div class="nt-stat-lbl">已置顶</div>
                </div>
            </div>
            <div class="nt-stat-item">
                <div class="nt-stat-icon" style="background:rgba(52,211,153,.12);color:#34d399;">📅</div>
                <div class="nt-stat-body">
                    <div class="nt-stat-val" id="statWeek">–</div>
                    <div class="nt-stat-lbl">本周新增</div>
                </div>
            </div>
            <div class="nt-stat-item">
                <div class="nt-stat-icon" style="background:rgba(251,191,36,.12);color:#fbbf24;">📄</div>
                <div class="nt-stat-body">
                    <div class="nt-stat-val" id="statChars">–</div>
                    <div class="nt-stat-lbl">总字数</div>
                </div>
            </div>
        </div>

        <!-- ═══ ECharts 图表区 ═══ -->
        <div class="nt-charts" id="chartsArea" style="display:none;">
            <div class="nt-chart-card nt-chart-wide">
                <h3>📈 近两周笔记趋势</h3>
                <div class="nt-chart-sub">每日新建笔记数量</div>
                <div id="chartTrend" class="nt-chart-box" style="height:200px;"></div>
            </div>
            <div class="nt-chart-card">
                <h3>🏷️ 标签分布</h3>
                <div class="nt-chart-sub">最常用的知识标签</div>
                <div id="chartTag" class="nt-chart-box" style="height:220px;"></div>
            </div>
            <div class="nt-chart-card">
                <h3>📏 内容长度</h3>
                <div class="nt-chart-sub">笔记字数分布</div>
                <div id="chartLen" class="nt-chart-box" style="height:220px;"></div>
            </div>
        </div>

        <div class="nt-section-title">📋 我的笔记</div>
        <div class="nt-grid" id="noteGrid">
            <div class="nt-loading">加载中...</div>
        </div>
        <% } %>
    </div>
</div>

<!-- 笔记编辑器弹窗 -->
<div class="nt-modal" id="noteEditor">
    <div class="nt-modal-overlay" onclick="closeEditor()"></div>
    <div class="nt-modal-content">
        <div class="nt-modal-header">
            <h2 id="editorTitle">新建笔记</h2>
            <button class="nt-modal-close" onclick="closeEditor()">✕</button>
        </div>
        <div class="nt-modal-body">
            <input type="hidden" id="editNoteId">
            <div class="nt-field">
                <label>标题</label>
                <input type="text" id="noteTitle" placeholder="输入笔记标题..." maxlength="200">
            </div>
            <div class="nt-field">
                <label>标签（逗号分隔）</label>
                <input type="text" id="noteTags" placeholder="如：Java, 算法, 深度学习" maxlength="500">
            </div>
            <div class="nt-field">
                <label>内容</label>
                <textarea id="noteContent" placeholder="输入笔记内容..." rows="10"></textarea>
            </div>
        </div>
        <div class="nt-modal-footer">
            <button class="nt-btn nt-btn-cancel" onclick="closeEditor()">取消</button>
            <button class="nt-btn nt-btn-primary" onclick="saveNote()">保存笔记</button>
        </div>
    </div>
</div>

<!-- Toast -->
<div class="nt-toast" id="ntToast"></div>

<script>
var searchTimer = null;
var currentNotes = [];
var _csrfToken = '<%= csrfToken != null ? csrfToken : "" %>';

// 拼接上下文路径（兼容不同的部署路径）
function apiUrl(path) {
    var ctx = window.CONTEXT_PATH || '';
    return ctx + path;
}

// 给 POST 请求体附加 CSRF Token
function csrfBody(body) {
    return body + '&csrfToken=' + encodeURIComponent(_csrfToken);
}

// 页面加载
document.addEventListener('DOMContentLoaded', function() {
    <% if (isLoggedIn) { %>
    loadNotes();
    loadStats();
    <% } %>
    // ESC 关闭弹窗
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeEditor();
    });
    // resize 时图表自适应
    window.addEventListener('resize', function() {
        [chartTrendInst, chartTagInst, chartLenInst].forEach(function(c) {
            if (c && !c.isDisposed()) c.resize();
        });
    });
});

function loadNotes() {
    var grid = document.getElementById('noteGrid');
    grid.innerHTML = '<div class="nt-loading">加载中...</div>';
    fetch(apiUrl('/notesPage?action=list'))
        .then(function(r) { return r.json(); })
        .then(function(data) {
            currentNotes = data.notes || [];
            renderNotes(currentNotes);
        })
        .catch(function() { grid.innerHTML = '<div class="nt-empty"><p>加载失败</p></div>'; });
}

function onSearch() {
    clearTimeout(searchTimer);
    searchTimer = setTimeout(function() {
        var q = document.getElementById('searchInput').value.trim();
        if (!q) { loadNotes(); return; }
        fetch(apiUrl('/notesPage?action=search&q=' + encodeURIComponent(q)))
            .then(function(r) { return r.json(); })
            .then(function(data) {
                currentNotes = data.notes || [];
                renderNotes(currentNotes);
            });
    }, 300);
}

function renderNotes(notes) {
    var grid = document.getElementById('noteGrid');
    if (!notes || notes.length === 0) {
        grid.innerHTML = '<div class="nt-empty"><div class="nt-empty-icon">📭</div><p>暂无笔记</p><p class="nt-empty-hint">点击"新建笔记"开始记录</p></div>';
        return;
    }
    var html = '';
    notes.forEach(function(n) {
        var tags = (n.tags || '').split(',').filter(Boolean);
        var tagsHtml = tags.map(function(t) { return '<span class="nt-tag">#' + escHtml(t.trim()) + '</span>'; }).join('');
        var preview = (n.content || '').substring(0, 150).replace(/\n/g, ' ');
        html += '<div class="nt-card' + (n.isPinned ? ' nt-pinned' : '') + '" onclick="openEditor(' + n.id + ')">';
        if (n.isPinned) html += '<span class="nt-pin-badge">📌</span>';
        html += '<div class="nt-card-header">';
        html += '<h3 class="nt-card-title">' + escHtml((n.title || '').replace(/\n/g, ' ')) + '</h3>';
        html += '<div class="nt-card-actions" onclick="event.stopPropagation()">';
        html += '<button class="nt-card-btn" title="置顶" onclick="togglePin(' + n.id + ')">📌</button>';
        html += '<button class="nt-card-btn nt-card-btn-danger" title="删除" onclick="deleteNote(' + n.id + ')">🗑</button>';
        html += '</div></div>';
        html += '<p class="nt-card-preview">' + escHtml(preview) + (n.content && n.content.length > 150 ? '...' : '') + '</p>';
        html += '<div class="nt-card-footer">';
        html += '<div class="nt-card-tags">' + tagsHtml + '</div>';
        html += '<span class="nt-card-date">' + formatDate(n.updatedAt || n.createdAt) + '</span>';
        html += '</div></div>';
    });
    grid.innerHTML = html;
}

function openEditor(noteId) {
    var editor = document.getElementById('noteEditor');
    if (noteId) {
        var note = currentNotes.find(function(n) { return n.id === noteId; });
        if (note) {
            document.getElementById('editorTitle').textContent = '编辑笔记';
            document.getElementById('editNoteId').value = note.id;
            document.getElementById('noteTitle').value = note.title || '';
            document.getElementById('noteTags').value = note.tags || '';
            document.getElementById('noteContent').value = note.content || '';
            editor.classList.add('active');
        } else {
            showToast('笔记数据未找到，请刷新后重试', 'error');
        }
    } else {
        document.getElementById('editorTitle').textContent = '新建笔记';
        document.getElementById('editNoteId').value = '';
        document.getElementById('noteTitle').value = '';
        document.getElementById('noteTags').value = '';
        document.getElementById('noteContent').value = '';
        editor.classList.add('active');
    }
}

function closeEditor() {
    document.getElementById('noteEditor').classList.remove('active');
}

var saving = false;

function saveNote() {
    if (saving) return;
    var noteId = document.getElementById('editNoteId').value;
    var title = document.getElementById('noteTitle').value.trim();
    var content = document.getElementById('noteContent').value;
    var tags = document.getElementById('noteTags').value.trim();
    if (!title) { showToast('请输入笔记标题', 'error'); return; }

    saving = true;
    var action = noteId ? 'update' : 'add';
    var body = csrfBody('action=' + action + '&title=' + encodeURIComponent(title) + '&content=' + encodeURIComponent(content) + '&tags=' + encodeURIComponent(tags));
    if (noteId) body += '&noteId=' + encodeURIComponent(noteId);

    fetch(apiUrl('/notesPage'), { method: 'POST', headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: body })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            saving = false;
            if (data.success) {
                showToast(noteId ? '笔记已更新' : '笔记已创建', 'success');
                closeEditor();
                loadNotes();
            } else {
                showToast(data.message || '操作失败', 'error');
            }
        })
        .catch(function() {
            saving = false;
            showToast('网络错误', 'error');
        });
}

function togglePin(noteId) {
    fetch(apiUrl('/notesPage'), { method: 'POST', headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: csrfBody('action=togglePin&noteId=' + noteId) })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) { showToast('操作成功', 'success'); loadNotes(); }
            else { showToast(data.message || '操作失败', 'error'); }
        });
}

function deleteNote(noteId) {
    if (!confirm('确定要删除这条笔记吗？')) return;
    fetch(apiUrl('/notesPage'), { method: 'POST', headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: csrfBody('action=delete&noteId=' + noteId) })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) { showToast('笔记已删除', 'success'); loadNotes(); }
            else { showToast(data.message || '删除失败', 'error'); }
        });
}

// ========== 图表实例 ==========
var chartTrendInst = null;
var chartTagInst = null;
var chartLenInst = null;

// ========== 加载统计数据 ==========
function loadStats() {
    fetch(apiUrl('/notesPage?action=stats'))
        .then(function(r) { return r.json(); })
        .then(function(d) {
            if (!d.success) return;
            var s = d.summary;
            // 填充统计卡片
            document.getElementById('statTotal').textContent = (s.totalNotes || 0) + ' 篇';
            document.getElementById('statPinned').textContent = (s.pinnedCount || 0) + ' 篇';
            document.getElementById('statWeek').textContent = (s.weekCount || 0) + ' 篇';
            var chars = s.totalChars || 0;
            document.getElementById('statChars').textContent = chars >= 1000 ? (chars/1000).toFixed(1) + 'k' : chars;
            // 显示统计区
            document.getElementById('statsBar').style.display = 'flex';
            document.getElementById('chartsArea').style.display = 'grid';
            // 渲染图表
            if (typeof echarts !== 'undefined') {
                renderTrendChart(d.dailyTrend || []);
                renderTagChart(d.tagDistribution || []);
                renderLenChart(d.lengthDistribution || []);
            }
        }).catch(function(){});
}

// ========== 趋势折线图 ==========

// ══════ 图表主题辅助（区分浅色/深色，高对比度 · 暴力加深版） ══════
function _ct(){
    // ★ 多层判断，避免 iframe 环境下 data-theme 未传递到子页面
    var _theme = (document.documentElement.getAttribute('data-theme')||'');
    try { if (window.parent && window.parent.document) { var _pt = window.parent.document.documentElement.getAttribute('data-theme'); if (_pt) _theme = _pt; } } catch(e){}
    var isLight = _theme.indexOf('-light') > -1;
    // ★ fallback：data-theme 为空时，用背景色亮度判断
    if (!isLight && !_theme) { try { var _bg = getComputedStyle(document.body).backgroundColor; var _m = _bg.match(/(\d+),\s*(\d+),\s*(\d+)/); if (_m) { var _br = (parseInt(_m[1])*299+parseInt(_m[2])*587+parseInt(_m[3])*114)/1000; if (_br > 150) isLight = true; } } catch(e){} }
    if (isLight) {
        return {
            ttBg: 'rgba(255,255,255,.98)',
            ttBd: 'rgba(37,99,235,.40)',
            ttTx: '#1a1815',
            ax1: '#1a1815',
            ax2: '#3d3929',
            ax3: '#6a6358',
            gr:  'rgba(26,24,20,.28)',
            gr2: 'rgba(26,24,20,.38)',
            pb:  '#ffffff',
            gt:  'rgba(26,24,20,.12)',
            dr:  'rgba(26,24,20,.08)',
            mu:  '#3d3929'
        };
    }
    return{
        ttBg:'rgba(20,25,45,.95)',
        ttBd:'rgba(0,245,255,.25)',
        ttTx:'#e5e9f0',
        ax1:'#e5e9f0',
        ax2:'#8a8370',
        ax3:'#7a7360',
        gr:'rgba(255,255,255,.08)',
        gr2:'rgba(255,255,255,.12)',
        pb:'#0d1525',
        gt:'rgba(255,255,255,.06)',
        dr:'rgba(255,255,255,.04)',
        mu:'#8a8370'
    };
}
function renderTrendChart(dailyTrend) {
    var dom = document.getElementById('chartTrend');
    if (!dom) return;
    if (chartTrendInst) chartTrendInst.dispose();
    chartTrendInst = echarts.init(dom, null, { devicePixelRatio: window.devicePixelRatio||1, renderer:'canvas' });

    // 补全 14 天数据
    var dates = [], counts = [];
    var endDate = new Date();
    for (var i = 13; i >= 0; i--) {
        var d = new Date(endDate);
        d.setDate(d.getDate() - i);
        var ds = d.getFullYear() + '-' + pad(d.getMonth()+1) + '-' + pad(d.getDate());
        dates.push(ds.substring(5)); // MM-DD
        // 查找当天数据
        var found = dailyTrend.find(function(item) { return item.date === ds; });
        counts.push(found ? found.count : 0);
    }

    var isLight = (document.documentElement.getAttribute('data-theme')||'').indexOf('-light') > -1;
    // 浅色用深蓝系实色（高饱和），深色用天蓝
    var barColor = isLight ? '#1d4ed8' : '#7dd3fc';
    var barFade  = isLight ? 'rgba(29,78,216,.45)' : 'rgba(125,211,252,.15)';
    var lineColor = isLight ? '#c2410c' : '#f59e0b';
    // 浅色用更粗的线条和更大的符号
    var lWidth   = isLight ? 2.5 : 1.5;
    var symSize  = isLight ? 8   : 6;

    chartTrendInst.setOption({
        tooltip: {
            backgroundColor: _ct().ttBg,
            borderColor: _ct().ttBd,
            textStyle: { color:_ct().ttTx,fontSize:12 },
            trigger: 'axis',
            formatter: function(p) { return p[0].axisValue + '<br/>📝 ' + p[0].value + ' 篇笔记'; }
        },
        grid: { top:12, right:14, bottom:20, left:36 },
        xAxis: {
            type: 'category', data: dates,
            axisLine: { lineStyle:{ color:_ct().gr2, width:1 } },
            axisTick: { show:false },
            axisLabel: { color:_ct().ax1, fontSize:10, rotate:30, fontWeight:600 }
        },
        yAxis: {
            type: 'value', minInterval: 1,
            splitLine: { lineStyle:{ color:_ct().gr, type:'dashed' } },
            axisLabel: { color:_ct().ax1, fontSize:10, fontWeight:600 }
        },
        series: [{
            type: 'bar',
            data: counts,
            barWidth: 16,
            itemStyle: {
                borderRadius: [6,6,0,0],
                color: new echarts.graphic.LinearGradient(0,0,0,1, [
                    {offset:0, color: barColor}, {offset:1, color: barFade}
                ])
            },
            emphasis: {
                itemStyle: { color: lineColor, shadowBlur:14, shadowColor: barColor + '60' }
            }
        }, {
            type: 'line',
            data: counts,
            smooth: true,
            symbol: 'circle', symbolSize: symSize,
            lineStyle: { color: lineColor, width: lWidth },
            itemStyle: { color: lineColor, borderColor:_ct().pb, borderWidth: 2 },
            z: 1
        }]
    });
}

// ========== 标签分布环形图 ==========
function renderTagChart(tagDist) {
    var dom = document.getElementById('chartTag');
    if (!dom) return;
    if (chartTagInst) chartTagInst.dispose();
    chartTagInst = echarts.init(dom, null, { devicePixelRatio: window.devicePixelRatio||1, renderer:'canvas' });

    if (!tagDist || tagDist.length === 0) {
        chartTagInst.setOption({
            title: { text:'暂无标签', left:'center', top:'45%',
                textStyle:{ color:_ct().ax1, fontSize:13, fontWeight:400 } }
        });
        return;
    }

    // ★ 浅色主题必须用高饱和深色系，pastel在浅背景上会融入
    var isLt = (document.documentElement.getAttribute('data-theme')||'').indexOf('-light') > -1;
    var colors = isLt
        ? ['#1d4ed8','#7c3aed','#059669','#dc2626','#0891b2','#4f46e5','#16a34a','#db2777','#0e7490','#9333ea']
        : ['#7dd3fc','#a78bfa','#f59e0b','#34d399','#f472b6','#38bdf8','#fb923c','#818cf8','#2dd4bf','#e879f9'];
    chartTagInst.setOption({
        tooltip: {
            backgroundColor: _ct().ttBg,
            borderColor: _ct().ttBd,
            textStyle: { color:_ct().ttTx,fontSize:12, fontWeight:600 },
            trigger: 'item',
            formatter: '{b}: {c} 次 ({d}%)'
        },
        legend: {
            orient: 'vertical', right: 6, top: 'center',
            textStyle: { color:_ct().ax2, fontSize:10, fontWeight:500 },
            itemWidth: 10, itemHeight: 10, itemGap: 8
        },
        color: colors,
        series: [{
            type: 'pie',
            radius: ['50%', '78%'],
            center: ['35%', '50%'],
            data: tagDist,
            label: { show:false },
            emphasis: {
                label: { show:true, fontSize:14, fontWeight:'bold', color:_ct().ttTx },
                itemStyle: { shadowBlur:16, shadowColor:_ct().ttBd }
            },
            itemStyle: { borderColor:_ct().pb, borderWidth:2, borderRadius:4 }
        }]
    });
}

// ========== 内容长度横向柱状图 ==========
function renderLenChart(lenDist) {
    var dom = document.getElementById('chartLen');
    if (!dom) return;
    if (chartLenInst) chartLenInst.dispose();
    chartLenInst = echarts.init(dom, null, { devicePixelRatio: window.devicePixelRatio||1, renderer:'canvas' });

    if (!lenDist || lenDist.length === 0) {
        chartLenInst.setOption({
            title: { text:'暂无数据', left:'center', top:'45%',
                textStyle:{ color:_ct().ax1, fontSize:13, fontWeight:400 } }
        });
        return;
    }

    var labels = lenDist.map(function(d){ return d.label; });
    var values = lenDist.map(function(d){ return d.count; });
    var maxVal = Math.max.apply(null, values) || 1;

    chartLenInst.setOption({
        tooltip: {
            backgroundColor: _ct().ttBg,
            borderColor: _ct().ttBd,
            textStyle: { color:_ct().ttTx,fontSize:12 },
            formatter: '{b}: {c} 篇'
        },
        grid: { top:8, right:20, bottom:14, left:100, containLabel:true },
        xAxis: {
            type: 'value', minInterval: 1,
            max: Math.ceil(maxVal * 1.3) || 5,
            splitLine: { lineStyle:{ color:_ct().gr } },
            axisLabel: { color:_ct().ax1, fontSize:10, formatter:'{value} 篇' }
        },
        yAxis: {
            type: 'category', data: labels,
            axisLine: { lineStyle:{ color:_ct().gr2 } },
            axisTick: { show:false },
            axisLabel: { color:_ct().ax2, fontSize:11 }
        },
        series: [{
            type: 'bar',
            data: values.map(function(v, i) {
                var isLt = (document.documentElement.getAttribute('data-theme')||'').indexOf('-light') > -1;
                // ★ 深色高饱和色板 + 加深的渐变尾端
                var barColors = isLt
                    ? ['#059666','#1d4ed8','#7c3aed','#dc2626']
                    : ['#34d399','#7dd3fc','#a78bfa','#f472b6'];
                var fadeColor = isLt
                    ? 'rgba(26,24,20,.30)'
                    : 'rgba(125,211,252,.08)';
                return { value:v, itemStyle:{ color:new echarts.graphic.LinearGradient(0,0,1,0, [
                    {offset:0, color:barColors[i]||'#1d4ed8'}, {offset:1, color:fadeColor}
                ]), borderRadius:[0,6,6,0] } };
            }),
            barWidth: 18,
            label: { show:true, position:'right', color:_ct().ax1, fontSize:11, fontWeight:'600', formatter:'{c}' },
            emphasis: {
                itemStyle: { shadowBlur:12, shadowColor:_ct().ttBd }
            }
        }]
    });
}

function formatDate(dateStr) {
    if (!dateStr) return '';
    try {
        var d = new Date(dateStr);
        if (isNaN(d.getTime())) return '';
        return d.getFullYear() + '-' + pad(d.getMonth()+1) + '-' + pad(d.getDate());
    } catch(e) { return ''; }
}

function pad(n) { return n < 10 ? '0' + n : n; }

function escHtml(s) {
    if (!s) return '';
    return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function showToast(msg, type) {
    var t = document.getElementById('ntToast');
    t.textContent = msg;
    t.className = 'nt-toast nt-toast-' + (type || 'info') + ' nt-toast-show';
    setTimeout(function() { t.className = 'nt-toast'; }, 2000);
}
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);setTimeout(function(){location.reload()},250);}});})();
</script>
</body>
</html>
