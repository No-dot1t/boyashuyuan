package com.ebookBuy301;

import com.ebookBuy301.dao.UserActivityDao;
import com.ebookBuy301.pojo.Users;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * ===========================================================================
 * UserApiServlet —— 用户数据 JSON API
 * ===========================================================================
 *
 * 映射路径        /api/users
 * 底层技术        Java EE Servlet
 * 数据访问        UserActivityDao（JDBC + PreparedStatement）
 * 最后更新        2026-06-13
 *
 * ── 路由表 ─────────────────────────────────────────────────────────────────
 *
 * 【GET】
 *   action=list       → 返回所有用户列表（JSON）
 *
 * ── 使用的关键方法与算法 ────────────────────────────────────────────────────
 *
 * 方法 / 技术                  用途
 * ─────────────────────────────────────────────────────────────────
 * UserActivityDao.getAllUsers()   查询所有用户
 * HttpServletRequest                 获取请求参数
 * response.getWriter().write()   输出 JSON 响应
 * JSON.toJSONString()            fastjson 对象转 JSON 字符串
 * ===========================================================================
 */
@WebServlet("/api/users")
public class UserApiServlet extends HttpServlet {

    private final UserActivityDao userDao = new UserActivityDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String action = request.getParameter("action");

        try {
            if ("list".equals(action)) {
                List<Users> users = userDao.getAllUsers();
                out.print(JSON.toJSONString(createSuccessResponse(users)));
            } else {
                out.print(JSON.toJSONString(createErrorResponse("无效的操作")));
            }
        } catch (Exception e) {
            System.err.println("[UserApiServlet] Error: " + e.getMessage());
            out.print(JSON.toJSONString(createErrorResponse("服务器内部错误")));
        }
    }

    private JSONObject createSuccessResponse(Object data) {
        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("data", data);
        return result;
    }

    private JSONObject createErrorResponse(String message) {
        JSONObject result = new JSONObject();
        result.put("success", false);
        result.put("message", message);
        return result;
    }
}