/**
 * ===========================================================================
 * StatsServlet —— Servlet 控制器
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
 * sendErrorResponse(HttpServletResponse response, int statusCode, String message)内部工具方法
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   statsDao = new StatsDao()
 *   activityDao = new UserActivityDao()
 *   module = request.getParameter("module")
 *   stats = statsDao.getStudyRoomStats()
 *   stats = statsDao.getCampus3dStats()
 *   stats = statsDao.getDashboardStats()
 *   rt = Runtime.getRuntime()
 *   stats = statsDao.getAccessStats()
 *   result = new HashMap<>()
 *   error = new HashMap<>()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   @WebServlet —— 注解式 Servlet 路由映射
 *   Servlet API —— HttpServlet / HttpServletRequest / HttpServletResponse
 *   doGet() —— GET 请求分发
 *   action 参数分发模式 —— 通过 request.getParameter("action") 分流操作
 *
 * ===========================================================================
 */

package com.ebookBuy301;

import com.alibaba.fastjson.JSON;
import com.ebookBuy301.dao.StatsDao;
import com.ebookBuy301.dao.UserActivityDao;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * =============================================================================
 * StatsServlet —— 统计数据 API
 * =============================================================================
 *
 * 提供各模块统计数据的 JSON 查询接口。
 *
 * 访问路径：/stats
 *
 * 请求参数 module：
 * - studyroom → 自习室统计
 * - campus3d → 校园 3D 统计
 * - dashboard → 管理驾驶舱统计
 * - access → 访问统计
 * - 无参数 → 返回所有统计数据
 * =============================================================================
 */
@WebServlet("/stats")
public class StatsServlet extends HttpServlet {

    private StatsDao statsDao = new StatsDao();
    private UserActivityDao activityDao = new UserActivityDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        String module = request.getParameter("module");

        try {
            if ("campus3d".equals(module)) {
                Map<String, Object> stats = statsDao.getCampus3dStats();
                response.getWriter().write(JSON.toJSONString(stats));

            } else if ("dashboard".equals(module)) {
                Map<String, Object> stats = statsDao.getDashboardStats();
                // 根据 period 参数动态获取趋势数据
                String period = request.getParameter("period");
                int days = 7; // 默认本周
                if ("month".equals(period)) {
                    days = 30;
                } else if ("quarter".equals(period)) {
                    days = 90;
                } else if ("year".equals(period)) {
                    days = 365;
                }
                stats.put("accessTrend", activityDao.getAccessStatsByDay(days));
                stats.put("hourlyActivity", activityDao.getActivityDistributionByHour());
                stats.put("trafficSources", activityDao.getTrafficSourceStats());
                stats.put("contentStats", activityDao.getContentStats());
                // JVM运行时信息
                Runtime rt = Runtime.getRuntime();
                stats.put("jvmCpuUsage", Math.round((rt.totalMemory() - rt.freeMemory()) * 100.0 / rt.maxMemory()));
                stats.put("jvmMemUsed", Math.round((rt.totalMemory() - rt.freeMemory()) / 1024 / 1024));
                stats.put("jvmMemMax", Math.round(rt.maxMemory() / 1024 / 1024));
                stats.put("jvmMemPercent", Math.round((rt.totalMemory() - rt.freeMemory()) * 100.0 / rt.maxMemory()));
                response.getWriter().write(JSON.toJSONString(stats));

            } else if ("access".equals(module)) {
                Map<String, Object> stats = statsDao.getAccessStats();
                response.getWriter().write(JSON.toJSONString(stats));

            } else {
                Map<String, Object> result = new HashMap<>();
                result.put("campus3d", statsDao.getCampus3dStats());
                result.put("dashboard", statsDao.getDashboardStats());
                result.put("access", statsDao.getAccessStats());
                response.getWriter().write(JSON.toJSONString(result));
            }

        } catch (Exception e) {
            System.err.println("[StatsServlet] 错误：" + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, 500, "服务器内部错误");
        }
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
