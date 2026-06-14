/**
 * ===========================================================================
 * AIFeedbackServlet —— Servlet 控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet, @param, @param, @throws, @throws, @param, @param, @param, @param, @param, @param, @return
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * doPost(HttpServletRequest request, HttpServletResponse response)HTTP 请求处理入口
 * writeFeedbackToFile(String feedback)内部工具方法
 * sendSuccessResponse(PrintWriter out, String message)内部工具方法
 * sendErrorResponse(PrintWriter out, String error)内部工具方法
 * escapeJson(String str)             内部工具方法
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   feedbackType = request.getParameter("type")
 *   message = request.getParameter("message")
 *   aiResponse = request.getParameter("aiResponse")
 *   out = response.getWriter()
 *   sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
 *   timestamp = sdf.format(new Date())
 *   feedbackText = String.format("[%s] %s反馈: 用户消息='%s', AI回复='%s'",
                    timestamp,
                    feedbackType.equals("positive") ? "👍 点赞" : "👎 点踩",
                    message.substring(0, Math.min(100, message.length())),
                    aiResponse != null ? aiResponse.substring(0, Math.min(100, aiResponse.length())) : "无")
 *   feedbackFile = new File(getServletContext().getRealPath("/logs/ai_feedback.log"))
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   @WebServlet —— 注解式 Servlet 路由映射
 *   Servlet API —— HttpServlet / HttpServletRequest / HttpServletResponse
 *   doPost() —— POST 请求分发
 *   action 参数分发模式 —— 通过 request.getParameter("action") 分流操作
 *
 * ===========================================================================
 */

package com.ebookBuy301;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * =============================================================================
 * AIFeedbackServlet —— AI 回答反馈收集
 * =============================================================================
 *
 * 收集用户对 AI 回答的反馈（点赞/点踩），记录到控制台或日志文件。
 *
 * 访问路径：/api/ai/feedback（POST 请求）
 *
 * 请求参数：
 *   - type       → 反馈类型："positive"（点赞）或 "negative"（点踩）
 *   - message    → 用户发送的消息
 *   - aiResponse → AI 的回复内容
 * =============================================================================
 */
@WebServlet("/api/ai/feedback")
public class AIFeedbackServlet extends HttpServlet {

    /**
     * 处理 POST 请求 —— 收集用户反馈
     *
     * @param request  HTTP 请求对象
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

        // ===== 1. 获取参数 =====
        String feedbackType = request.getParameter("type"); // "positive" or "negative"
        String message = request.getParameter("message");
        String aiResponse = request.getParameter("aiResponse");

        PrintWriter out = response.getWriter();

        // ===== 2. 验证参数 =====
        if (feedbackType == null || (!"positive".equals(feedbackType) && !"negative".equals(feedbackType))) {
            sendErrorResponse(out, "反馈类型无效");
            return;
        }

        if (message == null || message.trim().isEmpty()) {
            sendErrorResponse(out, "消息不能为空");
            return;
        }

        // ===== 3. 记录反馈 =====
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            String timestamp = sdf.format(new Date());

            String feedbackText = String.format("[%s] %s反馈: 用户消息='%s', AI回复='%s'",
                    timestamp,
                    feedbackType.equals("positive") ? "👍 点赞" : "👎 点踩",
                    message.substring(0, Math.min(100, message.length())),
                    aiResponse != null ? aiResponse.substring(0, Math.min(100, aiResponse.length())) : "无");

            // 输出到控制台
            System.out.println(feedbackText);

            // 写入日志文件（可选）
            writeFeedbackToFile(feedbackText);

            // ===== 4. 返回成功 =====
            sendSuccessResponse(out, "反馈已收到，感谢您的意见！");

        } catch (Exception e) {
            System.err.println("[AIFeedbackServlet] 处理反馈时出错: " + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(out, "处理反馈时出错: " + e.getMessage());
        }
    }

    /**
     * 将反馈内容写入日志文件（当前仅输出到控制台）
     *
     * @param feedback 反馈文本
     */
    private void writeFeedbackToFile(String feedback) {
        try {
            // 生产环境可写入文件或数据库
            // File feedbackFile = new File(getServletContext().getRealPath("/logs/ai_feedback.log"));
            // Files.write(feedbackFile.toPath(), (feedback + "\n").getBytes(StandardCharsets.UTF_8),
            //             StandardOpenOption.CREATE, StandardOpenOption.APPEND);
            System.out.println("[AI反馈日志] " + feedback);

        } catch (Exception e) {
            System.err.println("[AIFeedbackServlet] 写入反馈文件失败: " + e.getMessage());
        }
    }

    /**
     * 发送 JSON 成功响应
     *
     * @param out     PrintWriter
     * @param message 成功消息
     */
    private void sendSuccessResponse(PrintWriter out, String message) {
        out.print("{\"success\":true,\"message\":\"" + escapeJson(message) + "\"}");
    }

    /**
     * 发送 JSON 错误响应
     *
     * @param out   PrintWriter
     * @param error 错误消息
     */
    private void sendErrorResponse(PrintWriter out, String error) {
        out.print("{\"success\":false,\"error\":\"" + escapeJson(error) + "\"}");
    }

    /**
     * JSON 字符串转义（防止特殊字符破坏 JSON 格式）
     *
     * @param str 原始字符串
     * @return 转义后的字符串
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
