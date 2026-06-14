/**
 * ===========================================================================
 * AchievementDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 注解      @param, @param, @param, @return
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getAllAchievements()               查询操作
 * getAchievementsByUserId(String userId)查询操作
 * earnAchievement(String userId, int achievementId)内部工具方法
 * checkAndAwardAchievements(String userId)内部工具方法
 * checkCondition(String userId, String conditionType, int conditionValue)内部工具方法
 * calculateStreakDays(conn, userId)  内部工具方法
 * getEarnedAchievementIds(String userId)查询操作
 * extractAchievement(ResultSet rs)   数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM achievement ORDER BY sort_order ASC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(extractAchievement(rs))
 *   list = new ArrayList<>()
 *   earnedIds = getEarnedAchievementIds(userId)
 *   sql = "SELECT * FROM achievement ORDER BY sort_order ASC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) {
                Achievement a = extractAchievement(rs)
 *   sql = "INSERT IGNORE INTO user_achievement (user_id, achievement_id) VALUES (?, ?)"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   allAchievements = getAllAchievements()
 *   earnedIds = getEarnedAchievementIds(userId)
 *   conditionMet = checkCondition(userId, a.getConditionType(), a.getConditionValue())
 *   conn = DBManager.getConnection()) {
            switch (conditionType) {
                case "streak_days": {
                    // 检查连续学习天数
                    String sql = "SELECT COUNT(DISTINCT DATE(created_at)) AS streak_days FROM user_activity "
                               + "WHERE user_id = ? AND activity_type IN ('start_pomodoro','read','view_book') "
                               + "AND created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY)"
 *   ps = conn.prepareStatement(sql)) {
                        ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                            if (rs.next()) {
                                return calculateStreakDays(conn, userId) >= conditionValue
 *   sql = "SELECT COALESCE(SUM(focus_duration), 0) AS total_minutes FROM pomodoro_session "
                               + "WHERE user_id = ? AND is_completed = 1"
 *   ps = conn.prepareStatement(sql)) {
                        ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                            if (rs.next()) {
                                int totalMinutes = rs.getInt("total_minutes")
 *   sql = "SELECT COUNT(*) AS cnt FROM user_course_record WHERE user_id = ? AND status = 'completed'"
 *   ps = conn.prepareStatement(sql)) {
                        ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                            if (rs.next()) {
                                return rs.getInt("cnt") >= conditionValue
 *   sql = "SELECT COALESCE("
                               + "ROUND(SUM(CASE WHEN is_completed = 1 THEN focus_duration ELSE 0 END) * 100.0 "
                               + "/ NULLIF(SUM(focus_duration), 0)), 0) AS efficiency "
                               + "FROM pomodoro_session WHERE user_id = ?"
 *   ps = conn.prepareStatement(sql)) {
                        ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                            if (rs.next()) {
                                return rs.getInt("efficiency") >= conditionValue
 *   sql = "SELECT DATE(created_at) AS learn_date FROM user_activity "
                   + "WHERE user_id = ? AND activity_type IN ('start_pomodoro','read','view_book') "
                   + "GROUP BY DATE(created_at) ORDER BY learn_date DESC"
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                int streak = 0
 *   expectedDate = java.sql.Date.valueOf(java.time.LocalDate.now())
 *   learnDate = rs.getDate("learn_date")
 *   earnedIds = new HashSet<>()
 *   sql = "SELECT achievement_id FROM user_achievement WHERE user_id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                while (rs.next()) {
                    earnedIds.add(rs.getInt("achievement_id"))
 *   a = new Achievement()
 *   conditionValue = 0
 *   cv = rs.getObject("condition_value")
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
import com.ebookBuy301.pojo.Achievement;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

/**
 * =============================================================================
 * AchievementDao —— 成就数据访问层
 * =============================================================================
 *
 * 负责 achievement 和 user_achievement 表的增删改查操作。
 *
 * 方法索引：
 *   1. getAllAchievements()          → 获取所有成就
 *   2. getAchievementsByUserId()     → 获取用户成就（标记earned）
 *   3. earnAchievement()             → 授予成就
 *   4. checkAndAwardAchievements()   → 检查条件自动授予成就
 * =============================================================================
 */
public class AchievementDao {

