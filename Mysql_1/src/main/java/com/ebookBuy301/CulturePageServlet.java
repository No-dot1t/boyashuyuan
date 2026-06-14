package com.ebookBuy301;

import com.ebookBuy301.dao.CultureNotificationDao;
import com.ebookBuy301.pojo.CultureEvent;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

/**
 * ===========================================================================
 * CulturePageServlet —— 校园文化页面渲染
 * ===========================================================================
 *
 * 映射路径        /culturePage
 * 底层技术        Java EE Servlet
 * 数据访问        CultureNotificationDao（JDBC + PreparedStatement）
 * 最后更新        2026-06-13
 *
 * ── 路由表 ─────────────────────────────────────────────────────────────────
 *
 * 【GET】
 *   无 action          → 查询所有文化活动，forward 到 culture.jsp
 *
 * ── 使用的关键方法与算法 ────────────────────────────────────────────────────
 *
 * 方法 / 技术                  用途
 * ─────────────────────────────────────────────────────────────────
 * CultureNotificationDao.getAllCultureEvents()  查询所有文化活动
 * HttpServletRequest                       获取请求参数/Session
 * RequestDispatcher.forward()            JSP 页面转发
 * ===========================================================================
 */
@WebServlet("/culturePage")
public class CulturePageServlet extends HttpServlet {

    private CultureNotificationDao dao = new CultureNotificationDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try {
            ArrayList<CultureEvent> events = dao.getAllCultureEvents();
            req.setAttribute("cultureEvents", events);
        } catch (Exception e) {
            System.err.println("[CulturePageServlet] 错误：" + e.getMessage());
            req.setAttribute("cultureEvents", new ArrayList<>());
        }
        req.getRequestDispatcher("/pages/culture.jsp").forward(req, res);
    }
}
