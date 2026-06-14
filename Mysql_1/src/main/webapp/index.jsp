<%--
 =============================================================================
 index.jsp
 =============================================================================

 用途      首页 / 主页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   EL 表达式 —— ${} 访问后端数据
   JSTL 核心标签 —— <c:forEach> / <c:if> / <c:choose>
   Ajax 异步请求 —— fetch
   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById
   input[accept] —— 文件选择器类型过滤

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <title>博雅书院 · 科技风 | 未来学府 智联万象</title>
    <!-- 引入外部库 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <!-- AI聊天功能库 -->
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/atom-one-dark.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/html-docx-js/dist/html-docx.js"></script>
    <!-- Three.js 和 Chart.js 仅在需要时按需引入 -->
    <!-- 项目样式 -->
    <link rel="stylesheet" href="CSS/index.css?v=3.1">
    <link rel="stylesheet" href="CSS/components.css?v=2.0">
    <link rel="stylesheet" href="CSS/ai-assistant.css?v=10.0">
    <!-- 个人资料修改弹窗样式（已移至 index.css） -->

</head>
<body>
<%
    // 获取当前登录用户，用于权限控制
    Object currentUser = request.getSession().getAttribute("currentUser");

    // CSRF 令牌：每会话一个，所有管理表单共享
    String csrfToken = com.ebookBuy301.util.CsrfUtil.getToken(request.getSession());
