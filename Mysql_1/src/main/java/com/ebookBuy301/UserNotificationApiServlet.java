/**
 * UserNotificationApiServlet —— 用户端通知 API
 *
 * 路径：/api/userNotifications
 * 响应格式：JSON
 *
 * GET  /api/userNotifications?action=list       → 获取当前用户通知列表
 * GET  /api/userNotifications?action=unreadCount → 获取未读数
 * POST /api/userNotifications  body: {action, notificationId} → 标记已读/删除等
 */
package com.ebookBuy301;

import com.alibaba.fastjson.JSON;
import com.ebookBuy301.dao.CultureNotificationDao;
import com.ebookBuy301.pojo.Notification;
import com.ebookBuy301.pojo.Users;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;
import java.text.SimpleDateFormat;

@WebServlet("/api/userNotifications")
public class UserNotificationApiServlet extends HttpServlet {

    private CultureNotificationDao dao = new CultureNotificationDao();

    // ------ 工具方法：获取当前登录用户 ------
    private Users getCurrentUser(HttpServletRequest req) {
        return (Users) req.getSession().getAttribute("currentUser");
    }

    // ------ 工具方法：JSON 响应 ------
    private void jsonOut(HttpServletResponse res, Object data) throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        res.getWriter().write(JSON.toJSONString(data));
    }

    // ------ 通用错误 JSON ------
    private Map<String, Object> error(String msg) {
        Map<String, Object> m = new HashMap<>();
        m.put("success", false);
        m.put("message", msg);
        return m;
    }
    private Map<String, Object> ok(String msg) {
        Map<String, Object> m = new HashMap<>();
        m.put("success", true);
        m.put("message", msg);
        return m;
    }

    // ======================== GET ========================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        Users user = getCurrentUser(req);
        if (user == null) {
            jsonOut(res, error("用户未登录"));
            return;
        }
        String userId = user.getId();
        String action = req.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "unreadCount": {
                    int count = dao.getUnreadCountForUser(userId);
                    Map<String, Object> m = new HashMap<>();
                    m.put("success", true);
                    m.put("count", count);
                    jsonOut(res, m);
                    break;
                }
                case "detail": {
                    String nidStr = req.getParameter("id");
                    if (nidStr == null || nidStr.isEmpty()) {
                        jsonOut(res, error("缺少通知ID"));
                        break;
                    }
                    long nid = Long.parseLong(nidStr);
                    Notification n = dao.getNotificationById(nid);
                    if (n == null) {
                        jsonOut(res, error("通知不存在"));
                        break;
                    }
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("success", true);
                    item.put("id", n.getId());
                    item.put("title", n.getTitle() != null ? n.getTitle() : "");
                    item.put("content", n.getContent() != null ? n.getContent() : "");
                    item.put("type", n.getNotificationType() != null ? n.getNotificationType() : "info");
                    item.put("sendTime", n.getSendTime() != null ? new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(n.getSendTime()) : "");
                    item.put("senderId", n.getSenderId());
                    item.put("status", n.getStatus());
                    jsonOut(res, item);
                    break;
                }
                default: { // list
                    int offset = 0, limit = 50;
                    try { offset = Integer.parseInt(req.getParameter("offset")); } catch (Exception ignored) {}
                    try { limit = Integer.parseInt(req.getParameter("limit")); } catch (Exception ignored) {}
                    if (limit > 200) limit = 200;
                    ArrayList<Notification> list = dao.getNotificationsForUser(userId, offset, limit);
                    ArrayList<Notification> nextPage = dao.getNotificationsForUser(userId, offset + limit, 1);
                    boolean hasMore = !nextPage.isEmpty();
                    List<Map<String, Object>> result = new ArrayList<>();
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    for (Notification n : list) {
                        Map<String, Object> item = new LinkedHashMap<>();
                        item.put("id", n.getId());
                        item.put("title", n.getTitle() != null ? n.getTitle() : "");
                        item.put("content", n.getContent() != null ? n.getContent() : "");
                        item.put("type", n.getNotificationType() != null ? n.getNotificationType() : "info");
                        item.put("time", n.getSendTime() != null ? sdf.format(n.getSendTime()) : "");
                        item.put("isRead", n.getReadCount() > 0);
                        result.add(item);
                    }
                    Map<String, Object> m = new HashMap<>();
                    m.put("success", true);
                    m.put("data", result);
                    m.put("hasMore", hasMore);
                    m.put("offset", offset);
                    m.put("limit", limit);
                    jsonOut(res, m);
                    break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            jsonOut(res, error("服务器错误：" + e.getMessage()));
        }
    }

    // ======================== POST ========================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        Users user = getCurrentUser(req);
        if (user == null) {
            jsonOut(res, error("用户未登录"));
            return;
        }
        String userId = user.getId();

        // 解析 JSON 请求体
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = req.getReader().readLine()) != null) sb.append(line);
        Map<?, ?> body = sb.length() > 0 ? JSON.parseObject(sb.toString(), Map.class) : new HashMap<>();

        String action = (String) body.get("action");
        if (action == null) action = req.getParameter("action");
        if (action == null) { jsonOut(res, error("缺少 action 参数")); return; }

        try {
            switch (action) {
                case "markRead": {
                    Object nidObj = body.get("notificationId");
                    long nid = nidObj instanceof Number ? ((Number) nidObj).longValue()
                               : Long.parseLong(String.valueOf(nidObj));
                    boolean ok = dao.markNotificationRead(userId, nid);
                    jsonOut(res, ok ? ok("已标记为已读") : error("操作失败"));
                    break;
                }
                case "markAllRead": {
                    boolean ok = dao.markAllNotificationsRead(userId);
                    jsonOut(res, ok ? ok("已全部标记为已读") : error("操作失败"));
                    break;
                }
                case "delete": {
                    Object nidObj = body.get("notificationId");
                    long nid = nidObj instanceof Number ? ((Number) nidObj).longValue()
                               : Long.parseLong(String.valueOf(nidObj));
                    boolean ok = dao.hideNotificationForUser(nid, userId);
                    jsonOut(res, ok ? ok("通知已删除") : error("操作失败"));
                    break;
                }
                case "deleteRead": {
                    boolean ok = dao.hideAllReadNotifications(userId);
                    jsonOut(res, ok ? ok("已读通知已清除") : error("操作失败"));
                    break;
                }
                default:
                    jsonOut(res, error("未知操作: " + action));
            }
        } catch (Exception e) {
            e.printStackTrace();
            jsonOut(res, error("服务器错误：" + e.getMessage()));
        }
    }
}
