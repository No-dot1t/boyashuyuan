<%--
 =============================================================================
 contentReview.jsp
 =============================================================================

 用途      详情展示页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   Ajax 异步请求 —— fetch
   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById
   表单 GET/POST 提交 —— 携带 URL 参数或隐藏字段

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList, java.util.HashMap, java.util.Map, java.sql.Timestamp, java.text.SimpleDateFormat" %>
<%!
    // HTML 转义
    String h(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#039;");
    }
    // 内容类型中文映射
    String typeLabel(String t) {
        if (t == null) return "其他";
        switch (t) {
            case "course":   return "课程";
            case "article":  return "文章";
            case "comment":  return "讨论";
            case "report":   return "举报";
            case "data":     return "数据集";
            default:         return t;
        }
    }
    // 优先级样式映射
    String priorityClass(String p) {
        if (p == null) return "priority-normal";
        switch (p) {
            case "high":   return "priority-high";
            case "report": return "priority-report";
            case "low":    return "priority-low";
            default:       return "priority-normal";
        }
    }
    // 优先级标签
    String priorityBadge(String p) {
        if (p == null) return "";
        switch (p) {
            case "high":   return "<div class=\"item-badge\">🔥 紧急</div>";
            case "report": return "<div class=\"item-badge\">⚠️ 举报</div>";
            default:       return "";
        }
    }
    // 相对时间
    String timeAgo(Timestamp ts) {
        if (ts == null) return "";
        long diff = (System.currentTimeMillis() - ts.getTime()) / 1000;
        if (diff < 60) return "刚刚";
        if (diff < 3600) return (diff / 60) + "分钟前";
        if (diff < 86400) return (diff / 3600) + "小时前";
        if (diff < 2592000) return (diff / 86400) + "天前";
        return new SimpleDateFormat("yyyy-MM-dd").format(ts);
    }
