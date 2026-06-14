/**
 * ===========================================================================
 * HomeServlet —— Servlet 控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.servlet
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
 *   homeNewsDao = new HomeNewsDao()
 *   newsList = homeNewsDao.getAllPublishedNews()
 *   topNews = null
 *   otherNews = new ArrayList<>()
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

package com.ebookBuy301.servlet;

import com.ebookBuy301.dao.HomeNewsDao;
import com.ebookBuy301.pojo.HomeNews;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

/**
 * =============================================================================
 * HomeServlet —— 智识首页控制器
 * =============================================================================
 *
 * 处理首页请求，加载新闻数据并转发到 JSP 页面。
 *
 * 访问路径：/home
 *
 * 流程：
 *   1. 获取所有已发布新闻
 *   2. 取第一条置顶新闻作为头条（若无置顶则取最新）
 *   3. 取剩余最多 4 条作为其他新闻列表
 *   4. 转发到 /pages/home.jsp
 * =============================================================================
 */
@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    private HomeNewsDao homeNewsDao = new HomeNewsDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // ===== 1. 获取所有已发布新闻 =====
            ArrayList<HomeNews> newsList = homeNewsDao.getAllPublishedNews();

            // ===== 2. 获取置顶/最新新闻（头条） =====
            HomeNews topNews = null;
            for (HomeNews news : newsList) {
                if (news.isTop()) {
                    topNews = news;
                    break;
                }
            }
            if (topNews == null && newsList.size() > 0) {
                topNews = newsList.get(0);
            }

            // ===== 3. 获取其他新闻（最多4条，排除头条） =====
            ArrayList<HomeNews> otherNews = new ArrayList<>();
            if (topNews != null) {
                for (HomeNews news : newsList) {
                    if (news.getId() != topNews.getId() && otherNews.size() < 4) {
                        otherNews.add(news);
                    }
                }
            }

            // ===== 4. 转发到 JSP =====
            request.setAttribute("topNews", topNews);
            request.setAttribute("otherNews", otherNews);
            request.setAttribute("newsCount", newsList.size());
            request.getRequestDispatcher("/pages/home.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("[HomeServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            // 异常时返回空数据，不抛 500 错误
            request.setAttribute("topNews", null);
            request.setAttribute("otherNews", new ArrayList<HomeNews>());
            request.setAttribute("newsCount", 0);
            request.getRequestDispatcher("/pages/home.jsp").forward(request, response);
        }
    }
}
