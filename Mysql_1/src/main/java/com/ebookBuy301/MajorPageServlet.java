package com.ebookBuy301;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * ===========================================================================
 * MajorPageServlet —— 学域页面 + 用户专属路由
 * ===========================================================================
 *
 * 映射路径        /majorsPage
 * 底层技术        Java EE Servlet
 * 数据访问        无（数据由前端 fetch API 加载）
 * 最后更新        2026-06-13
 *
 * ── 路由表 ─────────────────────────────────────────────────────────────────
 *
 * 【GET】
 *   无 action          → 转发到 majors.jsp（我的书架页面）
 *   filter=my         → 用户专属学域筛选
 *   filter=register   → 用户已注册学域筛选
 *
 * ── 使用的关键方法与算法 ────────────────────────────────────────────────────
 *
 * 方法 / 技术                  用途
 * ─────────────────────────────────────────────────────────────────
 * HttpServletRequest             获取请求参数/Session
 * RequestDispatcher.forward()   JSP 页面转发
 * ===========================================================================
 */
@WebServlet("/majorsPage")
public class MajorPageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 数据由 majors.jsp 前端通过 fetch /api/bookAction 加载，无需后端查询
        request.getRequestDispatcher("/pages/majors.jsp").forward(request, response);
    }
}
