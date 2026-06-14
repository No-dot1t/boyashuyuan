/**
 * ===========================================================================
 * NotificationServlet —— Servlet 控制器
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
 * doDelete(HttpServletRequest req, HttpServletResponse res)内部工具方法
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   dao = new CultureNotificationDao()
 *   list = dao.getAllNotifications()
 *   sentList = new ArrayList<>()
 *   scheduledList = new ArrayList<>()
 *   status = n.getStatus()
 *   notifStats = dao.getNotificationStats()
 *   defaultStats = new java.util.HashMap<>()
 *   title = req.getParameter("title")
 *   content = req.getParameter("content")
 *   type = req.getParameter("type")
 *   target = req.getParameter("target")
 *   scheduledStr = req.getParameter("scheduled")
 *   scheduledTime = req.getParameter("scheduledTime")
 *   sb = new StringBuilder()
 *   body = JSON.parseObject(sb.toString(), Map.class)
 *   result = new HashMap<>()
 *   isScheduled = "true".equals(scheduledStr)
 *   ok = dao.addNotification(
                title.trim(),
                content != null ? content.trim() : "",
                type != null ? type : "info",
                target != null ? target : "all",
                isScheduled,
                isScheduled ? scheduledTime : null
            )
 *   id = req.getParameter("id")
 *   result = new HashMap<>()
 *   ok = dao.deleteNotification(Long.parseLong(id))
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
import com.ebookBuy301.dao.CultureNotificationDao;
import com.ebookBuy301.pojo.Notification;
import com.ebookBuy301.util.CsrfUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * NotificationServlet —— 通知管理
 * GET: 加载通知管理页面（带历史记录）
 * POST: 发送新通知（支持 JSON 和表单提交）
 * DELETE: 删除通知
 */
