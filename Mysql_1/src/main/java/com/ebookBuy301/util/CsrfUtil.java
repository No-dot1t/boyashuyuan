/**
 * ===========================================================================
 * CsrfUtil —— CSRF 令牌工具类
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.util
 *
 * ── 用途 ─────────────────────────────────────────────────────────────────
 *  生成和验证 CSRF 令牌，防御跨站请求伪造攻击。
 *
 * ── 使用方式 ─────────────────────────────────────────────────────────────
 *  JSP 端生成令牌：
 *   <%
 *     String csrfToken = CsrfUtil.getToken(session);
 *   %>
 *   <input type="hidden" name="_csrf" value="<%= csrfToken %>">
 *
 *  Servlet 端验证令牌：
 *   CsrfUtil.requireValidToken(request, response);
 *
 * ===========================================================================
 */

package com.ebookBuy301.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.security.SecureRandom;
import java.util.Base64;

public class CsrfUtil {

    private static final String SESSION_KEY = "csrfToken";    // Session 属性名：存储令牌
    private static final String PARAM_NAME  = "_csrf";         // 请求参数名：提交令牌
    private static final SecureRandom RANDOM = new SecureRandom();  // 密码学安全随机数生成器（优于 Random）

    /**
     * 从 Session 获取或生成 CSRF 令牌
     *
     * @param session HTTP 会话，可为 null
     * @return CSRF 令牌字符串
     */
    public static String getToken(HttpSession session) {
        if (session == null) return "";
        String token = (String) session.getAttribute(SESSION_KEY);
        if (token == null) {
            token = generateToken();
            session.setAttribute(SESSION_KEY, token);
        }
        return token;
    }

    /**
     * 生成安全的随机令牌
     */
    private static String generateToken() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    /**
     * 验证请求中的 CSRF 令牌是否与 Session 中一致
     *
     * @param request HTTP 请求
     * @return true 如果令牌有效
     */
    public static boolean isValid(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;

        String sessionToken = (String) session.getAttribute(SESSION_KEY);
        if (sessionToken == null) return false;

        String requestToken = request.getParameter(PARAM_NAME);
        return sessionToken.equals(requestToken);
    }

    /**
     * 直接验证给定的令牌是否与 Session 中一致（用于 JSON body 中提取的令牌）
     *
     * @param session HTTP 会话
     * @param providedToken 从请求中提取的令牌（如 JSON body 的 _csrf 字段）
     * @return true 如果令牌有效
     */
    public static boolean isValidToken(HttpSession session, String providedToken) {
        if (session == null || providedToken == null) return false;
        String sessionToken = (String) session.getAttribute(SESSION_KEY);
        if (sessionToken == null) return false;
        return sessionToken.equals(providedToken);
    }

    /**
     * 对 POST/PUT/DELETE 请求强制验证 CSRF 令牌。
     * 验证失败则返回 403 并终止请求。
     *
     * @param request  HTTP 请求
     * @param response HTTP 响应
     * @return true 通过验证，false 已拦截（请求已被终止）
     */
    public static boolean requireValidToken(HttpServletRequest request,
                                             HttpServletResponse response)
            throws IOException {
        String method = request.getMethod().toUpperCase();
        // 仅对写操作校验 CSRF
        if ("GET".equals(method) || "HEAD".equals(method) || "OPTIONS".equals(method)) {
            return true;
        }

        if (!isValid(request)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"CSRF 验证失败，请刷新页面后重试\"}");
            return false;
        }
        return true;
    }
}
