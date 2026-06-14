/**
 * ===========================================================================
 * ForYouServlet —— 为你推荐专用控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet("/forYou")
 * 最后更新  2026-06-04
 *
 * ── 功能 ──────────────────────────────────────────────────────────────
 *
 * 从首页"为你推荐"进入，展示精选个性化推荐内容（仅推荐卡片列表）。
 * 与 RecommendServlet(/recommend) 的区别：
 *   - /recommend = 阅读中心（Dashboard + 推荐 + 学习路径 三大块）
 *   - /forYou    = 为你推荐（仅推荐列表，精简聚焦）
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
import java.util.Map;

@WebServlet("/forYou")
public class ForYouServlet extends HttpServlet {

    private RecommendEngine engine = new RecommendEngine();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("currentUser");
        String userId = (currentUser != null) ? currentUser.getId() : null;
        String username = (currentUser != null) ? currentUser.getUsername() : "";

        boolean isPersonal = (userId != null && !userId.isEmpty());
        String filterType = request.getParameter("filterType");

        try {
            ArrayList<RecommendItem> items = engine.recommend(userId, filterType, 24);
            request.setAttribute("items", items);
            request.setAttribute("filterType", filterType != null ? filterType : "all");
            request.setAttribute("isPersonal", isPersonal);
            request.setAttribute("recommendUsername", username);
            request.setAttribute("totalCount", items != null ? items.size() : 0);
            // AI 用户兴趣画像
            request.setAttribute("userProfile", engine.getUserProfileForDisplay(userId));

            request.getRequestDispatcher("/pages/forYou.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("[ForYouServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            request.setAttribute("items", new ArrayList<RecommendItem>());
            request.setAttribute("filterType", "all");
            request.setAttribute("isPersonal", isPersonal);
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/pages/forYou.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
