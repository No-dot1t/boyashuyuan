/**
 * ===========================================================================
 * VirtualLabServlet —— Servlet 控制器
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
 * getExperimentById(int id)          查询操作
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   category = req.getParameter("category")
 *   idParam = req.getParameter("id")
 *   exp = getExperimentById(Integer.parseInt(idParam))
 *   categoryCount = new HashMap<>()
 *   cat = (String) exp.get("category")
 *   sql = "SELECT * FROM lab_experiment WHERE 1=1"
 *   category = ?"
 *   conn = com.ebookBuy301.db.DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            if (category != null && !category.isEmpty() && !"all".equals(category)) {
                ps.setString(1, category)
 *   rs = ps.executeQuery()
 *   m = new HashMap<>()
 *   m = new HashMap<>()
 *   sql = "SELECT * FROM lab_experiment WHERE id = ?"
 *   conn = com.ebookBuy301.db.DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id)
 *   rs = ps.executeQuery()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   @WebServlet —— 注解式 Servlet 路由映射
 *   Servlet API —— HttpServlet / HttpServletRequest / HttpServletResponse
 *   JDBC —— Connection / PreparedStatement / ResultSet 数据库访问
 *   doGet() —— GET 请求分发
 *   action 参数分发模式 —— 通过 request.getParameter("action") 分流操作
 *
 * ===========================================================================
 */

package com.ebookBuy301;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * VirtualLabServlet - 虚拟实验室
 * GET: 加载实验列表（支持分类筛选）
 */
@WebServlet("/virtualLab")
public class VirtualLabServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String category = req.getParameter("category");
        String idParam = req.getParameter("id");
        String mode = req.getParameter("mode");

        boolean isLabMode = "lab".equals(mode);

        if (idParam != null && !idParam.isEmpty()) {
            // 查看实验详情或进入实验模式
            try {
                Map<String, Object> exp = getExperimentById(Integer.parseInt(idParam));
                req.setAttribute("experiment", exp);
                req.setAttribute("isDetail", !isLabMode);
                req.setAttribute("isLabMode", isLabMode);
            } catch (Exception e) {
                req.setAttribute("experiment", null);
                req.setAttribute("isDetail", !isLabMode);
                req.setAttribute("isLabMode", isLabMode);
            }
        } else {
            req.setAttribute("isDetail", false);
            req.setAttribute("isLabMode", false);
        }

        // 获取实验列表
        ArrayList<Map<String, Object>> experiments = getExperiments(category);
        req.setAttribute("experiments", experiments);
        req.setAttribute("currentCategory", category != null ? category : "all");

        // 分类统计
        Map<String, Integer> categoryCount = new HashMap<>();
        for (Map<String, Object> exp : experiments) {
            String cat = (String) exp.get("category");
            categoryCount.put(cat, categoryCount.getOrDefault(cat, 0) + 1);
        }
        req.setAttribute("categoryCount", categoryCount);

        req.getRequestDispatcher("/pages/virtualLab.jsp").forward(req, res);
    }

    private ArrayList<Map<String, Object>> getExperiments(String category) {
        ArrayList<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM lab_experiment WHERE 1=1";
        if (category != null && !category.isEmpty() && !"all".equals(category)) {
            sql += " AND category = ?";
        }
        sql += " ORDER BY created_at DESC";
        try (Connection conn = com.ebookBuy301.db.DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            if (category != null && !category.isEmpty() && !"all".equals(category)) {
                ps.setString(1, category);
            }
            try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("name", rs.getString("name"));
                m.put("category", rs.getString("category"));
                m.put("description", rs.getString("description"));
                m.put("equipment", rs.getString("equipment"));
                m.put("steps", rs.getString("steps"));
                m.put("safetyNotes", rs.getString("safety_notes"));
                m.put("difficulty", rs.getString("difficulty"));
                m.put("durationMin", rs.getInt("duration_min"));
                m.put("createdAt", rs.getTimestamp("created_at"));
                list.add(m);
            }
            }
        } catch (Exception e) {
            System.err.println("[VirtualLabServlet] 获取实验列表失败: " + e.getMessage());
        }
        return list;
    }

    private Map<String, Object> getExperimentById(int id) {
        Map<String, Object> m = new HashMap<>();
        String sql = "SELECT * FROM lab_experiment WHERE id = ?";
        try (Connection conn = com.ebookBuy301.db.DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                m.put("id", rs.getInt("id"));
                m.put("name", rs.getString("name"));
                m.put("category", rs.getString("category"));
                m.put("description", rs.getString("description"));
                m.put("equipment", rs.getString("equipment"));
                m.put("steps", rs.getString("steps"));
                m.put("safetyNotes", rs.getString("safety_notes"));
                m.put("difficulty", rs.getString("difficulty"));
                m.put("durationMin", rs.getInt("duration_min"));
            }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return m.isEmpty() ? null : m;
    }
}
