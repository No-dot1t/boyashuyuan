package com.ebookBuy301;

import com.ebookBuy301.dao.MajorDao;
import com.ebookBuy301.pojo.Major;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

/**
 * ===========================================================================
 * MajorMatrixServlet —— 学域矩阵 JSON 数据 API
 * ===========================================================================
 *
 * 映射路径        /majorMatrix
 * 底层技术        Java EE Servlet
 * 数据访问        MajorDao（JDBC + PreparedStatement）
 * 最后更新        2026-06-13
 *
 * ── 路由表 ─────────────────────────────────────────────────────────────────
 *
 * 【GET】
 *   无 action          → 查询所有活跃学域，forward 到 majorMatrix.jsp
 *
 * ── 使用的关键方法与算法 ────────────────────────────────────────────────────
 *
 * 方法 / 技术                  用途
 * ─────────────────────────────────────────────────────────────────
 * MajorDao.getAllActiveMajors()    查询所有活跃学域（返回5个学域）
 * HttpServletRequest                  获取请求参数/Session
 * RequestDispatcher.forward()       JSP 页面转发
 * ===========================================================================
 */
@WebServlet("/majorMatrix")
public class MajorMatrixServlet extends HttpServlet {

    private final MajorDao majorDao = new MajorDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            ArrayList<Major> majors = majorDao.getAllActiveMajors();
            request.setAttribute("majors", majors);
        } catch (Exception e) {
            System.err.println("[MajorMatrixServlet] 查询学域失败：" + e.getMessage());
            request.setAttribute("error", "学域数据加载失败");
        }
        request.getRequestDispatcher("/pages/majorMatrix.jsp").forward(request, response);
    }
}
