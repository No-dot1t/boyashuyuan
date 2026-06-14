/**
 * ===========================================================================
 * AdminReportServlet —— Servlet 控制器
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

@WebServlet("/adminReport")
public class AdminReportServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBManager.getConnection();

            // 图书总数
            ps = conn.prepareStatement("SELECT COUNT(*) FROM book");
            rs = ps.executeQuery();
            int bookCount = 0;
            if (rs.next()) bookCount = rs.getInt(1);
            rs.close();
            ps.close();

            // 用户总数
            ps = conn.prepareStatement("SELECT COUNT(*) FROM users");
            rs = ps.executeQuery();
            int userCount = 0;
            if (rs.next()) userCount = rs.getInt(1);
            rs.close();
            ps.close();

            // 讲座总数
            ps = conn.prepareStatement("SELECT COUNT(*) FROM lecture");
            rs = ps.executeQuery();
            int lectureCount = 0;
            if (rs.next()) lectureCount = rs.getInt(1);
            rs.close();
            ps.close();

            // 课程总数
            ps = conn.prepareStatement("SELECT COUNT(*) FROM course");
            rs = ps.executeQuery();
            int courseCount = 0;
            if (rs.next()) courseCount = rs.getInt(1);
            rs.close();
            ps.close();

            req.setAttribute("bookCount", bookCount);
            req.setAttribute("userCount", userCount);
            req.setAttribute("lectureCount", lectureCount);
            req.setAttribute("courseCount", courseCount);

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

        req.getRequestDispatcher("/pages/adminReport.jsp").forward(req, res);
    }
}
