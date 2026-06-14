/**
 * ===========================================================================
 * ContentReviewServlet —— Servlet 控制器
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
 * doPost(HttpServletRequest req, HttpServletResponse res)HTTP 请求处理入口
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   dao = new ContentReviewDao()
 *   stats = dao.getReviewStats()
 *   filter = req.getParameter("filter")
 *   action = req.getParameter("action")
 *   idStr = req.getParameter("id")
 *   sb = new StringBuilder()
 *   body = JSON.parseObject(sb.toString(), Map.class)
 *   result = new HashMap<>()
 *   session = req.getSession()
 *   currentUser = (com.ebookBuy301.pojo.Users) session.getAttribute("currentUser")
 *   reviewerId = currentUser != null ? currentUser.getId() : "system"
 *   ok = false
 *   reason = req.getParameter("reason")
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

import com.alibaba.fastjson.JSON;
import com.ebookBuy301.dao.ContentReviewDao;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * =============================================================================
 * ContentReviewServlet —— 内容审核管理
 * =============================================================================
 *
 * GET:  加载审核页面（带统计数据和待审核队列）
 * POST: 审核操作（通过/拒绝）
 *
 * 访问路径：/contentReview
 * =============================================================================
 */
@WebServlet("/contentReview")
public class ContentReviewServlet extends HttpServlet {

    private ContentReviewDao dao = new ContentReviewDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        res.setCharacterEncoding("UTF-8");

        try {
            // 1. 获取审核统计
            Map<String, Object> stats = dao.getReviewStats();
            req.setAttribute("reviewStats", stats);

            // 2. 获取待审核队列
            String filter = req.getParameter("filter");
            ArrayList<Map<String, Object>> reviews = dao.getPendingReviews(filter);
            req.setAttribute("pendingReviews", reviews);

        } catch (Exception e) {
            System.err.println("[ContentReviewServlet] GET 错误：" + e.getMessage());
            e.printStackTrace();
            req.setAttribute("reviewStats", new HashMap<String, Object>());
            req.setAttribute("pendingReviews", new ArrayList<>());
        }

        req.getRequestDispatcher("/pages/contentReview.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        res.setContentType("application/json;charset=UTF-8");

        String action = req.getParameter("action");
        String idStr = req.getParameter("id");

        // 如果是 JSON 请求体
        if (action == null) {
            StringBuilder sb = new StringBuilder();
            String line;
            try {
                while ((line = req.getReader().readLine()) != null) sb.append(line);
                Map<?, ?> body = JSON.parseObject(sb.toString(), Map.class);
                if (body != null) {
                    action = (String) body.get("action");
                    idStr = body.get("id") != null ? body.get("id").toString() : null;
                }
            } catch (Exception ignored) {}
        }

        Map<String, Object> result = new HashMap<>();
        if (idStr == null || idStr.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "缺少审核项ID");
            res.getWriter().write(JSON.toJSONString(result));
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            result.put("success", false);
            result.put("message", "ID格式错误");
            res.getWriter().write(JSON.toJSONString(result));
            return;
        }

        // 获取审核人（从session）
        HttpSession session = req.getSession();
        com.ebookBuy301.pojo.Users currentUser = (com.ebookBuy301.pojo.Users) session.getAttribute("currentUser");
        String reviewerId = currentUser != null ? currentUser.getId() : "system";

        try {
            boolean ok = false;
            if ("approve".equals(action)) {
                ok = dao.approveReview(id, reviewerId);
                result.put("message", ok ? "审核通过" : "操作失败");
            } else if ("reject".equals(action)) {
                String reason = req.getParameter("reason");
                if (reason == null) reason = "内容不符合平台规范";
                ok = dao.rejectReview(id, reviewerId, reason);
                result.put("message", ok ? "已拒绝" : "操作失败");
            } else {
                result.put("success", false);
                result.put("message", "未知操作: " + action);
                res.getWriter().write(JSON.toJSONString(result));
                return;
            }
            result.put("success", ok);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "服务器错误：" + e.getMessage());
        }

        res.getWriter().write(JSON.toJSONString(result));
    }
}
