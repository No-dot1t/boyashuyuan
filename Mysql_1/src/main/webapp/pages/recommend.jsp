<%--
 =============================================================================
 recommend.jsp  ——  智能阅读中心（侧边栏主导航）
 功能：Hero + 统计、日历热力图、雷达图、AI推荐、学习路径
 路由：/recommend（RecommendServlet 转发）
 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ebookBuy301.pojo.*, java.util.*, java.text.DecimalFormat" %>
<%!
    private String sf(Object o) { return o != null ? o.toString() : ""; }
%>
<%
    String ctx = request.getContextPath();
    StudySummary summary = (StudySummary) request.getAttribute("summary");
    ArrayList<Skill> skills = (ArrayList<Skill>) request.getAttribute("skills");
    ArrayList<RecommendItem> items = (ArrayList<RecommendItem>) request.getAttribute("items");
    ArrayList<LearningStep> steps = (ArrayList<LearningStep>) request.getAttribute("steps");
    String filterType = (String) request.getAttribute("filterType");
    boolean isPersonal = request.getAttribute("isPersonal") != null && (Boolean) request.getAttribute("isPersonal");

    if (summary == null) summary = new StudySummary();
    if (skills == null) skills = new ArrayList<>();
    if (items == null) items = new ArrayList<>();
    if (steps == null) steps = new ArrayList<>();
    if (filterType == null) filterType = "all";

    DecimalFormat df = new DecimalFormat("#");
    String studyH = summary.getTotalHours() != null ? df.format(summary.getTotalHours()) : "0";
    int courses = summary.getTotalCourses();
    int points = summary.getCampusPoints();
    int weekPct = summary.getWeekProgress();

    Map<String, String[]> tStyle = new LinkedHashMap<>();
    tStyle.put("courses",  new String[]{"linear-gradient(135deg, #667eea, #764ba2)", "课程", "📖"});
    tStyle.put("books",    new String[]{"linear-gradient(135deg, #f093fb, #f5576c)", "图书", "📕"});
    tStyle.put("lectures", new String[]{"linear-gradient(135deg, #4facfe, #00f2fe)", "讲座", "🎙️"});

    StringBuilder skillsJson;
    if (!isPersonal || skills.isEmpty()) {
        skillsJson = new StringBuilder("[]");
    } else {
        skillsJson = new StringBuilder("[");
        for (int i = 0; i < skills.size(); i++) {
            Skill sk = skills.get(i);
            if (i > 0) skillsJson.append(",");
            skillsJson.append("{name:\"").append(sk.getSkillName() != null ? sk.getSkillName() : "Skill"+(i+1))
                      .append("\",value:").append(sk.getSkillValue()).append("}");
        }
        skillsJson.append("]");
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>智能阅读中心 · 博雅书院</title>
    <link rel="stylesheet" href="<%= ctx %>/CSS/recommend.css?v=rc3">
    <script src="<%= ctx %>/js/echarts.js"></script>
    <style>
        :root {
            --deep:#060b14; --card:#0d1525; --card-h:#131d32;
            --text:#e5e9f0; --muted:#7b8ba8; --border:#1a2740;
            --accent:#4facfe; --glow:rgba(79,172,254,.25);
            --green:#34d399; --purple:#a78bfa; --pink:#f472b6; --amber:#f59e0b;
        }
        *{margin:0;padding:0;box-sizing:border-box}
        body{
            background:var(--deep); color:var(--text);
            font-family:-apple-system,BlinkMacSystemFont,"Segoe UI","PingFang SC","Microsoft YaHei",sans-serif;
            min-height:100vh; overflow-y:auto; overflow-x:hidden; -webkit-font-smoothing:antialiased;
        }
        /* ── 星空背景增强 ── */
        .sf{position:fixed;inset:0;pointer-events:none;z-index:0}
        .sd{position:absolute;border-radius:50%;animation:tw 3s ease-in-out infinite}
        .sd.s{width:1px;height:1px;background:rgba(255,255,255,.15)}
        .sd.m{width:2px;height:2px;background:rgba(255,255,255,.25);box-shadow:0 0 6px rgba(79,172,254,.3)}
        .sd.l{width:3px;height:3px;background:rgba(167,139,250,.35);box-shadow:0 0 10px rgba(167,139,250,.4)}
        @keyframes tw{0%,100%{opacity:.1;transform:scale(1)}50%{opacity:.6;transform:scale(2.2)}}
        /* ── 背景光晕 ── */
        .bg-aurora{position:fixed;inset:0;pointer-events:none;z-index:0;overflow:hidden}
        .bg-aurora::before,.bg-aurora::after{content:'';position:absolute;border-radius:50%;filter:blur(120px)}
        .bg-aurora::before{width:600px;height:600px;background:radial-gradient(circle,rgba(79,172,254,.06),transparent);
            top:-200px;left:-100px;animation:aurora1 15s ease-in-out infinite}
        .bg-aurora::after{width:500px;height:500px;background:radial-gradient(circle,rgba(167,139,250,.05),transparent);
            bottom:-150px;right:-100px;animation:aurora2 18s ease-in-out infinite}
        @keyframes aurora1{0%,100%{transform:translate(0,0)}50%{transform:translate(100px,60px)}}
        @keyframes aurora2{0%,100%{transform:translate(0,0)}50%{transform:translate(-80px,-40px)}}
        .wrap{max-width:1280px;margin:0 auto;padding:0 20px 80px;position:relative;z-index:1}
        /* ── Hero ── */
        .hero{text-align:center;padding:44px 16px 12px;position:relative}
        .hero h1{
            font-size:36px;font-weight:900;letter-spacing:4px;
            background:linear-gradient(135deg,#e0e7ff 0%,#7dd3fc 25%,#a78bfa 55%,#f59e0b 85%);
            background-size:200% 200%;
            -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;
            animation:titleShine 6s ease-in-out infinite;
        }
        @keyframes titleShine{0%,100%{background-position:0% 50%}50%{background-position:100% 50%}}
        .hero .sub{color:var(--muted);font-size:13px;margin-top:6px;letter-spacing:.5px}
        .hero-deco{display:flex;justify-content:center;gap:6px;margin-top:12px}
        .hero-deco span{width:4px;height:4px;border-radius:50%;background:var(--accent);animation:decoPulse 1.8s ease-in-out infinite}
        .hero-deco span:nth-child(2){animation-delay:.2s;background:var(--purple)}
        .hero-deco span:nth-child(3){animation-delay:.4s;background:var(--amber)}
        @keyframes decoPulse{0%,100%{opacity:.2;transform:scale(1)}50%{opacity:.8;transform:scale(1.6)}}
        /* ── 统计条增强 ── */
        .sbar{display:flex;gap:14px;margin:18px 0 24px;flex-wrap:wrap}
        .sitem{
            flex:1;min-width:140px;display:flex;align-items:center;gap:12px;
            padding:16px 18px;background:var(--card);border:1px solid var(--border);
            border-radius:16px;transition:all .35s cubic-bezier(.22,.61,.36,1);
            position:relative;overflow:hidden;
        }
        .sitem::before{
            content:'';position:absolute;inset:0;border-radius:16px;opacity:0;
            background:radial-gradient(ellipse at top left,rgba(79,172,254,.08),transparent 60%);
            transition:opacity .4s;
        }
        .sitem:hover::before{opacity:1}
        .sitem:hover{border-color:var(--glow);transform:translateY(-3px);
            box-shadow:0 8px 28px rgba(0,0,0,.35),0 0 0 1px rgba(79,172,254,.12) inset}
        .sicon{width:44px;height:44px;border-radius:12px;display:flex;align-items:center;
            justify-content:center;font-size:1.3rem;flex-shrink:0;position:relative}
        .sicon::after{content:'';position:absolute;inset:-2px;border-radius:14px;opacity:0;transition:opacity .4s}
        .sitem:hover .sicon::after{opacity:1}
        .sicon.b{background:rgba(79,172,254,.12)} .sicon.b::after{box-shadow:0 0 16px rgba(79,172,254,.15)}
        .sicon.h{background:rgba(167,139,250,.12)} .sicon.h::after{box-shadow:0 0 16px rgba(167,139,250,.15)}
        .sicon.p{background:rgba(244,114,182,.12)} .sicon.p::after{box-shadow:0 0 16px rgba(244,114,182,.15)}
        .sicon.s{background:rgba(52,211,153,.12)} .sicon.s::after{box-shadow:0 0 16px rgba(52,211,153,.15)}
        .sval{font-size:1.35rem;font-weight:800;color:#e8ecf5;line-height:1.2;transition:color .3s}
        .sitem:hover .sval{color:#fff}
        .slabel{font-size:.68rem;color:var(--muted);letter-spacing:.5px;text-transform:uppercase}
        /* streak 高亮 */
        .sitem.streak-active{border-color:rgba(52,211,153,.25)}
        .sitem.streak-active .sicon.s{background:rgba(52,211,153,.18)}
        .sitem.streak-active .sval{color:#34d399}
        /* ── 日历卡片增强 ── */
        .chart-card{
            background:var(--card);border:1px solid var(--border);border-radius:18px;
            padding:18px 16px 12px;margin-bottom:24px;
            transition:border-color .4s;
        }
        .chart-card:hover{border-color:rgba(79,172,254,.18)}
        .chart-card-hd{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:2px}
        .chart-card h3{font-size:.9rem;color:var(--text);display:flex;align-items:center;gap:8px}
        .chart-card .streak-tag{
            display:inline-flex;align-items:center;gap:4px;padding:3px 12px;border-radius:20px;
            font-size:11px;font-weight:700;
            background:rgba(52,211,153,.1);border:1px solid rgba(52,211,153,.25);color:#34d399;
        }
        .chart-sub{font-size:.66rem;color:var(--muted);margin-bottom:8px}
        #readingCalendar{width:100%;height:175px}
        .chart-legend-row{display:flex;justify-content:flex-end;align-items:center;gap:5px;font-size:10px;color:var(--muted);margin-top:6px}
        .chart-legend-box{display:inline-block;width:13px;height:13px;border-radius:3px}
        /* ── 分隔线 ── */
        .section-divider{display:flex;align-items:center;gap:12px;margin:32px 0 20px}
        .section-divider span{font-size:.7rem;color:var(--muted);letter-spacing:2px;white-space:nowrap}
        .section-divider::before,.section-divider::after{content:'';flex:1;height:1px;
            background:linear-gradient(90deg,transparent,var(--border),transparent)}
        /* ── Dashboard ── */
        .dash{display:flex;gap:18px;margin-bottom:28px;align-items:stretch}
        @media(max-width:768px){.dash{flex-direction:column}}
        .dash-col{flex:1;display:flex;flex-direction:column;gap:14px}
        .radar-box{
            background:var(--card);border:1px solid var(--border);border-radius:18px;
            padding:16px 12px 10px;display:flex;flex-direction:column;align-items:center;
            transition:border-color .4s;
        }
        .radar-box:hover{border-color:rgba(79,172,254,.15)}
        .radar-box h3{font-size:.92rem;margin-bottom:2px;color:var(--text);letter-spacing:.5px}
        #radarChart{width:100%;height:280px}
        .stat-mini{
            background:var(--card);border:1px solid var(--border);border-radius:16px;
            padding:16px 18px;display:flex;align-items:center;gap:12px;
            transition:all .35s cubic-bezier(.22,.61,.36,1);
        }
        .stat-mini:hover{border-color:rgba(79,172,254,.25);transform:translateX(4px);
            box-shadow:0 4px 16px rgba(0,0,0,.25)}
        .sm-icon{width:40px;height:40px;border-radius:10px;display:flex;align-items:center;
            justify-content:center;font-size:1.1rem;flex-shrink:0}
        .sm-icon.c{background:rgba(79,172,254,.14)}
        .sm-icon.t{background:rgba(167,139,250,.14)}
        .sm-icon.g{background:rgba(244,114,182,.14)}
        .sm-icon.w{background:rgba(52,211,153,.14)}
        .sm-val{font-size:1.25rem;font-weight:800;color:#e8ecf5}
        .sm-lbl{font-size:.65rem;color:var(--muted);letter-spacing:.3px}
        .sm-full{flex:1}
        .progress-wrap{height:6px;background:rgba(255,255,255,.06);border-radius:3px;margin-top:8px;overflow:hidden}
        .progress-fill{height:100%;border-radius:3px;
            background:linear-gradient(90deg,#4facfe,#a78bfa);transition:width .6s cubic-bezier(.22,.61,.36,1);
            box-shadow:0 0 8px rgba(79,172,254,.2)}
        /* ── 推荐区域 ── */
        .sec{margin-bottom:36px}
        .sec h2{font-size:1.2rem;font-weight:800;margin-bottom:18px;display:flex;align-items:center;gap:10px;letter-spacing:.5px}
        .ftabs{display:flex;gap:10px;margin-bottom:22px;flex-wrap:wrap}
        .ft{padding:8px 20px;border-radius:22px;font-size:12px;font-weight:600;border:1px solid var(--border);
            color:var(--muted);text-decoration:none;transition:all .3s;position:relative}
        .ft:hover{border-color:rgba(79,172,254,.35);color:#c0d8f0;background:rgba(79,172,254,.05)}
        .ft.on{background:linear-gradient(135deg,rgba(79,172,254,.15),rgba(167,139,250,.1));
            border-color:rgba(79,172,254,.45);color:#7dd3fc;box-shadow:0 0 14px rgba(79,172,254,.1)}
        .rgrid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:18px}
        .rcd{
            background:var(--card);border:1px solid var(--border);border-radius:16px;
            overflow:hidden;cursor:pointer;
            transition:all .35s cubic-bezier(.22,.61,.36,1);
            animation:fadeUp .5s ease forwards;opacity:0;
            animation-delay:var(--ad,0s);
        }
        .rcd:hover{border-color:var(--glow);transform:translateY(-5px);
            box-shadow:0 16px 36px rgba(0,0,0,.35),0 0 0 1px rgba(79,172,254,.12) inset}
        .rcd:active{transform:scale(.97)}
        @keyframes fadeUp{from{opacity:0;transform:translateY(22px)}to{opacity:1;transform:translateY(0)}}
        .rcd-cover{height:115px;display:flex;align-items:center;justify-content:center;font-size:40px;
            position:relative;overflow:hidden}
        .rcd-cover::after{
            content:'';position:absolute;inset:0;z-index:4;
            background:linear-gradient(180deg,rgba(255,255,255,.12) 0%,transparent 55%);
            pointer-events:none;
        }
        .rcd-cover img{transition:transform .5s cubic-bezier(.22,.61,.36,1)}
        .rcd:hover .rcd-cover img{transform:scale(1.08)}
        .rcd-badge{position:absolute;top:10px;right:10px;padding:3px 12px;border-radius:16px;
            font-size:10px;font-weight:700;background:rgba(0,0,0,.6);border:1px solid rgba(255,255,255,.1);
            backdrop-filter:blur(6px);z-index:5;letter-spacing:.5px}
        .rcd-badge.hot{color:#fb7185;border-color:rgba(251,113,133,.25)}
        .rcd-badge.trending{color:#f59e0b;border-color:rgba(245,158,11,.25)}
        .rcd-badge.new{color:#34d399;border-color:rgba(52,211,153,.25)}
        .rcd-badge.personal{color:#7dd3fc;border-color:rgba(125,211,252,.25)}
        .rcd-badge.social{color:#c084fc;border-color:rgba(192,132,252,.25)}
        .rcd-body{padding:16px 16px 18px}
        .rcd-title{font-size:14px;font-weight:700;line-height:1.45;margin-bottom:5px;
            display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
        .rcd-cat{font-size:11px;color:var(--muted);margin-bottom:8px}
        .rcd-desc{font-size:11px;color:var(--muted);line-height:1.6;margin-bottom:10px;
            display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
        .rcd-reason{font-size:10px;color:rgba(167,139,250,.7);margin-bottom:8px;
            display:flex;align-items:center;gap:4px}
        .rcd-meta{display:flex;align-items:center;gap:10px;font-size:10px;color:var(--muted);flex-wrap:wrap}
        .rcd-meta span{display:inline-flex;align-items:center;gap:3px}
        .rcd-rating{margin-left:auto;color:#f59e0b;font-weight:700;font-size:12px}
        /* ── 学习路径 ── */
        .path{position:relative;background:var(--card);border:1px solid var(--border);
            border-radius:18px;padding:8px 20px 16px}
        .pstep{display:flex;gap:16px;padding:18px 0;position:relative}
        .pstep:not(:last-child)::before{
            content:'';position:absolute;left:23px;top:52px;bottom:-14px;
            width:2px;background:var(--border);
        }
        .pstep.completed:not(:last-child)::before{background:linear-gradient(180deg,#34d399,var(--border))}
        .pstep.current:not(:last-child)::before{background:linear-gradient(180deg,#4facfe,var(--border))}
        .pnum{
            width:46px;height:46px;border-radius:50%;display:flex;align-items:center;justify-content:center;
            font-size:16px;font-weight:800;flex-shrink:0;z-index:1;
            background:var(--card);border:2px solid var(--border);color:var(--muted);
            transition:all .3s;
        }
        .pstep.completed .pnum{border-color:#34d399;color:#34d399;background:rgba(52,211,153,.1)}
        .pstep.completed .pnum::after{content:'✓'}
        .pstep.completed .pnum span{display:none}
        .pstep.current .pnum{border-color:#4facfe;color:#7dd3fc;background:rgba(79,172,254,.12);
            box-shadow:0 0 18px rgba(79,172,254,.25);animation:pulse 2.2s ease-in-out infinite}
        @keyframes pulse{0%,100%{box-shadow:0 0 18px rgba(79,172,254,.25)}50%{box-shadow:0 0 28px rgba(79,172,254,.4)}}
        .pbody{flex:1;padding-top:4px}
        .pbody h4{font-size:.95rem;margin-bottom:4px;font-weight:700}
        .pbody p{font-size:.76rem;color:var(--muted);line-height:1.55}
        .pstatus{font-size:.68rem;margin-top:6px;font-weight:600}
        .pstatus.completed{color:#34d399}
        .pstatus.current{color:#7dd3fc}
        .pstatus.upcoming{color:var(--muted)}
        /* ── Footer ── */
        .ftr{text-align:center;padding:36px 0 0;color:var(--muted);font-size:11px;
            letter-spacing:5px;opacity:.15;transition:opacity .6s}
        .ftr:hover{opacity:.3}
        /* ── Toast ── */
        .ta-toast{
            position:fixed;top:24px;left:50%;transform:translateX(-50%);
            padding:14px 28px;border-radius:14px;color:#fff;z-index:9999;font-size:.88rem;font-weight:600;
            background:linear-gradient(135deg,rgba(26,48,80,.95),rgba(22,37,64,.95));
            border:1px solid rgba(79,172,254,.35);
            box-shadow:0 8px 32px rgba(0,0,0,.5),0 0 20px rgba(79,172,254,.08);
            opacity:0;transform:translateX(-50%) translateY(-8px);
            transition:all .35s cubic-bezier(.22,.61,.36,1);
            pointer-events:none;
        }
        .ta-toast.show{opacity:1;transform:translateX(-50%) translateY(0)}
        /* ── 响应式 ── */
        @media(max-width:768px){
            .hero h1{font-size:23px;letter-spacing:2px}
            .sbar{gap:8px}.sitem{min-width:calc(50% - 8px);padding:12px 14px}
            .sval{font-size:1.1rem}
            .rgrid{grid-template-columns:1fr}
            .section-divider{margin:24px 0 16px}
            .path{padding:6px 12px 12px}
        }
    </style>
    <!-- ========== 浅色主题 · 阅读中心全覆盖 ========== -->
    <style>
        /* ── CSS变量覆写（驱动所有var()引用）── */
        html[data-theme$="-light"]{
            --deep:#e8dfcf;--card:rgba(238,233,222,.85);--card-h:rgba(243,239,228,.94);
            --text:#3d3929;--muted:#7a7360;--border:rgba(139,119,80,.08);
            --accent:#2563eb;--glow:rgba(37,99,235,.15);
        }
        /* 基础底色 + 隐藏暗色背景装饰 */
        html[data-theme$="-light"] body{background:linear-gradient(170deg,#e9e2d2,#ede5d3 50%,#e4dbca)!important;color:#3d3929!important}
        html[data-theme$="-light"] .bg-aurora,.sf{opacity:.12!important}
        html[data-theme$="-light"] .sd.s{background:rgba(139,119,80,.1)!important}
        html[data-theme$="-light"] .sd.m{background:rgba(139,119,80,.15)!important;box-shadow:0 0 6px rgba(37,99,235,.15)!important}
        html[data-theme$="-light"] .sd.l{background:rgba(139,119,80,.2)!important;box-shadow:0 0 10px rgba(37,99,235,.2)!important}
        /* Hero */
        html[data-theme$="-light"] .hero h1{background:linear-gradient(135deg,#3d3929,#2563eb 25%,#7c3aed 55%,#d97706 85%)!important;background-size:200% 200%!important;-webkit-background-clip:text!important;-webkit-text-fill-color:transparent!important;background-clip:text!important}
        html[data-theme$="-light"] .hero .sub{color:#7a7360!important}
        html[data-theme$="-light"] .hero-deco span{background:#2563eb!important}.hero-deco span:nth-child(2){background:#7c3aed!important}.hero-deco span:nth-child(3){background:#d97706!important}
        /* 统计条 */
        html[data-theme$="-light"] .sval{color:#3d3929!important}
        html[data-theme$="-light"] .sitem:hover{box-shadow:0 8px 28px rgba(139,119,80,.12),0 0 0 1px rgba(37,99,235,.06) inset!important}
        html[data-theme$="-light"] .sitem::before{background:radial-gradient(ellipse at top left,rgba(37,99,235,.05),transparent 60%)!important}
        html[data-theme$="-light"] .sitem:hover .sval{color:#2563eb!important}
        /* 统计条 streak */
        html[data-theme$="-light"] .sitem.streak-active{border-color:rgba(16,185,129,.18)!important}
        html[data-theme$="-light"] .sitem.streak-active .sicon.s{background:rgba(16,185,129,.1)!important}
        html[data-theme$="-light"] .sitem.streak-active .sval{color:#059669!important}
        /* 日历 */
        html[data-theme$="-light"] .chart-card:hover{border-color:rgba(37,99,235,.12)!important}
        html[data-theme$="-light"] .streak-tag{background:rgba(16,185,129,.06)!important;border-color:rgba(16,185,129,.15)!important;color:#059669!important}
        /* 分隔线 */
        html[data-theme$="-light"] .section-divider::before,.section-divider::after{background:linear-gradient(90deg,transparent,rgba(139,119,80,.06),transparent)!important}
        /* Dash */
        html[data-theme$="-light"] .radar-box:hover{border-color:rgba(37,99,235,.1)!important}
        html[data-theme$="-light"] .stat-mini:hover{border-color:rgba(37,99,235,.15)!important;box-shadow:0 4px 16px rgba(139,119,80,.1)!important}
        html[data-theme$="-light"] .sm-val{color:#3d3929!important}
        html[data-theme$="-light"] .progress-wrap{background:rgba(139,119,80,.06)!important}
        html[data-theme$="-light"] .progress-fill{background:linear-gradient(90deg,#2563eb,#7c3aed)!important;box-shadow:0 0 8px rgba(37,99,235,.1)!important}
        /* Tab */
        html[data-theme$="-light"] .ft:hover{border-color:rgba(37,99,235,.25)!important;color:#5c5540!important;background:rgba(37,99,235,.04)!important}
        html[data-theme$="-light"] .ft.on{background:linear-gradient(135deg,rgba(37,99,235,.1),rgba(139,119,80,.06))!important;border-color:rgba(37,99,235,.3)!important;color:#2563eb!important;box-shadow:0 0 14px rgba(37,99,235,.06)!important}
        /* 推荐卡片 */
        html[data-theme$="-light"] .rcd:hover{box-shadow:0 16px 36px rgba(139,119,80,.12),0 0 0 1px rgba(37,99,235,.08) inset!important}
        html[data-theme$="-light"] .rcd-cover::after{background:linear-gradient(180deg,rgba(139,119,80,.06),transparent 55%)!important}
        html[data-theme$="-light"] .rcd-badge{background:rgba(139,119,80,.08)!important;border-color:rgba(139,119,80,.1)!important;color:#7a7360!important}
        html[data-theme$="-light"] .rcd-title{color:#3d3929!important}
        html[data-theme$="-light"] .rcd-reason{color:rgba(37,99,235,.55)!important}
        html[data-theme$="-light"] .rcd-rating{color:#d97706!important}
        /* 学习路径 */
        html[data-theme$="-light"] .pstep.completed .pnum{color:#059669!important;border-color:rgba(16,185,129,.25)!important;background:rgba(16,185,129,.06)!important}
        html[data-theme$="-light"] .pstep.current .pnum{color:#2563eb!important;border-color:rgba(37,99,235,.25)!important;background:rgba(37,99,235,.08)!important;box-shadow:0 0 18px rgba(37,99,235,.15)!important}
        @keyframes lightPulse{0%,100%{box-shadow:0 0 18px rgba(37,99,235,.15)}50%{box-shadow:0 0 24px rgba(37,99,235,.25)}}
        html[data-theme$="-light"] .pstep.current .pnum{animation:lightPulse 2.2s ease-in-out infinite!important}
        html[data-theme$="-light"] .pbody h4{color:#3d3929!important}
        html[data-theme$="-light"] .pstatus.completed{color:#059669!important}
        html[data-theme$="-light"] .pstatus.current{color:#2563eb!important}
        html[data-theme$="-light"] .pstep.completed:not(:last-child)::before{background:linear-gradient(180deg,#059669,rgba(139,119,80,.08))!important}
        html[data-theme$="-light"] .pstep.current:not(:last-child)::before{background:linear-gradient(180deg,#2563eb,rgba(139,119,80,.08))!important}
        /* 页脚 */
        html[data-theme$="-light"] .ftr{color:#7a7360!important}
        /* Toast */
        html[data-theme$="-light"] .ta-toast{background:linear-gradient(135deg,rgba(238,233,222,.97),rgba(243,239,228,.97))!important;border-color:rgba(37,99,235,.2)!important;color:#3d3929!important;box-shadow:0 8px 32px rgba(139,119,80,.15),0 0 20px rgba(37,99,235,.04)!important}
        /* recommend.css 类 */
        html[data-theme$="-light"] .recommend-container{color:#3d3929!important}
        html[data-theme$="-light"] .dashboard-section,.recommendations-section,.learning-path{background:linear-gradient(135deg,rgba(238,233,222,.88),rgba(243,239,228,.94))!important;border-color:rgba(37,99,235,.08)!important;box-shadow:0 4px 20px rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .glow-text{background:linear-gradient(120deg,#2563eb,#7c3aed)!important;-webkit-background-clip:text!important;background-clip:text!important;color:transparent!important;filter:none!important}
        html[data-theme$="-light"] .knowledge-radar{background:linear-gradient(135deg,rgba(37,99,235,.03),rgba(139,119,80,.02))!important;border-color:rgba(37,99,235,.08)!important}
        html[data-theme$="-light"] .legend-item{background:rgba(139,119,80,.05)!important;border-color:rgba(139,119,80,.1)!important;color:rgba(61,57,41,.8)!important}
        html[data-theme$="-light"] .stat-card{background:linear-gradient(135deg,rgba(37,99,235,.05),rgba(139,119,80,.03))!important;border-color:rgba(37,99,235,.12)!important}
        html[data-theme$="-light"] .stat-card:hover{border-color:rgba(37,99,235,.25)!important;box-shadow:0 6px 20px rgba(37,99,235,.06)!important}
        html[data-theme$="-light"] .stat-icon{background:linear-gradient(135deg,rgba(37,99,235,.15),rgba(139,119,80,.08))!important;border-color:rgba(37,99,235,.15)!important}
        html[data-theme$="-light"] .stat-value{background:linear-gradient(120deg,#2563eb,#7c3aed)!important;-webkit-background-clip:text!important;background-clip:text!important;color:transparent!important}
        html[data-theme$="-light"] .stat-label{color:rgba(61,57,41,.55)!important}
        html[data-theme$="-light"] .progress-bar{background:rgba(139,119,80,.06)!important;border-color:rgba(37,99,235,.06)!important}
        html[data-theme$="-light"] .progress-text{color:#2563eb!important}
        html[data-theme$="-light"] .filter-tab{background:rgba(139,119,80,.04)!important;border-color:rgba(37,99,235,.15)!important;color:rgba(61,57,41,.7)!important}
        html[data-theme$="-light"] .filter-tab:hover{background:rgba(37,99,235,.06)!important;border-color:rgba(37,99,235,.3)!important;color:#3d3929!important}
        html[data-theme$="-light"] .filter-tab.active{background:linear-gradient(135deg,rgba(37,99,235,.2),rgba(139,119,80,.1))!important;color:#fff!important;border-color:rgba(37,99,235,.3)!important;box-shadow:0 3px 12px rgba(37,99,235,.1)!important}
        html[data-theme$="-light"] .recommendation-card{background:linear-gradient(135deg,rgba(37,99,235,.04),rgba(139,119,80,.02))!important;border-color:rgba(37,99,235,.1)!important}
        html[data-theme$="-light"] .recommendation-card:hover{border-color:rgba(37,99,235,.3)!important;box-shadow:0 16px 40px rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] .rec-badge{background:rgba(139,119,80,.08)!important;border-color:rgba(139,119,80,.1)!important;color:#7a7360!important}
        html[data-theme$="-light"] .rec-content h3{color:#3d3929!important}
        html[data-theme$="-light"] .rec-category{color:#2563eb!important}
        html[data-theme$="-light"] .rec-description,.rec-meta{color:rgba(61,57,41,.5)!important}
        html[data-theme$="-light"] .rec-action{background:linear-gradient(135deg,rgba(37,99,235,.12),rgba(139,119,80,.06))!important;border-color:rgba(37,99,235,.2)!important;color:#2563eb!important}
        html[data-theme$="-light"] .rec-action:hover{background:linear-gradient(135deg,rgba(37,99,235,.22),rgba(139,119,80,.12))!important;border-color:rgba(37,99,235,.35)!important;color:#fff!important;box-shadow:0 6px 20px rgba(37,99,235,.1)!important}
        html[data-theme$="-light"] .path-step{background:linear-gradient(135deg,rgba(37,99,235,.03),rgba(139,119,80,.02))!important;border-color:rgba(37,99,235,.1)!important}
        html[data-theme$="-light"] .path-step:hover{border-color:rgba(37,99,235,.25)!important;box-shadow:0 6px 20px rgba(37,99,235,.05)!important}
        html[data-theme$="-light"] .path-step.completed{background:linear-gradient(135deg,rgba(16,185,129,.06),rgba(139,119,80,.03))!important;border-color:rgba(16,185,129,.2)!important}
        html[data-theme$="-light"] .path-step.current{background:linear-gradient(135deg,rgba(37,99,235,.08),rgba(139,119,80,.04))!important;border-color:rgba(37,99,235,.3)!important;box-shadow:0 0 20px rgba(37,99,235,.1)!important}
        html[data-theme$="-light"] .path-step.completed .step-number{background:linear-gradient(135deg,#059669,#10b981)!important;box-shadow:0 0 18px rgba(16,185,129,.2)!important}
        html[data-theme$="-light"] .path-step.current .step-number{background:linear-gradient(135deg,#2563eb,#7c3aed)!important;box-shadow:0 0 20px rgba(37,99,235,.25)!important}
        html[data-theme$="-light"] .path-step.upcoming .step-number{background:rgba(139,119,80,.06)!important;border-color:rgba(139,119,80,.15)!important;color:rgba(61,57,41,.4)!important}
        html[data-theme$="-light"] .step-number{background:linear-gradient(135deg,rgba(37,99,235,.3),rgba(139,119,80,.15))!important;border-color:rgba(37,99,235,.2)!important;color:#3d3929!important}
        html[data-theme$="-light"] .step-content h4{color:#3d3929!important}
        html[data-theme$="-light"] .step-content p{color:rgba(61,57,41,.45)!important}
        html[data-theme$="-light"] .step-progress{color:#2563eb!important}
        /* 通用 */
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3,html[data-theme$="-light"] h4{color:#3d3929!important}
        html[data-theme$="-light"] svg,html[data-theme$="-light"] [class*="icon"]{color:#5c5540!important;fill:#5c5540!important}
    </style>

</head>
<body>

<div class="bg-aurora"></div>
<div class="sf" id="sf"></div>

<div class="wrap">

    <!-- ═══════ Hero ═══════ -->
    <div class="hero">
        <h1>智 能 阅 读 中 心</h1>
        <p class="sub"><%= isPersonal ? "AI 分析你的阅读行为，助你发现知识宝藏" : "登录后开启个性化智能阅读体验" %></p>
        <div class="hero-deco"><span></span><span></span><span></span></div>
    </div>

    <!-- ═══════ 统计仪表盘 ═══════ -->
    <div class="sbar">
        <div class="sitem">
            <div class="sicon b">📚</div>
            <div><div class="sval" id="statBooks">–</div><div class="slabel">已读图书</div></div>
        </div>
        <div class="sitem">
            <div class="sicon h">⏱️</div>
            <div><div class="sval"><%= studyH %></div><div class="slabel">学习时长 (h)</div></div>
        </div>
        <div class="sitem">
            <div class="sicon p">📄</div>
            <div><div class="sval" id="statPages">–</div><div class="slabel">累计阅读页数</div></div>
        </div>
        <div class="sitem" id="streakItem">
            <div class="sicon s">🔥</div>
            <div><div class="sval" id="statStreak">–</div><div class="slabel">连续阅读 (天)</div></div>
        </div>
    </div>

    <!-- ═══════ 阅读日历热力图 ═══════ -->
    <div class="chart-card" id="calendarCard" style="display:none;">
        <div class="chart-card-hd">
            <h3>📅 近 4 周阅读日历</h3>
            <div class="streak-tag" id="streakBadge" style="display:none;">🔥 <span id="streakBadgeText">0</span> 天连续</div>
        </div>
        <div class="chart-sub">颜色越深代表当天阅读量越大</div>
        <div id="readingCalendar"></div>
        <div class="chart-legend-row">
            <span>少</span>
            <span class="chart-legend-box" style="background:#1a2740;"></span>
            <span class="chart-legend-box" style="background:#134e4a;"></span>
            <span class="chart-legend-box" style="background:#0e7490;"></span>
            <span class="chart-legend-box" style="background:#0c4a6e;"></span>
            <span class="chart-legend-box" style="background:#4facfe;"></span>
            <span>多</span>
        </div>
    </div>

    <div class="section-divider"><span>✦ 能 力 图 谱 ✦</span></div>

    <!-- ═══════ Dashboard ═══════ -->
    <div class="dash">
        <div class="dash-col">
            <div class="radar-box">
                <h3>🔭 知识能力雷达</h3>
                <div id="radarChart"></div>
            </div>
        </div>

        <div class="dash-col">
            <div class="stat-mini">
                <div class="sm-icon c">📚</div>
                <div class="sm-full"><div class="sm-val"><%= courses %></div><div class="sm-lbl">已修课程数</div></div>
            </div>
            <div class="stat-mini">
                <div class="sm-icon t">⏱️</div>
                <div class="sm-full"><div class="sm-val"><%= studyH %> h</div><div class="sm-lbl">学习时长</div></div>
            </div>
            <div class="stat-mini">
                <div class="sm-icon g">⭐</div>
                <div class="sm-full"><div class="sm-val"><%= points %></div><div class="sm-lbl">校园积分</div></div>
            </div>
            <div class="stat-mini">
                <div class="sm-icon w">📈</div>
                <div class="sm-full">
                    <div class="sm-lbl">周进度 <b><%= weekPct %>%</b></div>
                    <div class="progress-wrap"><div class="progress-fill" style="width:<%= weekPct %>%;"></div></div>
                </div>
            </div>
        </div>
    </div>

    <div class="section-divider"><span>✦ 智 能 推 荐 ✦</span></div>

    <!-- ═══════ AI 推荐 ═══════ -->
    <div class="sec">
        <h2>🤖 <%= isPersonal ? "AI 个性化推荐" : "热门推荐" %></h2>
        <div class="ftabs">
            <% String[][] fs = {{"all","全部"},{"books","📕 图书"},{"courses","📖 课程"},{"lectures","🎙️ 讲座"}};
            for (String[] f : fs) { %>
            <a href="<%= ctx %>/recommend<%= !"all".equals(f[0]) ? "?filterType="+f[0] : "" %>"
               class="ft <%= f[0].equals(filterType) ? "on" : "" %>"><%= f[1] %></a>
            <% } %>
        </div>

        <% if (items.isEmpty()) { %>
        <p style="text-align:center;color:var(--muted);padding:40px;">暂无推荐内容</p>
        <% } else { %>
        <div class="rgrid">
        <%
            int ii = 0;
            for (RecommendItem item : items) {
                String[] st = tStyle.get(item.getType());
                if (st == null) st = tStyle.get("courses");
                String grad = st[0], tType = st[1];
                String r = item.getRating() != null ? String.format("%.1f", item.getRating()) : "";
                String b = sf(item.getBadge());
                String reason = item.getMetaInfo();
                double ad = 0.04 * (ii % 10);
        %>
        <div class="rcd" style="--ad:<%= String.format("%.2f",ad) %>s;" onclick="goRec('<%= sf(item.getType()) %>','<%= sf(item.getRefId()) %>')">
        <%
                String coverImg = sf(item.getCoverImage());
        %>
        <div class="rcd-cover" style="background:<%= grad %>;opacity:.82;">
            <% if (!coverImg.isEmpty()) { %>
            <img src="<%= ctx + coverImg %>" alt=""
                 style="width:100%;height:100%;object-fit:cover;position:absolute;top:0;left:0;z-index:2;"
                 onerror="this.style.display='none';">
            <% } %>
            <span style="font-size:36px;position:relative;z-index:1;"><%= st[2] %></span>
            <% if (!b.isEmpty()) { %><span class="rcd-badge <%= b %>" style="z-index:5;"><%= b %></span><% } %>
        </div>
            <div class="rcd-body">
                <div class="rcd-title"><%= sf(item.getTitle()) %></div>
                <div class="rcd-cat"><%= sf(item.getCategory()) %> · <%= tType %></div>
                <div class="rcd-desc"><%= sf(item.getDescription()) %></div>
                <% if (reason != null && reason.contains("根据")) { %>
                <div class="rcd-reason">🤖 <%= reason %></div>
                <% } %>
                <div class="rcd-meta">
                    <span>🎓 <%= sf(item.getAuthor()) %></span>
                    <span>⏱️ <%= reason != null && !reason.contains("根据") ? reason : sf(item.getMetaInfo()) %></span>
                    <% if (!r.isEmpty()) { %><span class="rcd-rating">⭐ <%= r %></span><% } %>
                </div>
            </div>
        </div>
        <% ii++; } %>
        </div>
        <% } %>
    </div>

    <div class="section-divider"><span>✦ 学 习 路 径 ✦</span></div>

    <!-- ═══════ 学习路径 ═══════ -->
    <div class="sec">
        <h2>🛤️ 个性化学习路径</h2>
        <% if (steps.isEmpty()) { %>
        <p style="text-align:center;color:var(--muted);padding:30px;">完成更多学习后解锁个性化路径</p>
        <% } else { %>
        <div class="path">
            <% for (LearningStep step : steps) {
                String sc = "upcoming", sts = "规划中", pbar = "";
                if ("completed".equals(step.getStatus())) { sc = "completed"; sts = "✅ 已完成"; }
                else if ("current".equals(step.getStatus()) || "in_progress".equals(step.getStatus())) {
                    sc = "current"; sts = "⚡ 进行中 " + step.getProgressPercent() + "%";
                    pbar = "<div class=\"progress-wrap\" style=\"margin-top:8px;\"><div class=\"progress-fill\" style=\"width:"+step.getProgressPercent()+"%;\"></div></div>";
                }
            %>
            <div class="pstep <%= sc %>">
                <div class="pnum"><span><%= step.getStepNumber() %></span></div>
                <div class="pbody">
                    <h4><%= sf(step.getTitle()) %></h4>
                    <p><%= sf(step.getDescription()) %></p>
                    <div class="pstatus <%= sc %>"><%= sts %></div>
                    <%= pbar %>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>

    <div class="ftr">✦&nbsp;&nbsp;阅 读 中 心&nbsp;&nbsp;·&nbsp;&nbsp;B O Y A&nbsp;&nbsp;✦</div>
</div>

<script>
    var cp = '<%= ctx %>';
    var loggedIn = <%= isPersonal ? "true" : "false" %>;
    var _echartsRec = { radar: null, calendar: null };

    /** 在父框架右侧内容区加载页面，避免整体跳转 */
    function openInFrame(url) {
        try { var f = window.top.document.getElementById('academicFrame'); if (f) { f.src = url; return; } } catch(e) {}
        window.top.location.href = url;
    }

    // ========== ECharts 知识能力雷达图 ==========
    // 浅色主题辅助函数 · 暴力加深版
    var _cl = (function(){
        // ★ 多层判断，避免 iframe 环境下 data-theme 未传递
        var _theme = (document.documentElement.getAttribute('data-theme')||'');
        try { if (window.parent && window.parent.document) { var _pt = window.parent.document.documentElement.getAttribute('data-theme'); if (_pt) _theme = _pt; } } catch(e){}
        var t = _theme.indexOf('-light')>-1;
        // ★ fallback：data-theme 为空时，用背景色亮度判断
        if (!t && !_theme) { try { var _bg = getComputedStyle(document.body).backgroundColor; var _m = _bg.match(/(\d+),\s*(\d+),\s*(\d+)/); if (_m) { var _br = (parseInt(_m[1])*299+parseInt(_m[2])*587+parseInt(_m[3])*114)/1000; if (_br > 150) t = true; } } catch(e){} }
        return {
            tooltipBg: t?'rgba(255,255,255,.98)':'rgba(13,21,37,.96)',
            tooltipBorder: t?'rgba(37,99,235,.40)':'rgba(79,172,254,.35)',
            tooltipText: t?'#1a1815':'#e5e9f0',
            axisLabel: t?'#1a1815':'#94a3b8',
            axisLabel2: t?'#3d3929':'#64748b',
            axisLabel3: t?'#6a6358':'#7b8ba8',
            gridLine2: t?'rgba(26,24,20,.30)':'rgba(125,211,252,.12)',
            axisLine: t?'rgba(26,24,20,.22)':'rgba(255,255,255,.08)',
            axisLine2: t?'rgba(26,24,20,.38)':'rgba(255,255,255,.14)',
            radarBg: t?'rgba(37,99,235,.10)':'rgba(79,172,254,.035)',
            radarBg2: t?'rgba(37,99,235,.18)':'rgba(79,172,254,.07)',
            pieBorder: t?'#ffffff':'#0d1525',
            calendarBg: t?'#ede5d3':'#1a2740',
            calendarBorder: t?'rgba(139,119,80,.18)':'rgba(255,255,255,.06)',
            dark: t,
            radarAxisBg: t?'rgba(255,255,255,.96)':'rgba(13,21,37,.65)'
        };
    })();
    (function(){
        var skillsData = <%= skillsJson.toString() %>;
        var chartDom = document.getElementById('radarChart');

        // ECharts 未加载
        if (typeof echarts === 'undefined') {
            chartDom.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;' +
                'height:240px;color:#7b8ba8;font-size:13px;">ECharts 加载中，请刷新重试</div>';
            return;
        }

        // 空态处理：区分登录状态
        if (skillsData.length === 0) {
            var msg = loggedIn
                ? '🪐&nbsp;&nbsp;完成更多学习后解锁个人知识雷达'
                : '🔐&nbsp;&nbsp;登录后解锁个人知识雷达';
            chartDom.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;' +
                'height:240px;color:#7b8ba8;font-size:13px;letter-spacing:1px;">' + msg + '</div>';
            return;
        }

        try {
            var indicators = [];
            var userValues = [];
            var avgValues = [];
            for (var i = 0; i < skillsData.length; i++) {
                var name = skillsData[i].name;
                if (name.length > 4) name = name.substring(0,2) + '\n' + name.substring(2);
                indicators.push({ name: name, max: 100 });
                userValues.push(skillsData[i].value);
                avgValues.push(Math.round(skillsData[i].value * 0.85));
            }

            var chart = echarts.init(chartDom, null, {
                devicePixelRatio: window.devicePixelRatio || 1,
                renderer: 'canvas'
            });

            _echartsRec.radar = chart;
            // ★ 浅色/深色用不同的雷达图主色
            var isLt = _cl.dark;
            var radarPrimary = isLt ? '#1d4ed8' : '#4facfe';
            var radarSecond  = isLt ? '#7c3aed' : '#a78bfa';
            var radarAreaFill = isLt ? 'rgba(29,78,216,.28)' : 'rgba(79,172,254,.18)';
            var radarSecondArea= isLt ? 'rgba(124,58,237,.12)' : 'rgba(167,139,250,.06)';

            chart.setOption({
                animationDuration: 1200,
                animationEasing: 'cubicOut',
                color: [radarPrimary, radarSecond],
                tooltip: {
                    trigger: 'item',
                    backgroundColor: _cl.tooltipBg,
                    borderColor: _cl.tooltipBorder,
                    borderWidth: 1,
                    padding: [12, 16],
                    textStyle: { color: _cl.tooltipText, fontSize: 13 },
                    formatter: function(p) {
                        if (!p || !p.name) return '';
                        var dimName = p.name.replace(/\n/g, '');
                        var html = '<div style="font-weight:700;margin-bottom:6px;color:#7dd3fc;">' + dimName + '</div>';
                        for (var j = 0; j < p.value.length; j++) {
                            var label = ['我的能力', '平台均值'][j];
                            var color = ['#4facfe', '#a78bfa'][j];
                            html += '<div style="display:flex;justify-content:space-between;gap:24px;">' +
                                '<span style="color:#7b8ba8;">' + label + '</span>' +
                                '<span style="color:' + color + ';font-weight:600;">' + p.value[j] + ' 分</span>' +
                                '</div>';
                        }
                        return html;
                    }
                },
                legend: {
                    bottom: 2,
                    itemWidth: 10, itemHeight: 10, itemGap: 28,
                    textStyle: { color: _cl.axisLabel3, fontSize: 11 },
                    data: ['我的能力', '平台均值']
                },
                radar: {
                    center: ['50%', '47%'], radius: '62%',
                    indicator: indicators,
                    axisName: {
                        color: _cl.axisLabel3, fontSize: 10, lineHeight: 14,
                        borderRadius: 3, padding: [2, 5],
                        backgroundColor: _cl.radarAxisBg
                    },
                    shape: 'polygon', splitNumber: 4,
                    splitArea: {
                        areaStyle: { color: [_cl.radarBg,_cl.radarBg2,_cl.radarBg,_cl.radarBg2] }
                    },
                    splitLine: { lineStyle: { color: _cl.axisLine, width: 1 } },
                    axisLine: { lineStyle: { color: _cl.axisLine2, width: 1 } }
                },
                series: [
                    {
                        name: '我的能力', type: 'radar',
                        symbol: 'circle', symbolSize: 6,
                        lineStyle: { color: radarPrimary, width: 2.5, shadowBlur: 10, shadowColor: radarPrimary + '60' },
                        areaStyle: { color: radarAreaFill },
                        itemStyle: { color: radarPrimary, borderColor: _cl.dark?'#e5e9f0':'#ffffff', borderWidth: 1.5 },
                        data: [{ value: userValues, name: '我的能力' }],
                        emphasis: {
                            lineStyle: { width: 3.5, shadowBlur: 18, shadowColor: radarPrimary + '80' },
                            areaStyle: { color: isLt ? 'rgba(29,78,216,.45)' : 'rgba(79,172,254,.30)' },
                            itemStyle: { borderWidth: 2.5 }, symbolSize: 10
                        }
                    },
                    {
                        name: '平台均值', type: 'radar',
                        symbol: 'diamond', symbolSize: 5,
                        lineStyle: { color: radarSecond, width: 1.8, type: 'dashed', shadowBlur: 6, shadowColor: radarSecond + '50' },
                        areaStyle: { color: radarSecondArea },
                        itemStyle: { color: radarSecond },
                        data: [{ value: avgValues, name: '平台均值' }],
                        emphasis: {
                            lineStyle: { width: 2.5, shadowBlur: 14, shadowColor: radarSecond + '70' },
                            areaStyle: { color: isLt ? 'rgba(124,58,237,.22)' : 'rgba(167,139,250,.15)' },
                            itemStyle: { borderColor: _cl.dark?'#e5e9f0':'#ffffff', borderWidth: 1 }, symbolSize: 9
                        }
                    }
                ]
            });

            window.addEventListener('resize', function(){ chart.resize(); });
        } catch(e) {
            chartDom.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;' +
                'height:240px;color:#7b8ba8;font-size:13px;">雷达图渲染失败，请稍后重试</div>';
        }
    })();

    function goRec(type, refId) {
        if (type === 'books' || type === 'book') {
            if (refId) openInFrame(cp + '/bookDetail?bookId=' + refId);
            else openInFrame(cp + '/recommend?filterType=books');
        } else if (type === 'courses' || type === 'course') {
            toast('📚 课程详情即将上线');
        } else if (type === 'lectures' || type === 'lecture') {
            location.href = cp + '/lecturePage';
        }
    }

    // ── 阅读统计 AJAX ──
    if (loggedIn) {
        // 已读图书（来自 user_activity 真实记录）
        fetch(cp + '/api/bookAction?action=recentReads')
            .then(function(r){return r.json()})
            .then(function(d){
                var cnt = (d.books || []).length;
                document.getElementById('statBooks').textContent = cnt + ' 本';
            }).catch(function(){document.getElementById('statBooks').textContent='–';});

            // 连续阅读 & 日历热力图数据
        fetch(cp + '/api/bookAction?action=readingStreak')
            .then(function(r){return r.json()})
            .then(function(d){
                var sd = d.streakDays || 0;
                // 连续阅读天数
                document.getElementById('statStreak').textContent = sd + ' 天';
                // 高亮 streak 卡片
                var si = document.getElementById('streakItem');
                if (sd >= 3) { si.classList.add('streak-active'); }
                else { si.classList.remove('streak-active'); }
                // 累计阅读页数
                var pages = d.totalPages || 0;
                document.getElementById('statPages').textContent = pages + ' 页';
                // 渲染日历 & streak徽章
                var hasData = d.dailyReads && d.dailyReads.length > 0;
                if (hasData) {
                    renderReadingCalendar(d.dailyReads, sd);
                } else {
                    showEmptyCalendar();
                }
            }).catch(function(){
                document.getElementById('statStreak').textContent='0 天';
                document.getElementById('statPages').textContent='–';
                showEmptyCalendar();
            });
    } else {
        document.getElementById('statBooks').textContent = '登录后查看';
        document.getElementById('statPages').textContent = '登录后查看';
        document.getElementById('statStreak').textContent = '登录后查看';
    }

    // ========== 阅读日历热力图（ECharts Calendar） ==========
    function renderReadingCalendar(dailyReads, streakDays) {
        var calCard = document.getElementById('calendarCard');
        var calDom = document.getElementById('readingCalendar');
        if (!calCard || !calDom) return;
        calCard.style.display = 'block';
        // streak 徽章
        var badge = document.getElementById('streakBadge');
        var badgeText = document.getElementById('streakBadgeText');
        if (badge && badgeText && (streakDays || 0) > 0) {
            badge.style.display = 'inline-flex';
            badgeText.textContent = streakDays;
        }

        if (typeof echarts === 'undefined') {
            calDom.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;' +
                'height:120px;color:#7b8ba8;font-size:12px;">图表组件加载中...</div>';
            return;
        }

        try {
            var chart = echarts.init(calDom, null, { devicePixelRatio: window.devicePixelRatio || 1, renderer: 'canvas' });

            // 构建 [dateString, count] 数据
            var data = [];
            for (var i = 0; i < dailyReads.length; i++) {
                data.push([dailyReads[i].date, dailyReads[i].count]);
            }

            // 计算范围：今天往前 28 天
            var endDate = new Date();
            var startDate = new Date();
            startDate.setDate(startDate.getDate() - 27);

            _echartsRec.calendar = chart;
            chart.setOption({
                tooltip: {
                    backgroundColor: _cl.tooltipBg,
                    borderColor: _cl.tooltipBorder,
                    borderWidth: 1,
                    padding: [10, 14],
                    textStyle: { color: _cl.tooltipText, fontSize: 12 },
                    formatter: function(p) {
                        return '<div style="font-weight:600;margin-bottom:2px;">' + p.value[0] + '</div>' +
                            '<span style="color:' + (_cl.dark?'#7dd3fc':'#2563eb') + ';font-weight:700;">📖 ' + p.value[1] + ' 次阅读</span>';
                    }
                },
                visualMap: {
                    min: 0,
                    max: Math.max.apply(null, dailyReads.map(function(d){return d.count;})) || 5,
                    type: 'piecewise',
                    orient: 'horizontal',
                    left: 'center',
                    bottom: 2,
                    itemWidth: 14,
                    itemHeight: 14,
                    itemGap: 4,
                    textStyle: { color: _cl.axisLabel3, fontSize: 10 },
                    pieces: [
                        { min: 1, max: 1, color: _cl.dark?'#134e4a':'#dbeafe', label: '1次' },
                        { min: 2, max: 2, color: _cl.dark?'#0e7490':'#bfdbfe', label: '2次' },
                        { min: 3, max: 4, color: _cl.dark?'#0c4a6e':'#93c5fd', label: '3-4次' },
                        { min: 5, color: '#4facfe', label: '5+' }
                    ],
                    show: false
                },
                calendar: {
                    top: 5,
                    bottom: 40,
                    left: 10,
                    right: 10,
                    range: [startDate, endDate],
                    cellSize: ['auto', 18],
                    splitLine: { lineStyle: { color: _cl.calendarBorder, width: 3 } },
                    itemStyle: {
                        borderWidth: 2,
                        borderColor: _cl.calendarBorder,
                        borderRadius: 3,
                        color: _cl.calendarBg
                    },
                    dayLabel: {
                        color: _cl.axisLabel3, fontSize: 9,
                        firstDay: 1,
                        nameMap: ['日','一','二','三','四','五','六']
                    },
                    monthLabel: {
                        color: _cl.axisLabel3, fontSize: 9,
                        nameMap: 'cn'
                    },
                    yearLabel: { show: false }
                },
                series: [{
                    type: 'heatmap',
                    coordinateSystem: 'calendar',
                    data: data,
                    emphasis: {
                        itemStyle: {
                            shadowBlur: 8,
                            shadowColor: 'rgba(79,172,254,.5)',
                            borderColor: '#7dd3fc',
                            borderWidth: 1
                        }
                    }
                }]
            });

            window.addEventListener('resize', function(){ if (chart && !chart.isDisposed()) chart.resize(); });
        } catch(e) {
            calDom.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;' +
                'height:120px;color:#7b8ba8;font-size:12px;">图表渲染失败</div>';
        }
    }

    // ========== 阅读日历空状态 ==========
    function showEmptyCalendar() {
        var calCard = document.getElementById('calendarCard');
        var calDom = document.getElementById('readingCalendar');
        if (!calCard || !calDom) return;
        calCard.style.display = 'block';
        calDom.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;' +
            'height:120px;color:#7b8ba8;font-size:13px;letter-spacing:1px;flex-direction:column;gap:8px;">' +
            '<span style="font-size:28px;">📖</span>' +
            '<span>近 4 周暂无阅读记录</span>' +
            '<span style="font-size:11px;color:rgba(123,139,168,.5);">开始阅读图书，解锁你的阅读日历</span>' +
            '</div>';
    }

    function toast(msg) {
        var t = document.createElement('div');
        t.className = 'ta-toast';
        t.textContent = msg;
        document.body.appendChild(t);
        requestAnimationFrame(function(){ t.classList.add('show'); });
        setTimeout(function(){ t.classList.remove('show'); setTimeout(function(){ t.remove(); }, 350); }, 2400);
    }

    // 星空 + 光晕
    (function(){
        var f = document.getElementById('sf'), frag = document.createDocumentFragment();
        var sizes = ['s','s','s','m','m','l']; // 60%小 30%中 10%大
        for(var i=0;i<80;i++){
            var d=document.createElement('div');
            d.className = 'sd ' + sizes[Math.floor(Math.random() * sizes.length)];
            d.style.left=Math.random()*100+'%'; d.style.top=Math.random()*100+'%';
            d.style.animationDuration=(2.5+Math.random()*4)+'s';
            d.style.animationDelay=Math.random()*5+'s';
            frag.appendChild(d);
        }
        f.appendChild(frag);
    })();
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);setTimeout(function(){if(_echartsRec.radar&&!_echartsRec.radar.isDisposed()){_echartsRec.radar.dispose();_echartsRec.radar=null;}if(_echartsRec.calendar&&!_echartsRec.calendar.isDisposed()){_echartsRec.calendar.dispose();_echartsRec.calendar=null;}location.reload();},200);}});})();
</script>
</body>
</html>
