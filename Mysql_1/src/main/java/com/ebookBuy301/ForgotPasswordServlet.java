/**
 * ===========================================================================
 * ForgotPasswordServlet —— 忘记密码 / 重置密码控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet
 *
 * ── 用途 ─────────────────────────────────────────────────────────────────
 *  处理忘记密码流程：
 *   1. 验证邮箱是否存在
 *   2. 发送 6 位验证码到邮箱
 *   3. 校验验证码并重置密码（BCrypt 加密）
 *
 * ── 请求参数 ─────────────────────────────────────────────────────────────
 *  POST /forgotPassword
 *    action=sendCode   → email          发送验证码
 *    action=reset      → email, code, newPassword  重置密码
 *
 * ── 响应格式（JSON）────────────────────────────────────────────────────────
 *  { "success": true/false, "message": "..." }
 * ===========================================================================
 */

package com.ebookBuy301;

import com.alibaba.fastjson.JSONObject;
import com.ebookBuy301.dao.UsersDao;
import com.ebookBuy301.pojo.Users;
import com.ebookBuy301.util.MailService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/forgotPassword")
public class ForgotPasswordServlet extends HttpServlet {

    /**
     * 验证码存储：email → { code, expireTime(ms) }
     * 使用 ConcurrentHashMap 保证线程安全
     */
    private static final Map<String, CodeEntry> codeStore = new ConcurrentHashMap<>();

    /** 验证码有效期：15 分钟 */
    private static final long CODE_EXPIRE_MS = 15 * 60 * 1000;

    /** 验证码存储结构 */
    private static class CodeEntry {
        final String code;
        final long expireTime;

        CodeEntry(String code, long expireTime) {
            this.code = code;
            this.expireTime = expireTime;
        }

        boolean isExpired() {
            return System.currentTimeMillis() > expireTime;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String action = request.getParameter("action");
        JSONObject result = new JSONObject();

        try {
            if ("sendCode".equals(action)) {
                handleSendCode(request, result);
            } else if ("reset".equals(action)) {
                handleResetPassword(request, result);
            } else {
                result.put("success", false);
                result.put("message", "无效的操作");
            }
        } catch (Exception e) {
            System.err.println("[ForgotPassword] 异常：" + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "服务器内部错误，请稍后重试");
        }

        response.getWriter().write(result.toString());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // GET 请求不支持，返回错误
        response.setContentType("application/json;charset=UTF-8");
        JSONObject result = new JSONObject();
        result.put("success", false);
        result.put("message", "请使用 POST 请求");
        response.getWriter().write(result.toString());
    }

    /** 处理发送验证码 */
    private void handleSendCode(HttpServletRequest request, JSONObject result)
            throws ClassNotFoundException {
        String email = request.getParameter("email");

        // 参数校验
        if (email == null || email.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "请输入邮箱地址");
            return;
        }
        email = email.trim();

        // 检查邮箱格式
        if (!email.matches("^[\\w.-]+@[\\w.-]+\\.\\w{2,}$")) {
            result.put("success", false);
            result.put("message", "请输入有效的邮箱地址");
            return;
        }

        // 查找用户
        UsersDao dao = new UsersDao();
        Users user = dao.getUserByEmail(email);
        if (user == null) {
            result.put("success", false);
            result.put("message", "该邮箱未注册");
            return;
        }

        // 发送频率限制：60 秒内不能重复发送
        CodeEntry existing = codeStore.get(email);
        if (existing != null && !existing.isExpired()) {
            long elapsed = System.currentTimeMillis() - (existing.expireTime - CODE_EXPIRE_MS);
            if (elapsed < 60_000) {
                long remainSec = (60_000 - elapsed) / 1000;
                result.put("success", false);
                result.put("message", "请 " + remainSec + " 秒后再试");
                return;
            }
        }

        // 生成 6 位验证码
        String code = generateCode();

        // 存储验证码
        codeStore.put(email, new CodeEntry(code, System.currentTimeMillis() + CODE_EXPIRE_MS));

        // 发送邮件
        String sendResult = MailService.sendVerificationCode(email, code, 15);

        // 判断发送结果
        if (sendResult.contains("已发送")) {
            result.put("success", true);
            result.put("message", "验证码已发送至 " + maskEmail(email) + "，请查收邮件");
        } else {
            // 发送失败，清除已存储的验证码
            codeStore.remove(email);
            result.put("success", false);
            result.put("message", sendResult);
        }
    }

    /** 处理重置密码 */
    private void handleResetPassword(HttpServletRequest request, JSONObject result)
            throws ClassNotFoundException {
        String email = request.getParameter("email");
        String code = request.getParameter("code");
        String newPassword = request.getParameter("newPassword");

        // 参数校验
        if (email == null || email.trim().isEmpty()
                || code == null || code.trim().isEmpty()
                || newPassword == null || newPassword.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "请填写完整信息");
            return;
        }
        email = email.trim();
        code = code.trim();
        newPassword = newPassword.trim();

        // 密码长度校验
        if (newPassword.length() < 6) {
            result.put("success", false);
            result.put("message", "密码长度不能少于 6 位");
            return;
        }
        if (newPassword.length() > 32) {
            result.put("success", false);
            result.put("message", "密码长度不能超过 32 位");
            return;
        }

        // 验证码校验
        CodeEntry entry = codeStore.get(email);
        if (entry == null) {
            result.put("success", false);
            result.put("message", "请先获取验证码");
            return;
        }
        if (entry.isExpired()) {
            codeStore.remove(email);
            result.put("success", false);
            result.put("message", "验证码已过期，请重新获取");
            return;
        }
        if (!entry.code.equals(code)) {
            result.put("success", false);
            result.put("message", "验证码错误，请重新输入");
            return;
        }

        // 验证通过，重置密码（BCrypt 加密）
        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
        UsersDao dao = new UsersDao();
        int updated = dao.updatePassword(email, hashedPassword);

        if (updated > 0) {
            // 清除已使用的验证码
            codeStore.remove(email);
            result.put("success", true);
            result.put("message", "密码重置成功！请使用新密码登录");
        } else {
            result.put("success", false);
            result.put("message", "密码重置失败，请重试");
        }
    }

    /** 生成 6 位随机数字验证码 */
    private String generateCode() {
        java.security.SecureRandom random = new java.security.SecureRandom();
        StringBuilder sb = new StringBuilder(6);
        for (int i = 0; i < 6; i++) {
            sb.append(random.nextInt(10));
        }
        return sb.toString();
    }

    /** 邮箱脱敏显示：us***@example.com */
    private String maskEmail(String email) {
        int atIndex = email.indexOf('@');
        if (atIndex <= 2) {
            return email.substring(0, 1) + "***" + email.substring(atIndex);
        }
        return email.substring(0, 3) + "***" + email.substring(atIndex);
    }
}
