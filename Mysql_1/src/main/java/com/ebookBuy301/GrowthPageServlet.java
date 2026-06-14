/**
 * ===========================================================================
 * GrowthPageServlet —— 成长中心页面控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 路由      /growthPage
 * 最后更新  2026-06-03
 *
 * GET /growthPage → 渲染成长中心页面
 * GET /growthPage?action=achievements → JSON 成就列表（含用户获得状态）
 * GET /growthPage?action=stats → JSON 成长统计数据
 * GET /growthPage?action=timeline → JSON 活动时间线
 *
 * ===========================================================================
 */

package com.ebookBuy301;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.ebookBuy301.dao.AchievementDao;
import com.ebookBuy301.dao.PomodoroSessionDao;
import com.ebookBuy301.dao.UserActivityDao;
import com.ebookBuy301.dao.StudyTaskDao;
import com.ebookBuy301.pojo.Achievement;
import com.ebookBuy301.pojo.UserActivity;
import com.ebookBuy301.pojo.Users;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;

@WebServlet("/growthPage")
public class GrowthPageServlet extends HttpServlet {

    private AchievementDao achievementDao;
    private PomodoroSessionDao pomodoroDao;
    private UserActivityDao activityDao;
    private StudyTaskDao taskDao;

    @Override
    public void init() throws ServletException {
        achievementDao = new AchievementDao();
        pomodoroDao = new PomodoroSessionDao();
        activityDao = new UserActivityDao();
        taskDao = new StudyTaskDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        Users currentUser = (Users) request.getSession().getAttribute("currentUser");
        String action = request.getParameter("action");

        // API 模式
        if (action != null) {
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();

            if (currentUser == null) {
                out.print("{\"success\":false,\"message\":\"请先登录\"}");
                return;
            }

            String userId = currentUser.getId().toString();
            try {
                switch (action) {
                    case "achievements": {
                        ArrayList<Achievement> achievements = achievementDao.getAchievementsByUserId(userId);
                        out.print(achievementsToJson(achievements));
                        break;
                    }
                    case "stats": {
                        out.print(buildGrowthStats(userId));
                        break;
                    }
                    case "timeline": {
                        ArrayList<UserActivity> activities = activityDao.getRecentActivities(userId, 30);
                        out.print(timelineToJson(activities));
                        break;
                    }
                    case "trend": {
                        String period = request.getParameter("period");
                        if (period == null) period = "week";
                        ArrayList<java.util.Map<String, Object>> trend = pomodoroDao.getFocusTrend(userId, period);
                        out.print(trendToJson(trend));
                        break;
                    }
                    default:
                        out.print("{\"success\":false,\"message\":\"未知操作\"}");
                }
            } catch (Exception e) {
                out.print("{\"success\":false,\"message\":\"" + escapeJson(e.getMessage()) + "\"}");
            }
            return;
        }

        // 页面模式
        request.setAttribute("currentUser", currentUser);
        try {
            if (currentUser != null) {
                ArrayList<Achievement> achievements = achievementDao.getAchievementsByUserId(currentUser.getId().toString());
                request.setAttribute("achievements", achievements);
                request.setAttribute("achievementCount", (long) achievements.size());
                request.setAttribute("earnedCount", achievements.stream().filter(Achievement::isEarned).count());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        request.getRequestDispatcher("/pages/growth.jsp").forward(request, response);
    }

    /** 构建成长统计数据 JSON */
    private String buildGrowthStats(String userId) throws Exception {
        int totalTasks = taskDao.getTasksByUserId(userId).size();
        int completedToday = taskDao.getTodayCompletedCount();
        int todayFocus = pomodoroDao.getTodayFocusMinutes(userId);
        int totalFocus = pomodoroDao.getTotalFocusMinutes(userId);
        int streakDays = achievementDao.calculateStreakDays(userId);
        ArrayList<Achievement> achievements = achievementDao.getAchievementsByUserId(userId);
        long earnedCount = achievements.stream().filter(Achievement::isEarned).count();

        JSONObject obj = new JSONObject();
        obj.put("success", true);
        obj.put("totalTasks", totalTasks);
        obj.put("completedToday", completedToday);
        obj.put("todayFocusMinutes", todayFocus);
        obj.put("totalFocusMinutes", totalFocus);
        obj.put("streakDays", streakDays);
        obj.put("totalAchievements", achievements.size());
        obj.put("earnedAchievements", (int) earnedCount);
        return obj.toJSONString();
    }

    private String achievementsToJson(ArrayList<Achievement> list) {
        JSONArray arr = new JSONArray();
        for (Achievement a : list) {
            JSONObject obj = new JSONObject();
            obj.put("id", a.getId());
            obj.put("icon", a.getIcon());
            obj.put("name", a.getName());
            obj.put("description", a.getDescription());
            obj.put("earned", a.isEarned());
            obj.put("earnedAt", a.getEarnedAt() != null ? a.getEarnedAt().toString() : "");
            arr.add(obj);
        }
        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("achievements", arr);
        return result.toJSONString();
    }

    private String timelineToJson(ArrayList<UserActivity> activities) {
        JSONArray arr = new JSONArray();
        for (UserActivity act : activities) {
            JSONObject obj = new JSONObject();
            obj.put("type", act.getActivityType());
            obj.put("detail", act.getDetail());
            obj.put("time", act.getCreatedAt() != null ? act.getCreatedAt().toString() : "");
            arr.add(obj);
        }
        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("activities", arr);
        return result.toJSONString();
    }

    private String trendToJson(ArrayList<java.util.Map<String, Object>> trend) {
        JSONArray arr = new JSONArray();
        for (java.util.Map<String, Object> item : trend) {
            JSONObject obj = new JSONObject();
            obj.put("label", String.valueOf(item.get("label")));
            obj.put("minutes", item.get("minutes"));
            obj.put("sessionCount", item.get("sessionCount"));
            arr.add(obj);
        }
        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("trend", arr);
        return result.toJSONString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
}
