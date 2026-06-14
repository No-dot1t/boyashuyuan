/**
 * ===========================================================================
 * AdminSecurityServlet —— 安全管理控制器
 * ===========================================================================
 * 
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet("/adminSecurity")
 * 
 * 在 init() 阶段建表，在 doGet() 中查询安全统计数据。
 * ===========================================================================
 */

package com.ebookBuy301;

import com.ebookBuy301.db.DBManager;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

@WebServlet("/adminSecurity")
public class AdminSecurityServlet extends HttpServlet {

    @Override
    public void init() throws ServletException {
        // 应用加载时一次性建表，避免每次 HTTP 请求都执行 DDL
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "CREATE TABLE IF NOT EXISTS admin_activity_log (" +
                     "id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                     "username VARCHAR(100) NOT NULL," +
                     "action VARCHAR(200) NOT NULL," +
                     "action_type VARCHAR(50) DEFAULT 'login'," +
                     "ip_address VARCHAR(50) DEFAULT NULL," +
                     "status VARCHAR(20) DEFAULT 'success'," +
                     "details TEXT," +
                     "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                     "INDEX idx_username (username)," +
                     "INDEX idx_created_at (created_at)" +
                     ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4")) {
            ps.execute();
            System.out.println("[AdminSecurityServlet] admin_activity_log 表已就绪");
        } catch (Exception e) {
            throw new ServletException("Failed to initialize admin_activity_log table", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try (Connection conn = DBManager.getConnection()) {
            // 总登录尝试次数
            int loginAttempts = 0;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM admin_activity_log WHERE action_type = 'login'");
                    ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    loginAttempts = rs.getInt(1);
            }

            // 失败登录次数
            int failedLogins = 0;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM admin_activity_log WHERE action_type = 'login' AND status = 'failed'");
                    ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    failedLogins = rs.getInt(1);
            }

            // 最近登录活动
            ArrayList<String> recentLogins = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT username, action, status, created_at, ip_address " +
                            "FROM admin_activity_log ORDER BY created_at DESC LIMIT 10");
                    ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String ip = rs.getString("ip_address");
                    recentLogins.add(rs.getString("username") + "|"
                            + rs.getString("action") + "|"
                            + rs.getString("status") + "|"
                            + rs.getTimestamp("created_at") + "|"
                            + (ip != null ? ip : ""));
                }
            }

            req.setAttribute("loginAttempts", loginAttempts);
            req.setAttribute("failedLogins", failedLogins);
            req.setAttribute("recentLogins", recentLogins);

        } catch (SQLException e) {
            System.err.println("[AdminSecurityServlet] Database error: " + e.getMessage());
        }

        req.getRequestDispatcher("/pages/adminSecurity.jsp").forward(req, res);
    }
}
