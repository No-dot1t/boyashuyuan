/**
 * ===========================================================================
 * AdminSettingsServlet —— Servlet 控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet
 * 最后更新  2026-05-19
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
 *   doGet() —— GET 请求分发
 *   action 参数分发模式 —— 通过 request.getParameter("action") 分流操作
 *
 * ===========================================================================
 */

package com.ebookBuy301;

import com.ebookBuy301.db.DBManager;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;

@WebServlet("/adminSettings")
public class AdminSettingsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBManager.getConnection();

            // 确保 system_settings 表存在
            ps = conn.prepareStatement(
                "CREATE TABLE IF NOT EXISTS system_settings (" +
                "setting_key VARCHAR(100) PRIMARY KEY," +
                "setting_value TEXT NOT NULL," +
                "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            );
            ps.execute();
            ps.close();

            // 查询所有设置
            ps = conn.prepareStatement("SELECT setting_key, setting_value FROM system_settings");
            rs = ps.executeQuery();
            Map<String, String> settings = new HashMap<>();
            while (rs.next()) {
                settings.put(rs.getString("setting_key"), rs.getString("setting_value"));
            }

            req.setAttribute("settings", settings);

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) DBManager.close(conn);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        req.getRequestDispatcher("/pages/adminSettings.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        // 读取 JSON 请求体
        StringBuilder sb = new StringBuilder();
        BufferedReader reader = req.getReader();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
        String jsonBody = sb.toString();

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBManager.getConnection();

            // 确保表存在
            ps = conn.prepareStatement(
                "CREATE TABLE IF NOT EXISTS system_settings (" +
                "setting_key VARCHAR(100) PRIMARY KEY," +
                "setting_value TEXT NOT NULL," +
                "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            );
            ps.execute();
            ps.close();

            // 使用 fastjson 解析 JSON: {key1:value1, key2:value2, ...}
            if (jsonBody.startsWith("{") && jsonBody.endsWith("}")) {
                JSONObject jsonObject = JSON.parseObject(jsonBody);
                for (String key : jsonObject.keySet()) {
                    String value = jsonObject.getString(key);

                    ps = conn.prepareStatement(
                        "INSERT INTO system_settings (setting_key, setting_value) VALUES (?, ?) " +
                        "ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)"
                    );
                    ps.setString(1, key);
                    ps.setString(2, value);
                    ps.executeUpdate();
                    ps.close();
                }
            }

            res.setContentType("application/json;charset=UTF-8");
            res.getWriter().write("{\"success\":true,\"message\":\"设置保存成功\"}");

        } catch (SQLException e) {
            e.printStackTrace();
            res.setContentType("application/json;charset=UTF-8");
            res.getWriter().write("{\"success\":false,\"message\":\"保存失败，请稍后重试\"}");
        } finally {
            try {
                if (ps != null) ps.close();
                if (conn != null) DBManager.close(conn);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
