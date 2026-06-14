/**
 * ===========================================================================
 * SettingsServlet —— 设置中心页面控制器 v2.0
 * ===========================================================================
 *
 * 路由      /settings
 * 最后更新  2026-06-04
 *
 * GET  /settings                          → 渲染设置中心页面
 * GET  /settings?action=userStats         → JSON 账号统计（注册时间/最后活跃）
 * POST /settings?action=savePreference    → JSON 保存阅读偏好到 session
 * POST /settings?action=themeChange       → JSON 保存主题到 session
 * ===========================================================================
 */

package com.ebookBuy301;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.ebookBuy301.pojo.Users;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/settings")
public class SettingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        Users currentUser = (Users) request.getSession().getAttribute("currentUser");
        String action = request.getParameter("action");

        // API 模式：返回用户统计 JSON
        if ("userStats".equals(action)) {
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();
            JSONObject json = new JSONObject();
            json.put("success", true);

            if (currentUser != null) {
                json.put("username", currentUser.getUsername());
                json.put("nickname", currentUser.getNickname() != null ? currentUser.getNickname() : "");
                json.put("email", currentUser.getEmail() != null ? currentUser.getEmail() : "");
                json.put("sex", currentUser.getSex() != null ? currentUser.getSex() : "");
                json.put("role", currentUser.getRole() != null ? currentUser.getRole() : "user");
                json.put("avatar", currentUser.getAvatar() != null ? currentUser.getAvatar() : "");

                // 从 session 取最后活跃时间
                Object lastActiveObj = request.getSession().getAttribute("lastActiveTime");
                if (lastActiveObj != null) {
                    json.put("lastActiveTime", lastActiveObj.toString());
                } else {
                    json.put("lastActiveTime", "当前会话");
                }

                // 注册时间（session 中保存的格式字符串）
                Object registerObj = request.getSession().getAttribute("registerTime");
                if (registerObj != null) {
                    json.put("registerTime", registerObj.toString());
                } else {
                    json.put("registerTime", "首次登录");
                }
            } else {
                json.put("success", false);
                json.put("message", "未登录");
            }
            out.print(json.toJSONString());
            return;
        }

        // API 模式：读取偏好
        if ("loadPreference".equals(action)) {
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();
            JSONObject json = new JSONObject();
            json.put("success", true);
            String pref = (String) request.getSession().getAttribute("boya_reading_prefs");
            json.put("preference", pref != null ? pref : "{}");
            out.print(json.toJSONString());
            return;
        }

        // 页面模式
        String theme = (String) request.getSession().getAttribute("preferredTheme");
        if (theme == null) theme = "quantum-matrix";
        request.setAttribute("preferredTheme", theme);
        request.setAttribute("currentUser", currentUser);

        // 首次进入记录活跃时间
        if (request.getSession().getAttribute("lastActiveTime") == null) {
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");
            request.getSession().setAttribute("lastActiveTime", sdf.format(new java.util.Date()));
            if (request.getSession().getAttribute("registerTime") == null) {
                request.getSession().setAttribute("registerTime", sdf.format(new java.util.Date()));
            }
        }

        request.getRequestDispatcher("/pages/settings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String action = request.getParameter("action");
        JSONObject json = new JSONObject();

        // 保存偏好到 session + 可选 DB
        if ("savePreference".equals(action)) {
            String key = request.getParameter("key");
            String value = request.getParameter("value");
            if (key != null && value != null) {
                request.getSession().setAttribute(key, value);
            }
            // 同时存到 session 属性的通用偏好字段
            if (value != null && value.startsWith("{")) {
                request.getSession().setAttribute("boya_reading_prefs", value);
            }
            json.put("success", true);
            json.put("message", "偏好已保存");
            out.print(json.toJSONString());
            return;
        }

        // 保存主题
        if ("themeChange".equals(action)) {
            String theme = request.getParameter("theme");
            if (theme != null && !theme.trim().isEmpty()) {
                request.getSession().setAttribute("preferredTheme", theme.trim());
            }
            json.put("success", true);
            json.put("message", "主题已更新");
            out.print(json.toJSONString());
            return;
        }

        json.put("success", false);
        json.put("message", "未知操作");
        out.print(json.toJSONString());
    }
}
