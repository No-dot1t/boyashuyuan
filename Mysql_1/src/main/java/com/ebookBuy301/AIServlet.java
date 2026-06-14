/**
 * ===========================================================================
 * AIServlet —— Servlet 控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet, @param, @return, @param, @param, @param, @throws, @throws, @param, @param, @throws, @throws
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * init()                             初始化
 * getSessionHistory(HttpSession session)查询操作
 * clearSessionHistory(HttpSession session)内部工具方法
 * doPost(HttpServletRequest request, HttpServletResponse response)HTTP 请求处理入口
 * doGet(HttpServletRequest request, HttpServletResponse response)HTTP 请求处理入口
 * sendSuccessResponse(PrintWriter out, String message)内部工具方法
 * sendErrorResponse(PrintWriter out, String error)内部工具方法
 * escapeJson(String str)             内部工具方法
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   MAX_HISTORY_SIZE = 20
 *   sessionId = session.getId()
 *   message = request.getParameter("message")
 *   model = request.getParameter("model")
 *   action = request.getParameter("action")
 *   session = request.getSession(true)
 *   history = getSessionHistory(session)
 *   out = response.getWriter()
 *   out = response.getWriter()
 *   connected = deepSeekService.testConnection()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   @WebServlet —— 注解式 Servlet 路由映射
 *   Servlet API —— HttpServlet / HttpServletRequest / HttpServletResponse
 *   doGet() —— GET 请求分发
 *   doPost() —— POST 请求分发
 *   action 参数分发模式 —— 通过 request.getParameter("action") 分流操作
 *
 * ===========================================================================
 */

package com.ebookBuy301;

import com.ebookBuy301.service.DeepSeekService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * =============================================================================
 * AIServlet —— AI 对话控制器
 * =============================================================================
 *
 * 处理前端 AI 聊天请求，转发到 DeepSeek API 并返回结果。
 * 支持多轮对话历史记录（基于 Session），
 * 可通过 action=clear 清空历史。
 *
 * 访问路径：
 * POST /api/ai → AI 对话（需 message 参数）
 * GET /api/ai → 健康检查
 * POST /api/ai?action=clear → 清空对话历史
 *
 * 安全限制：
 * - 消息最长 2000 字符
 * - 对话历史最多保存 20 条
 * =============================================================================
 */
@WebServlet("/api/ai")
public class AIServlet extends HttpServlet {

    /** DeepSeek AI 服务实例 */
    private DeepSeekService deepSeekService;

    /**
     * 会话历史记录缓存（sessionId → HistoryEntry）
     * 使用 ConcurrentHashMap 保证线程安全
     */
    private static final Map<String, HistoryEntry> sessionHistories = new ConcurrentHashMap<>();

    /** 每个会话最大保留的历史消息条数 */
    private static final int MAX_HISTORY_SIZE = 20;

    /** 会话历史过期时间（秒）- 30分钟 */
    private static final long HISTORY_EXPIRE_SECONDS = 30 * 60;

