<%--
 =============================================================================
 usersList.jsp
 =============================================================================

 用途      数据列表 / 管理页面
 标签库    prefix="c" uri="http://java.sun.com/jsp/jstl/core"

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   EL 表达式 —— ${} 访问后端数据
   JSTL 核心标签 —— <c:forEach> / <c:if> / <c:choose>
   ${pageContext.request.contextPath} —— 获取应用上下文根路径
   DOM 事件处理
   DOM 选择器 —— querySelector / getElementById
   表单 GET/POST 提交 —— 携带 URL 参数或隐藏字段

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户管理 - 博雅书院</title>
    <style>
        :root {
            --bg-dark: #0a0c15;
            --bg-card: rgba(20, 28, 45, 0.8);
            --glow-cyan: #00f2ff;
            --glow-purple: #b77eff;
            --accent-blue: #2d7eff;
            --accent-red: #ff6464;
            --accent-green: #4ade80;
            --text-primary: #ffffff;
            --text-secondary: #ffffff;
            --border-glow: rgba(0, 242, 255, 0.3);
        }
        
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            background: radial-gradient(ellipse at 50% 0%, rgba(15, 23, 42, 0.9), var(--bg-dark));
            font-family: 'Inter', 'Segoe UI', 'Poppins', system-ui, sans-serif;
            min-height: 100vh;
            color: var(--text-primary);
            padding: 1rem;
            font-size: 13px;
        }
        
        /* 美化滚动条 */
        * { scrollbar-width: none !important; }
        
        .page-container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
            padding: 0.8rem 1.2rem;
            background: var(--bg-card);
            border-radius: 12px;
            border: 1px solid var(--border-glow);
            backdrop-filter: blur(12px);
        }
        
        .header-actions {
            display: flex;
            gap: 8px;
            align-items: center;
        }
        
        .btn-icon {
            width: 36px;
            height: 36px;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            border: 1px solid rgba(0, 242, 255, 0.4);
            background: linear-gradient(135deg, rgba(0, 242, 255, 0.2), rgba(45, 126, 255, 0.15));
            color: var(--glow-cyan);
            font-size: 1rem;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .btn-icon:hover {
            background: linear-gradient(135deg, rgba(0, 242, 255, 0.4), rgba(45, 126, 255, 0.35));
            transform: translateY(-1px);
            box-shadow: 0 2px 8px rgba(0, 242, 255, 0.3);
        }
        
        .page-title {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 1rem;
            font-weight: 700;
            background: linear-gradient(135deg, #fff, #88ccff);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }
        
        .page-title .icon {
            font-size: 1.2rem;
            filter: drop-shadow(0 0 6px var(--glow-cyan));
        }
        
        .btn {
            padding: 6px 14px;
            border-radius: 8px;
            border: none;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, rgba(45, 126, 255, 0.4), rgba(0, 242, 255, 0.3));
            border: 1px solid rgba(0, 242, 255, 0.4);
            color: var(--glow-cyan);
        }
        
        .btn-primary:hover {
            background: linear-gradient(135deg, rgba(45, 126, 255, 0.6), rgba(0, 242, 255, 0.5));
            transform: translateY(-1px);
            box-shadow: 0 2px 8px rgba(0, 242, 255, 0.3);
        }
        
        .btn-danger {
            background: rgba(255, 100, 100, 0.2);
            border: 1px solid rgba(255, 100, 100, 0.3);
            color: var(--accent-red);
        }
        
        .btn-danger:hover {
            background: rgba(255, 100, 100, 0.3);
            transform: translateY(-1px);
        }
        
        .btn-warning {
            background: rgba(255, 193, 7, 0.2);
            border: 1px solid rgba(255, 193, 7, 0.3);
            color: #ffc107;
        }
        
        .btn-warning:hover {
            background: rgba(255, 193, 7, 0.3);
            transform: translateY(-1px);
        }
        
        .btn-sm { padding: 4px 8px; font-size: 11px; border-radius: 6px; }
        
        .alert {
            padding: 0.6rem 1rem;
            border-radius: 8px;
            margin-bottom: 0.8rem;
            font-size: 12px;
            font-weight: 500;
        }
        
        .alert-success {
            background: rgba(74, 222, 128, 0.2);
            border: 1px solid rgba(74, 222, 128, 0.4);
            color: var(--accent-green);
        }
        
        .alert-error {
            background: rgba(255, 100, 100, 0.2);
            border: 1px solid rgba(255, 100, 100, 0.4);
            color: var(--accent-red);
        }
        
        .table-card {
            background: var(--bg-card);
            border-radius: 12px;
            border: 1px solid var(--border-glow);
            overflow: auto;
            max-height: calc(100vh - 120px);
            backdrop-filter: blur(12px);
        }
        
        .data-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 900px;
        }
        
        .data-table thead {
            background: linear-gradient(90deg, rgba(0, 242, 255, 0.15), rgba(45, 126, 255, 0.1));
            position: sticky;
            top: 0;
            z-index: 1;
        }
        
        .data-table th {
            padding: 10px 12px;
            text-align: left;
            font-weight: 600;
            color: var(--glow-cyan);
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid var(--border-glow);
            white-space: nowrap;
        }
        
        .data-table td {
            padding: 8px 12px;
            border-bottom: 1px solid rgba(0, 242, 255, 0.08);
            color: var(--text-primary);
            font-size: 12px;
        }
        
        .data-table tbody tr {
            transition: all 0.15s;
        }
        
        .data-table tbody tr:hover {
            background: rgba(0, 242, 255, 0.08);
        }
        
        .role-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 11px;
            font-weight: 600;
        }
        
        .role-admin {
            background: linear-gradient(135deg, rgba(183, 126, 255, 0.3), rgba(183, 126, 255, 0.1));
            color: var(--glow-purple);
            border: 1px solid rgba(183, 126, 255, 0.4);
        }
        
        .role-user {
            background: rgba(160, 179, 217, 0.15);
            color: var(--text-secondary);
            border: 1px solid rgba(160, 179, 217, 0.25);
        }
        
        .action-btns {
            display: flex;
            gap: 4px;
            flex-wrap: nowrap;
        }
        
        .action-btns .btn {
            flex-shrink: 0;
        }
        
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.7);
            backdrop-filter: blur(4px);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        
        .modal-overlay.active {
            display: flex;
        }
        
        .modal {
            background: linear-gradient(145deg, #141c2d, #0f1520);
            border-radius: 16px;
            border: 1px solid var(--border-glow);
            padding: 1.5rem;
            width: 90%;
            max-width: 420px;
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.5), 0 0 20px rgba(0, 242, 255, 0.1);
            animation: modalIn 0.25s ease;
        }
        
        @keyframes modalIn {
            from { opacity: 0; transform: scale(0.95) translateY(-10px); }
            to { opacity: 1; transform: scale(1) translateY(0); }
        }
        
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
            padding-bottom: 0.8rem;
            border-bottom: 1px solid var(--border-glow);
        }
        
        .modal-title {
            font-size: 1rem;
            font-weight: 700;
            background: linear-gradient(135deg, #fff, #88ccff);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }
        
        .modal-close {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            border: 1px solid rgba(255, 100, 100, 0.3);
            background: rgba(255, 100, 100, 0.1);
            color: var(--accent-red);
            font-size: 1rem;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .modal-close:hover {
            background: rgba(255, 100, 100, 0.3);
            transform: rotate(90deg);
        }
        
        .form-group {
            margin-bottom: 0.8rem;
        }
        
        .form-label {
            display: block;
            margin-bottom: 4px;
            font-size: 12px;
            color: var(--text-secondary);
            font-weight: 500;
        }
        
        .form-input {
            width: 100%;
            padding: 8px 12px;
            border-radius: 8px;
            border: 1px solid rgba(0, 242, 255, 0.3);
            background: rgba(10, 15, 25, 0.8);
            color: var(--text-primary);
            font-size: 13px;
            transition: all 0.2s;
        }
        
        .form-input:focus {
            outline: none;
            border-color: var(--glow-cyan);
            box-shadow: 0 0 10px rgba(0, 242, 255, 0.15);
        }
        
        .form-select {
            width: 100%;
            padding: 8px 12px;
            border-radius: 8px;
            border: 1px solid rgba(0, 242, 255, 0.3);
            background: rgba(10, 15, 25, 0.8);
            color: var(--text-primary);
            font-size: 13px;
            cursor: pointer;
        }
        
        .form-select:focus {
            outline: none;
            border-color: var(--glow-cyan);
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.8rem;
        }
        
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 0.8rem;
            margin-top: 1rem;
            padding-top: 0.8rem;
            border-top: 1px solid var(--border-glow);
        }
        
        @media (max-width: 768px) {
            .page-header { flex-direction: column; gap: 0.5rem; }
            .form-row { grid-template-columns: 1fr; }
        }
        
        /* 查询区域样式 - 玻璃拟态卡片 */
        .search-area {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
            padding: 1.2rem 1.5rem;
            background: linear-gradient(135deg, rgba(0, 242, 255, 0.08), rgba(45, 126, 255, 0.05));
            border-radius: 16px;
            margin-bottom: 1.2rem;
            border: 1px solid rgba(0, 242, 255, 0.2);
            box-shadow: 
                0 4px 20px rgba(0, 242, 255, 0.1),
                inset 0 1px 0 rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            align-items: flex-end;
        }
        
        .search-field {
            display: flex;
            flex-direction: column;
            gap: 6px;
            min-width: 160px;
            flex: 1;
        }
        
        .search-field label {
            font-size: 11px;
            color: var(--glow-cyan);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            text-shadow: 0 0 10px rgba(0, 242, 255, 0.3);
        }
        
        .search-field input,
        .search-field select {
            padding: 10px 14px;
            border-radius: 10px;
            border: 1px solid rgba(0, 242, 255, 0.3);
            background: rgba(10, 15, 25, 0.6);
            color: var(--text-primary);
            font-size: 13px;
            transition: all 0.3s ease;
        }
        
        .search-field input::placeholder {
            color: rgba(255, 255, 255, 0.3);
        }
        
        .search-field input:hover,
        .search-field select:hover {
            border-color: rgba(0, 242, 255, 0.5);
            background: rgba(10, 15, 25, 0.8);
        }
        
        .search-field input:focus,
        .search-field select:focus {
            outline: none;
            border-color: var(--glow-cyan);
            background: rgba(10, 15, 25, 0.9);
            box-shadow: 
                0 0 15px rgba(0, 242, 255, 0.2),
                inset 0 1px 0 rgba(255, 255, 255, 0.1);
        }
        
        .search-actions {
            display: flex;
            gap: 10px;
            align-items: flex-end;
            margin-left: auto;
        }
        
        .btn-search {
            padding: 10px 20px;
            background: linear-gradient(135deg, rgba(0, 242, 255, 0.5), rgba(45, 126, 255, 0.4));
            border: 1px solid rgba(0, 242, 255, 0.5);
            color: #fff;
            font-weight: 600;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0, 242, 255, 0.2);
        }
        
        .btn-search:hover {
            background: linear-gradient(135deg, rgba(0, 242, 255, 0.7), rgba(45, 126, 255, 0.6));
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0, 242, 255, 0.35);
        }
        
        .btn-search:active {
            transform: translateY(0);
        }
        
        .btn-reset {
            padding: 10px 18px;
            background: rgba(160, 179, 217, 0.1);
            border: 1px solid rgba(160, 179, 217, 0.3);
            color: rgba(255, 255, 255, 0.7);
            font-weight: 500;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .btn-reset:hover {
            background: rgba(160, 179, 217, 0.2);
            border-color: rgba(160, 179, 217, 0.5);
            color: #fff;
            transform: translateY(-2px);
        }
        
        .result-count {
            font-size: 12px;
            color: var(--glow-cyan);
            padding: 6px 14px;
            background: linear-gradient(135deg, rgba(0, 242, 255, 0.15), rgba(45, 126, 255, 0.1));
            border-radius: 20px;
            border: 1px solid rgba(0, 242, 255, 0.3);
            box-shadow: 0 2px 10px rgba(0, 242, 255, 0.1);
        }
        /* ══════════ 浅色主题 · 用户管理全覆盖 ══════════ */
        html[data-theme$="-light"] body {
            background: linear-gradient(170deg, #e9e2d2, #ede5d3 40%, #e4dbca) !important;
            color: #3d3929 !important;
        }
        /* ── 滚动条 ── */
        html[data-theme$="-light"] ::-webkit-scrollbar-track { background: rgba(139, 119, 80, 0.04) !important; }
        html[data-theme$="-light"] ::-webkit-scrollbar-thumb { background: rgba(37, 99, 235, 0.15) !important; border-radius: 3px !important; }
        html[data-theme$="-light"] * { scrollbar-color: rgba(37, 99, 235, 0.3) rgba(139, 119, 80, 0.04) !important; }
        /* ── 页面头部 ── */
        html[data-theme$="-light"] .page-header {
            background: rgba(238, 233, 222, 0.85) !important;
            border-color: rgba(37, 99, 235, 0.1) !important;
            box-shadow: 0 4px 20px rgba(139, 119, 80, 0.08) !important;
        }
        html[data-theme$="-light"] .page-title {
            background: linear-gradient(135deg, #3d3929, #2563eb) !important;
            -webkit-background-clip: text !important;
            background-clip: text !important;
            color: transparent !important;
        }
        html[data-theme$="-light"] .page-title .icon {
            filter: drop-shadow(0 0 4px rgba(37, 99, 235, 0.3)) !important;
        }
        /* ── 图标按钮 ── */
        html[data-theme$="-light"] .btn-icon {
            background: linear-gradient(135deg, rgba(37, 99, 235, 0.06), rgba(124, 58, 237, 0.04)) !important;
            border-color: rgba(37, 99, 235, 0.12) !important;
            color: #2563eb !important;
        }
        html[data-theme$="-light"] .btn-icon:hover {
            background: linear-gradient(135deg, rgba(37, 99, 235, 0.15), rgba(124, 58, 237, 0.1)) !important;
            box-shadow: 0 2px 10px rgba(37, 99, 235, 0.12) !important;
            color: #2563eb !important;
        }
        /* ── 按钮通用 ── */
        html[data-theme$="-light"] .btn-primary {
            background: linear-gradient(135deg, rgba(37, 99, 235, 0.1), rgba(124, 58, 237, 0.06)) !important;
            border-color: rgba(37, 99, 235, 0.18) !important;
            color: #2563eb !important;
        }
        html[data-theme$="-light"] .btn-primary:hover {
            background: linear-gradient(135deg, rgba(37, 99, 235, 0.2), rgba(124, 58, 237, 0.12)) !important;
            box-shadow: 0 4px 16px rgba(37, 99, 235, 0.1) !important;
        }
        html[data-theme$="-light"] .btn-danger {
            background: rgba(220, 60, 60, 0.06) !important;
            border-color: rgba(220, 60, 60, 0.15) !important;
            color: #b91c1c !important;
        }
        html[data-theme$="-light"] .btn-danger:hover {
            background: rgba(220, 60, 60, 0.12) !important;
            box-shadow: 0 2px 10px rgba(220, 60, 60, 0.1) !important;
        }
        html[data-theme$="-light"] .btn-warning {
            background: rgba(245, 158, 11, 0.06) !important;
            border-color: rgba(245, 158, 11, 0.15) !important;
            color: #b45309 !important;
        }
        html[data-theme$="-light"] .btn-warning:hover {
            background: rgba(245, 158, 11, 0.12) !important;
        }
        html[data-theme$="-light"] .btn-sm {
            color: inherit !important;
        }
        /* ── 提示信息 ── */
        html[data-theme$="-light"] .alert-success {
            background: rgba(5, 150, 105, 0.08) !important;
            border-color: rgba(5, 150, 105, 0.18) !important;
            color: #047857 !important;
        }
        html[data-theme$="-light"] .alert-error {
            background: rgba(220, 60, 60, 0.08) !important;
            border-color: rgba(220, 60, 60, 0.18) !important;
            color: #b91c1c !important;
        }
        /* ── 表格卡片 ── */
        html[data-theme$="-light"] .table-card {
            background: rgba(238, 233, 222, 0.85) !important;
            border-color: rgba(139, 119, 80, 0.06) !important;
        }
        /* ── 表头 ── */
        html[data-theme$="-light"] .data-table thead {
            background: linear-gradient(90deg, rgba(37, 99, 235, 0.05), rgba(139, 119, 80, 0.03)) !important;
        }
        html[data-theme$="-light"] .data-table th {
            color: #5c5540 !important;
            border-bottom-color: rgba(139, 119, 80, 0.08) !important;
        }
        /* ── 表体 ── */
        html[data-theme$="-light"] .data-table td {
            color: #3d3929 !important;
            border-bottom-color: rgba(139, 119, 80, 0.05) !important;
        }
        html[data-theme$="-light"] .data-table tbody tr:hover {
            background: rgba(37, 99, 235, 0.04) !important;
        }
        /* ── 角色标签 ── */
        html[data-theme$="-light"] .role-admin {
            background: linear-gradient(135deg, rgba(124, 58, 237, 0.08), rgba(124, 58, 237, 0.04)) !important;
            color: #7c3aed !important;
            border-color: rgba(124, 58, 237, 0.15) !important;
        }
        html[data-theme$="-light"] .role-user {
            background: rgba(139, 119, 80, 0.05) !important;
            color: #5c5540 !important;
            border-color: rgba(139, 119, 80, 0.1) !important;
        }
        /* ── 模态框遮罩 ── */
        html[data-theme$="-light"] .modal-overlay {
            background: rgba(61, 57, 41, 0.35) !important;
        }
        html[data-theme$="-light"] .modal {
            background: linear-gradient(145deg, rgba(238, 233, 222, 0.98), rgba(245, 240, 232, 0.96)) !important;
            border-color: rgba(37, 99, 235, 0.12) !important;
            box-shadow: 0 20px 60px rgba(139, 119, 80, 0.15) !important;
        }
        html[data-theme$="-light"] .modal-header {
            border-bottom-color: rgba(139, 119, 80, 0.06) !important;
        }
        html[data-theme$="-light"] .modal-title {
            background: linear-gradient(135deg, #3d3929, #2563eb) !important;
            -webkit-background-clip: text !important;
            background-clip: text !important;
            color: transparent !important;
        }
        html[data-theme$="-light"] .modal-close {
            background: rgba(220, 60, 60, 0.06) !important;
            border-color: rgba(220, 60, 60, 0.12) !important;
            color: #b91c1c !important;
        }
        html[data-theme$="-light"] .modal-close:hover {
            background: rgba(220, 60, 60, 0.12) !important;
        }
        html[data-theme$="-light"] .modal-footer {
            border-top-color: rgba(139, 119, 80, 0.06) !important;
        }
        /* ── 表单 ── */
        html[data-theme$="-light"] .form-label {
            color: #5c5540 !important;
        }
        html[data-theme$="-light"] .form-input {
            background: rgba(238, 233, 222, 0.85) !important;
            border-color: rgba(139, 119, 80, 0.1) !important;
            color: #3d3929 !important;
        }
        html[data-theme$="-light"] .form-input:focus {
            border-color: rgba(37, 99, 235, 0.25) !important;
            box-shadow: 0 0 12px rgba(37, 99, 235, 0.06) !important;
        }
        html[data-theme$="-light"] .form-select {
            background: rgba(238, 233, 222, 0.85) !important;
            border-color: rgba(139, 119, 80, 0.1) !important;
            color: #3d3929 !important;
        }
        html[data-theme$="-light"] .form-select:focus {
            border-color: rgba(37, 99, 235, 0.25) !important;
        }
        html[data-theme$="-light"] .form-select option {
            background: #f0ebe0 !important;
            color: #3d3929 !important;
        }
        /* ── 搜索区域 ── */
        html[data-theme$="-light"] .search-area {
            background: linear-gradient(135deg, rgba(37, 99, 235, 0.03), rgba(139, 119, 80, 0.02)) !important;
            border-color: rgba(37, 99, 235, 0.08) !important;
            box-shadow: 0 4px 16px rgba(139, 119, 80, 0.06), inset 0 1px 0 rgba(255, 255, 255, 0.3) !important;
        }
        html[data-theme$="-light"] .search-field label {
            color: #5c5540 !important;
            text-shadow: none !important;
        }
        html[data-theme$="-light"] .search-field input,
        html[data-theme$="-light"] .search-field select {
            background: rgba(238, 233, 222, 0.85) !important;
            border-color: rgba(139, 119, 80, 0.1) !important;
            color: #3d3929 !important;
        }
        html[data-theme$="-light"] .search-field input::placeholder {
            color: rgba(61, 57, 41, 0.25) !important;
        }
        html[data-theme$="-light"] .search-field input:hover,
        html[data-theme$="-light"] .search-field select:hover {
            border-color: rgba(37, 99, 235, 0.2) !important;
            background: rgba(243, 239, 228, 0.9) !important;
        }
        html[data-theme$="-light"] .search-field input:focus,
        html[data-theme$="-light"] .search-field select:focus {
            border-color: rgba(37, 99, 235, 0.3) !important;
            box-shadow: 0 0 12px rgba(37, 99, 235, 0.06), inset 0 1px 0 rgba(255, 255, 255, 0.6) !important;
        }
        /* ── 搜索按钮 ── */
        html[data-theme$="-light"] .btn-search {
            background: linear-gradient(135deg, rgba(37, 99, 235, 0.15), rgba(45, 126, 255, 0.1)) !important;
            border-color: rgba(37, 99, 235, 0.2) !important;
            color: #2563eb !important;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.06) !important;
        }
        html[data-theme$="-light"] .btn-search:hover {
            background: linear-gradient(135deg, rgba(37, 99, 235, 0.25), rgba(45, 126, 255, 0.18)) !important;
            box-shadow: 0 6px 20px rgba(37, 99, 235, 0.12) !important;
        }
        /* ── 重置按钮 ── */
        html[data-theme$="-light"] .btn-reset {
            background: rgba(139, 119, 80, 0.04) !important;
            border-color: rgba(139, 119, 80, 0.08) !important;
            color: #7a7360 !important;
        }
        html[data-theme$="-light"] .btn-reset:hover {
            background: rgba(139, 119, 80, 0.08) !important;
            border-color: rgba(139, 119, 80, 0.15) !important;
            color: #3d3929 !important;
        }
        /* ── 结果计数 ── */
        html[data-theme$="-light"] .result-count {
            background: linear-gradient(135deg, rgba(37, 99, 235, 0.06), rgba(124, 58, 237, 0.04)) !important;
            border-color: rgba(37, 99, 235, 0.12) !important;
            color: #2563eb !important;
            box-shadow: 0 2px 8px rgba(37, 99, 235, 0.04) !important;
        }
        /* ── 通用 ── */
        html[data-theme$="-light"] h1, html[data-theme$="-light"] h2, html[data-theme$="-light"] h3, html[data-theme$="-light"] h4 { color: #3d3929 !important; }
        html[data-theme$="-light"] p, html[data-theme$="-light"] span, html[data-theme$="-light"] label, html[data-theme$="-light"] td strong { color: inherit !important; }
        html[data-theme$="-light"] ::selection { background: rgba(37, 99, 235, 0.15) !important; color: #3d3929 !important; }
    </style>
</head>
<body>
<div class="page-container">
    <!-- 页面头部 -->
    <div class="page-header">
        <div class="page-title">
            <span class="icon">👥</span>
            用户管理
        </div>
        <div class="header-actions">
            <c:if test="${isSearch != null && isSearch}">
                <span class="result-count">找到 ${searchCount} 条结果</span>
            </c:if>
            <button class="btn-icon" onclick="toggleSearch()" title="多条件查询">
                🔍
            </button>
            <button class="btn btn-primary" onclick="openAddModal()">
                <span>+</span> 添加用户
            </button>
        </div>
    </div>
    
    <!-- 查询区域 -->
    <div class="search-area" id="searchArea" style="display: none;">
        <div class="search-field">
            <label>用户名</label>
            <input type="text" id="searchUsername" placeholder="输入用户名">
        </div>
        <div class="search-field">
            <label>性别</label>
            <select id="searchSex">
                <option value="">全部</option>
                <option value="男">男</option>
                <option value="女">女</option>
            </select>
        </div>
        <div class="search-actions">
            <button class="btn btn-search" onclick="performSearch()">🔍 查询</button>
            <button class="btn btn-reset" onclick="resetSearch()">重置</button>
        </div>
    </div>
    
    <!-- 提示信息 -->
    <c:if test="${param.success != null}">
        <div class="alert alert-success">✓ ${param.success}</div>
    </c:if>
    <c:if test="${param.error != null}">
        <div class="alert alert-error">✗ ${param.error}</div>
    </c:if>
    
    <!-- 数据表格 -->
    <div class="table-card">
        <table class="data-table">
            <thead>
                <tr>
                    <th>编号</th>
                    <th>用户名</th>
                    <th>密码</th>
                    <th>性别</th>
                    <th>年龄</th>
                    <th>邮箱</th>
                    <th>角色</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="user" items="${users}">
                    <tr data-id="${user.id}">
                        <td><strong>${user.id}</strong></td>
                        <td>${user.username}</td>
                        <td>********</td>
                        <td>${user.sex}</td>
                        <td>${user.age}</td>
                        <td>${user.email}</td>
                        <td>
                            <span class="role-badge ${user.role == 'admin' ? 'role-admin' : 'role-user'}">
                                ${user.role == 'admin' ? '👑 管理员' : '👤 普通用户'}
                            </span>
                        </td>
                        <td>
                            <div class="action-btns">
                                <button class="btn btn-sm btn-warning" onclick="editUser('${user.id}', '${user.username}', '', '${user.sex}', '${user.age}', '${user.email}', '${user.role}')">
                                    ✏️ 编辑
                                </button>
                                <button class="btn btn-sm btn-danger" onclick="deleteUser('${user.id}', '${user.username}')">
                                    🗑️ 删除
                                </button>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<!-- 添加/编辑用户模态框 -->
<div class="modal-overlay" id="userModal">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title" id="modalTitle">添加用户</span>
            <button class="modal-close" onclick="closeModal()">×</button>
        </div>
        <form action="${pageContext.request.contextPath}/usersList" method="post" id="userForm">
            <input type="hidden" name="action" id="formAction" value="add">
            <input type="hidden" name="id" id="userId">
            
            <div class="form-group">
                <label class="form-label">用户名 *</label>
                <input type="text" class="form-input" name="username" id="username" required placeholder="请输入用户名">
            </div>
            
            <div class="form-group">
                <label class="form-label">密码 <span id="passwordLabel">*</span></label>
                <input type="password" class="form-input" name="password" id="password" ${empty user.id ? 'required' : ''} placeholder="请输入密码">
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">性别</label>
                    <select class="form-select" name="sex" id="sex">
                        <option value="男">男</option>
                        <option value="女">女</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">年龄</label>
                    <input type="number" class="form-input" name="age" id="age" placeholder="年龄">
                </div>
            </div>
            
            <div class="form-group">
                <label class="form-label">邮箱</label>
                <input type="email" class="form-input" name="email" id="email" placeholder="example@email.com">
            </div>
            
            <div class="form-group">
                <label class="form-label">角色</label>
                <select class="form-select" name="role" id="role">
                    <option value="user">普通用户</option>
                    <option value="admin">管理员</option>
                </select>
            </div>
            
            <div class="modal-footer">
                <button type="button" class="btn btn-danger" onclick="closeModal()">取消</button>
                <button type="submit" class="btn btn-primary">保存</button>
            </div>
        </form>
    </div>
</div>

<script>
    // 查询区域展开/收起
    function toggleSearch() {
        const searchArea = document.getElementById('searchArea');
        if (searchArea.style.display === 'none') {
            searchArea.style.display = 'flex';
        } else {
            searchArea.style.display = 'none';
        }
    }

    // 1. 点击查询按钮时触发 - 提交到后端查询
    function performSearch() {
        // 2. 获取查询条件（用户名和性别）
        const searchUsername = document.getElementById('searchUsername').value.trim();
        const searchSex = document.getElementById('searchSex').value;
        
        // 3. 构建查询URL
        const params = new URLSearchParams();
        if (searchUsername) params.append('searchUsername', searchUsername);
        if (searchSex) params.append('searchSex', searchSex);
        
        // 4. 跳转到带查询参数的URL
        window.location.href = '${pageContext.request.contextPath}/usersList?' + params.toString();
    }
    
    // 页面加载时，如果有查询参数，展开查询区域并回填条件
    window.addEventListener('load', function() {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.toString()) {
            document.getElementById('searchArea').style.display = 'flex';
            // 回填查询条件
            if (urlParams.get('searchUsername')) document.getElementById('searchUsername').value = urlParams.get('searchUsername');
            if (urlParams.get('searchSex')) document.getElementById('searchSex').value = urlParams.get('searchSex');
        }
    });
    
    // 重置查询 - 跳转到无参数的列表页
    function resetSearch() {
        window.location.href = '${pageContext.request.contextPath}/usersList';
    }
    
    // 打开添加模态框
    function openAddModal() {
        document.getElementById('modalTitle').textContent = '添加用户';
        document.getElementById('formAction').value = 'add';
        document.getElementById('userForm').reset();
        document.getElementById('userId').value = '';
        document.getElementById('passwordLabel').textContent = '*';
        document.getElementById('userModal').classList.add('active');
    }
    
    // 打开编辑模态框
    function editUser(id, username, password, sex, age, email, role) {
        document.getElementById('modalTitle').textContent = '编辑用户';
        document.getElementById('formAction').value = 'update';
        document.getElementById('userId').value = id;
        document.getElementById('username').value = username;
        document.getElementById('password').value = password;
        document.getElementById('password').required = false;
        document.getElementById('sex').value = sex;
        document.getElementById('age').value = age;
        document.getElementById('email').value = email;
        document.getElementById('role').value = role;
        document.getElementById('passwordLabel').textContent = '(留空则不修改)';
        document.getElementById('userModal').classList.add('active');
    }
    
    // 关闭模态框
    function closeModal() {
        document.getElementById('userModal').classList.remove('active');
        document.getElementById('password').required = true;
    }
    
    // 删除用户
    function deleteUser(id, username) {
        if (confirm('确定要删除用户 "' + username + '" 吗？此操作不可恢复！')) {
            var formData = new URLSearchParams();
            formData.append('action', 'delete');
            formData.append('id', id);
            formData.append('_csrf', window.parent.CSRF_TOKEN || window.CSRF_TOKEN || '');
            fetch('${pageContext.request.contextPath}/usersList', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData.toString()
            }).then(function(res) {
                return res.json();
            }).then(function(data) {
                if (data.success) {
                    window.location.reload();
                } else {
                    alert(data.error || '删除失败');
                }
            }).catch(function() {
                alert('请求失败，请重试');
            });
        }
    }
    

    
    // 点击遮罩关闭
    document.getElementById('userModal').addEventListener('click', function(e) {
        if (e.target === this) closeModal();
    });
    
    // ESC 关闭
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeModal();
    });
</script>
<!-- ══════════ 主题初始化 ══════════ -->
<script>
(function() {
    var t = 'quantum-matrix';
    try {
        if (window.parent && window.parent !== window) {
            var pt = window.parent.document.documentElement.getAttribute('data-theme');
            if (pt) t = pt;
        }
    } catch (e) {}
    var s = localStorage.getItem('boya-theme');
    if (s) t = s;
    document.documentElement.setAttribute('data-theme', t);
    // 动态加载浅色主题 CSS
    var l = document.createElement('link');
    l.rel = 'stylesheet';
    l.id = 'boya-light-css';
    l.href = '<%= request.getContextPath() %>/CSS/sub-pages-light.css';
    document.head.appendChild(l);
    // 监听主题变化
    window.addEventListener('message', function(e) {
        if (e.data && e.data.type === 'themeChange' && e.data.theme) {
            document.documentElement.setAttribute('data-theme', e.data.theme);
            localStorage.setItem('boya-theme', e.data.theme);
        }
    });
})();
</script>
</body>
</html>
