/**
 * ===========================================================================
 * AvatarServlet —— Servlet 控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet
 * 最后更新  2026-05-26
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * doGet(HttpServletRequest req, HttpServletResponse res)HTTP 请求处理入口
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   @WebServlet —— 注解式 Servlet 路由映射
 *   Servlet API —— HttpServlet / HttpServletRequest / HttpServletResponse
 *   HttpSession —— 会话管理
 *
 * ===========================================================================
 */

package com.ebookBuy301;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * =============================================================================
 * AvatarServlet —— 用户头像页面控制器
 * =============================================================================
 *
 * 处理用户头像页面请求，从 Session 中获取当前登录用户信息，
 * 并转发到头像页面进行展示和管理。
 *
 * 访问路径：/avatar
 *
 * 流程：
 * 1. 获取 HttpSession 对象
 * 2. 从 Session 中获取 currentUser 属性
 * 3. 提取用户名和用户ID
 * 4. 将用户信息存入 request 属性
 * 5. 转发到 /pages/avatar.jsp
 *
 * 注意：未登录用户将显示默认访客信息
 * =============================================================================
 */
@WebServlet("/avatar")
public class AvatarServlet extends HttpServlet {

    /**
     * 处理 GET 请求 —— 加载头像页面
     *
     * @param req HTTP 请求对象
     * @param res HTTP 响应对象
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        // 获取 Session 中的用户信息
        HttpSession session = req.getSession();
        String username = "访客";
        String userId = null;

        Object userObj = session.getAttribute("currentUser");
        if (userObj != null) {
            com.ebookBuy301.pojo.Users u = (com.ebookBuy301.pojo.Users) userObj;
            username = u.getUsername();
            userId = u.getId();
        }

        // 将用户信息传递到页面
        req.setAttribute("username", username);
        req.setAttribute("userId", userId);

        // 转发到头像页面
        req.getRequestDispatcher("/pages/avatar.jsp").forward(req, res);
    }
}
