/**
 * ===========================================================================
 * StatsDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getStudyRoomStats()                查询操作
 * getCampus3dStats()                 查询操作
 * getDashboardStats()                查询操作
 * getAccessStats()                   查询操作
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   stats = new HashMap<>()
 *   sql = "SELECT * FROM studyroom_stats ORDER BY stat_date DESC LIMIT 1"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("onlineUsers", rs.getInt("online_users"))
 *   stats = new HashMap<>()
 *   sql = "SELECT * FROM campus3d_stats ORDER BY stat_date DESC LIMIT 1"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("onlineUsers", rs.getInt("online_users"))
 *   stats = new HashMap<>()
 *   sql = "SELECT * FROM dashboard_stats ORDER BY stat_date DESC LIMIT 1"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("activeUsers", rs.getInt("active_users"))
 *   stats = new HashMap<>()
 *   sql = "SELECT * FROM dashboard_access_stats ORDER BY stat_date DESC LIMIT 7"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            ArrayList<Map<String, Object>> list = new ArrayList<>()
 *   item = new HashMap<>()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   JDBC —— Connection / PreparedStatement / ResultSet 数据库访问
 *
 * ===========================================================================
 */

package com.ebookBuy301.dao;

import com.ebookBuy301.db.DBManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * =============================================================================
 * StatsDao —— 统计数据访问层
 * =============================================================================
 *
 * 负责各模块统计数据的查询操作。
 *
 * 方法索引：
 *   1. getStudyRoomStats()   → 自习室统计
 *   2. getCampus3dStats()    → 校园3D统计
 *   3. getDashboardStats()   → 管理驾驶舱统计
 *   4. getAccessStats()      → 访问统计（近7天）
 * =============================================================================
 */
public class StatsDao {

    /** 获取校园3D统计（最新一条） */
    public Map<String, Object> getCampus3dStats() throws SQLException {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT * FROM campus3d_stats ORDER BY stat_date DESC LIMIT 1";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("onlineUsers", rs.getInt("online_users"));
                stats.put("sceneCount", rs.getInt("scene_count"));
                stats.put("satisfactionRate", rs.getInt("satisfaction_rate"));
                stats.put("is24hOpen", rs.getBoolean("is_24h_open"));
                stats.put("statDate", rs.getDate("stat_date"));
            }
        }
        return stats;
    }

    /** 获取管理驾驶舱统计（最新一条） */
    public Map<String, Object> getDashboardStats() throws SQLException {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT * FROM dashboard_stats ORDER BY stat_date DESC LIMIT 1";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("activeUsers", rs.getInt("active_users"));
                stats.put("todayVisits", rs.getInt("today_visits"));
                stats.put("courseCompletionRate", rs.getInt("course_completion_rate"));
                stats.put("systemHealth", rs.getDouble("system_health"));
                stats.put("totalCourses", rs.getInt("total_courses"));
                stats.put("totalStudents", rs.getInt("total_students"));
                stats.put("totalTeachers", rs.getInt("total_teachers"));
                stats.put("statDate", rs.getDate("stat_date"));
            }
        }
        return stats;
    }

    /** 获取访问统计（近7天） */
    public Map<String, Object> getAccessStats() throws SQLException {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT * FROM dashboard_access_stats ORDER BY stat_date DESC LIMIT 7";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            ArrayList<Map<String, Object>> list = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("statDate", rs.getDate("stat_date"));
                item.put("totalVisits", rs.getInt("total_visits"));
                item.put("uniqueVisitors", rs.getInt("unique_visitors"));
                item.put("newUsers", rs.getInt("new_users"));
                item.put("activeUsers", rs.getInt("active_users"));
                item.put("pageViews", rs.getInt("page_views"));
                item.put("avgSessionDuration", rs.getInt("avg_session_duration"));
                item.put("bounceRate", rs.getDouble("bounce_rate"));
                list.add(item);
            }
            stats.put("recent7Days", list);
        }
        return stats;
    }
}