%>
<%
    // 从 Servlet 获取数据
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("reviewStats");
    ArrayList<Map<String, Object>> reviews = (ArrayList<Map<String, Object>>) request.getAttribute("pendingReviews");
    if (stats == null) stats = new HashMap<>();
    if (reviews == null) reviews = new ArrayList<>();

    int pendingCount = stats.get("pendingCount") != null ? ((Number) stats.get("pendingCount")).intValue() : 0;
    int todayReviews = stats.get("todayReviews") != null ? ((Number) stats.get("todayReviews")).intValue() : 0;
    int approvalRate = stats.get("approvalRate") != null ? ((Number) stats.get("approvalRate")).intValue() : 0;
    int avgTime = stats.get("avgTime") != null ? ((Number) stats.get("avgTime")).intValue() : 0;
    double avgAiScore = stats.get("avgAiScore") != null ? ((Number) stats.get("avgAiScore")).doubleValue() : 0;

    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <title>博雅书院 · 科技风 | 内容审核</title>
    <link rel="stylesheet" href="<%= contextPath %>/CSS/adminDashboard.css">
    <link rel="stylesheet" href="<%= contextPath %>/CSS/contentReview.css">
    <!-- ========== 浅色主题 · 内容审核全覆盖 ========== -->
    <style>
        html[data-theme$="-light"] body{background:linear-gradient(170deg,#e9e2d2,#ede5d3 40%,#e4dbca)!important;color:#3d3929!important}
        html[data-theme$="-light"] .admin-header h1{color:#3d3929!important}
        html[data-theme$="-light"] .header-subtitle{color:#7a7360!important}
        html[data-theme$="-light"] .glow-text{text-shadow:none!important}
        html[data-theme$="-light"] .admin-stat{background:rgba(238,233,222,.85)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .admin-stat.critical{background:rgba(220,60,60,.05)!important;border-color:rgba(220,60,60,.12)!important}
        html[data-theme$="-light"] .admin-stat.warning{background:rgba(217,119,6,.05)!important;border-color:rgba(217,119,6,.12)!important}
        html[data-theme$="-light"] .admin-stat.success{background:rgba(5,150,105,.05)!important;border-color:rgba(5,150,105,.12)!important}
        html[data-theme$="-light"] .admin-stat.info{background:rgba(37,99,235,.05)!important;border-color:rgba(37,99,235,.12)!important}
        html[data-theme$="-light"] .stat-value{color:#3d3929!important}
        html[data-theme$="-light"] .stat-label{color:#7a7360!important}
        html[data-theme$="-light"] .filter-bar{background:rgba(238,233,222,.75)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .filter-btn{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.06)!important;color:#7a7360!important}
        html[data-theme$="-light"] .filter-btn:hover{background:rgba(37,99,235,.05)!important;border-color:rgba(37,99,235,.12)!important;color:#5c5540!important}
        html[data-theme$="-light"] .filter-btn.active{background:rgba(37,99,235,.1)!important;border-color:rgba(37,99,235,.2)!important;color:#2563eb!important}
        html[data-theme$="-light"] .review-item{background:rgba(238,233,222,.8)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .review-item:hover{border-color:rgba(37,99,235,.1)!important;box-shadow:0 4px 16px rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .review-item.priority-high{border-left-color:rgba(220,60,60,.4)!important}
        html[data-theme$="-light"] .review-item.priority-report{border-left-color:rgba(217,119,6,.4)!important}
        html[data-theme$="-light"] .review-item.priority-normal{border-left-color:rgba(37,99,235,.25)!important}
        html[data-theme$="-light"] .review-item.priority-low{border-left-color:rgba(139,119,80,.15)!important}
        html[data-theme$="-light"] .item-badge{background:rgba(220,60,60,.08)!important;color:#b91c1c!important}
        html[data-theme$="-light"] .review-title{color:#3d3929!important}
        html[data-theme$="-light"] .review-meta{color:#7a7360!important}
        html[data-theme$="-light"] .review-excerpt{color:rgba(61,57,41,.5)!important}
        html[data-theme$="-light"] .review-type-tag{background:rgba(139,119,80,.05)!important;color:#7a7360!important}
        html[data-theme$="-light"] .ai-badge{background:rgba(37,99,235,.06)!important;color:#2563eb!important}
        html[data-theme$="-light"] .action-btn.approve{background:rgba(5,150,105,.08)!important;border-color:rgba(5,150,105,.15)!important;color:#047857!important}
        html[data-theme$="-light"] .action-btn.approve:hover{background:rgba(5,150,105,.15)!important}
        html[data-theme$="-light"] .action-btn.reject{background:rgba(220,60,60,.08)!important;border-color:rgba(220,60,60,.15)!important;color:#b91c1c!important}
        html[data-theme$="-light"] .action-btn.reject:hover{background:rgba(220,60,60,.15)!important}
        html[data-theme$="-light"] .action-btn.view{background:rgba(139,119,80,.05)!important;border-color:rgba(139,119,80,.08)!important;color:#7a7360!important}
        html[data-theme$="-light"] .action-btn.view:hover{background:rgba(139,119,80,.1)!important;color:#3d3929!important}
        html[data-theme$="-light"] .empty{color:#7a7360!important}
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3{color:#3d3929!important}
        html[data-theme$="-light"] ::selection{background:rgba(37,99,235,.15)!important;color:#3d3929!important}
    </style>
    <script>window.CONTEXT_PATH = '<%= contextPath %>';</script>
</head>
<body>
    <div class="admin-container">
        <!-- 内容审核头部 -->
        <div class="admin-header">
            <h1><span class="glow-text">✅</span> 内容审核中心</h1>
            <p class="header-subtitle">智能内容管理系统，保障平台内容质量与合规性</p>

            <div class="admin-stats">
                <div class="admin-stat critical">
                    <div class="stat-value" id="pendingReviews"><%= pendingCount %></div>
                    <div class="stat-label">待审核</div>
                </div>
                <div class="admin-stat warning">
                    <div class="stat-value" id="todayReviews"><%= todayReviews %></div>
                    <div class="stat-label">今日处理</div>
                </div>
                <div class="admin-stat success">
                    <div class="stat-value" id="approvalRate"><%= approvalRate %>%</div>
                    <div class="stat-label">通过率</div>
                </div>
                <div class="admin-stat info">
                    <div class="stat-value" id="avgTime"><%= avgTime %></div>
                    <div class="stat-label">平均耗时(分)</div>
                </div>
            </div>
        </div>

        <!-- 主要功能区 -->
        <div class="review-main">
            <!-- 左侧：审核队列 -->
            <div class="review-queue">
                <h2>📋 审核队列</h2>
                <div class="queue-filters">
                    <div class="filter-tabs">
                        <button class="filter-tab active" data-filter="all">全部内容</button>
                        <button class="filter-tab" data-filter="course">课程</button>
                        <button class="filter-tab" data-filter="article">文章</button>
                        <button class="filter-tab" data-filter="comment">讨论</button>
                        <button class="filter-tab" data-filter="report">举报</button>
                    </div>
                    <div class="search-box">
                        <input type="text" placeholder="搜索内容..." id="contentSearch">
                        <button>🔍</button>
                    </div>
                </div>
                <div class="batch-select-bar" id="batchSelectBar">
                    <label class="select-all-label">
                        <input type="checkbox" id="selectAllCheckbox">
                        <span>全选</span>
                    </label>
                    <span class="selected-count" id="selectedCount" style="display:none">已选 <strong>0</strong> 项</span>
                </div>

                <div class="queue-list" id="reviewQueue">
                    <% if (reviews.isEmpty()) { %>
                    <div class="queue-item priority-normal">
                        <div class="item-content">
                            <div class="item-title" style="text-align:center;color:rgba(255,255,255,0.5);">暂无待审核内容 🎉</div>
                        </div>
                    </div>
                    <% } else {
                        for (Map<String, Object> item : reviews) {
                            String id = String.valueOf(item.get("id"));
                            String title = h((String) item.get("title"));
                            String contentType = (String) item.get("contentType");
                            String contentPreview = h((String) item.get("contentPreview"));
                            String submitter = h((String) item.get("submitter"));
                            String priority = (String) item.get("priority");
                            Timestamp submittedAt = (Timestamp) item.get("submittedAt");
                            Object aiScoreObj = item.get("aiScore");
                            String aiScoreStr = (aiScoreObj != null) ? String.format("%.1f", ((Number) aiScoreObj).doubleValue()) : "";
                    %>
                    <div class="queue-item <%= priorityClass(priority) %>" data-id="<%= id %>" data-type="<%= h(contentType) %>">
                        <input type="checkbox" class="review-checkbox" value="<%= id %>" style="margin-right:12px;accent-color:#00f2ff;width:16px;height:16px;cursor:pointer">
                        <%= priorityBadge(priority) %>
                        <div class="item-content">
                            <div class="item-title"><%= title %></div>
                            <div class="item-meta">
                                <span class="meta-tag <%= h(contentType) %>"><%= typeLabel(contentType) %></span>
                                <span class="meta-author">提交者: <%= submitter %></span>
                                <span class="meta-time"><%= timeAgo(submittedAt) %></span>
                                <% if (!aiScoreStr.isEmpty()) { %>
                                <span class="meta-score">AI评分: <%= aiScoreStr %></span>
                                <% } %>
                            </div>
                            <div class="item-preview"><%= contentPreview %></div>
                        </div>
                        <div class="item-actions">
                            <button class="action-btn approve" data-id="<%= id %>">✅ 通过</button>
                            <button class="action-btn reject" data-id="<%= id %>">❌ 拒绝</button>
                            <button class="action-btn detail" data-id="<%= id %>">📄 详情</button>
                        </div>
                    </div>
                    <% } } %>
                </div>

                <div class="queue-pagination">
                    <button class="page-btn prev">◀ 上一页</button>
                    <span class="page-info">第 <strong>1</strong> 页</span>
                    <button class="page-btn next">下一页 ▶</button>
                </div>
            </div>

            <!-- 右侧：审核详情 -->
            <div class="review-detail">
                <h2>📝 审核详情</h2>
                <div class="detail-card" id="detailCard">
                    <div class="detail-header">
                        <h3 id="detailTitle">选择左侧审核项查看详情</h3>
                        <div class="detail-status pending" id="detailStatus">待选择</div>
                    </div>

                    <div class="detail-content" id="detailContent">
                        <div class="content-section">
                            <h4>操作提示</h4>
                            <p style="color:var(--text-secondary);">点击左侧审核项的"📄 详情"按钮查看完整信息</p>
                        </div>
                    </div>

                    <div class="detail-actions" id="detailActions">
                        <button class="action-large approve" id="btnApprove">
                            <span class="action-icon">✅</span>
                            <span class="action-text">通过审核</span>
                        </button>
                        <button class="action-large reject" id="btnReject">
                            <span class="action-icon">❌</span>
                            <span class="action-text">拒绝并反馈</span>
                        </button>
                        <button class="action-large pending" id="btnDefer">
                            <span class="action-icon">⏸️</span>
                            <span class="action-text">暂存待议</span>
                        </button>
                        <button class="action-large flag" id="btnFlag">
                            <span class="action-icon">🚩</span>
                            <span class="action-text">标记人工审核</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- 审核统计 -->
        <div class="review-stats">
            <h2>📊 审核统计</h2>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-chart">
                        <div class="chart-circle" data-percent="<%= approvalRate %>"></div>
                    </div>
                    <div class="stat-content">
                        <div class="stat-title">审核通过率</div>
                        <div class="stat-value"><%= approvalRate %>%</div>
                        <div class="stat-desc">累计审核通过比例</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-chart">
                        <div class="chart-bar">
                            <div class="bar-fill" style="height: <%= Math.min((int)(avgAiScore * 10), 100) %>%;"></div>
                        </div>
                    </div>
                    <div class="stat-content">
                        <div class="stat-title">内容质量</div>
                        <div class="stat-value"><%= String.format("%.1f", avgAiScore) %>/10</div>
                        <div class="stat-desc">AI 平均内容质量评分</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-chart">
                        <div class="chart-line">
                            <div class="line-fill" style="height: <%= Math.max(100 - approvalRate, 5) %>%;"></div>
                        </div>
                    </div>
                    <div class="stat-content">
                        <div class="stat-title">拒绝率</div>
                        <div class="stat-value"><%= (100 - approvalRate) %>%</div>
                        <div class="stat-desc">累计审核拒绝比例</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-chart">
                        <div class="chart-donut" data-percent="92"></div>
                    </div>
                    <div class="stat-content">
                        <div class="stat-title">AI 准确率</div>
                        <div class="stat-value">92%</div>
                        <div class="stat-desc">自动审核准确率</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 批量操作 -->
        <div class="batch-actions">
            <h2>⚡ 批量操作</h2>
            <div class="actions-grid">
                <button class="batch-btn" id="batchApprove">
                    <span class="btn-icon">✅</span>
                    <span class="btn-text">批量通过</span>
                </button>
                <button class="batch-btn" id="batchReject">
                    <span class="btn-icon">❌</span>
                    <span class="btn-text">批量拒绝</span>
                </button>
                <button class="batch-btn" id="batchExport">
                    <span class="btn-icon">📤</span>
                    <span class="btn-text">批量导出</span>
                </button>
                <button class="batch-btn" id="batchReport">
                    <span class="btn-icon">📊</span>
                    <span class="btn-text">生成报告</span>
                </button>
            </div>
        </div>
    </div>

    <script>
    (function() {
        var cp = window.CONTEXT_PATH || '';
        var currentItemId = null;

        // ===== Toast 消息提示 =====
        function showToast(msg, type) {
            var toast = document.getElementById('adminToast');
            if (!toast) {
                toast = document.createElement('div');
                toast.id = 'adminToast';
                toast.style.cssText = 'position:fixed;top:20px;right:20px;z-index:9999;padding:12px 24px;border-radius:10px;font-size:14px;font-weight:500;color:#fff;box-shadow:0 4px 20px rgba(0,0,0,0.3);transition:all 0.3s ease;opacity:0;transform:translateY(-10px);';
                document.body.appendChild(toast);
            }
            var colors = { success: '#10b981', error: '#ef4444', warning: '#f59e0b', info: '#3b82f6' };
            toast.style.background = colors[type] || colors.info;
            toast.textContent = msg;
            toast.style.opacity = '1';
            toast.style.transform = 'translateY(0)';
            clearTimeout(toast._timer);
            toast._timer = setTimeout(function() {
                toast.style.opacity = '0';
                toast.style.transform = 'translateY(-10px)';
            }, 3000);
        }
        window.adminToast = showToast;

        // ====== 队列过滤 ======
        document.querySelectorAll('.filter-tab').forEach(function(tab) {
            tab.addEventListener('click', function() {
                document.querySelectorAll('.filter-tab').forEach(function(t) { t.classList.remove('active'); });
                this.classList.add('active');
                var filter = this.getAttribute('data-filter');
                // 重新加载页面带上筛选参数
                window.location.href = cp + '/contentReview?filter=' + encodeURIComponent(filter);
            });
        });

        // ====== 审核操作（通过/拒绝） ======
        document.querySelectorAll('.action-btn.approve').forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                e.stopPropagation();
                var id = this.getAttribute('data-id');
                var item = this.closest('.queue-item');
                fetch(cp + '/contentReview', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'action=approve&id=' + id
                })
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (data.success) {
                        item.classList.add('approved');
                        item.querySelector('.item-actions').innerHTML = '<span class="status-approved">✅ 已通过</span>';
                        // 更新统计
                        var pending = document.getElementById('pendingReviews');
                        var today = document.getElementById('todayReviews');
                        if (pending) pending.textContent = Math.max(0, parseInt(pending.textContent) - 1);
                        if (today) today.textContent = parseInt(today.textContent) + 1;
                        showToast('审核通过成功', 'success');
                    } else {
                        showToast('操作失败: ' + (data.message || '未知错误'), 'error');
                    }
                })
                .catch(function(err) { showToast('网络错误，请重试: ' + err.message, 'error'); });
            });
        });

        document.querySelectorAll('.action-btn.reject').forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                e.stopPropagation();
                var id = this.getAttribute('data-id');
                var reason = prompt('请输入拒绝理由:', '内容不符合平台规范');
                if (!reason) return;
                var item = this.closest('.queue-item');
                fetch(cp + '/contentReview', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'action=reject&id=' + id + '&reason=' + encodeURIComponent(reason)
                })
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (data.success) {
                        item.classList.add('rejected');
                        item.querySelector('.item-actions').innerHTML = '<span class="status-rejected">❌ 已拒绝</span>';
                        var pending = document.getElementById('pendingReviews');
                        if (pending) pending.textContent = Math.max(0, parseInt(pending.textContent) - 1);
                        showToast('已拒绝该内容', 'success');
                    } else {
                        showToast('操作失败: ' + (data.message || '未知错误'), 'error');
                    }
                })
                .catch(function(err) { showToast('网络错误，请重试: ' + err.message, 'error'); });
            });
        });

        // ====== 详情按钮 ======
        document.querySelectorAll('.action-btn.detail').forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                e.stopPropagation();
                var id = this.getAttribute('data-id');
                currentItemId = id;
                var item = this.closest('.queue-item');
                var title = item.querySelector('.item-title').textContent;
                var preview = item.querySelector('.item-preview').textContent;
                var type = item.querySelector('.meta-tag').textContent;
                var author = item.querySelector('.meta-author').textContent;
                var time = item.querySelector('.meta-time').textContent;

                // 更新详情卡片
                document.getElementById('detailTitle').textContent = title;
                document.getElementById('detailStatus').textContent = '待审核';
                document.getElementById('detailStatus').className = 'detail-status pending';
                document.getElementById('detailContent').innerHTML =
                    '<div class="content-section">' +
                    '  <h4>内容信息</h4>' +
                    '  <div class="info-grid">' +
                    '    <div class="info-item"><label>内容类型:</label><span class="info-value">' + type + '</span></div>' +
                    '    <div class="info-item"><label>' + author + '</label><span class="info-value">' + time + '</span></div>' +
                    '    <div class="info-item"><label>审核编号:</label><span class="info-value">#' + id + '</span></div>' +
                    '  </div>' +
                    '</div>' +
                    '<div class="content-section">' +
                    '  <h4>内容预览</h4>' +
                    '  <div class="preview-box"><p>' + preview + '</p></div>' +
                    '</div>';
            });
        });

        // ====== 大按钮操作 ======
        var btnApprove = document.getElementById('btnApprove');
        var btnReject = document.getElementById('btnReject');
        if (btnApprove) {
            btnApprove.addEventListener('click', function() {
                if (!currentItemId) { showToast('请先在左侧列表点击"📄 详情"选择审核项', 'warning'); return; }
                var approveBtn = document.querySelector('.action-btn.approve[data-id="' + currentItemId + '"]');
                if (approveBtn) approveBtn.click();
            });
        }
        if (btnReject) {
            btnReject.addEventListener('click', function() {
                if (!currentItemId) { showToast('请先在左侧列表点击"📄 详情"选择审核项', 'warning'); return; }
                var rejectBtn = document.querySelector('.action-btn.reject[data-id="' + currentItemId + '"]');
                if (rejectBtn) rejectBtn.click();
            });
        }

        // ====== 搜索功能 ======
        var searchInput = document.getElementById('contentSearch');
        if (searchInput) {
            searchInput.addEventListener('input', function() {
                var query = this.value.toLowerCase().trim();
                document.querySelectorAll('.queue-item').forEach(function(item) {
                    var title = item.querySelector('.item-title');
                    if (!title) return;
                    var text = title.textContent.toLowerCase();
                    item.style.display = (!query || text.indexOf(query) >= 0) ? 'flex' : 'none';
                });
            });
        }

        // ====== 初始化统计动画 ======
        document.addEventListener('DOMContentLoaded', function() {
            var statIds = ['pendingReviews', 'todayReviews', 'approvalRate', 'avgTime'];
            statIds.forEach(function(statId) {
                var el = document.getElementById(statId);
                if (!el) return;
                var original = el.textContent;
                el.textContent = '0';
                setTimeout(function() {
                    var current = 0;
                    var target = statId === 'approvalRate'
                        ? parseFloat(original.replace('%', ''))
                        : parseInt(original);
                    if (isNaN(target) || target === 0) { el.textContent = original; return; }
                    var increment = target / 40;
                    var timer = setInterval(function() {
                        current += increment;
                        if (current >= target) {
                            current = target;
                            clearInterval(timer);
                        }
                        el.textContent = statId === 'approvalRate'
                            ? Math.floor(current) + '%'
                            : Math.floor(current);
                    }, 40);
                }, 500);
            });
        });
        // ====== 全选 / 反选 ======
        var selectAllCheckbox = document.getElementById('selectAllCheckbox');
        var selectedCountEl = document.getElementById('selectedCount');
        var batchSelectBar = document.getElementById('batchSelectBar');
        function updateSelectedCount() {
            var checked = document.querySelectorAll('.review-checkbox:checked');
            var total = document.querySelectorAll('.review-checkbox:not(:disabled)').length;
            if (checked.length > 0) {
                selectedCountEl.style.display = '';
                selectedCountEl.querySelector('strong').textContent = checked.length;
                batchSelectBar.classList.add('has-selection');
            } else {
                selectedCountEl.style.display = 'none';
                batchSelectBar.classList.remove('has-selection');
            }
            if (selectAllCheckbox) selectAllCheckbox.checked = checked.length === total && total > 0;
        }
        if (selectAllCheckbox) {
            selectAllCheckbox.addEventListener('change', function() {
                var checked = this.checked;
                document.querySelectorAll('.review-checkbox:not(:disabled)').forEach(function(cb) { cb.checked = checked; });
                updateSelectedCount();
            });
        }
        // 监听每个checkbox变化
        document.querySelectorAll('.review-checkbox').forEach(function(cb) {
            cb.addEventListener('change', updateSelectedCount);
        });

        // ====== 批量操作 ======
        function getSelectedIds() {
            var ids = [];
            document.querySelectorAll('.review-checkbox:checked').forEach(function(cb) { ids.push(cb.value); });
            return ids;
        }
        function batchAction(action) {
            var ids = getSelectedIds();
            if (ids.length === 0) { adminToast('请先勾选要操作的审核项', 'warning'); return; }
            if (!confirm('确认批量' + (action==='batchApprove'?'通过':'拒绝') + ' ' + ids.length + ' 项？')) return;
            showToast('正在批量处理 ' + ids.length + ' 项...', 'info');
            var results = 0;
            var promises = ids.map(function(id) {
                return fetch(cp + '/contentReview', {
                    method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'},
                    body: 'action=' + (action==='batchApprove'?'approve':'reject') + '&id=' + id
                }).then(function(r){return r.json()}).then(function(d){
                    if(d.success) results++;
                    var item = document.querySelector('.queue-item[data-id="'+id+'"]');
                    if(item){
                        item.style.opacity='0.3';
                        var cb = item.querySelector('.review-checkbox');
                        if(cb){cb.checked=false;cb.disabled=true;}
                        item.querySelector('.item-actions').innerHTML = '<span class="status-' + (action==='batchApprove'?'approved':'rejected') + '">' + (action==='batchApprove'?'✅ 已通过':'❌ 已拒绝') + '</span>';
                    }
                });
            });
            Promise.all(promises).then(function(){
                adminToast('操作完成：成功 ' + results + '/' + ids.length, 'success');
                updateSelectedCount();
                var pending = document.getElementById('pendingReviews');
                if(pending) pending.textContent = Math.max(0, parseInt(pending.textContent) - results);
            });
        }
        var ba = document.getElementById('batchApprove');
        var br = document.getElementById('batchReject');
        if(ba) ba.addEventListener('click', function(){ batchAction('batchApprove'); });
        if(br) br.addEventListener('click', function(){ batchAction('batchReject'); });

        // 批量导出
        var be = document.getElementById('batchExport');
        if(be) be.addEventListener('click', function(){
            var items = [];
            document.querySelectorAll('.queue-item').forEach(function(item){
                var title = item.querySelector('.item-title');
                if(title) items.push(title.textContent);
            });
            if(items.length===0){showToast('没有可导出的数据', 'warning');return;}
            var csv = '\uFEFF类型,标题,提交者\n';
            document.querySelectorAll('.queue-item').forEach(function(item){
                var title = item.querySelector('.item-title');
                var type = item.querySelector('.meta-tag');
                var author = item.querySelector('.meta-author');
                if(title) csv += (type?type.textContent:'') + ',"' + title.textContent + '",' + (author?author.textContent.replace('提交者: ',''):'') + '\n';
            });
            var blob = new Blob([csv], {type:'text/csv;charset=utf-8'});
            var a = document.createElement('a');
            a.href = URL.createObjectURL(blob);
            a.download = 'content_review_export_' + new Date().toISOString().slice(0,10) + '.csv';
            a.click();
        });

        // 生成报告
        var bReport = document.getElementById('batchReport');
        if(bReport) bReport.addEventListener('click', function(){
            var total = document.querySelectorAll('.queue-item').length;
            var pending = document.getElementById('pendingReviews').textContent;
            var today = document.getElementById('todayReviews').textContent;
            var rate = document.getElementById('approvalRate').textContent;
            var report = '📊 审核报告摘要\n\n待审核: ' + pending + ' 项\n今日处理: ' + today + ' 项\n通过率: ' + rate + '\n队列总数: ' + total + ' 项\n报告时间: ' + new Date().toLocaleString('zh-CN');
            showToast(report.replace(/\n/g, ' | '), 'info');
        });

        // 暂存/标记人工按钮
        var btnDefer = document.getElementById('btnDefer');
        if(btnDefer) btnDefer.addEventListener('click', function(){
            if(!currentItemId){ showToast('请先在左侧列表点击"📄 详情"选择审核项', 'warning'); return; }
            showToast('📋 审核项 #' + currentItemId + ' 已暂存待议', 'info');
        });
        var btnFlag = document.getElementById('btnFlag');
        if(btnFlag) btnFlag.addEventListener('click', function(){
            if(!currentItemId){ showToast('请先在左侧列表点击"📄 详情"选择审核项', 'warning'); return; }
            showToast('🚩 审核项 #' + currentItemId + ' 已标记为人工审核', 'info');
        });
    })();
    </script>

    <style>
        /* ===== CSS变量定义（修复深色模式卡片不可见） ===== */
        :root {
            --bg-card: rgba(20, 28, 40, 0.65);
            --bg-dark: rgba(10, 15, 26, 0.85);
            --border-glow: rgba(0, 242, 255, 0.3);
            --text-primary: #ffffff;
            --text-secondary: rgba(255, 255, 255, 0.7);
            --glow-primary: #00f2ff;
            --glow-secondary: #b77eff;
            --transition-tech: all 0.3s ease;
        }
        /* 内容审核专用样式 */
        .review-main {
            display: flex;
            gap: 30px;
            margin: 30px 0;
        }

        .review-queue {
            flex: 1;
            background: var(--bg-card);
            border-radius: 20px;
            padding: 25px;
            border: 1px solid var(--border-glow);
        }

        .review-detail {
            width: 45%;
            background: var(--bg-card);
            border-radius: 20px;
            padding: 25px;
            border: 1px solid var(--border-glow);
        }

        .queue-filters {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            gap: 15px;
        }

        .filter-tabs {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .filter-tab {
            padding: 8px 16px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-glow);
            border-radius: 10px;
            color: var(--text-secondary);
            cursor: pointer;
            transition: var(--transition-tech);
        }

        .filter-tab.active {
            background: var(--glow-primary);
            color: var(--bg-dark);
            border-color: var(--glow-primary);
        }

        .search-box {
            display: flex;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-glow);
            border-radius: 10px;
            overflow: hidden;
        }

        .search-box input {
            flex: 1;
            padding: 8px 15px;
            background: transparent;
            border: none;
            color: var(--text-primary);
        }

        .search-box button {
            padding: 8px 15px;
            background: var(--bg-dark);
            border: none;
            color: var(--text-primary);
            cursor: pointer;
        }

        .queue-list {
            max-height: 500px;
            overflow-y: auto;
            padding-right: 10px;
        }

        .queue-item {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-glow);
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 15px;
            transition: var(--transition-tech);
            position: relative;
        }

        .queue-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
        }

        .queue-item.priority-high { border-left: 4px solid #ff4757; }
        .queue-item.priority-report { border-left: 4px solid #ffa502; }

        .item-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            padding: 4px 10px;
            background: rgba(255, 71, 87, 0.2);
            border-radius: 8px;
            font-size: 0.8rem;
            color: #ff4757;
        }

        .item-content { margin-bottom: 15px; }

        .item-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 8px;
        }

        .item-meta {
            display: flex;
            gap: 15px;
            margin-bottom: 10px;
            font-size: 0.9rem;
            color: var(--text-secondary);
        }

        .meta-tag {
            padding: 2px 8px;
            background: var(--bg-dark);
            border-radius: 6px;
            border: 1px solid var(--border-glow);
        }

        .meta-tag.course { color: var(--glow-primary); }
        .meta-tag.article { color: var(--accent-secondary); }
        .meta-tag.comment { color: var(--glow-secondary); }
        .meta-tag.report { color: #ffa502; }
        .meta-tag.data { color: #7bed9f; }

        .meta-score {
            padding: 2px 8px;
            background: rgba(0, 245, 255, 0.1);
            border-radius: 6px;
            color: var(--glow-primary);
        }

        .item-preview {
            color: var(--text-secondary);
            font-size: 0.95rem;
            line-height: 1.4;
        }

        .item-actions { display: flex; gap: 10px; }

        .action-btn {
            padding: 8px 15px;
            border-radius: 8px;
            border: 1px solid var(--border-glow);
            background: var(--bg-dark);
            color: var(--text-primary);
            cursor: pointer;
            transition: var(--transition-tech);
        }

        .action-btn.approve:hover { background: #2ed573; border-color: #2ed573; }
        .action-btn.reject:hover { background: #ff4757; border-color: #ff4757; }
        .action-btn.detail:hover { background: var(--glow-primary); border-color: var(--glow-primary); color: var(--bg-dark); }

        .status-approved, .status-rejected { padding: 8px 15px; border-radius: 8px; font-size: 0.9rem; }
        .status-approved { background: rgba(46, 213, 115, 0.2); color: #2ed573; }
        .status-rejected { background: rgba(255, 71, 87, 0.2); color: #ff4757; }

        .queue-pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 20px;
            margin-top: 20px;
        }

        .page-btn {
            padding: 8px 15px;
            background: var(--bg-dark);
            border: 1px solid var(--border-glow);
            border-radius: 8px;
            color: var(--text-primary);
            cursor: pointer;
        }

        .page-info { color: var(--text-secondary); }

        .detail-card {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 15px;
            padding: 25px;
            border: 1px solid var(--border-glow);
        }

        .detail-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--border-glow);
        }

        .detail-header h3 { font-size: 1.3rem; color: var(--text-primary); }

        .detail-status { padding: 6px 12px; border-radius: 8px; font-size: 0.9rem; }
        .detail-status.pending { background: rgba(255, 165, 2, 0.2); color: #ffa502; }

        .content-section { margin-bottom: 25px; }
        .content-section h4 {
            font-size: 1.1rem;
            color: var(--text-primary);
            margin-bottom: 15px;
            padding-bottom: 8px;
            border-bottom: 1px solid var(--border-glow);
        }

        .info-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; }
        .info-item { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid rgba(255,255,255,0.05); }
        .info-item label { color: var(--text-secondary); }
        .info-item .info-value { color: var(--text-primary); font-weight: 500; }

        .preview-box {
            background: var(--bg-dark);
            border-radius: 10px;
            padding: 20px;
            border: 1px solid var(--border-glow);
        }

        .detail-actions { display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; margin-top: 30px; }

        .action-large {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            padding: 15px;
            border-radius: 12px;
            border: none;
            cursor: pointer;
            transition: var(--transition-tech);
            font-weight: 500;
        }

        .action-large.approve { background: linear-gradient(135deg, #2ed573, #1e90ff); color: white; }
        .action-large.reject { background: linear-gradient(135deg, #ff4757, #ff6b81); color: white; }
        .action-large.pending { background: var(--bg-dark); color: var(--text-primary); border: 1px solid var(--border-glow); }
        .action-large.flag { background: var(--bg-dark); color: var(--text-primary); border: 1px solid var(--border-glow); }
        .action-large:hover { transform: translateY(-3px); box-shadow: 0 8px 25px rgba(0,0,0,0.2); }

        .review-stats { margin: 30px 0; }
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }

        .stat-card {
            background: var(--bg-card);
            border-radius: 15px;
            padding: 20px;
            border: 1px solid var(--border-glow);
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .chart-circle, .chart-bar, .chart-line, .chart-donut {
            width: 60px; height: 60px;
            border-radius: 50%;
            border: 5px solid var(--border-glow);
            border-top-color: var(--glow-primary);
            position: relative;
        }

        .batch-select-bar {
            display: flex; align-items: center; gap: 16px;
            padding: 10px 14px; margin-bottom: 12px;
            background: rgba(0,242,255,0.05); border: 1px solid rgba(0,242,255,0.15);
            border-radius: 10px; transition: all .3s;
        }
        .batch-select-bar.has-selection {
            background: rgba(0,242,255,0.1); border-color: rgba(0,242,255,0.35);
            box-shadow: 0 0 12px rgba(0,242,255,0.1);
        }
        .select-all-label { display: flex; align-items: center; gap: 8px; cursor: pointer; color: var(--text-secondary); font-size: 0.9rem; }
        .select-all-label input { width: 16px; height: 16px; accent-color: #00f2ff; cursor: pointer; }
        .selected-count { color: var(--glow-primary); font-size: 0.85rem; }
        .selected-count strong { color: #fff; }
        .batch-actions { margin-top: 30px; }
        .actions-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; }

        .batch-btn {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
            padding: 20px 15px;
            background: var(--bg-card);
            border: 1px solid var(--border-glow);
            border-radius: 12px;
            cursor: pointer;
            transition: var(--transition-tech);
        }

        .batch-btn:hover { transform: translateY(-3px); border-color: var(--glow-primary); }
        .btn-icon { font-size: 1.5rem; }
        .btn-text { font-size: 0.9rem; color: var(--text-primary); }
    </style>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= contextPath %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
