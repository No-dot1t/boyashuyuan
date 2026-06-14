/**
 * ===========================================================================
 * CourseServlet —— Servlet 控制器
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
 *   courseDao = new CourseDao()
 *   action = request.getParameter("action")
 *   id = request.getParameter("id")
 *   category = request.getParameter("category")
 *   level = request.getParameter("level")
 *   keyword = request.getParameter("keyword")
 *   courses = courseDao.searchCourses(keyword)
 *   course = courseDao.getCourseById(Long.parseLong(id))
 *   courses = courseDao.getCoursesByCategory(category)
 *   courses = courseDao.getCoursesByLevel(level)
 *   courses = courseDao.getAllCourses()
 *   course = parseRequestBody(request, Course.class)
 *   success = courseDao.addCourse(course)
 *   result = buildResult(success, "课程添加成功", "课程添加失败")
 *   course = parseRequestBody(request, Course.class)
 *   success = courseDao.updateCourse(course)
 *   id = request.getParameter("id")
 *   success = courseDao.deleteCourse(Long.parseLong(id))
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
import com.ebookBuy301.dao.CourseDao;
import com.ebookBuy301.pojo.Course;

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
 * CourseServlet —— 课程管理 RESTful API
 * =============================================================================
 *
 * 提供课程的增删改查 RESTful API。
 *
 * 访问路径：/courses
 *
 * GET 请求：
 *   - /courses?action=search&keyword=xxx  → 搜索课程
 *   - /courses?id=1                        → 获取单个课程
 *   - /courses?category=编程                → 按分类查询
 *   - /courses?level=初级                   → 按难度查询
 *   - /courses（无参数）                    → 获取所有课程
 *
 * POST 请求：添加课程（JSON 请求体）
 * PUT 请求：更新课程（JSON 请求体）
 * DELETE 请求：/courses?id=1 → 删除课程
 * =============================================================================
 */
@WebServlet("/courses")
public class CourseServlet extends HttpServlet {

    private CourseDao courseDao = new CourseDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        String action = request.getParameter("action");
        String id = request.getParameter("id");
        String category = request.getParameter("category");
        String level = request.getParameter("level");
        String keyword = request.getParameter("keyword");

        try {
            if ("search".equals(action) && keyword != null) {
                ArrayList<Course> courses = courseDao.searchCourses(keyword);
                response.getWriter().write(JSON.toJSONString(courses));

            } else if (id != null) {
                Course course = courseDao.getCourseById(Long.parseLong(id));
                if (course != null) {
                    response.getWriter().write(JSON.toJSONString(course));
                } else {
                    sendErrorResponse(response, 404, "课程不存在");
                }

            } else if (category != null) {
                ArrayList<Course> courses = courseDao.getCoursesByCategory(category);
                response.getWriter().write(JSON.toJSONString(courses));

            } else if (level != null) {
                ArrayList<Course> courses = courseDao.getCoursesByLevel(level);
                response.getWriter().write(JSON.toJSONString(courses));

            } else {
                ArrayList<Course> courses = courseDao.getAllCourses();
                response.getWriter().write(JSON.toJSONString(courses));
            }

        } catch (Exception e) {
            System.err.println("[CourseServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        try {
            Course course = parseRequestBody(request, Course.class);
            boolean success = courseDao.addCourse(course);

            Map<String, Object> result = buildResult(success, "课程添加成功", "课程添加失败");
            if (success) response.setStatus(HttpServletResponse.SC_CREATED);
            response.getWriter().write(JSON.toJSONString(result));

        } catch (Exception e) {
            System.err.println("[CourseServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        try {
            Course course = parseRequestBody(request, Course.class);
            boolean success = courseDao.updateCourse(course);
            response.getWriter().write(JSON.toJSONString(buildResult(success, "课程更新成功", "课程更新失败")));

        } catch (Exception e) {
            System.err.println("[CourseServlet] 错误：" + e.getMessage());
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
                sendErrorResponse(response, 400, "缺少课程ID");
                return;
            }
            boolean success = courseDao.deleteCourse(Long.parseLong(id));
            response.getWriter().write(JSON.toJSONString(buildResult(success, "课程删除成功", "课程删除失败")));

        } catch (Exception e) {
            System.err.println("[CourseServlet] 错误：" + e.getMessage());
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
