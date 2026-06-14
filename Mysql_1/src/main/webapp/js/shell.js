/* ========================================
   博雅书院 Shell 脚本 - 主框架交互逻辑
   从 index.jsp 内联脚本提取，便于缓存和模块管理
   依赖：modules.js (setTheme, initSidebarSystem)
   ======================================== */

    (function() {
        const sidebar = document.getElementById('sidebar');
        const collapseBtn = document.getElementById('collapseToggle');
        const menuItems = document.querySelectorAll('.nav-item');
        const currentMenuSpan = document.getElementById('currentMenuName');
        const iframe = document.getElementById('academicFrame');
        let activeItem = null;

        function initCollapse() {
            let collapsed = false;
            collapseBtn.addEventListener('click', () => {
                collapsed = !collapsed;
                if (collapsed) {
                    sidebar.classList.add('collapsed');
                    collapseBtn.innerHTML = '▶';
                } else {
                    sidebar.classList.remove('collapsed');
                    collapseBtn.innerHTML = '◀';
                }
            });
        }

        function setLiveDate() {
            const now = new Date();
            const options = { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' };
            const dateStr = now.toLocaleDateString('zh-CN', options);
            document.getElementById('liveDate').innerHTML = `⏣ ${dateStr}`;
        }

        function initMenuEvents() {
            menuItems.forEach(item => {
                const link = item.querySelector('a');
                const title = item.getAttribute('data-title');
                const url = item.getAttribute('data-url');

                link.addEventListener('click', (e) => {
                    e.preventDefault();

                    // 移除之前的激活状态
                    if (activeItem) {
                        activeItem.classList.remove('active');
                    }

                    // 设置当前项为激活状态
                    item.classList.add('active');
                    activeItem = item;

                    // 在 iframe 中加载对应的页面
                    if (url) {
                        iframe.src = url;
                    }

                    // 更新面包屑标题
                    if (title) {
                        currentMenuSpan.textContent = title;
                    }
                });
            });

            // 系统管理菜单项点击事件
            const adminNavItems = document.querySelectorAll('.admin-nav-item');
            adminNavItems.forEach(item => {
                const link = item.querySelector('a');
                const title = item.getAttribute('data-title');
                const url = item.getAttribute('data-url');

                link.addEventListener('click', (e) => {
                    e.preventDefault();

                    // 移除之前的激活状态
                    if (activeItem) {
                        activeItem.classList.remove('active');
                    }

                    // 设置当前项为激活状态
                    item.classList.add('active');
                    activeItem = item;

                    // 在 iframe 中加载对应的页面
                    if (url) {
                        iframe.src = url;
                    }

                    // 更新面包屑标题
                    if (title) {
                        currentMenuSpan.textContent = title;
                    }
                });
            });

            // 初始化时高亮首页
            const homeItem = document.querySelector('.nav-item[data-page="home"]');
            if (homeItem) {
                homeItem.classList.add('active');
                activeItem = homeItem;
            }
        }

        function initLoginModal() {
            const loginBtn = document.getElementById('loginBtn');
            const logoutBtn = document.getElementById('logoutBtn');
            const userInfo = document.getElementById('userInfo');
            const userNameDisplay = document.getElementById('userName');

            // 打开登录页面
            loginBtn.addEventListener('click', () => {
                window.location.href = 'LOGIN/login.jsp';
            });

            // 退出登录
            logoutBtn.addEventListener('click', () => {
                if (confirm('确定要退出登录吗？')) {
                    // 给用户一个视觉反馈
                    logoutBtn.disabled = true;
                    logoutBtn.innerHTML = '<span style="color: rgba(255,255,255,0.7)">退出中...</span>';
                    logoutBtn.style.opacity = '0.7';
                    logoutBtn.style.cursor = 'not-allowed';
                    
                    // 添加退出动画效果
                    logoutBtn.style.transform = 'scale(0.95)';
                    
                    // 清空 localStorage（如果有）
                    localStorage.clear();
                    
                    // 清除所有 localStorage 中的用户相关数据
                    const localStorageKeys = Object.keys(localStorage);
                    localStorageKeys.forEach(key => {
                        if (key.includes('user') || key.includes('login') || key.includes('auth')) {
                            localStorage.removeItem(key);
                        }
                    });

                    // 添加延迟确保用户看到反馈效果
                    setTimeout(() => {
                        // 清除 Session - 重新加载页面让后端处理
                        window.location.href = 'LOGIN/logout.jsp';
                    }, 500);
                }
            });

            // 检查 URL 参数，处理退出登录后的状态
            function checkUrlParams() {
                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.has('logout') && urlParams.get('logout') === 'true') {
                    // 移除 logout 参数，避免重复触发
                    const newUrl = window.location.pathname;
                    window.history.replaceState({}, document.title, newUrl);
                    
                    // 显示退出成功消息
                    console.log('✅ 已成功退出登录');
                    
                    // 确保页面显示登录状态
                    loginBtn.style.display = 'inline-flex';
                    userInfo.classList.remove('active');
                    userNameDisplay.textContent = '用户';
                    
                    // 隐藏系统管理
                    const adminSection = document.getElementById('adminSection');
                    if (adminSection) adminSection.classList.remove('admin-visible');
                    
                    return true;
                }
                return false;
            }

            // 检查登录状态 - 优先从 Session 获取
            function checkLoginStatus() {
                // 尝试从页面隐藏字段获取用户名（如果后端设置了）
                const sessionUser = document.getElementById('sessionUser')?.value;
                const sessionRole = document.getElementById('sessionRole')?.value;
                const sessionNickname = document.getElementById('sessionNickname')?.value;
                const sessionAvatar = document.getElementById('sessionAvatar')?.value;
                const avatarEl = document.getElementById('userAvatar');

                if (sessionUser) {
                    // 从 Session 登录
                    loginBtn.style.display = 'none';
                    userInfo.classList.add('active');
                    // 显示昵称（有昵称则显示昵称，否则显示用户名）
                    userNameDisplay.textContent = sessionNickname || sessionUser;
                    // 显示头像（优先使用全局变量_currentUserInfo，兼容特殊字符）
                    const avatarUrl = (window._currentUserInfo && _currentUserInfo.avatar) || sessionAvatar || '';
                    updateHeaderAvatar(avatarEl, avatarUrl);

                    // Session 登录时，系统管理已由 JSP 控制显示（仅管理员可见）
                } else {
                    // 降级到 localStorage（兼容旧数据）
                    const isLoggedIn = localStorage.getItem('isLoggedIn') === 'true';
                    const username = localStorage.getItem('username');
                    const userRole = localStorage.getItem('userRole');

                    if (isLoggedIn && username) {
                        loginBtn.style.display = 'none';
                        userInfo.classList.add('active');
                        userNameDisplay.textContent = username;

                        // localStorage 登录时，检查是否为管理员
                        const adminSection = document.getElementById('adminSection');
                        if (userRole === 'admin') {
                            if (adminSection) adminSection.classList.add('admin-visible');
                        } else {
                            // 非管理员，确保隐藏系统管理
                            if (adminSection) adminSection.classList.remove('admin-visible');
                        }
                    } else {
                        // 未登录，确保隐藏系统管理
                        const adminSection = document.getElementById('adminSection');
                        if (adminSection) adminSection.classList.remove('admin-visible');
                    }
                }
            }

            // 页面加载时检查登录状态
            // 先检查URL参数（处理退出登录后的状态）
            if (!checkUrlParams()) {
                // 如果没有退出登录参数，正常检查登录状态
                checkLoginStatus();
            }
        }

        // ======== 🎨 3D环形旋转主题选择器 ========
        function initThemeToggle() {
            // 8个主题的顺序与名称映射
            var THEMES = [
                { id: 'apple-light',     name: '浅灰极简' },
                { id: 'notion-light',    name: '金黄暖调' },
                { id: 'weread-light',    name: '橄榄书香' },
                { id: 'quantum-matrix', name: '深灰蓝调' },
                { id: 'campus-light',   name: '奶油校园' },
                { id: 'nebula-dream',   name: '暗红星云' },
                { id: 'cyber-neon',     name: '橙红赛博' },
                { id: 'data-stream',    name: '深炭流光' }
            ];

            var themeToggleBtn    = document.getElementById('themeToggleBtn');
            var themeRingPanel    = document.getElementById('themeRingPanel');
            var themeRingBackdrop = document.getElementById('themeRingBackdrop');
            var themeRingClose    = document.getElementById('themeRingClose');
            var themeRingTrack    = document.getElementById('themeRingTrack');
            var themeRotateLeft   = document.getElementById('themeRotateLeft');
            var themeRotateRight  = document.getElementById('themeRotateRight');
            var themeCurrentName  = document.getElementById('themeCurrentName');
            var themeRingOrbit    = document.getElementById('themeRingOrbit');

            if (!themeToggleBtn || !themeRingPanel) return;

            // 轨道整体旋转角度（每步45°）
            var trackRotation = 0;

            // 将8个方块定位到环上（半径 = orbit直径/2 - item宽/2 - 偏移）
            function positionItems() {
                var items = themeRingTrack.querySelectorAll('.theme-ring-item');
                var orbitSize = themeRingOrbit.offsetWidth || 224;
                var radius = (orbitSize / 2) - 28; // 28 = item半宽 + 偏移
                var count = items.length;
                items.forEach(function(item, i) {
                    var angle = (i * 360 / count - 90) * Math.PI / 180; // 从顶部开始
                    var cx = orbitSize / 2 + radius * Math.cos(angle) - 23; // 23 = item宽/2
                    var cy = orbitSize / 2 + radius * Math.sin(angle) - 23;
                    item.style.left = cx + 'px';
                    item.style.top  = cy + 'px';
                });
            }

            // 显示/隐藏面板
            function openPanel() {
                themeRingPanel.classList.add('show');
                positionItems();
                syncActiveItem();
                updateCurrentName();
            }

            function closePanel() {
                themeRingPanel.classList.remove('show');
            }

            // 同步高亮当前主题
            function syncActiveItem() {
                var cur = localStorage.getItem('boya-theme') || 'quantum-matrix';
                themeRingTrack.querySelectorAll('.theme-ring-item').forEach(function(item) {
                    item.classList.toggle('active', item.getAttribute('data-theme') === cur);
                });
            }

            // 更新中部名称显示
            function updateCurrentName() {
                var cur = localStorage.getItem('boya-theme') || 'quantum-matrix';
                var found = THEMES.find(function(t) { return t.id === cur; });
                if (themeCurrentName) themeCurrentName.textContent = found ? found.name : cur;
            }

            // 旋转环
            function rotateTrack(direction) {
                // direction: +1 向右, -1 向左
                trackRotation += direction * 45;
                if (themeRingTrack) {
                    themeRingTrack.style.transform = 'rotate(' + trackRotation + 'deg)';
                }
                // 方块内容保持不旋转（逆旋转补偿）
                themeRingTrack.querySelectorAll('.theme-ring-item').forEach(function(item) {
                    item.style.transform = item.classList.contains('active')
                        ? 'rotate(' + (-trackRotation) + 'deg) scale(1.15) rotate(5deg)'
                        : 'rotate(' + (-trackRotation) + 'deg)';
                });
            }

            // 事件绑定
            themeToggleBtn.addEventListener('click', function(e) {
                e.stopPropagation();
                if (themeRingPanel.classList.contains('show')) {
                    closePanel();
                } else {
                    openPanel();
                }
            });

            if (themeRingBackdrop) {
                themeRingBackdrop.addEventListener('click', closePanel);
            }
            if (themeRingClose) {
                themeRingClose.addEventListener('click', closePanel);
            }
            if (themeRotateLeft) {
                themeRotateLeft.addEventListener('click', function(e) {
                    e.stopPropagation();
                    rotateTrack(-1);
                });
            }
            if (themeRotateRight) {
                themeRotateRight.addEventListener('click', function(e) {
                    e.stopPropagation();
                    rotateTrack(1);
                });
            }

            // 点击方块切换主题
            themeRingTrack.querySelectorAll('.theme-ring-item').forEach(function(item) {
                item.addEventListener('click', function(e) {
                    e.stopPropagation();
                    var themeName = item.getAttribute('data-theme');
                    if (!themeName) return;
                    setTheme(themeName);
                    syncActiveItem();
                    updateCurrentName();
                    // 补偿旋转
                    themeRingTrack.querySelectorAll('.theme-ring-item').forEach(function(it) {
                        it.style.transform = it.classList.contains('active')
                            ? 'rotate(' + (-trackRotation) + 'deg) scale(1.15) rotate(5deg)'
                            : 'rotate(' + (-trackRotation) + 'deg)';
                    });
                    // 短暂延迟后关闭
                    setTimeout(closePanel, 600);
                    showThemeSaveNotification(themeName);
                });
            });

            // Esc 关闭
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') closePanel();
            });

            // 初始化：应用已保存主题
            var currentTheme = localStorage.getItem('boya-theme') || 'quantum-matrix';
            setTheme(currentTheme);
            updateCurrentName();
        }

        // ★ 主题设置函数（IIFE 级别，供 initThemeToggle 和 initHomeNavigate 共用）
        function setTheme(themeName) {
            if (!themeName) return;
            document.documentElement.setAttribute('data-theme', themeName);
            localStorage.setItem('boya-theme', themeName);
            // 广播主题到 iframe 内的子页面
            var iframeEl = document.getElementById('academicFrame');
            if (iframeEl && iframeEl.contentWindow) {
                try {
                    iframeEl.contentWindow.postMessage({ type: 'themeChange', theme: themeName }, '*');
                } catch(e) { console.warn('主题广播到 iframe 失败：', e); }
            }
        }

        // 显示主题保存通知
        function showThemeSaveNotification(themeName) {
            console.log('主题已切换为: ' + themeName);
        }

        // 解析头像URL：相对路径自动拼接contextPath，绝对URL保持不变（模仿图书封面获取方式）
        function resolveAvatarUrl(url) {
            if (!url || !url.trim()) return '';
            var u = url.trim();
            // 如果是绝对URL（http/https/data:）或协议相对URL（//），直接返回
            if (u.indexOf('http://') === 0 || u.indexOf('https://') === 0 ||
                u.indexOf('data:') === 0 || u.indexOf('//') === 0) {
                return u;
            }
            // 相对路径：拼接 contextPath（如 /Mysql_1/avatars/xxx.jpg）
            return (window.CONTEXT_PATH || '') + u;
        }

        // 更新头部头像显示（带图片加载失败回退）
        function updateHeaderAvatar(containerEl, avatarUrl) {
            var resolvedUrl = resolveAvatarUrl(avatarUrl);
            if (resolvedUrl) {
                containerEl.innerHTML = '<img src="' + resolvedUrl + '" style="width:32px;height:32px;border-radius:50%;object-fit:cover;" onerror="this.outerHTML=\'<span style=display:flex;align-items:center;justify-content:center;width:100%;height:100%;font-size:16px;color:white;font-weight:700;background:linear-gradient(135deg,var(--primary-holo,#00f5ff),var(--secondary-holo,#8a2be2));border-radius:50%;>👤</span>\'">';
            } else {
                containerEl.textContent = '👤';
            }
        }

        // ===== 个人资料修改弹窗 =====
        function initProfileModal() {
            const overlay = document.getElementById('profileModalOverlay');
            const modal = document.getElementById('profileModal');
            const closeBtn = document.getElementById('profileModalClose');
            const cancelBtn = document.getElementById('profileCancelBtn');
            const saveBtn = document.getElementById('profileSaveBtn');
            const avatarFileInput = document.getElementById('avatarFileInput');
            const avatarUrlInput = document.getElementById('avatarUrlInput');
            const avatarUrlField = document.getElementById('avatarUrlField');
            const avatarOptionsMenu = document.getElementById('avatarOptionsMenu');
            const nicknameInput = document.getElementById('profileNicknameInput');
            const sexSelect = document.getElementById('profileSexSelect');
            const emailInput = document.getElementById('profileEmailInput');
            const avatarPreview = document.getElementById('profileAvatarPreview');
            const messageEl = document.getElementById('profileMessage');

            // 获取头像/用户名点击元素
            const userAvatar = document.getElementById('userAvatar');
            const userName = document.getElementById('userName');

            // 标识当前选中的方式：'file' 或 'url'，null 表示未选择
            var avatarMode = null;

            // 打开弹窗并填充数据
            function openProfileModal() {
                // 优先使用全局变量（支持特殊字符），其次从隐藏输入读取
                var cui = window._currentUserInfo || {};
                const sessionAvatar = cui.avatar || document.getElementById('sessionAvatar')?.value || '';
                const sessionNickname = cui.nickname || document.getElementById('sessionNickname')?.value || '';
                const sessionUser = cui.username || document.getElementById('sessionUser')?.value || '';
                const sessionSex = cui.sex || document.getElementById('sessionSex')?.value || '';
                const sessionEmail = cui.email || document.getElementById('sessionEmail')?.value || '';

                // 填充表单
                nicknameInput.value = sessionNickname || sessionUser || '';
                sexSelect.value = sessionSex || '';
                emailInput.value = sessionEmail || '';

                // 重置状态
                avatarMode = null;
                avatarFileInput.value = '';
                avatarUrlInput.value = '';
                avatarUrlField.style.display = 'none';
                avatarOptionsMenu.classList.remove('show');

                // 更新头像预览
                updateAvatarPreview(sessionAvatar);

                // 隐藏消息
                messageEl.className = 'profile-message';
                messageEl.style.display = 'none';
                saveBtn.disabled = false;
                saveBtn.textContent = '保存修改';

                // 显示弹窗
                overlay.classList.add('active');
                document.body.style.overflow = 'hidden';
            }

            // 关闭弹窗
            function closeProfileModal() {
                overlay.classList.remove('active');
                avatarOptionsMenu.classList.remove('show');
                document.body.style.overflow = '';
            }

            // 更新头像预览（使用resolveAvatarUrl解析路径）
            function updateAvatarPreview(url) {
                var resolved = resolveAvatarUrl(url);
                if (resolved) {
                    avatarPreview.innerHTML = '<img src="' + resolved + '" alt="avatar" onerror="this.parentElement.innerHTML=\'👤\'">';
                } else {
                    avatarPreview.innerHTML = '👤';
                }
            }

            // 点击头像显示选择菜单
            function toggleAvatarOptions(e) {
                if (e) e.stopPropagation();
                if (avatarOptionsMenu) {
                    avatarOptionsMenu.classList.toggle('show');
                }
            }

            // 选择"本地上传"
            function chooseLocalUpload() {
                avatarOptionsMenu.classList.remove('show');
                avatarUrlField.style.display = 'none';
                avatarUrlInput.value = '';
                avatarMode = null;           // 重置模式，等待 change 事件设置
                avatarFileInput.value = '';
                avatarFileInput.click();
            }

            // 选择"网络链接"
            function chooseUrlUpload() {
                avatarOptionsMenu.classList.remove('show');
                avatarUrlField.style.display = 'block';
                avatarUrlInput.focus();
                // 重置文件选择状态，避免之前选择的文件被意外提交
                avatarMode = null;
                avatarFileInput.value = '';
            }

            // 文件选中后预览
            avatarFileInput.addEventListener('change', function() {
                if (this.files && this.files.length > 0) {
                    avatarMode = 'file';
                    avatarUrlField.style.display = 'none';
                    avatarUrlInput.value = '';
                    var file = this.files[0];
                    var reader = new FileReader();
                    reader.onload = function(e) {
                        avatarPreview.innerHTML = '<img src="' + e.target.result + '" alt="avatar" style="width:100%;height:100%;border-radius:50%;object-fit:cover;">';
                    };
                    reader.readAsDataURL(file);
                }
            });

            // 网络链接输入预览
            avatarUrlInput.addEventListener('input', function() {
                if (this.value.trim()) {
                    avatarMode = 'url';
                    updateAvatarPreview(this.value.trim());
                }
            });

            // 保存修改
            function saveProfile() {
                const nickname = nicknameInput.value.trim();
                const sex = sexSelect.value;
                const email = emailInput.value.trim();

                if (!nickname) {
                    showMessage('请输入昵称', 'error');
                    return;
                }

                // 禁用按钮防止重复提交
                saveBtn.disabled = true;
                saveBtn.textContent = '保存中...';

                // 使用 FormData 发送（支持文件上传）
                var formData = new FormData();
                formData.append('action', 'update');
                formData.append('nickname', nickname);
                formData.append('sex', sex);
                formData.append('email', email);

                // 根据选择的模式添加头像数据
                if (avatarMode === 'file' && avatarFileInput.files && avatarFileInput.files.length > 0) {
                    formData.append('avatarFile', avatarFileInput.files[0]);
                } else if (avatarMode === 'url' && avatarUrlInput.value.trim()) {
                    formData.append('avatar', avatarUrlInput.value.trim());
                }

                var abortController = new AbortController();
                var timeoutId = setTimeout(function() { abortController.abort(); }, 30000);

                fetch((window.CONTEXT_PATH || '') + '/userProfile', {
                    method: 'POST',
                    body: formData,
                    signal: abortController.signal
                })
                .then(function(response) { clearTimeout(timeoutId); return response.json(); })
                .then(function(data) {
                    if (data.success) {
                        var newAvatar = data.avatar || '';

                        // 更新全局变量
                        if (window._currentUserInfo) {
                            _currentUserInfo.nickname = nickname;
                            _currentUserInfo.avatar = newAvatar;
                            _currentUserInfo.sex = sex;
                            _currentUserInfo.email = email;
                        }
                        // 同步隐藏字段
                        document.getElementById('sessionNickname').value = nickname;
                        document.getElementById('sessionAvatar').value = newAvatar;
                        document.getElementById('sessionSex').value = sex;
                        document.getElementById('sessionEmail').value = email;
                        // 更新页面昵称显示
                        document.getElementById('userName').textContent = nickname;

                        // 更新头部头像显示
                        var avatarEl = document.getElementById('userAvatar');
                        updateHeaderAvatar(avatarEl, newAvatar);

                        // 延迟关闭弹窗
                        setTimeout(function() {
                            closeProfileModal();
                        }, 1200);
                    } else {
                        showMessage('❌ ' + (data.message || '修改失败'), 'error');
                        saveBtn.disabled = false;
                        saveBtn.textContent = '保存修改';
                    }
                })
                .catch(function(err) {
                    showMessage('❌ 网络错误，请重试', 'error');
                    saveBtn.disabled = false;
                    saveBtn.textContent = '保存修改';
                    console.error('Profile update error:', err);
                });
            }

            // 显示消息
            function showMessage(text, type) {
                messageEl.textContent = text;
                messageEl.className = 'profile-message ' + type;
                messageEl.style.display = 'block';
            }

            // 事件绑定：点击头像或用户名打开弹窗
            if (userAvatar) {
                userAvatar.addEventListener('click', function(e) {
                    e.stopPropagation();
                    // 检查是否已登录（有sessionUser）
                    if (document.getElementById('sessionUser')?.value) {
                        openProfileModal();
                    }
                });
                // 添加鼠标指针样式
                userAvatar.style.cursor = 'pointer';
            }

            if (userName) {
                userName.addEventListener('click', function(e) {
                    e.stopPropagation();
                    if (document.getElementById('sessionUser')?.value) {
                        openProfileModal();
                    }
                });
                userName.style.cursor = 'pointer';
            }

            // 关闭按钮
            if (closeBtn) closeBtn.addEventListener('click', closeProfileModal);
            if (cancelBtn) cancelBtn.addEventListener('click', closeProfileModal);

            // 保存按钮
            if (saveBtn) saveBtn.addEventListener('click', saveProfile);

            // 头像点击弹出选择菜单
            if (avatarPreview) {
                avatarPreview.addEventListener('click', function(e) {
                    e.stopPropagation();
                    toggleAvatarOptions(e);
                });
            }

            // 选择"本地上传"
            var localOption = document.getElementById('avatarOptionLocal');
            if (localOption) {
                localOption.addEventListener('click', function(e) {
                    e.stopPropagation();
                    chooseLocalUpload();
                });
            }

            // 选择"网络链接"
            var urlOption = document.getElementById('avatarOptionUrl');
            if (urlOption) {
                urlOption.addEventListener('click', function(e) {
                    e.stopPropagation();
                    chooseUrlUpload();
                });
            }

            // 点击其他地方关闭菜单
            document.addEventListener('click', function() {
                if (avatarOptionsMenu) avatarOptionsMenu.classList.remove('show');
            });

            // 点击遮罩层关闭
            if (overlay) {
                overlay.addEventListener('click', function(e) {
                    if (e.target === overlay) {
                        closeProfileModal();
                    }
                });
            }

            // ESC键关闭
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape' && overlay && overlay.classList.contains('active')) {
                    closeProfileModal();
                }
            });
        }

        // ===== 头像文件上传处理函数（模仿图书封面上传） =====
        function profileHandleFileSelect(input, areaId, type) {
            var area = document.getElementById(areaId);
            if (!area || !input.files || input.files.length === 0) return;
            
            var file = input.files[0];
            var uploadContent = area.querySelector('.upload-content');
            var previewImage = area.querySelector('.preview-image');
            var fileInfo = area.querySelector('.file-info');
            var fileName = area.querySelector('.file-name');
            var removeBtn = area.querySelector('.remove-file');
            
            area.classList.add('has-file');
            if (uploadContent) uploadContent.classList.add('hidden');
            if (fileInfo) {
                fileInfo.classList.add('show');
                if (fileName) fileName.textContent = file.name;
            }
            if (removeBtn) removeBtn.classList.add('show');
            
            // 图片类型显示预览（同时在弹窗大头像中预览）
            if (type === 'image' && previewImage && file.type.startsWith('image/')) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    previewImage.src = e.target.result;
                    previewImage.classList.add('show');
                    // 同步更新大圆形头像预览
                    var preview = document.getElementById('profileAvatarPreview');
                    if (preview) {
                        preview.innerHTML = '<img src="' + e.target.result + '" alt="avatar" style="width:100%;height:100%;border-radius:50%;object-fit:cover;">';
                    }
                };
                reader.readAsDataURL(file);
            }
        }

        function profileClearFile(event, areaId, fileInput, skipEvent) {
            if (event) {
                event.preventDefault();
                event.stopPropagation();
            }
            var area = document.getElementById(areaId);
            if (!area) return;
            
            var input = fileInput || area.querySelector('input[type="file"]');
            var uploadContent = area.querySelector('.upload-content');
            var previewImage = area.querySelector('.preview-image');
            var fileInfo = area.querySelector('.file-info');
            var removeBtn = area.querySelector('.remove-file');
            
            if (input) input.value = '';
            area.classList.remove('has-file');
            if (fileInfo) fileInfo.classList.remove('show');
            if (removeBtn) removeBtn.classList.remove('show');
            if (uploadContent) uploadContent.classList.remove('hidden');
            if (previewImage) {
                previewImage.classList.remove('show');
                previewImage.src = '';
            }
            // 如果不跳过事件，恢复大圆形头像为当前已保存的头像
            if (!skipEvent) {
                var preview = document.getElementById('profileAvatarPreview');
                var savedAvatar = (window._currentUserInfo && _currentUserInfo.avatar) || 
                                  document.getElementById('sessionAvatar')?.value || '';
                if (savedAvatar) {
                    var resolved = resolveAvatarUrl(savedAvatar);
                    if (preview) {
                        preview.innerHTML = '<img src="' + resolved + '" alt="avatar" onerror="this.parentElement.innerHTML=\'👤\'">';
                    }
                } else if (preview) {
                    preview.innerHTML = '👤';
                }
            }
        }

        function profileInitDragUpload() {
            var uploadAreas = document.querySelectorAll('.file-upload-area');
            uploadAreas.forEach(function(area) {
                ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(function(eventName) {
                    area.addEventListener(eventName, function(e) {
                        e.preventDefault();
                        e.stopPropagation();
                    }, false);
                });
                ['dragenter', 'dragover'].forEach(function(eventName) {
                    area.addEventListener(eventName, function() {
                        area.classList.add('drag-over');
                    }, false);
                });
                ['dragleave', 'drop'].forEach(function(eventName) {
                    area.addEventListener(eventName, function() {
                        area.classList.remove('drag-over');
                    }, false);
                });
                area.addEventListener('drop', function(e) {
                    var dt = e.dataTransfer;
                    var files = dt.files;
                    var input = area.querySelector('input[type="file"]');
                    if (input && files.length > 0) {
                        input.files = files;
                        var event = new Event('change', { bubbles: true });
                        input.dispatchEvent(event);
                    }
                }, false);
            });
        }

        // ===== 监听首页模块卡片的 postMessage（导航 + 主题 + 资料更新） =====
        function initHomeNavigate() {
            window.addEventListener('message', function(e) {
                if (!e.data) return;

                // ── 导航跳转 ──
                if (e.data.type === 'navigate') {
                    var url = e.data.url;
                    var title = e.data.title;
                    if (!url) return;

                    // 切换 iframe
                    iframe.src = url;

                    // 更新面包屑
                    if (title && currentMenuSpan) {
                        currentMenuSpan.textContent = title;
                    }

                    // 高亮对应导航项
                    if (activeItem) activeItem.classList.remove('active');

                    var matched = document.querySelector('.nav-item[data-url="' + url + '"]');
                    if (!matched) {
                        matched = document.querySelector('.nav-item[data-title="' + title + '"]');
                    }
                    if (matched) {
                        matched.classList.add('active');
                        activeItem = matched;
                    }
                }

                // ── 主题切换 ──
                if (e.data.type === 'themeChange') {
                    var theme = e.data.theme;
                    if (theme) {
                        setTheme(theme);
                        // 同步环形选择器的 active 状态
                        document.querySelectorAll('.theme-ring-item').forEach(function(b){
                            b.classList.toggle('active', b.getAttribute('data-theme') === theme);
                        });
                        // 更新当前主题名称显示
                        var nameEl = document.getElementById('themeCurrentName');
                        if (nameEl) {
                            var THEME_NAMES = {
                                'apple-light': '浅灰极简', 'notion-light': '金黄暖调',
                                'weread-light': '橄榄书香', 'quantum-matrix': '深灰蓝调',
                                'campus-light': '奶油校园', 'nebula-dream': '暗红星云',
                                'cyber-neon': '橙红赛博', 'data-stream': '深炭流光'
                            };
                            nameEl.textContent = THEME_NAMES[theme] || theme;
                        }
                    }
                }

                // ── 资料更新 ──
                if (e.data.type === 'profileUpdate') {
                    var avatarEl = document.getElementById('userAvatar');
                    var userNameEl = document.getElementById('userName');
                    if (e.data.avatar && avatarEl) updateHeaderAvatar(avatarEl, e.data.avatar);
                    if (e.data.nickname && userNameEl) userNameEl.textContent = e.data.nickname;
                }
            });
        }

        function init() {
            initCollapse();
            // 不再调用 setLiveDate();
            initMenuEvents();
            initLoginModal();
            initProfileModal();
            profileInitDragUpload();
            initThemeToggle();
            initHomeNavigate();
            
            // 初始化科技风侧边栏系统
            if (typeof initSidebarSystem === 'function') {
                initSidebarSystem();
            }
            
            // 直接绑定系统管理展开事件
            const adminToggle = document.getElementById('adminToggle');
            const adminSection = document.getElementById('adminSection');
            if (adminToggle && adminSection) {
                adminToggle.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    adminSection.classList.toggle('expanded');
                    console.log('系统管理 clicked, expanded:', adminSection.classList.contains('expanded'));
                });
            }
        }
        init();
    })();
