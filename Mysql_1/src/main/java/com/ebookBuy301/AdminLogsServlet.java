/**
 * ===========================================================================
 * AdminLogsServlet —— Servlet 控制器
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
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/adminLogs")
public class AdminLogsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBManager.getConnection();

            // 确保表存在
            ps = conn.prepareStatement(
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
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            );
            ps.execute();
            ps.close();

            // 总日志数
            ps = conn.prepareStatement("SELECT COUNT(*) FROM admin_activity_log");
            rs = ps.executeQuery();
            int logCount = 0;
            if (rs.next()) logCount = rs.getInt(1);
            rs.close();
            ps.close();

            // 最近 50 条日志
            ps = conn.prepareStatement(
                "SELECT id, username, action, action_type, ip_address, status, details, created_at " +
                "FROM admin_activity_log ORDER BY created_at DESC LIMIT 50"
            );
            rs = ps.executeQuery();
            ArrayList<Map<String, Object>> logList = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> log = new HashMap<>();
                log.put("id", rs.getLong("id"));
                log.put("username", rs.getString("username"));
                log.put("action", rs.getString("action"));
                log.put("actionType", rs.getString("action_type"));
                log.put("ipAddress", rs.getString("ip_address") != null ? rs.getString("ip_address") : "");
                log.put("status", rs.getString("status"));
                log.put("details", rs.getString("details") != null ? rs.getString("details") : "");
                Timestamp ts = rs.getTimestamp("created_at");
                log.put("createdAt", ts != null ? ts.toString() : "");
                logList.add(log);
            }

            req.setAttribute("logList", logList);
            req.setAttribute("logCount", logCount);

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

        req.getRequestDispatcher("/pages/adminLogs.jsp").forward(req, res);
    }
}
