<%--
 =============================================================================
 settings.jsp —— 设置中心（主导航项5）v2.0
 =============================================================================

 功能：
   1. 个人资料编辑（昵称/邮箱/性别/头像上传）→ POST /userProfile?action=update
   2. 密码修改（BCrypt 加密）→ POST /userProfile?action=changePassword
   3. 阅读偏好设置 → POST /settings?action=savePreference + localStorage
   4. 主题切换 → POST /settings?action=themeChange + postMessage + localStorage
   5. 账号信息 → GET /settings?action=userStats

 路由：/settings（SettingsServlet 转发）
 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ebookBuy301.pojo.Users, com.ebookBuy301.util.CsrfUtil" %>
<%
    Users currentUser = (Users) request.getAttribute("currentUser");
    boolean isLoggedIn = (currentUser != null);
    String nickname = isLoggedIn && currentUser.getNickname() != null ? currentUser.getNickname() : "";
    String username = isLoggedIn && currentUser.getUsername() != null ? currentUser.getUsername() : "";
    String email = isLoggedIn && currentUser.getEmail() != null ? currentUser.getEmail() : "";
    String sex = isLoggedIn && currentUser.getSex() != null ? currentUser.getSex() : "";
    String avatar = isLoggedIn && currentUser.getAvatar() != null ? currentUser.getAvatar() : "";
    String ctx = request.getContextPath();
    // CSRF Token（统一使用 CsrfUtil，与后端校验参数名 _csrf 一致）
    String csrfToken = CsrfUtil.getToken(session);
