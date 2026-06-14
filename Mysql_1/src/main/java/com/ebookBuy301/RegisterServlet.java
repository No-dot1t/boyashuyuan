/**
 * ===========================================================================
 * RegisterServlet —— Servlet 控制器
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
 *   username = request.getParameter("reg_username")
 *   password = request.getParameter("reg_password")
 *   passwordConfirm = request.getParameter("reg_password_confirm")
 *   email = request.getParameter("reg_email")
 *   sex = request.getParameter("reg_sex")
 *   ageStr = request.getParameter("reg_age")
 *   hasError = false
 *   emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$"
 *   usersDao = new UsersDao()
 *   allUsers = usersDao.getAllUsers()
 *   id = UUID.randomUUID().toString().replace("-", "")
 *   newUser = new Users(id, username, password, sex, age, email)
 *   result = usersDao.addUser(newUser)
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
import java.util.UUID;
import org.mindrot.jbcrypt.BCrypt;

/**
 * =============================================================================
 * RegisterServlet —— 用户注册控制器
 * =============================================================================
 *
 * 处理新用户注册的 POST 请求。
 *
 * 访问路径：/register
 *
 * 注册流程（8 步校验）：
 * 1. 获取表单数据（用户名、密码、确认密码、邮箱、性别、年龄）
 * 2. 校验所有必填项
 * 3. 验证两次密码是否一致
 * 4. 验证密码长度（≥ 6 位）
 * 5. 验证邮箱格式（正则）
 * 6. 验证年龄范围（1-120 岁）
 * 7. 检查用户名和邮箱是否被占用
 * 8. 创建用户并写入数据库
 * =============================================================================
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    /**
     * 处理 POST 请求 —— 用户注册
     *
     * @param request  HTTP 请求对象
     * @param response HTTP 响应对象
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // ==================== 1. 获取注册表单数据 ====================
        String username = request.getParameter("reg_username");
        String password = request.getParameter("reg_password");
        String passwordConfirm = request.getParameter("reg_password_confirm");
        String email = request.getParameter("reg_email");
        String sex = request.getParameter("reg_sex");
        String ageStr = request.getParameter("reg_age");

        System.out.println("注册尝试 - 用户名：" + username + ", 邮箱已隐藏");

        // ==================== 2. 验证必填项 ====================
        boolean hasError = false;

        if (username == null || username.trim().isEmpty()) {
            request.setAttribute("regUsername_error", "请输入账号");
            hasError = true;
        } else {
            request.setAttribute("regUsername_value", username);
        }

        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("regPassword_error", "请输入密码");
            hasError = true;
        } else {
            // 密码不回显，不存入 request attribute
        }

        if (passwordConfirm == null || passwordConfirm.trim().isEmpty()) {
            request.setAttribute("regPasswordConfirm_error", "请确认密码");
            hasError = true;
        } else {
            request.setAttribute("regPasswordConfirm_value", passwordConfirm);
        }

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("regEmail_error", "请输入邮箱");
            hasError = true;
        } else {
            request.setAttribute("regEmail_value", email);
        }

        if (sex == null || sex.trim().isEmpty()) {
            request.setAttribute("regSex_error", "请选择性别");
            hasError = true;
        } else {
            request.setAttribute("regSex_value", sex);
        }

        if (ageStr == null || ageStr.trim().isEmpty()) {
            request.setAttribute("regAge_error", "请输入年龄");
            hasError = true;
        } else {
            request.setAttribute("regAge_value", ageStr);
        }

        if (hasError) {
            request.getSession().setAttribute("loginShown", true);
            request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
            return;
        }

        // ==================== 3. 验证密码一致性 ====================
        if (!password.equals(passwordConfirm)) {
            request.setAttribute("regPasswordConfirm_error", "两次输入的密码不一致");
            request.setAttribute("regUsername_value", username);
            request.setAttribute("regEmail_value", email);
            request.setAttribute("regSex_value", sex);
            request.setAttribute("regAge_value", ageStr);
            request.getSession().setAttribute("loginShown", true);
            request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
            return;
        }

        // ==================== 4. 验证密码长度 ====================
        if (password.length() < 6) {
            request.setAttribute("regPassword_error", "密码长度不能少于6位");
            request.setAttribute("regUsername_value", username);
            request.setAttribute("regEmail_value", email);
            request.setAttribute("regSex_value", sex);
            request.setAttribute("regAge_value", ageStr);
            request.getSession().setAttribute("loginShown", true);
            request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
            return;
        }

        // ==================== 5. 验证邮箱格式 ====================
        String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
        if (!email.matches(emailRegex)) {
            request.setAttribute("regEmail_error", "邮箱格式不正确");
            request.setAttribute("regUsername_value", username);
            request.setAttribute("regPasswordConfirm_value", passwordConfirm);
            request.setAttribute("regSex_value", sex);
            request.setAttribute("regAge_value", ageStr);
            request.getSession().setAttribute("loginShown", true);
            request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
            return;
        }

        // ==================== 6. 验证年龄 ====================
        long age;
        try {
            age = Long.parseLong(ageStr);
            if (age < 1 || age > 120) {
                request.setAttribute("regAge_error", "年龄必须在1-120之间");
                request.setAttribute("regUsername_value", username);
                request.setAttribute("regPasswordConfirm_value", passwordConfirm);
                request.setAttribute("regEmail_value", email);
                request.setAttribute("regSex_value", sex);
                request.getSession().setAttribute("loginShown", true);
                request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
                return;
            }
        } catch (NumberFormatException e) {
            request.setAttribute("regAge_error", "年龄必须是有效数字");
            request.setAttribute("regUsername_value", username);
            request.setAttribute("regPasswordConfirm_value", passwordConfirm);
            request.setAttribute("regEmail_value", email);
            request.setAttribute("regSex_value", sex);
            request.getSession().setAttribute("loginShown", true);
            request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
            return;
        }

        // ==================== 7. 检查用户名和邮箱是否已存在 ====================
        UsersDao usersDao = new UsersDao();
        try {
            // 检查用户名重复（使用单条查询替代全表扫描）
            Users existingUserByUsername = usersDao.getUserByUsername(username);
            if (existingUserByUsername != null) {
                request.setAttribute("regUsername_error", "该用户名已被注册");
                request.setAttribute("regPasswordConfirm_value", passwordConfirm);
                request.setAttribute("regEmail_value", email);
                request.setAttribute("regSex_value", sex);
                request.setAttribute("regAge_value", ageStr);
                request.getSession().setAttribute("loginShown", true);
                request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
                return;
            }

            // 检查邮箱重复（使用单条查询替代全表扫描）
            Users existingUserByEmail = usersDao.getUserByEmail(email);
            if (existingUserByEmail != null) {
                request.setAttribute("regEmail_error", "该邮箱已被注册");
                request.setAttribute("regUsername_value", username);
                request.setAttribute("regPasswordConfirm_value", passwordConfirm);
                request.setAttribute("regSex_value", sex);
                request.setAttribute("regAge_value", ageStr);
                request.getSession().setAttribute("loginShown", true);
                request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
                return;
            }

            // ==================== 8. 创建新用户并保存 ====================
            String id = UUID.randomUUID().toString().replace("-", "");
            System.out.println("[RegisterServlet] 开始密码加密 - 用户: " + username);
            long encryptStart = System.currentTimeMillis();
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
            long encryptEnd = System.currentTimeMillis();
            System.out.println("[RegisterServlet] 密码加密完成 - 耗时: " + (encryptEnd - encryptStart) + "ms, 哈希长度: "
                    + hashedPassword.length() + " 字符");
            System.out.println("[RegisterServlet] 哈希值前20位: "
                    + (hashedPassword.length() > 20 ? hashedPassword.substring(0, 20) + "..." : hashedPassword));

            Users newUser = new Users(id, username, hashedPassword, sex, age, email);

            int result = usersDao.addUser(newUser);

            if (result > 0) {
                // 注册成功
                System.out.println("注册成功 - 用户名：" + username);
                request.getSession().setAttribute("success", "注册成功！请使用新账号登录。");
                response.sendRedirect(request.getContextPath() + "/LOGIN/login.jsp");

            } else {
                // 注册失败
                request.setAttribute("regPassword_error", "注册失败，请稍后重试");
                request.setAttribute("regUsername_value", username);
                request.setAttribute("regEmail_value", email);
                request.setAttribute("regSex_value", sex);
                request.setAttribute("regAge_value", ageStr);
                request.getSession().setAttribute("loginShown", true);
                request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
            }

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            request.setAttribute("regPassword_error", "系统错误，请稍后重试");
            request.setAttribute("regUsername_value", username);
            request.setAttribute("regEmail_value", email);
            request.setAttribute("regSex_value", sex);
            request.getSession().setAttribute("loginShown", true);
            request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("[RegisterServlet] Unexpected error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("regPassword_error", "系统繁忙，请稍后重试");
            request.setAttribute("regUsername_value", username);
            request.setAttribute("regEmail_value", email);
            request.setAttribute("regSex_value", sex);
            request.getSession().setAttribute("loginShown", true);
            try {
                request.getRequestDispatcher("LOGIN/login.jsp").forward(request, response);
            } catch (Exception ex) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "System error");
            }
        }
    }

    /**
     * 处理 GET 请求 —— 跳转到登录页面
     *
     * @param request  HTTP 请求对象
     * @param response HTTP 响应对象
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("LOGIN/login.jsp");
    }
}
