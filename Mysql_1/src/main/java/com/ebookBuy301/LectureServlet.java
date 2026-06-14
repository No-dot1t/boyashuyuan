/**
 * ===========================================================================
 * LectureServlet —— Servlet 控制器
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
 *   lectureDao = new LectureDao()
 *   action = request.getParameter("action")
 *   id = request.getParameter("id")
 *   lectureList = lectureDao.getUpcomingLectures()
 *   lecture = lectureDao.getLectureById(Integer.parseInt(id))
 *   lectureList = lectureDao.getAllActiveLectures()
 *   lecture = parseRequestBody(request, Lecture.class)
 *   success = lectureDao.addLecture(lecture)
 *   result = buildResult(success, "讲座添加成功", "讲座添加失败")
 *   lecture = parseRequestBody(request, Lecture.class)
 *   success = lectureDao.updateLecture(lecture)
 *   id = request.getParameter("id")
 *   success = lectureDao.deleteLecture(Integer.parseInt(id))
 *   sb = new StringBuilder()
 *   result = new HashMap<>()
 *   error = new HashMap<>()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   @WebServlet —— 注解式 Servlet 路由映射
 *   Servlet API —— HttpServlet / HttpServletRequest / HttpServletResponse
 *   doGet() —— GET 请求分发
 *   doPost() —— POST 请求分发
 *   action 参数分发模式 —— 通过 request.getParameter("action") 分流操作
 *
 * ===========================================================================
 */

package com.ebookBuy301;

import com.alibaba.fastjson.JSON;
import com.ebookBuy301.dao.LectureDao;
import com.ebookBuy301.pojo.Lecture;

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
 * LectureServlet —— 讲座管理 RESTful API
 * =============================================================================
 *
 * 提供讲座/大师课信息的增删改查 RESTful API。
 *
 * 访问路径：/lectures
 *
 * GET 请求：
 *   - /lectures?action=upcoming  → 获取即将开始的讲座
 *   - /lectures?id=1             → 获取单个讲座
 *   - /lectures（无参数）         → 获取所有活跃讲座
 *
 * POST 请求：添加讲座（JSON 请求体）
 * PUT 请求：更新讲座（JSON 请求体）
 * DELETE 请求：/lectures?id=1 → 删除讲座
 * =============================================================================
 */
@WebServlet("/lectures")
public class LectureServlet extends HttpServlet {

    private LectureDao lectureDao = new LectureDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        String action = request.getParameter("action");
        String id = request.getParameter("id");

        try {
            if ("upcoming".equals(action)) {
                ArrayList<Lecture> lectureList = lectureDao.getUpcomingLectures();
                response.getWriter().write(JSON.toJSONString(lectureList));

            } else if (id != null) {
                Lecture lecture = lectureDao.getLectureById(Integer.parseInt(id));
                if (lecture != null) {
                    response.getWriter().write(JSON.toJSONString(lecture));
                } else {
                    sendErrorResponse(response, 404, "讲座不存在");
                }

            } else {
                ArrayList<Lecture> lectureList = lectureDao.getAllActiveLectures();
                response.getWriter().write(JSON.toJSONString(lectureList));
            }

        } catch (Exception e) {
            System.err.println("[LectureServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        try {
            Lecture lecture = parseRequestBody(request, Lecture.class);
            boolean success = lectureDao.addLecture(lecture);
            Map<String, Object> result = buildResult(success, "讲座添加成功", "讲座添加失败");
            if (success) response.setStatus(HttpServletResponse.SC_CREATED);
            response.getWriter().write(JSON.toJSONString(result));
        } catch (Exception e) {
            System.err.println("[LectureServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        try {
            Lecture lecture = parseRequestBody(request, Lecture.class);
            boolean success = lectureDao.updateLecture(lecture);
            response.getWriter().write(JSON.toJSONString(buildResult(success, "讲座更新成功", "讲座更新失败")));
        } catch (Exception e) {
            System.err.println("[LectureServlet] 错误：" + e.getMessage());
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
                sendErrorResponse(response, 400, "缺少讲座ID");
                return;
            }
            boolean success = lectureDao.deleteLecture(Integer.parseInt(id));
            response.getWriter().write(JSON.toJSONString(buildResult(success, "讲座删除成功", "讲座删除失败")));
        } catch (Exception e) {
            System.err.println("[LectureServlet] 错误：" + e.getMessage());
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