    /** 定时清理任务调度器 */
    private static final ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
        Thread t = new Thread(r, "AIServlet-Cleanup");
        t.setDaemon(true);
        return t;
    });

    static {
        // 启动定时清理任务，每5分钟执行一次
        scheduler.scheduleAtFixedRate(() -> {
            int cleaned = cleanupExpiredHistory();
            if (cleaned > 0) {
                System.out.println("[AIServlet] 定时清理完成，清理过期会话: " + cleaned + " 个");
            }
        }, 5, 5, TimeUnit.MINUTES);
    }

    /** 历史条目，包含消息列表和最后访问时间 */
    private static class HistoryEntry {
        List<ChatMessage> messages;
        long lastAccessTime;

        HistoryEntry(List<ChatMessage> messages) {
            this.messages = messages;
            this.lastAccessTime = System.currentTimeMillis();
        }

        void touch() {
            this.lastAccessTime = System.currentTimeMillis();
        }

        boolean isExpired() {
            return System.currentTimeMillis() - lastAccessTime > HISTORY_EXPIRE_SECONDS * 1000;
        }
    }

    /**
     * 对话消息内部类，记录角色和内容
     */
    private static class ChatMessage {
        String role;
        String content;

        ChatMessage(String role, String content) {
            this.role = role;
            this.content = content;
        }
    }

    /**
     * Servlet 初始化 —— 创建 DeepSeek 服务实例
     */
    @Override
    public void init() throws ServletException {
        super.init();
        deepSeekService = new DeepSeekService();
        System.out.println("========================================");
        System.out.println("[AIServlet] DeepSeek AI 服务初始化完成");
        System.out.println("[AIServlet] API 端点: /api/ai");
        System.out.println("[AIServlet] 支持多轮对话");
        System.out.println("========================================");
    }

    /**
     * 获取或创建当前会话的对话历史
     * 自动清理过期的历史记录
     *
     * @param session HTTP Session
     * @return 对话历史列表
     */
    private List<ChatMessage> getSessionHistory(HttpSession session) {
        String sessionId = session.getId();

        // 定期清理过期历史（每100次调用触发一次清理）
        if (System.currentTimeMillis() % 100 == 0) {
            cleanupExpiredHistory();
        }

        HistoryEntry entry = sessionHistories.computeIfAbsent(sessionId, k -> new HistoryEntry(new ArrayList<>()));
        entry.touch();
        return entry.messages;
    }

    /**
     * 清理指定会话的对话历史
     *
     * @param session HTTP Session
     */
    private void clearSessionHistory(HttpSession session) {
        sessionHistories.remove(session.getId());
    }

    /**
     * 清理过期的会话历史，防止内存泄漏
     * @return 清理的过期会话数量
     */
    private static int cleanupExpiredHistory() {
        int initialSize = sessionHistories.size();
        sessionHistories.entrySet().removeIf(entry -> entry.getValue().isExpired());
        return initialSize - sessionHistories.size();
    }

    /**
     * 处理 POST 请求 —— AI 对话
     *
     * @param request  HTTP 请求对象（需含 message、model 参数）
     * @param response HTTP 响应对象（JSON）
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String message = request.getParameter("message");
        String model = request.getParameter("model");
        String action = request.getParameter("action"); // clear: 清空历史

        // 自定义 API 配置（用户自填的 API Key / URL）
        String customApiUrl = request.getParameter("custom_api_url");
        String customApiKey = request.getParameter("custom_api_key");
        String customProvider = request.getParameter("custom_provider");

        HttpSession session = request.getSession(true);
        List<ChatMessage> history = getSessionHistory(session);

        PrintWriter out = response.getWriter();

        // ---- 处理清空历史 ----
        if ("clear".equals(action)) {
            clearSessionHistory(session);
            sendSuccessResponse(out, "对话历史已清空");
            return;
        }

        // ---- 验证消息不能为空 ----
        if (message == null || message.trim().isEmpty()) {
            sendErrorResponse(out, "消息不能为空");
            return;
        }

        // ---- 限制消息长度 ----
        if (message.length() > 2000) {
            sendErrorResponse(out, "消息长度不能超过2000字符");
            return;
        }

        // ---- 角色权限检查：DeepSeek 模型仅管理员可用系统 Key，其他用户需自填 ----
        Object currentUserObj = session.getAttribute("currentUser");
        String userRole = "user";
        if (currentUserObj instanceof com.ebookBuy301.pojo.Users) {
            String role = ((com.ebookBuy301.pojo.Users) currentUserObj).getRole();
            if (role != null) userRole = role;
        }
        boolean isAdmin = "admin".equals(userRole);
        if (model != null) {
            String m = model.trim().toLowerCase();
            if (m.startsWith("deepseek")) {
                boolean hasCustomKey = customApiKey != null && !customApiKey.trim().isEmpty();
                if (!isAdmin && !hasCustomKey) {
                    sendErrorResponse(out, "DeepSeek 模型需要填入你自己的 API Key，请点击模型选择器中的 🔑 设置按钮");
                    return;
                }
            }
        }

        try {
            System.out.println("[AIServlet] 收到用户消息, 当前对话历史: " + history.size() + " 条, 用户角色: " + userRole);

            // 添加用户消息到历史
            history.add(new ChatMessage("user", message.trim()));

            // 调用 AI API（支持自定义配置）
            String aiResponse;
            String effectiveModel = (model != null && !model.trim().isEmpty()) ? model.trim() : null;

            // 判断是否使用自定义配置
            boolean useCustom = customApiUrl != null && !customApiUrl.trim().isEmpty()
                    && customApiKey != null && !customApiKey.trim().isEmpty();

            if (useCustom) {
                aiResponse = deepSeekService.chat(message.trim(), effectiveModel, customApiUrl, customApiKey, customProvider);
            } else {
                if (effectiveModel != null) {
                    aiResponse = deepSeekService.chat(message.trim(), effectiveModel);
                } else {
                    aiResponse = deepSeekService.chat(message.trim());
                }
            }

            // 添加 AI 回复到历史
            history.add(new ChatMessage("assistant", aiResponse));

            // 限制历史记录大小（移除最早的记录）
            while (history.size() > MAX_HISTORY_SIZE) {
                history.remove(0);
            }

            // 返回成功响应
            sendSuccessResponse(out, aiResponse);

        } catch (java.net.SocketTimeoutException e) {
            System.err.println("[AIServlet] 请求超时: " + e.getMessage());
            sendErrorResponse(out, "请求超时，请稍后再试");
        } catch (java.net.UnknownHostException e) {
            System.err.println("[AIServlet] 网络错误，无法连接到 API 服务器");
            sendErrorResponse(out, "网络连接失败，请检查网络后重试");
        } catch (Exception e) {
            System.err.println("[AIServlet] AI 服务异常: " + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(out, "服务繁忙，请稍后再试: " + e.getMessage());
        }
    }

    /**
     * 处理 GET 请求 —— 健康检查
     *
     * @param request  HTTP 请求对象
     * @param response HTTP 响应对象（JSON）
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        PrintWriter out = response.getWriter();

        try {
            boolean connected = deepSeekService.testConnection();
            if (connected) {
                out.print("{\"status\":\"ok\",\"service\":\"DeepSeek AI\",\"connected\":true}");
            } else {
                out.print("{\"status\":\"error\",\"service\":\"DeepSeek AI\",\"connected\":false}");
            }
        } catch (Exception e) {
            out.print("{\"status\":\"error\",\"service\":\"DeepSeek AI\",\"error\":\""
                    + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private void sendSuccessResponse(PrintWriter out, String message) {
        out.print("{\"success\":true,\"message\":\"" + escapeJson(message) + "\"}");
    }

    private void sendErrorResponse(PrintWriter out, String error) {
        out.print("{\"success\":false,\"error\":\"" + escapeJson(error) + "\"}");
    }

    private String escapeJson(String str) {
        if (str == null)
            return "";
        return str.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
