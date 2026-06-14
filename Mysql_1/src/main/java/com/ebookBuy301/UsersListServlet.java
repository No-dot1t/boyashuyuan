/**
 * ===========================================================================
 * UsersListServlet —— Servlet 控制器（用户管理）
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet("/usersList")
 *
 * 处理后台用户管理页面的增删改查操作。
 *
 * GET 请求：
 *   - action=delete&id=xxx  → 删除用户
 *   - searchUsername / searchSex → 条件查询
 *   - 无参数                → 显示用户列表
 *
 * POST 请求：
 *   - action=add    → 添加用户
 *   - action=update → 修改用户
 * ===========================================================================
 */

package com.ebookBuy301;

import com.ebookBuy301.dao.UsersDao;
import com.ebookBuy301.pojo.Users;
import com.ebookBuy301.util.CsrfUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/usersList")
public class UsersListServlet extends HttpServlet {

    private UsersDao usersDao = new UsersDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            ArrayList<Users> users;
            String searchUsername = request.getParameter("searchUsername");
            String searchSex = request.getParameter("searchSex");

            boolean hasSearchCondition = (searchUsername != null && !searchUsername.trim().isEmpty())
                    || (searchSex != null && !searchSex.trim().isEmpty());

            if (hasSearchCondition) {
                users = usersDao.searchUsers(searchUsername, searchSex);
                request.setAttribute("isSearch", true);
                request.setAttribute("searchCount", users.size());
            } else {
                users = usersDao.getAllUsers();
            }

            request.setAttribute("users", users);
            request.getRequestDispatcher("JAVAList/usersList.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "操作失败: " + e.getMessage());
            try {
                request.setAttribute("users", usersDao.getAllUsers());
            } catch (Exception ex) {
                request.setAttribute("users", new ArrayList<Users>());
            }
            request.getRequestDispatcher("JAVAList/usersList.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String action = request.getParameter("action");

        try {
            // CSRF 验证
            if (!CsrfUtil.requireValidToken(request, response)) return;

            if ("delete".equals(action)) {
                String id = request.getParameter("id");
                Map<String, Object> result = new HashMap<>();
                try {
                    if (id != null && !id.isEmpty()) {
                        usersDao.deleteUser(id);
                        result.put("success", true);
                        result.put("message", "删除成功");
                    } else {
                        result.put("success", false);
                        result.put("error", "用户ID无效");
                    }
                } catch (Exception e) {
                    result.put("success", false);
                    result.put("error", "删除失败: " + e.getMessage());
                }
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write(new com.alibaba.fastjson.JSONObject(result).toJSONString());
                return;
            }

            if ("add".equals(action)) {
                String username = request.getParameter("username");
                String password = request.getParameter("password");

                if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
                    response.sendRedirect("usersList?error=用户名和密码不能为空");
                    return;
                }

                Users user = new Users();
                user.setId(UUID.randomUUID().toString().replace("-", ""));
                user.setUsername(username.trim());
                user.setPassword(BCrypt.hashpw(password, BCrypt.gensalt()));
                user.setSex(getParam(request, "sex", "未知"));
                user.setAge(parseLong(request.getParameter("age"), 0));
                user.setEmail(getParam(request, "email", ""));
                user.setRole("admin".equals(request.getParameter("role")) ? "admin" : "user");
                user.setAvatar(getParam(request, "avatar", ""));
                user.setNickname(getParam(request, "nickname", ""));

                usersDao.addUser(user);
                response.sendRedirect("usersList?success=添加成功");

            } else if ("update".equals(action)) {
                String id = request.getParameter("id");
                String username = request.getParameter("username");

                if (id == null || username == null || username.trim().isEmpty()) {
                    response.sendRedirect("usersList?error=参数错误");
                    return;
                }

                Users user = new Users();
                user.setId(id);
                user.setUsername(username.trim());
                user.setPassword(getParam(request, "password", ""));
                user.setSex(getParam(request, "sex", "未知"));
                user.setAge(parseLong(request.getParameter("age"), 0));
                user.setEmail(getParam(request, "email", ""));
                user.setRole("admin".equals(request.getParameter("role")) ? "admin" : "user");
                user.setAvatar(getParam(request, "avatar", ""));
                user.setNickname(getParam(request, "nickname", ""));

                usersDao.updateUser(user);
                response.sendRedirect("usersList?success=修改成功");

            } else {
                response.sendRedirect("usersList");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("usersList?error=操作失败: " + e.getMessage());
        }
    }

    private String getParam(HttpServletRequest request, String name, String defaultValue) {
        String value = request.getParameter(name);
        return (value != null) ? value : defaultValue;
    }

    private long parseLong(String value, long defaultValue) {
        if (value == null || value.trim().isEmpty()) return defaultValue;
        try {
            return Long.parseLong(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
