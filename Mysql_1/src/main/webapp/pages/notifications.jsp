<%--=============================================================================notifications.jsp=============================================================================用途
    功能页面 ── 使用的关键 API / 技术 ──────────────────────────────────────────────────── EL 表达式 —— ${} 访问后端数据 JSTL 核心标签 ——
    <c:forEach> / <c:if> / <c:choose>
            ${pageContext.request.contextPath} —— 获取应用上下文根路径
            Ajax 异步请求 —— fetch
            DOM 事件处理
            DOM 选择器 —— querySelector / getElementById

            =============================================================================
            --%>
            <%@ page contentType="text/html;charset=UTF-8" language="java" %>
                <%@ page import="java.util.Map, java.util.ArrayList, com.ebookBuy301.pojo.Notification" %>
                    <% Map<String, Object> notifStats = (Map<String, Object>) request.getAttribute("notifStats");
                            if (notifStats == null) notifStats = new java.util.HashMap<>();
                                int sentCount = notifStats.get("sentCount") != null ? ((Number)
                                notifStats.get("sentCount")).intValue() : 0;
                                int scheduledCount = notifStats.get("scheduledCount") != null ? ((Number)
                                notifStats.get("scheduledCount")).intValue() : 0;
                                int failedCount = notifStats.get("failedCount") != null ? ((Number)
                                notifStats.get("failedCount")).intValue() : 0;
                                int deliveryRate = notifStats.get("deliveryRate") != null ? ((Number)
                                notifStats.get("deliveryRate")).intValue() : 0;

                                ArrayList<Notification> sentNotifications = (ArrayList<Notification>)
                                        request.getAttribute("sentNotifications");
                                        if (sentNotifications == null) sentNotifications = new ArrayList<>();
                                            ArrayList<Notification> scheduledNotifications = (ArrayList<Notification>)
                                                    request.getAttribute("scheduledNotifications");
                                                    if (scheduledNotifications == null) scheduledNotifications = new
                                                    ArrayList<>();

                                                        String ctx = request.getContextPath();
                                                            String csrfToken = com.ebookBuy301.util.CsrfUtil.getToken(request.getSession());
                                                        %>
                                                        <!DOCTYPE html>
                                                        <html lang="zh-CN">

                                                        <head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();
