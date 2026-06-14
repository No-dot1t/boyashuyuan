<%--=============================================================================virtualLab.jsp=============================================================================用途
    功能页面 ── 使用的关键 API / 技术 ──────────────────────────────────────────────────── DOM 事件处理 DOM 选择器 —— querySelector /
    getElementById JSON 解析 本地存储=============================================================================--%>
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
        <%@ page import="java.util.ArrayList, java.util.Map" %>
            <% ArrayList<Map<String, Object>> experiments = (ArrayList<Map<String, Object>>)
                    request.getAttribute("experiments");
                    if (experiments == null) experiments = new ArrayList<>();
                        Map<String, Object> experiment = (Map<String, Object>) request.getAttribute("experiment");
                                Boolean isDetail = (Boolean) request.getAttribute("isDetail");
                                Boolean isLabMode = (Boolean) request.getAttribute("isLabMode");
                                String currentCategory = (String) request.getAttribute("currentCategory");
                                Map<String, Integer> categoryCount = (Map<String, Integer>)
                                        request.getAttribute("categoryCount");
                                        if (categoryCount == null) categoryCount = new java.util.HashMap<>();
                                            String ctx = request.getContextPath();

                                            String catLabel(String c) {
                                            if (c == null) return "全部";
                                            switch (c) {
                                            case "physics": return "物理"; case "chemistry": return "化学";
                                            case "biology": return "生物"; case "cs": return "计算机";
                                            default: return "其他";
                                            }
                                            }
                                            String diffLabel(String d) {
                                            if (d == null) return "中等";
                                            switch (d) {
                                            case "easy": return "初级"; case "medium": return "中等"; case "hard": return
                                            "高级";
                                            default: return "中等";
                                            }
                                            }
                                            String diffColor(String d) {
                                            if ("easy".equals(d)) return "#10b981";
                                            if ("hard".equals(d)) return "#ef4444";
                                            return "#f59e0b";
                                            }
                                            %>
                                            <!DOCTYPE html>
                                            <html lang="zh-CN">

                                            <head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

                                                <meta charset="UTF-8">
                                                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                                <title>博雅书院 | 虚拟实验室</title>
                                                <link rel="stylesheet" href="<%= ctx %>/CSS/index.css">
                                                <script
                                                    src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
                                                <style>
                                                    * {
                                                        margin: 0;
                                                        padding: 0;
                                                        box-sizing: border-box
                                                    }

                                                    body {
                                                        background: var(--bg-space, #0a0b1a);
                                                        color: #fff;
                                                        font-family: 'Segoe UI', 'PingFang SC', sans-serif;
                                                        min-height: 100vh
                                                    }

                                                    @keyframes fadeInUp {
                                                        from {
                                                            opacity: 0;
                                                            transform: translateY(30px)
                                                        }

                                                        to {
                                                            opacity: 1;
                                                            transform: translateY(0)
                                                        }
                                                    }

                                                    @keyframes shimmer {
                                                        0% {
                                                            background-position: -200% 0
                                                        }

                                                        100% {
                                                            background-position: 200% 0
                                                        }
                                                    }

                                                    @keyframes glowPulse {

                                                        0%,
                                                        100% {
                                                            box-shadow: 0 0 15px rgba(0, 242, 255, 0.08)
                                                        }

                                                        50% {
                                                            box-shadow: 0 0 30px rgba(0, 242, 255, 0.2)
                                                        }
                                                    }

                                                    @keyframes slideIn {
                                                        from {
                                                            opacity: 0;
                                                            transform: translateX(-20px)
                                                        }

                                                        to {
                                                            opacity: 1;
                                                            transform: translateX(0)
                                                        }
                                                    }

                                                    @keyframes pulse {

                                                        0%,
                                                        100% {
                                                            opacity: 1
                                                        }

                                                        50% {
                                                            opacity: 0.5
                                                        }
                                                    }

                                                    .lab-container {
                                                        max-width: 1200px;
                                                        margin: 0 auto;
                                                        padding: 30px 20px
                                                    }

                                                    .lab-header {
                                                        text-align: center;
                                                        margin-bottom: 30px;
                                                        animation: fadeInUp .6s ease-out
                                                    }

                                                    .lab-header h1 {
                                                        font-size: 2.2rem;
                                                        margin-bottom: 10px;
                                                        background: linear-gradient(135deg, #fff 0%, var(--glow-primary, #00f2ff) 50%, #fff 100%);
                                                        background-size: 200% auto;
                                                        -webkit-background-clip: text;
                                                        -webkit-text-fill-color: transparent;
                                                        background-clip: text;
                                                        animation: shimmer 3s linear infinite
                                                    }

                                                    .lab-header p {
                                                        color: rgba(255, 255, 255, 0.5);
                                                        font-size: 1rem
                                                    }

                                                    .back-btn {
                                                        display: inline-flex;
                                                        align-items: center;
                                                        gap: 8px;
                                                        padding: 10px 24px;
                                                        background: rgba(255, 255, 255, 0.06);
                                                        border: 1px solid rgba(255, 255, 255, 0.1);
                                                        border-radius: 10px;
                                                        color: rgba(255, 255, 255, 0.7);
                                                        text-decoration: none;
                                                        cursor: pointer;
                                                        transition: all .3s;
                                                        margin-bottom: 20px;
                                                        font-size: .92rem
                                                    }

                                                    .back-btn:hover {
                                                        background: rgba(0, 242, 255, 0.12);
                                                        border-color: rgba(0, 242, 255, 0.3);
                                                        color: #fff;
                                                        transform: translateX(-4px)
                                                    }

                                                    .filter-bar {
                                                        display: flex;
                                                        gap: 10px;
                                                        justify-content: center;
                                                        margin-bottom: 30px;
                                                        flex-wrap: wrap;
                                                        animation: fadeInUp .6s ease-out .1s both
                                                    }

                                                    .filter-btn {
                                                        padding: 9px 22px;
                                                        background: rgba(255, 255, 255, 0.03);
                                                        border: 1px solid rgba(255,255,255,0.07);border-radius:12px;color:rgba(255,255,255,0.6);cursor:pointer;font-size:.88rem;transition:all .4s cubic-bezier(.175,.885,.32,1.275)}
        .filter-btn.active,.filter-btn:hover{background:rgba(0,242,255,0.12);border-color:rgba(0,242,255,0.3);color:#fff;transform:translateY(-2px);box-shadow:0 4px 15px rgba(0,0,0,0.15)}
        .exp-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(340px,1fr));gap:20px;animation:fadeInUp .7s ease-out .2s both}
        .exp-card{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:18px;padding:25px;transition:all .4s cubic-bezier(.175,.885,.32,1.275);cursor:pointer;position:relative;overflow:hidden}
        .exp-card::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,transparent,var(--glow-primary,#00f2ff),transparent);opacity:0;transition:opacity .4s}
        .exp-card::after{content:'';position:absolute;inset:0;background:radial-gradient(circle at 50% 0%,rgba(0,242,255,0.06),transparent 70%);opacity:0;transition:opacity .4s;pointer-events:none}
        .exp-card:hover{transform:translateY(-6px);border-color:rgba(0,242,255,0.25);box-shadow:0 12px 35px rgba(0,0,0,0.3),0 0 40px rgba(0,242,255,0.06)}
        .exp-card:hover::before,.exp-card:hover::after{opacity:1}
        .exp-card .exp-head{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:12px;position:relative;z-index:1}
        .exp-card .exp-cat{font-size:.72rem;padding:3px 10px;border-radius:8px;background:rgba(0,242,255,0.1);color:var(--glow-primary,#00f2ff);border:1px solid rgba(0,242,255,0.15)}
        .exp-card .exp-diff{font-size:.72rem;padding:3px 10px;border-radius:8px}
        .exp-card h3{font-size:1.12rem;margin-bottom:8px;position:relative;z-index:1}
        .exp-card p{font-size:.88rem;color:rgba(255,255,255,0.5);line-height:1.6;margin-bottom:15px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;position:relative;z-index:1}
        .exp-card .exp-meta{display:flex;gap:15px;font-size:.78rem;color:rgba(255,255,255,0.35);position:relative;z-index:1}
        .exp-card .exp-meta span{display:flex;align-items:center;gap:4px}

        /* 详情页 */
        .detail-container{max-width:900px}
        .detail-card{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.08);border-radius:20px;padding:35px;position:relative;overflow:hidden;animation:fadeInUp .5s ease-out}
        .detail-card::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;background:linear-gradient(90deg,var(--glow-primary,#00f2ff),#a855f7,var(--glow-primary,#00f2ff))}
        .detail-card h2{font-size:1.6rem;margin-bottom:8px}
        .detail-badges{display:flex;gap:8px;margin-bottom:20px}
        .detail-badge{padding:4px 12px;border-radius:8px;font-size:.8rem}
        .detail-section{margin-bottom:25px}
        .detail-section h4{font-size:1.05rem;margin-bottom:10px;padding-bottom:8px;border-bottom:1px solid rgba(255,255,255,0.05);display:flex;align-items:center;gap:8px}
        .detail-section p{color:rgba(255,255,255,0.6);line-height:1.8;white-space:pre-line}
        .safety-box{background:rgba(239,68,68,0.06);border:1px solid rgba(239,68,68,0.2);border-radius:12px;padding:18px}
        .safety-box h4{color:#ef4444;display:flex;align-items:center;gap:8px}
        .safety-box p{color:rgba(255,255,255,0.6)}
        .start-lab-btn{width:100%;padding:16px;background:linear-gradient(135deg,#00d4e0,#00a8b5);border:none;border-radius:14px;color:#fff;font-size:1.05rem;font-weight:600;cursor:pointer;transition:all .3s;margin-top:20px;position:relative;overflow:hidden}
        .start-lab-btn:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(0,212,224,0.35)}
        .start-lab-btn:active{transform:translateY(0)}

        /* 实验模式 */
        .lab-mode-container{display:flex;height:calc(100vh - 80px);gap:20px;margin-top:20px}
        .lab-sidebar{width:320px;background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.06);border-radius:16px;padding:20px;overflow-y:auto}
        .lab-content{flex:1;background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.06);border-radius:16px;padding:25px;overflow-y:auto;position:relative}
        .step-list{margin-top:15px}
        .step-item{display:flex;align-items:center;gap:12px;padding:12px 15px;margin-bottom:8px;border-radius:10px;cursor:pointer;transition:all .3s;background:rgba(255,255,255,0.02)}
        .step-item:hover{background:rgba(255,255,255,0.06)}
        .step-item.active{background:rgba(0,242,255,0.1);border-left:3px solid var(--glow-primary,#00f2ff)}
        .step-item.completed{background:rgba(16,185,129,0.1)}
        .step-item.completed .step-num{background:#10b981;color:#fff}
        .step-item.active .step-num{background:var(--glow-primary,#00f2ff);color:#0a0b1a;animation:pulse 1.5s infinite}
        .step-num{width:28px;height:28px;border-radius:50%;background:rgba(255,255,255,0.1);display:flex;align-items:center;justify-content:center;font-size:.85rem;font-weight:600;color:rgba(255,255,255,0.6);flex-shrink:0}
        .step-content{flex:1;min-width:0}
        .step-content h5{font-size:.9rem;margin-bottom:2px;color:#fff}
        .step-content p{font-size:.78rem;color:rgba(255,255,255,0.45);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
        .lab-progress{margin-bottom:20px}
        .progress-bar{height:6px;background:rgba(255,255,255,0.08);border-radius:3px;overflow:hidden}
        .progress-fill{height:100%;background:linear-gradient(90deg,var(--glow-primary,#00f2ff),#a855f7);border-radius:3px;transition:width .5s ease-out}
        .progress-text{display:flex;justify-content:space-between;margin-top:8px;font-size:.85rem;color:rgba(255,255,255,0.5)}
        .lab-nav{display:flex;gap:12px;position:sticky;bottom:25px;margin-top:30px;padding-top:20px;border-top:1px solid rgba(255,255,255,0.05)}
        .nav-btn{flex:1;padding:14px;border-radius:12px;border:none;font-size:.95rem;cursor:pointer;transition:all .3s}
        .nav-btn:disabled{opacity:0.4;cursor:not-allowed}
        .nav-btn.prev{background:rgba(255,255,255,0.06);color:rgba(255,255,255,0.7)}
        .nav-btn.prev:hover:not(:disabled){background:rgba(255,255,255,0.1)}
        .nav-btn.next{background:linear-gradient(135deg,var(--glow-primary,#00f2ff),#00a8b5);color:#0a0b1a;font-weight:600}
        .nav-btn.next:hover:not(:disabled){transform:translateY(-2px);box-shadow:0 6px 20px rgba(0,242,255,0.3)}
        .nav-btn.finish{background:linear-gradient(135deg,#10b981,#059669)}
        .step-area{animation:slideIn .4s ease-out}
        .step-area h3{font-size:1.3rem;margin-bottom:20px;color:#fff}
        .step-area .step-description{background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.06);border-radius:14px;padding:20px;margin-bottom:25px;line-height:1.8;color:rgba(255,255,255,0.7)}
        .observation-box{background:rgba(255,255,255,0.03);border:1px dashed rgba(255,255,255,0.1);border-radius:12px;padding:20px;margin-bottom:20px}
        .observation-box textarea{width:100%;height:100px;background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.08);border-radius:8px;padding:12px;color:#fff;font-family:inherit;font-size:.9rem;resize:vertical;transition:all .3s}
        .observation-box textarea:focus{outline:none;border-color:var(--glow-primary,#00f2ff)}
        .observation-box label{display:block;margin-bottom:8px;font-size:.88rem;color:rgba(255,255,255,0.6)}
        .checklist{list-style:none;padding:0}
        .checklist li{display:flex;align-items:center;gap:10px;padding:12px 15px;background:rgba(255,255,255,0.03);border-radius:10px;margin-bottom:8px;cursor:pointer;transition:all .3s}
        .checklist li:hover{background:rgba(255,255,255,0.06)}
        .checklist li.checked{background:rgba(16,185,129,0.1)}
        .checklist li .check-icon{width:22px;height:22px;border:2px solid rgba(255,255,255,0.2);border-radius:6px;display:flex;align-items:center;justify-content:center;transition:all .3s}
        .checklist li.checked .check-icon{background:#10b981;border-color:#10b981}
        .checklist li .check-icon::after{content:'✓';color:#fff;font-size:.75rem}
        .checklist li span{font-size:.9rem;color:rgba(255,255,255,0.8)}
        .data-table{width:100%;border-collapse:collapse;margin-top:15px}
        .data-table th,.data-table td{padding:12px;text-align:left;border-bottom:1px solid rgba(255,255,255,0.05)}
        .data-table th{background:rgba(0,242,255,0.05);color:rgba(255,255,255,0.8);font-weight:600;font-size:.9rem}
        .data-table td{color:rgba(255,255,255,0.6)}
        .data-input{width:100px;padding:8px;background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.08);border-radius:6px;color:#fff;text-align:center;font-size:.85rem}
        .data-input:focus{outline:none;border-color:var(--glow-primary,#00f2ff)}
        .simulation-panel{background:linear-gradient(135deg,rgba(0,242,255,0.05),rgba(168,85,247,0.05));border:1px solid rgba(0,242,255,0.1);border-radius:16px;padding:20px;margin-bottom:20px}
        .sim-btn{padding:10px 20px;border:none;border-radius:10px;background:rgba(255,255,255,0.06);color:rgba(255,255,255,0.8);cursor:pointer;transition:all .3s;font-size:.9rem;margin-right:10px;margin-bottom:10px}
        .sim-btn:hover{background:rgba(0,242,255,0.15);color:#fff}
        .sim-btn.primary{background:linear-gradient(135deg,var(--glow-primary,#00f2ff),#00a8b5);color:#0a0b1a;font-weight:600}
        .sim-result{background:rgba(255,255,255,0.04);border-radius:10px;padding:15px;margin-top:15px;color:rgba(255,255,255,0.7)}
        .lab-report{display:none}
        .lab-report.active{display:block}
        .report-section{background:rgba(255,255,255,0.03);border-radius:14px;padding:20px;margin-bottom:20px}
        .report-section h4{font-size:1.1rem;margin-bottom:15px;color:#fff}
        .report-table{width:100%;border-collapse:collapse}
        .report-table th,.report-table td{padding:10px;border:1px solid rgba(255,255,255,0.05)}
        .report-table th{background:rgba(0,242,255,0.05)}
        .report-chart{height:300px;margin-top:20px}
        .success-badge{display:inline-flex;align-items:center;gap:8px;padding:8px 16px;background:rgba(16,185,129,0.1);border:1px solid rgba(16,185,129,0.3);border-radius:20px;color:#10b981;font-size:.9rem;margin-bottom:20px}

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
    <div class="lab-container">
        <a class="back-btn" href="<%= ctx %>/campus3d">← 返回元宇宙校园</a>

        <% if (Boolean.TRUE.equals(isLabMode) && experiment != null) { %>
        <!-- 实验模式 -->
        <div class="lab-mode-container">
            <div class="lab-sidebar">
                <h3 style="margin-bottom:15px;color:#fff;font-size:1.1rem">📝 实验步骤</h3>
                <div class="lab-progress">
                    <div class="progress-bar"><div class="progress-fill" id="progressFill"></div></div>
                    <div class="progress-text"><span id="progressText">0/0</span><span id="progressPercent">0%</span></div>
                </div>
                <div class="step-list" id="stepList"></div>
            </div>
            <div class="lab-content">
                <div id="labContent"></div>
                <div class="lab-nav">
                    <button class="nav-btn prev" id="prevBtn" onclick="prevStep()" disabled>← 上一步</button>
                    <button class="nav-btn next" id="nextBtn" onclick="nextStep()">下一步 →</button>
                </div>
            </div>
        </div>
        <% } else if (Boolean.TRUE.equals(isDetail) && experiment != null) { %>
        <!-- 详情页 -->
        <div class="detail-container">
            <div class="detail-card">
                <h2><%= experiment.get("name") %></h2>
                <div class="detail-badges">
                    <span class="detail-badge" style="background:rgba(0,242,255,0.1);color:var(--glow-primary,#00f2ff)"><%= catLabel((String)experiment.get("category")) %></span>
                    <span class="detail-badge" style="background:<%= diffColor((String)experiment.get("difficulty")) %>22;color:<%= diffColor((String)experiment.get("difficulty")) %>"><%= diffLabel((String)experiment.get("difficulty")) %></span>
                    <span class="detail-badge" style="background:rgba(255,255,255,0.08);color:rgba(255,255,255,0.6)">⏱️ <%= experiment.get("durationMin") %>分钟</span>
                </div>

                <div class="detail-section">
                    <h4>📋 实验描述</h4>
                    <p><%= experiment.get("description") %></p>
                </div>

                <div class="detail-section">
                    <h4>🔧 实验器材</h4>
                    <p><%= experiment.get("equipment") %></p>
                </div>

                <div class="detail-section">
                    <h4>📝 实验步骤</h4>
                    <div id="stepsPreview"></div>
                </div>

                <div class="safety-box">
                    <h4>⚠️ 安全须知</h4>
                    <p><%= experiment.get("safetyNotes") %></p>
                </div>

                <button class="start-lab-btn" onclick="startLab(<%= experiment.get("id") %>)">🔬 开始虚拟实验</button>
            </div>
        </div>
        <% } else { %>
        <!-- 列表页 -->
        <div class="lab-header">
            <h1><span class="glow-text">🔬</span> 虚拟实验室</h1>
            <p>安全、可重复的虚拟实验操作环境</p>
        </div>

        <div class="filter-bar">
            <a class="filter-btn <%= "all".equals(currentCategory) ? "active" : "" %>" href="<%= ctx %>/virtualLab?category=all">全部</a>
            <a class="filter-btn <%= "physics".equals(currentCategory) ? "active" : "" %>" href="<%= ctx %>/virtualLab?category=physics">物理</a>
            <a class="filter-btn <%= "chemistry".equals(currentCategory) ? "active" : "" %>" href="<%= ctx %>/virtualLab?category=chemistry">化学</a>
            <a class="filter-btn <%= "biology".equals(currentCategory) ? "active" : "" %>" href="<%= ctx %>/virtualLab?category=biology">生物</a>
            <a class="filter-btn <%= "cs".equals(currentCategory) ? "active" : "" %>" href="<%= ctx %>/virtualLab?category=cs">计算机</a>
        </div>

        <div class="exp-grid">
            <% if (experiments.isEmpty()) { %>
            <p style="color:rgba(255,255,255,0.5);text-align:center;grid-column:1/-1;">暂无实验数据</p>
            <% } else { %>
            <% for (Map<String, Object> exp : experiments) { %>
            <div class="exp-card" onclick="location.href='<%= ctx %>/virtualLab?id=<%= exp.get("id") %>'">
                <div class="exp-head">
                    <span class="exp-cat"><%= catLabel((String)exp.get("category")) %></span>
                    <span class="exp-diff" style="background:<%= diffColor((String)exp.get("difficulty")) %>22;color:<%= diffColor((String)exp.get("difficulty")) %>"><%= diffLabel((String)exp.get("difficulty")) %></span>
                </div>
                <h3><%= exp.get("name") %></h3>
                <p><%= exp.get("description") %></p>
                <div class="exp-meta">
                    <span>⏱️ <%= exp.get("durationMin") %>分钟</span>
                    <span>📊 <%= catLabel((String)exp.get("category")) %></span>
                </div>
            </div>
            <% } } %>
        </div>
        <% } %>
    </div>

    <script>
    var experimentId = <%= experiment != null ? experiment.get("id") : "null" %>;
    var experimentSteps = [];
    var currentStep = 0;
    var completedSteps = [];
    var observations = {};
    var dataRecords = {};

    function parseSteps(stepsStr) {
        try {
            return JSON.parse(stepsStr);
        } catch(e) {
            return [];
        }
    }

    function initLabMode(steps) {
        experimentSteps = steps;
        renderStepList();
        renderCurrentStep();
        updateProgress();
    }

    function renderStepList() {
        var list = document.getElementById('stepList');
        list.innerHTML = '';
        experimentSteps.forEach(function(step, index) {
            var item = document.createElement('div');
            item.className = 'step-item';
            if (index === currentStep) item.classList.add('active');
            if (completedSteps.includes(index)) item.classList.add('completed');
            item.onclick = function() { goToStep(index); };
            item.innerHTML = `
                <div class="step-num">${index + 1}</div>
                <div class="step-content">
                    <h5>${step.title}</h5>
                    <p>${step.content.substring(0, 30)}...</p>
                </div>
            `;
            list.appendChild(item);
        });
    }

    function renderCurrentStep() {
        var content = document.getElementById('labContent');
        var step = experimentSteps[currentStep];
        if (!step) {
            content.innerHTML = '<p style="color:rgba(255,255,255,0.5);text-align:center;padding:60px 0;">实验已完成！</p>';
            return;
        }

        var html = `<div class="step-area">
            <h3>📑 步骤 ${currentStep + 1}: ${step.title}</h3>
            <div class="step-description">${step.content}</div>`;

        if (currentStep === 0) {
            html += `
                <div class="observation-box">
                    <label>📝 实验目标</label>
                    <textarea id="obs_${currentStep}" placeholder="请记录本次实验的目标和预期结果..."></textarea>
                </div>
                <div class="checklist" id="checklist_${currentStep}">
                    <li onclick="toggleCheck(this)">
                        <div class="check-icon"></div>
                        <span>已阅读实验目的</span>
                    </li>
                    <li onclick="toggleCheck(this)">
                        <div class="check-icon"></div>
                        <span>已了解安全注意事项</span>
                    </li>
                    <li onclick="toggleCheck(this)">
                        <div class="check-icon"></div>
                        <span>准备好开始实验</span>
                    </li>
                </div>`;
        } else if (currentStep === experimentSteps.length - 1) {
            html += `
                <div class="observation-box">
                    <label>📊 实验结论</label>
                    <textarea id="obs_${currentStep}" placeholder="请总结实验结果和结论..."></textarea>
                </div>
                <div class="report-section">
                    <h4>📈 实验数据汇总</h4>
                    <div id="dataSummary"></div>
                </div>`;
        } else {
            html += `
                <div class="observation-box">
                    <label>🔍 观察记录</label>
                    <textarea id="obs_${currentStep}" placeholder="请记录本步骤的观察结果..."></textarea>
                </div>
                <div class="simulation-panel">
                    <h4 style="margin-bottom:15px;color:#fff">⚙️ 虚拟操作</h4>
                    <button class="sim-btn primary" onclick="runSimulation(${currentStep})">▶️ 运行模拟</button>
                    <button class="sim-btn" onclick="resetSimulation()">🔄 重置</button>
                    <div id="simResult"></div>
                </div>`;
            
            if (currentStep === 1 || currentStep === 2) {
                html += `
                    <div class="observation-box">
                        <label>📝 数据记录</label>
                        <table class="data-table">
                            <thead>
                                <tr><th>序号</th><th>测量值</th><th>单位</th></tr>
                            </thead>
                            <tbody>
                                <tr><td>1</td><td><input type="number" class="data-input" id="data_${currentStep}_1" step="0.01"></td><td></td></tr>
                                <tr><td>2</td><td><input type="number" class="data-input" id="data_${currentStep}_2" step="0.01"></td><td></td></tr>
                                <tr><td>3</td><td><input type="number" class="data-input" id="data_${currentStep}_3" step="0.01"></td><td></td></tr>
                            </tbody>
                        </table>
                    </div>`;
            }
        }

        html += '</div>';
        content.innerHTML = html;
    }

    function toggleCheck(el) {
        el.classList.toggle('checked');
    }

    function runSimulation(step) {
        var result = document.getElementById('simResult');
        result.innerHTML = '<div class="sim-result">⏳ 正在运行模拟...</div>';
        
        setTimeout(function() {
            var results = [
                '✅ 实验现象：观察到明显的物理变化，符合预期结果。',
                '✅ 实验现象：化学反应顺利进行，生成了预期产物。',
                '✅ 实验现象：数据采集完成，结果在误差范围内。',
                '✅ 实验现象：模拟成功，验证了理论假设。'
            ];
            result.innerHTML = `<div class="sim-result">${results[step % results.length]}</div>`;
        }, 1500);
    }

    function resetSimulation() {
        document.getElementById('simResult').innerHTML = '';
    }

    function goToStep(index) {
        if (index < 0 || index >= experimentSteps.length) return;
        saveCurrentStepData();
        currentStep = index;
        renderStepList();
        renderCurrentStep();
        updateProgress();
        updateNavButtons();
    }

    function prevStep() {
        if (currentStep > 0) {
            goToStep(currentStep - 1);
        }
    }

    function nextStep() {
        saveCurrentStepData();
        
        if (!completedSteps.includes(currentStep)) {
            completedSteps.push(currentStep);
        }
        
        if (currentStep < experimentSteps.length - 1) {
            goToStep(currentStep + 1);
        } else {
            showReport();
        }
    }

    function saveCurrentStepData() {
        var obs = document.getElementById(`obs_${currentStep}`);
        if (obs) {
            observations[currentStep] = obs.value;
        }
        var data1 = document.getElementById(`data_${currentStep}_1`);
        var data2 = document.getElementById(`data_${currentStep}_2`);
        var data3 = document.getElementById(`data_${currentStep}_3`);
        if (data1) {
            dataRecords[currentStep] = {
                d1: data1.value,
                d2: data2.value,
                d3: data3.value
            };
        }
    }

    function updateProgress() {
        var total = experimentSteps.length;
        var completed = completedSteps.length;
        var percent = total > 0 ? Math.round((completed / total) * 100) : 0;
        
        document.getElementById('progressFill').style.width = percent + '%';
        document.getElementById('progressText').textContent = completed + '/' + total;
        document.getElementById('progressPercent').textContent = percent + '%';
    }

    function updateNavButtons() {
        document.getElementById('prevBtn').disabled = currentStep === 0;
        var nextBtn = document.getElementById('nextBtn');
        if (currentStep === experimentSteps.length - 1) {
            nextBtn.textContent = '🏆 完成实验';
            nextBtn.classList.add('finish');
        } else {
            nextBtn.textContent = '下一步 →';
            nextBtn.classList.remove('finish');
        }
    }

    function showReport() {
        var content = document.getElementById('labContent');
        var nav = document.querySelector('.lab-nav');
        nav.style.display = 'none';
        
        var html = `
            <div class="lab-report active">
                <div class="success-badge">🎉 实验完成</div>
                <h3 style="margin-bottom:20px;color:#fff">📋 实验报告</h3>
                
                <div class="report-section">
                    <h4>📝 实验概述</h4>
                    <p style="color:rgba(255,255,255,0.7)">实验名称：${experiment ? '<%= experiment.get("name") %>' : '未知'}</p>
                    <p style="color:rgba(255,255,255,0.7)">实验日期：${new Date().toLocaleDateString('zh-CN')}</p>
                    <p style="color:rgba(255,255,255,0.7)">完成步骤：${completedSteps.length} / ${experimentSteps.length}</p>
                </div>

                <div class="report-section">
                    <h4>📊 实验数据记录</h4>
                    <table class="report-table">
                        <thead><tr><th>步骤</th><th>数据1</th><th>数据2</th><th>数据3</th></tr></thead>
                        <tbody>`;
        
        for (var i = 1; i < experimentSteps.length; i++) {
            var data = dataRecords[i] || {d1: '-', d2: '-', d3: '-'};
            html += `<tr><td>步骤${i+1}</td><td>${data.d1}</td><td>${data.d2}</td><td>${data.d3}</td></tr>`;
        }
        
        html += `</tbody></table>
                </div>

                <div class="report-section">
                    <h4>🔍 观察与结论</h4>
                    <div style="color:rgba(255,255,255,0.7);line-height:1.8">${observations[experimentSteps.length - 1] || '未填写结论'}</div>
                </div>

                <div class="report-section">
                    <h4>📈 数据分析</h4>
                    <canvas id="reportChart" class="report-chart"></canvas>
                </div>

                <div style="display:flex;gap:12px;margin-top:20px">
                    <button class="nav-btn prev" onclick="location.href='<%= ctx %>/virtualLab?id=${experimentId}'">← 返回详情</button>
                    <button class="nav-btn next" onclick="printReport()">🖨️ 打印报告</button>
                </div>
            </div>`;
        
        content.innerHTML = html;
        
        setTimeout(function() {
            renderChart();
        }, 500);
    }

    function renderChart() {
        var ctx = document.getElementById('reportChart').getContext('2d');

// ══════ 图表浅色/深色主题辅助 ══════
function _ct(){
    var d=(document.documentElement.getAttribute('data-theme')||'').indexOf('-light')>-1;
    return{
        ax:d?'rgba(61,57,41,.6)':_ct().ax,
        axL:d?'#5c5540':_ct().axL,
        gr:d?'rgba(139,119,80,.08)':_ct().gr,
        pri:d?'#2563eb':_ct().pri,
        priBg:d?'rgba(37,99,235,.12)':_ct().priBg,
        priBgL:d?'rgba(37,99,235,.08)':_ct().priBgL,
        dim:d?'rgba(139,119,80,.12)':_ct().dim,
        d:d
    };
}
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['步骤1', '步骤2', '步骤3', '步骤4'],
                datasets: [{
                    label: '实验数据趋势',
                    data: [65, 78, 82, 90],
                    borderColor: _ct().pri,
                    backgroundColor: _ct().priBgL,
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        labels: { color: _ct().axL }
                    }
                },
                scales: {
                    x: { ticks: { color: _ct().ax }, grid: { color: _ct().gr } },
                    y: { ticks: { color: _ct().ax }, grid: { color: _ct().gr } }
                }
            }
        });
    }

    function printReport() {
        window.print();
    }

    function startLab(id) {
        window.location.href = '<%= ctx %>/virtualLab?id=' + id + '&mode=lab';
    }

    window.onload = function() {
        var stepsStr = '<%= experiment != null ? experiment.get("steps") : "[]" %>';
        var steps = parseSteps(stepsStr);
        
        var stepsPreview = document.getElementById('stepsPreview');
        if (stepsPreview && steps.length > 0) {
            var html = '<ol style="padding-left:20px;color:rgba(255,255,255,0.6);line-height:2">';
            steps.forEach(function(s) {
                html += `<li style="margin-bottom:8px"><strong style="color:rgba(255,255,255,0.8)">${s.title}</strong>: ${s.content}</li>`;
            });
            html += '</ol>';
            stepsPreview.innerHTML = html;
        }

        if (window.location.search.includes('mode=lab') && steps.length > 0) {
            initLabMode(steps);
            updateNavButtons();
        }
    };
    </script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);setTimeout(function(){location.reload()},250);}});})();
</script>
</body>
</html>