%>
<div class="academic-container">
    <aside class="sidebar" id="sidebar">
        <!-- 侧边栏品牌标识区域 -->
        <div class="sidebar-brand">
            <!-- 侧边栏折叠按钮 -->
            <div class="sidebar-toggle" id="collapseToggle" title="折叠侧边栏">
                <div class="toggle-icon">◀</div>
            </div>
            <div class="brand-inner">
                <div class="brand-icon-frame">
                    <div class="brand-icon-ring"></div>
                    <div class="brand-icon-ring brand-icon-ring-2"></div>
                    <div class="brand-icon">
                        <span class="brand-icon-char">博</span>
                    </div>
                    <div class="brand-icon-dot brand-icon-dot-1"></div>
                    <div class="brand-icon-dot brand-icon-dot-2"></div>
                    <div class="brand-icon-dot brand-icon-dot-3"></div>
                    <div class="brand-icon-dot brand-icon-dot-4"></div>
                </div>
                <div class="brand-label">
                    <div class="brand-name">博雅书院</div>
                    <div class="brand-sub">
                        <span>智</span><span class="brand-sub-dot">·</span><span>联</span><span class="brand-sub-dot">·</span><span>万</span><span class="brand-sub-dot">·</span><span>象</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- 主导航菜单 -->
        <nav class="sidebar-nav">
            <div class="nav-scroll-container" id="navScrollContainer">
                <ul class="nav-list" id="navList">
                    <li class="nav-item" data-page="home" data-title="智识首页" data-url="home">
                        <a class="nav-link">
                            <div class="nav-icon">🏠</div>
                            <span class="nav-label">智识首页</span>
                            <div class="nav-indicator"></div>
                        </a>
                    </li>
                    <li class="nav-item" data-page="bookshelf" data-title="我的书架" data-url="majorsPage">
                        <a class="nav-link">
                            <div class="nav-icon">📚</div>
                            <span class="nav-label">我的书架</span>
                            <div class="nav-indicator"></div>
                        </a>
                    </li>
                    <li class="nav-item" data-page="reading" data-title="阅读中心" data-url="recommend">
                        <a class="nav-link">
                            <div class="nav-icon">📖</div>
                            <span class="nav-label">阅读中心</span>
                            <div class="nav-indicator"></div>
                        </a>
                    </li>
                    <li class="nav-item" data-page="notes" data-title="笔记中心" data-url="notesPage">
                        <a class="nav-link">
                            <div class="nav-icon">📝</div>
                            <span class="nav-label">笔记中心</span>
                            <div class="nav-indicator"></div>
                        </a>
                    </li>
                    <li class="nav-item" data-page="growth" data-title="成长中心" data-url="growthPage">
                        <a class="nav-link">
                            <div class="nav-icon">🏆</div>
                            <span class="nav-label">成长中心</span>
                            <div class="nav-indicator"></div>
                        </a>
                    </li>
                    <li class="nav-item" data-page="resources" data-title="资源中心" data-url="resourcePage">
                        <a class="nav-link">
                            <div class="nav-icon">🔍</div>
                            <span class="nav-label">资源中心</span>
                            <div class="nav-indicator"></div>
                        </a>
                    </li>
                    <li class="nav-item" data-page="settings" data-title="设置中心" data-url="settings">
                        <a class="nav-link">
                            <div class="nav-icon">⚙️</div>
                            <span class="nav-label">设置中心</span>
                            <div class="nav-indicator"></div>
                        </a>
                    </li>
                </ul>
            </div>
        </nav>

        <%-- 折叠式系统管理菜单 - 仅管理员可见 --%>
        <% boolean isAdmin = currentUser != null && 
                            ((com.ebookBuy301.pojo.Users)currentUser).getRole() != null &&
                            ((com.ebookBuy301.pojo.Users)currentUser).getRole().equals("admin");
        %>
        <div class="admin-section <%= isAdmin ? "admin-visible" : "" %>" id="adminSection">
            <div class="admin-toggle" id="adminToggle">
                <div class="admin-icon">⚙</div>
                <span class="admin-label">系统管理</span>
                <div class="toggle-arrow">▼</div>
            </div>
            <div class="admin-menu" id="adminMenu">
                <div class="admin-menu-content">
                    <ul class="admin-nav-list">
                        <li class="admin-nav-item" data-page="adminDashboard" data-title="管理驾驶舱" data-url="adminDashboard">
                            <a class="admin-nav-link">
                                <div class="admin-nav-icon">🚀</div>
                                <span class="admin-nav-label">管理驾驶舱</span>
                            </a>
                        </li>
                        <li class="admin-nav-item" data-page="usersList" data-title="用户列表" data-url="usersList">
                            <a class="admin-nav-link">
                                <div class="admin-nav-icon">👥</div>
                                <span class="admin-nav-label">用户列表</span>
                            </a>
                        </li>
                        <li class="admin-nav-item" data-page="booksList" data-title="图书列表" data-url="booksList">
                            <a class="admin-nav-link">
                                <div class="admin-nav-icon">📚</div>
                                <span class="admin-nav-label">图书管理</span>
                            </a>
                        </li>
                        <li class="admin-nav-item" data-page="bookTypeList" data-title="分类管理" data-url="bookTypeList">
                            <a class="admin-nav-link">
                                <div class="admin-nav-icon">📂</div>
                                <span class="admin-nav-label">分类管理</span>
                            </a>
                        </li>
                        <li class="admin-nav-item" data-page="contentReview" data-title="内容审核" data-url="contentReview">
                            <a class="admin-nav-link">
                                <div class="admin-nav-icon">✅</div>
                                <span class="admin-nav-label">内容审核</span>
                            </a>
                        </li>
                        <li class="admin-nav-item" data-page="notifications" data-title="通知推送" data-url="notifications">
                            <a class="admin-nav-link">
                                <div class="admin-nav-icon">📢</div>
                                <span class="admin-nav-label">通知推送</span>
                            </a>
                        </li>
                        <li class="admin-nav-item" data-page="adminPush" data-title="消息推送管理" data-url="adminPush">
                            <a class="admin-nav-link">
                                <div class="admin-nav-icon">📡</div>
                                <span class="admin-nav-label">讲坛和导师推送</span>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- 侧边栏底部 -->
        <div class="sidebar-footer">
            <div class="footer-content">
                <div class="data-flow">
                    <div class="flow-dot"></div>
                    <div class="flow-dot delayed"></div>
                    <div class="flow-dot delayed-2"></div>
                </div>
                <span class="footer-text">数据驱动 · 智周万物</span>
                <div class="footer-version">v2.4.1</div>
            </div>
        </div>
    </aside>

    <main class="main-content">
        <div class="content-header">
            <div class="breadcrumb">
                <span>BOYA</span> <span style="margin:0 6px">/</span> <span id="currentMenuName">博雅书院</span>
            </div>
            <div class="header-right">
                <div class="search-container">
                    <button class="search-btn" id="searchBtn" title="搜索">
                        🔍
                    </button>
                </div>
                <div class="notification-center">
                    <button class="notification-btn" id="notificationBtn" title="通知">
                        🔔
                        <span class="notification-badge" id="notificationBadge" style="display:none;">0</span>
                    </button>
                </div>
                <!-- 🎨 主题切换触发按钮 -->
                <div class="theme-dropdown-container">
                    <button class="theme-toggle-btn" id="themeToggleBtn" title="灵活的主题系统">
                        <span class="theme-toggle-icon">🎨</span>
                    </button>
                </div>

                <!-- 🎨 3D环形旋转主题选择器（全屏浮层） -->
                <div class="theme-ring-panel" id="themeRingPanel">
                    <div class="theme-ring-backdrop" id="themeRingBackdrop"></div>
                    <div class="theme-ring-card">
                        <button class="theme-ring-close" id="themeRingClose">✕</button>
                        <div class="theme-ring-header">
                            <div class="theme-ring-title">
                                <span class="theme-ring-title-icon"></span>
                                主题系统
                            </div>
                        </div>
                        <!-- 环形轨道 -->
                        <div class="theme-ring-orbit" id="themeRingOrbit">
                            <div class="theme-ring-center" id="themeRingCenter">Theme</div>
                            <div class="theme-ring-track" id="themeRingTrack">
                                <!-- 8个方块由JS动态定位 -->
                                <div class="theme-ring-item" data-theme="apple-light">
                                    <span class="theme-ring-item-label">浅灰极简</span>
                                </div>
                                <div class="theme-ring-item" data-theme="notion-light">
                                    <span class="theme-ring-item-label">金黄暖调</span>
                                </div>
                                <div class="theme-ring-item" data-theme="weread-light">
                                    <span class="theme-ring-item-label">橄榄书香</span>
                                </div>
                                <div class="theme-ring-item" data-theme="quantum-matrix">
                                    <span class="theme-ring-item-label">深灰蓝调</span>
                                </div>
                                <div class="theme-ring-item" data-theme="campus-light">
                                    <span class="theme-ring-item-label">奶油校园</span>
                                </div>
                                <div class="theme-ring-item" data-theme="nebula-dream">
                                    <span class="theme-ring-item-label">暗红星云</span>
                                </div>
                                <div class="theme-ring-item" data-theme="cyber-neon">
                                    <span class="theme-ring-item-label">橙红赛博</span>
                                </div>
                                <div class="theme-ring-item" data-theme="data-stream">
                                    <span class="theme-ring-item-label">深炭流光</span>
                                </div>
                            </div>
                        </div>
                        <!-- 旋转控制 -->
                        <div class="theme-ring-controls">
                            <button class="theme-ring-rotate-btn" id="themeRotateLeft" title="向左旋转">◀</button>
                            <span class="theme-ring-current-name" id="themeCurrentName">量子矩阵</span>
                            <button class="theme-ring-rotate-btn" id="themeRotateRight" title="向右旋转">▶</button>
                        </div>
                    </div>
                </div>
                <button class="login-btn" id="loginBtn">
                    <span>🔐</span>
                    <span>登录</span>
                </button>
                <div class="user-info" id="userInfo">
                    <div class="user-avatar" id="userAvatar">👤</div>
                    <span class="user-name" id="userName">用户</span>
                    <button class="logout-btn" id="logoutBtn">退出</button>
                </div>

            </div>
        </div>
        
        <!-- Session 用户信息（用于前后端交互） -->
        <%
            String sessionUser = null;
            String sessionUserId = null;
            String sessionRole = "user"; // 默认普通用户
            String sessionNickname = "";
            String sessionAvatar = "";
            // currentUser 已在页面顶部定义
            if (currentUser != null) {
                com.ebookBuy301.pojo.Users user = (com.ebookBuy301.pojo.Users)currentUser;
                sessionUser = user.getUsername();
                sessionUserId = user.getId();
                sessionNickname = user.getNickname() != null && !user.getNickname().isEmpty() ? user.getNickname() : user.getUsername();
                sessionAvatar = user.getAvatar() != null ? user.getAvatar() : "";
                // 管理员判断：从数据库 role 字段读取
                if (user.getRole() != null && user.getRole().equals("admin")) {
                    sessionRole = "admin";
                }
            }
        %>
        <%!
            // HTML属性转义工具函数
            String htmlEscape(String s) {
                if (s == null) return "";
                return s.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;").replace("'", "&#39;");
            }
        %>
        <input type="hidden" id="sessionUser" value="<%= htmlEscape(sessionUser != null ? sessionUser : "") %>">
        <input type="hidden" id="sessionRole" value="<%= htmlEscape(sessionRole) %>">
        <input type="hidden" id="sessionNickname" value="<%= htmlEscape(sessionNickname) %>">
        <input type="hidden" id="sessionAvatar" value="<%= htmlEscape(sessionAvatar) %>">
        <input type="hidden" id="sessionUserId" value="<%= htmlEscape(sessionUserId != null ? sessionUserId : "") %>">
        <%
            // 转义特殊字符用于JS输出（防止HTML/JS注入）
            String jsonAvatar = sessionAvatar.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
            String jsonNickname = sessionNickname.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
            String jsonUsername = (sessionUser != null ? sessionUser : "").replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
            String jsonUserId = (sessionUserId != null ? sessionUserId : "").replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
        %>
        <%
            String sessionSex = "";
            String sessionEmail = "";
            if (currentUser != null) {
                com.ebookBuy301.pojo.Users user = (com.ebookBuy301.pojo.Users)currentUser;
                sessionSex = user.getSex() != null ? user.getSex() : "";
                sessionEmail = user.getEmail() != null ? user.getEmail() : "";
            }
            String jsonSex = sessionSex.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
            String jsonEmail = sessionEmail.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
        %>
        <script>
            // 将用户信息保存到全局变量，方便JS安全读取
            window._currentUserInfo = {
                id: '<%= jsonUserId %>',
                username: '<%= jsonUsername %>',
                nickname: '<%= jsonNickname %>',
                avatar: '<%= jsonAvatar %>',
                sex: '<%= jsonSex %>',
                email: '<%= jsonEmail %>'
            };
        </script>
        <input type="hidden" id="sessionSex" value="<%= sessionSex %>">
        <input type="hidden" id="sessionEmail" value="<%= sessionEmail %>">
        
        <div class="iframe-wrapper">
            <iframe id="academicFrame" src="home" title="博雅动态" sandbox="allow-same-origin allow-scripts allow-popups allow-forms allow-modals allow-downloads allow-top-navigation-by-user-activation"></iframe>
        </div>
    </main>
