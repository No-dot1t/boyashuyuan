/**
 * ===========================================================================
 * AlumniServlet —— Servlet 控制器
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
 *   alumniDao = new AlumniDao()
 *   action = request.getParameter("action")
 *   id = request.getParameter("id")
 *   alumniList = alumniDao.getHonoraryAlumni()
 *   alumni = alumniDao.getAlumniById(Integer.parseInt(id))
 *   alumniList = alumniDao.getAllActiveAlumni()
 *   alumni = parseRequestBody(request, Alumni.class)
 *   success = alumniDao.addAlumni(alumni)
 *   result = buildResult(success, "校友添加成功", "校友添加失败")
 *   alumni = parseRequestBody(request, Alumni.class)
 *   success = alumniDao.updateAlumni(alumni)
 *   result = buildResult(success, "校友更新成功", "校友更新失败")
 *   id = request.getParameter("id")
 *   success = alumniDao.deleteAlumni(Integer.parseInt(id))
 *   result = buildResult(success, "校友删除成功", "校友删除失败")
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
import com.ebookBuy301.dao.AlumniDao;
import com.ebookBuy301.pojo.Alumni;

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
 * AlumniServlet —— 校友管理 RESTful API
 * =============================================================================
 *
 * 提供知名校友信息的增删改查 RESTful API。
 *
 * 访问路径：/api/alumni
 *
 * GET 请求：
 *   - /api/alumni?action=honorary  → 获取荣誉校友列表
 *   - /api/alumni?id=1             → 获取单个校友
 *   - /api/alumni（无参数）         → 获取所有活跃校友
 *
 * POST 请求：添加校友（JSON 请求体）
 * PUT 请求：更新校友（JSON 请求体）
 * DELETE 请求：/api/alumni?id=1  → 删除校友
 * =============================================================================
 */
@WebServlet("/api/alumni")
public class AlumniServlet extends HttpServlet {

    private AlumniDao alumniDao = new AlumniDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        String action = request.getParameter("action");
        String id = request.getParameter("id");

        try {
            if ("honorary".equals(action)) {
                ArrayList<Alumni> alumniList = alumniDao.getHonoraryAlumni();
                response.getWriter().write(JSON.toJSONString(alumniList));
            } else if (id != null) {
                Alumni alumni = alumniDao.getAlumniById(Integer.parseInt(id));
                if (alumni != null) {
                    response.getWriter().write(JSON.toJSONString(alumni));
                } else {
                    sendErrorResponse(response, 404, "校友不存在");
                }
            } else {
                ArrayList<Alumni> alumniList = alumniDao.getAllActiveAlumni();
                response.getWriter().write(JSON.toJSONString(alumniList));
            }
        } catch (Exception e) {
            System.err.println("[AlumniServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        try {
            Alumni alumni = parseRequestBody(request, Alumni.class);
            boolean success = alumniDao.addAlumni(alumni);

            Map<String, Object> result = buildResult(success, "校友添加成功", "校友添加失败");
            if (success) response.setStatus(HttpServletResponse.SC_CREATED);
            response.getWriter().write(JSON.toJSONString(result));
        } catch (Exception e) {
            System.err.println("[AlumniServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        try {
            Alumni alumni = parseRequestBody(request, Alumni.class);
            boolean success = alumniDao.updateAlumni(alumni);
            Map<String, Object> result = buildResult(success, "校友更新成功", "校友更新失败");
            response.getWriter().write(JSON.toJSONString(result));
        } catch (Exception e) {
            System.err.println("[AlumniServlet] 错误：" + e.getMessage());
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
                sendErrorResponse(response, 400, "缺少校友ID");
                return;
            }
            boolean success = alumniDao.deleteAlumni(Integer.parseInt(id));
            Map<String, Object> result = buildResult(success, "校友删除成功", "校友删除失败");
            response.getWriter().write(JSON.toJSONString(result));
        } catch (Exception e) {
            System.err.println("[AlumniServlet] 错误：" + e.getMessage());
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
