/**
 * ===========================================================================
 * AuthFilter —— 认证与鉴权过滤器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.filter
 * 注解      @WebFilter
 *
 * ── 用途 ─────────────────────────────────────────────────────────────────
 *  拦截管理员相关路由，验证用户登录状态与管理员角色。
 *  未登录用户重定向至登录页，非管理员用户返回 403 拒绝访问。
 *
 * ── 方法索引 ─────────────────────────────────────────────────────────────
 *  方法                                  用途
 *  ----------------------------------------------------------------------
 *  init(FilterConfig)                    初始化（容器启动时调用）
 *  doFilter(ServletRequest,
 *           ServletResponse,
 *           FilterChain)                 核心鉴权拦截逻辑
 *  destroy()                             销毁（容器关闭时调用）
 *
 * ── 拦截路径 ─────────────────────────────────────────────────────────────
 *  /adminDashboard, /adminLogs, /adminReport, /adminSettings,
 *  /adminSecurity, /adminUserAnalysis, /adminBackup,
 *  /adminPush, /usersList, /booksList,
 *  /bookTypeList, /contentReview, /notifications
 *
 * ── 鉴权规则 ─────────────────────────────────────────────────────────────
 *  1. Session 中无 currentUser        → 302 重定向到 /LOGIN/login.jsp
 *  2. 已登录但 user.isAdmin() == false → 403 拒绝访问（HTML 错误页）
 *  3. 已登录且为管理员                 → 放行（chain.doFilter）
 *
 * ===========================================================================
 */

package com.ebookBuy301.filter;

import com.ebookBuy301.pojo.Users;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {
    "/adminDashboard", "/adminLogs", "/adminReport", "/adminSettings",
    "/adminSecurity", "/adminUserAnalysis", "/adminBackup", "/adminPush",
    "/usersList", "/booksList", "/bookTypeList", "/contentReview",
    "/notifications"
})
public class AuthFilter implements Filter {

    /**
     * 过滤器初始化（容器启动时调用一次）。
     * <p>
     * 打印拦截路径日志，便于部署后快速确认过滤器已加载。
     *
     * @param filterConfig 容器提供的过滤器配置
     * @throws ServletException 初始化异常
     */
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("[AuthFilter] 管理员认证过滤器初始化完成");
        System.out.println("[AuthFilter] 拦截路径: /adminDashboard /adminLogs /usersList /booksList /contentReview /notifications 等");
    }

    /**
     * 核心鉴权拦截逻辑。
     * <p>
     * 算法流程：
     *   ① 获取 HttpSession（false 表示不创建新会话）
     *   ② 未登录（session 为空或无 currentUser）→ 重定向到登录页
     *   ③ 已登录但非管理员（user.isAdmin() == false）→ 403 错误页
     *   ④ 已登录且为管理员 → 放行（chain.doFilter）
     *
     * @param request  Servlet 请求
     * @param response Servlet 响应
     * @param chain    过滤器链
     * @throws IOException      IO 异常
     * @throws ServletException Servlet 异常
     */
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        // 未登录 → 重定向到登录页
        if (session == null || session.getAttribute("currentUser") == null) {
            String ctx = httpRequest.getContextPath();
            httpResponse.sendRedirect(ctx + "/LOGIN/login.jsp");
            return;
        }

        // 已登录但非管理员 → 403 禁止访问
        Users user = (Users) session.getAttribute("currentUser");
        if (!user.isAdmin()) {
            httpResponse.setStatus(HttpServletResponse.SC_FORBIDDEN);
            httpResponse.setContentType("text/html;charset=UTF-8");
            httpResponse.getWriter().write(
                "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>403 禁止访问</title>" +
                "<style>body{display:flex;align-items:center;justify-content:center;height:100vh;" +
                "background:#0a0f1a;color:#fff;font-family:sans-serif;flex-direction:column}" +
                "h1{font-size:48px;color:#0ff;margin:0}h2{color:#aaa}" +
                "a{color:#0ff;text-decoration:none;margin-top:20px}</style></head>" +
                "<body><h1>403</h1><h2>您没有权限访问此页面</h2>" +
                "<a href='" + httpRequest.getContextPath() + "/home'>返回首页</a></body></html>"
            );
            return;
        }

        // 管理员 → 放行
        chain.doFilter(request, response);
    }

    /**
     * 过滤器销毁（容器关闭时调用一次）。
     * <p>
     * 释放资源并打印销毁日志。
     */
    @Override
    public void destroy() {
        System.out.println("[AuthFilter] 管理员认证过滤器已销毁");
    }
}
