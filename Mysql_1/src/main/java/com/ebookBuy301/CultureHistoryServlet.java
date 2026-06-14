/**
 * ===========================================================================
 * CultureHistoryServlet —— Servlet 控制器
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
 * sendErrorResponse(HttpServletResponse response, int statusCode, String message)内部工具方法
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   dao = new CultureNotificationDao()
 *   module = request.getParameter("module")
 *   events = dao.getAllCultureEvents()
 *   records = dao.getAllHistoryRecords()
 *   notifications = dao.getAllNotifications()
 *   result = new HashMap<>()
 *   error = new HashMap<>()
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

import com.alibaba.fastjson.JSON;
import com.ebookBuy301.dao.CultureNotificationDao;
import com.ebookBuy301.pojo.CultureEvent;
import com.ebookBuy301.pojo.HistoryRecord;
import com.ebookBuy301.pojo.Notification;

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
 * =============================================================================
 * CultureHistoryServlet —— 文化·历史·通知综合数据 API
 * =============================================================================
 *
 * 提供文化活动、历史记录、通知公告的综合数据查询接口。
 *
 * 访问路径：/culture-history
 *
 * 请求参数 module：
 *   - culture       → 获取文化活动列表
 *   - history       → 获取历史记录列表
 *   - notifications → 获取通知公告列表
 *   - 无参数        → 返回所有数据（文化活动 + 历史 + 通知）
 * =============================================================================
 */
@WebServlet("/culture-history")
public class CultureHistoryServlet extends HttpServlet {

    private CultureNotificationDao dao = new CultureNotificationDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        String module = request.getParameter("module");

        try {
            if ("culture".equals(module)) {
                ArrayList<CultureEvent> events = dao.getAllCultureEvents();
                response.getWriter().write(JSON.toJSONString(events));

            } else if ("history".equals(module)) {
                ArrayList<HistoryRecord> records = dao.getAllHistoryRecords();
                response.getWriter().write(JSON.toJSONString(records));

            } else if ("notifications".equals(module)) {
                ArrayList<Notification> notifications = dao.getAllNotifications();
                response.getWriter().write(JSON.toJSONString(notifications));

            } else {
                Map<String, Object> result = new HashMap<>();
                result.put("culture", dao.getAllCultureEvents());
                result.put("history", dao.getAllHistoryRecords());
                result.put("notifications", dao.getAllNotifications());
                response.getWriter().write(JSON.toJSONString(result));
            }

        } catch (Exception e) {
            System.err.println("[CultureHistoryServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    private void sendErrorResponse(HttpServletResponse response, int statusCode, String message)
            throws IOException {
        response.setStatus(statusCode);
        Map<String, Object> error = new HashMap<>();
        error.put("success", false);
        error.put("error", message);
        response.getWriter().write(JSON.toJSONString(error));
    }
}
