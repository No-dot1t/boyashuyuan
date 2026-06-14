/**
 * ===========================================================================
 * FacultyServlet —— Servlet 控制器
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
 *   facultyDao = new FacultyDao()
 *   id = request.getParameter("id")
 *   department = request.getParameter("department")
 *   faculty = facultyDao.getFacultyById(Integer.parseInt(id))
 *   facultyList = facultyDao.getFacultyByDepartment(department)
 *   facultyList = facultyDao.getAllActiveFaculty()
 *   faculty = parseRequestBody(request, Faculty.class)
 *   success = facultyDao.addFaculty(faculty)
 *   result = buildResult(success, "导师添加成功", "导师添加失败")
 *   faculty = parseRequestBody(request, Faculty.class)
 *   success = facultyDao.updateFaculty(faculty)
 *   id = request.getParameter("id")
 *   success = facultyDao.deleteFaculty(Integer.parseInt(id))
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
import com.ebookBuy301.dao.FacultyDao;
import com.ebookBuy301.pojo.Faculty;

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
 * FacultyServlet —— 导师（师资）管理 RESTful API
 * =============================================================================
 *
 * 提供导师信息的增删改查 RESTful API。
 *
 * 访问路径：/api/faculty
 *
 * GET 请求：
 *   - /api/faculty?id=1             → 获取单个导师
 *   - /api/faculty?department=计算机  → 按系别查询
 *   - /api/faculty（无参数）         → 获取所有活跃导师
 *
 * POST 请求：添加导师（JSON 请求体）
 * PUT 请求：更新导师（JSON 请求体）
 * DELETE 请求：/api/faculty?id=1 → 删除导师
 * =============================================================================
 */
@WebServlet("/api/faculty")
public class FacultyServlet extends HttpServlet {

    private FacultyDao facultyDao = new FacultyDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        String id = request.getParameter("id");
        String department = request.getParameter("department");

        try {
            if (id != null) {
                Faculty faculty = facultyDao.getFacultyById(Integer.parseInt(id));
                if (faculty != null) {
                    response.getWriter().write(JSON.toJSONString(faculty));
                } else {
                    sendErrorResponse(response, 404, "导师不存在");
                }
            } else if (department != null) {
                ArrayList<Faculty> facultyList = facultyDao.getFacultyByDepartment(department);
                response.getWriter().write(JSON.toJSONString(facultyList));
            } else {
                ArrayList<Faculty> facultyList = facultyDao.getAllActiveFaculty();
                response.getWriter().write(JSON.toJSONString(facultyList));
            }
        } catch (Exception e) {
            System.err.println("[FacultyServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        try {
            Faculty faculty = parseRequestBody(request, Faculty.class);
            boolean success = facultyDao.addFaculty(faculty);
            Map<String, Object> result = buildResult(success, "导师添加成功", "导师添加失败");
            if (success) response.setStatus(HttpServletResponse.SC_CREATED);
            response.getWriter().write(JSON.toJSONString(result));
        } catch (Exception e) {
            System.err.println("[FacultyServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        try {
            Faculty faculty = parseRequestBody(request, Faculty.class);
            boolean success = facultyDao.updateFaculty(faculty);
            response.getWriter().write(JSON.toJSONString(buildResult(success, "导师更新成功", "导师更新失败")));
        } catch (Exception e) {
            System.err.println("[FacultyServlet] 错误：" + e.getMessage());
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
                sendErrorResponse(response, 400, "缺少导师ID");
                return;
            }
            boolean success = facultyDao.deleteFaculty(Integer.parseInt(id));
            response.getWriter().write(JSON.toJSONString(buildResult(success, "导师删除成功", "导师删除失败")));
        } catch (Exception e) {
            System.err.println("[FacultyServlet] 错误：" + e.getMessage());
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
