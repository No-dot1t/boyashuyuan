/**
 * ===========================================================================
 * LoginServlet —— Servlet 控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet, @param, @param, @throws, @throws, @param, @param, @throws, @throws
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * doPost(HttpServletRequest request, HttpServletResponse response)HTTP 请求处理入口
 * doGet(HttpServletRequest request, HttpServletResponse response)HTTP 请求处理入口
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   username = request.getParameter("username")
 *   password = request.getParameter("password")
 *   usersDao = new UsersDao()
 *   loginUser = usersDao.getUserByUsername(username)
 *   action = request.getParameter("action")
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

import com.ebookBuy301.dao.UsersDao;
import com.ebookBuy301.pojo.Users;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.mindrot.jbcrypt.BCrypt;

/**
 * =============================================================================
 * LoginServlet —— 用户登录控制器
 * =============================================================================
 *
 * 处理用户登录验证的 GET 和 POST 请求。
 *
 * 访问路径：/login
 *
 * POST 请求：执行登录验证
 * 1. 获取用户名和密码
 * 2. 通过 UsersDao.getUserByUsername() 查询用户
 * 3. 匹配密码 → 成功则存入 Session，跳转首页；失败则返回错误信息
 *
 * GET 请求：
 * - action=markShown → 标记弹窗已显示（AJAX 调用）
 * - 无参数 → 转发到登录页面
 * =============================================================================
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    /**
     * 处理 POST 请求 —— 用户登录验证
     *
     * @param request  HTTP 请求对象（需含 username、password 参数）
     * @param response HTTP 响应对象
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ===== 1. 设置编码 =====
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // ===== 2. 获取表单参数 =====
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // ===== 3. 校验非空 =====
        if (username == null || username.trim().isEmpty()) {
            request.setAttribute("loginUsername_error", "请输入账号");
            request.setAttribute("loginUsername_value", username);
            request.getSession().setAttribute("loginShown", true);
            request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
            return;
        }

        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("loginPassword_error", "请输入密码");
            request.setAttribute("loginUsername_value", username);
            request.getSession().setAttribute("loginShown", true);
            request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
            return;
        }

        // ===== 4. 执行登录验证 =====
        UsersDao usersDao = new UsersDao();

        try {
            Users loginUser = usersDao.getUserByUsername(username);

            if (loginUser != null) {
                boolean passwordMatch = false;
                boolean isPlainPassword = false;

                try {
                    passwordMatch = BCrypt.checkpw(password, loginUser.getPassword());
                } catch (IllegalArgumentException e) {
                    if (password.equals(loginUser.getPassword())) {
                        passwordMatch = true;
                        isPlainPassword = true;
                    }
                }

                if (passwordMatch && isPlainPassword) {
                    try {
                        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
                        usersDao.updatePasswordByUsername(username, hashedPassword);
                    } catch (Exception e) {
                    }
                }

                if (passwordMatch) {
                    request.getSession().invalidate();
                    javax.servlet.http.HttpSession newSession = request.getSession(true);
                    newSession.setAttribute("currentUser", loginUser);
                    newSession.setAttribute("userId", loginUser.getId());
                    newSession.setAttribute("username", loginUser.getUsername());
                    newSession.setAttribute("isLoggedIn", "true");
                    response.sendRedirect("index.jsp");

                } else {
                    request.setAttribute("loginPassword_error", "用户名或密码错误");
                    request.setAttribute("loginUsername_value", username);
                    request.getSession().setAttribute("loginShown", true);
                    request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("loginPassword_error", "用户名或密码错误");
                request.setAttribute("loginUsername_value", username);
                request.getSession().setAttribute("loginShown", true);
                request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
            }

        } catch (ClassNotFoundException e) {
            System.err.println("[LoginServlet] ClassNotFound: " + e.getMessage());
            request.setAttribute("loginPassword_error", "登录失败，请稍后重试");
            request.setAttribute("loginUsername_value", username);
            request.getSession().setAttribute("loginShown", true);
            request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("[LoginServlet] Unexpected error: " + e.getMessage());
            request.setAttribute("loginPassword_error", "系统繁忙，请稍后重试");
            request.setAttribute("loginUsername_value", username);
            request.getSession().setAttribute("loginShown", true);
            request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
        }
    }

    /**
     * 处理 GET 请求
     * <p>
     * - action=markShown：标记登录弹窗已显示（前端 AJAX 调用）
     * - 无参数：跳转到登录页面
     *
     * @param request  HTTP 请求对象
     * @param response HTTP 响应对象
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        // 标记登录弹窗已显示
        if ("markShown".equals(action)) {
            request.getSession().setAttribute("loginShown", true);
            response.setContentType("text/plain");
            response.getWriter().write("OK");
            return;
        }

        // 跳转到登录页面
        request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
    }
}