%>
<%!
    // HTML 上下文 XSS 转义
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
    // JS 字符串安全转义（处理单引号和反斜杠）
    private String escJs(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("'", "\\'")
                .replace("\n", "\\n").replace("\r", "\\r");
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>博雅书院 · 设置中心</title>
    <style>
/* ═══ Critical Inline (v3.0 玻璃拟态 · 外联加载前兜底) ═══ */
html,body{background:linear-gradient(160deg,#070b14 0%,#0a101e 50%,#0d1225 100%);margin:0;padding:0;min-height:100vh;color:#e2e8f0;font-family:'Inter','Segoe UI','PingFang SC','Microsoft YaHei',sans-serif;overflow-x:hidden;line-height:1.6;position:relative}
.st-container{max-width:1080px;margin:0 auto;padding:1.5rem 1.2rem;position:relative;z-index:1}

/* 头部 */
.st-header{display:flex;align-items:center;gap:1.2rem;margin-bottom:2rem;padding:1.4rem 1.8rem;background:linear-gradient(135deg,rgba(18,28,50,.7),rgba(12,18,35,.85));border:1px solid rgba(125,211,252,.08);border-radius:20px;backdrop-filter:blur(24px);position:relative;overflow:hidden;box-shadow:0 8px 32px rgba(0,0,0,.35),inset 0 1px 0 rgba(255,255,255,.04)}
.st-header::before{content:'';position:absolute;top:0;left:0;right:0;height:1px;background:linear-gradient(90deg,transparent,rgba(125,211,252,.4),rgba(167,139,250,.25),rgba(125,211,252,.15),transparent)}
.st-header::after{content:'';position:absolute;left:0;top:20%;bottom:20%;width:3px;background:linear-gradient(180deg,#7dd3fc,#a78bfa,transparent);border-radius:0 3px 3px 0}
.st-header-icon{font-size:2rem;width:56px;height:56px;display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg,rgba(125,211,252,.15),rgba(167,139,250,.08));border:1px solid rgba(125,211,252,.18);border-radius:16px;flex-shrink:0}
.st-header-text h1{font-size:1.4rem;font-weight:800;letter-spacing:-.3px;background:linear-gradient(135deg,#f0f4ff,#7dd3fc,#a78bfa,#f472b6);background-size:200% 200%;-webkit-background-clip:text;background-clip:text;color:transparent;margin:0}
.st-subtitle{font-size:.82rem;color:rgba(255,255,255,.42);margin-top:3px}

/* 未登录 */
.st-not-login{display:flex;flex-direction:column;align-items:center;padding:5rem 2rem;background:rgba(18,28,50,.55);border:1px solid rgba(125,211,252,.08);border-radius:24px;backdrop-filter:blur(20px);text-align:center}
.st-not-login-icon{font-size:4rem;margin-bottom:1.2rem;opacity:.4}
.st-not-login h2{font-size:1.3rem;color:rgba(255,255,255,.5);margin-bottom:.5rem;font-weight:600}
.st-not-login p{font-size:.88rem;color:rgba(255,255,255,.28);margin-bottom:1.5rem}

/* 内容布局 */
.st-content{display:flex;gap:20px;align-items:stretch}

/* 左侧导航 — 卡片容器 */
.st-nav{padding:8px;display:flex;flex-direction:column;gap:4px;background:var(--ui-glass);backdrop-filter:blur(30px) saturate(180%);-webkit-backdrop-filter:blur(30px) saturate(180%);border-radius:16px;border:1px solid rgba(var(--primary-holo-rgb),.15);box-shadow:0 4px 20px rgba(0,0,0,.28),inset 0 1px 0 rgba(var(--primary-holo-rgb),.04);overflow:hidden}
.st-nav-item{display:flex;align-items:center;gap:10px;padding:11px 16px;background:transparent;border:1px solid transparent;border-radius:10px;color:rgba(255,255,255,.45);font-size:.87rem;font-family:inherit;cursor:pointer;transition:all .3s cubic-bezier(.16,1,.3,1);text-align:left;position:relative;overflow:hidden}
.st-nav-item:hover{color:#e8ecf5;background:rgba(255,255,255,.04);border-color:rgba(255,255,255,.06);transform:translateX(3px)}
.st-nav-item.active{color:#7dd3fc;background:linear-gradient(135deg,rgba(125,211,252,.1),rgba(167,139,250,.05));border-color:rgba(125,211,252,.2);box-shadow:0 0 16px rgba(125,211,252,.08),inset 0 1px 0 rgba(125,211,252,.1);font-weight:600}
.st-nav-item.active::before{content:'';position:absolute;left:-1px;top:20%;bottom:20%;width:3px;background:linear-gradient(180deg,#7dd3fc,#a78bfa);border-radius:0 3px 3px 0}

/* 右侧面板 */
.st-panels{flex:1;min-width:0;min-height:400px}
.st-panel{display:block;background:rgba(18,28,50,.55);border:1px solid rgba(125,211,252,.08);border-radius:20px;padding:1.6rem 1.8rem;backdrop-filter:blur(20px);box-shadow:0 8px 32px rgba(0,0,0,.3),inset 0 1px 0 rgba(255,255,255,.03);position:relative;overflow:hidden;margin-bottom:1.5rem}
.st-panel.active{display:block;animation:panelSlideIn .4s cubic-bezier(.16,1,.3,1)}
@keyframes panelSlideIn{from{opacity:0;transform:translateY(12px) scale(.99)}to{opacity:1;transform:translateY(0) scale(1)}}
.st-panel::before{content:'';position:absolute;top:0;left:2.5rem;right:2.5rem;height:1px;background:linear-gradient(90deg,transparent,rgba(125,211,252,.2),transparent)}

/* 面板头部 */
.st-panel-head{margin-bottom:1.6rem;padding-bottom:1rem;border-bottom:1px solid rgba(255,255,255,.05);position:relative}
.st-panel-head h2{font-size:1.15rem;font-weight:700;color:#e8ecf5;margin-bottom:4px;letter-spacing:-.2px}
.st-panel-head p{font-size:.82rem;color:rgba(255,255,255,.42)}

/* 表单 */
.st-form{display:flex;flex-direction:column;gap:1.3rem}
.st-field{display:flex;flex-direction:column;gap:6px}
.st-field label{font-size:.72rem;color:rgba(255,255,255,.48);font-weight:600;letter-spacing:.4px;text-transform:uppercase}
.st-field input[type="text"],.st-field input[type="email"],.st-field input[type="password"],.st-field select,.st-field input[type="number"]{padding:12px 16px;background:rgba(255,255,255,.04);border:1px solid rgba(125,211,252,.12);border-radius:8px;color:#e8ecf5;font-size:.9rem;font-family:inherit;outline:none;transition:all .3s cubic-bezier(.16,1,.3,1);backdrop-filter:blur(8px)}
.st-field input:hover,.st-field select:hover{border-color:rgba(125,211,252,.22);background:rgba(255,255,255,.055)}
.st-field input:focus,.st-field select:focus{border-color:rgba(125,211,252,.35);background:rgba(255,255,255,.07);box-shadow:0 0 0 3px rgba(125,211,252,.08),0 0 20px rgba(125,211,252,.04)}
.st-field input::placeholder{color:rgba(255,255,255,.2)}
.st-field select{cursor:pointer;appearance:none;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' fill='%237dd3fc' viewBox='0 0 16 16'%3E%3Cpath d='M8 11L3 6h10z'/%3E%3C/svg%3E");background-repeat:no-repeat;background-position:right 14px center;padding-right:36px}
.st-field select option{background:#0d1225;color:#e8ecf5}
.st-field-hint{font-size:.73rem;color:rgba(255,255,255,.22);margin-top:2px}

/* Radio/Checkbox */
.st-radio-group,.st-check-group{display:flex;flex-wrap:wrap;gap:.75rem;margin-top:4px}
.st-radio,.st-check{display:inline-flex;align-items:center;gap:7px;font-size:.86rem;color:rgba(255,255,255,.48);cursor:pointer;transition:all .25s;padding:8px 16px;border-radius:8px;border:1px solid rgba(255,255,255,.05);background:rgba(255,255,255,.02)}
.st-radio:hover,.st-check:hover{color:#e8ecf5;background:rgba(255,255,255,.05);border-color:rgba(125,211,252,.15)}
.st-radio input[type="radio"],.st-check input[type="checkbox"]{accent-color:#7dd3fc;width:17px;height:17px;cursor:pointer}

/* 头像 */
.st-avatar-section{display:flex;align-items:center;gap:1.5rem;padding:1.3rem 1.4rem;background:rgba(255,255,255,.025);border:1px solid rgba(125,211,252,.08);border-radius:14px;margin-bottom:.5rem;backdrop-filter:blur(12px);position:relative;overflow:hidden}
.st-avatar-preview{width:88px;height:88px;border-radius:50%;overflow:hidden;background:linear-gradient(135deg,rgba(125,211,252,.12),rgba(167,139,250,.08));border:2.5px solid rgba(125,211,252,.25);display:flex;align-items:center;justify-content:center;font-size:2.2rem;flex-shrink:0;transition:all .4s;box-shadow:0 0 0 4px rgba(125,211,252,.06)}
.st-avatar-preview:hover{border-color:rgba(125,211,252,.5);box-shadow:0 0 0 6px rgba(125,211,252,.1),0 0 24px rgba(125,211,252,.15);transform:scale(1.04)}
.st-avatar-preview img{width:100%;height:100%;object-fit:cover}
.st-avatar-actions{display:flex;flex-direction:column;gap:8px;position:relative;z-index:1}
.st-avatar-hint{font-size:.74rem;color:rgba(255,255,255,.22)}

/* 按钮 */
.st-btn{display:inline-flex;align-items:center;justify-content:center;gap:7px;padding:10px 20px;border-radius:11px;font-size:.87rem;font-family:inherit;font-weight:600;cursor:pointer;border:none;transition:all .3s cubic-bezier(.16,1,.3,1);letter-spacing:.4px;white-space:nowrap;position:relative;overflow:hidden}
.st-btn::after{content:'';position:absolute;inset:0;background:linear-gradient(180deg,rgba(255,255,255,.1),transparent);opacity:0;transition:opacity .3s}
.st-btn:hover::after{opacity:1}
.st-btn-primary{background:linear-gradient(135deg,rgba(125,211,252,.22),rgba(167,139,250,.14));color:#7dd3fc;border:1px solid rgba(125,211,252,.25);box-shadow:0 2px 12px rgba(125,211,252,.08)}
.st-btn-primary:hover{background:linear-gradient(135deg,rgba(125,211,252,.32),rgba(167,139,250,.2));border-color:rgba(125,211,252,.38);box-shadow:0 4px 24px rgba(125,211,252,.15),0 0 40px rgba(125,211,252,.06);transform:translateY(-2px)}
.st-btn-primary:active{transform:translateY(0)}
.st-btn-outline{background:rgba(255,255,255,.03);border:1px solid rgba(125,211,252,.18);color:rgba(255,255,255,.58)}
.st-btn-outline:hover{border-color:rgba(125,211,252,.4);color:#7dd3fc;background:rgba(125,211,252,.06);box-shadow:0 0 16px rgba(125,211,252,.06)}
.st-btn-lg{padding:13px 28px;font-size:.92rem;border-radius:13px}
.st-btn-disabled{opacity:.45;pointer-events:none}

/* 3D环形旋转主题选择器 */
.st-theme-ring-container{position:relative;width:100%;padding:10px 0 0;perspective:900px;perspective-origin:50% 42%}
.st-theme-ring-orbit{position:relative;width:260px;height:260px;margin:0 auto 24px;transform-style:preserve-3d;transform:rotateX(28deg);transition:transform .6s ease}
.st-theme-ring-halo{position:absolute;top:8px;left:8px;width:244px;height:244px;border-radius:50%;border:2px solid rgba(125,211,252,.18);box-shadow:0 0 50px rgba(125,211,252,.08),inset 0 0 40px rgba(125,211,252,.04);pointer-events:none}
.st-theme-ring-halo-outer{position:absolute;top:-4px;left:-4px;width:268px;height:268px;border-radius:50%;border:1.5px dashed rgba(255,255,255,.08);pointer-events:none;animation:stRingHaloSpin 20s linear infinite}
@keyframes stRingHaloSpin{from{transform:rotateZ(0deg)}to{transform:rotateZ(360deg)}}
@keyframes stRingActivePulse{0%,100%{box-shadow:0 0 0 0 rgba(var(--primary-holo-rgb),.4)}50%{box-shadow:0 0 0 8px rgba(var(--primary-holo-rgb),0)}}
/* 旋转轨道（3D保留） */
.st-theme-ring-track{position:absolute;inset:0;transform-style:preserve-3d;transition:transform .85s cubic-bezier(.22,1,.36,1)}
/* 单个主题方块 — transition:none由JS统一管理深度 */
.st-theme-ring-item{position:absolute;width:50px;height:50px;border-radius:13px;cursor:pointer;border:3px solid rgba(255,255,255,.15);transform-style:preserve-3d;box-shadow:0 6px 18px rgba(0,0,0,.4);will-change:transform,opacity;transition:none}
/* 底部高亮条 = accent色 */
.st-theme-ring-item::before{content:'';position:absolute;bottom:3px;left:18%;right:18%;height:4px;border-radius:2px;background:currentColor;opacity:.75;pointer-events:none}
.st-theme-ring-item:hover{z-index:20!important;border-color:rgba(255,255,255,.7)!important;box-shadow:0 10px 28px rgba(0,0,0,.5),0 0 30px rgba(var(--primary-holo-rgb),.4)!important}
.st-theme-ring-item.active{z-index:15!important;border-color:#fff!important;box-shadow:0 10px 32px rgba(0,0,0,.5)!important}
.st-theme-ring-item.active::after{content:'';position:absolute;inset:-5px;border-radius:18px;border:2px solid rgba(255,255,255,.35);pointer-events:none;animation:stRingActivePulse 2s ease-in-out infinite}
/* 方块标签 */
.st-theme-ring-label{position:absolute;bottom:-20px;left:50%;transform:translateX(-50%);font-size:10px;font-weight:600;color:rgba(255,255,255,.45);white-space:nowrap;pointer-events:none;transition:color .25s}
.st-theme-ring-item:hover .st-theme-ring-label{color:rgba(255,255,255,.95)}
/* 底部指示文字（通过JS更新） */
.st-theme-ring-bottom-label{text-align:center;font-size:.82rem;font-weight:650;color:rgba(255,255,255,.55);letter-spacing:.5px;margin:4px 0 8px;transition:color .25s,transform .25s}
.st-theme-ring-bottom-label.flash{color:rgba(255,255,255,.9);transform:scale(1.08)}
/* 中心标识 */
.st-theme-ring-center{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%) translateZ(5px);width:64px;height:64px;border-radius:50%;background:rgba(255,255,255,.04);border:2px dashed rgba(125,211,252,.18);display:flex;align-items:center;justify-content:center;pointer-events:none;transition:all .4s ease}
.st-theme-ring-center-icon{font-size:22px;opacity:.6;transition:opacity .4s}
.st-theme-ring-center:hover .st-theme-ring-center-icon{opacity:1}
/* 旋转控制 */
.st-theme-ring-controls{display:flex;align-items:center;justify-content:center;gap:16px;margin-top:4px}
.st-theme-ring-btn{width:42px;height:42px;border-radius:50%;background:rgba(255,255,255,.05);border:1.5px solid rgba(125,211,252,.15);color:rgba(255,255,255,.6);font-size:14px;cursor:pointer;transition:all .3s cubic-bezier(.16,1,.3,1);display:flex;align-items:center;justify-content:center;font-family:inherit}
.st-theme-ring-btn:hover{background:rgba(125,211,252,.1);border-color:rgba(125,211,252,.35);color:#7dd3fc;box-shadow:0 0 20px rgba(125,211,252,.15);transform:scale(1.1)}
.st-theme-ring-btn:active{transform:scale(.95)}
/* 信息列表 */
.st-info-list{display:flex;flex-direction:column;gap:2px}
.st-info-item{display:flex;justify-content:space-between;align-items:center;padding:14px 18px;background:rgba(255,255,255,.02);border-radius:8px;transition:all .25s;border:1px solid transparent}
.st-info-item:nth-child(even){background:rgba(255,255,255,.03)}
.st-info-item:hover{background:rgba(125,211,252,.04);border-color:rgba(125,211,252,.08);transform:translateX(3px)}
.st-info-label{font-size:.87rem;color:rgba(255,255,255,.45)}
.st-info-value{font-size:.87rem;color:#e8ecf5;font-weight:600;font-variant-numeric:tabular-nums}
/* 账号信息编辑模式 */
.st-info-item.editing{background:rgba(125,211,252,.06)!important;border-color:rgba(125,211,252,.12)!important;border-radius:10px}
.st-info-input{font-size:.87rem;font-weight:600;color:#e8ecf5;background:rgba(255,255,255,.06);border:1px solid rgba(125,211,252,.2);border-radius:6px;padding:6px 10px;width:180px;text-align:right;outline:none;transition:border-color .25s,box-shadow .25s;font-family:inherit;box-sizing:border-box}
.st-info-input:focus{border-color:rgba(125,211,252,.5);box-shadow:0 0 0 3px rgba(125,211,252,.1)}
.st-info-select{width:120px;text-align:left;text-align-last:left;cursor:pointer;appearance:none;-webkit-appearance:none;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6'%3E%3Cpath d='M0 0l5 6 5-6z' fill='rgba(125,211,252,.5)'/%3E%3C/svg%3E");background-repeat:no-repeat;background-position:right 10px center;padding-right:28px}
.st-panel-head-actions{display:flex;justify-content:space-between;align-items:flex-start;gap:1rem}
.st-info-action-btns{display:flex;align-items:center;gap:8px;flex-shrink:0;margin-top:2px}
.st-btn-xs{font-size:.78rem;padding:5px 14px;border-radius:8px;min-width:auto}
.st-btn-ghost{color:rgba(255,255,255,.5);background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);cursor:pointer;transition:all .25s;font-family:inherit}
.st-btn-ghost:hover{color:rgba(255,255,255,.85);background:rgba(125,211,252,.1);border-color:rgba(125,211,252,.25)}

/* Toast */
.st-toast{position:fixed;top:24px;right:24px;padding:12px 26px;border-radius:14px;font-size:.87rem;font-family:inherit;font-weight:500;z-index:9999;opacity:0;transform:translateX(40px) scale(.95);transition:all .4s cubic-bezier(.16,1,.3,1);pointer-events:none;backdrop-filter:blur(20px);box-shadow:0 12px 36px rgba(0,0,0,.5);border:1px solid rgba(255,255,255,.06)}
.st-toast.show{opacity:1;transform:translateX(0) scale(1)}
.st-toast-success{background:rgba(0,200,150,.12);border-color:rgba(0,200,150,.25);color:#00c896}
.st-toast-error{background:rgba(255,80,80,.12);border-color:rgba(255,80,80,.25);color:#ff6b6b}

@media(max-width:1024px){.st-container{padding:1rem .6rem}}
@media(max-width:768px){body{padding:.8rem .3rem}.st-content{flex-direction:column}.st-nav{width:100%;flex-direction:row;flex-wrap:wrap;gap:6px;padding:8px;position:static;max-height:none}.st-nav-item{flex:1;min-width:85px;justify-content:center;font-size:.76rem;padding:9px 8px}.st-nav-item.active::before{display:none}.st-panel{padding:1.2rem 1.2rem}.st-theme-grid{grid-template-columns:1fr 1fr;gap:8px}.st-info-item{flex-direction:column;align-items:flex-start;gap:4px}.st-avatar-section{flex-direction:column;text-align:center}.st-radio-group,.st-check-group{flex-direction:column;gap:6px}}
@media(max-width:480px){.st-header{padding:.9rem 1rem;border-radius:14px}.st-header-icon{width:44px;height:44px;font-size:1.6rem}.st-header-text h1{font-size:1.15rem}.st-nav-item{font-size:.7rem;padding:7px 6px;min-width:72px}.st-theme-grid{grid-template-columns:1fr !important}.st-orb{display:none}}
    </style>
    <link rel="stylesheet" href="<%= ctx %>/CSS/settings.css?v=20260604-v2">
    <style>
/* ══════════ 浅色主题 · 设置中心 v3.0 玻璃拟态 ══════════ */
/* ── 基础底色 ── */
html[data-theme$="-light"] body{background:linear-gradient(170deg,#e9e2d2,#ede5d3 40%,#e4dbca)!important;color:#3d3929!important}
html[data-theme$="-light"] body::after{background-image:linear-gradient(rgba(139,119,80,.025)1px,transparent 1px),linear-gradient(90deg,rgba(139,119,80,.025)1px,transparent 1px)!important;opacity:.6!important}

/* ── 浮动光球 ── */
html[data-theme$="-light"] .st-orb{opacity:.04!important}

/* ── 头部 ── */
html[data-theme$="-light"] .st-header{background:linear-gradient(135deg,rgba(238,233,222,.85),rgba(243,239,228,.95))!important;border-color:rgba(37,99,235,.12)!important;box-shadow:0 4px 28px rgba(139,119,80,.12),inset 0 1px 0 rgba(255,255,255,.7)!important}
html[data-theme$="-light"] .st-header::before{background:linear-gradient(90deg,transparent,rgba(37,99,235,.18),rgba(124,58,237,.12),transparent)!important}
html[data-theme$="-light"] .st-header::after{display:none!important}
html[data-theme$="-light"] .st-header-icon{background:linear-gradient(135deg,rgba(37,99,235,.08),rgba(124,58,237,.05))!important;border-color:rgba(37,99,235,.15)!important}
html[data-theme$="-light"] .st-header-text h1{background:linear-gradient(135deg,#1d4ed8,#7c3aed,#dc2626)!important;-webkit-background-clip:text!important;background-clip:text!important;color:transparent!important}
html[data-theme$="-light"] .st-subtitle{color:#8a8370!important}

/* ── 未登录 ── */
html[data-theme$="-light"] .st-not-login{background:rgba(238,233,222,.65)!important;border-color:rgba(139,119,80,.08)!important;box-shadow:0 4px 20px rgba(139,119,80,.08)!important}
html[data-theme$="-light"] .st-not-login h2{color:#5c5540!important}
html[data-theme$="-light"] .st-not-login p{color:#8a8370!important}

/* ── 左侧导航 — 卡片容器 ── */
html[data-theme$="-light"] .st-nav{background:rgba(238,233,222,.75)!important;border-color:rgba(139,119,80,.1)!important;box-shadow:0 4px 16px rgba(139,119,80,.06),inset 0 1px 0 rgba(255,255,255,.5)!important}
html[data-theme$="-light"] .st-nav-item{color:rgba(61,57,41,.45)!important;border-color:transparent!important}
html[data-theme$="-light"] .st-nav-item:hover{color:#3d3929!important;background:rgba(37,99,235,.05)!important;border-color:rgba(37,99,235,.08)!important}
html[data-theme$="-light"] .st-nav-item.active{color:#2563eb!important;background:linear-gradient(135deg,rgba(37,99,235,.07),rgba(124,58,237,.04))!important;border-color:rgba(37,99,235,.16)!important;box-shadow:0 0 14px rgba(37,99,235,.06),inset 0 1px 0 rgba(37,99,235,.08)!important}
html[data-theme$="-light"] .st-nav-item.active::before{background:linear-gradient(180deg,#2563eb,#7c3aed)!important}

/* ── 右侧面板容器 ── */
html[data-theme$="-light"] .st-panel{background:rgba(255,252,246,.82)!important;border-color:rgba(139,119,80,.1)!important;box-shadow:0 4px 24px rgba(139,119,80,.08),inset 0 1px 0 rgba(255,255,255,.6)!important}
html[data-theme$="-light"] .st-panel::before{background:linear-gradient(90deg,transparent,rgba(37,99,235,.12),transparent)!important}

/* ── 面板头部 ── */
html[data-theme$="-light"] .st-panel-head{border-bottom-color:rgba(139,119,80,.08)!important}
html[data-theme$="-light"] .st-panel-head h2{color:#2d2a24!important;font-weight:700!important}
html[data-theme$="-light"] .st-panel-head p{color:#8a8370!important}

/* ── 表单字段 ── */
html[data-theme$="-light"] .st-field label{color:rgba(61,57,41,.48)!important;text-transform:none!important;letter-spacing:.2px!important;font-size:.82rem!important;font-weight:600!important}
html[data-theme$="-light"] .st-field input[type="text"],
html[data-theme$="-light"] .st-field input[type="email"],
html[data-theme$="-light"] .st-field input[type="password"],
html[data-theme$="-light"] .st-field input[type="number"],
html[data-theme$="-light"] .st-field select{
    background:rgba(245,240,232,.85)!important;
    border-color:rgba(139,119,80,.12)!important;
    color:#2d2a24!important;
    box-shadow:none!important
}
html[data-theme$="-light"] .st-field input:hover,
html[data-theme$="-light"] .st-field select:hover{
    border-color:rgba(37,99,235,.18)!important;
    background:rgba(250,246,238,.92)!important
}
html[data-theme$="-light"] .st-field input:focus,
html[data-theme$="-light"] .st-field select:focus{
    border-color:rgba(37,99,235,.35)!important;
    background:#fff!important;
    box-shadow:0 0 0 3px rgba(37,99,235,.08),0 0 20px rgba(37,99,235,.03)!important
}
html[data-theme$="-light"] .st-field input::placeholder{color:rgba(61,57,41,.25)!important}
html[data-theme$="-light"] .st-field select option{background:#f5f0e4!important;color:#2d2a24!important}
html[data-theme$="-light"] .st-field-hint{color:rgba(61,57,41,.28)!important}

/* ── Radio/Checkbox ── */
html[data-theme$="-light"] .st-radio,
html[data-theme$="-light"] .st-check{
    color:rgba(61,57,41,.52)!important;
    background:rgba(245,240,232,.6)!important;
    border-color:rgba(139,119,80,.12)!important
}
html[data-theme$="-light"] .st-radio:hover,
html[data-theme$="-light"] .st-check:hover{
    color:#2d2a24!important;
    background:rgba(37,99,235,.05)!important;
    border-color:rgba(37,99,235,.15)!important
}
html[data-theme$="-light"] .st-radio input[type="radio"],
html[data-theme$="-light"] .st-check input[type="checkbox"]{
    accent-color:#2563eb!important
}

/* ── 头像区域 ── */
html[data-theme$="-light"] .st-avatar-section{
    background:rgba(245,240,232,.5)!important;
    border-color:rgba(139,119,80,.1)!important
}
html[data-theme$="-light"] .st-avatar-preview{
    background:linear-gradient(135deg,rgba(37,99,235,.06),rgba(124,58,237,.04))!important;
    border-color:rgba(37,99,235,.22)!important;
    box-shadow:0 0 0 4px rgba(37,99,235,.05)!important
}
html[data-theme$="-light"] .st-avatar-preview:hover{
    border-color:rgba(37,99,235,.45)!important;
    box-shadow:0 0 0 6px rgba(37,99,235,.10),0 0 20px rgba(37,99,235,.1)!important
}
html[data-theme$="-light"] .st-avatar-hint{color:rgba(61,57,41,.28)!important}

/* ── 按钮 ── */
html[data-theme$="-light"] .st-btn-primary{
    background:linear-gradient(135deg,rgba(37,99,235,.13),rgba(124,58,237,.08))!important;
    color:#1d4ed8!important;
    border-color:rgba(37,99,235,.2)!important;
    box-shadow:0 2px 10px rgba(37,99,235,.08)!important
}
html[data-theme$="-light"] .st-btn-primary:hover{
    background:linear-gradient(135deg,rgba(37,99,235,.22),rgba(124,58,237,.13))!important;
    border-color:rgba(37,99,235,.32)!important;
    box-shadow:0 4px 20px rgba(37,99,235,.12),0 0 32px rgba(37,99,235,.05)!important
}
html[data-theme$="-light"] .st-btn-outline{
    background:rgba(245,240,232,.6)!important;
    border-color:rgba(139,119,80,.14)!important;
    color:rgba(61,57,41,.52)!important
}
html[data-theme$="-light"] .st-btn-outline:hover{
    border-color:rgba(37,99,235,.25)!important;
    color:#1d4ed8!important;
    background:rgba(37,99,235,.05)!important;
    box-shadow:0 0 12px rgba(37,99,235,.05)!important
}
html[data-theme$="-light"] .st-btn-disabled{opacity:.42!important}

/* ── 3D主题环·浅色 ── */
html[data-theme$="-light"] .st-theme-ring-halo{border-color:rgba(0,0,0,.1)!important;box-shadow:0 0 50px rgba(0,0,0,.05),inset 0 0 40px rgba(0,0,0,.025)!important}
html[data-theme$="-light"] .st-theme-ring-halo-outer{border-color:rgba(0,0,0,.08)!important}
html[data-theme$="-light"] .st-theme-ring-item{box-shadow:0 6px 18px rgba(0,0,0,.18)!important}
html[data-theme$="-light"] .st-theme-ring-item:hover{border-color:rgba(0,0,0,.45)!important;box-shadow:0 10px 28px rgba(0,0,0,.22),0 0 30px rgba(37,99,235,.15)!important}
html[data-theme$="-light"] .st-theme-ring-item.active{border-color:#2563eb!important;box-shadow:0 10px 32px rgba(0,0,0,.2)!important}
html[data-theme$="-light"] .st-theme-ring-item.active::after{border-color:rgba(37,99,235,.25)!important}
html[data-theme$="-light"] .st-theme-ring-label{color:rgba(40,35,25,.4)!important}
html[data-theme$="-light"] .st-theme-ring-item:hover .st-theme-ring-label{color:#1a1815!important}
html[data-theme$="-light"] .st-theme-ring-center{background:rgba(0,0,0,.03)!important;border-color:rgba(0,0,0,.12)!important}
html[data-theme$="-light"] .st-theme-ring-btn{background:rgba(0,0,0,.03)!important;border-color:rgba(0,0,0,.12)!important;color:rgba(50,45,35,.45)!important}
html[data-theme$="-light"] .st-theme-ring-btn:hover{background:rgba(37,99,235,.08)!important;border-color:rgba(37,99,235,.25)!important;color:#1d4ed8!important;box-shadow:0 0 20px rgba(37,99,235,.1)!important}
html[data-theme$="-light"] .st-theme-ring-bottom-label{color:rgba(50,45,35,.55)!important}
html[data-theme$="-light"] .st-theme-ring-bottom-label.flash{color:#1a1815!important}

/* ── 信息列表 ── */
html[data-theme$="-light"] .st-info-list{gap:4px}
html[data-theme$="-light"] .st-info-item{
    background:rgba(245,240,232,.45)!important;
    border-radius:10px!important
}
html[data-theme$="-light"] .st-info-item:nth-child(even){background:rgba(238,233,222,.55)!important}
html[data-theme$="-light"] .st-info-item:hover{
    background:rgba(37,99,235,.05)!important;
    border-color:rgba(37,99,235,.1)!important
}
html[data-theme$="-light"] .st-info-label{color:rgba(61,57,41,.48)!important}
html[data-theme$="-light"] .st-info-value{color:#2d2a24!important}
html[data-theme$="-light"] .st-info-item.editing{background:rgba(37,99,235,.06)!important;border-color:rgba(37,99,235,.15)!important}
html[data-theme$="-light"] .st-info-input{color:#1a1815!important;background:rgba(255,255,255,.7)!important;border-color:rgba(37,99,235,.2)!important}
html[data-theme$="-light"] .st-info-input:focus{border-color:rgba(37,99,235,.4)!important;box-shadow:0 0 0 3px rgba(37,99,235,.08)!important}
html[data-theme$="-light"] .st-btn-ghost{color:rgba(50,45,35,.5)!important;background:rgba(0,0,0,.03)!important;border-color:rgba(0,0,0,.1)!important}
html[data-theme$="-light"] .st-btn-ghost:hover{color:#1a1815!important;background:rgba(37,99,235,.08)!important;border-color:rgba(37,99,235,.2)!important}

/* ── Toast ── */
html[data-theme$="-light"] .st-toast{
    background:rgba(255,252,246,.96)!important;
    box-shadow:0 8px 30px rgba(139,119,80,.18)!important;
    border:1px solid rgba(139,119,80,.1)!important
}
html[data-theme$="-light"] .st-toast-success{
    background:rgba(5,150,105,.08)!important;
    border-color:rgba(5,150,105,.2)!important;
    color:#047857!important
}
html[data-theme$="-light"] .st-toast-error{
    background:rgba(220,60,60,.08)!important;
    border-color:rgba(220,60,60,.2)!important;
    color:#b91c1c!important
}

/* ── 通用 ── */
html[data-theme$="-light"] ::selection{background:rgba(37,99,235,.15)!important;color:#2d2a24!important}
html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3{color:#2d2a24!important}
html[data-theme$="-light"] p{color:#8a8370!important}

/* ══════════ 8套主题 · 导航栏与面板独立背景风格 ══════════ */
/* ── 🌙 量子矩阵 (默认) ── */
html[data-theme="quantum-matrix"] body{background:linear-gradient(160deg,#070b14,#0a101e 50%,#0d1225)!important}
html[data-theme="quantum-matrix"] .st-nav{background:rgba(18,28,50,.6)!important;border-color:rgba(74,158,255,.1)!important;box-shadow:0 4px 20px rgba(0,0,0,.28),inset 0 1px 0 rgba(74,158,255,.04)!important}
html[data-theme="quantum-matrix"] .st-panel{background:rgba(18,28,50,.58)!important;border-color:rgba(74,158,255,.1)!important;box-shadow:0 8px 32px rgba(0,0,0,.32),inset 0 1px 0 rgba(74,158,255,.04)!important}
html[data-theme="quantum-matrix"] .st-header{background:linear-gradient(135deg,rgba(18,28,50,.7),rgba(12,18,35,.85))!important;border-color:rgba(74,158,255,.1)!important;box-shadow:0 8px 32px rgba(0,0,0,.35),inset 0 1px 0 rgba(74,158,255,.05)!important}
/* ── 🌌 星云幻影 ── */
html[data-theme="nebula-dream"] body{background:linear-gradient(160deg,#140810,#2a1418 50%,#1e0e14)!important}
html[data-theme="nebula-dream"] .st-nav{background:rgba(42,20,28,.78)!important;border-color:rgba(244,114,182,.1)!important;box-shadow:0 4px 20px rgba(0,0,0,.28),inset 0 1px 0 rgba(244,114,182,.04)!important}
html[data-theme="nebula-dream"] .st-panel{background:rgba(38,18,26,.78)!important;border-color:rgba(244,114,182,.1)!important;box-shadow:0 8px 32px rgba(0,0,0,.32),inset 0 1px 0 rgba(244,114,182,.04)!important}
html[data-theme="nebula-dream"] .st-header{background:linear-gradient(135deg,rgba(42,20,28,.75),rgba(30,14,20,.88))!important;border-color:rgba(244,114,182,.12)!important;box-shadow:0 8px 32px rgba(0,0,0,.35),inset 0 1px 0 rgba(244,114,182,.05)!important}
/* ── 🌀 赛博霓虹 ── */
html[data-theme="cyber-neon"] body{background:linear-gradient(160deg,#100608,#28160c 50%,#1a0e08)!important}
html[data-theme="cyber-neon"] .st-nav{background:rgba(40,22,14,.78)!important;border-color:rgba(0,242,255,.1)!important;box-shadow:0 4px 20px rgba(0,0,0,.28),inset 0 1px 0 rgba(0,242,255,.04)!important}
html[data-theme="cyber-neon"] .st-panel{background:rgba(32,18,12,.78)!important;border-color:rgba(0,242,255,.1)!important;box-shadow:0 8px 32px rgba(0,0,0,.32),inset 0 1px 0 rgba(0,242,255,.04)!important}
html[data-theme="cyber-neon"] .st-header{background:linear-gradient(135deg,rgba(40,22,14,.75),rgba(28,15,8,.88))!important;border-color:rgba(0,242,255,.12)!important;box-shadow:0 8px 32px rgba(0,0,0,.35),inset 0 1px 0 rgba(0,242,255,.05)!important}
/* ── 📊 数据流光 ── */
html[data-theme="data-stream"] body{background:linear-gradient(160deg,#0a0c10,#1e2228 50%,#14171d)!important}
html[data-theme="data-stream"] .st-nav{background:rgba(22,26,32,.78)!important;border-color:rgba(0,255,157,.1)!important;box-shadow:0 4px 20px rgba(0,0,0,.28),inset 0 1px 0 rgba(0,255,157,.04)!important}
html[data-theme="data-stream"] .st-panel{background:rgba(24,28,34,.78)!important;border-color:rgba(0,255,157,.1)!important;box-shadow:0 8px 32px rgba(0,0,0,.32),inset 0 1px 0 rgba(0,255,157,.04)!important}
html[data-theme="data-stream"] .st-header{background:linear-gradient(135deg,rgba(24,28,34,.75),rgba(20,24,30,.88))!important;border-color:rgba(0,255,157,.12)!important;box-shadow:0 8px 32px rgba(0,0,0,.35),inset 0 1px 0 rgba(0,255,157,.05)!important}
/* ── ☀️ 浅色四套 · 纸质书香 ── */

/* ── 🍎 Apple极简 ── */
html[data-theme="apple-light"] body{background:linear-gradient(170deg,#d8dae0,#e8e8ec 40%,#e0e2e8)!important}
html[data-theme="apple-light"] .st-nav{background:rgba(238,236,242,.88)!important;border-color:rgba(0,113,227,.1)!important;box-shadow:0 4px 18px rgba(139,119,80,.06),inset 0 1px 0 rgba(255,255,255,.65)!important}
html[data-theme="apple-light"] .st-panel{background:rgba(245,243,249,.92)!important;border-color:rgba(0,113,227,.08)!important;box-shadow:0 4px 26px rgba(139,119,80,.08),inset 0 1px 0 rgba(255,255,255,.65)!important}
html[data-theme="apple-light"] .st-header{background:linear-gradient(135deg,rgba(235,233,240,.88),rgba(242,240,247,.95))!important;border-color:rgba(0,113,227,.1)!important;box-shadow:0 4px 28px rgba(139,119,80,.12),inset 0 1px 0 rgba(255,255,255,.7)!important}

/* ── 📝 Notion风 ── */
html[data-theme="notion-light"] body{background:linear-gradient(170deg,#e0d8b0,#f0e6c8 40%,#e8ddb8)!important}
html[data-theme="notion-light"] .st-nav{background:rgba(248,242,220,.88)!important;border-color:rgba(47,128,237,.1)!important;box-shadow:0 4px 18px rgba(139,119,80,.06),inset 0 1px 0 rgba(255,255,255,.65)!important}
html[data-theme="notion-light"] .st-panel{background:rgba(252,248,234,.92)!important;border-color:rgba(47,128,237,.08)!important;box-shadow:0 4px 26px rgba(139,119,80,.08),inset 0 1px 0 rgba(255,255,255,.65)!important}
html[data-theme="notion-light"] .st-header{background:linear-gradient(135deg,rgba(245,238,215,.88),rgba(250,245,225,.95))!important;border-color:rgba(47,128,237,.1)!important;box-shadow:0 4px 28px rgba(139,119,80,.12),inset 0 1px 0 rgba(255,255,255,.7)!important}

/* ── 📖 微信读书 ── */
html[data-theme="weread-light"] body{background:linear-gradient(170deg,#ccd4b8,#d8e0c8 40%,#d0d8bc)!important}
html[data-theme="weread-light"] .st-nav{background:rgba(232,238,222,.88)!important;border-color:rgba(7,193,96,.1)!important;box-shadow:0 4px 18px rgba(139,119,80,.06),inset 0 1px 0 rgba(255,255,255,.65)!important}
html[data-theme="weread-light"] .st-panel{background:rgba(242,246,235,.92)!important;border-color:rgba(7,193,96,.08)!important;box-shadow:0 4px 26px rgba(139,119,80,.08),inset 0 1px 0 rgba(255,255,255,.65)!important}
html[data-theme="weread-light"] .st-header{background:linear-gradient(135deg,rgba(225,232,215,.88),rgba(235,242,228,.95))!important;border-color:rgba(7,193,96,.1)!important;box-shadow:0 4px 28px rgba(139,119,80,.12),inset 0 1px 0 rgba(255,255,255,.7)!important}

/* ── 🏫 智慧校园 ── */
html[data-theme="campus-light"] body{background:linear-gradient(170deg,#e2dcc8,#f0ece0 40%,#e8e4d4)!important}
html[data-theme="campus-light"] .st-nav{background:rgba(248,245,238,.88)!important;border-color:rgba(49,130,206,.1)!important;box-shadow:0 4px 18px rgba(139,119,80,.06),inset 0 1px 0 rgba(255,255,255,.65)!important}
html[data-theme="campus-light"] .st-panel{background:rgba(252,250,245,.92)!important;border-color:rgba(49,130,206,.08)!important;box-shadow:0 4px 26px rgba(139,119,80,.08),inset 0 1px 0 rgba(255,255,255,.65)!important}
html[data-theme="campus-light"] .st-header{background:linear-gradient(135deg,rgba(242,238,228,.88),rgba(248,245,236,.95))!important;border-color:rgba(49,130,206,.1)!important;box-shadow:0 4px 28px rgba(139,119,80,.12),inset 0 1px 0 rgba(255,255,255,.7)!important}
    </style>
</head>
<body id="settingsBody">
<!-- 浮动光球 -->
<div class="st-orb st-orb-1"></div>
<div class="st-orb st-orb-2"></div>
<div class="st-orb st-orb-3"></div>

<div class="st-container">
    <!-- ══════════ 页面头部 ══════════ -->
    <div class="st-header">
        <div class="st-header-icon">⚙️</div>
        <div class="st-header-text">
            <h1>设置中心</h1>
            <p class="st-subtitle">管理您的账户、偏好与个性化设置</p>
        </div>
    </div>

    <% if (!isLoggedIn) { %>
    <div class="st-not-login">
        <div class="st-not-login-icon">🔐</div>
        <h2>请先登录</h2>
        <p>登录后即可管理您的个人设置</p>
        <button class="st-btn st-btn-primary" onclick="parent.location.href='<%= ctx %>/LOGIN/login.jsp'">去登录</button>
    </div>
    <% } else { %>
    <!-- ══════════ 设置内容 ══════════ -->
    <div class="st-content">
        <!-- 左侧导航 -->
        <div class="st-nav">
            <button class="st-nav-item active" data-section="profile"><span class="nav-emoji">👤</span>个人资料</button>
            <button class="st-nav-item" data-section="password"><span class="nav-emoji">🔒</span>修改密码</button>
            <button class="st-nav-item" data-section="preferences"><span class="nav-emoji">📖</span>阅读偏好</button>
            <button class="st-nav-item" data-section="theme"><span class="nav-emoji">🎨</span>主题外观</button>
            <button class="st-nav-item" data-section="account"><span class="nav-emoji">📋</span>账号信息</button>
        </div>

        <!-- 右侧内容区 -->
        <div class="st-panels">

            <!-- ===== 1. 个人资料 ===== -->
            <div class="st-panel active" id="panel-profile">
                <div class="st-panel-head">
                    <h2>👤 个人资料</h2>
                    <p>修改您的昵称、邮箱和头像</p>
                </div>
                <form class="st-form" id="profileForm">
                    <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                    <input type="hidden" name="action" value="update">
                    <!-- 头像 -->
                    <div class="st-avatar-section">
                        <div class="st-avatar-preview" id="avatarPreview">
                            <% if (avatar != null && !avatar.isEmpty()) { %>
                            <img src="<%= ctx + "/" + avatar.replaceAll("^/", "") %>" alt="头像" onerror="this.style.display='none';this.parentElement.textContent='👤'">
                            <% } else { %>
                            👤
                            <% } %>
                        </div>
                        <div class="st-avatar-actions">
                            <label class="st-btn st-btn-outline">
                                📷 上传头像
                                <input type="file" name="avatarFile" accept="image/*" style="display:none" id="avatarFileInput">
                            </label>
                            <span class="st-avatar-hint">支持 JPG/PNG/GIF/WebP</span>
                        </div>
                    </div>
                    <!-- 昵称 -->
                    <div class="st-field">
                        <label for="nickname">昵称</label>
                        <input type="text" id="nickname" name="nickname" value="<%= esc(nickname) %>" placeholder="输入您的昵称" maxlength="50" required>
                    </div>
                    <!-- 性别 -->
                    <div class="st-field">
                        <label>性别</label>
                        <div class="st-radio-group">
                            <label class="st-radio"><input type="radio" name="sex" value="男" <%= "男".equals(sex) ? "checked" : "" %>> 男</label>
                            <label class="st-radio"><input type="radio" name="sex" value="女" <%= "女".equals(sex) ? "checked" : "" %>> 女</label>
                            <label class="st-radio"><input type="radio" name="sex" value="保密" <%= (!"男".equals(sex) && !"女".equals(sex)) ? "checked" : "" %>> 保密</label>
                        </div>
                    </div>
                    <!-- 邮箱 -->
                    <div class="st-field">
                        <label for="email">邮箱</label>
                        <input type="email" id="email" name="email" value="<%= esc(email) %>" placeholder="输入您的邮箱" required>
                    </div>
                    <button type="submit" class="st-btn st-btn-primary st-btn-lg">💾 保存修改</button>
                </form>
            </div>

            <!-- ===== 2. 修改密码 ===== -->
            <div class="st-panel" id="panel-password">
                <div class="st-panel-head">
                    <h2>🔒 修改密码</h2>
                    <p>为了账号安全，请定期更换密码</p>
                </div>
                <form class="st-form" id="passwordForm">
                    <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                    <div class="st-field">
                        <label for="oldPassword">当前密码</label>
                        <input type="password" id="oldPassword" name="oldPassword" placeholder="输入当前密码" required>
                    </div>
                    <div class="st-field">
                        <label for="newPassword">新密码</label>
                        <input type="password" id="newPassword" name="newPassword" placeholder="输入新密码（至少6位）" minlength="6" required>
                        <span class="st-field-hint">至少 6 位，建议包含字母和数字</span>
                    </div>
                    <div class="st-field">
                        <label for="confirmPassword">确认新密码</label>
                        <input type="password" id="confirmPassword" name="confirmPassword" placeholder="再次输入新密码" minlength="6" required>
                    </div>
                    <button type="submit" class="st-btn st-btn-primary st-btn-lg">🔒 更新密码</button>
                </form>
            </div>

            <!-- ===== 3. 阅读偏好 ===== -->
            <div class="st-panel" id="panel-preferences">
                <div class="st-panel-head">
                    <h2>📖 阅读偏好</h2>
                    <p>个性化您的阅读体验</p>
                </div>
                <form class="st-form" id="prefsForm">
                    <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                    <div class="st-field">
                        <label for="prefFontSize">字体大小</label>
                        <select id="prefFontSize">
                            <option value="small">小 (14px)</option>
                            <option value="medium" selected>中 (16px)</option>
                            <option value="large">大 (18px)</option>
                            <option value="xlarge">超大 (20px)</option>
                        </select>
                    </div>
                    <div class="st-field">
                        <label for="prefReadingMode">阅读模式</label>
                        <select id="prefReadingMode">
                            <option value="scroll" selected>滚动阅读</option>
                            <option value="page">翻页阅读</option>
                            <option value="auto">自动滚动</option>
                        </select>
                    </div>
                    <div class="st-field">
                        <label>推荐偏好</label>
                        <div class="st-check-group">
                            <label class="st-check"><input type="checkbox" name="prefGenre" value="文学"> 文学</label>
                            <label class="st-check"><input type="checkbox" name="prefGenre" value="科技"> 科技</label>
                            <label class="st-check"><input type="checkbox" name="prefGenre" value="历史"> 历史</label>
                            <label class="st-check"><input type="checkbox" name="prefGenre" value="哲学"> 哲学</label>
                            <label class="st-check"><input type="checkbox" name="prefGenre" value="经济"> 经济</label>
                            <label class="st-check"><input type="checkbox" name="prefGenre" value="艺术"> 艺术</label>
                        </div>
                    </div>
                    <button type="submit" class="st-btn st-btn-primary st-btn-lg">💾 保存偏好</button>
                </form>
            </div>

            <!-- ===== 4. 主题外观 ===== -->
            <div class="st-panel" id="panel-theme">
                <div class="st-panel-head">
                    <h2>🎨 主题外观</h2>
                </div>
                <!-- 🎨 3D环形旋转主题选择器 -->
                <div class="st-theme-ring-container" id="stThemeRingContainer">
                    <div class="st-theme-ring-orbit" id="stThemeRingOrbit">
                        <div class="st-theme-ring-halo"></div>
                        <div class="st-theme-ring-halo-outer"></div>
                        <div class="st-theme-ring-track" id="stThemeRingTrack">
                            <div class="st-theme-ring-item" data-theme="apple-light" data-accent="#0a7ad6" style="background:linear-gradient(135deg,#d0def0,#e0e4ec);border-color:rgba(10,122,214,.55)">
                                <span class="st-theme-ring-label">浅灰极简</span>
                            </div>
                            <div class="st-theme-ring-item" data-theme="notion-light" data-accent="#e8a020" style="background:linear-gradient(135deg,#faf0c8,#e8d890);border-color:rgba(232,160,32,.55)">
                                <span class="st-theme-ring-label">金黄暖调</span>
                            </div>
                            <div class="st-theme-ring-item" data-theme="weread-light" data-accent="#5a9030" style="background:linear-gradient(135deg,#d8e8c0,#b0d090);border-color:rgba(90,144,48,.55)">
                                <span class="st-theme-ring-label">橄榄书香</span>
                            </div>
                            <div class="st-theme-ring-item" data-theme="quantum-matrix" data-accent="#4a9eff" style="background:linear-gradient(135deg,#1c2a40,#0d1a2e)">
                                <span class="st-theme-ring-label">深灰蓝调</span>
                            </div>
                            <div class="st-theme-ring-item" data-theme="campus-light" data-accent="#6078d8" style="background:linear-gradient(135deg,#e8e4f0,#d8d4e8);border-color:rgba(96,120,216,.55)">
                                <span class="st-theme-ring-label">奶油校园</span>
                            </div>
                            <div class="st-theme-ring-item" data-theme="nebula-dream" data-accent="#e05060" style="background:linear-gradient(135deg,#2a1820,#1a0c14);border-color:rgba(224,80,96,.5)">
                                <span class="st-theme-ring-label">暗红星云</span>
                            </div>
                            <div class="st-theme-ring-item" data-theme="cyber-neon" data-accent="#ff6030" style="background:linear-gradient(135deg,#2a1810,#1a0c06);border-color:rgba(255,96,48,.5)">
                                <span class="st-theme-ring-label">橙红赛博</span>
                            </div>
                            <div class="st-theme-ring-item" data-theme="data-stream" data-accent="#30c8a0" style="background:linear-gradient(135deg,#1a2828,#0e1c1c);border-color:rgba(48,200,160,.5)">
                                <span class="st-theme-ring-label">深炭流光</span>
                            </div>
                        </div>
                        <!-- 中心标识 -->
                        <div class="st-theme-ring-center" id="stThemeRingCenter">
                            <span class="st-theme-ring-center-icon">🎨</span>
                        </div>
                    </div>
                    <!-- 底部标签（6点钟位置方块名称） -->
                    <div class="st-theme-ring-bottom-label" id="stThemeBottomLabel">深灰蓝调</div>
                    <!-- 旋转控制 -->
                    <div class="st-theme-ring-controls">
                        <button class="st-theme-ring-btn" id="stThemeRotateLeft" title="向左旋转">◀</button>
                        <button class="st-theme-ring-btn" id="stThemeRotateRight" title="向右旋转">▶</button>
                    </div>
                </div>
            </div>

            <!-- ===== 5. 账号信息 ===== -->
            <div class="st-panel" id="panel-account">
                <div class="st-panel-head st-panel-head-actions">
                    <div>
                        <h2>📋 账号信息</h2>
                        <p>查看您的账号详情与统计数据</p>
                    </div>
                    <div class="st-info-action-btns">
                        <button class="st-btn st-btn-xs st-btn-ghost" id="btnEditAccount">✏️ 编辑</button>
                        <button class="st-btn st-btn-xs st-btn-primary" id="btnSaveAccount" style="display:none">✅ 保存</button>
                        <button class="st-btn st-btn-xs st-btn-ghost" id="btnCancelAccount" style="display:none">取消</button>
                    </div>
                </div>
                <div class="st-info-list" id="accountInfoList">
                    <div class="st-info-item">
                        <span class="st-info-label">用户名</span>
                        <span class="st-info-value"><%= esc(username) %></span>
                    </div>
                    <div class="st-info-item" data-field="nickname">
                        <span class="st-info-label">昵称</span>
                        <span class="st-info-value st-info-display"><%= esc(!nickname.isEmpty() ? nickname : username) %></span>
                        <input class="st-info-input" type="text" value="<%= esc(!nickname.isEmpty() ? nickname : username) %>" maxlength="50" style="display:none">
                    </div>
                    <div class="st-info-item" data-field="email">
                        <span class="st-info-label">邮箱</span>
                        <span class="st-info-value st-info-display"><%= esc(!email.isEmpty() ? email : "未设置") %></span>
                        <input class="st-info-input" type="email" value="<%= esc(!email.isEmpty() ? email : "") %>" placeholder="输入邮箱" style="display:none">
                    </div>
                    <div class="st-info-item" data-field="sex">
                        <span class="st-info-label">性别</span>
                        <span class="st-info-value st-info-display"><%= esc(!sex.isEmpty() ? sex : "未设置") %></span>
                        <select class="st-info-input st-info-select" style="display:none">
                            <option value="男" <%= "男".equals(sex) ? "selected" : "" %>>男</option>
                            <option value="女" <%= "女".equals(sex) ? "selected" : "" %>>女</option>
                            <option value="保密" <%= (!"男".equals(sex) && !"女".equals(sex)) ? "selected" : "" %>>保密</option>
                        </select>
                    </div>
                    <div class="st-info-item">
                        <span class="st-info-label">角色</span>
                        <span class="st-info-value"><%= esc(currentUser.getRole() != null ? currentUser.getRole() : "用户") %></span>
                    </div>
                    <div class="st-info-item">
                        <span class="st-info-label">注册时间</span>
                        <span class="st-info-value" id="infoRegisterTime">加载中...</span>
                    </div>
                    <div class="st-info-item">
                        <span class="st-info-label">最后活跃</span>
                        <span class="st-info-value" id="infoLastLogin">加载中...</span>
                    </div>
                </div>
            </div>

        </div><!-- /st-panels -->
    </div><!-- /st-content -->
    <% } %>
</div><!-- /st-container -->

<script>
(function(){
                var cp = '<%= ctx %>';
    var _csrf = '<%= csrfToken %>';
    var isLoggedIn = <%= isLoggedIn ? "true" : "false" %>;

    // ══════════ 3D环形主题旋转选择器 — 数据定义（必须在 restoreTheme 之前） ══════════
    var themeRing = {
        names: {
            'apple-light': '浅灰极简', 'notion-light': '金黄暖调', 'weread-light': '橄榄书香',
            'quantum-matrix': '深灰蓝调', 'campus-light': '奶油校园',
            'nebula-dream': '暗红星云', 'cyber-neon': '橙红赛博', 'data-stream': '深炭流光'
        },
        themes: ['apple-light','notion-light','weread-light','quantum-matrix','campus-light','nebula-dream','cyber-neon','data-stream'],
        activeIndex: 3,
        currentAngle: 0
    };

    // ══════════ 初始化：恢复已保存主题（与 index.jsp 一致：data-theme + boya-theme） ══════════
    (function restoreTheme() {
        var theme = 'quantum-matrix';
        // 优先：从父窗口同步
        try {
            if (window.parent && window.parent !== window) {
                var pt = window.parent.document.documentElement.getAttribute('data-theme');
                if (pt) theme = pt;
            }
        } catch(e){}
        // 兜底：localStorage
        var saved = localStorage.getItem('boya-theme');
        if (saved) theme = saved;
        document.documentElement.setAttribute('data-theme', theme);
        // 加载浅色主题CSS
        var link = document.createElement('link');
        link.rel = 'stylesheet';
        link.id = 'boya-light-css';
        link.href = '<%= request.getContextPath() %>/CSS/sub-pages-light.css';
        document.head.appendChild(link);
        // 初始化3D主题环
        initThemeRing(theme);
        // 监听父窗口发来的主题切换消息
        window.addEventListener('message', function(e) {
            if (e.data && e.data.type === 'themeChange' && e.data.theme) {
                var th = e.data.theme;
                document.documentElement.setAttribute('data-theme', th);
                localStorage.setItem('boya-theme', th);
                // 同时旋转3D环到该主题位置
                if (window._externalSnap) window._externalSnap(th);
                if (window.themeRingHighlight) window.themeRingHighlight(th);
            }
        });
    })();

    // ══════════ 左侧导航切换 ══════════
    document.querySelectorAll('.st-nav-item').forEach(function(btn){
        btn.addEventListener('click', function(){
            document.querySelectorAll('.st-nav-item').forEach(function(b){ b.classList.remove('active'); });
            this.classList.add('active');
            var section = this.getAttribute('data-section');
            document.querySelectorAll('.st-panel').forEach(function(p){
                p.classList.toggle('active', p.id === 'panel-' + section);
            });
        });
    });

    // ══════════ 3D环形主题旋转选择器 函数定义 ══════════
    function initThemeRing(currentTheme) {
        var track = document.getElementById('stThemeRingTrack');
        var items = track.querySelectorAll('.st-theme-ring-item');
        var OR = 105;
        var CAROUSEL_DEPTH = 80; // 3D深度范围：前方+80px ~ 后方-80px

        // 将方块排列在圆形轨道上（仅首次位置初始化）
        items.forEach(function(item, i) {
            var angle = (i / items.length) * 2 * Math.PI - Math.PI / 2;
            var cx = OR * Math.cos(angle);
            var cy = OR * Math.sin(angle);
            item.style.left = (130 + cx - 25) + 'px';
            item.style.top  = (130 + cy - 25) + 'px';
            // 给item设accent色（用于before伪元素）
            var accent = item.getAttribute('data-accent') || '#fff';
            item.style.color = accent;
            // accent色底部线条（伪元素background:currentColor）
            item.style.setProperty('--item-accent', accent);
        });

        // ═════ 核心：根据轨道旋转角度计算每个item的3D深度 ═════
        function updateCarouselDepth(trackAngle) {
            var angRad = trackAngle * Math.PI / 180;
            items.forEach(function(item, i) {
                // 每个item的初始角度（弧度）
                var baseAngle = (i / items.length) * 2 * Math.PI - Math.PI / 2;
                // 视觉角度 = 初始角度 + 轨道旋转角（rotateZ顺时针=+）
                var visualAngle = baseAngle + angRad;
                // sin: 底部(+90°)=1最前, 顶部(-90°)=-1最后
                var depthFactor = Math.sin(visualAngle);
                
                // translateZ: +CAROUSEL_DEPTH到-CAROUSEL_DEPTH平滑变化
                var tz = CAROUSEL_DEPTH * depthFactor;
                // scale: 1.0(前方) ~ 0.55(后方)
                var sc = 0.55 + 0.45 * (depthFactor + 1) / 2;
                // opacity: 1.0(前方) ~ 0.15(后方)
                var op = 0.15 + 0.85 * (depthFactor + 1) / 2;
                // z-index: 深度大的在前
                var zi = Math.round(10 + tz);

                item.style.transform = 'translateZ(' + tz.toFixed(1) + 'px) scale(' + sc.toFixed(2) + ')';
                item.style.opacity = op.toFixed(2);
                item.style.zIndex = zi;

                // 标签跟随可见度
                var lbl = item.querySelector('.st-theme-ring-label');
                if (lbl) {
                    lbl.style.opacity = depthFactor > 0.3 ? '1' : '0';
                    lbl.style.color = depthFactor > 0.3 ? 'rgba(255,255,255,' + (0.45 + depthFactor*0.55).toFixed(1) + ')' : 'transparent';
                }
            });
        }

        // ═════ 找出最接近底部(6点钟)的item并更新标签 ═════
        function updateBottomLabel(trackAngle) {
            var angRad = trackAngle * Math.PI / 180;
            var bestIdx = 0;
            var bestDist = Infinity;
            items.forEach(function(item, i) {
                var baseAngle = (i / items.length) * 2 * Math.PI - Math.PI / 2;
                var visualAngle = baseAngle + angRad;
                // 底部 = 90° (π/2), 计算angular distance
                var diff = Math.abs(visualAngle - Math.PI / 2);
                // wrap around (eg 350° vs 90°)
                if (diff > Math.PI) diff = 2 * Math.PI - diff;
                if (diff < bestDist) {
                    bestDist = diff;
                    bestIdx = i;
                }
            });
            var bottomItem = items[bestIdx];
            var th = bottomItem.getAttribute('data-theme');
            var name = themeRing.names[th] || th;
            // 更新底部标签（环形下方）
            var labelEl = document.getElementById('stThemeBottomLabel');
            if (labelEl && labelEl.textContent !== name) {
                labelEl.textContent = name;
                labelEl.classList.remove('flash');
                void labelEl.offsetWidth;
                labelEl.classList.add('flash');
                setTimeout(function(){ labelEl.classList.remove('flash'); }, 400);
            }
            return { index: bestIdx, theme: th, name: name };
        }

        // ═════ Snap轨道到指定index + 更新3D深度 + 底部标签 ═════
        function snapToIndex(idx, instant) {
            themeRing.activeIndex = idx;
            var targetAngle = 180 - idx * 45;
            themeRing.currentAngle = targetAngle;
            if (instant) {
                track.style.transition = 'none';
                track.style.transform = 'rotateZ(' + targetAngle + 'deg)';
                // 强行同步·计算3D深度
                updateCarouselDepth(targetAngle);
                updateBottomLabel(targetAngle);
                track.offsetHeight;
                track.style.transition = 'transform .85s cubic-bezier(.22,1,.36,1)';
            } else {
                track.style.transform = 'rotateZ(' + targetAngle + 'deg)';
            }
        }

        // 监听轨道旋转动画 → 实时更新深度（requestAnimationFrame轮询）
        var depthAnimFrame = null;
        function startDepthPolling() {
            if (depthAnimFrame) cancelAnimationFrame(depthAnimFrame);
            var lastAngle = themeRing.currentAngle;
            function tick() {
                var matrix = getComputedStyle(track).transform;
                var currentAngle = lastAngle;
                if (matrix && matrix !== 'none') {
                    // 从matrix中提取旋转角
                    var vals = matrix.match(/matrix\(([^)]+)\)/);
                    if (vals) {
                        var parts = vals[1].split(',').map(parseFloat);
                        // rotateZ → cos(θ) at m11, sin(θ) at m21
                        currentAngle = Math.atan2(parts[1], parts[0]) * 180 / Math.PI;
                    }
                }
                updateCarouselDepth(currentAngle);
                updateBottomLabel(currentAngle);
                // 判断动画是否结束（角度接近目标）
                if (Math.abs(currentAngle - lastAngle) < 0.05 && 
                    Math.abs(currentAngle - (180 - themeRing.activeIndex * 45)) < 0.1) {
                    // 动画结束，停止轮询
                    depthAnimFrame = null;
                    return;
                }
                lastAngle = currentAngle;
                depthAnimFrame = requestAnimationFrame(tick);
            }
            tick();
        }

        // 监听track transitionend来停止轮询
        track.addEventListener('transitionend', function() {
            var exactAngle = 180 - themeRing.activeIndex * 45;
            updateCarouselDepth(exactAngle);
            updateBottomLabel(exactAngle);
            if (depthAnimFrame) {
                cancelAnimationFrame(depthAnimFrame);
                depthAnimFrame = null;
            }
        });

        // 找到当前主题并初始snap
        var tidx = themeRing.themes.indexOf(currentTheme);
        if (tidx >= 0) {
            themeRing.activeIndex = tidx;
            snapToIndex(tidx, true);
        }

        // 旋转按钮：◀ = 顺时针（向左转），▶ = 逆时针（向右转）
        document.getElementById('stThemeRotateLeft').addEventListener('click', function(){
            var next = (themeRing.activeIndex + 1) % themeRing.themes.length;
            snapToIndex(next, false);
            startDepthPolling();
        });
        document.getElementById('stThemeRotateRight').addEventListener('click', function(){
            var prev = (themeRing.activeIndex - 1 + themeRing.themes.length) % themeRing.themes.length;
            snapToIndex(prev, false);
            startDepthPolling();
        });

        // 点击方块直接切换
        items.forEach(function(item) {
            item.addEventListener('click', function() {
                var th = item.getAttribute('data-theme');
                var idx = themeRing.themes.indexOf(th);
                if (idx < 0) return;
                snapToIndex(idx, false);
                startDepthPolling();
                applyThemeNow(th);
            });
        });

        // ═════ 外部snap供postMessage使用 ═════
        window._externalSnap = function(th) {
            var idx = themeRing.themes.indexOf(th);
            if (idx >= 0) {
                snapToIndex(idx, false);
                startDepthPolling();
            }
        };

        // 初始高亮
        themeRingHighlight(currentTheme, items);
    }

    function applyThemeNow(th) {
        document.documentElement.setAttribute('data-theme', th);
        localStorage.setItem('boya-theme', th);
        if (window.parent && window.parent !== window) {
            window.parent.postMessage({ type: 'themeChange', theme: th }, '*');
        }
        var items = document.querySelectorAll('.st-theme-ring-item');
        var idx = themeRing.themes.indexOf(th);
        if (idx >= 0) themeRing.activeIndex = idx;
        items.forEach(function(itm) {
            itm.classList.toggle('active', itm.getAttribute('data-theme') === th);
        });
        showToast('✅ 主题已切换：' + (themeRing.names[th] || th));
    }

    // 高亮当前活动主题 + 更新底部标签
    function themeRingHighlight(th, items) {
        var els = items || document.querySelectorAll('.st-theme-ring-item');
        els.forEach(function(itm) {
            itm.classList.toggle('active', itm.getAttribute('data-theme') === th);
        });
        var idx = themeRing.themes.indexOf(th);
        if (idx >= 0) themeRing.activeIndex = idx;
    }

    // 暴露给外部（postMessage回调）
    window.themeRingHighlight = themeRingHighlight;

    // 旧的卡片逻辑已移除（由3D环取代）

    // ══════════ 头像上传预览 ══════════
    var avatarInput = document.getElementById('avatarFileInput');
    if (avatarInput) {
        avatarInput.addEventListener('change', function(){
            var file = this.files[0];
            if (file) {
                if (file.size > 5 * 1024 * 1024) {
                    showToast('⚠️ 头像文件不能超过 5MB', 'error');
                    this.value = '';
                    return;
                }
                var reader = new FileReader();
                reader.onload = function(e){
                    var preview = document.getElementById('avatarPreview');
                    preview.innerHTML = '<img src="' + e.target.result + '" alt="预览">';
                };
                reader.readAsDataURL(file);
            }
        });
    }

    // ══════════ 个人资料表单提交 ══════════
    var profileForm = document.getElementById('profileForm');
    if (profileForm) {
        profileForm.addEventListener('submit', function(e){
            e.preventDefault();
            var nick = document.getElementById('nickname').value.trim();
            if (!nick) { showToast('⚠️ 昵称不能为空', 'error'); return; }

            var formData = new FormData();
            formData.append('_csrf', _csrf);
            formData.append('action', 'update');
            formData.append('nickname', nick);
            formData.append('email', document.getElementById('email').value.trim());
            var sexRadio = document.querySelector('input[name="sex"]:checked');
            if (sexRadio) formData.append('sex', sexRadio.value);
            var avatarFile = avatarInput ? avatarInput.files[0] : null;
            if (avatarFile) formData.append('avatarFile', avatarFile);

            var btn = profileForm.querySelector('button[type="submit"]');
            var origText = btn.textContent;
            btn.textContent = '⏳ 保存中...';
            btn.classList.add('st-btn-disabled');

            var abortCtrl = new AbortController();
            var timerId = setTimeout(function(){ abortCtrl.abort(); }, 30000);

            fetch(cp + '/userProfile', { method: 'POST', body: formData, signal: abortCtrl.signal })
                .then(function(r){ clearTimeout(timerId); if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); })
                .then(function(d){
                    btn.textContent = origText;
                    btn.classList.remove('st-btn-disabled');
                    if (d.success) {
                        showToast('✅ ' + d.message);
                        if (d.avatar) {
                            var preview = document.getElementById('avatarPreview');
                            preview.innerHTML = '<img src="' + cp + '/' + d.avatar.replace(/^\//,'') + '?t=' + Date.now() + '" alt="头像">';
                        }
                        // 通知父窗口更新用户显示
                        if (window.parent && window.parent !== window) {
                            window.parent.postMessage({ type: 'profileUpdate', nickname: nick, avatar: d.avatar }, '*');
                        }
                    } else {
                        showToast('❌ ' + (d.message || '修改失败'), 'error');
                    }
                }).catch(function(e){
                    console.error('[settings]', e);
                    btn.textContent = origText;
                    btn.classList.remove('st-btn-disabled');
                    showToast('❌ 网络异常，请稍后重试', 'error');
                });
        });
    }

    // ══════════ 密码修改 ══════════
    var passwordForm = document.getElementById('passwordForm');
    if (passwordForm) {
        passwordForm.addEventListener('submit', function(e){
            e.preventDefault();
            var oldPwd = document.getElementById('oldPassword').value.trim();
            var newPwd = document.getElementById('newPassword').value.trim();
            var confirmPwd = document.getElementById('confirmPassword').value.trim();
            if (!oldPwd || !newPwd) { showToast('⚠️ 请填写完整', 'error'); return; }
            if (newPwd.length < 6) { showToast('⚠️ 新密码至少6位', 'error'); return; }
            if (newPwd !== confirmPwd) { showToast('⚠️ 两次密码不一致', 'error'); return; }

            var btn = passwordForm.querySelector('button[type="submit"]');
            var origText = btn.textContent;
            btn.textContent = '⏳ 提交中...';
            btn.classList.add('st-btn-disabled');

            var pwdAbort = new AbortController();
            var pwdTimer = setTimeout(function(){ pwdAbort.abort(); }, 30000);

            fetch(cp + '/userProfile', {
                method: 'POST',
                headers: {'Content-Type':'application/x-www-form-urlencoded'},
                body: 'action=changePassword&_csrf=' + encodeURIComponent(_csrf) +
                      '&oldPassword=' + encodeURIComponent(oldPwd) +
                      '&newPassword=' + encodeURIComponent(newPwd),
                signal: pwdAbort.signal
            }).then(function(r){ clearTimeout(pwdTimer); if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); })
            .then(function(d){
                btn.textContent = origText;
                btn.classList.remove('st-btn-disabled');
                if (d.success) {
                    showToast('✅ 密码修改成功');
                    passwordForm.reset();
                } else {
                    showToast('❌ ' + (d.message || '修改失败'), 'error');
                }
            }).catch(function(e){
                console.error('[settings]', e);
                btn.textContent = origText;
                btn.classList.remove('st-btn-disabled');
                showToast('❌ 网络异常，请稍后重试', 'error');
            });
        });
    }

    // ══════════ 偏好保存（localStorage + 服务端双写） =═════════
    var prefsForm = document.getElementById('prefsForm');
    if (prefsForm) {
        // 恢复已保存的偏好
        (function loadPrefs() {
            try {
                var saved = localStorage.getItem('boya_reading_prefs');
                if (saved) {
                    var p = JSON.parse(saved);
                    if (p.fontSize) document.getElementById('prefFontSize').value = p.fontSize;
                    if (p.readingMode) document.getElementById('prefReadingMode').value = p.readingMode;
                    if (p.genres && p.genres.length) {
                        document.querySelectorAll('input[name="prefGenre"]').forEach(function(cb){
                            cb.checked = p.genres.indexOf(cb.value) !== -1;
                        });
                    }
                }
            } catch(e){}
        })();

        prefsForm.addEventListener('submit', function(e){
            e.preventDefault();
            var prefs = {
                fontSize: document.getElementById('prefFontSize').value,
                readingMode: document.getElementById('prefReadingMode').value,
                genres: []
            };
            document.querySelectorAll('input[name="prefGenre"]:checked').forEach(function(cb){
                prefs.genres.push(cb.value);
            });
            // 1. 本地持久化
            try { localStorage.setItem('boya_reading_prefs', JSON.stringify(prefs)); } catch(e){}

            // 2. 服务端保存
            fetch(cp + '/settings', {
                method: 'POST',
                headers: {'Content-Type':'application/x-www-form-urlencoded'},
                body: 'action=savePreference&key=boya_reading_prefs&value=' + encodeURIComponent(JSON.stringify(prefs))
            }).then(function(r){ return r.json(); })
            .then(function(d){
                showToast(d.success ? '✅ 偏好已保存' : '⚠️ 本地已保存，云端同步失败');
            }).catch(function(){
                showToast('⚠️ 本地已保存，云端暂不可用');
            });
        });
    }

    // ══════════ 账号信息加载（独立 API） ══════════
    if (isLoggedIn) {
        fetch(cp + '/settings?action=userStats')
            .then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); })
            .then(function(d){
                if (d.success) {
                    document.getElementById('infoRegisterTime').textContent = d.registerTime || '首次登录';
                    document.getElementById('infoLastLogin').textContent = d.lastActiveTime || '当前会话';
                } else {
                    document.getElementById('infoRegisterTime').textContent = '--';
                    document.getElementById('infoLastLogin').textContent = '--';
                }
            }).catch(function(){
                document.getElementById('infoRegisterTime').textContent = '--';
                document.getElementById('infoLastLogin').textContent = '--';
            });
    }

    // ══════════ 账号信息内联编辑 ══════════
    (function(){
        var btnEdit = document.getElementById('btnEditAccount');
        var btnSave = document.getElementById('btnSaveAccount');
        var btnCancel = document.getElementById('btnCancelAccount');
        if (!btnEdit || !btnSave || !btnCancel) return;

        var editing = false;

        // 进入编辑模式
        btnEdit.addEventListener('click', function(){
            editing = true;
            btnEdit.style.display = 'none';
            btnSave.style.display = '';
            btnCancel.style.display = '';

            document.querySelectorAll('#accountInfoList .st-info-item[data-field]').forEach(function(item){
                item.classList.add('editing');
                var disp = item.querySelector('.st-info-display');
                var inp = item.querySelector('.st-info-input');
                if (disp) disp.style.display = 'none';
                if (inp) { inp.style.display = ''; inp.focus(); }
            });
        });

        // 取消编辑
        function cancelEdit(){
            editing = false;
            btnEdit.style.display = '';
            btnSave.style.display = 'none';
            btnCancel.style.display = 'none';

            document.querySelectorAll('#accountInfoList .st-info-item[data-field]').forEach(function(item){
                item.classList.remove('editing');
                var disp = item.querySelector('.st-info-display');
                var inp = item.querySelector('.st-info-input');
                if (disp) disp.style.display = '';
                if (inp) { inp.style.display = 'none'; }
            });
        }
        btnCancel.addEventListener('click', cancelEdit);

        // 保存
        btnSave.addEventListener('click', function(){
            if (!editing) return;
            var list = document.getElementById('accountInfoList');
            var nickname = list.querySelector('[data-field="nickname"] .st-info-input');
            var email = list.querySelector('[data-field="email"] .st-info-input');
            var sex = list.querySelector('[data-field="sex"] .st-info-input');

            var nickVal = (nickname && nickname.value) ? nickname.value.trim() : '';
            var emailVal = (email && email.value) ? email.value.trim() : '';
            var sexVal = (sex && sex.value) ? sex.value : '';

            if (!nickVal) { showToast('⚠️ 昵称不能为空', 'error'); return; }

            btnSave.disabled = true;
            btnSave.textContent = '⏳ 保存中...';

            fetch(cp + '/userProfile', {
                method: 'POST',
                headers: {'Content-Type':'application/x-www-form-urlencoded'},
                body: '_csrf=' + encodeURIComponent(_csrf) +
                      '&action=update&nickname=' + encodeURIComponent(nickVal) +
                      '&email=' + encodeURIComponent(emailVal) +
                      '&sex=' + encodeURIComponent(sexVal)
            }).then(function(r){ return r.json(); })
            .then(function(d){
                btnSave.disabled = false;
                btnSave.textContent = '✅ 保存';
                if (d.success) {
                    // 更新显示值
                    var nickDisp = list.querySelector('[data-field="nickname"] .st-info-display');
                    var emailDisp = list.querySelector('[data-field="email"] .st-info-display');
                    var sexDisp = list.querySelector('[data-field="sex"] .st-info-display');
                    if (nickDisp) nickDisp.textContent = nickVal;
                    if (emailDisp) emailDisp.textContent = emailVal || '未设置';
                    if (sexDisp) sexDisp.textContent = sexVal || '未设置';
                    showToast('✅ 账号信息已保存');
                    cancelEdit();
                } else {
                    showToast('⚠️ 保存失败：' + (d.message || '请稍后重试'), 'error');
                }
            }).catch(function(){
                btnSave.disabled = false;
                btnSave.textContent = '✅ 保存';
                showToast('⚠️ 网络异常，请稍后重试', 'error');
            });
        });
    })();

    // ══════════ Toast 通知 =═════════
    function showToast(msg, type) {
        type = type || 'success';
        var t = document.createElement('div');
        t.className = 'st-toast st-toast-' + type;
        t.textContent = msg;
        document.body.appendChild(t);
        requestAnimationFrame(function(){ t.classList.add('show'); });
        setTimeout(function(){
            t.classList.remove('show');
            setTimeout(function(){ if(t.parentNode) t.remove(); }, 300);
        }, 2800);
    }
})();
</script>
</body>
</html>
