package com.ebookBuy301;

import com.ebookBuy301.dao.LectureDao;
import com.ebookBuy301.pojo.Lecture;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

/**
 * ===========================================================================
 * LecturePageServlet —— 讲座页面渲染
 * ===========================================================================
 *
 * 映射路径        /lecturePage
 * 底层技术        Java EE Servlet
 * 数据访问        LectureDao（JDBC + PreparedStatement）
 * 最后更新        2026-06-13
 *
 * ── 路由表 ─────────────────────────────────────────────────────────────────
 *
 * 【GET】
 *   无 action          → 查询所有活跃讲座 + 即将开始的讲座，forward 到 lecture.jsp
 *
 * ── 使用的关键方法与算法 ────────────────────────────────────────────────────
 *
 * 方法 / 技术                  用途
 * ─────────────────────────────────────────────────────────────────
 * LectureDao.getAllActiveLectures()   查询所有活跃讲座
 * LectureDao.getUpcomingLectures()   查询即将开始的讲座
 * HttpServletRequest                     获取请求参数/Session
 * RequestDispatcher.forward()         JSP 页面转发
 * ===========================================================================
 */
@WebServlet("/lecturePage")
public class LecturePageServlet extends HttpServlet {

    private LectureDao lectureDao = new LectureDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try {
            ArrayList<Lecture> lectures = lectureDao.getAllActiveLectures();
            ArrayList<Lecture> upcoming = lectureDao.getUpcomingLectures();
            req.setAttribute("lectures", lectures);
            req.setAttribute("upcoming", upcoming);
        } catch (Exception e) {
            System.err.println("[LecturePageServlet] 错误：" + e.getMessage());
            req.setAttribute("lectures", new ArrayList<>());
            req.setAttribute("upcoming", new ArrayList<>());
        }
        req.getRequestDispatcher("/pages/lecture.jsp").forward(req, res);
    }
}
