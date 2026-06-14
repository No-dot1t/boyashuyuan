package com.ebookBuy301;

import com.ebookBuy301.dao.CampusSceneDao;
import com.ebookBuy301.pojo.CampusScene;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

/**
 * ===========================================================================
 * CampusTourServlet —— 校园导览页面渲染
 * ===========================================================================
 *
 * 映射路径        /campusTour
 * 底层技术        Java EE Servlet
 * 数据访问        CampusSceneDao（JDBC + PreparedStatement）
 * 最后更新        2026-06-13
 *
 * ── 路由表 ─────────────────────────────────────────────────────────────────
 *
 * 【GET】
 *   无 action          → 查询所有校园场景，forward 到 campusTour.jsp
 *
 * ── 使用的关键方法与算法 ────────────────────────────────────────────────────
 *
 * 方法 / 技术                  用途
 * ─────────────────────────────────────────────────────────────────
 * CampusSceneDao.getAllActiveScenes()  查询所有活跃校园场景
 * HttpServletRequest                       获取请求参数/Session
 * RequestDispatcher.forward()            JSP 页面转发
 * ===========================================================================
 */
@WebServlet("/campusTour")
public class CampusTourServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        try {
            CampusSceneDao dao = new CampusSceneDao();
            ArrayList<CampusScene> scenes = dao.getAllActiveScenes();
            req.setAttribute("scenes", scenes);
        } catch (Exception e) {
            req.setAttribute("scenes", new ArrayList<CampusScene>());
        }
        req.getRequestDispatcher("/pages/campusTour.jsp").forward(req, res);
    }
}