    /** 获取所有成就 */
    public ArrayList<Achievement> getAllAchievements() throws SQLException {
        ArrayList<Achievement> list = new ArrayList<>();
        String sql = "SELECT * FROM achievement ORDER BY sort_order ASC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(extractAchievement(rs));
            }
        }
        return list;
    }

    /** 获取用户成就（标记earned=true表示已获得） */
    public ArrayList<Achievement> getAchievementsByUserId(String userId) throws SQLException {
        ArrayList<Achievement> list = new ArrayList<>();
        // 先获取用户已获得的成就ID集合
        Set<Integer> earnedIds = getEarnedAchievementIds(userId);

        String sql = "SELECT * FROM achievement ORDER BY sort_order ASC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Achievement a = extractAchievement(rs);
                a.setEarned(earnedIds.contains(a.getId()));
                list.add(a);
            }
        }
        return list;
    }

    /** 授予成就 */
    public boolean earnAchievement(String userId, int achievementId) throws SQLException {
        String sql = "INSERT IGNORE INTO user_achievement (user_id, achievement_id) VALUES (?, ?)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setInt(2, achievementId);
            return ps.executeUpdate() > 0;
        }
    }

    /** 检查条件自动授予成就 */
    public void checkAndAwardAchievements(String userId) throws SQLException {
        // 获取所有成就定义
        ArrayList<Achievement> allAchievements = getAllAchievements();
        // 获取用户已获得的成就ID
        Set<Integer> earnedIds = getEarnedAchievementIds(userId);

        for (Achievement a : allAchievements) {
            // 跳过已获得的成就
            if (earnedIds.contains(a.getId())) {
                continue;
            }
            // 检查条件是否满足
            boolean conditionMet = checkCondition(userId, a.getConditionType(), a.getConditionValue());
            if (conditionMet) {
                earnAchievement(userId, a.getId());
            }
        }
    }

    /**
     * 检查用户是否满足某个成就条件
     * @param userId 用户ID
     * @param conditionType 条件类型
     * @param conditionValue 条件阈值
     * @return 是否满足
     */
    private boolean checkCondition(String userId, String conditionType, int conditionValue) throws SQLException {
        try (Connection conn = DBManager.getConnection()) {
            switch (conditionType) {
                case "streak_days": {
                    // 检查连续学习天数
                    String sql = "SELECT COUNT(DISTINCT DATE(created_at)) AS streak_days FROM user_activity "
                               + "WHERE user_id = ? AND activity_type IN ('start_pomodoro','read','view_book') "
                               + "AND created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY)";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, userId);
                        ps.setInt(2, conditionValue + 5); // 留余量
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                return calculateStreakDays(conn, userId) >= conditionValue;
                            }
                        }
                    }
                    break;
                }
                case "total_focus_hours": {
                    // 累计学习小时数
                    String sql = "SELECT COALESCE(SUM(focus_duration), 0) AS total_minutes FROM pomodoro_session "
                               + "WHERE user_id = ? AND is_completed = 1";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, userId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                int totalMinutes = rs.getInt("total_minutes");
                                return (totalMinutes / 60) >= conditionValue;
                            }
                        }
                    }
                    break;
                }
                case "courses_completed": {
                    // 完成课程数
                    String sql = "SELECT COUNT(*) AS cnt FROM user_course_record WHERE user_id = ? AND status = 'completed'";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, userId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                return rs.getInt("cnt") >= conditionValue;
                            }
                        }
                    }
                    break;
                }
                case "efficiency_score": {
                    // 效率指数（基于专注完成率）
                    String sql = "SELECT COALESCE("
                               + "ROUND(SUM(CASE WHEN is_completed = 1 THEN focus_duration ELSE 0 END) * 100.0 "
                               + "/ NULLIF(SUM(focus_duration), 0)), 0) AS efficiency "
                               + "FROM pomodoro_session WHERE user_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, userId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                return rs.getInt("efficiency") >= conditionValue;
                            }
                        }
                    }
                    break;
                }
                default:
                    break;
            }
        }
        return false;
    }

    /** 计算用户连续学习天数（自动获取连接） */
    public int calculateStreakDays(String userId) throws SQLException {
        try (Connection conn = DBManager.getConnection()) {
            return calculateStreakDays(conn, userId);
        }
    }

    /** 计算用户连续学习天数（使用已有连接，避免重复创建） */
    public int calculateStreakDays(Connection conn, String userId) throws SQLException {
        String sql = "SELECT DATE(created_at) AS learn_date FROM user_activity "
                   + "WHERE user_id = ? AND activity_type IN ('start_pomodoro','read','view_book') "
                   + "GROUP BY DATE(created_at) ORDER BY learn_date DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                int streak = 0;
                java.sql.Date expectedDate = java.sql.Date.valueOf(java.time.LocalDate.now());
                while (rs.next()) {
                    java.sql.Date learnDate = rs.getDate("learn_date");
                    if (learnDate.equals(expectedDate) || learnDate.equals(
                            java.sql.Date.valueOf(expectedDate.toLocalDate().minusDays(streak)))) {
                        streak++;
                    } else {
                        break;
                    }
                }
                return streak;
            }
        }
    }

    /** 获取用户已获得的成就ID集合 */
    private Set<Integer> getEarnedAchievementIds(String userId) throws SQLException {
        Set<Integer> earnedIds = new HashSet<>();
        String sql = "SELECT achievement_id FROM user_achievement WHERE user_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    earnedIds.add(rs.getInt("achievement_id"));
                }
            }
        }
        return earnedIds;
    }

    /** 从ResultSet提取Achievement对象 */
    private Achievement extractAchievement(ResultSet rs) throws SQLException {
        Achievement a = new Achievement();
        a.setId(rs.getInt("id"));
        a.setIcon(rs.getString("icon"));
        a.setName(rs.getString("name"));
        a.setDescription(rs.getString("description"));
        a.setConditionType(rs.getString("condition_type"));
        int conditionValue = 0;
        Object cv = rs.getObject("condition_value");
        if (cv != null) {
            conditionValue = ((Number) cv).intValue();
        }
        a.setConditionValue(conditionValue);
        a.setSortOrder(rs.getInt("sort_order"));
        return a;
    }
}