</div>

<!-- ===== 个人资料修改弹窗 ===== -->
<div class="profile-modal-overlay" id="profileModalOverlay">
    <div class="profile-modal" id="profileModal">
        <div class="profile-modal-header">
            <h3>个人资料</h3>
            <button class="profile-modal-close" id="profileModalClose">✕</button>
        </div>
        <div class="profile-modal-body">
            <!-- 头像展示（可点击） -->
            <div class="profile-avatar-section">
                <div class="profile-avatar-preview" id="profileAvatarPreview" style="cursor:pointer;">👤</div>
                <!-- 点击头像弹出的选择菜单（独立在外面，避免被 innerHTML 清掉） -->
                <div class="avatar-options-menu" id="avatarOptionsMenu">
                    <div class="avatar-option" id="avatarOptionLocal">
                        <span class="avatar-option-icon">📁</span>
                        <span class="avatar-option-text">本地上传</span>
                    </div>
                    <div class="avatar-option" id="avatarOptionUrl">
                        <span class="avatar-option-icon">🔗</span>
                        <span class="avatar-option-text">网络链接</span>
                    </div>
                </div>
                <div style="font-size:12px;color:rgba(255,255,255,0.35);">点击头像更换</div>
            </div>

            <!-- 隐藏的文件输入 -->
            <input type="file" id="avatarFileInput" accept="image/*" style="display:none;">

            <!-- 隐藏的网络链接输入（选择"网络链接"后显示） -->
            <div class="profile-field" id="avatarUrlField" style="display:none;">
                <label>头像链接</label>
                <input type="text" id="avatarUrlInput" placeholder="输入图片URL">
                <div class="hint">支持 https:// 网络图片链接</div>
            </div>

            <!-- 提示消息 -->
            <div class="profile-message" id="profileMessage"></div>

            <!-- 表单字段 -->
            <div class="profile-field">
                <label>昵称</label>
                <input type="text" id="profileNicknameInput" placeholder="输入昵称（选填）" maxlength="20">
            </div>
            <div class="profile-field">
                <label>性别</label>
                <select id="profileSexSelect">
                    <option value="">-- 请选择 --</option>
                    <option value="男">男</option>
                    <option value="女">女</option>
                    <option value="未知">未知</option>
                </select>
            </div>
            <div class="profile-field">
                <label>邮箱</label>
                <input type="email" id="profileEmailInput" placeholder="输入邮箱地址">
            </div>
        </div>
        <div class="profile-modal-footer">
            <button class="profile-btn profile-btn-secondary" id="profileCancelBtn">取消</button>
            <button class="profile-btn profile-btn-primary" id="profileSaveBtn">保存修改</button>
        </div>
    </div>
