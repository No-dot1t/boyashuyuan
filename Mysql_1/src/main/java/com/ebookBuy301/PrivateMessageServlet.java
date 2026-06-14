package com.ebookBuy301;

import com.ebookBuy301.dao.PrivateMessageDao;
import com.ebookBuy301.pojo.PrivateMessage;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * ===========================================================================
 * PrivateMessageServlet —— 私信系统 Servlet（发/收/已读/删除）
 * ===========================================================================
 *
 * 映射路径        /api/privateMessages
 * 底层技术        Java EE Servlet
 * 数据访问        PrivateMessageDao（JDBC + PreparedStatement）
 * 最后更新        2026-06-13
 *
 * ── 路由表 ─────────────────────────────────────────────────────────────────
 *
 * 【GET】
 *   action=list&otherUserId=xxx  → 获取与指定用户的消息列表
 *   action=list                   → 获取会话列表
 *   action=poll&otherUserId=xxx&since=time → 轮询新消息
 *   action=unreadCount            → 获取未读消息数
 *
 * 【POST】
 *   action=send       → 发送私信
 *   action=delete     → 删除私信
 *
 * 【PUT】
 *   action=markRead   → 标记消息已读
 *
 * 【DELETE】
 *   action=conversation&otherUserId=xxx → 删除整个对话
 *
 * ── 使用的关键方法与算法 ────────────────────────────────────────────────────
 *
 * 方法 / 技术                  用途
 * ─────────────────────────────────────────────────────────────────
 * PrivateMessageDao.sendMessage()        发送私信
 * PrivateMessageDao.getMessagesBetween() 获取两用户间消息
 * PrivateMessageDao.getConversations()   获取会话列表
 * PrivateMessageDao.markAsRead()        标记已读
 * PrivateMessageDao.deleteMessage()      删除私信
 * PrivateMessageDao.deleteConversation() 删除对话
 * PrivateMessageDao.getUnreadCount()    获取未读消息数
 * PrivateMessageDao.getMessagesSince()   获取指定时间后的消息
 * HttpServletRequest                        获取请求参数/Session
 * response.getWriter().write()          输出 JSON 响应
 * JSON.parseObject()                   解析请求 JSON 数据
 * ===========================================================================
 */
@WebServlet("/api/privateMessages")
public class PrivateMessageServlet extends HttpServlet {

    private final PrivateMessageDao pmDao = new PrivateMessageDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession(false);
        
        String userId = null;
        if (session != null) {
            userId = (String) session.getAttribute("userId");
        }
        
        if (userId == null) {
            out.print(JSON.toJSONString(createErrorResponse("请先登录")));
            return;
        }

        String action = request.getParameter("action");
        
