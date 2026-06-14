<%--
 =============================================================================
 virtualClassroom.jsp
 =============================================================================

 用途      功能页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList, java.util.Map" %>
<%
    ArrayList<Map<String, String>> schedule = (ArrayList<Map<String, String>>) request.getAttribute("schedule");
    if (schedule == null) schedule = new ArrayList<>();
    String ctx = request.getContextPath();
    String[] days = {"周一","周二","周三","周四","周五","周六","周日"};
    String[] periods = {"第1节\n8:00-9:40","第2节\n10:00-11:40","第3节\n14:00-15:40","第4节\n16:00-17:40","第5节\n19:00-20:40","第6节\n20:50-22:00"};
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>
<script>window.CONTEXT_PATH = '<%= ctx %>';</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>博雅书院 | 虚拟教室</title>
    <link rel="stylesheet" href="<%= ctx %>/CSS/index.css">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{background:var(--bg-space,#0a0b1a);color:#fff;font-family:'Segoe UI','PingFang SC',sans-serif;min-height:100vh}
        @keyframes fadeInUp{from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)}}
        @keyframes shimmer{0%{background-position:-200% 0}100%{background-position:200% 0}}
        @keyframes pulseGlow{0%,100%{box-shadow:0 0 10px rgba(0,242,255,0.05)}50%{box-shadow:0 0 25px rgba(0,242,255,0.15)}}
        .classroom-container{max-width:1200px;margin:0 auto;padding:30px 20px}
        .classroom-header{text-align:center;margin-bottom:30px;animation:fadeInUp .6s ease-out}
        .classroom-header h1{font-size:2.2rem;margin-bottom:10px;background:linear-gradient(135deg,#fff 0%,var(--glow-primary,#00f2ff) 50%,#fff 100%);background-size:200% auto;-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;animation:shimmer 3s linear infinite}
        .classroom-header p{color:rgba(255,255,255,0.5);font-size:1rem}
        .back-btn{display:inline-flex;align-items:center;gap:8px;padding:10px 24px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:10px;color:rgba(255,255,255,0.7);text-decoration:none;cursor:pointer;transition:all .3s;margin-bottom:20px;font-size:.92rem}
        .back-btn:hover{background:rgba(0,242,255,0.12);border-color:rgba(0,242,255,0.3);color:#fff;transform:translateX(-4px)}
        .quick-actions{display:flex;gap:12px;justify-content:center;margin-bottom:25px;flex-wrap:wrap;animation:fadeInUp .6s ease-out .1s both}
        .quick-action{padding:10px 22px;background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.07);border-radius:12px;color:rgba(255,255,255,0.7);cursor:pointer;transition:all .4s cubic-bezier(.175,.885,.32,1.275);font-size:.88rem;position:relative;overflow:hidden}
        .quick-action::after{content:'';position:absolute;inset:0;background:radial-gradient(circle at 50% 100%,rgba(0,242,255,0.1),transparent 70%);opacity:0;transition:opacity .3s}
        .quick-action:hover{border-color:rgba(0,242,255,0.3);color:#fff;transform:translateY(-3px);box-shadow:0 6px 20px rgba(0,0,0,0.2)}
        .quick-action:hover::after{opacity:1}
        .timetable{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:20px;overflow:hidden;animation:fadeInUp .7s ease-out .2s both;backdrop-filter:blur(10px)}
        .timetable-header{display:grid;grid-template-columns:100px repeat(5,1fr);background:rgba(0,242,255,0.06)}
        .timetable-header div{padding:14px 8px;text-align:center;font-weight:600;font-size:.88rem;border-bottom:1px solid rgba(255,255,255,0.06);color:rgba(255,255,255,0.8)}
        .timetable-header div:first-child{background:rgba(0,0,0,0.15);border-radius:0}
        .timetable-body{display:grid;grid-template-columns:100px repeat(5,1fr)}
        .period-label{padding:12px 8px;text-align:center;font-size:.72rem;color:rgba(255,255,255,0.4);border-bottom:1px solid rgba(255,255,255,0.03);border-right:1px solid rgba(255,255,255,0.04);white-space:pre-line;display:flex;align-items:center;justify-content:center;background:rgba(0,0,0,0.08)}
        .timetable-cell{padding:4px;border-bottom:1px solid rgba(255,255,255,0.03);border-right:1px solid rgba(255,255,255,0.03);min-height:72px}
        .course-card{background:rgba(255,255,255,0.03);border-left:3px solid;border-radius:8px;padding:8px 10px;cursor:pointer;transition:all .3s;height:100%;position:relative;overflow:hidden}
        .course-card::after{content:'';position:absolute;inset:0;background:linear-gradient(135deg,transparent,rgba(255,255,255,0.03));opacity:0;transition:opacity .3s}
        .course-card:hover{transform:scale(1.04);box-shadow:0 4px 18px rgba(0,0,0,0.3)}
        .course-card:hover::after{opacity:1}
        .course-card.blue{border-color:#3b82f6;background:rgba(59,130,246,0.08)}
        .course-card.green{border-color:#10b981;background:rgba(16,185,129,0.08)}
        .course-card.purple{border-color:#a855f7;background:rgba(168,85,247,0.08)}
        .course-card.orange{border-color:#f59e0b;background:rgba(245,158,11,0.08)}
        .course-card.red{border-color:#ef4444;background:rgba(239,68,68,0.08)}
        .course-card.cyan{border-color:#06b6d4;background:rgba(6,182,212,0.08)}
        .course-card .cname{font-size:.82rem;font-weight:600;margin-bottom:3px;position:relative;z-index:1}
        .course-card .cinfo{font-size:.68rem;color:rgba(255,255,255,0.4);position:relative;z-index:1}
        .course-card .ctype{display:inline-block;font-size:.62rem;padding:1px 6px;border-radius:4px;background:rgba(255,255,255,0.08);margin-top:3px;position:relative;z-index:1}
        .detail-modal{display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.75);z-index:1000;justify-content:center;align-items:center;backdrop-filter:blur(6px)}
        .detail-modal.active{display:flex}
        .detail-panel{background:linear-gradient(145deg,#131d30,#0e1728);border:1px solid rgba(0,242,255,0.2);border-radius:20px;padding:35px;max-width:500px;width:90%;position:relative;box-shadow:0 25px 60px rgba(0,0,0,0.5);animation:fadeInUp .3s ease-out}
        .detail-panel h3{font-size:1.4rem;margin-bottom:20px}
        .detail-close{position:absolute;top:15px;right:20px;background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.1);border-radius:50%;width:36px;height:36px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:1.2rem;cursor:pointer;transition:all .3s}
        .detail-close:hover{background:rgba(239,68,68,0.2);border-color:rgba(239,68,68,0.4);transform:rotate(90deg)}
        .detail-row{display:flex;justify-content:space-between;padding:12px 0;border-bottom:1px solid rgba(255,255,255,0.05);font-size:.95rem}
        .detail-row .dlabel{color:rgba(255,255,255,0.45)}
        .detail-row .dval{font-weight:500}
        .enter-class-btn{width:100%;padding:14px;background:linear-gradient(135deg,#00d4e0,#00a8b5);border:none;border-radius:12px;color:#fff;font-size:1rem;font-weight:600;cursor:pointer;margin-top:25px;transition:all .3s;position:relative;overflow:hidden}
        .enter-class-btn:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(0,212,224,0.35)}
        .enter-class-btn:active{transform:translateY(0)}
        .week-selector{display:flex;gap:8px;justify-content:center;margin-bottom:20px;animation:fadeInUp .6s ease-out .15s both}
        .week-btn{padding:8px 20px;background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.08);border-radius:10px;color:rgba(255,255,255,0.5);cursor:pointer;font-size:.85rem;transition:all .3s}
        .week-btn.active,.week-btn:hover{background:rgba(0,242,255,0.12);border-color:rgba(0,242,255,0.3);color:#fff}
        ::-webkit-scrollbar{width:6px}::-webkit-scrollbar-track{background:rgba(255,255,255,0.02)}::-webkit-scrollbar-thumb{background:rgba(0,242,255,0.2);border-radius:3px}
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
        html[data-theme$="-light"] [class*="toast"],[class*="notification"]{color:#3d3929!important;background:rgba(248,243,230,.96)!important}
        html[data-theme$="-light"] a{color:#2563eb!important}
    </style>

</head>
<body>
    <div class="classroom-container">
        <a class="back-btn" href="<%= ctx %>/campus3d">← 返回元宇宙校园</a>
        <div class="classroom-header">
            <h1><span class="glow-text">🏫</span> 虚拟教室</h1>
            <p>在线课表与虚拟课堂</p>
        </div>

        <div class="quick-actions">
            <div class="quick-action" onclick="showToast('📋 已复制本周课表链接')">📋 分享课表</div>
            <div class="quick-action" onclick="showToast('🔔 已开启上课提醒')">🔔 上课提醒</div>
            <div class="quick-action" onclick="showToast('📥 课表已导出为PDF')">📥 导出课表</div>
            <div class="quick-action" onclick="showToast('➕ 课程已添加到日历')">➕ 同步日历</div>
        </div>

        <div class="week-selector">
            <div class="week-btn" onclick="selectWeek(this,-1)">◀ 上一周</div>
            <div class="week-btn active">本周 (第14周)</div>
            <div class="week-btn" onclick="selectWeek(this,1)">下一周 ▶</div>
        </div>

        <div class="timetable">
            <div class="timetable-header">
                <div>时间</div>
                <% for (int i = 0; i < 5; i++) { %><div><%= days[i] %></div><% } %>
            </div>
            <div class="timetable-body">
                <% for (int p = 1; p <= 5; p++) { %>
                <div class="period-label"><%= periods[p-1] %></div>
                <% for (int d = 0; d < 5; d++) { %>
                <div class="timetable-cell">
                    <% boolean found = false;
                       for (Map<String, String> c : schedule) {
                           if (c.get("day").equals(days[d]) && c.get("period").equals(String.valueOf(p))) { found = true; %>
                    <div class="course-card <%= c.get("color") %>" onclick='showCourseDetail(<%= d+1 %>,<%= p %>,this)'
                         data-name="<%= c.get("name") %>" data-teacher="<%= c.get("teacher") %>"
                         data-location="<%= c.get("location") %>" data-type="<%= c.get("type") %>">
                        <div class="cname"><%= c.get("name") %></div>
                        <div class="cinfo"><%= c.get("location") %></div>
                        <span class="ctype"><%= c.get("type") %></span>
                    </div>
                    <% break; }
                       }
                       if (!found) { %>
                    <div style="height:100%"></div>
                    <% } %>
                </div>
                <% } %>
                <% } %>
            </div>
        </div>
    </div>

    <div class="detail-modal" id="courseDetail">
        <div class="detail-panel">
            <button class="detail-close" onclick="document.getElementById('courseDetail').classList.remove('active')">&times;</button>
            <h3 id="courseName">课程名称</h3>
            <div class="detail-row"><span class="dlabel">授课教师</span><span class="dval" id="courseTeacher">-</span></div>
            <div class="detail-row"><span class="dlabel">上课地点</span><span class="dval" id="courseLocation">-</span></div>
            <div class="detail-row"><span class="dlabel">课程类型</span><span class="dval" id="courseType">-</span></div>
            <div class="detail-row"><span class="dlabel">课程进度</span><span class="dval">12/16 周 (75%)</span></div>
            <div class="detail-row"><span class="dlabel">在线状态</span><span class="dval" style="color:#10b981">● 教室开放中</span></div>
            <button class="enter-class-btn" onclick="enterClass()">🚀 进入虚拟教室</button>
        </div>
    </div>

    <script>
    function showCourseDetail(day, period, el) {
        document.getElementById('courseName').textContent = el.getAttribute('data-name');
        document.getElementById('courseTeacher').textContent = el.getAttribute('data-teacher');
        document.getElementById('courseLocation').textContent = el.getAttribute('data-location');
        document.getElementById('courseType').textContent = el.getAttribute('data-type');
        document.getElementById('courseDetail').classList.add('active');
    }
    function enterClass() {
        document.getElementById('courseDetail').classList.remove('active');
        showToast('🚀 正在连接虚拟教室... 请稍候');
    }
    function selectWeek(el, dir) {
        el.parentElement.querySelectorAll('.week-btn').forEach(function(b){b.classList.remove('active')});
        el.classList.add('active');

        var weekNum = parseInt(el.getAttribute('data-week'));
        var courseGrid = document.getElementById('courseGrid');

        if (courseGrid) courseGrid.style.opacity = '0.5';

        // 从后端加载对应周次课表
        fetch(window.CONTEXT_PATH + '/virtualClassroom?action=getWeek&week=' + weekNum)
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success && data.schedule) {
                    renderSchedule(data.schedule);
                }
                if (courseGrid) courseGrid.style.opacity = '1';
                showToast(dir < 0 ? '已切换到上一周' : '已切换到下一周');
            })
            .catch(function() {
                if (courseGrid) courseGrid.style.opacity = '1';
                showToast('切换失败，请稍后重试');
            });
    }
    function showToast(msg) {
        var t = document.createElement('div');
        t.textContent = msg;
        t.style.cssText = 'position:fixed;top:20px;left:50%;transform:translateX(-50%);padding:12px 24px;background:linear-gradient(135deg,#1a3050,#162540);border:1px solid rgba(0,242,255,0.3);border-radius:10px;color:#fff;z-index:9999;font-size:.95rem;box-shadow:0 4px 20px rgba(0,0,0,0.4);opacity:0;transition:opacity .3s';
        document.body.appendChild(t);
        setTimeout(function(){t.style.opacity='1'},10);
        setTimeout(function(){t.style.opacity='0';setTimeout(function(){t.remove()},300)},2500);
    }
    document.getElementById('courseDetail').addEventListener('click', function(e) {
        if (e.target === this) this.classList.remove('active');
    });
    </script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>
