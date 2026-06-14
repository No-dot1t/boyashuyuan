/**
 * ===========================================================================
 * StudyTaskDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getTasksByUserId(String userId)    查询操作
 * addTask(String userId, String title)新增操作
 * addTaskReturnId(String userId, String title)新增操作
 * completeTask(int taskId)           内部工具方法
 * deleteTask(int taskId)             删除操作
 * extractStudyTask(ResultSet rs)     数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM study_task WHERE user_id = ? ORDER BY created_at DESC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractStudyTask(rs))
 *   sql = "INSERT INTO study_task (user_id, title, status) VALUES (?, ?, 'pending')"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   sql = "INSERT INTO study_task (user_id, title, status) VALUES (?, ?, 'pending')"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, userId)
 *   rows = ps.executeUpdate()
 *   rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1)
 *   sql = "UPDATE study_task SET status = 'completed', completed_at = CURRENT_TIMESTAMP WHERE id = ? AND status = 'pending'"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, taskId)
 *   sql = "DELETE FROM study_task WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, taskId)
 *   task = new StudyTask()
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
import com.ebookBuy301.pojo.StudyTask;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * =============================================================================
 * StudyTaskDao —— 学习任务数据访问层
 * =============================================================================
 *
 * 负责 study_task 表的增删改查操作。
 *
 * 方法索引：
 *   1. getTasksByUserId()  → 根据用户ID获取任务列表
 *   2. addTask()           → 添加学习任务
 *   3. completeTask()      → 完成学习任务
 *   4. deleteTask()        → 删除学习任务
 * =============================================================================
 */
public class StudyTaskDao {

    /** 根据用户ID获取任务列表 */
    public ArrayList<StudyTask> getTasksByUserId(String userId) throws SQLException {
        ArrayList<StudyTask> list = new ArrayList<>();
        String sql = "SELECT * FROM study_task WHERE user_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractStudyTask(rs));
                }
            }
        }
        return list;
    }

    /** 添加学习任务 */
    public boolean addTask(String userId, String title) throws SQLException {
        String sql = "INSERT INTO study_task (user_id, title, status) VALUES (?, ?, 'pending')";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, title);
            return ps.executeUpdate() > 0;
        }
    }

    /** 添加学习任务，返回自增ID（失败返回-1） */
    public int addTaskReturnId(String userId, String title) throws SQLException {
        String sql = "INSERT INTO study_task (user_id, title, status) VALUES (?, ?, 'pending')";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, userId);
            ps.setString(2, title);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
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

    /** 完成学习任务 */
    public boolean completeTask(int taskId) throws SQLException {
        String sql = "UPDATE study_task SET status = 'completed', completed_at = CURRENT_TIMESTAMP WHERE id = ? AND status = 'pending'";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            return ps.executeUpdate() > 0;
        }
    }

    /** 更新学习任务标题和截止日期 */
    public boolean updateTask(int taskId, String title, String dueDate) throws SQLException {
        String sql = "UPDATE study_task SET title = ?" +
                     (dueDate != null && !dueDate.isEmpty() ? ", task_dueDate = ?" : "") +
                     " WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            int paramIndex = 2;
            if (dueDate != null && !dueDate.isEmpty()) {
                ps.setString(paramIndex++, dueDate);
            }
            ps.setInt(paramIndex, taskId);
            return ps.executeUpdate() > 0;
        }
    }

    /** 删除学习任务 */
    public boolean deleteTask(int taskId) throws SQLException {
        String sql = "DELETE FROM study_task WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * 获取接下来24小时内到期的任务提醒
     * @return 包含 title 和 dueDate 的 Map 列表
     */
    public ArrayList<Map<String, Object>> getTasksDueSoon() throws SQLException {
        ArrayList<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT title, task_dueDate FROM study_task "
                   + "WHERE status = 'pending' AND task_dueDate IS NOT NULL "
                   + "AND task_dueDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 1 DAY) "
                   + "ORDER BY task_dueDate ASC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("title", rs.getString("title"));
                java.util.Date dueDate = rs.getTimestamp("task_dueDate");
                item.put("dueDate", dueDate != null ? dueDate.toString() : "");
                list.add(item);
            }
        }
        return list;
    }

    /** 统计今日完成的任务数 */
    public int getTodayCompletedCount() throws SQLException {
        String sql = "SELECT COUNT(*) AS cnt FROM study_task "
                   + "WHERE status = 'completed' AND DATE(completed_at) = CURDATE()";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("cnt");
            }
        }
        return 0;
    }

    /** 从ResultSet提取StudyTask对象 */
    private StudyTask extractStudyTask(ResultSet rs) throws SQLException {
        StudyTask task = new StudyTask();
        task.setId(rs.getInt("id"));
        task.setUserId(rs.getString("user_id"));
        task.setTitle(rs.getString("title"));
        task.setStatus(rs.getString("status"));
        task.setCreatedAt(rs.getTimestamp("created_at"));
        task.setCompletedAt(rs.getTimestamp("completed_at"));
        return task;
    }
}