</div>

<!-- ===== AI API Key 设置弹窗 ===== -->
<div class="api-key-modal-overlay" id="apiKeyModalOverlay">
    <div class="api-key-modal" id="apiKeyModal">
        <div class="api-key-modal-header">
            <h3 id="apiKeyModalTitle">🔑 API Key 设置</h3>
            <button class="api-key-modal-close" id="apiKeyModalClose">✕</button>
        </div>
        <div class="api-key-modal-body">
            <div class="api-key-notice" id="apiKeyNotice" style="display:none;">
                <span class="api-key-notice-icon">🔒</span>
                <span id="apiKeyNoticeText"></span>
            </div>
            <div class="api-key-field">
                <label>API 地址</label>
                <input type="text" id="apiKeyUrlInput" placeholder="https://api.deepseek.com/chat/completions" autocomplete="off">
            </div>
            <div class="api-key-field">
                <label>API Key</label>
                <input type="password" id="apiKeyValueInput" placeholder="sk-xxxxxxxxxxxxxxxx" autocomplete="off">
                <button class="api-key-toggle-vis" id="apiKeyToggleVis" title="显示/隐藏">👁</button>
            </div>
            <div class="api-key-field" id="apiKeyModelField">
                <label>模型名称</label>
                <input type="text" id="apiKeyModelInput" placeholder="deepseek-chat" autocomplete="off">
            </div>
            <div class="api-key-saved-info" id="apiKeySavedInfo" style="display:none;">
                <span>✅ 已保存配置</span>
            </div>
            <!-- 快速预设 -->
            <div class="api-key-presets" id="apiKeyPresets">
                <span class="preset-label">快速预设：</span>
                <button class="preset-chip" data-name="DeepSeek" data-url="https://api.deepseek.com/chat/completions" data-model="deepseek-chat">DeepSeek</button>
                <button class="preset-chip" data-name="硅基流动" data-url="https://api.siliconflow.cn/v1/chat/completions" data-model="deepseek-ai/DeepSeek-V3">硅基流动</button>
                <button class="preset-chip" data-name="OpenAI" data-url="https://api.openai.com/v1/chat/completions" data-model="gpt-3.5-turbo">OpenAI</button>
                <button class="preset-chip" data-name="Groq" data-url="https://api.groq.com/openai/v1/chat/completions" data-model="llama-3.3-70b-versatile">Groq</button>
            </div>
        </div>
        <div class="api-key-modal-footer">
            <button class="api-key-btn api-key-btn-secondary" id="apiKeyClearBtn">清除配置</button>
            <button class="api-key-btn api-key-btn-secondary" id="apiKeyCancelBtn">取消</button>
            <button class="api-key-btn api-key-btn-primary" id="apiKeySaveBtn">保存</button>
        </div>
    </div>
