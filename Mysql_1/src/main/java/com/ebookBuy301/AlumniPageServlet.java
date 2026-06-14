package com.ebookBuy301;

import com.ebookBuy301.dao.AlumniDao;
import com.ebookBuy301.pojo.Alumni;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

/**
 * ===========================================================================
 * AlumniPageServlet —— 校友风采页面渲染
 * ===========================================================================
 *
 * 映射路径        /alumniPage
 * 底层技术        Java EE Servlet
 * 数据访问        AlumniDao（JDBC + PreparedStatement）
 * 最后更新        2026-06-13
 *
 * ── 路由表 ─────────────────────────────────────────────────────────────────
 *
 * 【GET】
 *   无 action          → 查询所有活跃校友 + 荣誉校友，forward 到 alumni.jsp
 *
 * ── 使用的关键方法与算法 ────────────────────────────────────────────────────
 *
 * 方法 / 技术                  用途
 * ─────────────────────────────────────────────────────────────────
 * AlumniDao.getAllActiveAlumni()   查询所有活跃校友
 * AlumniDao.getHonoraryAlumni()   查询荣誉校友
 * HttpServletRequest                获取请求参数/Session
 * RequestDispatcher.forward()       JSP 页面转发
 * ===========================================================================
 */
@WebServlet("/alumniPage")
public class AlumniPageServlet extends HttpServlet {

    private AlumniDao alumniDao = new AlumniDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try {
            ArrayList<Alumni> alumniList = alumniDao.getAllActiveAlumni();
            ArrayList<Alumni> honoraryList = alumniDao.getHonoraryAlumni();
            req.setAttribute("alumniList", alumniList);
            req.setAttribute("honoraryList", honoraryList);
        } catch (Exception e) {
            System.err.println("[AlumniPageServlet] 错误：" + e.getMessage());
            req.setAttribute("alumniList", new ArrayList<>());
            req.setAttribute("honoraryList", new ArrayList<>());
        }
        req.getRequestDispatcher("/pages/alumni.jsp").forward(req, res);
    }
}
