/**
 * ===========================================================================
 * PomodoroSessionDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 注解      @param, @return
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * startSession(String userId, int focusDuration, int breakDuration)内部工具方法
 * completeSession(int sessionId)     内部工具方法
 * getRecentSessions(String userId, int limit)查询操作
 * getTodayFocusMinutes(String userId)查询操作
 * extractPomodoroSession(ResultSet rs)数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   sql = "INSERT INTO pomodoro_session (user_id, focus_duration, break_duration, started_at, is_completed) "
                   + "VALUES (?, ?, ?, CURRENT_TIMESTAMP, 0)"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, userId)
 *   rows = ps.executeUpdate()
 *   rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1)
 *   sql = "UPDATE pomodoro_session SET is_completed = 1, completed_at = CURRENT_TIMESTAMP WHERE id = ? AND is_completed = 0"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId)
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM pomodoro_session WHERE user_id = ? ORDER BY started_at DESC LIMIT ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractPomodoroSession(rs))
 *   sql = "SELECT COALESCE(SUM(focus_duration), 0) AS total_minutes FROM pomodoro_session "
                   + "WHERE user_id = ? AND is_completed = 1 AND DATE(started_at) = CURDATE()"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total_minutes")
 *   sql = "SELECT DATE_FORMAT(started_at, '" + dateFormat + "') AS period_label, "
                   + "SUM(focus_duration) AS total_minutes, "
                   + "COUNT(*) AS session_count "
                   + "FROM pomodoro_session "
                   + "WHERE user_id = ? AND is_completed = 1 "
                   + "AND started_at >= DATE_SUB(CURDATE(), INTERVAL " + intervalDays + " DAY) "
                   + "GROUP BY period_label ORDER BY period_label ASC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>()
 *   session = new PomodoroSession()
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
import com.ebookBuy301.pojo.PomodoroSession;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * =============================================================================
 * PomodoroSessionDao —— 番茄钟数据访问层
 * =============================================================================
 *
 * 负责 pomodoro_session 表的增删改查操作。
 *
 * 方法索引：
 *   1. startSession()       → 开始番茄钟（返回session ID）
 *   2. completeSession()    → 完成番茄钟
 *   3. getRecentSessions()  → 获取最近番茄钟记录
 *   4. getTodayFocusMinutes() → 获取今日专注分钟数
 *   5. getFocusTrend()      → 按日/周/月返回专注度数据
 * =============================================================================
 */
public class PomodoroSessionDao {

    /** 开始番茄钟，返回session ID（失败返回-1） */
    public int startSession(String userId, int focusDuration, int breakDuration) throws SQLException {
        String sql = "INSERT INTO pomodoro_session (user_id, focus_duration, break_duration, started_at, is_completed) "
                   + "VALUES (?, ?, ?, CURRENT_TIMESTAMP, 0)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, userId);
            ps.setInt(2, focusDuration);
            ps.setInt(3, breakDuration);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
                // 回退方案：部分 JDBC 驱动不返回 generated keys
                try (Statement st = conn.createStatement();
                     ResultSet rs2 = st.executeQuery("SELECT LAST_INSERT_ID()")) {
                    if (rs2.next()) {
                        int id = rs2.getInt(1);
                        if (id > 0) return id;
                    }
                }
            }
        }
        return -1;
    }

    /** 完成番茄钟 */
    public boolean completeSession(int sessionId) throws SQLException {
        String sql = "UPDATE pomodoro_session SET is_completed = 1, completed_at = CURRENT_TIMESTAMP WHERE id = ? AND is_completed = 0";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            return ps.executeUpdate() > 0;
        }
    }

    /** 取消番茄钟会话（用户主动重置时调用） */
    public boolean cancelSession(int sessionId) throws SQLException {
        String sql = "DELETE FROM pomodoro_session WHERE id = ? AND is_completed = 0";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            return ps.executeUpdate() > 0;
        }
    }

    /** 获取最近番茄钟记录 */
    public ArrayList<PomodoroSession> getRecentSessions(String userId, int limit) throws SQLException {
        ArrayList<PomodoroSession> list = new ArrayList<>();
        String sql = "SELECT * FROM pomodoro_session WHERE user_id = ? ORDER BY started_at DESC LIMIT ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractPomodoroSession(rs));
                }
            }
        }
        return list;
    }

    /** 获取今日专注分钟数 */
    public int getTodayFocusMinutes(String userId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(focus_duration), 0) AS total_minutes FROM pomodoro_session "
                   + "WHERE user_id = ? AND is_completed = 1 AND DATE(started_at) = CURDATE()";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total_minutes");
                }
            }
        }
        return 0;
    }

    /**
     * 按日/周/月返回专注度数据
     * @param period "day" | "week" | "month"
     * @return 包含 date/label/minutes 的Map列表
     */
    public ArrayList<Map<String, Object>> getFocusTrend(String userId, String period) throws SQLException {
        ArrayList<Map<String, Object>> list = new ArrayList<>();
        String dateFormatExpr;
        int intervalDays;
        switch (period) {
            case "week":
                dateFormatExpr = "%Y-%u"; // 年-周
                intervalDays = 56; // 8周
                break;
            case "month":
                dateFormatExpr = "%Y-%m"; // 年-月
                intervalDays = 180; // 6个月
                break;
            default:
                dateFormatExpr = "%Y-%m-%d"; // 年-月-日
                intervalDays = 30; // 30天
                break;
        }
        String sql = "SELECT DATE_FORMAT(started_at, ?) AS period_label, "
                   + "SUM(focus_duration) AS total_minutes, "
                   + "COUNT(*) AS session_count "
                   + "FROM pomodoro_session "
                   + "WHERE user_id = ? AND is_completed = 1 "
                   + "AND started_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY) "
                   + "GROUP BY period_label ORDER BY period_label ASC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dateFormatExpr);
            ps.setString(2, userId);
            ps.setInt(3, intervalDays);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("label", rs.getString("period_label"));
                    item.put("minutes", rs.getInt("total_minutes"));
                    item.put("sessionCount", rs.getInt("session_count"));
                    list.add(item);
                }
            }
        }
        return list;
    }

    /** 获取用户累计专注分钟数 */
    public int getTotalFocusMinutes(String userId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(focus_duration), 0) AS total_minutes FROM pomodoro_session "
                   + "WHERE user_id = ? AND is_completed = 1";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total_minutes");
                }
            }
        }
        return 0;
    }

    /** 获取今日所有用户的总专注时长（分钟） */
    public int getTodayTotalFocusMinutes() throws SQLException {
        String sql = "SELECT COALESCE(SUM(focus_duration), 0) AS total_minutes FROM pomodoro_session "
                   + "WHERE is_completed = 1 AND DATE(started_at) = CURDATE()";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("total_minutes");
            }
        }
        return 0;
    }

    /** 从ResultSet提取PomodoroSession对象 */
    private PomodoroSession extractPomodoroSession(ResultSet rs) throws SQLException {
        PomodoroSession session = new PomodoroSession();
        session.setId(rs.getInt("id"));
        session.setUserId(rs.getString("user_id"));
        session.setFocusDuration(rs.getInt("focus_duration"));
        session.setBreakDuration(rs.getInt("break_duration"));
        session.setStartedAt(rs.getTimestamp("started_at"));
        session.setCompletedAt(rs.getTimestamp("completed_at"));
        session.setCompleted(rs.getBoolean("is_completed"));
        return session;
    }
}