</div>

<script>
    // 定义全局变量供 modules.js 使用
    window.CONTEXT_PATH = '<%= request.getContextPath() %>';
    window.USER_ROLE = '<%= htmlEscape(sessionRole) %>';
    window.IS_ADMIN = <%= isAdmin %>;
    window.USER_NAME = '<%= htmlEscape(sessionUser != null ? sessionUser : "") %>';
    window.USER_ID = '<%= htmlEscape(sessionUserId != null ? sessionUserId : "") %>';
    window.CSRF_TOKEN = '<%= csrfToken %>';
</script>
<script src="js/modules.js?v=7.0"></script>
<script src="js/shell.js?v=1.0"></script>
<!-- ===== AI 助教现代化组件 ===== -->
<!-- AI 悬浮按钮 -->
<button class="ai-fab" id="aiFab" title="博雅小星 AI 助手">
    <span class="ai-fab-icon">
        <svg viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
            <defs>
                <!-- 书本3D渐变 -->
                <linearGradient id="bookGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stop-color="#ffffff"/>
                    <stop offset="50%" stop-color="#e8e8e8"/>
                    <stop offset="100%" stop-color="#d0d0d0"/>
                </linearGradient>
                <!-- 星星3D渐变 -->
                <linearGradient id="starGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stop-color="#ffffff"/>
                    <stop offset="40%" stop-color="#fffde7"/>
                    <stop offset="100%" stop-color="#ffd54f"/>
                </linearGradient>
                <!-- 阴影 -->
                <filter id="iconShadow" x="-20%" y="-20%" width="140%" height="140%">
                    <feDropShadow dx="0" dy="2" stdDeviation="2" flood-color="#000" flood-opacity="0.25"/>
                </filter>
                <filter id="starGlow" x="-30%" y="-30%" width="160%" height="160%">
                    <feGaussianBlur stdDeviation="1.5" result="blur"/>
                    <feMerge>
                        <feMergeNode in="blur"/>
                        <feMergeNode in="SourceGraphic"/>
                    </feMerge>
                </filter>
            </defs>
            <!-- 左页（带厚度） -->
            <path d="M6 10C6 9.5 6.4 9 7 9H15V27H7C6.4 27 6 26.5 6 26V10Z" fill="url(#bookGrad)" filter="url(#iconShadow)"/>
            <path d="M6 10H15V12H6V10Z" fill="#b8b8b8" opacity="0.6"/>
            <!-- 右页（带厚度） -->
            <path d="M34 10C34 9.5 33.6 9 33 9H25V27H33C33.6 27 34 26.5 34 26V10Z" fill="url(#bookGrad)" filter="url(#iconShadow)"/>
            <path d="M25 10H34V12H25V10Z" fill="#b8b8b8" opacity="0.6"/>
            <!-- 书脊 -->
            <path d="M15 9V27" stroke="#c0c0c0" stroke-width="1.5"/>
            <!-- 书页纹理 -->
            <path d="M8 14H13" stroke="#b0b0b0" stroke-width="0.8"/>
            <path d="M8 17H13" stroke="#b0b0b0" stroke-width="0.8"/>
            <path d="M8 20H13" stroke="#b0b0b0" stroke-width="0.8"/>
            <path d="M27 14H32" stroke="#b0b0b0" stroke-width="0.8"/>
            <path d="M27 17H32" stroke="#b0b0b0" stroke-width="0.8"/>
            <path d="M27 20H32" stroke="#b0b0b0" stroke-width="0.8"/>
            <!-- 3D星星 -->
            <g filter="url(#starGlow)">
                <path d="M20 3L21.5 6.8L25 6L22.5 9L25 12L20 10.5L15 12L17.5 9L15 6L18.5 6.8L20 3Z" fill="url(#starGrad)"/>
                <!-- 星星高光 -->
                <ellipse cx="19" cy="7" rx="1" ry="0.8" fill="white" opacity="0.7"/>
            </g>
        </svg>
    </span>
    <span class="ai-fab-badge" id="aiFabBadge">1</span>
</button>

<!-- AI 遮罩层（移动端使用） -->
<div class="ai-overlay" id="aiOverlay"></div>

