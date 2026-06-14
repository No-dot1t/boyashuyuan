/**
 * ===========================================================================
 * RecommendServlet —— Servlet 控制器
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
 * doPost(HttpServletRequest request, HttpServletResponse response)HTTP 请求处理入口
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   engine = new RecommendEngine()
 *   session = request.getSession()
 *   currentUser = (Users) session.getAttribute("currentUser")
 *   userId = (currentUser != null) ? currentUser.getId() : null
 *   username = (currentUser != null) ? currentUser.getUsername() : ""
 *   filterType = request.getParameter("filterType")
 *   isPersonal = (userId != null && !userId.isEmpty())
 *   summary = engine.getStudySummary(userId)
 *   skills = engine.getSkills(userId)
 *   items = engine.recommend(userId, filterType, 20)
 *   steps = engine.getLearningSteps(userId)
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   @WebServlet —— 注解式 Servlet 路由映射
 *   Servlet API —— HttpServlet / HttpServletRequest / HttpServletResponse
 *   doGet() —— GET 请求分发
 *   doPost() —— POST 请求分发
 *   action 参数分发模式 —— 通过 request.getParameter("action") 分流操作
 *
 * ===========================================================================
 */

package com.ebookBuy301;

import com.ebookBuy301.pojo.*;
import com.ebookBuy301.service.RecommendEngine;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;

/**
 * =============================================================================
 * RecommendServlet —— 跨模块智能推荐
 * =============================================================================
 *
 * 从 book / course / lecture 真实数据中生成个性化推荐。
 * 支持根据用户登录状态生成个性化或通用推荐。
 *
 * 访问路径：/recommend
 *
 * 请求参数：
 *   - filterType（可选）：按类型筛选推荐内容
 *
 * 页面数据：
 *   1. 学习汇总（StudySummary）
 *   2. 技能列表（Skills）
 *   3. 跨模块推荐内容（RecommendItems）
 *   4. 学习路径（LearningSteps）
 * =============================================================================
 */
@WebServlet("/recommend")
public class RecommendServlet extends HttpServlet {

    private RecommendEngine engine = new RecommendEngine();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // 从 session 获取当前登录用户信息
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("currentUser");
        String userId = (currentUser != null) ? currentUser.getId() : null;
        String username = (currentUser != null) ? currentUser.getUsername() : "";

        // 获取筛选类型
        String filterType = request.getParameter("filterType");
        request.setAttribute("filterType", filterType);

        // 是否登录用户的个性化推荐
        boolean isPersonal = (userId != null && !userId.isEmpty());

        try {
            // ===== 1. 学习汇总 =====
            StudySummary summary = engine.getStudySummary(userId);
            request.setAttribute("summary", summary);

            // ===== 2. 技能列表 =====
            ArrayList<Skill> skills = engine.getSkills(userId);
            request.setAttribute("skills", skills);

            // ===== 3. 跨模块智能推荐内容 =====
            ArrayList<RecommendItem> items = engine.recommend(userId, filterType, 20);
            request.setAttribute("items", items);

            // ===== 4. 学习路径 =====
            ArrayList<LearningStep> steps = engine.getLearningSteps(userId);
            request.setAttribute("steps", steps);

            // ===== 5. 标记是否为个性化推荐 =====
            request.setAttribute("isPersonal", isPersonal);
            request.setAttribute("recommendUsername", username);

            // 转发到 JSP
            request.getRequestDispatcher("/pages/recommend.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("[RecommendServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            // 异常时返回空数据
            request.setAttribute("recommendBooks", new ArrayList<>());
            request.setAttribute("recommendCourses", new ArrayList<>());
            request.setAttribute("recommendLectures", new ArrayList<>());
            request.getRequestDispatcher("/pages/recommend.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