@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {

    private CultureNotificationDao dao = new CultureNotificationDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try {
            // 支持按类型和状态过滤
            String typeFilter = req.getParameter("type");
            String statusFilter = req.getParameter("status");

            ArrayList<Notification> list;
            if ((typeFilter != null && !typeFilter.isEmpty()) || (statusFilter != null && !statusFilter.isEmpty())) {
                list = dao.getNotificationsByFilter(typeFilter, statusFilter);
            } else {
                list = dao.getAllNotifications();
            }
            req.setAttribute("notificationList", list);
            req.setAttribute("filterType", typeFilter);
            req.setAttribute("filterStatus", statusFilter);

            // 分离已发送/定时/失败的通知
            ArrayList<Notification> sentList = new ArrayList<>();
            ArrayList<Notification> scheduledList = new ArrayList<>();
            for (Notification n : list) {
                String status = n.getStatus();
                if ("scheduled".equals(status)) {
                    scheduledList.add(n);
                } else {
                    sentList.add(n);
                }
            }
            req.setAttribute("sentNotifications", sentList);
            req.setAttribute("scheduledNotifications", scheduledList);

            // 添加通知统计数据
            java.util.Map<String, Object> notifStats = dao.getNotificationStats();
            req.setAttribute("notifStats", notifStats);
        } catch (Exception e) {
            System.err.println("[NotificationServlet] GET 错误：" + e.getMessage());
            req.setAttribute("notificationList", new ArrayList<>());
            java.util.Map<String, Object> defaultStats = new java.util.HashMap<>();
            defaultStats.put("sentCount", 0);
            defaultStats.put("scheduledCount", 0);
            defaultStats.put("failedCount", 0);
            defaultStats.put("deliveryRate", 0);
            req.setAttribute("notifStats", defaultStats);
        }
        req.getRequestDispatcher("/pages/notifications.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.setContentType("application/json;charset=UTF-8");
        req.setCharacterEncoding("UTF-8");

        String title = req.getParameter("title");
        String content = req.getParameter("content");
        String type = req.getParameter("type");
        String target = req.getParameter("target");
        String scheduledStr = req.getParameter("scheduled");
        String scheduledTime = req.getParameter("scheduledTime");
        String action = req.getParameter("action");
        String csrfFromBody = null;

        // 如果是 JSON 请求体（title 为 null），先解析 JSON 提取所有参数
        if (title == null) {
            StringBuilder sb = new StringBuilder();
            String line;
            try {
                while ((line = req.getReader().readLine()) != null) sb.append(line);
                Map<?, ?> body = JSON.parseObject(sb.toString(), Map.class);
                if (body != null) {
                    title = (String) body.get("title");
                    content = (String) body.get("content");
                    type = (String) body.get("type");
                    target = (String) body.get("target");
                    scheduledStr = body.get("scheduled") != null ? String.valueOf(body.get("scheduled")) : null;
                    scheduledTime = (String) body.get("scheduledTime");
                    if (body.get("action") != null) action = String.valueOf(body.get("action"));
                    csrfFromBody = (String) body.get("_csrf");
                }
            } catch (Exception ignored) {}
        }

        // 处理 delete 操作
        if ("delete".equals(action)) {
            if (!isCsrfValid(req, csrfFromBody)) {
                res.setStatus(403);
                res.getWriter().write("{\"success\":false,\"message\":\"CSRF 验证失败，请刷新页面后重试\"}");
                return;
            }
            String id = req.getParameter("id");
            Map<String, Object> result = new HashMap<>();
            try {
                boolean ok = dao.deleteNotification(Long.parseLong(id));
                result.put("success", ok);
                result.put("message", ok ? "删除成功" : "删除失败");
            } catch (Exception e) {
                result.put("success", false);
                result.put("message", "删除失败，请稍后重试");
            }
            res.getWriter().write(JSON.toJSONString(result));
            return;
        }

        // 处理 markRead 操作
        if ("markRead".equals(action)) {
            String notificationId = req.getParameter("notificationId");
            String userId = null;
            com.ebookBuy301.pojo.Users user = (com.ebookBuy301.pojo.Users) req.getSession().getAttribute("currentUser");
            if (user != null) userId = user.getId();
            Map<String, Object> result = new HashMap<>();
            if (userId == null || notificationId == null) {
                result.put("success", false);
                result.put("message", "参数不完整");
                res.getWriter().write(JSON.toJSONString(result));
                return;
            }
            try {
                boolean ok = dao.markNotificationRead(userId, Long.parseLong(notificationId));
                result.put("success", ok);
                result.put("message", ok ? "已标记为已读" : "操作失败");
            } catch (Exception e) {
                result.put("success", false);
                result.put("message", "服务器错误：" + e.getMessage());
            }
            res.getWriter().write(JSON.toJSONString(result));
            return;
        }

        // 发送通知需 CSRF 验证
        if (!isCsrfValid(req, csrfFromBody)) {
            res.setStatus(403);
            res.getWriter().write("{\"success\":false,\"message\":\"CSRF 验证失败，请刷新页面后重试\"}");
            return;
        }

        Map<String, Object> result = new HashMap<>();
        if (title == null || title.trim().isEmpty()) {
            res.setStatus(400);
            result.put("success", false);
            result.put("message", "标题不能为空");
            res.getWriter().write(JSON.toJSONString(result));
            return;
        }

        try {
            boolean isScheduled = "true".equals(scheduledStr);
            boolean ok = dao.addNotification(
                title.trim(),
                content != null ? content.trim() : "",
                type != null ? type : "info",
                target != null ? target : "all",
                isScheduled,
                isScheduled ? scheduledTime : null
            );
            result.put("success", ok);
            result.put("message", ok ? (isScheduled ? "定时通知设置成功" : "通知发送成功") : "操作失败");
        } catch (Exception e) {
            e.printStackTrace();
            res.setStatus(500);
            result.put("success", false);
            result.put("message", "服务器错误：" + e.getMessage());
        }
        res.getWriter().write(JSON.toJSONString(result));
    }

    /**
     * CSRF 校验：先尝试 request parameter (_csrf)，失败则尝试 JSON body 中的令牌
     */
    private boolean isCsrfValid(HttpServletRequest req, String csrfFromBody) {
        if (CsrfUtil.isValid(req)) return true;
        javax.servlet.http.HttpSession s = req.getSession(false);
        return CsrfUtil.isValidToken(s, csrfFromBody);
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.setContentType("application/json;charset=UTF-8");
        String id = req.getParameter("id");
        Map<String, Object> result = new HashMap<>();
        try {
            boolean ok = dao.deleteNotification(Long.parseLong(id));
            result.put("success", ok);
            result.put("message", ok ? "删除成功" : "删除失败");
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "删除出错：" + e.getMessage());
        }
        res.getWriter().write(JSON.toJSONString(result));
    }
}
