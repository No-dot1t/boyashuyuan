/**
 * ===========================================================================
 * HomeNewsServlet —— Servlet 控制器
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
 * doPut(HttpServletRequest request, HttpServletResponse response)内部工具方法
 * doDelete(HttpServletRequest request, HttpServletResponse response)内部工具方法
 * buildResult(boolean success, String successMsg, String failMsg)内部工具方法
 * sendErrorResponse(HttpServletResponse response, int statusCode, String message)内部工具方法
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   homeNewsDao = new HomeNewsDao()
 *   action = request.getParameter("action")
 *   id = request.getParameter("id")
 *   type = request.getParameter("type")
 *   newsList = homeNewsDao.getTopNews()
 *   news = homeNewsDao.getNewsById(Long.parseLong(id))
 *   newsList = homeNewsDao.getNewsByType(type)
 *   newsList = homeNewsDao.getAllPublishedNews()
 *   news = parseRequestBody(request, HomeNews.class)
 *   success = homeNewsDao.addNews(news)
 *   result = buildResult(success, "新闻添加成功", "新闻添加失败")
 *   news = parseRequestBody(request, HomeNews.class)
 *   success = homeNewsDao.updateNews(news)
 *   id = request.getParameter("id")
 *   success = homeNewsDao.deleteNews(Long.parseLong(id))
 *   sb = new StringBuilder()
 *   result = new HashMap<>()
 *   error = new HashMap<>()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   @WebServlet —— 注解式 Servlet 路由映射
 *   Servlet API —— HttpServlet / HttpServletRequest / HttpServletResponse
 *   JDBC —— Connection / PreparedStatement / ResultSet 数据库访问
 *   doGet() —— GET 请求分发
 *   doPost() —— POST 请求分发
 *   action 参数分发模式 —— 通过 request.getParameter("action") 分流操作
 *
 * ===========================================================================
 */

package com.ebookBuy301;

import com.alibaba.fastjson.JSON;
import com.ebookBuy301.dao.HomeNewsDao;
import com.ebookBuy301.pojo.HomeNews;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * =============================================================================
 * HomeNewsServlet —— 首页新闻管理 RESTful API
 * =============================================================================
 *
 * 提供首页新闻/公告的增删改查 RESTful API。
 *
 * 访问路径：/home-news
 *
 * GET 请求：
 *   - /home-news?action=top      → 获取置顶新闻
 *   - /home-news?id=1             → 获取单个新闻详情
 *   - /home-news?type=通知        → 按类型查询
 *   - /home-news（无参数）        → 获取所有已发布新闻
 *
 * POST 请求：添加新闻（JSON 请求体，自动设置发布时间和状态）
 * PUT 请求：更新新闻（JSON 请求体）
 * DELETE 请求：/home-news?id=1 → 删除新闻
 * =============================================================================
 */
@WebServlet("/home-news")
public class HomeNewsServlet extends HttpServlet {

    private HomeNewsDao homeNewsDao = new HomeNewsDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        String action = request.getParameter("action");
        String id = request.getParameter("id");
        String type = request.getParameter("type");

        try {
            if ("top".equals(action)) {
                ArrayList<HomeNews> newsList = homeNewsDao.getTopNews();
                response.getWriter().write(JSON.toJSONString(newsList));

            } else if (id != null) {
                HomeNews news = homeNewsDao.getNewsById(Long.parseLong(id));
                if (news != null) {
                    response.getWriter().write(JSON.toJSONString(news));
                } else {
                    sendErrorResponse(response, 404, "新闻不存在");
                }

            } else if (type != null) {
                ArrayList<HomeNews> newsList = homeNewsDao.getNewsByType(type);
                response.getWriter().write(JSON.toJSONString(newsList));

            } else {
                ArrayList<HomeNews> newsList = homeNewsDao.getAllPublishedNews();
                response.getWriter().write(JSON.toJSONString(newsList));
            }

        } catch (Exception e) {
            System.err.println("[HomeNewsServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        try {
            HomeNews news = parseRequestBody(request, HomeNews.class);

            if (news.getPublishTime() == null) {
                news.setPublishTime(new Timestamp(System.currentTimeMillis()));
            }
            if (news.getStatus() == null) {
                news.setStatus("published");
            }

            boolean success = homeNewsDao.addNews(news);
            Map<String, Object> result = buildResult(success, "新闻添加成功", "新闻添加失败");
            if (success) response.setStatus(HttpServletResponse.SC_CREATED);
            response.getWriter().write(JSON.toJSONString(result));

        } catch (Exception e) {
            System.err.println("[HomeNewsServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        try {
            HomeNews news = parseRequestBody(request, HomeNews.class);
            boolean success = homeNewsDao.updateNews(news);
            response.getWriter().write(JSON.toJSONString(buildResult(success, "新闻更新成功", "新闻更新失败")));

        } catch (Exception e) {
            System.err.println("[HomeNewsServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        String id = request.getParameter("id");

        try {
            if (id == null) {
                sendErrorResponse(response, 400, "缺少新闻ID");
                return;
            }
            boolean success = homeNewsDao.deleteNews(Long.parseLong(id));
            response.getWriter().write(JSON.toJSONString(buildResult(success, "新闻删除成功", "新闻删除失败")));

        } catch (Exception e) {
            System.err.println("[HomeNewsServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    private <T> T parseRequestBody(HttpServletRequest request, Class<T> clazz) throws IOException {
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            sb.append(line);
        }
        return JSON.parseObject(sb.toString(), clazz);
    }

    private Map<String, Object> buildResult(boolean success, String successMsg, String failMsg) {
        Map<String, Object> result = new HashMap<>();
        result.put("success", success);
        result.put("message", success ? successMsg : failMsg);
        return result;
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
