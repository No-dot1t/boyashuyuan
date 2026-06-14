/**
 * ===========================================================================
 * AdminUserAnalysisServlet —— Servlet 控制器
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
import java.util.HashMap;
import java.util.Map;

@WebServlet("/adminUserAnalysis")
public class AdminUserAnalysisServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBManager.getConnection();

            // 总用户数
            ps = conn.prepareStatement("SELECT COUNT(*) FROM users");
            rs = ps.executeQuery();
            int totalUsers = 0;
            if (rs.next()) totalUsers = rs.getInt(1);
            rs.close();
            ps.close();

            // 7 天内新增用户
            ps = conn.prepareStatement(
                "SELECT COUNT(*) FROM users WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)"
            );
            rs = ps.executeQuery();
            int newUsers7Days = 0;
            if (rs.next()) newUsers7Days = rs.getInt(1);
            rs.close();
            ps.close();

            // 角色分布
            ps = conn.prepareStatement(
                "SELECT role, COUNT(*) AS cnt FROM users GROUP BY role ORDER BY cnt DESC"
            );
            rs = ps.executeQuery();
            Map<String, Integer> roleDistribution = new HashMap<>();
            while (rs.next()) {
                String role = rs.getString("role");
                roleDistribution.put(role != null && !role.isEmpty() ? role : "user", rs.getInt("cnt"));
            }

            req.setAttribute("totalUsers", totalUsers);
            req.setAttribute("newUsers7Days", newUsers7Days);
            req.setAttribute("roleDistribution", roleDistribution);

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

        req.getRequestDispatcher("/pages/adminUserAnalysis.jsp").forward(req, res);
    }
}
