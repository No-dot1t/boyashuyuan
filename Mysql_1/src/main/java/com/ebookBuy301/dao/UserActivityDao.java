/**
 * ===========================================================================
 * UserActivityDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * logActivity(String userId, String activityType, String referenceId, String detail)内部工具方法
 * getRecentActivities(String userId, int limit)查询操作
 * getActivityCountByType(String activityType, String since)查询操作
 * getActiveUserCount(int minutesAgo) 查询操作
 * getContentStats()                  查询操作
 * extractUserActivity(ResultSet rs)  数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   sql = "INSERT INTO user_activity (user_id, activity_type, reference_id, detail) VALUES (?, ?, ?, ?)"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM user_activity WHERE user_id = ? ORDER BY created_at DESC LIMIT ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractUserActivity(rs))
 *   sql = "SELECT COUNT(*) AS cnt FROM user_activity WHERE activity_type = ? AND created_at >= ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, activityType)
 *   rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt")
 *   sql = "SELECT COUNT(DISTINCT user_id) AS cnt FROM user_activity "
                   + "WHERE created_at >= DATE_SUB(NOW(), INTERVAL ? MINUTE) AND user_id IS NOT NULL"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, minutesAgo)
 *   rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt")
 *   sql = "SELECT DATE(created_at) AS stat_date, "
                   + "COUNT(*) AS total_visits, "
                   + "COUNT(DISTINCT user_id) AS unique_visitors, "
                   + "COUNT(CASE WHEN activity_type = 'login' THEN 1 END) AS login_count, "
                   + "COUNT(CASE WHEN activity_type = 'view_book' THEN 1 END) AS view_book_count, "
                   + "COUNT(CASE WHEN activity_type = 'start_pomodoro' THEN 1 END) AS pomodoro_count "
                   + "FROM user_activity "
                   + "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY) "
                   + "GROUP BY DATE(created_at) ORDER BY stat_date ASC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, days)
 *   rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>()
 *   sql = "SELECT HOUR(created_at) AS hour_slot, COUNT(*) AS activity_count "
                   + "FROM user_activity "
                   + "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) "
                   + "GROUP BY HOUR(created_at) ORDER BY hour_slot ASC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>()
 *   sql = "SELECT "
                   + "CASE "
                   + "  WHEN activity_type = 'login' THEN '直接访问' "
                   + "  WHEN activity_type = 'view_book' THEN '书籍浏览' "
                   + "  WHEN activity_type = 'start_pomodoro' THEN '学习工具' "
                   + "  WHEN activity_type = 'visit_scene' THEN '虚拟校园' "
                   + "  WHEN activity_type = 'read' THEN '阅读器' "
                   + "  ELSE '其他' "
                   + "END AS source, "
                   + "COUNT(*) AS visit_count "
                   + "FROM user_activity "
                   + "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) "
                   + "GROUP BY source ORDER BY visit_count DESC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>()
 *   stats = new HashMap<>()
 *   conn = DBManager.getConnection()) {
            // 总课程数
            try (Statement st = conn.createStatement()
 *   rs = st.executeQuery("SELECT COUNT(*) FROM course")) {
                if (rs.next()) stats.put("totalCourses", rs.getInt(1))
 *   st = conn.createStatement()
 *   rs = st.executeQuery("SELECT COUNT(*) FROM content_reviews WHERE status='pending'")) {
                if (rs.next()) stats.put("pendingReviews", rs.getInt(1))
 *   st = conn.createStatement()
 *   rs = st.executeQuery("SELECT COUNT(*) FROM users")) {
                if (rs.next()) stats.put("totalUsers", rs.getInt(1))
 *   ps = conn.prepareStatement(
                    "SELECT COUNT(DISTINCT user_id) FROM user_activity WHERE activity_type='register' AND created_at >= CURDATE()")) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) stats.put("todayNewUsers", rs.getInt(1))
 *   st = conn.createStatement()
 *   rs = st.executeQuery("SELECT COUNT(*) FROM notification WHERE status='sent'")) {
                if (rs.next()) stats.put("sentNotifications", rs.getInt(1))
 *   activity = new UserActivity()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   JDBC —— Connection / PreparedStatement / ResultSet 数据库访问
 *   ResultSet 行映射 —— 手动抽取字段 → POJO 对象
 *
 * ===========================================================================
 */

package com.ebookBuy301.dao;

