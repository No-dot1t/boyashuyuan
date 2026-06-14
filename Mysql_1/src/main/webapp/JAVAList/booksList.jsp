<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <!DOCTYPE html>
            <html lang="zh-CN">

            <head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>图书管理 - 博雅书院</title>

                <style>
                    :root {
                        --bg-dark: #0a0c15;
                        --bg-card: rgba(20, 28, 45, 0.85);
                        --glow-cyan: #00f2ff;
                        --accent-red: #ff6464;
                        --accent-green: #4ade80;
                        --accent-purple: #a78bfa;
                        --accent-orange: #fb923c;
                        --text-primary: #ffffff;
                        --text-secondary: #94a3b8;
                        --border-glow: rgba(0, 242, 255, 0.3);
                    }

                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }

                    body {
                        background:
                            radial-gradient(ellipse at 20% 0%, rgba(99, 102, 241, 0.15) 0%, transparent 50%),
                            radial-gradient(ellipse at 80% 100%, rgba(0, 242, 255, 0.1) 0%, transparent 50%),
                            linear-gradient(180deg, #0a0c15 0%, #111827 100%);
                        font-family: 'Inter', 'Segoe UI', -apple-system, sans-serif;
                        min-height: 100vh;
                        color: var(--text-primary);
                        padding: 1.5rem;
                        font-size: 13px;
                        line-height: 1.6;
                    }

                    .page-container {
                        max-width: 1500px;
                        margin: 0 auto;
                    }

                    /* ========== 页面标题区 ========== */
                    .page-header {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        margin-bottom: 1.5rem;
                        padding: 1.2rem 1.8rem;
                        background: linear-gradient(135deg, rgba(30, 41, 59, 0.9), rgba(15, 23, 42, 0.95));
                        border-radius: 16px;
                        border: 1px solid rgba(0, 242, 255, 0.2);
                        box-shadow:
                            0 4px 20px rgba(0, 0, 0, 0.3),
                            inset 0 1px 0 rgba(255, 255, 255, 0.05);
                    }

                    .page-title {
                        display: flex;
                        align-items: center;
                        gap: 0.6rem;
                        font-size: 1.3rem;
                        font-weight: 700;
                        background: linear-gradient(135deg, #fff 0%, #a5f3fc 50%, #67e8f9 100%);
                        -webkit-background-clip: text;
                        background-clip: text;
                        color: transparent;
                        text-shadow: 0 0 30px rgba(0, 242, 255, 0.3);
                    }

                    .page-title::before {
                        content: '📚';
                        filter: drop-shadow(0 0 8px rgba(0, 242, 255, 0.5));
                    }

                    /* ========== 页面标题区按钮组 ========== */
                    .header-actions {
                        display: flex;
                        gap: 10px;
                    }

                    /* ========== 搜索面板 ========== */
                    .search-panel {
                        display: none;
                        margin-bottom: 1.2rem;
                        opacity: 0;
                        transform: translateY(-10px) scale(0.98);
                        transition: opacity 0.3s ease, transform 0.3s ease;
                    }

                    /* 点击搜索按钮时显示 */
                    .search-panel:target {
                        display: block;
                        animation: searchPanelIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
                    }

                    /* 搜索后保持显示 */
                    .search-panel.active {
                        display: block;
                        opacity: 1;
                        transform: translateY(0) scale(1);
                    }

                    @keyframes searchPanelIn {
                        from {
                            opacity: 0;
                            transform: translateY(-15px) scale(0.96);
                        }

                        to {
                            opacity: 1;
                            transform: translateY(0) scale(1);
                        }
                    }

                    .search-form {
                        display: flex;
                        flex-wrap: wrap;
                        align-items: center;
                        gap: 12px;
                        padding: 1rem 1.4rem;
                        background: linear-gradient(145deg, rgba(30, 41, 59, 0.95), rgba(15, 23, 42, 0.98));
                        border-radius: 14px;
                        border: 1px solid rgba(99, 102, 241, 0.2);
                        box-shadow: 0 6px 24px rgba(0, 0, 0, 0.25), 0 0 30px rgba(99, 102, 241, 0.05);
                    }

                    .search-input,
                    .search-select {
                        padding: 8px 12px;
                        border-radius: 8px;
                        border: 1px solid rgba(148, 163, 184, 0.2);
                        background: rgba(15, 23, 42, 0.9);
                        color: #f1f5f9;
                        font-size: 13px;
                        transition: all 0.2s ease;
                        height: 36px;
                    }

                    .search-input {
                        flex: 1;
                        min-width: 140px;
                        max-width: 180px;
                    }

                    .search-input:focus,
                    .search-select:focus {
                        outline: none;
                        border-color: rgba(99, 102, 241, 0.6);
                        box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
                    }

                    .search-input::placeholder {
                        color: #64748b;
                    }

                    .search-select {
                        min-width: 120px;
                        cursor: pointer;
                        appearance: none;
                        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2394a3b8' stroke-width='2'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
                        background-repeat: no-repeat;
                        background-position: right 10px center;
                        padding-right: 32px;
                        scrollbar-width: none;
                        -ms-overflow-style: none;
                    }

                    .search-select::-webkit-scrollbar {
                        display: none;
                        width: 0;
                        height: 0;
                    }

                    .search-select option {
                        background: #1e293b;
                        color: #f1f5f9;
                    }

                    /* ========== 全局滚动条隐藏 ========== */
                    ::-webkit-scrollbar {
                        display: none;
                    }

                    * {
                        scrollbar-width: none;
                        -ms-overflow-style: none;
                    }

                    .search-actions {
                        display: flex;
                        align-items: center;
                        gap: 8px;
                        margin-left: auto;
                    }

                    .btn-search {
                        padding: 8px 16px;
                        border-radius: 8px;
                        border: none;
                        background: linear-gradient(135deg, rgba(99, 102, 241, 0.85), rgba(79, 70, 229, 0.9));
                        color: #fff;
                        font-size: 13px;
                        font-weight: 600;
                        cursor: pointer;
                        display: inline-flex;
                        align-items: center;
                        gap: 6px;
                        transition: all 0.2s ease;
                        text-decoration: none;
                    }

                    .btn-search:hover {
                        background: linear-gradient(135deg, rgba(99, 102, 241, 1), rgba(79, 70, 229, 1));
                        transform: translateY(-1px);
                        box-shadow: 0 4px 12px rgba(99, 102, 241, 0.35);
                    }

                    .btn-reset {
                        padding: 8px 14px;
                        border-radius: 8px;
                        border: 1px solid rgba(148, 163, 184, 0.25);
                        background: rgba(100, 116, 139, 0.15);
                        color: #94a3b8;
                        font-size: 13px;
                        font-weight: 500;
                        text-decoration: none;
                        transition: all 0.2s ease;
                    }

                    .btn-reset:hover {
                        background: rgba(100, 116, 139, 0.25);
                        border-color: rgba(148, 163, 184, 0.4);
                        color: #cbd5e1;
                    }

                    .btn-close-search {
                        padding: 8px 14px;
                        border-radius: 8px;
                        border: 1px solid rgba(239, 68, 68, 0.25);
                        background: rgba(239, 68, 68, 0.1);
                        color: #fca5a5;
                        font-size: 13px;
                        font-weight: 500;
                        text-decoration: none;
                        transition: all 0.2s ease;
                    }

                    .btn-close-search:hover {
                        background: rgba(239, 68, 68, 0.2);
                        border-color: rgba(239, 68, 68, 0.4);
                        color: #fecaca;
                    }

                    .btn-search-toggle {
                        padding: 10px 18px;
                        border-radius: 10px;
                        border: 1px solid rgba(99, 102, 241, 0.35);
                        background: rgba(99, 102, 241, 0.1);
                        color: #a5b4fc;
                        font-size: 13px;
                        font-weight: 500;
                        cursor: pointer;
                        display: inline-flex;
                        align-items: center;
                        gap: 6px;
                        transition: all 0.3s ease;
                        text-decoration: none;
                    }

                    .btn-search-toggle:hover {
                        background: rgba(99, 102, 241, 0.25);
                        border-color: rgba(99, 102, 241, 0.5);
                        transform: translateY(-2px);
                        box-shadow: 0 4px 15px rgba(99, 102, 241, 0.2);
                    }

                    /* 搜索按钮激活状态 */
                    .btn-search-toggle.active {
                        background: rgba(99, 102, 241, 0.3);
                        border-color: rgba(99, 102, 241, 0.6);
                    }

                    /* ========== 按钮样式 ========== */
                    .btn {
                        padding: 10px 20px;
                        border-radius: 10px;
                        border: none;
                        font-size: 13px;
                        font-weight: 600;
                        cursor: pointer;
                        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                        display: inline-flex;
                        align-items: center;
                        gap: 6px;
                        text-decoration: none;
                    }

                    .btn-primary {
                        background: linear-gradient(135deg, rgba(0, 242, 255, 0.25), rgba(99, 102, 241, 0.2));
                        border: 1px solid rgba(0, 242, 255, 0.5);
                        color: #a5f3fc;
                        box-shadow: 0 0 20px rgba(0, 242, 255, 0.15);
                    }

                    .btn-primary:hover {
                        background: linear-gradient(135deg, rgba(0, 242, 255, 0.4), rgba(99, 102, 241, 0.3));
                        transform: translateY(-2px);
                        box-shadow: 0 4px 25px rgba(0, 242, 255, 0.3);
                    }

                    .btn-danger {
                        background: linear-gradient(135deg, rgba(239, 68, 68, 0.2), rgba(220, 38, 38, 0.15));
                        border: 1px solid rgba(239, 68, 68, 0.4);
                        color: #fca5a5;
                    }

                    .btn-danger:hover {
                        background: linear-gradient(135deg, rgba(239, 68, 68, 0.35), rgba(220, 38, 38, 0.25));
                        transform: translateY(-1px);
                        box-shadow: 0 4px 15px rgba(239, 68, 68, 0.25);
                    }

                    .btn-warning {
                        background: linear-gradient(135deg, rgba(251, 191, 36, 0.2), rgba(245, 158, 11, 0.15));
                        border: 1px solid rgba(251, 191, 36, 0.4);
                        color: #fcd34d;
                    }

                    .btn-warning:hover {
                        background: linear-gradient(135deg, rgba(251, 191, 36, 0.35), rgba(245, 158, 11, 0.25));
                        transform: translateY(-1px);
                        box-shadow: 0 4px 15px rgba(251, 191, 36, 0.25);
                    }

                    .btn-sm {
                        padding: 6px 12px;
                        font-size: 12px;
                        border-radius: 8px;
                    }

                    /* ========== 表格卡片 ========== */
                    .table-card {
                        background: linear-gradient(145deg, rgba(30, 41, 59, 0.95), rgba(15, 23, 42, 0.98));
                        border-radius: 20px;
                        border: 1px solid rgba(0, 242, 255, 0.15);
                        overflow-y: auto;
                        max-height: calc(100vh - 140px);
                        box-shadow:
                            0 8px 32px rgba(0, 0, 0, 0.4),
                            0 0 60px rgba(0, 242, 255, 0.05);
                    }

                    .data-table {
                        width: 100%;
                        border-collapse: collapse;
                        min-width: 800px;
                    }

                    .data-table thead {
                        background: linear-gradient(90deg, rgba(0, 242, 255, 0.12), rgba(99, 102, 241, 0.08), rgba(0, 242, 255, 0.12));
                        position: sticky;
                        top: 0;
                        z-index: 10;
                    }

                    .data-table th,
                    .data-table td {
                        padding: 6px 8px;
                        text-align: left;
                        vertical-align: middle;
                    }

                    .data-table th {
                        font-weight: 600;
                        color: #a5f3fc;
                        font-size: 10px;
                        text-transform: uppercase;
                        letter-spacing: 0.5px;
                        border-bottom: 2px solid rgba(0, 242, 255, 0.3);
                        white-space: nowrap;
                        background: linear-gradient(90deg, rgba(0, 242, 255, 0.12), rgba(99, 102, 241, 0.08), rgba(0, 242, 255, 0.12));
                    }

                    .data-table th:nth-child(1),
                    .data-table td:nth-child(1) {
                        width: 50px;
                        text-align: center;
                    }

                    .data-table th:nth-child(2),
                    .data-table td:nth-child(2) {
                        width: 45px;
                        text-align: center;
                    }

                    .data-table th:nth-child(3),
                    .data-table td:nth-child(3) {
                        min-width: 120px;
                    }

                    .data-table th:nth-child(4),
                    .data-table td:nth-child(4) {
                        width: 80px;
                    }

                    .data-table th:nth-child(5),
                    .data-table td:nth-child(5) {
                        min-width: 150px;
                    }

                    .data-table th:nth-child(6),
                    .data-table td:nth-child(6) {
                        width: 80px;
                        text-align: center;
                    }

                    .data-table th:nth-child(7),
                    .data-table td:nth-child(7) {
                        width: 60px;
                        text-align: center;
                    }

                    .data-table th:nth-child(8),
                    .data-table td:nth-child(8) {
                        width: 55px;
                        text-align: center;
                    }

                    .data-table th:nth-child(9),
                    .data-table td:nth-child(9) {
                        width: 55px;
                        text-align: center;
                    }

                    .data-table th:nth-child(10),
                    .data-table td:nth-child(10) {
                        width: 80px;
                        text-align: center;
                    }

                    .data-table td {
                        border-bottom: 1px solid rgba(0, 242, 255, 0.06);
                        font-size: 11px;
                    }

                    .data-table tbody tr {
                        transition: all 0.2s ease;
                    }

                    .data-table tbody tr:hover {
                        background: linear-gradient(90deg, rgba(0, 242, 255, 0.08), rgba(99, 102, 241, 0.05));
                    }

                    .data-table tbody tr:hover td {
                        color: #fff;
                    }

                    /* 封面图片 */
                    .book-cover {
                        width: 40px;
                        height: 55px;
                        object-fit: cover;
                        border-radius: 6px;
                        border: 1px solid rgba(0, 242, 255, 0.2);
                        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
                        transition: transform 0.2s, box-shadow 0.2s;
                    }

                    .book-cover:hover {
                        transform: scale(1.05);
                        box-shadow: 0 4px 15px rgba(0, 242, 255, 0.2);
                    }

                    .cover-link {
                        display: inline-block;
                        cursor: pointer;
                        border-radius: 6px;
                        transition: all 0.25s ease;
                    }

                    .cover-link:hover .book-cover {
                        transform: scale(1.08);
                        box-shadow: 0 0 20px rgba(0, 242, 255, 0.4), 0 4px 15px rgba(0, 242, 255, 0.2);
                    }

                    .cover-link:hover {
                        outline: 2px solid rgba(0, 242, 255, 0.5);
                        outline-offset: 2px;
                    }

                    .book-title {
                        font-weight: 600;
                        color: #e2e8f0;
                        max-width: 115px;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        white-space: nowrap;
                        display: block;
                    }

                    .book-author {
                        color: #94a3b8;
                        max-width: 75px;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        white-space: nowrap;
                        display: block;
                    }

                    .book-summary {
                        color: #64748b;
                        max-width: 145px;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        white-space: nowrap;
                        display: block;
                    }

                    .book-type {
                        display: inline-block;
                        padding: 4px 10px;
                        border-radius: 20px;
                        font-size: 11px;
                        font-weight: 500;
                        background: linear-gradient(135deg, rgba(167, 139, 250, 0.2), rgba(139, 92, 246, 0.15));
                        border: 1px solid rgba(167, 139, 250, 0.3);
                        color: #c4b5fd;
                    }

                    .download-count {
                        display: flex;
                        align-items: center;
                        gap: 4px;
                        color: #fb923c;
                        font-weight: 500;
                    }

                    .download-count::before {
                        content: '⬇';
                        font-size: 11px;
                    }

                    .book-year {
                        color: #94a3b8;
                        font-size: 12px;
                    }

                    .book-format {
                        display: inline-block;
                        padding: 3px 8px;
                        border-radius: 4px;
                        font-size: 10px;
                        font-weight: 600;
                        text-transform: uppercase;
                        background: rgba(0, 242, 255, 0.1);
                        border: 1px solid rgba(0, 242, 255, 0.2);
                        color: #67e8f9;
                    }

                    .action-buttons {
                        display: flex;
                        gap: 8px;
                        flex-wrap: wrap;
                    }

                    /* 空状态 */
                    .empty-state {
                        text-align: center;
                        padding: 60px 20px;
                        color: #64748b;
                    }

                    .empty-state-icon {
                        font-size: 48px;
                        margin-bottom: 16px;
                        opacity: 0.5;
                    }

                    .empty-state-text {
                        font-size: 14px;
                    }

                    /* 表格卡片可滑动，但隐藏滚动条 */
                    .table-card::-webkit-scrollbar {
                        display: none;
                    }

                    .table-card {
                        scrollbar-width: none;
                        -ms-overflow-style: none;
                    }

                    /* 斑马纹 */
                    .data-table tbody tr:nth-child(even) {
                        background: rgba(0, 0, 0, 0.15);
                    }

                    .data-table tbody tr:nth-child(even):hover {
                        background: linear-gradient(90deg, rgba(0, 242, 255, 0.08), rgba(99, 102, 241, 0.05));
                    }

                    /* =============================================== */
                    /* ========== 纯CSS弹窗样式 - :target伪类 ========== */
                    /* =============================================== */

                    /* 弹窗遮罩层 - 默认隐藏 */
                    .modal-overlay {
                        display: none;
                        position: fixed;
                        top: 0;
                        left: 0;
                        width: 100%;
                        height: 100%;
                        background: rgba(0, 0, 0, 0.75);
                        backdrop-filter: blur(8px);
                        z-index: 1000;
                        justify-content: center;
                        align-items: center;
                        animation: fadeIn 0.3s ease;
                    }

                    @keyframes fadeIn {
                        from {
                            opacity: 0;
                        }

                        to {
                            opacity: 1;
                        }
                    }

                    /* 弹窗主体 - 默认隐藏 */
                    .modal-dialog {
                        display: none;
                        position: relative;
                        width: 90%;
                        max-width: 560px;
                        max-height: 80vh;
                        margin-top: 5vh;
                        background: linear-gradient(160deg, #1e293b 0%, #0f172a 50%, #1a1f35 100%);
                        border-radius: 24px;
                        border: 1px solid rgba(148, 163, 184, 0.15);
                        box-shadow:
                            0 25px 80px rgba(0, 0, 0, 0.6),
                            0 0 50px rgba(99, 102, 241, 0.08),
                            inset 0 1px 0 rgba(255, 255, 255, 0.08);
                        animation: modalSlideIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1);
                        flex-direction: column;
                    }

                    @keyframes modalSlideIn {
                        from {
                            opacity: 0;
                            transform: scale(0.9) translateY(-30px);
                        }

                        to {
                            opacity: 1;
                            transform: scale(1) translateY(0);
                        }
                    }

                    /* 弹窗头部 - 固定不滚动 */
                    .modal-header {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        padding: 1.4rem 1.8rem;
                        background: linear-gradient(135deg, rgba(99, 102, 241, 0.12) 0%, rgba(0, 242, 255, 0.06) 100%);
                        border-bottom: 1px solid rgba(148, 163, 184, 0.1);
                        position: sticky;
                        top: 0;
                        z-index: 10;
                        flex-shrink: 0;
                    }

                    .modal-header::after {
                        content: '';
                        position: absolute;
                        bottom: 0;
                        left: 50%;
                        transform: translateX(-50%);
                        width: 60%;
                        height: 1px;
                        background: linear-gradient(90deg, transparent, rgba(0, 242, 255, 0.3), transparent);
                    }

                    .modal-title {
                        font-size: 1.2rem;
                        font-weight: 600;
                        color: #f1f5f9;
                        letter-spacing: 0.5px;
                    }

                    .modal-close {
                        position: relative;
                        width: 28px;
                        height: 28px;
                        border: none;
                        background: transparent;
                        cursor: pointer;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        transition: all 0.25s ease;
                        border-radius: 6px;
                    }

                    .modal-close::before,
                    .modal-close::after {
                        content: '';
                        position: absolute;
                        width: 16px;
                        height: 2px;
                        background: #64748b;
                        border-radius: 2px;
                        transition: all 0.25s ease;
                    }

                    .modal-close::before {
                        transform: rotate(45deg);
                    }

                    .modal-close::after {
                        transform: rotate(-45deg);
                    }

                    .modal-close:hover {
                        background: rgba(239, 68, 68, 0.15);
                    }

                    .modal-close:hover::before,
                    .modal-close:hover::after {
                        background: #ef4444;
                    }

                    /* 弹窗内容区 - 不再滚动，select 下拉可正常弹出 */
                    .modal-body {
                        padding: 1.8rem;
                        overflow: visible;
                        flex-shrink: 1;
                        background: linear-gradient(180deg, rgba(30, 41, 59, 0.3), transparent);
                    }

                    /* 弹窗底部按钮区 - 固定不滚动 */
                    .modal-footer {
                        display: flex;
                        justify-content: flex-end;
                        gap: 1rem;
                        padding: 1.2rem 1.8rem;
                        background: linear-gradient(135deg, rgba(15, 23, 42, 0.8), rgba(30, 41, 59, 0.6));
                        border-top: 1px solid rgba(148, 163, 184, 0.08);
                        position: sticky;
                        bottom: 0;
                        z-index: 10;
                        flex-shrink: 0;
                    }

                    .modal-footer .btn {
                        padding: 12px 28px;
                        border-radius: 12px;
                    }

                    /* ========== 关键：:target 激活弹窗 ========== */

                    /* 当 URL 带有 #add-modal 时显示 */
                    .modal-overlay:target,
                    .modal-overlay:target .modal-dialog {
                        display: flex;
                        flex-direction: column;
                    }

                    /* 弹窗可滚动，但隐藏滚动条 */
                    .modal-overlay:target .modal-dialog {
                        overflow-y: auto;
                        overflow-x: hidden;
                        scrollbar-width: none;
                        -ms-overflow-style: none;
                    }

                    .modal-overlay:target .modal-dialog::-webkit-scrollbar {
                        display: none;
                    }

                    /* ========== 表单样式（弹窗内） ========== */
                    .form-group {
                        margin-bottom: 1.2rem;
                    }

                    .form-label {
                        display: block;
                        margin-bottom: 8px;
                        font-size: 12px;
                        font-weight: 500;
                        color: #94a3b8;
                        letter-spacing: 0.3px;
                        text-transform: uppercase;
                    }

                    .form-label::before {
                        content: '▸ ';
                        color: rgba(99, 102, 241, 0.6);
                        font-size: 10px;
                    }

                    .form-input,
                    .form-select,
                    .form-textarea {
                        width: 100%;
                        padding: 12px 16px;
                        border-radius: 12px;
                        border: 1px solid rgba(148, 163, 184, 0.2);
                        background: linear-gradient(135deg, rgba(15, 23, 42, 0.9), rgba(30, 41, 59, 0.7));
                        color: #f1f5f9;
                        font-size: 14px;
                        font-family: inherit;
                        transition: all 0.3s ease;
                    }

                    .form-input:focus,
                    .form-select:focus,
                    .form-textarea:focus {
                        outline: none;
                        border-color: rgba(99, 102, 241, 0.6);
                        box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15), 0 4px 15px rgba(0, 0, 0, 0.2);
                        transform: translateY(-1px);
                    }

                    .form-input::placeholder {
                        color: #475569;
                    }

                    .form-select {
                        cursor: pointer;
                        appearance: none;
                        -webkit-appearance: none;
                        -moz-appearance: none;
                        padding-right: 36px;
                        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2394a3b8' stroke-width='2'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
                        background-repeat: no-repeat;
                        background-position: right 12px center;
                    }

                    /* 下拉框容器（用于定位） */
                    .form-select-wrapper {
                        position: relative;
                    }

                    .form-select option {
                        background: #1e293b;
                        color: #f1f5f9;
                        padding: 8px 12px;
                    }

                    .form-textarea {
                        resize: vertical;
                        min-height: 90px;
                        line-height: 1.6;
                    }

                    .form-row {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 1.2rem;
                    }

                    .form-input[readonly] {
                        background: rgba(0, 0, 0, 0.3);
                        color: #64748b;
                        cursor: not-allowed;
                    }

                    /* ========== 文件上传区域美化 ========== */
                    .file-upload-area {
                        position: relative;
                        width: 100%;
                        min-height: 80px;
                        border: 2px dashed rgba(99, 102, 241, 0.35);
                        border-radius: 12px;
                        background: linear-gradient(135deg, rgba(15, 23, 42, 0.6), rgba(30, 41, 59, 0.4));
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        justify-content: center;
                        gap: 4px;
                        padding: 10px;
                        cursor: pointer;
                        transition: all 0.3s ease;
                        overflow: hidden;
                    }

                    .file-upload-area:hover {
                        border-color: rgba(99, 102, 241, 0.7);
                        background: linear-gradient(135deg, rgba(99, 102, 241, 0.08), rgba(79, 70, 229, 0.05));
                        box-shadow: 0 0 30px rgba(99, 102, 241, 0.1);
                    }

                    .file-upload-area.has-file {
                        border-style: solid;
                        border-color: rgba(74, 222, 128, 0.4);
                        background: linear-gradient(135deg, rgba(74, 222, 128, 0.06), rgba(34, 197, 94, 0.04));
                    }

                    .file-upload-area .upload-icon {
                        width: 32px;
                        height: 32px;
                        border-radius: 8px;
                        background: linear-gradient(135deg, rgba(99, 102, 241, 0.2), rgba(79, 70, 229, 0.15));
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        transition: all 0.3s ease;
                    }

                    .file-upload-area:hover .upload-icon {
                        transform: translateY(-1px);
                        background: linear-gradient(135deg, rgba(99, 102, 241, 0.3), rgba(79, 70, 229, 0.25));
                        box-shadow: 0 2px 8px rgba(99, 102, 241, 0.2);
                    }

                    .file-upload-area .upload-icon svg {
                        width: 16px;
                        height: 16px;
                        color: #a5b4fc;
                        transition: all 0.3s ease;
                    }

                    .file-upload-area:hover .upload-icon svg {
                        color: #c7d2fe;
                    }

                    .file-upload-area .upload-text {
                        font-size: 12px;
                        font-weight: 500;
                        color: #94a3b8;
                        text-align: center;
                        transition: color 0.3s ease;
                    }

                    .file-upload-area:hover .upload-text {
                        color: #cbd5e1;
                    }

                    .file-upload-area .upload-hint {
                        font-size: 10px;
                        color: #64748b;
                        text-align: center;
                    }

                    .file-upload-area input[type="file"] {
                        position: absolute;
                        top: 0;
                        left: 0;
                        width: 100%;
                        height: 100%;
                        opacity: 0;
                        cursor: pointer;
                        z-index: 2;
                    }

                    /* 图片预览 */
                    .file-upload-area .preview-image {
                        max-width: 100%;
                        max-height: 70px;
                        border-radius: 6px;
                        object-fit: cover;
                        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
                        display: none;
                    }

                    .file-upload-area .preview-image.show {
                        display: block;
                    }

                    .file-upload-area .file-info {
                        display: none;
                        align-items: center;
                        gap: 8px;
                        padding: 8px 14px;
                        background: rgba(74, 222, 128, 0.1);
                        border: 1px solid rgba(74, 222, 128, 0.2);
                        border-radius: 10px;
                        font-size: 12px;
                        color: #86efac;
                    }

                    .file-upload-area .file-info.show {
                        display: flex;
                    }

                    .file-upload-area .file-info svg {
                        width: 16px;
                        height: 16px;
                        color: #4ade80;
                        flex-shrink: 0;
                    }

                    .file-upload-area .file-name {
                        max-width: 200px;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        white-space: nowrap;
                    }

                    .file-upload-area .remove-file {
                        position: absolute;
                        top: 8px;
                        right: 8px;
                        width: 24px;
                        height: 24px;
                        border-radius: 6px;
                        background: rgba(239, 68, 68, 0.2);
                        border: 1px solid rgba(239, 68, 68, 0.3);
                        color: #fca5a5;
                        display: none;
                        align-items: center;
                        justify-content: center;
                        cursor: pointer;
                        z-index: 3;
                        font-size: 14px;
                        line-height: 1;
                        transition: all 0.2s ease;
                    }

                    .file-upload-area .remove-file:hover {
                        background: rgba(239, 68, 68, 0.35);
                        color: #fecaca;
                    }

                    .file-upload-area .remove-file.show {
                        display: flex;
                    }

                    /* 拖拽时的样式 */
                    .file-upload-area.drag-over {
                        border-color: rgba(99, 102, 241, 0.9);
                        background: linear-gradient(135deg, rgba(99, 102, 241, 0.12), rgba(79, 70, 229, 0.08));
                        box-shadow: 0 0 40px rgba(99, 102, 241, 0.15);
                        transform: scale(1.01);
                    }

                    /* 上传内容区默认隐藏，有文件时显示 */
                    .file-upload-area .upload-content {
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        gap: 8px;
                        transition: all 0.3s ease;
                    }

                    .file-upload-area .upload-content.hidden {
                        display: none;
                    }

                    /* ========== 弹窗底部按钮样式 ========== */
                    .btn-cancel {
                        padding: 12px 28px;
                        border-radius: 12px;
                        border: 1px solid rgba(148, 163, 184, 0.2);
                        background: rgba(100, 116, 139, 0.15);
                        color: #94a3b8;
                        font-size: 14px;
                        font-weight: 500;
                        text-decoration: none;
                        cursor: pointer;
                        transition: all 0.3s ease;
                    }

                    .btn-cancel:hover {
                        background: rgba(100, 116, 139, 0.25);
                        border-color: rgba(148, 163, 184, 0.3);
                        color: #cbd5e1;
                    }

                    .btn-submit {
                        padding: 12px 32px;
                        border-radius: 12px;
                        border: none;
                        background: linear-gradient(135deg, rgba(99, 102, 241, 0.8), rgba(79, 70, 229, 0.9));
                        color: #fff;
                        font-size: 14px;
                        font-weight: 600;
                        cursor: pointer;
                        transition: all 0.3s ease;
                        box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3);
                    }

                    .btn-submit:hover {
                        background: linear-gradient(135deg, rgba(99, 102, 241, 1), rgba(79, 70, 229, 1));
                        transform: translateY(-2px);
                        box-shadow: 0 6px 20px rgba(99, 102, 241, 0.4);
                    }

                    /* ========== 二级联动下拉 ========== */
                    .cascade-group {
                        display: flex;
                        gap: 8px;
                        flex: 1;
                        min-width: 200px;
                    }

                    .cascade-group .search-select {
                        flex: 1;
                        min-width: 100px !important;
                        max-width: 140px !important;
                    }

                    /* 弹窗内的联动下拉 - 横排 */
                    .cascade-row {
                        display: flex;
                        gap: 10px;
                        width: 100%;
                    }

                    .cascade-row .form-select {
                        flex: 1;
                        margin-bottom: 0 !important;
                    }

                    /* ========== 错误消息横幅 ========== */
                    .error-banner {
                        display: none;
                        align-items: center;
                        gap: 12px;
                        padding: 0.8rem 1.4rem;
                        margin-bottom: 1rem;
                        background: linear-gradient(135deg, rgba(239, 68, 68, 0.15), rgba(220, 38, 38, 0.1));
                        border: 1px solid rgba(239, 68, 68, 0.3);
                        border-radius: 14px;
                        color: #fca5a5;
                        font-size: 13px;
                        animation: fadeIn 0.3s ease;
                    }

                    .error-banner.show {
                        display: flex;
                    }

                    .error-banner .error-close {
                        margin-left: auto;
                        cursor: pointer;
                        width: 22px;
                        height: 22px;
                        border-radius: 6px;
                        border: 1px solid rgba(239, 68, 68, 0.3);
                        background: transparent;
                        color: #fca5a5;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 14px;
                        transition: all 0.2s;
                    }

                    .error-banner .error-close:hover {
                        background: rgba(239, 68, 68, 0.25);
                    }

                    /* ========== 多文件列表 ========== */
                    .file-list {
                        display: none;
                    }

                    .file-list.show {
                        display: block;
                        margin-top: 4px;
                    }

                    .file-list-item {
                        display: flex;
                        align-items: center;
                        gap: 8px;
                        padding: 4px 10px;
                        font-size: 11px;
                        color: #86efac;
                        border-radius: 6px;
                        background: rgba(74, 222, 128, 0.06);
                        margin-bottom: 2px;
                    }

                    .file-list-item::before {
                        content: '📄';
                        font-size: 10px;
                    }

                    /* ========== 上传加载状态 ========== */
                    .upload-loading {
                        display: none;
                        align-items: center;
                        gap: 8px;
                        padding: 8px 16px;
                        background: rgba(99, 102, 241, 0.1);
                        border-radius: 10px;
                        font-size: 12px;
                        color: #a5b4fc;
                    }

                    .upload-loading.show {
                        display: flex;
                    }

                    .upload-loading .spinner {
                        width: 16px;
                        height: 16px;
                        border: 2px solid rgba(99, 102, 241, 0.3);
                        border-top-color: #a5b4fc;
                        border-radius: 50%;
                        animation: spin 0.8s linear infinite;
                    }

                    @keyframes spin {
                        to {
                            transform: rotate(360deg);
                        }
                    }
                    /* ══════════ 浅色主题 · 图书管理全覆盖 ══════════ */
                    html[data-theme$="-light"] body {
                        background: linear-gradient(170deg, #e9e2d2, #ede5d3 40%, #e4dbca) !important;
                        color: #3d3929 !important;
                    }
                    /* ── 页面头部 ── */
                    html[data-theme$="-light"] .page-header {
                        background: linear-gradient(135deg, rgba(238, 233, 222, 0.9), rgba(243, 239, 228, 0.95)) !important;
                        border-color: rgba(37, 99, 235, 0.1) !important;
                        box-shadow: 0 4px 20px rgba(139, 119, 80, 0.08), inset 0 1px 0 rgba(255, 255, 255, 0.3) !important;
                    }
                    html[data-theme$="-light"] .page-title {
                        background: linear-gradient(135deg, #3d3929, #2563eb) !important;
                        -webkit-background-clip: text !important;
                        background-clip: text !important;
                        color: transparent !important;
                        text-shadow: none !important;
                    }
                    html[data-theme$="-light"] .page-title::before {
                        filter: drop-shadow(0 0 4px rgba(37, 99, 235, 0.25)) !important;
                    }
                    /* ── 搜索面板 ── */
                    html[data-theme$="-light"] .search-form {
                        background: linear-gradient(145deg, rgba(238, 233, 222, 0.95), rgba(243, 239, 228, 0.98)) !important;
                        border-color: rgba(37, 99, 235, 0.1) !important;
                        box-shadow: 0 6px 20px rgba(139, 119, 80, 0.08), 0 0 20px rgba(37, 99, 235, 0.04) !important;
                    }
                    html[data-theme$="-light"] .search-input,
                    html[data-theme$="-light"] .search-select {
                        background: rgba(238, 233, 222, 0.85) !important;
                        border-color: rgba(139, 119, 80, 0.1) !important;
                        color: #3d3929 !important;
                    }
                    html[data-theme$="-light"] .search-input:focus,
                    html[data-theme$="-light"] .search-select:focus {
                        border-color: rgba(37, 99, 235, 0.25) !important;
                        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.08) !important;
                    }
                    html[data-theme$="-light"] .search-input::placeholder {
                        color: rgba(61, 57, 41, 0.3) !important;
                    }
                    html[data-theme$="-light"] .search-select option {
                        background: #f0ebe0 !important;
                        color: #3d3929 !important;
                    }
                    /* ── 搜索按钮 ── */
                    html[data-theme$="-light"] .btn-search {
                        background: linear-gradient(135deg, rgba(37, 99, 235, 0.12), rgba(79, 70, 229, 0.08)) !important;
                        color: #2563eb !important;
                    }
                    html[data-theme$="-light"] .btn-search:hover {
                        background: linear-gradient(135deg, rgba(37, 99, 235, 0.22), rgba(79, 70, 229, 0.15)) !important;
                        box-shadow: 0 4px 12px rgba(37, 99, 235, 0.1) !important;
                    }
                    html[data-theme$="-light"] .btn-reset {
                        background: rgba(139, 119, 80, 0.04) !important;
                        border-color: rgba(139, 119, 80, 0.1) !important;
                        color: #7a7360 !important;
                    }
                    html[data-theme$="-light"] .btn-reset:hover {
                        background: rgba(139, 119, 80, 0.1) !important;
                        border-color: rgba(139, 119, 80, 0.18) !important;
                        color: #3d3929 !important;
                    }
                    html[data-theme$="-light"] .btn-close-search {
                        background: rgba(220, 60, 60, 0.05) !important;
                        border-color: rgba(220, 60, 60, 0.12) !important;
                        color: #b91c1c !important;
                    }
                    html[data-theme$="-light"] .btn-close-search:hover {
                        background: rgba(220, 60, 60, 0.12) !important;
                        border-color: rgba(220, 60, 60, 0.25) !important;
                    }
                    html[data-theme$="-light"] .btn-search-toggle {
                        background: rgba(37, 99, 235, 0.06) !important;
                        border-color: rgba(37, 99, 235, 0.12) !important;
                        color: #2563eb !important;
                    }
                    html[data-theme$="-light"] .btn-search-toggle:hover {
                        background: rgba(37, 99, 235, 0.15) !important;
                        border-color: rgba(37, 99, 235, 0.25) !important;
                        box-shadow: 0 4px 12px rgba(37, 99, 235, 0.08) !important;
                    }
                    html[data-theme$="-light"] .btn-search-toggle.active {
                        background: rgba(37, 99, 235, 0.15) !important;
                        border-color: rgba(37, 99, 235, 0.3) !important;
                    }
                    /* ── 通用按钮 ── */
                    html[data-theme$="-light"] .btn-primary {
                        background: linear-gradient(135deg, rgba(37, 99, 235, 0.1), rgba(124, 58, 237, 0.06)) !important;
                        border-color: rgba(37, 99, 235, 0.18) !important;
                        color: #2563eb !important;
                        box-shadow: 0 2px 10px rgba(37, 99, 235, 0.04) !important;
                    }
                    html[data-theme$="-light"] .btn-primary:hover {
                        background: linear-gradient(135deg, rgba(37, 99, 235, 0.2), rgba(124, 58, 237, 0.12)) !important;
                        box-shadow: 0 4px 16px rgba(37, 99, 235, 0.1) !important;
                    }
                    html[data-theme$="-light"] .btn-danger {
                        background: rgba(220, 60, 60, 0.06) !important;
                        border-color: rgba(220, 60, 60, 0.12) !important;
                        color: #b91c1c !important;
                    }
                    html[data-theme$="-light"] .btn-danger:hover {
                        background: rgba(220, 60, 60, 0.12) !important;
                        box-shadow: 0 4px 12px rgba(220, 60, 60, 0.08) !important;
                    }
                    html[data-theme$="-light"] .btn-warning {
                        background: rgba(245, 158, 11, 0.06) !important;
                        border-color: rgba(245, 158, 11, 0.12) !important;
                        color: #b45309 !important;
                    }
                    html[data-theme$="-light"] .btn-warning:hover {
                        background: rgba(245, 158, 11, 0.12) !important;
                        box-shadow: 0 4px 12px rgba(245, 158, 11, 0.08) !important;
                    }
                    /* ── 表格卡片 ── */
                    html[data-theme$="-light"] .table-card {
                        background: linear-gradient(145deg, rgba(238, 233, 222, 0.92), rgba(243, 239, 228, 0.95)) !important;
                        border-color: rgba(139, 119, 80, 0.06) !important;
                        box-shadow: 0 8px 28px rgba(139, 119, 80, 0.08), 0 0 40px rgba(37, 99, 235, 0.03) !important;
                    }
                    html[data-theme$="-light"] .data-table thead {
                        background: linear-gradient(90deg, rgba(37, 99, 235, 0.04), rgba(139, 119, 80, 0.02), rgba(37, 99, 235, 0.04)) !important;
                    }
                    html[data-theme$="-light"] .data-table th {
                        color: #5c5540 !important;
                        border-bottom-color: rgba(139, 119, 80, 0.1) !important;
                        background: linear-gradient(90deg, rgba(37, 99, 235, 0.04), rgba(139, 119, 80, 0.02), rgba(37, 99, 235, 0.04)) !important;
                    }
                    html[data-theme$="-light"] .data-table td {
                        color: #3d3929 !important;
                        border-bottom-color: rgba(139, 119, 80, 0.04) !important;
                    }
                    html[data-theme$="-light"] .data-table tbody tr:hover {
                        background: linear-gradient(90deg, rgba(37, 99, 235, 0.04), rgba(124, 58, 237, 0.02)) !important;
                    }
                    html[data-theme$="-light"] .data-table tbody tr:hover td {
                        color: #3d3929 !important;
                    }
                    html[data-theme$="-light"] .data-table tbody tr:nth-child(even) {
                        background: rgba(139, 119, 80, 0.03) !important;
                    }
                    html[data-theme$="-light"] .data-table tbody tr:nth-child(even):hover {
                        background: linear-gradient(90deg, rgba(37, 99, 235, 0.04), rgba(124, 58, 237, 0.02)) !important;
                    }
                    /* ── 书籍展示 ── */
                    html[data-theme$="-light"] .book-cover {
                        border-color: rgba(139, 119, 80, 0.1) !important;
                        box-shadow: 0 2px 8px rgba(139, 119, 80, 0.1) !important;
                    }
                    html[data-theme$="-light"] .cover-link:hover .book-cover {
                        box-shadow: 0 0 16px rgba(37, 99, 235, 0.15), 0 4px 12px rgba(37, 99, 235, 0.08) !important;
                    }
                    html[data-theme$="-light"] .cover-link:hover {
                        outline-color: rgba(37, 99, 235, 0.25) !important;
                    }
                    html[data-theme$="-light"] .book-title { color: #3d3929 !important; }
                    html[data-theme$="-light"] .book-author { color: #7a7360 !important; }
                    html[data-theme$="-light"] .book-summary { color: #8a8370 !important; }
                    html[data-theme$="-light"] .book-type {
                        background: linear-gradient(135deg, rgba(124, 58, 237, 0.06), rgba(139, 92, 246, 0.04)) !important;
                        border-color: rgba(124, 58, 237, 0.12) !important;
                        color: #7c3aed !important;
                    }
                    html[data-theme$="-light"] .download-count { color: #b45309 !important; }
                    html[data-theme$="-light"] .book-year { color: #7a7360 !important; }
                    html[data-theme$="-light"] .book-format {
                        background: rgba(37, 99, 235, 0.06) !important;
                        border-color: rgba(37, 99, 235, 0.12) !important;
                        color: #2563eb !important;
                    }
                    /* ── 空状态 ── */
                    html[data-theme$="-light"] .empty-state { color: #8a8370 !important; }
                    html[data-theme$="-light"] .empty-state-icon { opacity: 0.35 !important; }
                    html[data-theme$="-light"] .empty-state-text { color: #7a7360 !important; }
                    /* ── 模态框 ── */
                    html[data-theme$="-light"] .modal-overlay {
                        background: rgba(61, 57, 41, 0.35) !important;
                    }
                    html[data-theme$="-light"] .modal-dialog {
                        background: linear-gradient(160deg, rgba(238, 233, 222, 0.98), rgba(245, 240, 232, 0.96), rgba(240, 235, 225, 0.97)) !important;
                        border-color: rgba(37, 99, 235, 0.1) !important;
                        box-shadow: 0 25px 80px rgba(139, 119, 80, 0.15), 0 0 40px rgba(37, 99, 235, 0.04), inset 0 1px 0 rgba(255, 255, 255, 0.5) !important;
                    }
                    html[data-theme$="-light"] .modal-header {
                        background: linear-gradient(135deg, rgba(37, 99, 235, 0.04), rgba(139, 119, 80, 0.02)) !important;
                        border-bottom-color: rgba(139, 119, 80, 0.06) !important;
                    }
                    html[data-theme$="-light"] .modal-header::after {
                        background: linear-gradient(90deg, transparent, rgba(37, 99, 235, 0.15), transparent) !important;
                    }
                    html[data-theme$="-light"] .modal-title { color: #3d3929 !important; }
                    html[data-theme$="-light"] .modal-close::before,
                    html[data-theme$="-light"] .modal-close::after {
                        background: #8a8370 !important;
                    }
                    html[data-theme$="-light"] .modal-close:hover {
                        background: rgba(220, 60, 60, 0.1) !important;
                    }
                    html[data-theme$="-light"] .modal-close:hover::before,
                    html[data-theme$="-light"] .modal-close:hover::after {
                        background: #b91c1c !important;
                    }
                    html[data-theme$="-light"] .modal-body {
                        background: linear-gradient(180deg, rgba(238, 233, 222, 0.2), transparent) !important;
                    }
                    html[data-theme$="-light"] .modal-footer {
                        background: linear-gradient(135deg, rgba(243, 239, 228, 0.7), rgba(238, 233, 222, 0.5)) !important;
                        border-top-color: rgba(139, 119, 80, 0.05) !important;
                    }
                    /* ── 表单 ── */
                    html[data-theme$="-light"] .form-label { color: #5c5540 !important; }
                    html[data-theme$="-light"] .form-label::before { color: rgba(37, 99, 235, 0.5) !important; }
                    html[data-theme$="-light"] .form-input,
                    html[data-theme$="-light"] .form-select,
                    html[data-theme$="-light"] .form-textarea {
                        background: linear-gradient(135deg, rgba(238, 233, 222, 0.9), rgba(243, 239, 228, 0.8)) !important;
                        border-color: rgba(139, 119, 80, 0.1) !important;
                        color: #3d3929 !important;
                    }
                    html[data-theme$="-light"] .form-input:focus,
                    html[data-theme$="-light"] .form-select:focus,
                    html[data-theme$="-light"] .form-textarea:focus {
                        border-color: rgba(37, 99, 235, 0.25) !important;
                        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.08), 0 4px 12px rgba(139, 119, 80, 0.06) !important;
                    }
                    html[data-theme$="-light"] .form-input::placeholder { color: rgba(61, 57, 41, 0.25) !important; }
                    html[data-theme$="-light"] .form-select option {
                        background: #f0ebe0 !important;
                        color: #3d3929 !important;
                    }
                    html[data-theme$="-light"] .form-input[readonly] {
                        background: rgba(139, 119, 80, 0.06) !important;
                        color: #8a8370 !important;
                    }
                    /* ── 文件上传 ── */
                    html[data-theme$="-light"] .file-upload-area {
                        background: linear-gradient(135deg, rgba(238, 233, 222, 0.6), rgba(243, 239, 228, 0.4)) !important;
                        border-color: rgba(37, 99, 235, 0.12) !important;
                    }
                    html[data-theme$="-light"] .file-upload-area:hover {
                        border-color: rgba(37, 99, 235, 0.3) !important;
                        background: linear-gradient(135deg, rgba(37, 99, 235, 0.04), rgba(79, 70, 229, 0.02)) !important;
                        box-shadow: 0 0 20px rgba(37, 99, 235, 0.06) !important;
                    }
                    html[data-theme$="-light"] .file-upload-area .upload-icon {
                        background: linear-gradient(135deg, rgba(37, 99, 235, 0.08), rgba(79, 70, 229, 0.05)) !important;
                    }
                    html[data-theme$="-light"] .file-upload-area .upload-icon svg { color: #2563eb !important; }
                    html[data-theme$="-light"] .file-upload-area .upload-text { color: #7a7360 !important; }
                    html[data-theme$="-light"] .file-upload-area:hover .upload-text { color: #5c5540 !important; }
                    html[data-theme$="-light"] .file-upload-area .upload-hint,
                    html[data-theme$="-light"] .file-upload-area:hover .upload-hint { color: #8a8370 !important; }
                    html[data-theme$="-light"] .file-upload-area.has-file {
                        border-color: rgba(5, 150, 105, 0.2) !important;
                        background: linear-gradient(135deg, rgba(5, 150, 105, 0.03), rgba(34, 197, 94, 0.02)) !important;
                    }
                    html[data-theme$="-light"] .file-upload-area:hover .upload-icon {
                        background: linear-gradient(135deg, rgba(37, 99, 235, 0.15), rgba(79, 70, 229, 0.1)) !important;
                        box-shadow: 0 2px 6px rgba(37, 99, 235, 0.1) !important;
                    }
                    html[data-theme$="-light"] .file-upload-area:hover .upload-icon svg { color: #1d4ed8 !important; }
                    /* ── 错误横幅 ── */
                    html[data-theme$="-light"] .error-banner {
                        background: linear-gradient(135deg, rgba(220, 60, 60, 0.06), rgba(220, 38, 38, 0.04)) !important;
                        border-color: rgba(220, 60, 60, 0.15) !important;
                        color: #b91c1c !important;
                    }
                    html[data-theme$="-light"] .error-banner .error-close {
                        border-color: rgba(220, 60, 60, 0.15) !important;
                        color: #b91c1c !important;
                    }
                    html[data-theme$="-light"] .error-banner .error-close:hover {
                        background: rgba(220, 60, 60, 0.12) !important;
                    }
                    /* ── 文件列表项 ── */
                    html[data-theme$="-light"] .file-list-item {
                        color: #047857 !important;
                        background: rgba(5, 150, 105, 0.06) !important;
                    }
                    /* ── 上传加载 ── */
                    html[data-theme$="-light"] .upload-loading {
                        background: rgba(37, 99, 235, 0.06) !important;
                        color: #2563eb !important;
                    }
                    html[data-theme$="-light"] .upload-loading .spinner {
                        border-color: rgba(37, 99, 235, 0.2) !important;
                        border-top-color: #2563eb !important;
                    }
                    /* ── 通用 ── */
                    html[data-theme$="-light"] h1, html[data-theme$="-light"] h2, html[data-theme$="-light"] h3 { color: #3d3929 !important; }
                    html[data-theme$="-light"] ::selection { background: rgba(37, 99, 235, 0.15) !important; color: #3d3929 !important; }
                </style>
            </head>

            <body>
                <div class="page-container">
                    <!-- ========== 页面标题区 ========== -->
                    <div class="page-header">
                        <div class="page-title">📚 图书管理</div>
                        <div class="header-actions">
                            <!-- 搜索按钮 - 点击展开搜索表单 -->
                            <a href="#search-panel" class="btn btn-search-toggle">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2">
                                    <circle cx="11" cy="11" r="8" />
                                    <path d="m21 21-4.35-4.35" />
                                </svg>
                                搜索
                            </a>
                            <!-- 添加按钮 - 链接到 #add-modal -->
                            <a href="#add-modal" class="btn btn-primary">添加图书</a>
                        </div>
                    </div>

                    <!-- ========== [P1] 错误消息横幅（从 session 读取一次性错误） ========== -->
                    <div id="errorBanner" class="error-banner ${not empty uploadError ? 'show' : ''}">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                            stroke-width="2" style="flex-shrink:0;">
                            <circle cx="12" cy="12" r="10" />
                            <line x1="12" y1="8" x2="12" y2="12" />
                            <line x1="12" y1="16" x2="12.01" y2="16" />
                        </svg>
                        <span id="errorMessage">${uploadError}</span>
                        <button class="error-close"
                            onclick="document.getElementById('errorBanner').classList.remove('show')">&times;</button>
                    </div>

                    <!-- ========== 学域来源横幅 ========== -->
                    <c:if test="${fromMajor}">
                        <div
                            style="display:flex;align-items:center;gap:12px;margin-bottom:1rem;padding:0.8rem 1.4rem;background:linear-gradient(135deg,rgba(30,41,59,0.95),rgba(15,23,42,0.98));border-radius:14px;border:1px solid rgba(125,211,252,0.12);">
                            <span style="font-size:1.2rem;">🏛️</span>
                            <div style="flex:1;">
                                <span style="color:#94a3b8;font-size:0.78rem;">来自学域</span>
                                <span
                                    style="color:#7dd3fc;font-weight:600;font-size:0.9rem;margin-left:6px;">${majorName}</span>
                                <span style="color:#64748b;font-size:0.75rem;margin-left:8px;">相关图书</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/majorMatrix"
                                style="display:inline-flex;align-items:center;gap:4px;padding:6px 14px;border-radius:8px;border:1px solid rgba(125,211,252,0.15);color:#94a3b8;font-size:0.78rem;text-decoration:none;transition:all 0.2s;"
                                onmouseover="this.style.color='#cbd5e1';this.style.borderColor='rgba(125,211,252,0.3)'"
                                onmouseout="this.style.color='#94a3b8';this.style.borderColor='rgba(125,211,252,0.15)'">←
                                返回学域矩阵</a>
                        </div>
                    </c:if>

                    <!-- ========== 搜索表单（点击搜索按钮显示或搜索后保持显示） ========== -->
                    <div id="search-panel" class="search-panel ${showSearchPanel ? 'active' : ''}">
                        <form action="${pageContext.request.contextPath}/booksList" method="get" class="search-form">
                            <input type="text" name="searchTitle" class="search-input" placeholder="搜索书名"
                                value="${searchTitle != null ? searchTitle : ''}">
                            <input type="text" name="searchAuthor" class="search-input" placeholder="搜索作者"
                                value="${searchAuthor != null ? searchAuthor : ''}">
                            <div class="cascade-group">
                                <select id="searchParentType" class="search-select">
                                    <option value="">全部分类</option>
                                </select>
                                <select id="searchChildType" name="searchTypeId" class="search-select"
                                    data-selected="${searchTypeId != null ? searchTypeId : ''}" style="display:none;">
                                    <option value="0">全部分类</option>
                                </select>
                            </div>
                            <div class="search-actions">
                                <button type="submit" class="btn btn-search">
                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2">
                                        <circle cx="11" cy="11" r="8" />
                                        <path d="m21 21-4.35-4.35" />
                                    </svg>
                                    搜索
                                </button>
                                <a href="${pageContext.request.contextPath}/booksList" class="btn btn-reset">重置</a>
                                <a href="#" class="btn btn-close-search">关闭</a>
                            </div>
                        </form>
                    </div>

                    <!-- ========== 图书列表表格 ========== -->
                    <div class="table-card">
                        <c:choose>
                            <c:when test="${empty books}">
                                <div class="empty-state">
                                    <div class="empty-state-icon">📚</div>
                                    <div class="empty-state-text">暂无图书数据</div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <table class="data-table">
                                    <thead>
                                        <tr>
                                            <th>封面</th>
                                            <th>ID</th>
                                            <th>书名</th>
                                            <th>作者</th>
                                            <th>简介</th>
                                            <th>类型</th>
                                            <th>下载</th>
                                            <th>年份</th>
                                            <th>格式</th>
                                            <th>操作</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="book" items="${books}">
                                            <tr>
                                                <td><a href="#cover-modal-${book.id}" class="cover-link"><img
                                                            class="book-cover"
                                                            src="${pageContext.request.contextPath}${book.bookCover}"
                                                            onerror="this.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2255%22 height=%2275%22><rect fill=%22%23111%22 width=%22100%25%22 height=%22100%25%22 rx=%228%22/><text x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 fill=%22%23666%22 font-size=%2212%22>📖</text></svg>'"></a>
                                                </td>
                                                <td><span style="color:#475569;font-size:11px;">${book.id}</span></td>
                                                <td><span class="book-title">${book.bookTitle}</span></td>
                                                <td><span class="book-author">${book.bookAuthor}</span></td>
                                                <td><span class="book-summary">${book.bookSummary}</span></td>
                                                <td><span class="book-type">${book.bookType.bTypeName}</span></td>
                                                <td><span class="download-count">${book.downloadTimes}</span></td>
                                                <td><span class="book-year">${book.bookPubYear}</span></td>
                                                <td><span class="book-format">${book.bookFormat}</span></td>
                                                <td class="action-buttons">
                                                    <!-- 编辑按钮 - 链接到 #edit-modal -->
                                                    <a href="#edit-modal-${book.id}"
                                                        class="btn btn-sm btn-warning">✏️</a>
                                                    <!-- 删除按钮 - POST请求 -->
                                                    <form action="${pageContext.request.contextPath}/booksList"
                                                        method="post" style="display:inline;">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="id" value="${book.id}">
                                                        <input type="hidden" name="_csrf" value="<%= com.ebookBuy301.util.CsrfUtil.getToken(request.getSession()) %>">
                                                        <button type="submit" class="btn btn-sm btn-danger">🗑️</button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>


                <%--添加图书 #add-modal--%>
                    <div id="add-modal" class="modal-overlay">
                        <div class="modal-dialog">
                            <div class="modal-header">
                                <h3 class="modal-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                                        style="vertical-align: middle; margin-right: 8px;">
                                        <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
                                        <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" />
                                        <line x1="12" y1="8" x2="12" y2="14" />
                                        <line x1="9" y1="11" x2="15" y2="11" />
                                    </svg>
                                    添加图书
                                </h3>
                                <a href="#" class="modal-close"></a>
                            </div>
                            <form action="${pageContext.request.contextPath}/booksList" method="post"
                                enctype="multipart/form-data">
                                <input type="hidden" name="action" value="add">
                                <div class="modal-body">
                                    <div class="form-group">
                                        <label class="form-label">书名 *</label>
                                        <input type="text" class="form-input" name="bookTitle" required
                                            placeholder="请输入书名">
                                    </div>

                                    <div class="form-row">
                                        <div class="form-group">
                                            <label class="form-label">作者</label>
                                            <input type="text" class="form-input" name="bookAuthor" placeholder="作者">
                                        </div>
                                        <div class="form-group">
                                            <label class="form-label">图书分类</label>
                                            <div class="cascade-row">
                                                <select id="addParentType" class="form-select">
                                                    <option value="">请选择分类</option>
                                                </select>
                                                <select id="addChildType" name="typeId" class="form-select"
                                                    style="display:none;">
                                                    <option value="">请选择分类</option>
                                                </select>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label class="form-label">简介</label>
                                        <textarea class="form-textarea" name="bookSummary" rows="2"
                                            placeholder="图书简介"></textarea>
                                    </div>

                                    <div class="form-row">
                                        <div class="form-group">
                                            <label class="form-label">出版年份</label>
                                            <input type="date" class="form-input" name="bookPubYear">
                                        </div>
                                        <div class="form-group">
                                            <label class="form-label">下载次数</label>
                                            <input type="number" class="form-input" name="downloadTimes" value="0"
                                                min="0">
                                        </div>
                                    </div>

                                    <div class="form-row">
                                        <div class="form-group">
                                            <label class="form-label">上传封面图片</label>
                                            <div class="file-upload-area" id="addCoverUpload">
                                                <input type="file" class="form-input" name="bookCover" accept="image/*"
                                                    onchange="handleFileSelect(this, 'addCoverUpload', 'image')">
                                                <span class="remove-file"
                                                    onclick="clearFile(event, 'addCoverUpload')">&times;</span>
                                                <div class="upload-content">
                                                    <div class="upload-icon">
                                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                            stroke-width="2" stroke-linecap="round"
                                                            stroke-linejoin="round">
                                                            <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
                                                            <circle cx="8.5" cy="8.5" r="1.5" />
                                                            <polyline points="21 15 16 10 5 21" />
                                                        </svg>
                                                    </div>
                                                    <span class="upload-text">点击或拖拽上传封面</span>
                                                    <span class="upload-hint">支持 JPG、PNG、GIF 格式</span>
                                                </div>
                                                <img class="preview-image" alt="封面预览">
                                                <div class="file-info">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                        stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                        <path
                                                            d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                                                        <polyline points="14 2 14 8 20 8" />
                                                        <polyline points="9 15 12 12 15 15" />
                                                        <path d="M12 12v9" />
                                                    </svg>
                                                    <span class="file-name"></span>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="form-label">文件格式</label>
                                            <div class="form-select-wrapper">
                                                <select class="form-select" name="bookFormat" id="addBookFormat"
                                                    onchange="syncFileAcceptByFormat(this, 'addBookFiles', 'addFileUpload')">
                                                    <option value="PDF">PDF</option>
                                                    <option value="EPUB">EPUB</option>
                                                    <option value="MOBI">MOBI</option>
                                                    <option value="TXT">TXT</option>
                                                </select>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label class="form-label">上传文件</label>
                                        <div class="file-upload-area" id="addFileUpload">
                                            <input type="file" class="form-input" name="bookFiles" id="addBookFiles"
                                                multiple onchange="handleFileSelect(this, 'addFileUpload', 'file')">
                                            <span class="remove-file"
                                                onclick="clearFile(event, 'addFileUpload')">&times;</span>
                                            <div class="upload-content">
                                                <div class="upload-icon">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                        stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                                                        <polyline points="17 8 12 3 7 8" />
                                                        <line x1="12" y1="3" x2="12" y2="15" />
                                                    </svg>
                                                </div>
                                                <span class="upload-text">点击或拖拽上传图书文件</span>
                                                <span class="upload-hint">支持 PDF、EPUB、MOBI、TXT 格式</span>
                                            </div>
                                            <div class="file-info">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                    <path
                                                        d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                                                    <polyline points="14 2 14 8 20 8" />
                                                    <polyline points="9 15 12 12 15 15" />
                                                    <path d="M12 12v9" />
                                                </svg>
                                                <span class="file-name"></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <a href="#" class="btn-cancel">取消</a>
                                    <button type="submit" class="btn-submit">保存</button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <%--封面管理弹窗 (每个图书一个)--%>
                        <c:forEach var="book" items="${books}">
                            <div id="cover-modal-${book.id}" class="modal-overlay">
                                <div class="modal-dialog" style="max-width: 480px;">
                                    <div class="modal-header">
                                        <h3 class="modal-title">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                                stroke-linejoin="round"
                                                style="vertical-align: middle; margin-right: 8px;">
                                                <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
                                                <circle cx="8.5" cy="8.5" r="1.5" />
                                                <polyline points="21 15 16 10 5 21" />
                                            </svg>
                                            封面管理 - ${book.bookTitle}
                                        </h3>
                                        <a href="#" class="modal-close"></a>
                                    </div>
                                    <div class="modal-body" style="text-align:center;">
                                        <!-- 大图预览 -->
                                        <div style="margin-bottom:1.2rem;">
                                            <img id="coverPreview${book.id}"
                                                src="${pageContext.request.contextPath}${book.bookCover}"
                                                onerror="this.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%22200%22 height=%22280%22><rect fill=%22%23111%22 width=%22100%25%22 height=%22100%25%22 rx=%2212%22/><text x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 fill=%22%23666%22 font-size=%2236%22>📖</text></svg>'"
                                                style="max-width:200px;max-height:280px;border-radius:12px;border:1px solid rgba(0,242,255,0.2);box-shadow:0 4px 20px rgba(0,0,0,0.4);object-fit:cover;">
                                        </div>

                                        <!-- 上传新封面 -->
                                        <form id="coverForm${book.id}"
                                            action="${pageContext.request.contextPath}/booksList" method="post"
                                            enctype="multipart/form-data">
                                            <input type="hidden" name="action" value="updateCover">
                                            <input type="hidden" name="id" value="${book.id}">
                                            <div class="file-upload-area" id="coverUploadArea${book.id}"
                                                style="margin-bottom:1rem;">
                                                <input type="file" name="bookCover" accept="image/*"
                                                    onchange="previewCoverFile(this, ${book.id})">
                                                <span class="remove-file" onclick="clearCoverFile(event, ${book.id})"
                                                    id="coverRemoveBtn${book.id}">&times;</span>
                                                <div class="upload-content" id="coverUploadContent${book.id}">
                                                    <div class="upload-icon">
                                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                            stroke-width="2" stroke-linecap="round"
                                                            stroke-linejoin="round" style="width:20px;height:20px;">
                                                            <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
                                                            <circle cx="8.5" cy="8.5" r="1.5" />
                                                            <polyline points="21 15 16 10 5 21" />
                                                        </svg>
                                                    </div>
                                                    <span class="upload-text">点击选择新封面</span>
                                                    <span class="upload-hint">支持 JPG、PNG、GIF</span>
                                                </div>
                                                <div class="file-info" id="coverFileInfo${book.id}">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                        stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                                                        style="width:16px;height:16px;">
                                                        <path
                                                            d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                                                        <polyline points="14 2 14 8 20 8" />
                                                        <polyline points="9 15 12 12 15 15" />
                                                        <path d="M12 12v9" />
                                                    </svg>
                                                    <span class="file-name" id="coverFileName${book.id}"></span>
                                                </div>
                                            </div>
                                            <div style="display:flex;gap:0.8rem;justify-content:center;">
                                                <button type="submit" class="btn btn-primary btn-sm"
                                                    style="padding:10px 24px;">
                                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                                                        stroke="currentColor" stroke-width="2"
                                                        style="vertical-align:middle;margin-right:4px;">
                                                        <polyline points="20 6 9 17 4 12" />
                                                    </svg>
                                                    上传新封面
                                                </button>
                                                <button type="button" class="btn btn-danger btn-sm"
                                                    style="padding:10px 24px;" onclick="deleteCover(${book.id})">
                                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                                                        stroke="currentColor" stroke-width="2"
                                                        style="vertical-align:middle;margin-right:4px;">
                                                        <polyline points="3 6 5 6 21 6" />
                                                        <path
                                                            d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
                                                    </svg>
                                                    删除封面
                                                </button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>

                        <%--编辑图书 (多个，按ID区分)--%>
                            <c:forEach var="book" items="${books}">
                                <div id="edit-modal-${book.id}" class="modal-overlay">
                                    <div class="modal-dialog">
                                        <div class="modal-header">
                                            <h3 class="modal-title">
                                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                    stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                                    stroke-linejoin="round"
                                                    style="vertical-align: middle; margin-right: 8px;">
                                                    <path
                                                        d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                                                    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
                                                </svg>
                                                编辑图书
                                            </h3>
                                            <a href="#" class="modal-close"></a>
                                        </div>
                                        <form action="${pageContext.request.contextPath}/booksList" method="post"
                                            enctype="multipart/form-data">
                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="id" value="${book.id}">
                                            <div class="modal-body">
                                                <div class="form-group">
                                                    <label class="form-label">书名 *</label>
                                                    <input type="text" class="form-input" name="bookTitle"
                                                        value="${book.bookTitle}" required placeholder="请输入书名">
                                                </div>

                                                <div class="form-row">
                                                    <div class="form-group">
                                                        <label class="form-label">作者</label>
                                                        <input type="text" class="form-input" name="bookAuthor"
                                                            value="${book.bookAuthor}" placeholder="作者">
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">图书分类</label>
                                                        <div class="cascade-row">
                                                            <select class="form-select cascade-parent-type">
                                                                <option value="">请选择分类</option>
                                                            </select>
                                                            <select class="form-select cascade-child-type" name="typeId"
                                                                data-selected="${book.typeId}" style="display:none;">
                                                                <option value="">请选择分类</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="form-group">
                                                    <label class="form-label">简介</label>
                                                    <textarea class="form-textarea" name="bookSummary" rows="2"
                                                        placeholder="图书简介">${book.bookSummary}</textarea>
                                                </div>

                                                <div class="form-row">
                                                    <div class="form-group">
                                                        <label class="form-label">出版年份</label>
                                                        <input type="date" class="form-input" name="bookPubYear"
                                                            value="${book.bookPubYear}">
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">下载次数</label>
                                                        <input type="number" class="form-input" name="downloadTimes"
                                                            value="${book.downloadTimes}" min="0">
                                                    </div>
                                                </div>

                                                <div class="form-row">
                                                    <div class="form-group">
                                                        <label class="form-label">上传封面图片</label>
                                                        <div class="file-upload-area"
                                                            id="editCoverUpload${book.id}">
                                                            <input type="file" class="form-input" name="bookCover"
                                                                accept="image/*"
                                                                onchange="handleFileSelect(this, 'editCoverUpload${book.id}', 'image')">
                                                            <span class="remove-file"
                                                                onclick="clearFile(event, 'editCoverUpload${book.id}')">&times;</span>
                                                            <div class="upload-content">
                                                                <div class="upload-icon">
                                                                    <svg viewBox="0 0 24 24" fill="none"
                                                                        stroke="currentColor" stroke-width="2"
                                                                        stroke-linecap="round" stroke-linejoin="round">
                                                                        <rect x="3" y="3" width="18" height="18" rx="2"
                                                                            ry="2" />
                                                                        <circle cx="8.5" cy="8.5" r="1.5" />
                                                                        <polyline points="21 15 16 10 5 21" />
                                                                    </svg>
                                                                </div>
                                                                <span class="upload-text">点击或拖拽上传封面</span>
                                                                <span class="upload-hint">支持 JPG、PNG、GIF 格式</span>
                                                            </div>
                                                            <img class="preview-image"
                                                            alt="封面预览">
                                                            <div class="file-info">
                                                                <svg viewBox="0 0 24 24" fill="none"
                                                                    stroke="currentColor" stroke-width="2"
                                                                    stroke-linecap="round" stroke-linejoin="round">
                                                                    <path
                                                                        d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                                                                    <polyline points="14 2 14 8 20 8" />
                                                                    <polyline points="9 15 12 12 15 15" />
                                                                    <path d="M12 12v9" />
                                                                </svg>
                                                                <span class="file-name"></span>
                                                            </div>
                                                        </div>
                                                        <c:if
                                                            test="${book.bookCover != null && not empty book.bookCover}">
                                                            <div
                                                                style="margin-top: 8px; padding-top: 8px; border-top: 1px solid rgba(255,255,255,0.1);">
                                                                <label
                                                                    style="font-size: 12px; color: #888; margin-bottom: 6px; display: block;">当前封面：</label>
                                                                <img src="${pageContext.request.contextPath}${book.bookCover}"
                                                                    style="max-width: 100px; max-height: 140px; border-radius: 8px; border: 1px solid rgba(0,242,255,0.2);"
                                                                    alt="当前封面">
                                                                <span
                                                                    style="font-size: 11px; color: #666; display: block; margin-top: 4px;">提示：重新上传将替换当前封面</span>
                                                            </div>
                                                        </c:if>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">文件格式</label>
                                                        <div class="form-select-wrapper">
                                                            <select class="form-select" name="bookFormat"
                                                                onchange="syncFileAcceptByFormat(this, 'editBookFiles${book.id}', 'editFileUpload${book.id}')">
                                                                <option value="PDF" ${book.bookFormat=='PDF'
                                                                    ? 'selected' : '' }>PDF</option>
                                                                <option value="EPUB" ${book.bookFormat=='EPUB'
                                                                    ? 'selected' : '' }>EPUB</option>
                                                                <option value="MOBI" ${book.bookFormat=='MOBI'
                                                                    ? 'selected' : '' }>MOBI</option>
                                                                <option value="TXT" ${book.bookFormat=='TXT'
                                                                    ? 'selected' : '' }>TXT</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="form-group">
                                                    <label class="form-label">上传文件</label>
                                                    <div class="file-upload-area"
                                                        id="editFileUpload${book.id}">
                                                        <input type="file" class="form-input" name="bookFiles"
                                                            id="editBookFiles${book.id}" multiple
                                                            onchange="handleFileSelect(this, 'editFileUpload${book.id}', 'file')">
                                                        <span class="remove-file"
                                                            onclick="clearFile(event, 'editFileUpload${book.id}')">&times;</span>
                                                        <div class="upload-content">
                                                            <div class="upload-icon">
                                                                <svg viewBox="0 0 24 24" fill="none"
                                                                    stroke="currentColor" stroke-width="2"
                                                                    stroke-linecap="round" stroke-linejoin="round">
                                                                    <path
                                                                        d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                                                                    <polyline points="17 8 12 3 7 8" />
                                                                    <line x1="12" y1="3" x2="12" y2="15" />
                                                                </svg>
                                                            </div>
                                                            <span class="upload-text">点击或拖拽上传图书文件</span>
                                                            <span class="upload-hint">支持 PDF、EPUB、MOBI、TXT 格式</span>
                                                        </div>
                                                        <div class="file-info">
                                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                                stroke-width="2" stroke-linecap="round"
                                                                stroke-linejoin="round">
                                                                <path
                                                                    d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                                                                <polyline points="14 2 14 8 20 8" />
                                                                <polyline points="9 15 12 12 15 15" />
                                                                <path d="M12 12v9" />
                                                            </svg>
                                                            <span class="file-name"></span>
                                                        </div>
                                                    </div>
                                                    <c:if test="${book.bookFile != null && not empty book.bookFile}">
                                                        <div
                                                            style="margin-top: 8px; padding-top: 8px; border-top: 1px solid rgba(255,255,255,0.1);">
                                                            <label
                                                                style="font-size: 12px; color: #888; margin-bottom: 6px; display: block;">已上传文件：</label>
                                                            <c:set var="filePaths"
                                                                value="${fn:split(book.bookFile, ',')}" />
                                                            <c:forEach var="filePath" items="${filePaths}">
                                                                <div
                                                                    style="display: inline-flex; align-items: center; background: rgba(255,255,255,0.05); padding: 4px 12px; border-radius: 4px; margin-right: 8px; margin-bottom: 4px;">
                                                                    <svg width="14" height="14" viewBox="0 0 24 24"
                                                                        fill="none" stroke="currentColor"
                                                                        stroke-width="2" style="margin-right: 6px;">
                                                                        <path
                                                                            d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                                                                        <polyline points="14 2 14 8 20 8" />
                                                                        <polyline points="9 15 12 12 15 15" />
                                                                    </svg>
                                                                    <span
                                                                        style="font-size: 12px;">${filePath.substring(filePath.lastIndexOf('/')
                                                                        + 1)}</span>
                                                                </div>
                                                            </c:forEach>
                                                            <span
                                                                style="font-size: 11px; color: #666; display: block; margin-top: 4px;">提示：重新上传将替换所有现有文件</span>
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </div>
                                            <div class="modal-footer">
                                                <a href="#" class="btn-cancel">取消</a>
                                                <button type="submit" class="btn-submit">保存</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </c:forEach>

                            <%--==========文件上传处理==========--%>
                                <script>
                                    // ─────────────────────────────────────────────────────────────────
                                    //  [P2] 客户端文件大小限制映射（与服务端一致）
                                    // ─────────────────────────────────────────────────────────────────
                                    var CLIENT_MAX_SIZE = {
                                        'COVER': 10 * 1024 * 1024,
                                        'TXT': 10 * 1024 * 1024,
                                        'EPUB': 50 * 1024 * 1024,
                                        'MOBI': 50 * 1024 * 1024,
                                        'PDF': 100 * 1024 * 1024
                                    };

                                    // 处理文件选择（支持单个/多个文件）
                                    function handleFileSelect(input, areaId, type) {
                                        var area = document.getElementById(areaId);
                                        if (!area || !input.files || input.files.length === 0) return;

                                        var files = input.files;
                                        var fileCount = files.length;
                                        var uploadContent = area.querySelector('.upload-content');
                                        var previewImage = area.querySelector('.preview-image');
                                        var fileInfo = area.querySelector('.file-info');
                                        var fileName = area.querySelector('.file-name');
                                        var removeBtn = area.querySelector('.remove-file');

                                        // [P2] 客户端文件大小校验（文件类型）
                                        if (type === 'file') {
                                            // 查找最近的格式下拉框获取当前选中的格式
                                            var formatSelect = area.closest('.modal-body')
                                                ? area.closest('.modal-body').querySelector('select[name="bookFormat"]')
                                                : null;
                                            var format = formatSelect ? formatSelect.value : 'PDF';
                                            var maxBytes = CLIENT_MAX_SIZE[format] || CLIENT_MAX_SIZE['PDF'];
                                            var sizeHint = (maxBytes / (1024 * 1024)) + ' MB';
                                            var oversized = [];
                                            for (var i = 0; i < files.length; i++) {
                                                if (files[i].size > maxBytes) {
                                                    oversized.push(files[i].name + ' (' + (files[i].size / (1024 * 1024)).toFixed(1) + ' MB)');
                                                }
                                            }
                                            if (oversized.length > 0) {
                                                alert('以下文件超过 ' + sizeHint + ' 大小限制：\n' + oversized.join('\n'));
                                                input.value = '';
                                                return;
                                            }
                                        } else if (type === 'image') {
                                            for (var i = 0; i < files.length; i++) {
                                                if (files[i].size > CLIENT_MAX_SIZE['COVER']) {
                                                    alert('封面图片 ' + files[i].name + ' 超过 10 MB 大小限制');
                                                    input.value = '';
                                                    return;
                                                }
                                            }
                                        }

                                        area.classList.add('has-file');
                                        if (uploadContent) uploadContent.classList.add('hidden');
                                        if (fileInfo) {
                                            fileInfo.classList.add('show');
                                            if (fileName) {
                                                if (fileCount > 1) {
                                                    fileName.textContent = '已选择 ' + fileCount + ' 个文件';
                                                } else {
                                                    fileName.textContent = files[0].name;
                                                }
                                            }
                                        }
                                        if (removeBtn) removeBtn.classList.add('show');

                                        // [P2] 多文件时显示文件名列表
                                        if (fileCount > 1) {
                                            var existingList = area.querySelector('.file-list');
                                            if (!existingList) {
                                                var listDiv = document.createElement('div');
                                                listDiv.className = 'file-list show';
                                                for (var i = 0; i < files.length; i++) {
                                                    var item = document.createElement('div');
                                                    item.className = 'file-list-item';
                                                    item.textContent = files[i].name;
                                                    listDiv.appendChild(item);
                                                }
                                                if (fileInfo && fileInfo.parentNode) {
                                                    fileInfo.parentNode.insertBefore(listDiv, fileInfo.nextSibling);
                                                }
                                            }
                                        } else {
                                            var existingList = area.querySelector('.file-list');
                                            if (existingList) existingList.remove();
                                        }

                                        // 图片类型且仅单个文件时显示预览
                                        if (type === 'image' && fileCount === 1 && previewImage && files[0].type.startsWith('image/')) {
                                            var reader = new FileReader();
                                            reader.onload = function (e) {
                                                previewImage.src = e.target.result;
                                                previewImage.classList.add('show');
                                            };
                                            reader.readAsDataURL(files[0]);
                                        }
                                    }

                                    // ─────────────────────────────────────────────────────────────────
                                    //  文件格式 ↔ 上传文件框联动：选择什么格式，文件选择器就只显示该类型
                                    // ─────────────────────────────────────────────────────────────────
                                    function syncFileAcceptByFormat(formatSelect, fileInputId, uploadAreaId) {
                                        var fileInput = document.getElementById(fileInputId);
                                        if (!fileInput) return;

                                        // [P3] 如果已有选中的文件，询问是否切换
                                        if (fileInput.files && fileInput.files.length > 0) {
                                            if (!confirm('切换文件格式将清除已选文件，是否继续？')) {
                                                // 还原下拉框值
                                                var oldFormat = fileInput.getAttribute('data-prev-format');
                                                formatSelect.value = oldFormat || 'PDF';
                                                return;
                                            }
                                        }
                                        fileInput.setAttribute('data-prev-format', formatSelect.value);

                                        var format = formatSelect.value;
                                        var acceptMap = {
                                            'PDF': '.pdf,application/pdf',
                                            'EPUB': '.epub,application/epub+zip',
                                            'MOBI': '.mobi,application/x-mobipocket-ebook',
                                            'TXT': '.txt,text/plain'
                                        };
                                        fileInput.accept = acceptMap[format] || '';

                                        // 清空已选文件
                                        fileInput.value = '';
                                        var uploadArea = document.getElementById(uploadAreaId);
                                        if (uploadArea) {
                                            uploadArea.classList.remove('has-file');
                                            var uc = uploadArea.querySelector('.upload-content');
                                            if (uc) uc.classList.remove('hidden');
                                            var pi = uploadArea.querySelector('.preview-image');
                                            if (pi) { pi.classList.remove('show'); pi.src = ''; }
                                            var fi = uploadArea.querySelector('.file-info');
                                            if (fi) fi.classList.remove('show');
                                            var rb = uploadArea.querySelector('.remove-file');
                                            if (rb) rb.classList.remove('show');
                                            var fl = uploadArea.querySelector('.file-list');
                                            if (fl) fl.remove();
                                        }
                                    }

                                    // 清除已选文件
                                    function clearFile(event, areaId) {
                                        event.preventDefault();
                                        event.stopPropagation();

                                        var area = document.getElementById(areaId);
                                        if (!area) return;

                                        var input = area.querySelector('input[type="file"]');
                                        var uploadContent = area.querySelector('.upload-content');
                                        var previewImage = area.querySelector('.preview-image');
                                        var fileInfo = area.querySelector('.file-info');
                                        var removeBtn = area.querySelector('.remove-file');

                                        if (input) input.value = '';
                                        area.classList.remove('has-file');
                                        if (uploadContent) uploadContent.classList.remove('hidden');
                                        if (previewImage) {
                                            previewImage.classList.remove('show');
                                            previewImage.src = '';
                                        }
                                        if (fileInfo) fileInfo.classList.remove('show');
                                        if (removeBtn) removeBtn.classList.remove('show');
                                    }

                                    // 拖拽上传支持
                                    function initDragUpload() {
                                        var uploadAreas = document.querySelectorAll('.file-upload-area');
                                        uploadAreas.forEach(function (area) {
                                            ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(function (eventName) {
                                                area.addEventListener(eventName, function (e) {
                                                    e.preventDefault();
                                                    e.stopPropagation();
                                                }, false);
                                            });

                                            ['dragenter', 'dragover'].forEach(function (eventName) {
                                                area.addEventListener(eventName, function () {
                                                    area.classList.add('drag-over');
                                                }, false);
                                            });

                                            ['dragleave', 'drop'].forEach(function (eventName) {
                                                area.addEventListener(eventName, function () {
                                                    area.classList.remove('drag-over');
                                                }, false);
                                            });

                                            area.addEventListener('drop', function (e) {
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

                                    // ====== 封面管理弹窗专用函数 ======
                                    function previewCoverFile(input, bookId) {
                                        if (!input.files || input.files.length === 0) return;
                                        var file = input.files[0];
                                        var area = document.getElementById('coverUploadArea' + bookId);
                                        var uploadContent = document.getElementById('coverUploadContent' + bookId);
                                        var fileInfo = document.getElementById('coverFileInfo' + bookId);
                                        var fileName = document.getElementById('coverFileName' + bookId);
                                        var removeBtn = document.getElementById('coverRemoveBtn' + bookId);
                                        var previewImg = document.getElementById('coverPreview' + bookId);

                                        area.classList.add('has-file');
                                        uploadContent.classList.add('hidden');
                                        fileInfo.classList.add('show');
                                        fileName.textContent = file.name;
                                        removeBtn.classList.add('show');

                                        // 保存原始封面路径，用于取消时恢复
                                        if (previewImg && !previewImg.getAttribute('data-orig-src')) {
                                            previewImg.setAttribute('data-orig-src', previewImg.src);
                                        }

                                        // 预览大图
                                        if (file.type.startsWith('image/')) {
                                            var reader = new FileReader();
                                            reader.onload = function (e) {
                                                if (previewImg) previewImg.src = e.target.result;
                                            };
                                            reader.readAsDataURL(file);
                                        }
                                    }

                                    function clearCoverFile(event, bookId) {
                                        event.preventDefault();
                                        event.stopPropagation();
                                        var area = document.getElementById('coverUploadArea' + bookId);
                                        var input = area.querySelector('input[type="file"]');
                                        var uploadContent = document.getElementById('coverUploadContent' + bookId);
                                        var fileInfo = document.getElementById('coverFileInfo' + bookId);
                                        var removeBtn = document.getElementById('coverRemoveBtn' + bookId);

                                        if (input) input.value = '';
                                        area.classList.remove('has-file');
                                        uploadContent.classList.remove('hidden');
                                        fileInfo.classList.remove('show');
                                        removeBtn.classList.remove('show');

                                        // 恢复原始封面
                                        var img = document.getElementById('coverPreview' + bookId);
                                        var origSrc = img.getAttribute('data-orig-src') || img.src;
                                        img.src = origSrc;
                                    }

                                    function deleteCover(bookId) {
                                        var form = document.getElementById('coverForm' + bookId);
                                        if (!form) return;

                                        // 添加删除标记
                                        var deleteInput = document.createElement('input');
                                        deleteInput.type = 'hidden';
                                        deleteInput.name = 'deleteCover';
                                        deleteInput.value = 'true';
                                        form.appendChild(deleteInput);

                                        // 清除文件输入（确保不上传文件）
                                        var fileInput = form.querySelector('input[type="file"]');
                                        if (fileInput) fileInput.value = '';

                                        form.submit();
                                    }

                                    // ─────────────────────────────────────────────────────────────────
                                    //  [P3] 上传加载状态：提交时禁用按钮 + 显示加载动画
                                    // ─────────────────────────────────────────────────────────────────
                                    document.addEventListener('submit', function (e) {
                                        var form = e.target;
                                        if (!form || !form.querySelector('input[type="file"]')) return;
                                        // 只拦截 multipart 表单
                                        if (form.getAttribute('enctype') !== 'multipart/form-data') return;

                                        var submitBtn = form.querySelector('button[type="submit"]');
                                        if (submitBtn) {
                                            submitBtn.disabled = true;
                                            submitBtn.innerHTML = '<span class="spinner" style="display:inline-block;width:14px;height:14px;border:2px solid rgba(255,255,255,0.3);border-top-color:#fff;border-radius:50%;animation:spin 0.8s linear infinite;vertical-align:middle;margin-right:6px;"></span>上传中...';
                                        }
                                    });

                                    // ─────────────────────────────────────────────────────────────────
                                    //  页面初始化
                                    // ─────────────────────────────────────────────────────────────────
                                    window.addEventListener('load', function () {
                                        initDragUpload();
                                        loadCascadeSelects();
                                    });

                                </script>

                                <%--==========二级联动下拉==========--%>
                                    <script>
                                        // 注意：loadCascadeSelects 定义在此 script 块中，window load 事件在上面已绑定
                                        function loadCascadeSelects() {
                                            fetch("${pageContext.request.contextPath}/bookTypeJson")
                                                .then(function (response) {
                                                    if (!response.ok) throw new Error('HTTP ' + response.status);
                                                    return response.json();
                                                })
                                                .then(function (data) {
                                                    console.log("加载 " + data.length + " 个分类");

                                                    // 分离父分类和子分类
                                                    var parents = [];
                                                    var childMap = {};
                                                    var childToParent = {};
                                                    for (var i = 0; i < data.length; i++) {
                                                        var t = data[i];
                                                        var pid = String(t.bTPerentId || '').trim();
                                                        if (!pid || pid === '0' || pid === 'null') {
                                                            parents.push(t);
                                                        } else {
                                                            if (!childMap[pid]) childMap[pid] = [];
                                                            childMap[pid].push(t);
                                                            childToParent[t.bTid] = pid;
                                                        }
                                                    }

                                                    // 给指定父select填充选项
                                                    function fillParents(sel) {
                                                        for (var j = 0; j < parents.length; j++) {
                                                            var opt = document.createElement('option');
                                                            opt.value = parents[j].bTid;
                                                            opt.text = parents[j].bTypeName;
                                                            sel.appendChild(opt);
                                                        }
                                                    }

                                                    // 根据父ID更新子select
                                                    function updateChild(parentSel, childSel) {
                                                        var pid = parentSel.value;
                                                        childSel.innerHTML = '';
                                                        if (!pid) { childSel.style.display = 'none'; return; }
                                                        childSel.style.display = 'block';
                                                        var def = document.createElement('option');
                                                        def.value = '';
                                                        def.text = '请选择分类';
                                                        childSel.appendChild(def);
                                                        var children = childMap[pid] || [];
                                                        for (var k = 0; k < children.length; k++) {
                                                            var opt = document.createElement('option');
                                                            opt.value = children[k].bTid;
                                                            opt.text = children[k].bTypeName;
                                                            childSel.appendChild(opt);
                                                        }
                                                    }

                                                    // 初始化一对联动
                                                    function initPair(parentSel, childSel) {
                                                        if (!parentSel || !childSel) return;
                                                        fillParents(parentSel);

                                                        var preChild = childSel.getAttribute('data-selected');
                                                        var preParent = null;
                                                        if (preChild && childToParent[preChild]) {
                                                            preParent = childToParent[preChild];
                                                        }
                                                        if (preParent) {
                                                            parentSel.value = preParent;
                                                            updateChild(parentSel, childSel);
                                                            if (preChild) childSel.value = preChild;
                                                        }
                                                        parentSel.addEventListener('change', function () {
                                                            updateChild(parentSel, childSel);
                                                        });
                                                    }

                                                    // 1. 搜索面板
                                                    initPair(
                                                        document.getElementById('searchParentType'),
                                                        document.getElementById('searchChildType')
                                                    );

                                                    // 2. 添加弹窗
                                                    initPair(
                                                        document.getElementById('addParentType'),
                                                        document.getElementById('addChildType')
                                                    );

                                                    // 3. 编辑弹窗（每个图书一个）
                                                    var editParents = document.querySelectorAll('.cascade-parent-type');
                                                    for (var m = 0; m < editParents.length; m++) {
                                                        var ep = editParents[m];
                                                        var ec = ep.closest('.cascade-row')
                                                            .querySelector('.cascade-child-type');
                                                        initPair(ep, ec);
                                                    }

                                                    console.log("联动下拉初始化完成");
                                                })
                                                .catch(function (error) {
                                                    console.error("加载分类失败:", error);
                                                });
                                        }
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