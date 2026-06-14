<%--
 =============================================================================
 login.jsp
 =============================================================================

 用途      用户登录页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   EL 表达式 —— ${} 访问后端数据
   JSTL 核心标签 —— <c:forEach> / <c:if> / <c:choose>
   ${pageContext.request.contextPath} —— 获取应用上下文根路径
   Ajax 异步请求 —— fetch
   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById
   表单 GET/POST 提交 —— 携带 URL 参数或隐藏字段

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>博雅书院 · 登录</title>
    <link rel="stylesheet" href="../CSS/index.css">
    <link rel="stylesheet" href="../CSS/sub-pages-light.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            background: var(--bg-space);
            display: flex;
            justify-content: center;
            align-items: center;
            font-family: 'Orbitron', 'Inter', 'Segoe UI', system-ui, sans-serif;
            overflow: hidden;
            position: relative;
        }

        /* 科技感背景 */
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: 
                radial-gradient(circle at 20% 30%, rgba(var(--primary-holo-rgb), 0.08) 0%, transparent 50%),
                radial-gradient(circle at 80% 70%, rgba(var(--secondary-holo-rgb), 0.05) 0%, transparent 50%),
                linear-gradient(135deg, var(--bg-space) 0%, var(--bg-deep-space) 100%);
            z-index: -2;
            pointer-events: none;
        }

        /* 网格背景效果 */
        body::after {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: 
                linear-gradient(rgba(var(--primary-holo-rgb), 0.03) 1px, transparent 1px),
                linear-gradient(90deg, rgba(var(--primary-holo-rgb), 0.03) 1px, transparent 1px);
            background-size: 50px 50px;
            z-index: -1;
            opacity: 0.5;
            pointer-events: none;
        }

        .container {
            display: flex;
            align-items: center;
            gap: 100px;
            padding: 40px;
        }

        /* ========== 桌面场景 ========== */
        .desk-scene {
            position: relative;
            width: 500px;
            height: 560px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        /* 桌面 - 木纹质感 */
        .desk-surface {
            position: absolute;
            bottom: 0;
            left: -30px;
            right: -30px;
            height: 18px;
            background: linear-gradient(90deg, 
                #3d2914 0%, 
                #5c3d1e 20%, 
                #4a3019 40%, 
                #5c3d1e 60%, 
                #4a3019 80%, 
                #3d2914 100%);
            border-radius: 3px;
            box-shadow: 
                0 5px 15px rgba(0, 0, 0, 0.5),
                inset 0 2px 3px rgba(255, 255, 255, 0.1);
            z-index: 10;
        }

        /* ========== 桌面背景 - 模拟墙面框架 ========== */
        .wall-backdrop {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 30px;
            z-index: 0;
            border-radius: 12px 12px 0 0;
            /* 底色跟随主题变量 - 使用bg-surface比body略亮一层 */
            background: 
                /* 水平板条纹理 */
                repeating-linear-gradient(
                    0deg,
                    transparent,
                    transparent 59px,
                    rgba(255, 255, 255, 0.04) 59px,
                    rgba(255, 255, 255, 0.04) 60px
                ),
                /* 垂直板条纹理 */
                repeating-linear-gradient(
                    90deg,
                    transparent,
                    transparent 79px,
                    rgba(255, 255, 255, 0.025) 79px,
                    rgba(255, 255, 255, 0.025) 80px
                ),
                linear-gradient(180deg, 
                    var(--bg-surface) 0%, 
                    var(--bg-deep-space) 40%,
                    var(--bg-surface) 100%);
            /* 深色半透明内阴影营造墙壁纵深感 */
            box-shadow: 
                inset 0 0 120px rgba(0, 0, 0, 0.7),
                inset 0 3px 0 rgba(255, 255, 255, 0.06),
                inset 0 -40px 50px rgba(0, 0, 0, 0.5);
        }
        /* 墙面可见框架边框 */
        .wall-backdrop::after {
            content: '';
            position: absolute;
            top: -2px; left: -2px; right: -2px; bottom: 2px;
            border: 3px solid rgba(255, 255, 255, 0.18);
            border-bottom: none;
            border-radius: 13px 13px 0 0;
            pointer-events: none;
            z-index: 1;
            box-shadow: 0 0 0 1px rgba(255, 255, 255, 0.06), 0 0 15px rgba(var(--primary-holo-rgb), 0.08);
        }

        /* ========== 打开的书本 ========== */
        .open-book {
            position: absolute;
            bottom: 18px;
            left: 50%;
            transform: translateX(-50%);
            width: 140px;
            height: 45px;
            background: linear-gradient(180deg, #fef9e7 0%, #f5f0dc 100%);
            border-radius: 3px 3px 3px 3px;
            box-shadow: 
                0 3px 10px rgba(0, 0, 0, 0.3),
                0 0 0 rgba(var(--primary-holo-rgb), 0);
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 8px;
            transition: all 0.5s ease;
            z-index: 4;
        }

        .open-book.on {
            box-shadow: 
                0 3px 10px rgba(0, 0, 0, 0.3),
                0 0 40px rgba(var(--primary-holo-rgb), 0.5);
        }

        /* 书脊 */
        .book-spine {
            position: absolute;
            left: 50%;
            top: 0;
            bottom: 0;
            width: 2px;
            background: linear-gradient(180deg, #ddd 0%, #ccc 100%);
            transform: translateX(-50%);
        }

        /* 书本上的文字线 */
        .book-lines {
            width: 100%;
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .book-line {
            height: 2px;
            background: linear-gradient(90deg, 
                transparent 0%, 
                #aaa 10%, 
                #aaa 90%, 
                transparent 100%);
            border-radius: 1px;
        }

        .book-line:nth-child(1) { width: 90%; }
        .book-line:nth-child(2) { width: 85%; }
        .book-line:nth-child(3) { width: 88%; }
        .book-line:nth-child(4) { width: 82%; }

        /* ========== 小摆件区域 ========== */
        .desk-decor {
            position: absolute;
            bottom: 18px;
            z-index: 6;
        }

        /* 咖啡杯 */
        .coffee-cup {
            left: 20px;
            width: 32px;
            height: 32px;
        }

        .cup-body {
            position: absolute;
            bottom: 0;
            left: 0;
            width: 22px;
            height: 18px;
            background: linear-gradient(180deg, #ecf0f1, #bdc3c7);
            border-radius: 2px 2px 6px 6px;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.2);
        }

        .cup-handle {
            position: absolute;
            bottom: 5px;
            right: 0;
            width: 8px;
            height: 10px;
            border: 2px solid #bdc3c7;
            border-left: none;
            border-radius: 0 8px 8px 0;
        }

        .cup-steam {
            position: absolute;
            bottom: 20px;
            left: 6px;
            width: 12px;
            height: 12px;
        }

        .steam-line {
            position: absolute;
            width: 2px;
            height: 8px;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 2px;
            animation: steam 2s infinite;
        }

        .steam-line:nth-child(1) { left: 0; animation-delay: 0s; }
        .steam-line:nth-child(2) { left: 4px; animation-delay: 0.5s; }
        .steam-line:nth-child(3) { left: 8px; animation-delay: 1s; }

        @keyframes steam {
            0% { opacity: 0; transform: translateY(0) scaleY(0.5); }
            50% { opacity: 0.5; transform: translateY(-5px) scaleY(1); }
            100% { opacity: 0; transform: translateY(-10px) scaleY(0.5); }
        }

        /* 照片框 */
        .photo-frame {
            right: 50px;
            width: 22px;
            height: 28px;
            background: linear-gradient(145deg, #f5f5dc, #ddd);
            border: 2px solid #8b4513;
            border-radius: 2px;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
        }

        .photo-frame::before {
            content: '';
            position: absolute;
            top: 3px;
            left: 3px;
            right: 3px;
            bottom: 3px;
            background: linear-gradient(135deg, #87ceeb, #98fb98);
        }

        /* ========== 更多小摆件 ========== */
        
        /* 小盆栽 */
        .potted-plant {
            left: 70px;
            width: 28px;
            height: 45px;
        }

        .plant-pot {
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 20px;
            height: 18px;
            background: linear-gradient(180deg, #d35400, #a04000);
            border-radius: 3px 3px 6px 6px;
            box-shadow: 1px 2px 4px rgba(0, 0, 0, 0.3);
        }

        .plant-leaves {
            position: absolute;
            bottom: 16px;
            left: 50%;
            transform: translateX(-50%);
            width: 24px;
            height: 28px;
        }

        .leaf {
            position: absolute;
            width: 10px;
            height: 16px;
            background: linear-gradient(180deg, #27ae60, #1e8449);
            border-radius: 50% 50% 50% 50% / 60% 60% 40% 40%;
            box-shadow: inset -2px -2px 4px rgba(0, 0, 0, 0.2);
        }

        .leaf:nth-child(1) { left: 2px; top: 0; transform: rotate(-20deg); }
        .leaf:nth-child(2) { left: 7px; top: 4px; transform: rotate(5deg); }
        .leaf:nth-child(3) { left: 12px; top: 0; transform: rotate(25deg); }

        /* 笔筒 */
        .pen-holder {
            right: 100px;
            width: 26px;
            height: 40px;
        }

        .holder-body {
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 22px;
            height: 30px;
            background: linear-gradient(180deg, #5d6d7e, #34495e);
            border-radius: 4px 4px 8px 8px;
            box-shadow: 1px 2px 4px rgba(0, 0, 0, 0.3);
        }

        .holder-body::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #7f8c8d, #95a5a6, #7f8c8d);
            border-radius: 4px 4px 0 0;
        }

        .pen {
            position: absolute;
            width: 3px;
            height: 25px;
            border-radius: 1px 1px 2px 2px;
            bottom: 22px;
        }

        .pen:nth-child(1) { left: 5px; background: linear-gradient(180deg, #3498db, #2980b9); transform: rotate(-8deg); }
        .pen:nth-child(2) { left: 10px; background: linear-gradient(180deg, #e74c3c, #c0392b); transform: rotate(2deg); height: 28px; }
        .pen:nth-child(3) { left: 15px; background: linear-gradient(180deg, #f39c12, #d68910); transform: rotate(10deg); height: 22px; }

        /* 书签/便签 */
        .sticky-note {
            right: 20px;
            width: 30px;
            height: 30px;
            background: linear-gradient(135deg, #f1c40f, #f39c12);
            transform: rotate(5deg);
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.2);
        }

        .sticky-note::before {
            content: '';
            position: absolute;
            top: 5px;
            left: 4px;
            right: 4px;
            height: 2px;
            background: rgba(0, 0, 0, 0.1);
            box-shadow: 0 5px 0 rgba(0, 0, 0, 0.1), 0 10px 0 rgba(0, 0, 0, 0.1);
        }

        /* 小摆件 - 装饰球 */
        .decor-ball {
            left: 115px;
            width: 22px;
            height: 22px;
            border-radius: 50%;
            background: linear-gradient(135deg, #9b59b6, #8e44ad);
            box-shadow: 
                2px 2px 6px rgba(0, 0, 0, 0.3),
                inset -3px -3px 6px rgba(0, 0, 0, 0.2),
                inset 3px 3px 6px rgba(255, 255, 255, 0.2);
        }

        /* 小摆件 - 地球仪 */
        .globe {
            left: 160px;
            width: 26px;
            height: 38px;
        }

        .globe-sphere {
            position: absolute;
            top: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 22px;
            height: 22px;
            background: linear-gradient(135deg, #3498db, #2980b9);
            border-radius: 50%;
            box-shadow: 
                2px 2px 5px rgba(0, 0, 0, 0.3),
                inset -3px -3px 6px rgba(0, 0, 0, 0.2),
                inset 3px 3px 6px rgba(255, 255, 255, 0.3);
            overflow: hidden;
        }

        .globe-sphere::before {
            content: '';
            position: absolute;
            top: 3px;
            left: 3px;
            width: 6px;
            height: 8px;
            background: #27ae60;
            border-radius: 30%;
            transform: rotate(-20deg);
        }

        .globe-sphere::after {
            content: '';
            position: absolute;
            bottom: 5px;
            right: 3px;
            width: 5px;
            height: 6px;
            background: #f39c12;
            border-radius: 30%;
        }

        .globe-stand {
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 4px;
            height: 14px;
            background: linear-gradient(90deg, #7f8c8d, #95a5a6);
            border-radius: 2px;
        }

        .globe-base {
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 18px;
            height: 4px;
            background: linear-gradient(180deg, #7f8c8d, #5d6d7e);
            border-radius: 2px;
        }

        /* 小摆件 - 书本（叠放的） */
        .stacked-books {
            right: 140px;
            width: 35px;
            height: 20px;
        }

        .stacked-book {
            position: absolute;
            left: 0;
            border-radius: 2px;
            box-shadow: 1px 1px 3px rgba(0, 0, 0, 0.2);
        }

        .stacked-book:nth-child(1) {
            bottom: 0;
            width: 32px;
            height: 8px;
            background: linear-gradient(90deg, #e74c3c, #c0392b);
        }

        .stacked-book:nth-child(2) {
            bottom: 8px;
            width: 28px;
            height: 7px;
            background: linear-gradient(90deg, #3498db, #2980b9);
            transform: rotate(-3deg);
        }

        .stacked-book:nth-child(3) {
            bottom: 15px;
            width: 30px;
            height: 6px;
            background: linear-gradient(90deg, #2ecc71, #27ae60);
            transform: rotate(2deg);
        }

        /* 小摆件 - 茶杯组 */
        .tea-set {
            left: 200px;
            width: 45px;
            height: 30px;
        }

        .tea-cup {
            position: absolute;
            bottom: 0;
            left: 0;
            width: 16px;
            height: 14px;
            background: linear-gradient(180deg, #ecf0f1, #bdc3c7);
            border-radius: 2px 2px 5px 5px;
            box-shadow: 1px 1px 3px rgba(0, 0, 0, 0.2);
        }

        .tea-cup::before {
            content: '';
            position: absolute;
            right: -5px;
            top: 3px;
            width: 5px;
            height: 7px;
            border: 1px solid #bdc3c7;
            border-left: none;
            border-radius: 0 4px 4px 0;
        }

        .tea-cup-small {
            position: absolute;
            bottom: 2px;
            left: 22px;
            width: 12px;
            height: 10px;
            background: linear-gradient(180deg, #ecf0f1, #bdc3c7);
            border-radius: 2px 2px 4px 4px;
            box-shadow: 1px 1px 2px rgba(0, 0, 0, 0.2);
        }

        .tea-saucer {
            position: absolute;
            bottom: -2px;
            left: 5px;
            width: 24px;
            height: 4px;
            background: linear-gradient(180deg, #ecf0f1, #bdc3c7);
            border-radius: 50%;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
        }

        /* 小摆件 - 装饰画 */
        .mini-frame {
            right: 200px;
            top: 80px;
            width: 35px;
            height: 45px;
            background: linear-gradient(145deg, #ffeaa7, #fdcb6e);
            border: 3px solid #8b4513;
            border-radius: 2px;
            box-shadow: 2px 3px 8px rgba(0, 0, 0, 0.3);
        }

        .mini-frame::before {
            content: '';
            position: absolute;
            top: 5px;
            left: 5px;
            right: 5px;
            bottom: 5px;
            background: linear-gradient(180deg, #74b9ff 0%, #a29bfe 50%, #55efc4 100%);
        }

        /* 小摆件 - 仙人掌 */
        .cactus {
            left: 250px;
            width: 20px;
            height: 40px;
        }

        .cactus-pot {
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 16px;
            height: 14px;
            background: linear-gradient(180deg, #d35400, #a04000);
            border-radius: 2px 2px 4px 4px;
        }

        .cactus-body {
            position: absolute;
            bottom: 12px;
            left: 50%;
            transform: translateX(-50%);
            width: 10px;
            height: 22px;
            background: linear-gradient(90deg, #27ae60, #2ecc71, #27ae60);
            border-radius: 5px 5px 3px 3px;
            box-shadow: inset -2px 0 4px rgba(0, 0, 0, 0.1);
        }

        .cactus-arm {
            position: absolute;
            width: 6px;
            height: 10px;
            background: linear-gradient(90deg, #27ae60, #2ecc71);
            border-radius: 3px;
        }

        .cactus-arm:nth-child(1) {
            top: 6px;
            left: 0;
            transform: rotate(30deg);
        }

        .cactus-arm:nth-child(2) {
            top: 10px;
            right: 0;
            transform: rotate(-30deg);
        }

        /* ========== 墙壁挂件 ========== */
        
        /* ========== 赛博朋克圆环指针时钟 ========== */
        .cyber-analog-clock {
            left: 10px;
            top: 210px;
            width: 100px;
            height: 100px;
            position: relative;
        }

        /* 外圈发光环 */
        .cyber-clock-outer {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            border-radius: 50%;
            background: conic-gradient(
                from 0deg,
                var(--primary-holo) 0deg,
                var(--secondary-holo) 90deg,
                var(--accent-cyber) 180deg,
                var(--primary-holo) 270deg,
                var(--primary-holo) 360deg
            );
            opacity: 0.6;
            animation: rotateRing 10s linear infinite;
        }

        @keyframes rotateRing {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }

        /* 时钟主体 */
        .cyber-clock-face {
            position: absolute;
            top: 4px;
            left: 4px;
            right: 4px;
            bottom: 4px;
            background: linear-gradient(145deg, rgba(10, 11, 26, 0.98) 0%, rgba(15, 20, 40, 0.98) 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 
                inset 0 0 20px rgba(var(--primary-holo-rgb), 0.2),
                0 0 30px rgba(var(--primary-holo-rgb), 0.3);
        }

        /* 刻度圆环 */
        .cyber-clock-ticks {
            position: absolute;
            width: 100%;
            height: 100%;
        }

        .cyber-tick {
            position: absolute;
            width: 2px;
            height: 6px;
            background: rgba(var(--primary-holo-rgb), 0.5);
            left: 50%;
            top: 6px;
            transform-origin: center 44px;
            border-radius: 1px;
        }

        .cyber-tick.major {
            width: 3px;
            height: 8px;
            background: var(--primary-holo);
            box-shadow: 0 0 5px var(--primary-holo);
        }

        /* 数字显示 */
        .cyber-clock-number {
            position: absolute;
            font-size: 8px;
            color: var(--primary-holo);
            font-weight: bold;
            text-shadow: 0 0 5px var(--primary-holo);
            font-family: 'Orbitron', monospace;
        }

        /* 中心发光点 */
        .cyber-clock-center {
            position: absolute;
            width: 10px;
            height: 10px;
            background: radial-gradient(circle, var(--primary-holo) 0%, transparent 70%);
            border-radius: 50%;
            z-index: 10;
            box-shadow: 0 0 15px var(--primary-holo);
        }

        /* 指针容器 */
        .cyber-hands {
            position: absolute;
            width: 100%;
            height: 100%;
        }

        /* 时针 */
        .cyber-hand-hour {
            position: absolute;
            top: 50%;
            left: 50%;
            width: 4px;
            height: 25px;
            margin-left: -2px;
            margin-top: -25px;
            background: linear-gradient(to top, var(--primary-holo) 0%, rgba(var(--primary-holo-rgb), 0.3) 100%);
            transform-origin: 50% 100%;
            border-radius: 2px;
            box-shadow: 0 0 8px var(--primary-holo);
            z-index: 3;
        }

        /* 分针 */
        .cyber-hand-minute {
            position: absolute;
            top: 50%;
            left: 50%;
            width: 3px;
            height: 35px;
            margin-left: -1.5px;
            margin-top: -35px;
            background: linear-gradient(to top, var(--accent-cyber) 0%, rgba(var(--accent-cyber-rgb), 0.3) 100%);
            transform-origin: 50% 100%;
            border-radius: 2px;
            box-shadow: 0 0 8px var(--accent-cyber);
            z-index: 2;
        }

        /* 秒针 */
        .cyber-hand-second {
            position: absolute;
            top: 50%;
            left: 50%;
            width: 2px;
            height: 40px;
            margin-left: -1px;
            margin-top: -40px;
            background: linear-gradient(to top, #e74c3c 0%, rgba(231, 76, 60, 0.3) 100%);
            transform-origin: 50% 100%;
            border-radius: 1px;
            box-shadow: 0 0 10px #e74c3c;
            z-index: 4;
        }

        /* 秒针尾部 */
        .cyber-hand-second::after {
            content: '';
            position: absolute;
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%);
            width: 2px;
            height: 10px;
            background: #e74c3c;
            border-radius: 1px 1px 0 0;
        }

        /* 秒针尾部 */
        .cyber-hand-second::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 50%;
            transform: translateX(-50%);
            width: 2px;
            height: 8px;
            background: #e74c3c;
            border-radius: 0 0 1px 1px;
        }

        /* 装饰性圆环 */
        .cyber-ring-inner {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 60px;
            height: 60px;
            border: 1px solid rgba(var(--primary-holo-rgb), 0.2);
            border-radius: 50%;
        }

        .cyber-ring-outer {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 76px;
            height: 76px;
            border: 1px dashed rgba(var(--accent-cyber-rgb), 0.3);
            border-radius: 50%;
        }

        /* 墙上挂历 */
        .wall-calendar {
            left: 100px;
            top: 50px;
            width: 40px;
            height: 50px;
            background: linear-gradient(145deg, #fff, #f5f5f5);
            border: 2px solid #8b4513;
            border-radius: 3px;
            box-shadow: 2px 2px 6px rgba(0, 0, 0, 0.3);
        }

        .calendar-header {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 12px;
            background: #e74c3c;
            border-radius: 2px 2px 0 0;
        }

        .calendar-body {
            position: absolute;
            top: 14px;
            left: 5px;
            right: 5px;
            bottom: 5px;
            background: #fff;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        .calendar-month {
            font-size: 6px;
            color: #333;
            font-weight: bold;
        }

        .calendar-day {
            font-size: 14px;
            color: #e74c3c;
            font-weight: bold;
            line-height: 1;
        }

        /* 墙上装饰壁挂 */
        .wall-art-1 {
            right: 30px;
            top: 40px;
            width: 50px;
            height: 35px;
            background: linear-gradient(145deg, #2c3e50, #34495e);
            border: 3px solid #8b4513;
            border-radius: 3px;
            box-shadow: 2px 3px 8px rgba(0, 0, 0, 0.4);
        }

        .wall-art-1::before {
            content: '';
            position: absolute;
            top: 5px;
            left: 5px;
            right: 5px;
            bottom: 5px;
            background: linear-gradient(135deg, #3498db 25%, transparent 25%, transparent 50%, #3498db 50%, #3498db 75%, transparent 75%);
            background-size: 10px 10px;
            opacity: 0.6;
        }

        /* 墙上挂着的耳机 */
        .wall-headphones {
            left: 180px;
            top: 30px;
            width: 40px;
            height: 30px;
        }

        .headphone-band {
            position: absolute;
            top: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 30px;
            height: 20px;
            border: 3px solid #333;
            border-bottom: none;
            border-radius: 15px 15px 0 0;
        }

        .headphone-cup {
            position: absolute;
            bottom: 0;
            width: 10px;
            height: 14px;
            background: linear-gradient(180deg, #333, #222);
            border-radius: 3px;
        }

        .headphone-cup.left { left: 0; }
        .headphone-cup.right { right: 0; }

        /* 墙上装饰旗 */
        .wall-flag {
            left: 230px;
            top: 25px;
            width: 25px;
            height: 35px;
            background: linear-gradient(180deg, #e74c3c, #c0392b);
            border-radius: 2px;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
        }

        .wall-flag::before {
            content: '';
            position: absolute;
            top: -8px;
            left: 50%;
            transform: translateX(-50%);
            width: 2px;
            height: 10px;
            background: #8b4513;
        }

        .wall-flag::after {
            content: '';
            position: absolute;
            top: 5px;
            left: 3px;
            width: 10px;
            height: 10px;
            background: rgba(255, 255, 255, 0.3);
            clip-path: polygon(50% 0%, 100% 50%, 50% 100%, 0% 50%);
        }

        /* 墙上海报 */
        .wall-poster {
            right: 100px;
            top: 100px;
            width: 45px;
            height: 60px;
            background: linear-gradient(145deg, #2c3e50, #34495e);
            border: 2px solid #5d6d7e;
            border-radius: 2px;
            box-shadow: 2px 3px 8px rgba(0, 0, 0, 0.4);
        }

        .wall-poster::before {
            content: '';
            position: absolute;
            top: 8px;
            left: 8px;
            right: 8px;
            bottom: 15px;
            background: linear-gradient(180deg, #f39c12 0%, #e67e22 30%, #3498db 50%, #1abc9c 100%);
            border-radius: 2px;
        }

        .wall-poster::after {
            content: '海报';
            position: absolute;
            bottom: 4px;
            left: 50%;
            transform: translateX(-50%);
            font-size: 5px;
            color: #aaa;
        }

        /* 墙上挂历（第二个月历） */
        .wall-calendar-2 {
            left: 270px;
            top: 55px;
            width: 35px;
            height: 45px;
            background: linear-gradient(145deg, #fff, #ecf0f1);
            border: 2px solid #27ae60;
            border-radius: 2px;
            box-shadow: 2px 2px 6px rgba(0, 0, 0, 0.3);
        }

        .wall-calendar-2 .cal-header {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 10px;
            background: #27ae60;
            border-radius: 2px 2px 0 0;
        }

        .wall-calendar-2 .cal-body {
            position: absolute;
            top: 12px;
            left: 5px;
            right: 5px;
            bottom: 5px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        .wall-calendar-2 .cal-month {
            font-size: 5px;
            color: #333;
            font-weight: bold;
        }

        .wall-calendar-2 .cal-day {
            font-size: 12px;
            color: #e74c3c;
            font-weight: bold;
        }

        /* 墙上挂饰 - 星星月亮 */
        .wall-moon {
            left: 320px;
            top: 15px;
            width: 30px;
            height: 30px;
        }

        .moon-circle {
            position: absolute;
            top: 0;
            left: 0;
            width: 25px;
            height: 25px;
            background: linear-gradient(135deg, #f1c40f, #f39c12);
            border-radius: 50%;
            box-shadow: 0 0 10px rgba(241, 196, 15, 0.5);
        }

        .moon-circle::before {
            content: '';
            position: absolute;
            top: 3px;
            left: 5px;
            width: 18px;
            height: 18px;
            background: #16213e;
            border-radius: 50%;
        }

        .moon-star {
            position: absolute;
            bottom: 0;
            right: 0;
            width: 0;
            height: 0;
            border-left: 6px solid transparent;
            border-right: 6px solid transparent;
            border-bottom: 10px solid #f1c40f;
            transform: rotate(15deg);
        }

        .moon-star::before {
            content: '';
            position: absolute;
            top: 3px;
            left: -3px;
            width: 0;
            height: 0;
            border-left: 3px solid transparent;
            border-right: 3px solid transparent;
            border-bottom: 5px solid #f1c40f;
        }

        /* 墙上相框（第二张） */
        .wall-frame {
            right: 160px;
            top: 45px;
            width: 30px;
            height: 40px;
            background: linear-gradient(145deg, #8b4513, #a0522d);
            border: 3px solid #5d4037;
            border-radius: 2px;
            box-shadow: 2px 3px 8px rgba(0, 0, 0, 0.4);
        }

        .wall-frame::before {
            content: '';
            position: absolute;
            top: 5px;
            left: 5px;
            right: 5px;
            bottom: 5px;
            background: linear-gradient(135deg, #74b9ff 0%, #a29bfe 50%, #fd79a8 100%);
        }

        /* ========== 桌面上的电脑 ========== */
        
        /* 笔记本电脑 */
        .laptop {
            right: 5px;
            bottom: 18px;
            width: 90px;
            height: 60px;
            z-index: 5;
        }

        .laptop-screen {
            position: absolute;
            top: 0;
            left: 5px;
            width: 80px;
            height: 50px;
            background: linear-gradient(145deg, #333, #222);
            border-radius: 5px 5px 0 0;
            border: 2px solid #444;
            overflow: hidden;
        }

        .screen-content {
            position: absolute;
            top: 3px;
            left: 3px;
            right: 3px;
            bottom: 3px;
            background: linear-gradient(180deg, #1a1a2e, #16213e);
        }

        .screen-content::before {
            content: '';
            position: absolute;
            top: 8px;
            left: 8px;
            width: 20px;
            height: 3px;
            background: rgba(0, 245, 255, 0.5);
            box-shadow: 0 8px 0 rgba(0, 245, 255, 0.3), 0 16px 0 rgba(0, 245, 255, 0.2);
        }

        .laptop-base {
            position: absolute;
            bottom: 0;
            left: 0;
            width: 90px;
            height: 8px;
            background: linear-gradient(180deg, #444, #333);
            border-radius: 0 0 5px 5px;
        }

        .laptop-base::before {
            content: '';
            position: absolute;
            top: 2px;
            left: 10px;
            right: 10px;
            height: 2px;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
        }

        /* 桌面上的手机 */
        .smartphone {
            left: 280px;
            bottom: 18px;
            width: 28px;
            height: 50px;
            z-index: 5;
        }

        .phone-body {
            position: absolute;
            top: 0;
            left: 0;
            width: 28px;
            height: 50px;
            background: linear-gradient(145deg, #2c3e50, #1a252f);
            border-radius: 4px;
            border: 2px solid #34495e;
            box-shadow: 2px 2px 6px rgba(0, 0, 0, 0.4);
        }

        .phone-screen {
            position: absolute;
            top: 5px;
            left: 3px;
            right: 3px;
            height: 35px;
            background: linear-gradient(180deg, #1a1a2e, #0a0b1a);
            border-radius: 2px;
            overflow: hidden;
        }

        .phone-screen::before {
            content: '';
            position: absolute;
            top: 5px;
            left: 3px;
            width: 12px;
            height: 2px;
            background: rgba(0, 245, 255, 0.4);
            box-shadow: 0 6px 0 rgba(0, 255, 157, 0.3), 0 12px 0 rgba(138, 43, 226, 0.2);
        }

        .phone-button {
            position: absolute;
            bottom: 3px;
            left: 50%;
            transform: translateX(-50%);
            width: 6px;
            height: 6px;
            background: #444;
            border-radius: 50%;
        }

        .phone-speaker {
            position: absolute;
            top: 2px;
            left: 50%;
            transform: translateX(-50%);
            width: 8px;
            height: 2px;
            background: #333;
            border-radius: 1px;
        }

        /* 桌面音箱 */
        .desktop-speaker {
            left: 320px;
            bottom: 18px;
            width: 22px;
            height: 45px;
            z-index: 5;
        }

        .speaker-body {
            position: absolute;
            bottom: 0;
            left: 0;
            width: 22px;
            height: 40px;
            background: linear-gradient(180deg, #333, #222);
            border-radius: 4px;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.4);
        }

        .speaker-grille {
            position: absolute;
            top: 5px;
            left: 3px;
            right: 3px;
            height: 30px;
            background: repeating-linear-gradient(
                0deg,
                #222 0px,
                #222 2px,
                #444 2px,
                #444 4px
            );
            border-radius: 2px;
        }

        .speaker-led {
            position: absolute;
            top: 3px;
            right: 3px;
            width: 4px;
            height: 4px;
            background: #00ff9d;
            border-radius: 50%;
            box-shadow: 0 0 5px #00ff9d;
            animation: ledBlink 1.5s infinite;
        }

        @keyframes ledBlink {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.4; }
        }

        /* 桌面鼠标 */
        .desktop-mouse {
            left: 300px;
            bottom: 18px;
            width: 18px;
            height: 28px;
            z-index: 5;
        }

        .mouse-body {
            position: absolute;
            bottom: 0;
            left: 0;
            width: 18px;
            height: 24px;
            background: linear-gradient(145deg, #333, #222);
            border-radius: 9px 9px 6px 6px;
            box-shadow: 1px 2px 4px rgba(0, 0, 0, 0.4);
        }

        .mouse-wheel {
            position: absolute;
            top: 5px;
            left: 50%;
            transform: translateX(-50%);
            width: 4px;
            height: 8px;
            background: #444;
            border-radius: 2px;
        }

        .mouse-line {
            position: absolute;
            bottom: 8px;
            left: 50%;
            width: 1px;
            height: 15px;
            background: #333;
        }

        /* 桌面键盘 */
        .desktop-keyboard {
            left: 55px;
            bottom: 18px;
            width: 70px;
            height: 25px;
            z-index: 5;
        }

        .keyboard-body {
            position: absolute;
            bottom: 0;
            left: 0;
            width: 70px;
            height: 22px;
            background: linear-gradient(180deg, #333, #2a2a2a);
            border-radius: 3px;
            box-shadow: 1px 2px 5px rgba(0, 0, 0, 0.4);
            padding: 3px;
        }

        .keyboard-keys {
            width: 100%;
            height: 100%;
            background: repeating-linear-gradient(
                90deg,
                #222 0px,
                #222 6px,
                #333 6px,
                #333 8px
            );
            border-radius: 2px;
            opacity: 0.7;
        }

        /* 桌面马克杯（带logo） */
        .desk-mug {
            left: 145px;
            bottom: 18px;
            width: 26px;
            height: 32px;
            z-index: 5;
        }

        .mug-body {
            position: absolute;
            bottom: 0;
            left: 0;
            width: 22px;
            height: 26px;
            background: linear-gradient(180deg, #ecf0f1, #bdc3c7);
            border-radius: 3px 3px 8px 8px;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
        }

        .mug-handle {
            position: absolute;
            bottom: 6px;
            right: 0;
            width: 8px;
            height: 14px;
            border: 3px solid #bdc3c7;
            border-left: none;
            border-radius: 0 8px 8px 0;
        }

        .mug-logo {
            position: absolute;
            top: 8px;
            left: 4px;
            width: 10px;
            height: 10px;
            background: #e74c3c;
            border-radius: 50%;
        }

        /* 桌面时钟/闹铃 */
        .desk-alarm {
            right: 105px;
            bottom: 18px;
            width: 30px;
            height: 35px;
            z-index: 5;
        }

        .alarm-body {
            position: absolute;
            bottom: 0;
            left: 0;
            width: 30px;
            height: 28px;
            background: linear-gradient(145deg, #f39c12, #d68910);
            border-radius: 5px;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
        }

        .alarm-face {
            position: absolute;
            top: 4px;
            left: 50%;
            transform: translateX(-50%);
            width: 18px;
            height: 18px;
            background: #fff;
            border-radius: 50%;
        }

        .alarm-bell {
            position: absolute;
            top: 0;
            width: 8px;
            height: 8px;
            background: #f39c12;
            border-radius: 50%;
        }

        .alarm-bell.left { left: 3px; }
        .alarm-bell.right { right: 3px; }

        /* 桌面书本立架 */
        .book-stand {
            left: 10px;
            bottom: 18px;
            width: 40px;
            height: 35px;
            z-index: 4;
        }

        .stand-base {
            position: absolute;
            bottom: 0;
            left: 0;
            width: 40px;
            height: 5px;
            background: linear-gradient(180deg, #8b4513, #654321);
            border-radius: 2px;
        }

        .stand-back {
            position: absolute;
            bottom: 4px;
            left: 5px;
            width: 30px;
            height: 28px;
            background: linear-gradient(180deg, #a0522d, #8b4513);
            transform: skewX(-10deg);
            border-radius: 2px;
        }

        .stand-front {
            position: absolute;
            bottom: 4px;
            left: 8px;
            width: 25px;
            height: 22px;
            background: linear-gradient(180deg, #deb887, #d2b48c);
            transform: skewX(5deg);
            border-radius: 2px;
        }

        /* 手办/玩偶摆件 */
        .figure-doll {
            left: 390px;
            bottom: 18px;
            width: 25px;
            height: 45px;
            z-index: 6;
        }

        .figure-head {
            position: absolute;
            top: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 16px;
            height: 16px;
            background: linear-gradient(145deg, #ffeaa7, #fdcb6e);
            border-radius: 50% 50% 45% 45%;
        }

        .figure-body {
            position: absolute;
            top: 14px;
            left: 50%;
            transform: translateX(-50%);
            width: 18px;
            height: 18px;
            background: linear-gradient(145deg, #e94560, #c0392b);
            border-radius: 4px;
        }

        .figure-legs {
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 16px;
            height: 14px;
            display: flex;
            justify-content: space-between;
        }

        .figure-leg {
            width: 6px;
            height: 14px;
            background: linear-gradient(180deg, #2c3e50, #34495e);
            border-radius: 2px;
        }

        /* 奖杯摆件 */
        .trophy {
            left: 420px;
            bottom: 18px;
            width: 30px;
            height: 50px;
            z-index: 6;
        }

        .trophy-cup {
            position: absolute;
            top: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 24px;
            height: 28px;
            background: linear-gradient(180deg, #f1c40f, #f39c12, #e67e22);
            border-radius: 3px 3px 8px 8px;
            box-shadow: inset -3px 0 8px rgba(0, 0, 0, 0.2);
        }

        .trophy-cup::before {
            content: '';
            position: absolute;
            top: -4px;
            left: 50%;
            transform: translateX(-50%);
            width: 28px;
            height: 6px;
            background: linear-gradient(180deg, #f1c40f, #e67e22);
            border-radius: 3px;
        }

        .trophy-handle {
            position: absolute;
            top: 5px;
            width: 6px;
            height: 15px;
            border: 3px solid #f39c12;
            border-left: none;
            border-radius: 0 8px 8px 0;
        }

        .trophy-handle.left {
            left: -4px;
            border-right: none;
            border-left: 3px solid #f39c12;
            border-radius: 8px 0 0 8px;
        }

        .trophy-handle.right {
            right: -4px;
        }

        .trophy-stem {
            position: absolute;
            bottom: 12px;
            left: 50%;
            transform: translateX(-50%);
            width: 6px;
            height: 10px;
            background: linear-gradient(90deg, #f39c12, #f1c40f, #f39c12);
        }

        .trophy-base {
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 22px;
            height: 12px;
            background: linear-gradient(180deg, #34495e, #2c3e50);
            border-radius: 2px;
        }

        /* 计算器摆件 */
        .calculator {
            left: 360px;
            bottom: 18px;
            width: 22px;
            height: 32px;
            background: linear-gradient(145deg, #2c3e50, #1a252f);
            border-radius: 3px;
            border: 1px solid #34495e;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
            z-index: 5;
        }

        .calc-screen {
            position: absolute;
            top: 4px;
            left: 3px;
            width: 16px;
            height: 8px;
            background: #98d8c8;
            border-radius: 2px;
        }

        .calc-buttons {
            position: absolute;
            top: 14px;
            left: 3px;
            width: 16px;
            height: 16px;
            background: repeating-linear-gradient(
                0deg,
                #34495e 0px,
                #34495e 3px,
                #2c3e50 3px,
                #2c3e50 4px
            );
        }

        /* 名片夹 */
        .business-card-holder {
            left: 225px;
            bottom: 18px;
            width: 30px;
            height: 22px;
            background: linear-gradient(145deg, #34495e, #2c3e50);
            border-radius: 2px;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
            z-index: 5;
        }

        .business-card-holder::before {
            content: '';
            position: absolute;
            top: 2px;
            left: 2px;
            width: 26px;
            height: 16px;
            background: linear-gradient(180deg, #ecf0f1, #bdc3c7);
            border-radius: 1px;
        }

        .business-card-holder::after {
            content: '';
            position: absolute;
            top: 4px;
            left: 4px;
            width: 22px;
            height: 2px;
            background: #7f8c8d;
        }

        /* 耳机支架 */
        .headphone-stand {
            left: 5px;
            bottom: 18px;
            width: 18px;
            height: 50px;
            z-index: 5;
        }

        .headphone-stand-base {
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 24px;
            height: 5px;
            background: linear-gradient(90deg, #333, #555, #333);
            border-radius: 3px;
        }

        .headphone-stand-pole {
            position: absolute;
            bottom: 4px;
            left: 50%;
            transform: translateX(-50%);
            width: 6px;
            height: 35px;
            background: linear-gradient(90deg, #444, #666, #444);
            border-radius: 2px;
        }

        .headphone-stand-hook {
            position: absolute;
            top: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 14px;
            height: 18px;
            border: 3px solid #555;
            border-bottom: none;
            border-radius: 10px 10px 0 0;
        }

        /* 仙人掌盆栽（第二盆） */
        .mini-cactus {
            right: 55px;
            bottom: 18px;
            width: 18px;
            height: 35px;
            z-index: 5;
        }

        .mini-cactus-pot {
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 14px;
            height: 12px;
            background: linear-gradient(180deg, #e74c3c, #c0392b);
            border-radius: 2px 2px 4px 4px;
        }

        .mini-cactus-body {
            position: absolute;
            bottom: 10px;
            left: 50%;
            transform: translateX(-50%);
            width: 8px;
            height: 18px;
            background: linear-gradient(90deg, #27ae60, #2ecc71, #27ae60);
            border-radius: 4px 4px 2px 2px;
        }

        /* 磁带摆件 */
        .cassette-tape {
            right: 155px;
            bottom: 18px;
            width: 35px;
            height: 24px;
            background: linear-gradient(145deg, #2c3e50, #34495e);
            border-radius: 3px;
            border: 1px solid #5d6d7e;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
            z-index: 5;
        }

        .cassette-tape::before {
            content: '';
            position: absolute;
            top: 5px;
            left: 5px;
            width: 12px;
            height: 12px;
            background: #1a1a2e;
            border-radius: 50%;
            border: 2px solid #7f8c8d;
        }

        .cassette-tape::after {
            content: '';
            position: absolute;
            top: 5px;
            right: 5px;
            width: 12px;
            height: 12px;
            background: #1a1a2e;
            border-radius: 50%;
            border: 2px solid #7f8c8d;
        }

        .cassette-label {
            position: absolute;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            width: 20px;
            height: 3px;
            background: #e74c3c;
            border-radius: 1px;
        }

        /* 耳机（第二副） */
        .desktop-headphones {
            left: 240px;
            bottom: 18px;
            width: 35px;
            height: 30px;
            z-index: 5;
        }

        .desktop-headphones .dh-band {
            position: absolute;
            top: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 25px;
            height: 15px;
            border: 3px solid #e94560;
            border-bottom: none;
            border-radius: 12px 12px 0 0;
        }

        .desktop-headphones .dh-cup {
            position: absolute;
            bottom: 0;
            width: 12px;
            height: 18px;
            background: linear-gradient(145deg, #e94560, #c0392b);
            border-radius: 4px;
        }

        .desktop-headphones .dh-cup.left { left: 0; }
        .desktop-headphones .dh-cup.right { right: 0; }

        /* ========== 台灯和拉绳开关组合（同一竖线） ========== */
        .lamp-string-container {
            position: absolute;
            bottom: 18px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            flex-direction: column;
            align-items: center;
            z-index: 8;
        }

        /* 拉绳开关（位于台灯后方同一竖线） */
        .pull-string {
            position: absolute;
            top: -180px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            flex-direction: column;
            align-items: center;
            z-index: 20;
            cursor: pointer;
        }

        /* 开关底座 */
        .string-switch {
            width: 28px;
            height: 38px;
            background: linear-gradient(180deg, #4a4a6a, #2a2a4a);
            border-radius: 6px 6px 4px 4px;
            border: 1px solid rgba(var(--primary-holo-rgb), 0.3);
            box-shadow: 
                0 3px 10px rgba(0, 0, 0, 0.4),
                inset 0 1px 3px rgba(255, 255, 255, 0.1);
            display: flex;
            justify-content: center;
            align-items: flex-start;
            padding-top: 6px;
        }

        /* 开关指示灯 */
        .switch-indicator {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #444;
            box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.5);
            transition: all 0.3s ease;
        }

        .switch-indicator.on {
            background: var(--primary-holo);
            box-shadow: 0 0 8px var(--primary-holo), 0 0 15px rgba(var(--primary-holo-rgb), 0.5);
        }

        /* 拉绳 */
        .string-line {
            width: 2px;
            height: 60px;
            background: linear-gradient(180deg, #666, #888);
            border-radius: 1px;
            position: relative;
            transform-origin: top center;
            transition: transform 0.3s ease;
        }

        /* 拉绳开关把手 */
        .string-handle {
            position: absolute;
            bottom: -12px;
            left: 50%;
            transform: translateX(-50%);
            width: 14px;
            height: 18px;
            background: linear-gradient(180deg, #e74c3c, #c0392b);
            border-radius: 3px 3px 5px 5px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.3);
            transition: transform 0.3s ease;
        }

        .pull-string:active .string-line {
            transform: rotate(12deg) scaleY(1.1);
        }

        .pull-string:active .string-handle {
            transform: translateX(-50%) translateY(8px);
        }

        /* ========== 台灯样式（放在书本上） ========== */
        .lamp-area {
            width: 100px;
            height: 180px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        /* 灯罩 - 经典半圆形台灯 */
        .lamp-shade {
            position: relative;
            width: 100px;
            height: 70px;
            background: linear-gradient(180deg, 
                rgba(var(--primary-holo-rgb), 0.3) 0%, 
                rgba(var(--secondary-holo-rgb), 0.2) 100%);
            border-radius: 50px 50px 8px 8px;
            box-shadow: 
                0 8px 30px rgba(0, 0, 0, 0.4),
                inset 0 -10px 20px rgba(0, 0, 0, 0.3);
            transition: all 0.5s ease;
            border: 1px solid rgba(var(--primary-holo-rgb), 0.3);
            z-index: 2;
        }

        .lamp-shade.on {
            background: linear-gradient(180deg, 
                rgba(var(--primary-holo-rgb), 0.5) 0%, 
                rgba(var(--secondary-holo-rgb), 0.4) 100%);
            box-shadow: 
                0 8px 30px rgba(0, 0, 0, 0.4),
                inset 0 -10px 20px rgba(0, 0, 0, 0.2),
                0 0 50px rgba(var(--primary-holo-rgb), 0.6);
        }

        /* 灯罩内部发光 */
        .lamp-shade::after {
            content: '';
            position: absolute;
            bottom: 8px;
            left: 50%;
            transform: translateX(-50%);
            width: 60px;
            height: 35px;
            background: radial-gradient(ellipse, 
                rgba(255, 255, 255, 0.1) 0%, 
                rgba(var(--primary-holo-rgb), 0.2) 50%, 
                transparent 70%);
            border-radius: 50%;
            filter: blur(2px);
            transition: all 0.5s ease;
        }

        .lamp-shade.on::after {
            background: radial-gradient(ellipse, 
                rgba(255, 255, 255, 0.7) 0%, 
                rgba(var(--primary-holo-rgb), 0.8) 50%, 
                transparent 70%);
            box-shadow: 0 0 20px rgba(var(--primary-holo-rgb), 0.5);
        }

        /* 灯罩边缘发光 */
        .lamp-shade::before {
            content: '';
            position: absolute;
            top: -2px;
            left: -2px;
            right: -2px;
            bottom: -2px;
            border-radius: 52px 52px 10px 10px;
            background: linear-gradient(180deg, var(--primary-holo), var(--secondary-holo));
            opacity: 0;
            z-index: -1;
            filter: blur(8px);
            transition: opacity 0.5s ease;
        }

        .lamp-shade.on::before {
            opacity: 0.4;
        }

        /* 灯臂连接 */
        .lamp-arm {
            position: relative;
            width: 8px;
            height: 50px;
            background: linear-gradient(90deg, 
                #2a2f4a 0%, 
                #4a5070 30%,
                #5a6080 50%,
                #4a5070 70%,
                #2a2f4a 100%);
            border-radius: 4px;
            margin: -5px 0;
            box-shadow: inset 0 0 8px rgba(0, 0, 0, 0.5);
        }

        /* 关节装饰 */
        .lamp-joint {
            width: 14px;
            height: 14px;
            background: linear-gradient(145deg, #3a3f5c, #2d3748);
            border-radius: 50%;
            border: 1px solid rgba(var(--primary-holo-rgb), 0.3);
            box-shadow: 0 0 8px rgba(var(--primary-holo-rgb), 0.2);
            position: absolute;
            top: 45px;
            left: 50%;
            transform: translateX(-50%);
            z-index: 3;
        }

        /* 灯杆 */
        .lamp-pole {
            width: 10px;
            height: 60px;
            background: linear-gradient(90deg, 
                #2a2f4a 0%, 
                #4a5070 30%,
                #5a6080 50%,
                #4a5070 70%,
                #2a2f4a 100%);
            border-radius: 5px;
            box-shadow: inset 0 0 8px rgba(0, 0, 0, 0.5);
        }

        /* 灯座底座 */
        .lamp-base {
            width: 70px;
            height: 12px;
            background: linear-gradient(180deg, 
                #3a3f5c 0%, 
                #2a2f4a 50%,
                #1a1f3a 100%);
            border-radius: 6px;
            box-shadow: 
                0 4px 10px rgba(0, 0, 0, 0.5),
                inset 0 1px 2px rgba(255, 255, 255, 0.1);
            margin-top: -2px;
        }

        /* 灯光效果 - 向下照射照亮书本 */
        .lamp-light {
            position: absolute;
            top: 130px;
            left: 50%;
            transform: translateX(-50%);
            width: 0;
            height: 0;
            border-left: 50px solid transparent;
            border-right: 50px solid transparent;
            border-top: 100px solid transparent;
            filter: blur(15px);
            transition: all 0.6s ease;
            pointer-events: none;
            z-index: 1;
            opacity: 0;
        }

        .lamp-light.on {
            opacity: 1;
            border-top-color: rgba(255, 248, 220, 0.3);
            box-shadow: 0 0 40px rgba(var(--primary-holo-rgb), 0.3);
        }

        /* 提示文字 */
        .hint-text {
            position: absolute;
            bottom: -35px;
            left: 50%;
            transform: translateX(-50%);
            color: var(--primary-holo);
            font-size: 11px;
            white-space: nowrap;
            opacity: 0.7;
            text-shadow: 0 0 10px rgba(var(--primary-holo-rgb), 0.5);
            letter-spacing: 1px;
        }

        /* ========== 登录表单区域 ========== */
        .login-area {
            position: relative;
        }

        /* 科技感玻璃卡片 */
        .login-card {
            width: 380px;
            background: rgba(15, 20, 40, 0.85);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(var(--primary-holo-rgb), 0.25);
            border-radius: 24px;
            padding: 40px;
            opacity: 0;
            transform: translateY(30px) scale(0.95);
            transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 0 0 rgba(var(--primary-holo-rgb), 0);
            position: relative;
            overflow: hidden;
        }

        /* 卡片发光边框 */
        .login-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            border-radius: 24px;
            padding: 1px;
            background: linear-gradient(135deg, 
                rgba(var(--primary-holo-rgb), 0.3),
                transparent,
                rgba(var(--secondary-holo-rgb), 0.2));
            -webkit-mask: 
                linear-gradient(#fff 0 0) content-box, 
                linear-gradient(#fff 0 0);
            -webkit-mask-composite: xor;
            mask-composite: exclude;
            pointer-events: none;
        }

        .login-card.show {
            opacity: 1;
            transform: translateY(0) scale(1);
            box-shadow: 0 0 60px rgba(var(--primary-holo-rgb), 0.3), 
                        inset 0 0 30px rgba(var(--primary-holo-rgb), 0.05);
        }

        .login-title {
            text-align: center;
            margin-bottom: 35px;
        }

        .login-title h1 {
            font-size: 2rem;
            font-weight: 700;
            color: var(--text-holo);
            margin-bottom: 8px;
            letter-spacing: 3px;
            text-shadow: 0 0 20px rgba(var(--primary-holo-rgb), 0.8),
                         0 0 40px rgba(var(--primary-holo-rgb), 0.6),
                         0 0 60px rgba(var(--primary-holo-rgb), 0.4);
        }

        .login-title p {
            font-size: 0.85rem;
            color: var(--primary-holo);
            letter-spacing: 4px;
            font-weight: 600;
            text-shadow: 0 0 10px rgba(var(--primary-holo-rgb), 0.5);
        }

        .form-group {
            margin-bottom: 24px;
            position: relative;
        }

        /* 字段级错误提示 */
        .field-error {
            position: absolute;
            bottom: -18px;
            left: 0;
            color: var(--color-danger);
            font-size: 0.75rem;
            font-weight: 500;
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-5px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* 输入框错误状态 */
        .form-input.input-error {
            border-color: var(--color-danger) !important;
            box-shadow: 0 0 0 3px rgba(255, 107, 107, 0.2) !important;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            color: var(--primary-holo);
            font-size: 0.9rem;
            font-weight: 600;
            letter-spacing: 1px;
            text-transform: uppercase;
        }

        /* 科技感输入框 */
        .form-input {
            width: 100%;
            padding: 14px 18px;
            background: rgba(var(--primary-holo-rgb), 0.05);
            border: 1px solid rgba(var(--primary-holo-rgb), 0.2);
            border-radius: 12px;
            color: var(--text-holo);
            font-size: 1rem;
            transition: var(--transition-quantum);
            font-family: inherit;
            -webkit-appearance: none;
            appearance: none;
        }

        /* select下拉框样式 */
        .form-input option {
            background: var(--bg-space);
            color: var(--text-holo);
            padding: 10px;
        }

        .form-input optgroup {
            background: var(--bg-space);
            color: var(--primary-holo);
            font-weight: bold;
        }

        .form-input::placeholder {
            color: var(--text-muted);
        }

        .form-input:focus {
            outline: none;
            border-color: var(--primary-holo);
            box-shadow: 0 0 0 3px rgba(var(--primary-holo-rgb), 0.15),
                        0 0 25px rgba(var(--primary-holo-rgb), 0.2);
            background: rgba(var(--primary-holo-rgb), 0.08);
        }

        /* 科技感按钮 */
        .login-btn {
            width: 100%;
            padding: 16px;
            background: linear-gradient(135deg, 
                rgba(var(--primary-holo-rgb), 0.2),
                rgba(var(--secondary-holo-rgb), 0.15));
            border: 1px solid rgba(var(--primary-holo-rgb), 0.4);
            border-radius: 12px;
            color: var(--primary-holo);
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            transition: var(--transition-quantum);
            margin-top: 10px;
            letter-spacing: 3px;
            text-transform: uppercase;
            position: relative;
            overflow: hidden;
            font-family: inherit;
        }

        .login-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, 
                transparent,
                rgba(var(--primary-holo-rgb), 0.3),
                transparent);
            transition: left 0.6s;
        }

        .login-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(var(--primary-holo-rgb), 0.4),
                        inset 0 1px 0 rgba(255, 255, 255, 0.1);
            border-color: var(--primary-holo);
            background: linear-gradient(135deg, 
                rgba(var(--primary-holo-rgb), 0.3),
                rgba(var(--secondary-holo-rgb), 0.25));
        }

        .login-btn:hover::before {
            left: 100%;
        }

        .login-btn:active {
            transform: translateY(0);
        }

        .forgot-password {
            text-align: center;
            margin-top: 20px;
        }

        .forgot-password a {
            color: var(--text-muted);
            font-size: 0.85rem;
            text-decoration: none;
            transition: color 0.3s ease;
            cursor: pointer;
        }

        .forgot-password a:hover {
            color: var(--primary-holo);
            text-shadow: 0 0 10px rgba(var(--primary-holo-rgb), 0.5);
        }

        /* ===== 找回密码面板 ===== */
        .forgot-pwd-panel {
            display: none;
            padding: 10px 0;
        }
        .forgot-pwd-panel.active {
            display: block;
            animation: fadeInSuccess 0.3s ease;
        }
        .forgot-pwd-panel .forgot-step-title {
            color: var(--text-holo);
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: 16px;
            text-align: center;
        }
        .forgot-pwd-panel .forgot-step-desc {
            color: var(--text-muted);
            font-size: 0.82rem;
            text-align: center;
            margin-bottom: 18px;
            line-height: 1.5;
        }
        .forgot-pwd-panel .form-group {
            margin-bottom: 16px;
        }
        .forgot-pwd-panel .form-label {
            display: block;
            color: var(--text-dim);
            font-size: 0.85rem;
            margin-bottom: 6px;
            font-weight: 500;
        }
        .forgot-pwd-panel .form-input {
            width: 100%;
            padding: 12px 14px;
            background: rgba(15, 20, 40, 0.6);
            border: 1px solid var(--ui-glass-border);
            border-radius: 10px;
            color: var(--text-holo);
            font-size: 0.95rem;
            transition: var(--transition-quantum);
            outline: none;
            box-sizing: border-box;
        }
        .forgot-pwd-panel .form-input:focus {
            border-color: var(--primary-holo);
            box-shadow: 0 0 15px rgba(var(--primary-holo-rgb), 0.2);
        }
        .forgot-pwd-panel .form-input::placeholder {
            color: var(--text-muted);
            font-size: 0.85rem;
        }
        .forgot-pwd-panel .code-row {
            display: flex;
            gap: 10px;
        }
        .forgot-pwd-panel .code-row .form-input {
            flex: 1;
        }
        .forgot-pwd-btn {
            width: 100%;
            padding: 13px;
            background: linear-gradient(135deg, var(--primary-holo), var(--secondary-holo));
            border: none;
            border-radius: 12px;
            color: var(--text-on-accent);
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition-quantum);
            position: relative;
            overflow: hidden;
            letter-spacing: 1px;
        }
        .forgot-pwd-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(var(--primary-holo-rgb), 0.35);
        }
        .forgot-pwd-btn:active {
            transform: translateY(0);
        }
        .forgot-pwd-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
            pointer-events: none;
        }
        .forgot-pwd-btn-secondary {
            background: transparent;
            border: 1px solid var(--ui-glass-border);
            color: var(--text-dim);
            font-size: 0.85rem;
            margin-top: 10px;
        }
        .forgot-pwd-btn-secondary:hover {
            border-color: var(--primary-holo);
            color: var(--primary-holo);
            box-shadow: none;
        }
        .forgot-pwd-countdown {
            color: var(--accent-cyber);
            font-size: 0.8rem;
            text-align: center;
            margin-top: 8px;
        }
        .forgot-pwd-back {
            display: block;
            text-align: center;
            color: var(--text-muted);
            font-size: 0.85rem;
            cursor: pointer;
            margin-top: 16px;
            text-decoration: none;
            transition: color 0.3s;
        }
        .forgot-pwd-back:hover {
            color: var(--primary-holo);
        }
        .forgot-pwd-error {
            background: rgba(255, 71, 87, 0.12);
            border: 1px solid rgba(255, 71, 87, 0.25);
            color: var(--color-danger);
            padding: 10px 14px;
            border-radius: 8px;
            margin-bottom: 14px;
            text-align: center;
            font-size: 0.85rem;
            display: none;
        }
        .forgot-pwd-error.show {
            display: block;
            animation: shakeError 0.4s ease;
        }
        .forgot-pwd-success {
            background: rgba(0, 255, 157, 0.12);
            border: 1px solid rgba(0, 255, 157, 0.25);
            color: var(--accent-cyber);
            padding: 10px 14px;
            border-radius: 8px;
            margin-bottom: 14px;
            text-align: center;
            font-size: 0.85rem;
            display: none;
        }
        .forgot-pwd-success.show {
            display: block;
            animation: fadeInSuccess 0.3s ease;
        }
        .forgot-pwd-panel .password-input-wrapper {
            position: relative;
        }
        .forgot-pwd-panel .toggle-password {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: var(--text-muted);
            cursor: pointer;
            padding: 4px;
            font-size: 1.1rem;
        }

        /* 错误提示 */
        .error-message {
            background: rgba(255, 71, 87, 0.15);
            border: 1px solid rgba(255, 71, 87, 0.3);
            color: var(--color-danger);
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 20px;
            text-align: center;
            font-size: 0.9rem;
            box-shadow: 0 0 15px rgba(255, 71, 87, 0.2);
            animation: shakeError 0.5s ease;
            display: none;
        }

        .error-message.show {
            display: block;
        }

        /* 成功提示 */
        .success-message {
            background: rgba(0, 255, 157, 0.15);
            border: 1px solid rgba(0, 255, 157, 0.3);
            color: var(--accent-cyber);
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 20px;
            text-align: center;
            font-size: 0.9rem;
            box-shadow: 0 0 15px rgba(0, 255, 157, 0.2);
            display: none;
        }

        .success-message.show {
            display: block;
            animation: fadeInSuccess 0.3s ease;
        }

        @keyframes shakeError {
            0%, 100% { transform: translateX(0); }
            20%, 60% { transform: translateX(-5px); }
            40%, 80% { transform: translateX(5px); }
        }

        @keyframes fadeInSuccess {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* 标签切换 */
        .tab-switch {
            display: flex;
            gap: 20px;
            margin-bottom: 30px;
            border-bottom: 2px solid rgba(var(--primary-holo-rgb), 0.2);
        }

        .tab-btn {
            flex: 1;
            padding: 12px;
            background: transparent;
            border: none;
            color: var(--text-muted);
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
            font-family: inherit;
            letter-spacing: 1px;
        }

        .tab-btn::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            width: 100%;
            height: 2px;
            background: var(--primary-holo);
            transform: scaleX(0);
            transition: transform 0.3s ease;
            box-shadow: 0 0 10px var(--primary-holo);
        }

        .tab-btn.active {
            color: var(--primary-holo);
        }

        .tab-btn.active::after {
            transform: scaleX(1);
        }

        .tab-btn:hover {
            color: var(--primary-holo);
        }

        /* 表单容器 */
        .form-container {
            display: none;
        }

        .form-container.active {
            display: block;
        }

        /* 注册表单紧凑样式 - 减小高度 */
        #registerForm .form-group {
            margin-bottom: 14px;
        }

        #registerForm .form-label {
            margin-bottom: 6px;
            font-size: 0.75rem;
        }

        #registerForm .form-input {
            padding: 10px 14px;
            font-size: 0.9rem;
        }

        #registerForm .login-btn {
            margin-top: 10px;
        }

        /* 响应式 */
        @media (max-width: 768px) {
            .container {
                flex-direction: column;
                gap: 40px;
            }

            .desk-scene {
                width: 320px;
                height: 400px;
            }

            .login-card {
                width: 320px;
                padding: 30px;
            }
        }

        /* 密码输入框包装器 */
        .password-input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .password-input-wrapper .form-input {
            width: 100%;
            padding-right: 45px;
        }

        .toggle-password {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            justify-content: center;
            width: 24px;
            height: 24px;
            transition: color 0.3s ease;
        }

        .toggle-password:hover {
            color: var(--primary-holo);
        }

        .toggle-password svg {
            width: 20px;
            height: 20px;
        }
        /* ══════════ 浅色主题 · 登录页全覆盖 ══════════ */
        html[data-theme$="-light"] body {
            background: var(--bg-space) !important;
        }
        /* ── 暗色背景装饰 dim ── */
        html[data-theme$="-light"] body::before {
            background:
                radial-gradient(circle at 20% 30%, rgba(var(--primary-holo-rgb), 0.04) 0%, transparent 50%),
                radial-gradient(circle at 80% 70%, rgba(var(--secondary-holo-rgb), 0.03) 0%, transparent 50%),
                linear-gradient(135deg, var(--bg-space) 0%, var(--ui-glass) 100%) !important;
            opacity: 1 !important;
        }
        html[data-theme$="-light"] body::after {
            background-image:
                linear-gradient(rgba(var(--primary-holo-rgb), 0.05) 1px, transparent 1px),
                linear-gradient(90deg, rgba(var(--primary-holo-rgb), 0.05) 1px, transparent 1px) !important;
            opacity: 0.4 !important;
        }
        /* ── 装饰场景 dimmed ── */
        html[data-theme$="-light"] .cyber-clock-outer { opacity: 0.15 !important; }
        /* ── 浅色墙面框架 ── */
        html[data-theme$="-light"] .wall-backdrop {
            background: 
                repeating-linear-gradient(0deg, transparent, transparent 59px, rgba(0,0,0,0.05) 59px, rgba(0,0,0,0.05) 60px),
                repeating-linear-gradient(90deg, transparent, transparent 79px, rgba(0,0,0,0.03) 79px, rgba(0,0,0,0.03) 80px),
                linear-gradient(180deg,
                    var(--bg-surface) 0%,
                    var(--bg-deep-space) 40%,
                    var(--bg-surface) 100%) !important;
            box-shadow: 
                inset 0 0 80px rgba(0,0,0,0.08),
                inset 0 2px 0 rgba(255,255,255,0.6),
                inset 0 -20px 30px rgba(0,0,0,0.06) !important;
        }
        html[data-theme$="-light"] .wall-backdrop::after {
            border-color: rgba(var(--text-holo-rgb), 0.16) !important;
            box-shadow: 0 0 0 1px rgba(var(--text-holo-rgb), 0.06), 0 0 15px rgba(var(--primary-holo-rgb), 0.10) !important;
        }
        html[data-theme$="-light"] .desk-surface {
            box-shadow: 0 5px 15px rgba(var(--primary-holo-rgb), 0.15), inset 0 2px 3px rgba(255, 255, 255, 0.15) !important;
        }
        /* ── 登录卡片 ── */
        html[data-theme$="-light"] .login-card {
            background: var(--ui-glass) !important;
            border-color: rgba(var(--primary-holo-rgb), 0.12) !important;
            box-shadow: 0 0 0 rgba(var(--primary-holo-rgb), 0) !important;
        }
        html[data-theme$="-light"] .login-card::before {
            background: linear-gradient(135deg, rgba(var(--primary-holo-rgb), 0.2), transparent, rgba(var(--secondary-holo-rgb), 0.12)) !important;
        }
        html[data-theme$="-light"] .login-card.show {
            box-shadow: 0 8px 40px rgba(var(--primary-holo-rgb), 0.15), inset 0 0 30px rgba(var(--primary-holo-rgb), 0.02) !important;
        }
        /* ── 标题 ── */
        html[data-theme$="-light"] .login-title h1 {
            color: var(--text-holo) !important;
            text-shadow: none !important;
        }
        html[data-theme$="-light"] .login-title p {
            color: var(--text-dim) !important;
            text-shadow: none !important;
        }
        /* ── 标签切换 ── */
        html[data-theme$="-light"] .tab-switch {
            border-bottom-color: rgba(var(--primary-holo-rgb), 0.1) !important;
        }
        html[data-theme$="-light"] .tab-btn {
            color: var(--text-dim) !important;
        }
        html[data-theme$="-light"] .tab-btn::after {
            background: var(--primary-holo) !important;
            box-shadow: 0 0 8px rgba(var(--primary-holo-rgb), 0.3) !important;
        }
        html[data-theme$="-light"] .tab-btn.active {
            color: var(--primary-holo) !important;
        }
        html[data-theme$="-light"] .tab-btn:hover {
            color: var(--text-holo) !important;
        }
        /* ── 表单 ── */
        html[data-theme$="-light"] .form-label {
            color: var(--text-dim) !important;
        }
        html[data-theme$="-light"] .form-input {
            background: var(--ui-glass) !important;
            border-color: rgba(var(--primary-holo-rgb), 0.1) !important;
            color: var(--text-holo) !important;
        }
        html[data-theme$="-light"] .form-input::placeholder {
            color: rgba(var(--text-holo-rgb), 0.3) !important;
        }
        html[data-theme$="-light"] .form-input:focus {
            border-color: rgba(var(--primary-holo-rgb), 0.3) !important;
            background: var(--bg-space) !important;
            box-shadow: 0 0 0 3px rgba(var(--primary-holo-rgb), 0.08), 0 0 20px rgba(var(--primary-holo-rgb), 0.06) !important;
        }
        html[data-theme$="-light"] .form-input.input-error {
            border-color: var(--color-danger) !important;
            box-shadow: 0 0 0 3px rgba(220, 38, 38, 0.1) !important;
        }
        html[data-theme$="-light"] .form-input option {
            background: var(--bg-space) !important;
            color: var(--text-holo) !important;
        }
        html[data-theme$="-light"] .form-input optgroup {
            background: var(--bg-space) !important;
            color: var(--text-dim) !important;
        }
        html[data-theme$="-light"] .field-error {
            color: var(--color-danger) !important;
        }
        /* ── 按钮 ── */
        html[data-theme$="-light"] .login-btn {
            background: linear-gradient(135deg, rgba(var(--primary-holo-rgb), 0.1), rgba(var(--secondary-holo-rgb), 0.06)) !important;
            border-color: rgba(var(--primary-holo-rgb), 0.2) !important;
            color: var(--primary-holo) !important;
        }
        html[data-theme$="-light"] .login-btn::before {
            background: linear-gradient(90deg, transparent, rgba(var(--primary-holo-rgb), 0.15), transparent) !important;
        }
        html[data-theme$="-light"] .login-btn:hover {
            background: linear-gradient(135deg, rgba(var(--primary-holo-rgb), 0.2), rgba(var(--secondary-holo-rgb), 0.12)) !important;
            border-color: var(--primary-holo) !important;
            box-shadow: 0 8px 25px rgba(var(--primary-holo-rgb), 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.3) !important;
        }
        /* ── 消息提示 ── */
        html[data-theme$="-light"] .error-message {
            background: rgba(220, 60, 60, 0.08) !important;
            border-color: rgba(220, 60, 60, 0.18) !important;
            color: var(--color-danger) !important;
            box-shadow: 0 0 12px rgba(220, 60, 60, 0.06) !important;
        }
        html[data-theme$="-light"] .success-message {
            background: rgba(5, 150, 105, 0.08) !important;
            border-color: rgba(5, 150, 105, 0.18) !important;
            color: var(--color-success) !important;
            box-shadow: 0 0 12px rgba(5, 150, 105, 0.06) !important;
        }
/* ── 忘记密码 ── */
html[data-theme$="-light"] .forgot-password a {
    color: var(--text-dim) !important;
}
html[data-theme$="-light"] .forgot-password a:hover {
    color: var(--primary-holo) !important;
    text-shadow: none !important;
}
html[data-theme$="-light"] .forgot-pwd-panel .form-input {
    background: var(--ui-glass) !important;
    border-color: rgba(var(--primary-holo-rgb), 0.15) !important;
    color: var(--text-holo) !important;
}
html[data-theme$="-light"] .forgot-pwd-panel .form-input:focus {
    border-color: var(--primary-holo) !important;
    box-shadow: 0 0 12px rgba(var(--primary-holo-rgb), 0.15) !important;
}
html[data-theme$="-light"] .forgot-pwd-panel .form-label {
    color: var(--text-dim) !important;
}
html[data-theme$="-light"] .forgot-pwd-panel .forgot-step-title {
    color: var(--text-holo) !important;
}
html[data-theme$="-light"] .forgot-pwd-panel .forgot-step-desc {
    color: var(--text-dim) !important;
}
html[data-theme$="-light"] .forgot-pwd-btn-secondary {
    border-color: rgba(var(--primary-holo-rgb), 0.15) !important;
    color: var(--text-dim) !important;
}
html[data-theme$="-light"] .forgot-pwd-btn-secondary:hover {
    border-color: var(--primary-holo) !important;
    color: var(--primary-holo) !important;
}
html[data-theme$="-light"] .forgot-pwd-back {
    color: var(--text-dim) !important;
}
html[data-theme$="-light"] .forgot-pwd-back:hover {
    color: var(--primary-holo) !important;
}
        /* ── 密码切换 ── */
        html[data-theme$="-light"] .toggle-password {
            color: var(--text-dim) !important;
        }
        html[data-theme$="-light"] .toggle-password:hover {
            color: var(--text-dim) !important;
        }
        /* ── 通用 ── */
        html[data-theme$="-light"] h1, html[data-theme$="-light"] h2 { color: var(--text-holo) !important; }
        html[data-theme$="-light"] ::selection { background: rgba(var(--primary-holo-rgb), 0.15) !important; color: var(--text-holo) !important; }
    </style>
</head>
<body>
    <div class="container">
        <!-- 桌面场景 -->
        <div class="desk-scene">
            <!-- 墙壁背景 -->
            <div class="wall-backdrop"></div>
            
            <!-- 赛博朋克圆环指针时钟 -->
            <div class="cyber-analog-clock" style="position: absolute; left: 10px; top: 210px;">
                <div class="cyber-clock-outer"></div>
                <div class="cyber-clock-face">
                    <div class="cyber-clock-ticks">
                        <div class="cyber-tick major" style="transform: rotate(0deg)"></div>
                        <div class="cyber-tick" style="transform: rotate(30deg)"></div>
                        <div class="cyber-tick" style="transform: rotate(60deg)"></div>
                        <div class="cyber-tick major" style="transform: rotate(90deg)"></div>
                        <div class="cyber-tick" style="transform: rotate(120deg)"></div>
                        <div class="cyber-tick" style="transform: rotate(150deg)"></div>
                        <div class="cyber-tick major" style="transform: rotate(180deg)"></div>
                        <div class="cyber-tick" style="transform: rotate(210deg)"></div>
                        <div class="cyber-tick" style="transform: rotate(240deg)"></div>
                        <div class="cyber-tick major" style="transform: rotate(270deg)"></div>
                        <div class="cyber-tick" style="transform: rotate(300deg)"></div>
                        <div class="cyber-tick" style="transform: rotate(330deg)"></div>
                    </div>
                    <div class="cyber-ring-inner"></div>
                    <div class="cyber-ring-outer"></div>
                    <div class="cyber-clock-number" style="top: 12px; left: 50%; transform: translateX(-50%);">12</div>
                    <div class="cyber-clock-number" style="top: 50%; right: 10px; transform: translateY(-50%);">3</div>
                    <div class="cyber-clock-number" style="bottom: 12px; left: 50%; transform: translateX(-50%);">6</div>
                    <div class="cyber-clock-number" style="top: 50%; left: 10px; transform: translateY(-50%);">9</div>
                    <div class="cyber-hands">
                        <div class="cyber-hand-hour" id="cyberHourHand"></div>
                        <div class="cyber-hand-minute" id="cyberMinuteHand"></div>
                        <div class="cyber-hand-second" id="cyberSecondHand"></div>
                    </div>
                    <div class="cyber-clock-center"></div>
                </div>
            </div>
            
            <!-- 墙上挂件 - 挂历 -->
            <div class="desk-decor wall-calendar">
                <div class="calendar-header"></div>
                <div class="calendar-body">
                    <span class="calendar-month" id="calendarMonth">APR</span>
                    <span class="calendar-day" id="calendarDay">14</span>
                </div>
            </div>
            
            <!-- 墙上挂件 - 装饰画 -->
            <div class="desk-decor wall-art-1"></div>
            
            <!-- 墙上挂件 - 耳机 -->
            <div class="desk-decor wall-headphones">
                <div class="headphone-band"></div>
                <div class="headphone-cup left"></div>
                <div class="headphone-cup right"></div>
            </div>
            
            <!-- 墙上挂件 - 装饰旗 -->
            <div class="desk-decor wall-flag"></div>
            
            <!-- 墙上挂件 - 海报 -->
            <div class="desk-decor wall-poster"></div>
            
            <!-- 墙上挂件 - 第二个月历 -->
            <div class="desk-decor wall-calendar-2">
                <div class="cal-header"></div>
                <div class="cal-body">
                    <span class="cal-month">MAY</span>
                    <span class="cal-day" id="calendar2Day">16</span>
                </div>
            </div>
            
            <!-- 墙上挂件 - 月亮星星 -->
            <div class="desk-decor wall-moon">
                <div class="moon-circle"></div>
                <div class="moon-star"></div>
            </div>
            
            <!-- 墙上挂件 - 相框 -->
            <div class="desk-decor wall-frame"></div>
            
            <!-- 灯光效果 - 首次进入时需要拉开关，后续自动显示 -->
            <%
                // 首次进入登录页面时，登录卡片隐藏；表单提交返回后直接显示
                Boolean loginShown = (Boolean) session.getAttribute("loginShown");
                String sessionSuccess = (String) session.getAttribute("success");
                boolean showLoginCard = loginShown != null 
                    || request.getAttribute("error") != null 
                    || request.getAttribute("success") != null
                    || sessionSuccess != null;
                if (loginShown == null && showLoginCard) {
                    session.setAttribute("loginShown", true);
                }
            %>
            <div class="lamp-light <%= showLoginCard ? "on" : "" %>" id="lampLight"></div>
            
            <!-- 小摆件 - 装饰画（挂在墙上） -->
            <div class="desk-decor mini-frame"></div>
            
            <!-- 台灯和拉绳开关组合（同一竖线） -->
            <div class="lamp-string-container">
                <!-- 拉绳开关（位于台灯后方同一竖线） -->
                <div class="pull-string" id="pullString">
                    <div class="string-switch">
                        <div class="switch-indicator <%= showLoginCard ? "on" : "" %>" id="switchIndicator"></div>
                    </div>
                    <div class="string-line">
                        <div class="string-handle"></div>
                    </div>
                </div>
                
                <!-- 台灯（放在书本上） -->
                <div class="lamp-area">
                    <!-- 灯罩 -->
                    <div class="lamp-shade <%= showLoginCard ? "on" : "" %>" id="lampShade"></div>
                    
                    <!-- 灯臂连接 -->
                    <div class="lamp-arm">
                        <div class="lamp-joint"></div>
                    </div>
                    
                    <!-- 灯杆 -->
                    <div class="lamp-pole"></div>
                    
                    <!-- 灯座底座 -->
                    <div class="lamp-base"></div>
                </div>
            </div>
            
            <!-- 打开的书本（位于台灯下方） -->
            <div class="open-book <%= showLoginCard ? "on" : "" %>" id="openBook">
                <div class="book-spine"></div>
                <div class="book-lines">
                    <div class="book-line"></div>
                    <div class="book-line"></div>
                    <div class="book-line"></div>
                    <div class="book-line"></div>
                </div>
            </div>
            
            <!-- 小摆件 - 咖啡杯 -->
            <div class="desk-decor coffee-cup">
                <div class="cup-body"></div>
                <div class="cup-handle"></div>
                <div class="cup-steam">
                    <div class="steam-line"></div>
                    <div class="steam-line"></div>
                    <div class="steam-line"></div>
                </div>
            </div>
            
            <!-- 小摆件 - 小盆栽 -->
            <div class="desk-decor potted-plant">
                <div class="plant-leaves">
                    <div class="leaf"></div>
                    <div class="leaf"></div>
                    <div class="leaf"></div>
                </div>
                <div class="plant-pot"></div>
            </div>
            
            <!-- 小摆件 - 笔筒 -->
            <div class="desk-decor pen-holder">
                <div class="holder-body">
                    <div class="pen"></div>
                    <div class="pen"></div>
                    <div class="pen"></div>
                </div>
            </div>
            
            <!-- 小摆件 - 便签 -->
            <div class="desk-decor sticky-note"></div>
            
            <!-- 小摆件 - 装饰球 -->
            <div class="desk-decor decor-ball"></div>
            
            <!-- 小摆件 - 地球仪 -->
            <div class="desk-decor globe">
                <div class="globe-sphere"></div>
                <div class="globe-stand"></div>
                <div class="globe-base"></div>
            </div>
            
            <!-- 小摆件 - 叠放的书 -->
            <div class="desk-decor stacked-books">
                <div class="stacked-book"></div>
                <div class="stacked-book"></div>
                <div class="stacked-book"></div>
            </div>
            
            <!-- 小摆件 - 茶杯组 -->
            <div class="desk-decor tea-set">
                <div class="tea-saucer"></div>
                <div class="tea-cup"></div>
                <div class="tea-cup-small"></div>
            </div>
            
            <!-- 小摆件 - 仙人掌 -->
            <div class="desk-decor cactus">
                <div class="cactus-body">
                    <div class="cactus-arm"></div>
                    <div class="cactus-arm"></div>
                </div>
                <div class="cactus-pot"></div>
            </div>
            
            <!-- 小摆件 - 照片框 -->
            <div class="desk-decor photo-frame"></div>
            
            <!-- 桌面物件 - 笔记本电脑 -->
            <div class="desk-decor laptop">
                <div class="laptop-screen">
                    <div class="screen-content"></div>
                </div>
                <div class="laptop-base"></div>
            </div>
            
            <!-- 桌面物件 - 手机 -->
            <div class="desk-decor smartphone">
                <div class="phone-body">
                    <div class="phone-speaker"></div>
                    <div class="phone-screen"></div>
                    <div class="phone-button"></div>
                </div>
            </div>
            
            <!-- 桌面物件 - 音箱 -->
            <div class="desk-decor desktop-speaker">
                <div class="speaker-body">
                    <div class="speaker-grille"></div>
                    <div class="speaker-led"></div>
                </div>
            </div>
            
            <!-- 桌面物件 - 键盘 -->
            <div class="desk-decor desktop-keyboard">
                <div class="keyboard-body">
                    <div class="keyboard-keys"></div>
                </div>
            </div>
            
            <!-- 桌面物件 - 鼠标 -->
            <div class="desk-decor desktop-mouse">
                <div class="mouse-body">
                    <div class="mouse-wheel"></div>
                </div>
                <div class="mouse-line"></div>
            </div>
            
            <!-- 桌面物件 - 马克杯 -->
            <div class="desk-decor desk-mug">
                <div class="mug-body">
                    <div class="mug-logo"></div>
                </div>
                <div class="mug-handle"></div>
            </div>
            
            <!-- 桌面物件 - 闹钟 -->
            <div class="desk-decor desk-alarm">
                <div class="alarm-body">
                    <div class="alarm-face"></div>
                </div>
                <div class="alarm-bell left"></div>
                <div class="alarm-bell right"></div>
            </div>
            
            <!-- 桌面物件 - 书本立架 -->
            <div class="desk-decor book-stand">
                <div class="stand-back"></div>
                <div class="stand-front"></div>
                <div class="stand-base"></div>
            </div>
            
            <!-- 桌面物件 - 手办 -->
            <div class="desk-decor figure-doll">
                <div class="figure-head"></div>
                <div class="figure-body"></div>
                <div class="figure-legs">
                    <div class="figure-leg"></div>
                    <div class="figure-leg"></div>
                </div>
            </div>
            
            <!-- 桌面物件 - 奖杯 -->
            <div class="desk-decor trophy">
                <div class="trophy-cup">
                    <div class="trophy-handle left"></div>
                    <div class="trophy-handle right"></div>
                </div>
                <div class="trophy-stem"></div>
                <div class="trophy-base"></div>
            </div>
            
            <!-- 桌面物件 - 计算器 -->
            <div class="desk-decor calculator">
                <div class="calc-screen"></div>
                <div class="calc-buttons"></div>
            </div>
            
            <!-- 桌面物件 - 名片夹 -->
            <div class="desk-decor business-card-holder"></div>
            
            <!-- 桌面物件 - 耳机支架 -->
            <div class="desk-decor headphone-stand">
                <div class="headphone-stand-hook"></div>
                <div class="headphone-stand-pole"></div>
                <div class="headphone-stand-base"></div>
            </div>
            
            <!-- 桌面物件 - 小仙人掌 -->
            <div class="desk-decor mini-cactus">
                <div class="mini-cactus-body"></div>
                <div class="mini-cactus-pot"></div>
            </div>
            
            <!-- 桌面物件 - 磁带 -->
            <div class="desk-decor cassette-tape">
                <div class="cassette-label"></div>
            </div>
            
            <!-- 桌面物件 - 耳机 -->
            <div class="desk-decor desktop-headphones">
                <div class="dh-band"></div>
                <div class="dh-cup left"></div>
                <div class="dh-cup right"></div>
            </div>
            
            <!-- 桌面 -->
            <div class="desk-surface"></div>
            
            <div class="hint-text">👆 拉动灯绳开启书房的灯</div>
        </div>

        <!-- 登录表单区域 -->
        <div class="login-area">
            <div class="login-card <%= showLoginCard ? "show" : "" %>" id="loginCard">
                <div class="login-title">
                    <h1>欢迎回来</h1>
                    <p>BOYA ACADEMY</p>
                </div>

                <!-- 错误/成功提示 -->
                <%
                    // 从 request 或 session 中获取消息
                    String errorMsg = (String) request.getAttribute("error");
                    String successMsg = (String) request.getAttribute("success");
                    if (successMsg == null) {
                        successMsg = (String) session.getAttribute("success");
                        // 读取后从 session 中移除，避免重复显示
                        if (successMsg != null) {
                            session.removeAttribute("success");
                        }
                    }
                %>
                <div id="formMessage" class="<%= errorMsg != null ? "error-message show" : "" %>">
                    <% if (errorMsg != null) { %>
                        <%= errorMsg %>
                    <% } %>
                </div>
                <div id="successMessage" class="<%= successMsg != null ? "success-message show" : "" %>">
                    <% if (successMsg != null) { %>
                        <%= successMsg %>
                    <% } %>
                </div>

                <!-- 标签切换 -->
                <div class="tab-switch">
                    <button type="button" class="tab-btn active" id="loginTab">登录</button>
                    <button type="button" class="tab-btn" id="registerTab">注册</button>
                </div>

                <!-- 登录表单 -->
                <div class="form-container active" id="loginForm">
                    <form action="${pageContext.request.contextPath}/login" method="post">
                        <div class="form-group">
                            <label class="form-label">账号</label>
                            <input type="text" class="form-input <%= request.getAttribute("loginUsername_error") != null ? "input-error" : "" %>" 
                                   name="username" id="loginUsername" placeholder="请输入账号" 
                                   value="<%= request.getAttribute("loginUsername_value") != null ? request.getAttribute("loginUsername_value") : "" %>" required>
                            <% if (request.getAttribute("loginUsername_error") != null) { %>
                                <span class="field-error"><%= request.getAttribute("loginUsername_error") %></span>
                            <% } %>
                        </div>
                        <div class="form-group">
                            <label class="form-label">密码</label>
                            <div class="password-input-wrapper">
                                <input type="password" class="form-input <%= request.getAttribute("loginPassword_error") != null ? "input-error" : "" %>" 
                                       name="password" id="loginPassword" placeholder="请输入密码" required>
                                <span class="toggle-password" onclick="togglePassword('loginPassword', this)">
                                    <svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                        <circle cx="12" cy="12" r="3"></circle>
                                    </svg>
                                    <svg class="eye-off-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display: none;">
                                        <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                                        <line x1="1" y1="1" x2="23" y2="23"></line>
                                    </svg>
                                </span>
                            </div>
                            <% if (request.getAttribute("loginPassword_error") != null) { %>
                                <span class="field-error"><%= request.getAttribute("loginPassword_error") %></span>
                            <% } %>
                        </div>
                        <button type="submit" class="login-btn">登 录</button>
                    </form>
                    <div class="forgot-password">
                        <a id="forgotPwdLink">忘记密码？</a>
                    </div>
                </div>

                <!-- 找回密码面板 -->
                <div class="form-container forgot-pwd-panel" id="forgotPwdPanel">
                    <div id="forgotPwdError" class="forgot-pwd-error"></div>
                    <div id="forgotPwdSuccess" class="forgot-pwd-success"></div>

                    <!-- 步骤1：输入邮箱 -->
                    <div id="forgotStep1">
                        <div class="forgot-step-title">📧 找回密码</div>
                        <div class="forgot-step-desc">请输入注册时使用的邮箱，我们将发送验证码</div>
                        <div class="form-group">
                            <label class="form-label">邮箱地址</label>
                            <input type="email" class="form-input" id="forgotEmail" placeholder="请输入注册邮箱">
                        </div>
                        <button type="button" class="forgot-pwd-btn" id="sendCodeBtn">发送验证码</button>
                        <div class="forgot-pwd-countdown" id="sendCountdown" style="display:none;"></div>
                    </div>

                    <!-- 步骤2：验证码 + 新密码 -->
                    <div id="forgotStep2" style="display:none;">
                        <div class="forgot-step-title">🔐 重置密码</div>
                        <div class="forgot-step-desc" id="forgotStep2Desc">
                            验证码已发送至 <strong id="forgotEmailDisplay"></strong>
                        </div>
                        <div class="form-group">
                            <label class="form-label">验证码</label>
                            <div class="code-row">
                                <input type="text" class="form-input" id="forgotCode" placeholder="输入 6 位验证码" maxlength="6" autocomplete="off">
                                <button type="button" class="forgot-pwd-btn" id="resendCodeBtn" style="width:auto;padding:12px 16px;font-size:0.8rem;white-space:nowrap;flex-shrink:0;" disabled>重新发送</button>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">新密码</label>
                            <div class="password-input-wrapper">
                                <input type="password" class="form-input" id="forgotNewPwd" placeholder="请输入新密码（至少 6 位）" autocomplete="new-password">
                                <button type="button" class="toggle-password" onclick="togglePassword('forgotNewPwd', this)" title="显示/隐藏密码">
                                    <span class="eye-icon">👁</span>
                                    <span class="eye-off-icon" style="display:none;">🙈</span>
                                </button>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">确认密码</label>
                            <div class="password-input-wrapper">
                                <input type="password" class="form-input" id="forgotConfirmPwd" placeholder="请再次输入新密码" autocomplete="new-password">
                                <button type="button" class="toggle-password" onclick="togglePassword('forgotConfirmPwd', this)" title="显示/隐藏密码">
                                    <span class="eye-icon">👁</span>
                                    <span class="eye-off-icon" style="display:none;">🙈</span>
                                </button>
                            </div>
                        </div>
                        <button type="button" class="forgot-pwd-btn" id="resetPwdBtn">重置密码</button>
                    </div>

                    <a class="forgot-pwd-back" id="forgotPwdBack">← 返回登录</a>
                </div>

                <!-- 注册表单 -->
                <div class="form-container" id="registerForm">
                    <form action="${pageContext.request.contextPath}/register" method="post">
                        <div class="form-group">
                            <label class="form-label">账号</label>
                            <input type="text" class="form-input <%= request.getAttribute("regUsername_error") != null ? "input-error" : "" %>" 
                                   name="reg_username" placeholder="请输入账号" 
                                   value="<%= request.getAttribute("regUsername_value") != null ? request.getAttribute("regUsername_value") : "" %>" required>
                            <% if (request.getAttribute("regUsername_error") != null) { %>
                                <span class="field-error"><%= request.getAttribute("regUsername_error") %></span>
                            <% } %>
                        </div>
                        <div class="form-group">
                            <label class="form-label">密码</label>
                            <div class="password-input-wrapper">
                                <input type="password" class="form-input <%= request.getAttribute("regPassword_error") != null ? "input-error" : "" %>" 
                                       name="reg_password" id="regPassword" placeholder="请输入密码" required>
                                <span class="toggle-password" onclick="togglePassword('regPassword', this)">
                                    <svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                        <circle cx="12" cy="12" r="3"></circle>
                                    </svg>
                                    <svg class="eye-off-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display: none;">
                                        <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                                        <line x1="1" y1="1" x2="23" y2="23"></line>
                                    </svg>
                                </span>
                            </div>
                            <% if (request.getAttribute("regPassword_error") != null) { %>
                                <span class="field-error"><%= request.getAttribute("regPassword_error") %></span>
                            <% } %>
                        </div>
                        <div class="form-group">
                            <label class="form-label">确认密码</label>
                            <div class="password-input-wrapper">
                                <input type="password" class="form-input <%= request.getAttribute("regPasswordConfirm_error") != null ? "input-error" : "" %>" 
                                       name="reg_password_confirm" id="regPasswordConfirm" placeholder="请再次输入密码" 
                                       value="<%= request.getAttribute("regPasswordConfirm_value") != null ? request.getAttribute("regPasswordConfirm_value") : "" %>" required>
                                <span class="toggle-password" onclick="togglePassword('regPasswordConfirm', this)">
                                    <svg class="eye-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                        <circle cx="12" cy="12" r="3"></circle>
                                    </svg>
                                    <svg class="eye-off-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display: none;">
                                        <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                                        <line x1="1" y1="1" x2="23" y2="23"></line>
                                    </svg>
                                </span>
                            </div>
                            <% if (request.getAttribute("regPasswordConfirm_error") != null) { %>
                                <span class="field-error"><%= request.getAttribute("regPasswordConfirm_error") %></span>
                            <% } %>
                        </div>
                        <div class="form-group">
                            <label class="form-label">邮箱</label>
                            <input type="email" class="form-input <%= request.getAttribute("regEmail_error") != null ? "input-error" : "" %>" 
                                   name="reg_email" placeholder="请输入邮箱" 
                                   value="<%= request.getAttribute("regEmail_value") != null ? request.getAttribute("regEmail_value") : "" %>" required>
                            <% if (request.getAttribute("regEmail_error") != null) { %>
                                <span class="field-error"><%= request.getAttribute("regEmail_error") %></span>
                            <% } %>
                        </div>
                        <div class="form-group" style="display: flex; gap: 20px;">
                            <div style="flex: 1; position: relative;">
                                <label class="form-label">性别</label>
                                <select class="form-input <%= request.getAttribute("regSex_error") != null ? "input-error" : "" %>" name="reg_sex" required>
                                    <option value="">请选择</option>
                                    <option value="男" <%= "男".equals(request.getAttribute("regSex_value")) ? "selected" : "" %>>男</option>
                                    <option value="女" <%= "女".equals(request.getAttribute("regSex_value")) ? "selected" : "" %>>女</option>
                                </select>
                                <% if (request.getAttribute("regSex_error") != null) { %>
                                    <span class="field-error"><%= request.getAttribute("regSex_error") %></span>
                                <% } %>
                            </div>
                            <div style="flex: 1; position: relative;">
                                <label class="form-label">年龄</label>
                                <input type="number" class="form-input <%= request.getAttribute("regAge_error") != null ? "input-error" : "" %>" 
                                       name="reg_age" placeholder="请输入年龄" min="1" max="150" 
                                       value="<%= request.getAttribute("regAge_value") != null ? request.getAttribute("regAge_value") : "" %>" required>
                                <% if (request.getAttribute("regAge_error") != null) { %>
                                    <span class="field-error"><%= request.getAttribute("regAge_error") %></span>
                                <% } %>
                            </div>
                        </div>
                        <button type="submit" class="login-btn">注 册</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        (function() {
            const pullString = document.getElementById('pullString');
            const switchIndicator = document.getElementById('switchIndicator');
            const lampLight = document.getElementById('lampLight');
            const lampShade = document.getElementById('lampShade');
            const openBook = document.getElementById('openBook');
            const loginCard = document.getElementById('loginCard');
            const loginTab = document.getElementById('loginTab');
            const registerTab = document.getElementById('registerTab');
            const loginForm = document.getElementById('loginForm');
            const registerForm = document.getElementById('registerForm');

            // 检查初始状态 - 如果有错误或成功信息，灯已经亮了（由JSP控制）
            // 只需要同步JavaScript状态，不需要触发动画
            let isLightOn = loginCard.classList.contains('show');

            // ========== 自动检测并切换到对应表单 ==========
            // 检测哪个表单有数据回显（说明是哪个表单提交失败返回的）
            const loginUsernameInput = document.querySelector('input[name="username"]');
            const regUsernameInput = document.querySelector('input[name="reg_username"]');
            
            const hasLoginData = loginUsernameInput && loginUsernameInput.value;
            const hasRegData = regUsernameInput && regUsernameInput.value;
            
            // 如果是注册失败返回（有 reg_username 的值），切换到注册表单
            if (hasRegData) {
                registerTab.classList.add('active');
                loginTab.classList.remove('active');
                registerForm.classList.add('active');
                loginForm.classList.remove('active');
            }
            // 如果是登录失败返回（有 username 的值），切换到登录表单
            else if (hasLoginData) {
                loginTab.classList.add('active');
                registerTab.classList.remove('active');
                loginForm.classList.add('active');
                registerForm.classList.remove('active');
            }

            // 拉绳开关点击事件
            pullString.addEventListener('click', function() {
                isLightOn = !isLightOn;

                if (isLightOn) {
                    // 首次拉开关时，设置 session 标记（通过 AJAX）
                    if (!document.body.dataset.loginShown) {
                        fetch('${pageContext.request.contextPath}/login?action=markShown', { method: 'POST' })
                            .then(() => {
                                document.body.dataset.loginShown = 'true';
                            });
                    }
                    lampLight.classList.add('on');
                    lampShade.classList.add('on');
                    switchIndicator.classList.add('on');
                    openBook.classList.add('on');
                    loginCard.classList.add('show');
                } else {
                    lampLight.classList.remove('on');
                    lampShade.classList.remove('on');
                    switchIndicator.classList.remove('on');
                    openBook.classList.remove('on');
                    loginCard.classList.remove('show');
                }
            });

            // 标记页面已显示过登录卡片（用于 AJAX 后续同步）
            if (loginCard.classList.contains('show')) {
                document.body.dataset.loginShown = 'true';
            }

            // ========== 输入时清除字段级错误提示 ==========
            const allInputs = document.querySelectorAll('.form-input');
            const formMessage = document.getElementById('formMessage');
            const successMessage = document.getElementById('successMessage');

            allInputs.forEach(function(input) {
                input.addEventListener('input', function() {
                    // 清除该输入框的错误状态
                    input.classList.remove('input-error');
                    const errorSpan = input.parentElement.querySelector('.field-error');
                    if (errorSpan) {
                        errorSpan.remove();
                    }
                });
            });

            // 标签切换 - 登录
            loginTab.addEventListener('click', function() {
                loginTab.classList.add('active');
                registerTab.classList.remove('active');
                loginForm.classList.add('active');
                registerForm.classList.remove('active');
                // 切换时清除所有提示
                clearAllErrors();
            });

            // 标签切换 - 注册
            registerTab.addEventListener('click', function() {
                registerTab.classList.add('active');
                loginTab.classList.remove('active');
                registerForm.classList.add('active');
                loginForm.classList.remove('active');
                // 切换时清除所有提示
                clearAllErrors();
            });

            // 清除所有错误的函数
            function clearAllErrors() {
                // 清除表单顶部消息
                if (formMessage) {
                    formMessage.style.display = 'none';
                    formMessage.classList.remove('show');
                }
                if (successMessage) {
                    successMessage.style.display = 'none';
                    successMessage.classList.remove('show');
                }
                // 清除所有字段级错误
                document.querySelectorAll('.field-error').forEach(function(el) {
                    el.remove();
                });
                document.querySelectorAll('.input-error').forEach(function(el) {
                    el.classList.remove('input-error');
                });
            }

            // ========== 挂历实时日期更新 ==========
            const calendarMonth = document.getElementById('calendarMonth');
            const calendarDay = document.getElementById('calendarDay');
            const calendar2Day = document.getElementById('calendar2Day');

            const monthNames = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

            function updateCalendarDate() {
                const now = new Date();
                const month = monthNames[now.getMonth()];
                const day = now.getDate();

                if (calendarMonth) {
                    calendarMonth.textContent = month;
                }
                if (calendarDay) {
                    calendarDay.textContent = day;
                }
                if (calendar2Day) {
                    calendar2Day.textContent = day;
                }
            }

            // 初始化日历日期
            updateCalendarDate();

            // 每分钟检查一次日期变化（用于跨天切换）
            setInterval(updateCalendarDate, 60000);

            // ========== 赛博朋克指针时钟更新 ==========
            function updateCyberAnalogClock() {
                const now = new Date();
                const hours = now.getHours() % 12;
                const minutes = now.getMinutes();
                const seconds = now.getSeconds();
                const milliseconds = now.getMilliseconds();

                // 计算角度
                const hourDeg = (hours * 30) + (minutes * 0.5);
                const minuteDeg = (minutes * 6) + (seconds * 0.1);
                const secondDeg = (seconds * 6) + (milliseconds * 0.006);

                var hourHand = document.getElementById('cyberHourHand');
                var minuteHand = document.getElementById('cyberMinuteHand');
                var secondHand = document.getElementById('cyberSecondHand');

                if (hourHand) {
                    hourHand.style.transform = 'rotate(' + hourDeg + 'deg)';
                }
                if (minuteHand) {
                    minuteHand.style.transform = 'rotate(' + minuteDeg + 'deg)';
                }
                if (secondHand) {
                    secondHand.style.transform = 'rotate(' + secondDeg + 'deg)';
                }
            }

            // 初始化时钟
            updateCyberAnalogClock();

            // 每50毫秒更新一次，实现平滑转动
            setInterval(updateCyberAnalogClock, 50);
        })();

        // ===== 忘记密码流程 =====
        var forgotPwdLink = document.getElementById('forgotPwdLink');
        var forgotPwdPanel = document.getElementById('forgotPwdPanel');
        var forgotPwdBack = document.getElementById('forgotPwdBack');
        var forgotPwdError = document.getElementById('forgotPwdError');
        var forgotPwdSuccess = document.getElementById('forgotPwdSuccess');
        var forgotStep1 = document.getElementById('forgotStep1');
        var forgotStep2 = document.getElementById('forgotStep2');
        var sendCodeBtn = document.getElementById('sendCodeBtn');
        var resendCodeBtn = document.getElementById('resendCodeBtn');
        var resetPwdBtn = document.getElementById('resetPwdBtn');
        var forgotEmail = document.getElementById('forgotEmail');
        var forgotCode = document.getElementById('forgotCode');
        var forgotNewPwd = document.getElementById('forgotNewPwd');
        var forgotConfirmPwd = document.getElementById('forgotConfirmPwd');
        var forgotEmailDisplay = document.getElementById('forgotEmailDisplay');
        var sendCountdown = document.getElementById('sendCountdown');

        var countdownTimer = null;
        var countdownSeconds = 0;

        // 显示/隐藏提示函数
        function showForgotError(msg) {
            if (forgotPwdError) {
                forgotPwdError.textContent = msg;
                forgotPwdError.classList.add('show');
            }
            if (forgotPwdSuccess) forgotPwdSuccess.classList.remove('show');
        }
        function showForgotSuccess(msg) {
            if (forgotPwdSuccess) {
                forgotPwdSuccess.textContent = msg;
                forgotPwdSuccess.classList.add('show');
            }
            if (forgotPwdError) forgotPwdError.classList.remove('show');
        }
        function hideForgotMessages() {
            if (forgotPwdError) forgotPwdError.classList.remove('show');
            if (forgotPwdSuccess) forgotPwdSuccess.classList.remove('show');
        }

        // 打开找回密码面板
        if (forgotPwdLink) {
            forgotPwdLink.addEventListener('click', function() {
                // 隐藏登录/注册表单
                loginForm.classList.remove('active');
                registerForm.classList.remove('active');
                // 隐藏 Tab 按钮
                loginTab.style.display = 'none';
                registerTab.style.display = 'none';
                // 显示找回密码面板
                forgotPwdPanel.classList.add('active');
                // 重置到步骤1
                showForgotStep1();
                hideForgotMessages();
            });
        }

        // 返回登录
        if (forgotPwdBack) {
            forgotPwdBack.addEventListener('click', function() {
                backToLogin();
            });
        }

        function backToLogin() {
            forgotPwdPanel.classList.remove('active');
            loginTab.style.display = '';
            registerTab.style.display = '';
            loginTab.classList.add('active');
            registerTab.classList.remove('active');
            loginForm.classList.add('active');
            registerForm.classList.remove('active');
            hideForgotMessages();
            clearCountdown();
        }

        function showForgotStep1() {
            if (forgotStep1) forgotStep1.style.display = '';
            if (forgotStep2) forgotStep2.style.display = 'none';
            hideForgotMessages();
        }

        function showForgotStep2(email) {
            if (forgotStep1) forgotStep1.style.display = 'none';
            if (forgotStep2) forgotStep2.style.display = '';
            if (forgotEmailDisplay) forgotEmailDisplay.textContent = email || '';
            hideForgotMessages();
        }

        // 倒计时
        function startCountdown() {
            countdownSeconds = 60;
            if (resendCodeBtn) resendCodeBtn.disabled = true;
            if (sendCountdown) sendCountdown.style.display = '';
            updateCountdown();
            countdownTimer = setInterval(function() {
                countdownSeconds--;
                if (countdownSeconds <= 0) {
                    clearCountdown();
                } else {
                    updateCountdown();
                }
            }, 1000);
        }

        function updateCountdown() {
            if (sendCountdown) sendCountdown.textContent = countdownSeconds + ' 秒后可重新发送';
        }

        function clearCountdown() {
            if (countdownTimer) { clearInterval(countdownTimer); countdownTimer = null; }
            countdownSeconds = 0;
            if (resendCodeBtn) resendCodeBtn.disabled = false;
            if (sendCountdown) sendCountdown.style.display = 'none';
        }

        // 发送验证码
        function doSendCode() {
            var email = forgotEmail ? forgotEmail.value.trim() : '';
            if (!email) {
                showForgotError('请输入邮箱地址');
                return;
            }
            if (!/^[\w.-]+@[\w.-]+\.\w{2,}$/.test(email)) {
                showForgotError('请输入有效的邮箱地址');
                return;
            }

            // 禁用按钮，显示加载
            if (sendCodeBtn) { sendCodeBtn.disabled = true; sendCodeBtn.textContent = '发送中...'; }
            hideForgotMessages();

            var ctx = window.location.pathname.replace(/\/LOGIN\/login\.jsp$/, '') || '';
            fetch(ctx + '/forgotPassword', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=sendCode&email=' + encodeURIComponent(email)
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) {
                    showForgotSuccess(data.message);
                    showForgotStep2(email);
                    startCountdown();
                } else {
                    showForgotError(data.message);
                }
            })
            .catch(function() {
                showForgotError('网络错误，请稍后重试');
            })
            .finally(function() {
                if (sendCodeBtn) { sendCodeBtn.disabled = false; sendCodeBtn.textContent = '发送验证码'; }
            });
        }

        if (sendCodeBtn) sendCodeBtn.addEventListener('click', doSendCode);
        if (resendCodeBtn) resendCodeBtn.addEventListener('click', doSendCode);

        // 重置密码
        if (resetPwdBtn) {
            resetPwdBtn.addEventListener('click', function() {
                var email = forgotEmail ? forgotEmail.value.trim() : '';
                var code = forgotCode ? forgotCode.value.trim() : '';
                var pwd = forgotNewPwd ? forgotNewPwd.value.trim() : '';
                var confirmPwd = forgotConfirmPwd ? forgotConfirmPwd.value.trim() : '';

                if (!code) { showForgotError('请输入验证码'); return; }
                if (code.length !== 6 || !/^\d{6}$/.test(code)) { showForgotError('验证码为 6 位数字'); return; }
                if (!pwd) { showForgotError('请输入新密码'); return; }
                if (pwd.length < 6) { showForgotError('密码长度不能少于 6 位'); return; }
                if (pwd !== confirmPwd) { showForgotError('两次密码输入不一致'); return; }

                if (resetPwdBtn) { resetPwdBtn.disabled = true; resetPwdBtn.textContent = '重置中...'; }
                hideForgotMessages();

                var ctx = window.location.pathname.replace(/\/LOGIN\/login\.jsp$/, '') || '';
                fetch(ctx + '/forgotPassword', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'action=reset&email=' + encodeURIComponent(email) + '&code=' + encodeURIComponent(code) + '&newPassword=' + encodeURIComponent(pwd)
                })
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (data.success) {
                        showForgotSuccess(data.message);
                        // 2 秒后自动返回登录
                        setTimeout(function() {
                            backToLogin();
                        }, 2500);
                    } else {
                        showForgotError(data.message);
                    }
                })
                .catch(function() {
                    showForgotError('网络错误，请稍后重试');
                })
                .finally(function() {
                    if (resetPwdBtn) { resetPwdBtn.disabled = false; resetPwdBtn.textContent = '重置密码'; }
                });
            });
        }

        // 输入时清除错误提示
        [forgotEmail, forgotCode, forgotNewPwd, forgotConfirmPwd].forEach(function(input) {
            if (!input) return;
            input.addEventListener('input', function() {
                if (forgotPwdError) forgotPwdError.classList.remove('show');
            });
        });

        // 按回车键发送验证码（步骤1）/ 重置密码（步骤2）
        if (forgotEmail) {
            forgotEmail.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') { doSendCode(); }
            });
        }
        [forgotCode, forgotNewPwd, forgotConfirmPwd].forEach(function(input) {
            if (!input) return;
            input.addEventListener('keypress', function(e) {
                if (e.key === 'Enter' && resetPwdBtn) { resetPwdBtn.click(); }
            });
        });

        // 切换密码显示/隐藏
        function togglePassword(inputId, toggleElement) {
            const passwordInput = document.getElementById(inputId);
            const eyeIcon = toggleElement.querySelector('.eye-icon');
            const eyeOffIcon = toggleElement.querySelector('.eye-off-icon');

            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                eyeIcon.style.display = 'none';
                eyeOffIcon.style.display = 'block';
            } else {
                passwordInput.type = 'password';
                eyeIcon.style.display = 'block';
                eyeOffIcon.style.display = 'none';
            }
        }
    </script>
</body>
</html>
