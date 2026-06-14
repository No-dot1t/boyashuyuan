<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="zh-CN">

    <head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>讲坛和导师管理 - 博雅书院</title>
        <link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/adminPush.css">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <style>
            * {
                scrollbar-width: none;
                /* Firefox */
                -ms-overflow-style: none;
                /* IE/Edge */
            }

            *::-webkit-scrollbar {
                display: none;
                /* Chrome/Safari/Opera */
            }

            html,
            body {
                overflow-y: auto !important;
                height: auto !important;
            }
        </style>
    <!-- ========== 浅色主题 · 讲坛导师管理全覆盖 ========== -->
    <style>
        html[data-theme$="-light"] body{background:linear-gradient(170deg,#e9e2d2,#ede5d3 40%,#e4dbca)!important;color:#3d3929!important}
        html[data-theme$="-light"] .admin-container{background:transparent!important}
        html[data-theme$="-light"] .admin-header{background:linear-gradient(135deg,rgba(238,233,222,.82),rgba(243,239,228,.9))!important;border-color:rgba(37,99,235,.1)!important;box-shadow:0 4px 20px rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .header-info h1{color:#3d3929!important}
        html[data-theme$="-light"] .header-info p{color:#7a7360!important}
        html[data-theme$="-light"] .btn-refresh{background:rgba(37,99,235,.08)!important;border-color:rgba(37,99,235,.12)!important;color:#2563eb!important}
        html[data-theme$="-light"] .btn-refresh:hover{background:rgba(37,99,235,.15)!important}
        html[data-theme$="-light"] .stat-card{background:rgba(238,233,222,.85)!important;border-color:rgba(139,119,80,.06)!important;box-shadow:0 4px 16px rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .stat-card:hover{border-color:rgba(37,99,235,.12)!important;box-shadow:0 8px 28px rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .stat-value{color:#2563eb!important}
        html[data-theme$="-light"] .stat-label{color:#7a7360!important}
        html[data-theme$="-light"] .tab-btn{background:rgba(139,119,80,.04)!important;border-color:rgba(139,119,80,.06)!important;color:#7a7360!important}
        html[data-theme$="-light"] .tab-btn:hover{background:rgba(37,99,235,.05)!important;color:#5c5540!important}
        html[data-theme$="-light"] .tab-btn.active{background:rgba(37,99,235,.1)!important;border-color:rgba(37,99,235,.2)!important;color:#2563eb!important}
        html[data-theme$="-light"] .panel-header h2{color:#3d3929!important}
        html[data-theme$="-light"] .btn-add{background:rgba(37,99,235,.08)!important;border-color:rgba(37,99,235,.12)!important;color:#2563eb!important}
        html[data-theme$="-light"] .btn-add:hover{background:rgba(37,99,235,.15)!important}
        html[data-theme$="-light"] .modal-overlay{background:rgba(61,57,41,.35)!important}
        html[data-theme$="-light"] .modal-content{background:rgba(238,233,222,.97)!important;border-color:rgba(37,99,235,.12)!important;box-shadow:0 20px 60px rgba(139,119,80,.15)!important}
        html[data-theme$="-light"] .modal-header h3{color:#3d3929!important}
        html[data-theme$="-light"] .btn-close{color:#7a7360!important}
        html[data-theme$="-light"] .btn-close:hover{color:#b91c1c!important}
        html[data-theme$="-light"] input,html[data-theme$="-light"] textarea,html[data-theme$="-light"] select{background:rgba(238,233,222,.85)!important;border-color:rgba(139,119,80,.1)!important;color:#3d3929!important}
        html[data-theme$="-light"] input:focus,html[data-theme$="-light"] textarea:focus{border-color:rgba(37,99,235,.2)!important}
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3{color:#3d3929!important}
        html[data-theme$="-light"] ::selection{background:rgba(37,99,235,.15)!important;color:#3d3929!important}
        /* ── 卡片容器 ── */
        html[data-theme$="-light"] .lecture-card,html[data-theme$="-light"] .teacher-card{background:rgba(238,233,222,.88)!important;border-color:rgba(139,119,80,.08)!important;box-shadow:0 4px 16px rgba(139,119,80,.04)!important}
        html[data-theme$="-light"] .lecture-card:hover,html[data-theme$="-light"] .teacher-card:hover{border-color:rgba(37,99,235,.15)!important;box-shadow:0 8px 28px rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .lecture-card p,html[data-theme$="-light"] .teacher-card p,html[data-theme$="-light"] .teacher-card span{color:#5c5540!important}
        /* ── 描述文字 ── */
        html[data-theme$="-light"] .lec-desc,html[data-theme$="-light"] .teacher-bio{color:#5c5540!important}
        /* ── 链接按钮 ── */
        html[data-theme$="-light"] .lec-link{background:linear-gradient(135deg,rgba(37,99,235,.1),rgba(124,58,237,.06))!important;color:#2563eb!important;border-color:rgba(37,99,235,.15)!important}
        /* ── 操作按钮 ── */
        html[data-theme$="-light"] .btn-edit{background:rgba(37,99,235,.08)!important;border-color:rgba(37,99,235,.12)!important;color:#2563eb!important}
        html[data-theme$="-light"] .btn-edit:hover{background:rgba(37,99,235,.16)!important}
        html[data-theme$="-light"] .btn-delete{background:rgba(220,38,38,.06)!important;border-color:rgba(220,38,38,.12)!important;color:#b91c1c!important}
        html[data-theme$="-light"] .btn-delete:hover{background:rgba(220,38,38,.12)!important}
        html[data-theme$="-light"] .btn-cancel{background:rgba(139,119,80,.05)!important;border-color:rgba(139,119,80,.1)!important;color:#7a7360!important}
        html[data-theme$="-light"] .btn-cancel:hover{background:rgba(139,119,80,.1)!important;color:#5c5540!important}
        html[data-theme$="-light"] .btn-submit{background:linear-gradient(135deg,rgba(37,99,235,.12),rgba(124,58,237,.08))!important;border-color:rgba(37,99,235,.18)!important;color:#2563eb!important}
        html[data-theme$="-light"] .btn-submit:hover{background:linear-gradient(135deg,rgba(37,99,235,.2),rgba(124,58,237,.14))!important}
        /* ── 内容区 + 分隔 ── */
        html[data-theme$="-light"] .content-area{background:rgba(238,233,222,.82)!important;border-color:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .card-actions{border-top-color:rgba(139,119,80,.08)!important}
        /* ── 表单 ── */
        html[data-theme$="-light"] .form-group label{color:#5c5540!important}
        html[data-theme$="-light"] .form-actions{border-top-color:rgba(139,119,80,.08)!important}
        /* ── 统计图标 + 空态 ── */
        html[data-theme$="-light"] .stat-icon{background:rgba(37,99,235,.08)!important;color:#2563eb!important}
        html[data-theme$="-light"] .empty-state{color:#7a7360!important}
        html[data-theme$="-light"] .empty-state i{opacity:0.25!important}
        /* ── 讲师头像 ── */
        html[data-theme$="-light"] .teacher-avatar{filter:none!important}
        /* ── toast ── */
        html[data-theme$="-light"] .toast,html[data-theme$="-light"] .toast-success,html[data-theme$="-light"] .toast-error{background:rgba(238,233,222,.96)!important;border-color:rgba(139,119,80,.1)!important;color:#3d3929!important;box-shadow:0 8px 30px rgba(139,119,80,.1)!important}
    </style>

    </head>

    <body>
        <div class="admin-container">
            <div class="admin-header">
                <div class="header-left">
                    <div class="header-icon">📡</div>
                    <div class="header-info">
                        <h1>讲坛和导师管理</h1>
                        <p>管理前沿讲坛和导师光网数据</p>
                    </div>
                </div>
                <button class="btn-refresh" onclick="loadData()">
                    <i class="fas fa-sync-alt"></i> 刷新
                </button>
            </div>

            <div class="stats-row">
                <div class="stat-card">
                    <div class="stat-icon">📚</div>
                    <div class="stat-content">
                        <div class="stat-value" id="lecture-count">0</div>
                        <div class="stat-label">讲座总数</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">👨‍🏫</div>
                    <div class="stat-content">
                        <div class="stat-value" id="faculty-count">0</div>
                        <div class="stat-label">导师总数</div>
                    </div>
                </div>
            </div>

            <div class="module-tabs">
                <button class="tab-btn active" data-module="lecture" onclick="switchModule('lecture')">
                    <i class="fas fa-video"></i> 前沿讲坛
                </button>
                <button class="tab-btn" data-module="faculty" onclick="switchModule('faculty')">
                    <i class="fas fa-user-tie"></i> 导师光网
                </button>
            </div>

            <div class="content-area">
                <div id="lecture-panel">
                    <div class="panel-header">
                        <h2>📡 前沿讲坛</h2>
                        <button class="btn-add" onclick="showAddLectureModal()">
                            <i class="fas fa-plus"></i> 添加讲座
                        </button>
                    </div>
                    <div class="lecture-grid" id="lecture-list"></div>
                </div>

                <div id="faculty-panel" style="display:none;">
                    <div class="panel-header">
                        <h2>⚛ 导师光网</h2>
                        <button class="btn-add" onclick="showAddFacultyModal()">
                            <i class="fas fa-plus"></i> 添加导师
                        </button>
                    </div>
                    <div class="teacher-grid" id="faculty-list"></div>
                </div>
            </div>
        </div>

        <div class="modal-overlay" id="modal-overlay" style="display:none;">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 id="modal-title">添加</h3>
                    <button class="btn-close" onclick="closeModal()">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                <form id="modal-form">
                    <input type="hidden" id="form-id" name="id">
                    <input type="hidden" id="form-module" name="module">
                    <input type="hidden" id="form-action" name="action">
                    <input type="hidden" id="form-csrf" name="_csrf">
                    <%
                        String adminPushCsrf = com.ebookBuy301.util.CsrfUtil.getToken(request.getSession());
                    %>

                    <div id="lecture-form-fields">
                        <div class="form-group">
                            <label>讲座标题 *</label>
                            <input type="text" id="lecture-title" name="title" required placeholder="输入讲座标题">
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label>主讲人 *</label>
                                <input type="text" id="lecture-speaker" name="speaker" required placeholder="主讲人姓名">
                            </div>
                            <div class="form-group">
                                <label>职称</label>
                                <input type="text" id="lecture-speaker-title" name="speakerTitle" placeholder="如：教授、博士">
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label>讲座时间</label>
                                <input type="text" id="lecture-time" name="lectureTime" placeholder="如：14:00-16:00">
                            </div>
                            <div class="form-group">
                                <label>状态</label>
                                <select id="lecture-status" name="status">
                                    <option value="upcoming">🔜 即将开始</option>
                                    <option value="ongoing">🔴 进行中</option>
                                    <option value="completed">✅ 已完成</option>
                                    <option value="cancelled">❌ 已取消</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label>是否在线</label>
                                <select id="lecture-online" name="isOnline">
                                    <option value="false">线下讲座</option>
                                    <option value="true">🌐 在线直播</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>直播链接</label>
                                <input type="text" id="lecture-url" name="meetingUrl" placeholder="输入会议链接">
                            </div>
                        </div>
                        <div class="form-group">
                            <label>讲座简介 *</label>
                            <textarea id="lecture-desc" name="description" rows="4" required
                                placeholder="详细描述讲座内容"></textarea>
                        </div>
                    </div>

                    <div id="faculty-form-fields" style="display:none;">
                        <div class="form-row">
                            <div class="form-group">
                                <label>导师姓名 *</label>
                                <input type="text" id="faculty-name" name="facultyName" required placeholder="导师姓名">
                            </div>
                            <div class="form-group">
                                <label>职称 *</label>
                                <input type="text" id="faculty-title" name="facultyTitle" required
                                    placeholder="如：教授、博导">
                            </div>
                        </div>
                        <div class="form-group">
                            <label>研究方向 *</label>
                            <input type="text" id="faculty-research" name="researchArea" required placeholder="研究方向">
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label>所属部门</label>
                                <input type="text" id="faculty-dept" name="department" placeholder="所属院系">
                            </div>
                            <div class="form-group">
                                <label>邮箱</label>
                                <input type="email" id="faculty-email" name="email" placeholder="导师邮箱">
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label>办公室</label>
                                <input type="text" id="faculty-office" name="office" placeholder="办公室地址">
                            </div>
                            <div class="form-group">
                                <label>办公时间</label>
                                <input type="text" id="faculty-hours" name="officeHours" placeholder="如：周一 14:00-17:00">
                            </div>
                        </div>
                        <div class="form-group">
                            <label>个人简介 *</label>
                            <textarea id="faculty-bio" name="bio" rows="4" required placeholder="导师个人简介"></textarea>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="button" class="btn-cancel" onclick="closeModal()">取消</button>
                        <button type="button" class="btn-submit" onclick="submitForm()">
                            <i class="fas fa-paper-plane"></i> 发送
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <div class="toast" id="toast"></div>

        <script>
            var currentModule = 'lecture';

            function switchModule(module) {
                currentModule = module;
                document.querySelectorAll('.tab-btn').forEach(function (btn) {
                    btn.classList.remove('active');
                });
                document.querySelector('[data-module="' + module + '"]').classList.add('active');
                document.getElementById('lecture-panel').style.display = module === 'lecture' ? 'block' : 'none';
                document.getElementById('faculty-panel').style.display = module === 'faculty' ? 'block' : 'none';
                if (module === 'lecture') {
                    loadLectures();
                } else {
                    loadFaculty();
                }
            }

            function loadData() {
                loadLectures();
                loadFaculty();
            }

            function loadLectures() {
                fetch('adminPush?action=list&module=lecture')
                    .then(function (res) { return res.json(); })
                    .then(function (data) {
                        renderLectureList(data);
                        document.getElementById('lecture-count').textContent = data.length;
                    })
                    .catch(function (err) {
                        console.error('加载讲座失败:', err);
                        showToast('加载失败', 'error');
                    });
            }

            function loadFaculty() {
                fetch('adminPush?action=list&module=faculty')
                    .then(function (res) { return res.json(); })
                    .then(function (data) {
                        renderFacultyList(data);
                        document.getElementById('faculty-count').textContent = data.length;
                    })
                    .catch(function (err) {
                        console.error('加载导师失败:', err);
                        showToast('加载失败', 'error');
                    });
            }

            function renderLectureList(lectures) {
                var container = document.getElementById('lecture-list');
                if (!lectures || lectures.length === 0) {
                    container.innerHTML = '<div class="empty-state"><i class="fas fa-folder-open"></i><p>暂无讲座信息</p></div>';
                    return;
                }
                var html = '';
                for (var i = 0; i < lectures.length; i++) {
                    var l = lectures[i];
                    var dateStr = l.lectureDate ? new Date(l.lectureDate).toLocaleDateString() : '待定';
                    var statusBadge = getLectureStatusBadge(l.status);
                    var onlineLink = '';
                    if (l.online && l.meetingUrl) {
                        onlineLink = '<a class="lec-link" href="' + escapeHtml(l.meetingUrl) + '" target="_blank" onclick="event.stopPropagation()">🌐 在线参加</a>';
                    }
                    html += '<div class="lecture-card">';
                    html += '<span class="lec-date">' + dateStr + '</span>';
                    html += '<h3>' + escapeHtml(l.title) + '</h3>';
                    html += '<p>主讲：' + escapeHtml(l.speaker || '未知');
                    if (l.speakerTitle) {
                        html += ' · ' + escapeHtml(l.speakerTitle);
                    }
                    html += '</p>';
                    if (l.description) {
                        html += '<p class="lec-desc">' + escapeHtml(l.description) + '</p>';
                    }
                    html += '<span class="lec-status" style="color:' + statusBadge.color + ';border-color:' + statusBadge.color + '">' + statusBadge.text + '</span>';
                    if (onlineLink) {
                        html += onlineLink;
                    }
                    html += '<div class="card-actions">';
                    html += '<button class="btn-edit" onclick="editLecture(' + l.id + ')"><i class="fas fa-edit"></i> 编辑</button>';
                    html += '<button class="btn-delete" onclick="deleteLecture(' + l.id + ')"><i class="fas fa-trash"></i> 删除</button>';
                    html += '</div></div>';
                }
                container.innerHTML = html;
            }

            function renderFacultyList(faculty) {
                var container = document.getElementById('faculty-list');
                if (!faculty || faculty.length === 0) {
                    container.innerHTML = '<div class="empty-state"><i class="fas fa-users"></i><p>暂无导师信息</p></div>';
                    return;
                }
                var html = '';
                for (var i = 0; i < faculty.length; i++) {
                    var f = faculty[i];
                    var icon = f.avatarIcon || '👨‍🏫';
                    html += '<div class="teacher-card">';
                    html += '<div class="teacher-avatar">' + icon + '</div>';
                    html += '<h3>' + escapeHtml(f.name);
                    if (f.title) {
                        html += ' ' + escapeHtml(f.title);
                    }
                    html += '</h3>';
                    if (f.researchArea) {
                        html += '<p>' + escapeHtml(f.researchArea);
                        if (f.department) {
                            html += '（' + escapeHtml(f.department) + '）';
                        }
                        html += '</p>';
                    }
                    if (f.bio) {
                        html += '<p class="teacher-bio">' + escapeHtml(f.bio) + '</p>';
                    }
                    if (f.email) {
                        html += '<p class="teacher-email">📧 ' + escapeHtml(f.email) + '</p>';
                    }
                    html += '<div class="card-actions">';
                    html += '<button class="btn-edit" onclick="editFaculty(' + f.id + ')"><i class="fas fa-edit"></i> 编辑</button>';
                    html += '<button class="btn-delete" onclick="deleteFaculty(' + f.id + ')"><i class="fas fa-trash"></i> 删除</button>';
                    html += '</div></div>';
                }
                container.innerHTML = html;
            }

            function getLectureStatusBadge(status) {
                var map = {
                    'upcoming': { text: '🔜 即将开始', color: '#ffa502' },
                    'ongoing': { text: '🔴 进行中', color: '#ff4757' },
                    'completed': { text: '✅ 已完成', color: '#2ed573' },
                    'cancelled': { text: '❌ 已取消', color: '#9e9e9e' }
                };
                return map[status] || { text: '📢', color: '#00f2ff' };
            }

            function showAddLectureModal() {
                document.getElementById('modal-title').textContent = '添加讲座';
                document.getElementById('lecture-form-fields').style.display = 'block';
                document.getElementById('faculty-form-fields').style.display = 'none';
                document.getElementById('modal-form').reset();
                document.getElementById('form-id').value = '';
                document.getElementById('form-module').value = 'lecture';
                document.getElementById('form-action').value = 'add';
                document.getElementById('form-csrf').value = window.parent.CSRF_TOKEN || window.CSRF_TOKEN || '<%= adminPushCsrf %>';
                document.getElementById('modal-overlay').style.display = 'flex';
            }

            function showAddFacultyModal() {
                document.getElementById('modal-title').textContent = '添加导师';
                document.getElementById('lecture-form-fields').style.display = 'none';
                document.getElementById('faculty-form-fields').style.display = 'block';
                document.getElementById('modal-form').reset();
                document.getElementById('form-id').value = '';
                document.getElementById('form-module').value = 'faculty';
                document.getElementById('form-action').value = 'add';
                document.getElementById('form-csrf').value = window.parent.CSRF_TOKEN || window.CSRF_TOKEN || '<%= adminPushCsrf %>';
                document.getElementById('modal-overlay').style.display = 'flex';
            }

            function editLecture(id) {
                fetch('adminPush?action=list&module=lecture')
                    .then(function (res) { return res.json(); })
                    .then(function (data) {
                        var lecture = null;
                        for (var i = 0; i < data.length; i++) {
                            if (data[i].id === id) {
                                lecture = data[i];
                                break;
                            }
                        }
                        if (lecture) {
                            document.getElementById('modal-title').textContent = '编辑讲座';
                            document.getElementById('lecture-form-fields').style.display = 'block';
                            document.getElementById('faculty-form-fields').style.display = 'none';
                            document.getElementById('modal-form').reset();
                            document.getElementById('form-id').value = lecture.id;
                            document.getElementById('form-module').value = 'lecture';
                            document.getElementById('form-action').value = 'update';
                            document.getElementById('form-csrf').value = window.parent.CSRF_TOKEN || window.CSRF_TOKEN || '<%= adminPushCsrf %>';
                            document.getElementById('lecture-title').value = lecture.title || '';
                            document.getElementById('lecture-speaker').value = lecture.speaker || '';
                            document.getElementById('lecture-speaker-title').value = lecture.speakerTitle || '';
                            document.getElementById('lecture-time').value = lecture.lectureTime || '';
                            document.getElementById('lecture-status').value = lecture.status || 'upcoming';
                            document.getElementById('lecture-online').value = lecture.online ? 'true' : 'false';
                            document.getElementById('lecture-url').value = lecture.meetingUrl || '';
                            document.getElementById('lecture-desc').value = lecture.description || '';
                            document.getElementById('modal-overlay').style.display = 'flex';
                        }
                    });
            }

            function editFaculty(id) {
                fetch('adminPush?action=list&module=faculty')
                    .then(function (res) { return res.json(); })
                    .then(function (data) {
                        var faculty = null;
                        for (var i = 0; i < data.length; i++) {
                            if (data[i].id === id) {
                                faculty = data[i];
                                break;
                            }
                        }
                        if (faculty) {
                            document.getElementById('modal-title').textContent = '编辑导师';
                            document.getElementById('lecture-form-fields').style.display = 'none';
                            document.getElementById('faculty-form-fields').style.display = 'block';
                            document.getElementById('modal-form').reset();
                            document.getElementById('form-id').value = faculty.id;
                            document.getElementById('form-module').value = 'faculty';
                            document.getElementById('form-action').value = 'update';
                            document.getElementById('form-csrf').value = window.parent.CSRF_TOKEN || window.CSRF_TOKEN || '<%= adminPushCsrf %>';
                            document.getElementById('faculty-name').value = faculty.name || '';
                            document.getElementById('faculty-title').value = faculty.title || '';
                            document.getElementById('faculty-research').value = faculty.researchArea || '';
                            document.getElementById('faculty-dept').value = faculty.department || '';
                            document.getElementById('faculty-email').value = faculty.email || '';
                            document.getElementById('faculty-office').value = faculty.office || '';
                            document.getElementById('faculty-hours').value = faculty.officeHours || '';
                            document.getElementById('faculty-bio').value = faculty.bio || '';
                            document.getElementById('modal-overlay').style.display = 'flex';
                        }
                    });
            }

            function deleteLecture(id) {
                if (confirm('确定要删除这条讲座吗？')) {
                    fetch('adminPush', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: 'action=delete&module=lecture&id=' + id + '&_csrf=' + encodeURIComponent(window.parent.CSRF_TOKEN || window.CSRF_TOKEN || '')
                    })
                        .then(function (res) { return res.json(); })
                        .then(function (data) {
                            showToast(data.message, data.success ? 'success' : 'error');
                            if (data.success) loadLectures();
                        });
                }
            }

            function deleteFaculty(id) {
                if (confirm('确定要删除这位导师吗？')) {
                    fetch('adminPush', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: 'action=delete&module=faculty&id=' + id + '&_csrf=' + encodeURIComponent(window.parent.CSRF_TOKEN || window.CSRF_TOKEN || '')
                    })
                        .then(function (res) { return res.json(); })
                        .then(function (data) {
                            showToast(data.message, data.success ? 'success' : 'error');
                            if (data.success) loadFaculty();
                        });
                }
            }

            function closeModal() {
                document.getElementById('modal-overlay').style.display = 'none';
                document.getElementById('modal-form').reset();
            }

            function submitForm() {
                var form = document.getElementById('modal-form');

                var moduleField = document.getElementById('form-module');
                var actionField = document.getElementById('form-action');

                if (!moduleField.value || moduleField.value.trim() === '') {
                    moduleField.value = currentModule;
                }

                if (!actionField.value || actionField.value.trim() === '') {
                    actionField.value = 'add';
                }

                console.log('=== Form Debug Info ===');
                console.log('Module:', moduleField.value);
                console.log('Action:', actionField.value);

                var formData = new FormData(form);
                var params = new URLSearchParams(formData);

                console.log('Form Data entries:');
                for (var [key, value] of formData.entries()) {
                    console.log('  ' + key + ': ' + value);
                }

                fetch('adminPush', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: params
                }).then(function (res) {
                    // 处理 CSRF 403 等非 200 响应
                    if (!res.ok) {
                        return res.json().then(function (data) {
                            throw new Error(data.error || data.message || '请求失败 (HTTP ' + res.status + ')');
                        });
                    }
                    return res.json();
                }).then(function (data) {
                    if (data.success) {
                        showToast(data.message || '操作成功', 'success');
                        closeModal();
                        if (currentModule === 'lecture') {
                            loadLectures();
                        } else {
                            loadFaculty();
                        }
                    } else {
                        showToast(data.message || '操作失败', 'error');
                    }
                }).catch(function (err) {
                    console.error('提交失败:', err);
                    showToast('提交失败: ' + err.message, 'error');
                });
            }



            function showToast(message, type) {
                var toast = document.getElementById('toast');
                toast.textContent = message;
                toast.className = 'toast toast-' + type;
                toast.style.display = 'block';
                setTimeout(function () {
                    toast.style.display = 'none';
                }, 3000);
            }

            function escapeHtml(text) {
                if (!text) return '';
                var div = document.createElement('div');
                div.textContent = text;
                return div.innerHTML;
            }

            document.addEventListener('DOMContentLoaded', loadData);
        </script>
    <script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>

    </html>