        try {
            if ("list".equals(action)) {
                String otherUserId = request.getParameter("otherUserId");
                if (otherUserId != null && !otherUserId.isEmpty()) {
                    List<PrivateMessage> messages = pmDao.getMessagesBetween(userId, otherUserId);
                    pmDao.markAsRead(userId, otherUserId);
                    out.print(JSON.toJSONString(createSuccessResponse(messages)));
                } else {
                    List<PrivateMessage> conversations = pmDao.getConversations(userId);
                    out.print(JSON.toJSONString(createSuccessResponse(conversations)));
                }
            } else if ("poll".equals(action)) {
                // 轮询：仅返回指定时间后的新消息
                String otherUserId = request.getParameter("otherUserId");
                String sinceStr = request.getParameter("since");
                if (otherUserId == null || otherUserId.isEmpty() || sinceStr == null || sinceStr.isEmpty()) {
                    out.print(JSON.toJSONString(createErrorResponse("缺少参数")));
                    return;
                }
                try {
                    java.sql.Timestamp since = java.sql.Timestamp.valueOf(sinceStr.replace("T", " "));
                    List<PrivateMessage> newMsgs = pmDao.getMessagesSince(userId, otherUserId, since);
                    if (!newMsgs.isEmpty()) {
                        pmDao.markAsRead(userId, otherUserId);
                    }
                    out.print(JSON.toJSONString(createSuccessResponse(newMsgs)));
                } catch (IllegalArgumentException e) {
                    out.print(JSON.toJSONString(createErrorResponse("时间格式错误")));
                }
            } else if ("unreadCount".equals(action)) {
                int count = pmDao.getUnreadCount(userId);
                JSONObject result = new JSONObject();
                result.put("unreadCount", count);
                out.print(JSON.toJSONString(createSuccessResponse(result)));
            } else {
                out.print(JSON.toJSONString(createErrorResponse("无效的操作")));
            }
        } catch (Exception e) {
            System.err.println("[PrivateMessageServlet] GET Error: " + e.getMessage());
            out.print(JSON.toJSONString(createErrorResponse("服务器内部错误")));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession(false);
        
        String userId = null;
        if (session != null) {
            userId = (String) session.getAttribute("userId");
        }
        
        if (userId == null) {
            out.print(JSON.toJSONString(createErrorResponse("请先登录")));
            return;
        }

        try {
            String jsonData = request.getReader().lines().reduce("", String::concat);
            JSONObject data = JSON.parseObject(jsonData);
            
            String action = data.getString("action");
            
            if ("send".equals(action)) {
                String receiverId = data.getString("receiverId");
                String content = data.getString("content");
                
                if (receiverId == null || receiverId.isEmpty() || content == null || content.isEmpty()) {
                    out.print(JSON.toJSONString(createErrorResponse("缺少必要参数")));
                    return;
                }
                
                boolean success = pmDao.sendMessage(userId, receiverId, content);
                if (success) {
                    out.print(JSON.toJSONString(createSuccessResponse("发送成功")));
                } else {
                    out.print(JSON.toJSONString(createErrorResponse("发送失败")));
                }
            } else if ("delete".equals(action)) {
                Long messageId = data.getLong("messageId");
                if (messageId == null) {
                    out.print(JSON.toJSONString(createErrorResponse("缺少消息ID")));
                    return;
                }
                
                boolean success = pmDao.deleteMessage(userId, messageId);
                if (success) {
                    out.print(JSON.toJSONString(createSuccessResponse("删除成功")));
                } else {
                    out.print(JSON.toJSONString(createErrorResponse("删除失败")));
                }
            } else {
                out.print(JSON.toJSONString(createErrorResponse("无效的操作")));
            }
        } catch (Exception e) {
            System.err.println("[PrivateMessageServlet] POST Error: " + e.getMessage());
            out.print(JSON.toJSONString(createErrorResponse("服务器内部错误")));
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession(false);
        
        String userId = null;
        if (session != null) {
            userId = (String) session.getAttribute("userId");
        }
        
        if (userId == null) {
            out.print(JSON.toJSONString(createErrorResponse("请先登录")));
            return;
        }

        try {
            String jsonData = request.getReader().lines().reduce("", String::concat);
            JSONObject data = JSON.parseObject(jsonData);
            
            String action = data.getString("action");
            
            if ("markRead".equals(action)) {
                String otherUserId = data.getString("otherUserId");
                if (otherUserId == null || otherUserId.isEmpty()) {
                    out.print(JSON.toJSONString(createErrorResponse("缺少用户ID")));
                    return;
                }
                
                boolean success = pmDao.markAsRead(userId, otherUserId);
                if (success) {
                    out.print(JSON.toJSONString(createSuccessResponse("标记已读成功")));
                } else {
                    out.print(JSON.toJSONString(createErrorResponse("标记失败")));
                }
            } else {
                out.print(JSON.toJSONString(createErrorResponse("无效的操作")));
            }
        } catch (Exception e) {
            System.err.println("[PrivateMessageServlet] PUT Error: " + e.getMessage());
            out.print(JSON.toJSONString(createErrorResponse("服务器内部错误")));
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession(false);
        
        String userId = null;
        if (session != null) {
            userId = (String) session.getAttribute("userId");
        }
        
        if (userId == null) {
            out.print(JSON.toJSONString(createErrorResponse("请先登录")));
            return;
        }

        String action = request.getParameter("action");
        String otherUserId = request.getParameter("otherUserId");
        
        try {
            if ("conversation".equals(action) && otherUserId != null && !otherUserId.isEmpty()) {
                boolean success = pmDao.deleteConversation(userId, otherUserId);
                if (success) {
                    out.print(JSON.toJSONString(createSuccessResponse("删除对话成功")));
                } else {
                    out.print(JSON.toJSONString(createErrorResponse("删除失败")));
                }
            } else {
                out.print(JSON.toJSONString(createErrorResponse("无效的操作")));
            }
        } catch (Exception e) {
            System.err.println("[PrivateMessageServlet] DELETE Error: " + e.getMessage());
            out.print(JSON.toJSONString(createErrorResponse("服务器内部错误")));
        }
    }

    private JSONObject createSuccessResponse(Object data) {
        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("data", data);
        return result;
    }

    private JSONObject createErrorResponse(String message) {
        JSONObject result = new JSONObject();
        result.put("success", false);
        result.put("message", message);
        return result;
    }
}