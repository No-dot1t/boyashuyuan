/**
 * ===========================================================================
 * Campus3dPageServlet —— Servlet 控制器
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
 * doGet(HttpServletRequest request, HttpServletResponse response)HTTP 请求处理入口
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   sceneDao = new CampusSceneDao()
 *   activityDao = new UserActivityDao()
 *   scenes = sceneDao.getAllActiveScenes()
 *   stats = new HashMap<>()
 *   user = (Users) request.getSession().getAttribute("currentUser")
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

import com.ebookBuy301.dao.CampusSceneDao;
import com.ebookBuy301.dao.UserActivityDao;
import com.ebookBuy301.db.DBManager;
import com.ebookBuy301.pojo.CampusScene;
import com.ebookBuy301.pojo.Users;

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
import java.util.HashMap;
import java.util.Map;

@WebServlet("/campus3d")
public class Campus3dPageServlet extends HttpServlet {

    private CampusSceneDao sceneDao = new CampusSceneDao();
    private UserActivityDao activityDao = new UserActivityDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // 加载场景列表
            ArrayList<CampusScene> scenes = sceneDao.getAllActiveScenes();
            request.setAttribute("scenes", scenes);

            // 统计数据
            Map<String, Object> stats = new HashMap<>();
            stats.put("onlineUsers", activityDao.getActiveUserCount(5));
            stats.put("sceneCount", scenes.size());

            // 从 user_evaluations 表查询真实满意度评分
            double satisfactionRate = 0;
            int evaluationCount = 0;
            String evalSql = "SELECT AVG(rating) AS avg_rating, COUNT(*) AS total_count FROM user_evaluations WHERE target_type = 'campus3d'";
            try (Connection conn = DBManager.getConnection();
                    PreparedStatement ps = conn.prepareStatement(evalSql);
                    ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    satisfactionRate = rs.getDouble("avg_rating");
                    evaluationCount = rs.getInt("total_count");
                }
            } catch (SQLException e) {
                System.err.println("[Campus3dPageServlet] 查询满意度失败：" + e.getMessage());
            }

            // 如果没有评价数据，使用默认值
            if (evaluationCount == 0) {
                satisfactionRate = 85; // 默认满意度
                evaluationCount = 0;
            }

            stats.put("satisfactionRate", (int) Math.round(satisfactionRate));
            stats.put("evaluationCount", evaluationCount);
            stats.put("is24hOpen", true);
            request.setAttribute("campusStats", stats);

            // 记录用户访问
            Users user = (Users) request.getSession().getAttribute("currentUser");
            if (user != null) {
                activityDao.logActivity(user.getId(), "visit_scene", null, "访问元宇宙校园");
            }
        } catch (Exception e) {
            System.err.println("[Campus3dPageServlet] 错误：" + e.getMessage());
        }
        request.getRequestDispatcher("/pages/campus3d.jsp").forward(request, response);
    }
}