<!-- AI 聊天面板（右侧滑入） -->
<div class="ai-panel" id="aiPanel">
    <!-- 头部 -->
    <div class="ai-panel-header">
        <div class="ai-panel-header-left">
            <div class="ai-header-avatar">
                <svg viewBox="0 0 40 40" width="22" height="22" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <defs>
                        <linearGradient id="bookGrad2" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stop-color="#ffffff"/>
                            <stop offset="50%" stop-color="#e8e8e8"/>
                            <stop offset="100%" stop-color="#d0d0d0"/>
                        </linearGradient>
                        <linearGradient id="starGrad2" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stop-color="#ffffff"/>
                            <stop offset="40%" stop-color="#fffde7"/>
                            <stop offset="100%" stop-color="#ffd54f"/>
                        </linearGradient>
                        <filter id="iconShadow2" x="-20%" y="-20%" width="140%" height="140%">
                            <feDropShadow dx="0" dy="1.5" stdDeviation="1" flood-color="#000" flood-opacity="0.2"/>
                        </filter>
                        <filter id="starGlow2" x="-30%" y="-30%" width="160%" height="160%">
                            <feGaussianBlur stdDeviation="1" result="blur"/>
                            <feMerge>
                                <feMergeNode in="blur"/>
                                <feMergeNode in="SourceGraphic"/>
                            </feMerge>
                        </filter>
                    </defs>
                    <path d="M6 10C6 9.5 6.4 9 7 9H15V27H7C6.4 27 6 26.5 6 26V10Z" fill="url(#bookGrad2)" filter="url(#iconShadow2)"/>
                    <path d="M6 10H15V12H6V10Z" fill="#b8b8b8" opacity="0.6"/>
                    <path d="M34 10C34 9.5 33.6 9 33 9H25V27H33C33.6 27 34 26.5 34 26V10Z" fill="url(#bookGrad2)" filter="url(#iconShadow2)"/>
                    <path d="M25 10H34V12H25V10Z" fill="#b8b8b8" opacity="0.6"/>
                    <path d="M15 9V27" stroke="#c0c0c0" stroke-width="1.5"/>
                    <path d="M8 14H13" stroke="#b0b0b0" stroke-width="0.8"/>
                    <path d="M8 17H13" stroke="#b0b0b0" stroke-width="0.8"/>
                    <path d="M8 20H13" stroke="#b0b0b0" stroke-width="0.8"/>
                    <path d="M27 14H32" stroke="#b0b0b0" stroke-width="0.8"/>
                    <path d="M27 17H32" stroke="#b0b0b0" stroke-width="0.8"/>
                    <path d="M27 20H32" stroke="#b0b0b0" stroke-width="0.8"/>
                    <g filter="url(#starGlow2)">
                        <path d="M20 3L21.5 6.8L25 6L22.5 9L25 12L20 10.5L15 12L17.5 9L15 6L18.5 6.8L20 3Z" fill="url(#starGrad2)"/>
                        <ellipse cx="19" cy="7" rx="1" ry="0.8" fill="white" opacity="0.7"/>
                    </g>
                </svg>
            </div>
            <div class="ai-header-info">
                <div class="ai-header-name">博雅小星</div>
                <div class="ai-header-status">
                    <span class="ai-header-status-dot"></span>
                    <span>在线 · 深度思考模式</span>
                </div>
            </div>
        </div>
        <div class="ai-panel-header-actions">
            <button class="ai-header-btn" id="aiExportBtn" title="导出对话">📄</button>
            <button class="ai-header-btn" id="aiClearBtn" title="清空对话">🗑</button>
            <button class="ai-header-btn ai-close-btn" id="aiCloseBtn" title="关闭">✕</button>
        </div>
    </div>

    <!-- 模型选择栏 -->
    <div class="ai-model-bar">
        <span class="ai-model-label">模型</span>
        <select class="ai-model-select" id="aiModelSelect">
            <optgroup label="DeepSeek">
                <option value="deepseek-chat">DeepSeek Chat</option>
                <option value="deepseek-reasoner">DeepSeek Reasoner</option>
            </optgroup>
            <optgroup label="通义千问">
                <option value="qwen-max">Qwen Max</option>
                <option value="qwen-plus">Qwen Plus</option>
                <option value="qwen-turbo" selected>Qwen Turbo</option>
            </optgroup>
            <optgroup label="Kimi">
                <option value="moonshot-v1-8k">Kimi v1 (8K)</option>
                <option value="moonshot-v1-32k">Kimi v1 (32K)</option>
                <option value="moonshot-v1-128k">Kimi v1 (128K)</option>
            </optgroup>
            <optgroup label="自定义模型">
                <option value="__custom__">🔧 添加自定义模型...</option>
            </optgroup>
        </select>
        <button class="ai-model-settings-btn" id="aiModelSettingsBtn" title="API Key 设置">🔑</button>
        <span class="ai-stats" id="aiStats">0 条消息</span>
    </div>

    <!-- 消息列表 -->
    <div class="ai-messages" id="aiMessages">
        <div class="ai-welcome" id="aiWelcome">
            <div class="ai-welcome-icon">
                <svg viewBox="0 0 40 40" width="56" height="56" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <defs>
                        <linearGradient id="bookGrad3" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stop-color="#ffffff"/>
                            <stop offset="50%" stop-color="#e8e8e8"/>
                            <stop offset="100%" stop-color="#d0d0d0"/>
                        </linearGradient>
                        <linearGradient id="starGrad3" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stop-color="#ffffff"/>
                            <stop offset="40%" stop-color="#fffde7"/>
                            <stop offset="100%" stop-color="#ffd54f"/>
                        </linearGradient>
                        <filter id="iconShadow3" x="-20%" y="-20%" width="140%" height="140%">
                            <feDropShadow dx="0" dy="2" stdDeviation="2" flood-color="#000" flood-opacity="0.25"/>
                        </filter>
                        <filter id="starGlow3" x="-30%" y="-30%" width="160%" height="160%">
                            <feGaussianBlur stdDeviation="1.5" result="blur"/>
                            <feMerge>
                                <feMergeNode in="blur"/>
                                <feMergeNode in="SourceGraphic"/>
                            </feMerge>
                        </filter>
                    </defs>
                    <path d="M6 10C6 9.5 6.4 9 7 9H15V27H7C6.4 27 6 26.5 6 26V10Z" fill="url(#bookGrad3)" filter="url(#iconShadow3)"/>
                    <path d="M6 10H15V12H6V10Z" fill="#b8b8b8" opacity="0.6"/>
                    <path d="M34 10C34 9.5 33.6 9 33 9H25V27H33C33.6 27 34 26.5 34 26V10Z" fill="url(#bookGrad3)" filter="url(#iconShadow3)"/>
                    <path d="M25 10H34V12H25V10Z" fill="#b8b8b8" opacity="0.6"/>
                    <path d="M15 9V27" stroke="#c0c0c0" stroke-width="1.5"/>
                    <path d="M8 14H13" stroke="#b0b0b0" stroke-width="0.8"/>
                    <path d="M8 17H13" stroke="#b0b0b0" stroke-width="0.8"/>
                    <path d="M8 20H13" stroke="#b0b0b0" stroke-width="0.8"/>
                    <path d="M27 14H32" stroke="#b0b0b0" stroke-width="0.8"/>
                    <path d="M27 17H32" stroke="#b0b0b0" stroke-width="0.8"/>
                    <path d="M27 20H32" stroke="#b0b0b0" stroke-width="0.8"/>
                    <g filter="url(#starGlow3)">
                        <path d="M20 3L21.5 6.8L25 6L22.5 9L25 12L20 10.5L15 12L17.5 9L15 6L18.5 6.8L20 3Z" fill="url(#starGrad3)"/>
                        <ellipse cx="19" cy="7" rx="1" ry="0.8" fill="white" opacity="0.7"/>
                    </g>
                </svg>
            </div>
            <div class="ai-welcome-title">你好，我是博雅小星</div>
            <div class="ai-welcome-sub">我是你的智能学习助手，可以帮你解答问题、编写代码、提供学习建议</div>
            <div class="ai-welcome-suggestions">
                <span class="ai-suggestion-chip" data-text="帮我推荐一些Java学习资源">📚 推荐学习资源</span>
                <span class="ai-suggestion-chip" data-text="Python和Java有什么区别">💡 语言对比</span>
                <span class="ai-suggestion-chip" data-text="用CSS写一个漂亮的按钮">🎨 写段代码</span>
                <span class="ai-suggestion-chip" data-text="解释一下什么是微服务架构">🔍 概念解释</span>
            </div>
        </div>
    </div>

    <!-- 输入区域 -->
    <div class="ai-input-area">
        <div class="ai-input-wrapper">
            <textarea class="ai-textarea" id="aiInput" rows="1" placeholder="输入你的问题..." autocomplete="off"></textarea>
            <button class="ai-send-btn" id="aiSendBtn" disabled>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="22" y1="2" x2="11" y2="13"></line>
                    <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
                </svg>
            </button>
        </div>
        <div class="ai-input-tools">
            <button class="ai-input-tool-btn" id="aiVoiceBtn" title="语音输入">🎤</button>
        </div>
    </div>

    <!-- 底部 -->
    <div class="ai-footer">博雅书院 · 深度思考 AI 助手</div>