import com.ebookBuy301.db.DBManager;
import com.ebookBuy301.pojo.UserActivity;
import com.ebookBuy301.pojo.Users;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * =============================================================================
 * UserActivityDao —— 用户活动日志数据访问层
 * =============================================================================
 *
 * 负责 user_activity 表的增删改查及统计操作。
 *
 * 方法索引：
 *   1. logActivity()               → 记录用户活动
 *   2. getRecentActivities()       → 获取用户最近活动
 *   3. getActivityCountByType()    → 按类型统计活动数
 *   4. getActiveUserCount()        → 获取最近N分钟活跃用户数
 *   5. getAccessStatsByDay()       → 每日访问统计
 *   6. getActivityDistributionByHour() → 按小时分布统计
 *   7. getTrafficSourceStats()     → 模拟访问来源统计
 *   8. getContentStats()           → 内容管理综合统计（dashboard用）
 * =============================================================================
 */
public class UserActivityDao {

    /** 记录用户活动 */
    public boolean logActivity(String userId, String activityType, String referenceId, String detail) throws ClassNotFoundException {
        String sql = "INSERT INTO user_activity (user_id, activity_type, reference_id, detail) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, activityType);
            // reference_id 是 BIGINT 类型，兼容 null 和非数字字符串
            if (referenceId != null && !referenceId.isEmpty()) {
                try {
                    ps.setLong(3, Long.parseLong(referenceId));
                } catch (NumberFormatException e) {
                    ps.setNull(3, Types.BIGINT);
                }
            } else {
                ps.setNull(3, Types.BIGINT);
            }
            ps.setString(4, detail);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UserActivityDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /** 获取用户最近活动 */
    public ArrayList<UserActivity> getRecentActivities(String userId, int limit) throws ClassNotFoundException {
        ArrayList<UserActivity> list = new ArrayList<>();
        String sql = "SELECT * FROM user_activity WHERE user_id = ? ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractUserActivity(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserActivityDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /** 按类型统计活动数 */
    public int getActivityCountByType(String activityType, String since) throws ClassNotFoundException {
        String sql = "SELECT COUNT(*) AS cnt FROM user_activity WHERE activity_type = ? AND created_at >= ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, activityType);
            ps.setString(2, since);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt");
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserActivityDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /** 获取最近N分钟活跃用户数 */
    public int getActiveUserCount(int minutesAgo) throws ClassNotFoundException {
        String sql = "SELECT COUNT(DISTINCT user_id) AS cnt FROM user_activity "
                   + "WHERE created_at >= DATE_SUB(NOW(), INTERVAL ? MINUTE) AND user_id IS NOT NULL";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, minutesAgo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt");
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserActivityDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /** 每日访问统计（近N天） */
    public ArrayList<Map<String, Object>> getAccessStatsByDay(int days) throws ClassNotFoundException {
        ArrayList<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT DATE(created_at) AS stat_date, "
                   + "COUNT(*) AS total_visits, "
                   + "COUNT(DISTINCT user_id) AS unique_visitors, "
                   + "COUNT(CASE WHEN activity_type = 'login' THEN 1 END) AS login_count, "
                   + "COUNT(CASE WHEN activity_type = 'view_book' THEN 1 END) AS view_book_count, "
                   + "COUNT(CASE WHEN activity_type = 'start_pomodoro' THEN 1 END) AS pomodoro_count "
                   + "FROM user_activity "
                   + "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY) "
                   + "GROUP BY DATE(created_at) ORDER BY stat_date ASC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("statDate", rs.getDate("stat_date").toString());
                    item.put("totalVisits", rs.getInt("total_visits"));
                    item.put("uniqueVisitors", rs.getInt("unique_visitors"));
                    item.put("loginCount", rs.getInt("login_count"));
                    item.put("viewBookCount", rs.getInt("view_book_count"));
                    item.put("pomodoroCount", rs.getInt("pomodoro_count"));
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserActivityDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /** 按小时分布统计活动 */
    public ArrayList<Map<String, Object>> getActivityDistributionByHour() throws ClassNotFoundException {
        ArrayList<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT HOUR(created_at) AS hour_slot, COUNT(*) AS activity_count "
                   + "FROM user_activity "
                   + "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) "
                   + "GROUP BY HOUR(created_at) ORDER BY hour_slot ASC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("hour", rs.getInt("hour_slot"));
                item.put("users", rs.getInt("activity_count"));
                list.add(item);
            }
        } catch (SQLException e) {
            System.err.println("[UserActivityDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /** 模拟访问来源统计 */
    public ArrayList<Map<String, Object>> getTrafficSourceStats() throws ClassNotFoundException {
        ArrayList<Map<String, Object>> list = new ArrayList<>();
        // 基于activity_type模拟不同来源的流量分布
        String sql = "SELECT "
                   + "CASE "
                   + "  WHEN activity_type = 'login' THEN '直接访问' "
                   + "  WHEN activity_type = 'view_book' THEN '书籍浏览' "
                   + "  WHEN activity_type = 'start_pomodoro' THEN '学习工具' "
                   + "  WHEN activity_type = 'visit_scene' THEN '虚拟校园' "
                   + "  WHEN activity_type = 'read' THEN '阅读器' "
                   + "  ELSE '其他' "
                   + "END AS source, "
                   + "COUNT(*) AS visit_count "
                   + "FROM user_activity "
                   + "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) "
                   + "GROUP BY source ORDER BY visit_count DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("source", rs.getString("source"));
                item.put("count", rs.getInt("visit_count"));
                list.add(item);
            }
        } catch (SQLException e) {
            System.err.println("[UserActivityDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /** 内容管理综合统计（管理驾驶舱用） */
    public Map<String, Object> getContentStats() throws ClassNotFoundException {
        Map<String, Object> stats = new HashMap<>();
        try (Connection conn = DBManager.getConnection()) {
            // 总课程数
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM course")) {
                if (rs.next()) stats.put("totalCourses", rs.getInt(1));
            }
            // 待审核内容
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM content_review WHERE status='pending'")) {
                if (rs.next()) stats.put("pendingReviews", rs.getInt(1));
            }
            // 总用户数
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM users")) {
                if (rs.next()) stats.put("totalUsers", rs.getInt(1));
            }
            // 今日新增用户（从用户活动日志推算注册行为，若无则返回0）
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(DISTINCT user_id) FROM user_activity WHERE activity_type='register' AND created_at >= CURDATE()")) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) stats.put("todayNewUsers", rs.getInt(1));
                }
            }
            // 已发送通知数
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM notification WHERE status='sent'")) {
                if (rs.next()) stats.put("sentNotifications", rs.getInt(1));
            }
        } catch (SQLException e) {
            System.err.println("[UserActivityDao] getContentStats SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        // 兜底默认值
        if (!stats.containsKey("totalCourses")) stats.put("totalCourses", 0);
        if (!stats.containsKey("pendingReviews")) stats.put("pendingReviews", 0);
        if (!stats.containsKey("totalUsers")) stats.put("totalUsers", 0);
        if (!stats.containsKey("todayNewUsers")) stats.put("todayNewUsers", 0);
        if (!stats.containsKey("sentNotifications")) stats.put("sentNotifications", 0);
        return stats;
    }

    /**
     * 获取最近5分钟内在线的用户列表（含用户信息）
     * @return 用户信息Map列表
     */
    public ArrayList<Map<String, Object>> getOnlineBuddies() throws ClassNotFoundException {
        ArrayList<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT DISTINCT u.id, u.nickname, u.username, u.avatar, "
                   + "a.activity_type, a.detail, a.created_at AS activity_time "
                   + "FROM user_activity a "
                   + "JOIN users u ON a.user_id = u.id "
                   + "WHERE a.created_at > DATE_SUB(NOW(), INTERVAL 5 MINUTE) "
                   + "ORDER BY a.created_at DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("userId", rs.getString("id"));
                item.put("nickname", rs.getString("nickname"));
                item.put("username", rs.getString("username"));
                item.put("avatar", rs.getString("avatar"));
                item.put("activityType", rs.getString("activity_type"));
                item.put("detail", rs.getString("detail"));
                item.put("activityTime", rs.getTimestamp("activity_time") != null
                    ? rs.getTimestamp("activity_time").toString() : "");
                list.add(item);
            }
        } catch (SQLException e) {
            System.err.println("[UserActivityDao] getOnlineBuddies SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /** 获取管理员数量 */
    public int getAdminCount() throws ClassNotFoundException {
        String sql = "SELECT COUNT(*) FROM users WHERE role = 'admin'";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[UserActivityDao] getAdminCount SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /** 从ResultSet提取UserActivity对象 */
    private UserActivity extractUserActivity(ResultSet rs) throws SQLException {
        UserActivity activity = new UserActivity();
        activity.setId(rs.getInt("id"));
        activity.setUserId(rs.getString("user_id"));
        activity.setActivityType(rs.getString("activity_type"));
        long refId = rs.getLong("reference_id");
        activity.setReferenceId(rs.wasNull() ? null : String.valueOf(refId));
        activity.setDetail(rs.getString("detail"));
        activity.setCreatedAt(rs.getTimestamp("created_at"));
        return activity;
    }

    /** 获取所有用户列表（含头像） */
    public List<Users> getAllUsers() throws ClassNotFoundException {
        List<Users> users = new ArrayList<>();
        String sql = "SELECT id, username, nickname, role, avatar FROM users WHERE id IS NOT NULL";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Users user = new Users();
                user.setId(rs.getString("id"));
                user.setUsername(rs.getString("username"));
                user.setNickname(rs.getString("nickname"));
                user.setRole(rs.getString("role"));
                user.setAvatar(rs.getString("avatar"));
                users.add(user);
            }
        } catch (SQLException e) {
            System.err.println("[UserActivityDao] getAllUsers SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return users;
    }
}
