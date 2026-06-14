/**
 * ===========================================================================
 * MajorServlet —— Servlet 控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet, @param, @param, @throws, @throws, @param, @param, @throws, @throws, @param, @param, @throws, @throws, @param, @param, @throws, @throws, @param, @param, @param, @return, @throws, @param, @param, @param, @throws
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
 * sendErrorResponse(HttpServletResponse response, int statusCode, String message)内部工具方法
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   majorDao = new MajorDao()
 *   id = request.getParameter("id")
 *   category = request.getParameter("category")
 *   major = majorDao.getMajorById(Integer.parseInt(id))
 *   majorList = majorDao.getMajorsByCategory(category)
 *   majorList = majorDao.getAllActiveMajors()
 *   major = parseRequestBody(request, Major.class)
 *   success = majorDao.addMajor(major)
 *   result = new HashMap<>()
 *   major = parseRequestBody(request, Major.class)
 *   success = majorDao.updateMajor(major)
 *   result = new HashMap<>()
 *   id = request.getParameter("id")
 *   success = majorDao.deleteMajor(Integer.parseInt(id))
 *   result = new HashMap<>()
 *   sb = new StringBuilder()
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
import com.ebookBuy301.dao.MajorDao;
import com.ebookBuy301.pojo.Major;

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
 * MajorServlet —— 学域（专业）管理 RESTful API
 * =============================================================================
 *
 * 提供学域/专业的增删改查 RESTful API，返回 JSON 格式数据。
 *
 * 访问路径：/majors
 *
 * GET 请求：
 *   - /majors?id=1           → 获取单个学域
 *   - /majors?category=工科   → 按分类获取学域列表
 *   - /majors（无参数）       → 获取所有活跃学域
 *
 * POST 请求：添加新学域（请求体 JSON）
 * PUT 请求：更新学域（请求体 JSON）
 * DELETE 请求：/majors?id=1  → 删除学域
 * =============================================================================
 */
@WebServlet("/majors")
public class MajorServlet extends HttpServlet {

    /** 学域数据访问层 */
    private MajorDao majorDao = new MajorDao();

    // ======================== GET 请求处理 ========================

    /**
     * 处理 GET 请求 —— 查询学域（单个/按分类/全部）
     *
     * @param request  HTTP 请求对象
     * @param response HTTP 响应对象（JSON）
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        String id = request.getParameter("id");
        String category = request.getParameter("category");

        try {
            if (id != null) {
                // 查询单个学域
                Major major = majorDao.getMajorById(Integer.parseInt(id));
                if (major != null) {
                    response.getWriter().write(JSON.toJSONString(major));
                } else {
                    sendErrorResponse(response, 404, "专业不存在");
                }

            } else if (category != null) {
                // 按分类查询
                ArrayList<Major> majorList = majorDao.getMajorsByCategory(category);
                response.getWriter().write(JSON.toJSONString(majorList));

            } else {
                // 查询全部
                ArrayList<Major> majorList = majorDao.getAllActiveMajors();
                response.getWriter().write(JSON.toJSONString(majorList));
            }

        } catch (Exception e) {
            System.err.println("[MajorServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    // ======================== POST 请求处理 ========================

    /**
     * 处理 POST 请求 —— 添加新学域
     *
     * @param request  HTTP 请求对象（JSON 请求体）
     * @param response HTTP 响应对象（JSON）
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        try {
            // 读取 JSON 请求体
            Major major = parseRequestBody(request, Major.class);
            boolean success = majorDao.addMajor(major);

            Map<String, Object> result = new HashMap<>();
            if (success) {
                result.put("success", true);
                result.put("message", "专业添加成功");
                response.setStatus(HttpServletResponse.SC_CREATED);
            } else {
                result.put("success", false);
                result.put("message", "专业添加失败");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }

            response.getWriter().write(JSON.toJSONString(result));

        } catch (Exception e) {
            System.err.println("[MajorServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    // ======================== PUT 请求处理 ========================

    /**
     * 处理 PUT 请求 —— 更新学域信息
     *
     * @param request  HTTP 请求对象（JSON 请求体）
     * @param response HTTP 响应对象（JSON）
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        try {
            Major major = parseRequestBody(request, Major.class);
            boolean success = majorDao.updateMajor(major);

            Map<String, Object> result = new HashMap<>();
            if (success) {
                result.put("success", true);
                result.put("message", "专业更新成功");
            } else {
                result.put("success", false);
                result.put("message", "专业更新失败");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }

            response.getWriter().write(JSON.toJSONString(result));

        } catch (Exception e) {
            System.err.println("[MajorServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    // ======================== DELETE 请求处理 ========================

    /**
     * 处理 DELETE 请求 —— 删除学域
     *
     * @param request  HTTP 请求对象（需含 id 参数）
     * @param response HTTP 响应对象（JSON）
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        String id = request.getParameter("id");

        try {
            if (id == null) {
                sendErrorResponse(response, 400, "缺少专业ID");
                return;
            }

            boolean success = majorDao.deleteMajor(Integer.parseInt(id));

            Map<String, Object> result = new HashMap<>();
            if (success) {
                result.put("success", true);
                result.put("message", "专业删除成功");
            } else {
                result.put("success", false);
                result.put("message", "专业删除失败");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }

            response.getWriter().write(JSON.toJSONString(result));

        } catch (Exception e) {
            System.err.println("[MajorServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
    }

    // ======================== 通用私有方法 ========================

    /**
     * 从请求体中读取 JSON 并解析为指定类型
     *
     * @param request HTTP 请求对象
     * @param clazz   目标类型
     * @param <T>     泛型类型
     * @return 解析后的对象
     * @throws IOException 读取请求体异常
     */
    private <T> T parseRequestBody(HttpServletRequest request, Class<T> clazz) throws IOException {
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            sb.append(line);
        }
        return JSON.parseObject(sb.toString(), clazz);
    }

    /**
     * 发送 JSON 格式的错误响应
     *
     * @param response   HTTP 响应对象
     * @param statusCode HTTP 状态码
     * @param message    错误消息
     * @throws IOException 写入响应异常
     */
    private void sendErrorResponse(HttpServletResponse response, int statusCode, String message)
            throws IOException {
        response.setStatus(statusCode);
        Map<String, Object> error = new HashMap<>();
        error.put("success", false);
        error.put("error", message);
        response.getWriter().write(JSON.toJSONString(error));
    }
}