</div>

<!-- 移动端菜单按钮 -->
<button class="mobile-menu-btn" id="mobileMenuBtn">
    ☰
</button>

<!-- 移动端菜单遮罩层 -->
<div class="mobile-menu-overlay" id="mobileMenuOverlay"></div>

<!-- 搜索弹窗 -->
<div class="search-modal" id="searchModal" style="display: none;">
    <div class="search-modal-content">
        <div class="search-header">
            <h3>全局智识搜索</h3>
            <button class="close-search" id="closeSearch">×</button>
        </div>
        <div class="search-input-container">
            <input type="text" class="search-input" id="searchInput" placeholder="搜索课程、导师、图书、论文..." autocomplete="off">
            <button class="search-submit" id="searchSubmit">搜索</button>
        </div>
        <div class="search-tabs">
            <button class="search-tab active" data-type="all">全部</button>
            <button class="search-tab" data-type="courses">课程</button>
            <button class="search-tab" data-type="teachers">导师</button>
            <button class="search-tab" data-type="books">图书</button>
            <button class="search-tab" data-type="papers">论文</button>
            <button class="search-tab" data-type="alumni">校友</button>
            <% if (isAdmin) { %>
            <span class="search-tab-separator">|</span>
            <button class="search-tab admin-search-tab" data-type="users">👥 用户</button>
            <button class="search-tab admin-search-tab" data-type="booktypes">📂 分类</button>
            <button class="search-tab admin-search-tab" data-type="notifications">📢 通知</button>
            <button class="search-tab admin-search-tab" data-type="reviews">✅ 审核</button>
            <% } %>
        </div>
        <div class="search-history">
            <h4>最近搜索</h4>
            <div class="history-tags" id="historyTags">
                <span class="history-tag">人工智能</span>
                <span class="history-tag">量子计算</span>
                <span class="history-tag">数字人文</span>
            </div>
        </div>
        <div class="search-hot">
            <h4>热门搜索</h4>
            <div class="hot-tags" id="hotTags">
                <span class="hot-tag">元宇宙</span>
                <span class="hot-tag">深度学习</span>
                <span class="hot-tag">区块链</span>
                <span class="hot-tag">Web开发</span>
            </div>
        </div>
    </div>