// 监听父窗口主题切换消息（iframe 内）
window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);}});
// CSRF 令牌，供 fetch 请求使用
window._csrfToken = '<%= csrfToken %>';
</script>

                                                            <meta charset="UTF-8">
                                                            <meta name="viewport"
                                                                content="width=device-width, initial-scale=1.0">
                                                            <title>通知推送管理 - 博雅书院</title>
                                                            <link rel="stylesheet"
                                                                href="${pageContext.request.contextPath}/CSS/index.css">
                                                            <link rel="stylesheet"
                                                                href="${pageContext.request.contextPath}/CSS/components.css">
                                                            <link rel="stylesheet"
                                                                href="${pageContext.request.contextPath}/CSS/notifications.css?v=3">
                                                            <link rel="stylesheet"
                                                                href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
                                                            <style>
                                                                :root {
                                                                    --notify-success: #10b981;
            --notify-warning: #f59e0b;
            --notify-error: #ef4444;
            --notify-info: #3b82f6;
        }

        .scrollable-container {
            overflow-y: auto;
            overflow-x: hidden;
            scrollbar-width: none;
            -ms-overflow-style: none;
        }
        .scrollable-container::-webkit-scrollbar {
            display: none;
        }

        .notification-list,
        .notification-history,
        .scheduled-notifications,
        .quick-send-card {
            max-height: 400px;
            overflow-y: auto;
            scrollbar-width: none;
            -ms-overflow-style: none;
        }
        .notification-list::-webkit-scrollbar,
        .notification-history::-webkit-scrollbar,
        .scheduled-notifications::-webkit-scrollbar,
        .quick-send-card::-webkit-scrollbar {
            display: none;
        }

        .admin-content {
            overflow-y: auto;
            scrollbar-width: none;
            -ms-overflow-style: none;
            max-height: calc(100vh - 20px);
            width: calc(100% - 280px);
            margin-left: 280px;
        }
        .admin-content.full-width {
            width: 100%;
            margin-left: 0;
        }
        .admin-content::-webkit-scrollbar {
            display: none;
        }

        .notification-list {
            max-height: 350px;
        }

        .scheduled-notifications {
            max-height: 300px;
        }

        .modal-body {
            max-height: 400px;
            overflow-y: auto;
            scrollbar-width: none;
            -ms-overflow-style: none;
        }
        .modal-body::-webkit-scrollbar {
            display: none;
        }

        /* 消息详情弹窗样式 */
        .detail-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6);
            z-index: 1000;
            justify-content: center;
            align-items: center;
        }
        .detail-modal.active {
            display: flex;
        }
        .detail-modal-content {
            background: #1a1a2e;
            border-radius: 12px;
            width: 90%;
            max-width: 600px;
            max-height: 80vh;
            overflow: hidden;
            animation: slideIn 0.3s ease;
        }
        @keyframes slideIn {
            from { transform: translateY(-20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        .detail-modal-header {
            padding: 20px;
            border-bottom: 1px solid #333;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .detail-modal-header .close-btn {
            background: none;
            border: none;
            color: #999;
            font-size: 24px;
            cursor: pointer;
            transition: color 0.3s;
        }
        .detail-modal-header .close-btn:hover {
            color: #fff;
        }
        .detail-modal-body {
            padding: 24px;
            max-height: 400px;
            overflow-y: auto;
        }
        .detail-modal-body .content-text {
            font-size: 16px;
            line-height: 1.8;
            color: #ccc;
            white-space: pre-wrap;
        }
        .detail-modal-body .meta-info {
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #333;
            color: #999;
            font-size: 14px;
        }

        /* 私信样式 */
        .private-chat-container {
            display: flex;
            height: 500px;
            border-radius: 12px;
            overflow: hidden;
            background: #1a1a2e;
        }
        .chat-sidebar {
            width: 280px;
            border-right: 1px solid #333;
            display: flex;
            flex-direction: column;
        }
        .chat-sidebar-header {
            padding: 16px;
            border-bottom: 1px solid #333;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .chat-sidebar-header h3 {
            margin: 0;
            font-size: 16px;
        }
        .chat-sidebar-header .new-chat-btn {
            background: #4A90D9;
            border: none;
            color: white;
            padding: 6px 12px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        .chat-contact-list {
            flex: 1;
            overflow-y: auto;
            padding: 8px;
        }
        .chat-contact {
            display: flex;
            padding: 12px;
            border-radius: 8px;
            cursor: pointer;
            transition: background 0.3s;
            margin-bottom: 4px;
        }
        .chat-contact:hover,
        .chat-contact.active {
            background: #2a2a4a;
        }
        .chat-contact-avatar {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            background: linear-gradient(135deg, #4A90D9, #6E7BD4);
            display: flex;
            justify-content: center;
            align-items: center;
            color: white;
            font-size: 18px;
            margin-right: 12px;
        }
        .chat-contact-info {
            flex: 1;
            min-width: 0;
        }
        .chat-contact-name {
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 4px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .chat-contact-preview {
            font-size: 12px;
            color: #999;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .chat-contact-unread {
            background: #ef4444;
            color: white;
            font-size: 12px;
            padding: 2px 6px;
            border-radius: 10px;
            margin-left: auto;
        }

        .chat-main {
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        .chat-main-header {
            padding: 16px;
            border-bottom: 1px solid #333;
            display: flex;
            align-items: center;
        }
        .chat-main-header .chat-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #4A90D9, #6E7BD4);
            display: flex;
            justify-content: center;
            align-items: center;
            color: white;
            font-size: 16px;
            margin-right: 12px;
        }
        .chat-main-header .chat-name {
            font-size: 16px;
            font-weight: 500;
        }

        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 16px;
            display: flex;
            flex-direction: column;
        }
        .chat-message {
            max-width: 70%;
            margin-bottom: 16px;
            display: flex;
            flex-direction: column;
        }
        .chat-message.sent {
            align-self: flex-end;
        }
        .chat-message.received {
            align-self: flex-start;
        }
        .chat-message-content {
            background: #2a2a4a;
            padding: 12px 16px;
            border-radius: 12px;
            font-size: 14px;
            line-height: 1.5;
        }
        .chat-message.sent .chat-message-content {
            background: #4A90D9;
        }
        .chat-message-time {
            font-size: 11px;
            color: #666;
            margin-top: 4px;
            padding: 0 4px;
        }
        .chat-message.sent .chat-message-time {
            text-align: right;
        }

        .chat-input-area {
            padding: 12px 16px;
            border-top: 1px solid #333;
            display: flex;
            gap: 12px;
        }
        .chat-input-area input {
            flex: 1;
            background: #2a2a4a;
            border: 1px solid #333;
            border-radius: 20px;
            padding: 10px 16px;
            color: white;
            font-size: 14px;
            outline: none;
            transition: border-color 0.3s;
        }
        .chat-input-area input:focus {
            border-color: #4A90D9;
        }
        .chat-input-area button {
            background: #4A90D9;
            border: none;
            color: white;
            padding: 10px 20px;
            border-radius: 20px;
            cursor: pointer;
            font-size: 14px;
            transition: background 0.3s;
        }
        .chat-input-area button:hover {
            background: #3a80c9;
        }

        /* 用户选择模态框 */
        .user-select-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6);
            z-index: 1000;
            justify-content: center;
            align-items: center;
        }
        .user-select-modal.active {
            display: flex;
        }
        .user-select-content {
            background: #1a1a2e;
            border-radius: 12px;
            width: 90%;
            max-width: 500px;
            max-height: 70vh;
            overflow: hidden;
        }
        .user-select-header {
            padding: 16px;
            border-bottom: 1px solid #333;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .user-select-header .close-btn {
            background: none;
            border: none;
            color: #999;
            font-size: 24px;
            cursor: pointer;
        }
        .user-select-search {
            padding: 12px;
            border-bottom: 1px solid #333;
        }
        .user-select-search input {
            width: 100%;
            background: #2a2a4a;
            border: 1px solid #333;
            border-radius: 8px;
            padding: 10px 12px;
            color: white;
            font-size: 14px;
            outline: none;
        }
        .user-select-list {
            max-height: 400px;
            overflow-y: auto;
            padding: 8px;
        }
        .user-select-item {
            display: flex;
            align-items: center;
            padding: 12px;
            border-radius: 8px;
            cursor: pointer;
            transition: background 0.3s;
        }
        .user-select-item:hover {
            background: #2a2a4a;
        }
        .user-select-item .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #4A90D9, #6E7BD4);
            display: flex;
            justify-content: center;
            align-items: center;
            color: white;
            font-size: 16px;
            margin-right: 12px;
        }
        .user-select-item .user-info {
            flex: 1;
        }
        .user-select-item .user-name {
            font-size: 14px;
            font-weight: 500;
        }
        .user-select-item .user-role {
            font-size: 12px;
            color: #999;
        }

        /* 侧栏内联搜索（与消息中心一致） */
        .chat-sidebar-search {
            padding: 10px 12px;
            border-bottom: 1px solid #333;
            background: #16162a;
        }
        .chat-sidebar-search input {
            width: 100%;
            background: #2a2a4a;
            border: 1px solid #444;
            border-radius: 8px;
            padding: 8px 12px;
            color: #e0e0e0;
            font-size: 13px;
            outline: none;
            transition: border-color 0.3s;
        }
        .chat-sidebar-search input:focus {
            border-color: #4A90D9;
        }
        .chat-sidebar-search input::placeholder {
            color: #888;
        }
        .chat-search-cancel {
            background: transparent;
            border: 1px solid #555;
            color: #aaa;
            padding: 4px 10px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            transition: all 0.2s;
        }
        .chat-search-cancel:hover {
            background: #333;
            color: #fff;
        }
        .chat-sidebar-users {
            flex: 1;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
        }
        .user-list-inline {
            padding: 6px;
        }
        .user-list-inline .user-item {
            display: flex;
            align-items: center;
            padding: 10px 12px;
            border-radius: 8px;
            cursor: pointer;
            transition: background 0.2s;
            margin-bottom: 2px;
        }
        .user-list-inline .user-item:hover {
            background: #2a2a4a;
        }
        .user-list-inline .user-info {
            flex: 1;
            min-width: 0;
            margin-left: 10px;
        }
        .user-list-inline .user-name {
            font-size: 13px;
            font-weight: 500;
            color: #e0e0e0;
        }
        .user-list-inline .user-role {
            font-size: 11px;
            color: #888;
        }
        .user-list-inline .user-check {
            color: #666;
            font-size: 16px;
            margin-left: auto;
        }
        .user-list-inline .chat-contact-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: linear-gradient(135deg, #4A90D9, #6E7BD4);
            display: flex;
            justify-content: center;
            align-items: center;
            color: white;
            font-size: 14px;
            flex-shrink: 0;
            overflow: hidden;
        }
        .chat-contact.has-unread {
            position: relative;
        }
        .chat-contact.has-unread::after {
            content: '';
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #ef4444;
        }
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
        html[data-theme$="-light"] [class*="toast"],html[data-theme$="-light"] [class*="notification"]{color:#3d3929!important;background:rgba(248,243,230,.96)!important}
        html[data-theme$="-light"] a{color:#2563eb!important}
    </style>

</head>
<body class="admin-page">
    <div class="admin-container">
        <main class="admin-content full-width">
            <header class="page-header">
                <div class="header-left">
                    <h1><i class="fas fa-bell"></i> 通知推送管理</h1>
                    <p class="subtitle">管理全局通知、系统公告和用户消息</p>
                </div>
                <div class="header-actions">
                    <button class="btn btn-primary" id="send-notification">
                        <i class="fas fa-paper-plane"></i> 发送新通知
                    </button>
                    <button class="btn btn-secondary" id="schedule-notification">
                        <i class="fas fa-clock"></i> 定时发送
                    </button>
                </div>
            </header>

            <!-- 标签切换 -->
            <div class="tab-container">
                <button class="tab-btn active" data-tab="notification">系统通知</button>
                <button class="tab-btn" data-tab="private">私信消息</button>
            </div>

            <!-- 系统通知内容 -->
            <div id="notification-tab" class="tab-content active">
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon success">
                            <i class="fas fa-check-circle"></i>
                        </div>
                        <div class="stat-info">
                            <h3><%= sentCount %></h3>
                            <p>已发送通知</p>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon warning">
                            <i class="fas fa-clock"></i>
                        </div>
                        <div class="stat-info">
                            <h3><%= scheduledCount %></h3>
                            <p>定时等待</p>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon error">
                            <i class="fas fa-exclamation-circle"></i>
                        </div>
                        <div class="stat-info">
                            <h3><%= failedCount %></h3>
                            <p>失败通知</p>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon info">
                            <i class="fas fa-users"></i>
                        </div>
                        <div class="stat-info">
                            <h3><%= deliveryRate %>%</h3>
                            <p>送达率</p>
                        </div>
                    </div>
                </div>

                <div class="quick-send-card">
                    <div class="card-header">
                        <h3><i class="fas fa-paper-plane"></i> 快速发送通知</h3>
                    </div>
                    <div class="card-body">
                        <form id="quick-send-form">
                            <div class="form-row">
                                <div class="form-group">
                                    <label>通知标题</label>
                                    <input type="text" id="quick-title" placeholder="请输入通知标题" required>
                                </div>
                                <div class="form-group">
                                    <label>通知类型</label>
                                    <select id="quick-type">
                                        <option value="success">成功通知</option>
                                        <option value="warning">警告通知</option>
                                        <option value="error">错误通知</option>
                                        <option value="info">信息通知</option>
                                        <option value="system">系统公告</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>通知内容</label>
                                <textarea id="quick-content" rows="3" placeholder="请输入通知内容" required></textarea>
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label>目标用户</label>
                                    <select id="quick-target">
                                        <option value="all">所有用户</option>
                                        <option value="students">学生用户</option>
                                        <option value="teachers">教师用户</option>
                                        <option value="vip">VIP用户</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>发送方式</label>
                                    <div class="checkbox-group">
                                        <label class="checkbox-item">
                                            <input type="checkbox" id="send-email" checked>
                                            <span>邮件通知</span>
                                        </label>
                                        <label class="checkbox-item">
                                            <input type="checkbox" id="send-sms">
                                            <span>短信通知</span>
                                        </label>
                                    </div>
                                </div>
                            </div>
                            <button type="submit" class="btn btn-primary btn-block">
                                <i class="fas fa-paper-plane"></i> 立即发送
                            </button>
                        </form>
                    </div>
                </div>

                <div class="section-grid">
                    <div class="notification-history">
                        <div class="card-header">
                            <h3><i class="fas fa-history"></i> 通知历史记录</h3>
                            <div class="filter-bar">
                                <select id="history-filter-type">
                                    <option value="">全部类型</option>
                                    <option value="success">成功通知</option>
                                    <option value="warning">警告通知</option>
                                    <option value="error">错误通知</option>
                                    <option value="info">信息通知</option>
                                    <option value="system">系统公告</option>
                                </select>
                                <select id="history-filter-time">
                                    <option value="">全部时间</option>
                                    <option value="today">今天</option>
                                    <option value="week">本周</option>
                                    <option value="month">本月</option>
                                </select>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="notification-list" id="history-list">
                                <% for (Notification n : sentNotifications) { %>
                                <div class="notification-item" data-id="<%= n.getId() %>" onclick="showNotificationDetail(<%= n.getId() %>)">
                                    <div class="notification-icon <%= n.getNotificationType() %>">
                                        <i class="fas <%= getIconClass(n.getNotificationType()) %>"></i>
                                    </div>
                                    <div class="notification-content">
                                        <h4><%= n.getTitle() != null ? n.getTitle() : "无标题" %></h4>
                                        <p><%= n.getContent() != null ? (n.getContent().length() > 50 ? n.getContent().substring(0, 50) + "..." : n.getContent()) : "" %></p>
                                        <div class="notification-meta">
                                            <span class="meta-item"><i class="fas fa-clock"></i> <%= formatTime(n.getSendTime()) %></span>
                                            <span class="meta-item"><i class="fas fa-users"></i> <%= n.getTotalRecipients() > 0 ? n.getTotalRecipients() : "0" %>人</span>
                                            <span class="meta-item"><i class="fas fa-eye"></i> <%= n.getReadCount() > 0 ? n.getReadCount() : "0" %>已读</span>
                                        </div>
                                    </div>
                                    <div class="notification-actions">
                                        <button class="action-btn delete-btn" onclick="event.stopPropagation(); deleteNotification(<%= n.getId() %>)">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </div>
                                <% } %>
                                <% if (sentNotifications.isEmpty()) { %>
                                <div class="empty-state">
                                    <i class="fas fa-inbox"></i>
                                    <p>暂无通知记录</p>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <div class="scheduled-card">
                        <div class="card-header">
                            <h3><i class="fas fa-clock"></i> 定时通知管理</h3>
                        </div>
                        <div class="card-body">
                            <div class="scheduled-notifications">
                                <% for (Notification n : scheduledNotifications) { %>
                                <div class="scheduled-item">
                                    <div class="scheduled-info">
                                        <h4><%= n.getTitle() != null ? n.getTitle() : "无标题" %></h4>
                                        <p><%= formatTime(n.getScheduledTime()) %></p>
                                    </div>
                                    <div class="scheduled-actions">
                                        <button class="action-btn cancel-btn" onclick="cancelScheduled(<%= n.getId() %>)">
                                            <i class="fas fa-times"></i> 取消
                                        </button>
                                    </div>
                                </div>
                                <% } %>
                                <% if (scheduledNotifications.isEmpty()) { %>
                                <div class="empty-state">
                                    <i class="fas fa-clock"></i>
                                    <p>暂无定时通知</p>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 私信内容 -->
            <div id="private-tab" class="tab-content">
                <div class="private-chat-container">
                    <div class="chat-sidebar">
                        <div class="chat-sidebar-header">
                            <h3 id="chat-sidebar-title">私信列表</h3>
                            <div style="display:flex;align-items:center;gap:6px;">
                                <button class="new-chat-btn" id="admin-new-chat-btn">
                                    <i class="fas fa-plus"></i> 发起对话
                                </button>
                                <button class="chat-search-cancel" id="admin-chat-search-cancel" style="display:none;">取消</button>
                            </div>
                        </div>
                        <!-- 内嵌搜索 -->
                        <div class="chat-sidebar-search" id="admin-chat-sidebar-search" style="display:none;">
                            <input type="text" id="admin-user-search-input" placeholder="搜索用户..." autocomplete="off">
                        </div>
                        <div class="chat-sidebar-users" id="admin-chat-sidebar-users" style="display:none;">
                            <div class="user-list-inline" id="admin-user-list">
                                <div class="empty-state"><i class="fas fa-spinner fa-spin"></i><p>加载中...</p></div>
                            </div>
                        </div>
                        <div class="chat-contact-list" id="chat-contact-list">
                            <div class="empty-state">
                                <i class="fas fa-message-circle"></i>
                                <p>暂无对话</p>
                            </div>
                        </div>
                    </div>
                    <div class="chat-main" id="chat-main">
                        <div class="chat-main-header" id="chat-main-header" style="display: none;">
                            <div class="chat-avatar" id="chat-avatar"></div>
                            <span class="chat-name" id="chat-name"></span>
                        </div>
                        <div class="chat-messages" id="chat-messages">
                            <div class="empty-state" id="chat-empty">
                                <i class="fas fa-message-circle"></i>
                                <p>选择一个对话开始聊天</p>
                            </div>
                        </div>
                        <div class="chat-input-area" id="chat-input-area" style="display: none;">
                            <input type="text" id="chat-input" placeholder="输入消息..." onkeyup="if(event.keyCode==13) sendMessage()">
                            <button onclick="sendMessage()"><i class="fas fa-paper-plane"></i></button>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- 发送通知模态框 -->
    <div class="modal" id="send-modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>发送新通知</h2>
                <button class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <form id="send-form">
                    <div class="form-group">
                        <label>通知标题</label>
                        <input type="text" id="modal-title" required>
                    </div>
                    <div class="form-group">
                        <label>通知内容</label>
                        <textarea id="modal-content" rows="5" required></textarea>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>通知类型</label>
                            <select id="modal-type">
                                <option value="success">成功通知</option>
                                <option value="warning">警告通知</option>
                                <option value="error">错误通知</option>
                                <option value="info">信息通知</option>
                                <option value="system">系统公告</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>目标用户</label>
                            <select id="modal-target">
                                <option value="all">所有用户</option>
                                <option value="students">学生用户</option>
                                <option value="teachers">教师用户</option>
                                <option value="vip">VIP用户</option>
                                <option value="custom">指定用户</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>发送方式</label>
                            <div class="checkbox-group">
                                <label class="checkbox-item">
                                    <input type="checkbox" id="modal-email" checked>
                                    <span>邮件通知</span>
                                </label>
                                <label class="checkbox-item">
                                    <input type="checkbox" id="modal-sms">
                                    <span>短信通知</span>
                                </label>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="custom-users-group" style="display: none;">
                        <label>指定用户（逗号分隔用户ID）</label>
                        <input type="text" id="custom-users" placeholder="例如: user1, user2, user3">
                    </div>
                    <button type="submit" class="btn btn-primary btn-block">发送通知</button>
                </form>
            </div>
        </div>
    </div>

    <!-- 定时发送模态框 -->
    <div class="modal" id="schedule-modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>定时发送通知</h2>
                <button class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <form id="schedule-form">
                    <div class="form-group">
                        <label>通知标题</label>
                        <input type="text" id="schedule-title" required>
                    </div>
                    <div class="form-group">
                        <label>通知内容</label>
                        <textarea id="schedule-content" rows="5" required></textarea>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>通知类型</label>
                            <select id="schedule-type">
                                <option value="success">成功通知</option>
                                <option value="warning">警告通知</option>
                                <option value="error">错误通知</option>
                                <option value="info">信息通知</option>
                                <option value="system">系统公告</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>目标用户</label>
                            <select id="schedule-target">
                                <option value="all">所有用户</option>
                                <option value="students">学生用户</option>
                                <option value="teachers">教师用户</option>
                                <option value="vip">VIP用户</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>发送时间</label>
                            <input type="datetime-local" id="schedule-time" required>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary btn-block">预约发送</button>
                </form>
            </div>
        </div>
    </div>

    <!-- 消息详情弹窗 -->
    <div class="detail-modal" id="detail-modal">
        <div class="detail-modal-content">
            <div class="detail-modal-header">
                <h2 id="detail-title">通知详情</h2>
                <button class="close-btn" onclick="closeDetailModal()">&times;</button>
            </div>
            <div class="detail-modal-body">
                <div class="content-text" id="detail-content"></div>
                <div class="meta-info" id="detail-meta"></div>
            </div>
        </div>
    </div>



    <script>
        var ctx = '<%= ctx %>';
        var currentChatUserId = null;

        // 标签切换
        document.querySelectorAll('.tab-btn').forEach(function(btn) {
            btn.addEventListener('click', function() {
                document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
                btn.classList.add('active');
                document.getElementById(btn.dataset.tab + '-tab').classList.add('active');
                
                if (btn.dataset.tab === 'private') {
                    loadConversations();
                }
            });
        });

        // 发送通知模态框
        document.getElementById('send-notification').addEventListener('click', function() {
            document.getElementById('send-modal').style.display = 'block';
        });

        // 定时发送模态框
        document.getElementById('schedule-notification').addEventListener('click', function() {
            document.getElementById('schedule-modal').style.display = 'block';
        });

        // 关闭模态框
        document.querySelectorAll('.close-modal').forEach(function(btn) {
            btn.addEventListener('click', function() {
                this.closest('.modal').style.display = 'none';
            });
        });

        // 点击模态框外部关闭
        window.addEventListener('click', function(e) {
            if (e.target.classList.contains('modal')) {
                e.target.style.display = 'none';
            }
        });

        // 目标用户选择变化
        document.getElementById('modal-target').addEventListener('change', function() {
            document.getElementById('custom-users-group').style.display = 
                this.value === 'custom' ? 'block' : 'none';
        });

        // 快速发送表单
        document.getElementById('quick-send-form').addEventListener('submit', function(e) {
            e.preventDefault();
            var data = {
                title: document.getElementById('quick-title').value,
                content: document.getElementById('quick-content').value,
                type: document.getElementById('quick-type').value,
                target: document.getElementById('quick-target').value,
                sendEmail: document.getElementById('send-email').checked,
                sendSms: document.getElementById('send-sms').checked
            };
            sendNotification(data);
            this.reset();
        });

        // 发送通知表单
        document.getElementById('send-form').addEventListener('submit', function(e) {
            e.preventDefault();
            var data = {
                title: document.getElementById('modal-title').value,
                content: document.getElementById('modal-content').value,
                type: document.getElementById('modal-type').value,
                target: document.getElementById('modal-target').value,
                sendEmail: document.getElementById('modal-email').checked,
                sendSms: document.getElementById('modal-sms').checked,
                customUsers: document.getElementById('custom-users').value
            };
            sendNotification(data);
            document.getElementById('send-modal').style.display = 'none';
            this.reset();
        });

        // 定时发送表单
        document.getElementById('schedule-form').addEventListener('submit', function(e) {
            e.preventDefault();
            var data = {
                title: document.getElementById('schedule-title').value,
                content: document.getElementById('schedule-content').value,
                type: document.getElementById('schedule-type').value,
                target: document.getElementById('schedule-target').value,
                scheduledTime: document.getElementById('schedule-time').value
            };
            scheduleNotification(data);
            document.getElementById('schedule-modal').style.display = 'none';
            this.reset();
        });

        // 发送通知
        function sendNotification(data) {
            // 注入 CSRF 令牌
            data._csrf = window._csrfToken || '';
            fetch(ctx + '/notifications', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            })
            .then(r => r.json())
            .then(res => {
                if (res.success) {
                    alert('通知发送成功');
                    window.location.reload();
                } else {
                    alert('发送失败: ' + (res.message || res.error || '未知错误'));
                }
            })
            .catch(e => {
                console.error('发送失败:', e);
                alert('发送失败');
            });
        }

        // 定时发送通知
        function scheduleNotification(data) {
            // 注入 CSRF 令牌
            data._csrf = window._csrfToken || '';
            fetch(ctx + '/notifications', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ ...data, scheduled: true })
            })
            .then(r => r.json())
            .then(res => {
                if (res.success) {
                    alert('定时通知已预约');
                    window.location.reload();
                } else {
                    alert('预约失败: ' + res.message);
                }
            })
            .catch(e => {
                console.error('预约失败:', e);
                alert('预约失败');
            });
        }

        // 删除通知
        function deleteNotification(id) {
            if (!confirm('确定要删除这条通知吗？')) return;
            fetch(ctx + '/notifications', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=delete&id=' + id + '&_csrf=' + encodeURIComponent(window.parent.CSRF_TOKEN || window.CSRF_TOKEN || '')
            })
            .then(r => r.json())
            .then(res => {
                if (res.success) {
                    alert('删除成功');
                    window.location.reload();
                } else {
                    alert('删除失败');
                }
            });
        }

        // 取消定时通知
        function cancelScheduled(id) {
            if (!confirm('确定要取消这条定时通知吗？')) return;
            fetch(ctx + '/notifications?id=' + id, { method: 'DELETE' })
            .then(r => r.json())
            .then(res => {
                if (res.success) {
                    alert('已取消');
                    window.location.reload();
                } else {
                    alert('取消失败');
                }
            });
        }

        // 显示通知详情
        function showNotificationDetail(id) {
            fetch(ctx + '/api/userNotifications?action=detail&id=' + id)
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    document.getElementById('detail-title').textContent = data.title || '通知详情';
                    document.getElementById('detail-content').textContent = data.content || '暂无内容';
                    var meta = '<p><i class="fas fa-clock"></i> 发送时间: ' + (data.sendTime || '未知') + '</p>';
                    meta += '<p><i class="fas fa-user"></i> 发送者: ' + (data.senderId || '系统') + '</p>';
                    meta += '<p><i class="fas fa-tag"></i> 类型: ' + getTypeName(data.type) + '</p>';
                    document.getElementById('detail-meta').innerHTML = meta;
                    document.getElementById('detail-modal').classList.add('active');
                }
            });
        }

        // 关闭详情弹窗
        function closeDetailModal() {
            document.getElementById('detail-modal').classList.remove('active');
        }

        // 获取类型名称
        function getTypeName(type) {
            var types = {
                success: '成功通知',
                warning: '警告通知',
                error: '错误通知',
                info: '信息通知',
                system: '系统公告'
            };
            return types[type] || '未知';
        }

        // ═══════════════════════════════════════════════════════════
        // 头像工具函数（与消息中心一致）
        // ═══════════════════════════════════════════════════════════
        function resolveAvatarUrl(url) {
            if (!url || !url.trim()) return '';
            var u = url.trim();
            if (u.indexOf('http://') === 0 || u.indexOf('https://') === 0 ||
                u.indexOf('data:') === 0 || u.indexOf('//') === 0) {
                return u;
            }
            return ctx + u;
        }

        function renderChatAvatar(avatarUrl, fallbackName) {
            var resolved = resolveAvatarUrl(avatarUrl);
            var initial = (fallbackName || '?').charAt(0).toUpperCase();
            if (resolved) {
                return '<div class="chat-contact-avatar">' +
                    '<img src="' + resolved + '" style="width:100%;height:100%;border-radius:50%;object-fit:cover;" onerror="this.style.display=\'none\';this.parentElement.textContent=\'' + initial + '\'">' +
                    '</div>';
            }
            return '<div class="chat-contact-avatar">' + initial + '</div>';
        }

        function formatChatTime(timeStr) {
            if (!timeStr) return '';
            try {
                var t = new Date(timeStr.replace(/-/g, '/'));
                var now = new Date();
                var h = t.getHours(), m = t.getMinutes();
                var hh = (h < 10 ? '0' : '') + h;
                var mm = (m < 10 ? '0' : '') + m;
                if (t.toDateString() === now.toDateString()) return hh + ':' + mm;
                var yesterday = new Date(now);
                yesterday.setDate(yesterday.getDate() - 1);
                if (t.toDateString() === yesterday.toDateString()) return '昨天 ' + hh + ':' + mm;
                return (t.getMonth() + 1) + '/' + t.getDate() + ' ' + hh + ':' + mm;
            } catch (e) { return ''; }
        }

        function formatChatDate(timeStr) {
            if (!timeStr) return '';
            try {
                var t = new Date(timeStr.replace(/-/g, '/'));
                var now = new Date();
                if (t.toDateString() === now.toDateString()) return '今天';
                var yesterday = new Date(now);
                yesterday.setDate(yesterday.getDate() - 1);
                if (t.toDateString() === yesterday.toDateString()) return '昨天';
                return t.getFullYear() + '年' + (t.getMonth() + 1) + '月' + t.getDate() + '日';
            } catch (e) { return ''; }
        }

        // ═══════════════════════════════════════════════════════════
        // 加载对话列表（带头像）
        // ═══════════════════════════════════════════════════════════
        function loadConversations() {
            var currentUserId = '<%= session != null ? session.getAttribute("userId") : "" %>';
            fetch(ctx + '/api/privateMessages?action=list')
            .then(r => r.json())
            .then(data => {
                var list = document.getElementById('chat-contact-list');
                if (!data.success || !data.data || data.data.length === 0) {
                    list.innerHTML = '<div class="empty-state"><i class="fas fa-message-circle"></i><p>暂无对话，点击上方 + 发起对话</p></div>';
                    return;
                }
                list.innerHTML = data.data.map(function(item) {
                    var otherUserId = (item.senderId === currentUserId) ? item.receiverId : item.senderId;
                    var name = (item.senderId === currentUserId) ? (item.receiverName || '未知用户') : (item.senderName || '未知用户');
                    var avatarUrl = (item.senderId === currentUserId) ? (item.receiverAvatar || '') : (item.senderAvatar || '');
                    var avatarHtml = renderChatAvatar(avatarUrl, name);
                    var preview = item.content || '';
                    if (preview.length > 25) preview = preview.substring(0, 25) + '...';
                    var isMe = item.senderId === currentUserId;
                    var unreadCount = item.unreadCount || 0;
                    var unreadBadge = unreadCount > 0 ? '<span class="chat-contact-unread">' + (unreadCount > 99 ? '99+' : unreadCount) + '</span>' : '';
                    var timeStr = formatChatTime(item.createdAt);
                    var isActive = currentChatUserId === otherUserId;
                    var unreadCls = unreadCount > 0 ? ' has-unread' : '';
                    return '<div class="chat-contact' + (isActive ? ' active' : '') + unreadCls + '" data-user-id="' + escapeHtml(otherUserId) + '" data-user-name="' + escapeHtml(name) + '">' +
                        avatarHtml +
                        '<div class="chat-contact-info">' +
                            '<div style="display:flex;justify-content:space-between;align-items:center;">' +
                                '<div class="chat-contact-name">' + escapeHtml(name) + '</div>' +
                                '<span style="font-size:11px;color:#666;margin-left:8px;white-space:nowrap;">' + timeStr + '</span>' +
                            '</div>' +
                            '<div class="chat-contact-preview" style="display:flex;justify-content:space-between;align-items:center;">' +
                                '<span>' + (isMe ? '<span style="color:#4A90D9;">我: </span>' : '') + escapeHtml(preview) + '</span>' +
                                unreadBadge +
                            '</div>' +
                        '</div>' +
                    '</div>';
                }).join('');
                // 绑定联系人点击事件
                bindContactEvents();
            })
            .catch(function(e) {
                console.error('加载对话列表失败:', e);
                document.getElementById('chat-contact-list').innerHTML = '<div class="empty-state"><i class="fas fa-message-circle"></i><p>加载失败</p></div>';
            });
        }

        function bindContactEvents() {
            var contacts = document.querySelectorAll('#chat-contact-list .chat-contact');
            contacts.forEach(function(c) {
                c.addEventListener('click', function() {
                    var userId = c.getAttribute('data-user-id');
                    var userName = c.getAttribute('data-user-name');
                    openChat(userId, userName);
                });
            });
        }

        // ═══════════════════════════════════════════════════════════
        // 打开聊天
        // ═══════════════════════════════════════════════════════════
        function openChat(userId, userName) {
            currentChatUserId = userId;
            document.getElementById('chat-empty').style.display = 'none';
            document.getElementById('chat-main-header').style.display = 'flex';
            document.getElementById('chat-input-area').style.display = 'flex';
            document.getElementById('chat-avatar').textContent = userName.charAt(0);
            document.getElementById('chat-name').textContent = userName;
            loadMessages(userId);
            // 更新侧栏高亮
            updateContactHighlight(userId);
        }

        function updateContactHighlight(userId) {
            var contacts = document.querySelectorAll('#chat-contact-list .chat-contact');
            contacts.forEach(function(c) {
                if (c.getAttribute('data-user-id') === userId) {
                    c.classList.add('active');
                } else {
                    c.classList.remove('active');
                }
            });
        }

        // ═══════════════════════════════════════════════════════════
        // 加载消息（带日期分隔线和发送者名）
        // ═══════════════════════════════════════════════════════════
        function loadMessages(userId) {
            var currentUserId = '<%= session != null ? session.getAttribute("userId") : "" %>';
            fetch(ctx + '/api/privateMessages?action=list&otherUserId=' + userId)
            .then(r => r.json())
            .then(data => {
                if (!data.success || !data.data) {
                    document.getElementById('chat-messages').innerHTML = '<div class="empty-state"><i class="fas fa-message-circle"></i><p>暂无消息</p></div>';
                    return;
                }
                var msgs = document.getElementById('chat-messages');
                var html = '';
                var lastDate = '';
                data.data.forEach(function(item) {
                    var msgDate = formatChatDate(item.createdAt);
                    if (msgDate !== lastDate) {
                        html += '<div style="text-align:center;margin:12px 0;"><span style="background:#2a2a4a;color:#888;padding:2px 12px;border-radius:10px;font-size:12px;">' + msgDate + '</span></div>';
                        lastDate = msgDate;
                    }
                    var isSent = item.senderId === currentUserId;
                    var senderName = isSent ? '我' : (item.senderName || '未知用户');
                    var timeStr = formatChatTime(item.createdAt);
                    html += '<div class="chat-message ' + (isSent ? 'sent' : 'received') + '">' +
                        '<div style="font-size:11px;color:#666;margin-bottom:2px;padding:0 4px;">' + (!isSent ? escapeHtml(senderName) : '') + '</div>' +
                        '<div class="chat-message-content">' + escapeHtml(item.content) + '</div>' +
                        '<div class="chat-message-time">' + timeStr + '</div>' +
                    '</div>';
                });
                msgs.innerHTML = html || '<div class="empty-state"><i class="fas fa-message-circle"></i><p>暂无消息</p></div>';
                msgs.scrollTop = msgs.scrollHeight;
            })
            .catch(function() {
                document.getElementById('chat-messages').innerHTML = '<div class="empty-state"><i class="fas fa-message-circle"></i><p>加载失败</p></div>';
            });
        }

        // ═══════════════════════════════════════════════════════════
        // 发送消息
        // ═══════════════════════════════════════════════════════════
        function sendMessage() {
            var content = document.getElementById('chat-input').value.trim();
            if (!content || !currentChatUserId) return;
            fetch(ctx + '/api/privateMessages', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ action: 'send', receiverId: currentChatUserId, content: content })
            })
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    document.getElementById('chat-input').value = '';
                    loadMessages(currentChatUserId);
                    loadConversations();
                } else {
                    alert('发送失败: ' + (data.message || '未知错误'));
                }
            })
            .catch(function() {
                alert('发送失败，请稍后重试');
            });
        }

        // ═══════════════════════════════════════════════════════════
        // 侧栏内联搜索（与消息中心一致）
        // ═══════════════════════════════════════════════════════════
        function enterNewChatMode() {
            document.getElementById('chat-sidebar-title').textContent = '新对话';
            document.getElementById('admin-chat-sidebar-search').style.display = 'block';
            document.getElementById('admin-chat-sidebar-users').style.display = 'block';
            document.getElementById('chat-contact-list').style.display = 'none';
            document.getElementById('admin-new-chat-btn').style.display = 'none';
            document.getElementById('admin-chat-search-cancel').style.display = 'inline-block';
            document.getElementById('admin-user-search-input').value = '';
            document.getElementById('admin-user-search-input').focus();
            loadUserList();
        }

        function exitNewChatMode() {
            document.getElementById('chat-sidebar-title').textContent = '私信列表';
            document.getElementById('admin-chat-sidebar-search').style.display = 'none';
            document.getElementById('admin-chat-sidebar-users').style.display = 'none';
            document.getElementById('chat-contact-list').style.display = '';
            document.getElementById('admin-new-chat-btn').style.display = '';
            document.getElementById('admin-chat-search-cancel').style.display = 'none';
            document.getElementById('admin-user-search-input').value = '';
            loadConversations();
        }

        function toggleNewChat() {
            var isSearch = document.getElementById('admin-chat-sidebar-search').style.display !== 'none';
            if (isSearch) {
                exitNewChatMode();
            } else {
                enterNewChatMode();
            }
        }

        // ═══════════════════════════════════════════════════════════
        // 加载用户列表（JSON API，带头像）
        // ═══════════════════════════════════════════════════════════
        function loadUserList() {
            var currentUserId = '<%= session != null ? session.getAttribute("userId") : "" %>';
            fetch(ctx + '/api/users?action=list')
            .then(r => r.json())
            .then(data => {
                var list = document.getElementById('admin-user-list');
                if (!data.success || !data.data) {
                    list.innerHTML = '<div class="empty-state"><i class="fas fa-users"></i><p>暂无用户</p></div>';
                    return;
                }
                var filtered = data.data.filter(function(user) {
                    return String(user.id) !== String(currentUserId);
                });
                if (filtered.length === 0) {
                    list.innerHTML = '<div class="empty-state"><i class="fas fa-users"></i><p>没有其他用户</p></div>';
                    return;
                }
                list.innerHTML = filtered.map(function(user) {
                    var name = user.nickname || user.username || '未知用户';
                    var avatarUrl = user.avatar || '';
                    var avatarHtml = renderChatAvatar(avatarUrl, name);
                    return '<div class="user-item" data-user-id="' + escapeHtml(user.id) + '" data-user-name="' + escapeHtml(name) + '">' +
                        avatarHtml +
                        '<div class="user-info">' +
                            '<div class="user-name">' + escapeHtml(name) + '</div>' +
                            '<div class="user-role">' + (user.role === 'admin' ? '管理员' : '用户') + '</div>' +
                        '</div>' +
                        '<span class="user-check">&rsaquo;</span>' +
                    '</div>';
                }).join('');
                // 绑定用户点击事件
                bindUserListEvents();
            })
            .catch(function() {
                document.getElementById('admin-user-list').innerHTML = '<div class="empty-state"><i class="fas fa-exclamation-circle"></i><p>加载失败</p></div>';
            });
        }

        function bindUserListEvents() {
            var items = document.querySelectorAll('#admin-user-list .user-item');
            items.forEach(function(item) {
                item.addEventListener('click', function() {
                    var userId = item.getAttribute('data-user-id');
                    var userName = item.getAttribute('data-user-name');
                    selectUserForChat(userId, userName);
                });
            });
        }

        function searchUsers() {
            var keyword = document.getElementById('admin-user-search-input').value.toLowerCase().trim();
            var items = document.querySelectorAll('#admin-user-list .user-item');
            items.forEach(function(item) {
                var name = item.getAttribute('data-user-name').toLowerCase();
                item.style.display = name.indexOf(keyword) !== -1 ? 'flex' : 'none';
            });
        }

        function selectUserForChat(userId, userName) {
            exitNewChatMode();
            openChat(userId, userName);
            loadConversations();
        }

        // ═══════════════════════════════════════════════════════════
        // 事件绑定
        // ═══════════════════════════════════════════════════════════
        document.getElementById('admin-new-chat-btn').addEventListener('click', function(e) {
            e.preventDefault();
            toggleNewChat();
        });
        document.getElementById('admin-chat-search-cancel').addEventListener('click', function(e) {
            e.preventDefault();
            exitNewChatMode();
        });
        document.getElementById('admin-user-search-input').addEventListener('input', searchUsers);
        // Enter 键发送
        document.getElementById('chat-input').addEventListener('keyup', function(e) {
            if (e.key === 'Enter') sendMessage();
        });

        // HTML转义
        function escapeHtml(str) {
            return str.replace(/&/g, '&amp;')
                      .replace(/</g, '&lt;')
                      .replace(/>/g, '&gt;')
                      .replace(/"/g, '&quot;')
                      .replace(/'/g, '&#039;');
        }

        // 格式化日期时间
        function formatDateTime(dateStr) {
            if (!dateStr) return '';
            var date = new Date(dateStr);
            return date.toLocaleString('zh-CN', {
                month: '2-digit',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit'
            });
        }
    </script>

    <%!
        private String getIconClass(String type) {
            if ("success".equals(type)) return "fa-check-circle";
            if ("warning".equals(type)) return "fa-exclamation-triangle";
            if ("error".equals(type)) return "fa-times-circle";
            if ("system".equals(type)) return "fa-bullhorn";
            return "fa-info-circle";
        }

        private String formatTime(java.sql.Timestamp ts) {
            if (ts == null) return "未知";
            java.util.Date date = new java.util.Date(ts.getTime());
            return new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(date);
        }
    %>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>