/**
 * ===========================================================================
 * GlobalExceptionFilter —— Servlet 过滤器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.filter
 * 注解      @WebFilter
 * 最后更新  2026-05-26
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * init(FilterConfig filterConfig)     初始化
 * doFilter(...)                      HTTP 请求处理入口（全局异常捕获）
 * destroy()                          销毁资源
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   @WebFilter —— 注解式过滤器注册
 *   Filter API —— Filter / FilterChain / FilterConfig
 *   try-catch —— 全局异常捕获
 *
 * ===========================================================================
 */

package com.ebookBuy301.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * =============================================================================
 * GlobalExceptionFilter —— 全局异常过滤器
 * =============================================================================
 *
 * 拦截所有请求，捕获未处理的异常，返回统一的错误响应格式。
 * 防止异常堆栈信息暴露给客户端，增强系统安全性。
 *
 * 拦截路径：/*（所有请求）
 *
 * 错误响应格式：{"success":false,"error":"系统繁忙，请稍后重试"}
 * =============================================================================
 */
@WebFilter("/*")
public class GlobalExceptionFilter implements Filter {

    /**
     * 过滤器初始化
     */
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("[GlobalExceptionFilter] 全局异常过滤器初始化完成");
    }

    /**
     * 执行过滤 —— 捕获并处理全局异常
     *
     * @param request  ServletRequest 对象
     * @param response ServletResponse 对象
     * @param chain    FilterChain 对象
     */
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        try {
            chain.doFilter(request, response);
        } catch (Exception e) {
            HttpServletResponse httpResponse = (HttpServletResponse) response;
            HttpServletRequest httpRequest = (HttpServletRequest) request;

            // 区分 Ajax 请求与页面请求
            String requestedWith = httpRequest.getHeader("X-Requested-With");
            String accept = httpRequest.getHeader("Accept");
            boolean isAjax = "XMLHttpRequest".equals(requestedWith)
                    || (accept != null && accept.contains("application/json"));

            if (isAjax) {
                // Ajax 请求 → JSON 错误响应
                httpResponse.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                httpResponse.setContentType("application/json;charset=UTF-8");
                httpResponse.getWriter().write("{\"success\":false,\"error\":\"系统繁忙，请稍后重试\"}");
            } else {
                // 页面请求 → 友好错误页面
                httpResponse.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                httpResponse.setContentType("text/html;charset=UTF-8");
                httpResponse.getWriter().write(
                    "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>500 - 系统错误</title>" +
                    "<style>body{display:flex;align-items:center;justify-content:center;height:100vh;" +
                    "background:#0a0f1a;color:#fff;font-family:sans-serif;flex-direction:column}" +
                    "h1{font-size:48px;color:#0ff;margin:0}h2{color:#aaa;margin:8px}" +
                    "p{color:#888;max-width:400px;text-align:center}" +
                    "a{color:#0ff;text-decoration:none;margin-top:20px}</style></head>" +
                    "<body><h1>500</h1><h2>系统繁忙，请稍后重试</h2>" +
                    "<p>服务器遇到了一个临时错误，请刷新页面或稍后再试。</p>" +
                    "<a href='" + httpRequest.getContextPath() + "/home'>返回首页</a></body></html>"
                );
            }
            System.err.println("[GlobalExceptionFilter] Unexpected error: " + e.getMessage());
        }
    }

    /**
     * 过滤器销毁
     */
    @Override
    public void destroy() {
        System.out.println("[GlobalExceptionFilter] 全局异常过滤器已销毁");
    }
}