</div>

<!-- ===== 通知面板 ===== -->
<div class="notification-panel" id="notificationPanel">
    <div class="notif-panel-header">
        <h3><span>🔔</span> 消息中心</h3>
        <div class="notif-header-right">
            <button class="notif-btn-text" id="markAllReadBtn" title="全部已读">✓ 全部已读</button>
            <button class="notif-btn-text" id="sendMessageBtn" title="发送私信">💬 发私信</button>
            <button class="notif-close-btn" id="closeNotifications">✕</button>
        </div>
    </div>
    <div class="notif-tabs" id="notifTabs">
        <button class="notif-tab active" data-tab="notifications">📢 通知</button>
        <button class="notif-tab" data-tab="messages">💬 私信</button>
    </div>
    <div class="notif-stats" id="notifStats">
        <span class="notif-stat-count" id="notifCount">加载中...</span>
        <button class="notif-btn-clear" id="clearReadBtn">清除已读</button>
    </div>
    <div class="notif-list" id="notificationList">
        <div class="notif-empty">🔔 加载中...</div>
    </div>
        <div class="chat-container" id="chatContainer" style="display:none;">
        <div class="chat-sidebar" id="chatSidebar">
            <div class="chat-sidebar-header" id="chatSidebarHeader">
                <span class="chat-title" id="chatSidebarTitle">私信列表</span>
                <div class="chat-sidebar-header-right">
                    <button class="new-chat-btn" id="newChatBtn">+ 发起对话</button>
                    <button class="chat-search-cancel" id="chatSearchCancel" style="display:none">取消</button>
                </div>
            </div>
            <!-- 内嵌搜索 -->
            <div class="chat-sidebar-search" id="chatSidebarSearch" style="display:none">
                <input type="text" id="userSearchInput" placeholder="搜索联系人...">
            </div>
            <div class="chat-sidebar-users" id="chatSidebarUsers" style="display:none">
                <div class="user-list-inline" id="userList">
                    <div class="notif-empty">加载中...</div>
                </div>
            </div>
            <div class="chat-contact-list" id="chatContactList">
                <div class="notif-empty">暂无对话</div>
            </div>
        </div>
        <div class="chat-main" id="chatMain">
            <div class="chat-header" id="chatHeader">
                <div class="chat-header-left">
                    <button class="chat-back-btn" id="chatBackBtn" title="返回列表">←</button>
                    <span class="chat-user-name">选择一个对话</span>
                </div>
                <button class="chat-close-btn" id="closeChatBtn">✕</button>
            </div>
            <div class="chat-messages" id="chatMessages">
                <div class="chat-empty">选择对话开始聊天</div>
            </div>
            <div class="chat-input-area">
                <input type="text" id="chatInput" placeholder="输入消息...">
                <button class="chat-send-btn" id="sendChatBtn">发送</button>
            </div>
        </div>
    </div>
    <div class="notif-footer" id="notificationFooter" style="display:none">
        <button class="notif-btn-load" id="loadMoreBtn">加载更多 ↓</button>
    </div>
</div>

<!-- 消息详情弹窗 -->
<div class="notification-detail-modal" id="notificationDetailModal">
    <div class="modal-overlay" id="detailModalOverlay"></div>
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="detailTitle">通知详情</h3>
            <button class="modal-close-btn" id="closeDetailBtn">✕</button>
        </div>
        <div class="modal-body">
            <div class="detail-type" id="detailType"></div>
            <div class="detail-content" id="detailContent"></div>
            <div class="detail-meta" id="detailMeta"></div>
        </div>
        <div class="modal-footer">
            <button class="modal-btn" id="closeDetailModalBtn">关闭</button>
        </div>
    </div>
</div>
</body>
</html>
