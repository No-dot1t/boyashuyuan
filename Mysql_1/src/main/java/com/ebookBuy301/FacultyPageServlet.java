package com.ebookBuy301;

import com.ebookBuy301.dao.FacultyDao;
import com.ebookBuy301.pojo.Faculty;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

/**
 * ===========================================================================
 * FacultyPageServlet —— 师资页面渲染
 * ===========================================================================
 *
 * 映射路径        /facultyPage
 * 底层技术        Java EE Servlet
 * 数据访问        FacultyDao（JDBC + PreparedStatement）
 * 最后更新        2026-06-13
 *
 * ── 路由表 ─────────────────────────────────────────────────────────────────
 *
 * 【GET】
 *   无 action          → 查询所有活跃导师，forward 到 faculty.jsp
 *
 * ── 使用的关键方法与算法 ────────────────────────────────────────────────────
 *
 * 方法 / 技术                  用途
 * ─────────────────────────────────────────────────────────────────
 * FacultyDao.getAllActiveFaculty()   查询所有活跃导师
 * HttpServletRequest                   获取请求参数/Session
 * RequestDispatcher.forward()         JSP 页面转发
 * ===========================================================================
 */
@WebServlet("/facultyPage")
public class FacultyPageServlet extends HttpServlet {

    private FacultyDao facultyDao = new FacultyDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try {
            ArrayList<Faculty> facultyList = facultyDao.getAllActiveFaculty();
            req.setAttribute("facultyList", facultyList);
        } catch (Exception e) {
            System.err.println("[FacultyPageServlet] 错误：" + e.getMessage());
            req.setAttribute("facultyList", new ArrayList<>());
        }
        req.getRequestDispatcher("/pages/faculty.jsp").forward(req, res);
    }
}
