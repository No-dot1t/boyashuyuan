/**
 * ===========================================================================
 * ContentReviewDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getReviewStats()                   查询操作
 * approveReview(int id, String reviewerId)内部工具方法
 * rejectReview(int id, String reviewerId, String reason)内部工具方法
 * addReview(String title, String contentType, String contentPreview,
                              String submitter, String priority, double aiScore, String aiFeedback)新增操作
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   sql = new StringBuilder()
 *   status = 'pending' ")
 *   content_type = ? ")
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql.toString())) {
            if (contentType != null && !contentType.isEmpty() && !"all".equals(contentType)) {
                ps.setString(1, contentType)
 *   rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>()
 *   stats = new HashMap<>()
 *   sql = "SELECT "
                   + "COUNT(*) AS total, "
                   + "SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending_count, "
                   + "SUM(CASE WHEN status = 'approved' AND DATE(reviewed_at) = CURDATE() THEN 1 ELSE 0 END) AS today_approved, "
                   + "SUM(CASE WHEN status = 'rejected' AND DATE(reviewed_at) = CURDATE() THEN 1 ELSE 0 END) AS today_rejected, "
                   + "SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) AS total_approved, "
                   + "SUM(CASE WHEN status IN ('approved','rejected') THEN 1 ELSE 0 END) AS total_reviewed, "
                   + "COALESCE(AVG(CASE WHEN status IN ('approved','rejected') AND reviewed_at IS NOT NULL "
                   + "THEN TIMESTAMPDIFF(MINUTE, submitted_at, reviewed_at) END), 0) AS avg_review_minutes, "
                   + "COALESCE(AVG(ai_score), 0) AS avg_ai_score "
                   + "FROM content_review"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            if (rs.next()) {
                int pending = rs.getInt("pending_count")
 *   todayApproved = rs.getInt("today_approved")
 *   todayRejected = rs.getInt("today_rejected")
 *   todayTotal = todayApproved + todayRejected
 *   totalApproved = rs.getInt("total_approved")
 *   totalReviewed = rs.getInt("total_reviewed")
 *   sql = "UPDATE content_review SET status = 'approved', reviewer_id = ?, reviewed_at = NOW() WHERE id = ? AND status = 'pending'"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, reviewerId)
 *   sql = "UPDATE content_review SET status = 'rejected', reviewer_id = ?, rejection_reason = ?, reviewed_at = NOW() WHERE id = ? AND status = 'pending'"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, reviewerId)
 *   sql = "INSERT INTO content_review (title, content_type, content_preview, submitter, priority, status, submitted_at, ai_score, ai_feedback) "
                   + "VALUES (?, ?, ?, ?, ?, 'pending', NOW(), ?, ?)"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, title)
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   JDBC —— Connection / PreparedStatement / ResultSet 数据库访问
 *
 * ===========================================================================
 */

package com.ebookBuy301.dao;

import com.ebookBuy301.db.DBManager;
import com.ebookBuy301.pojo.Course;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * =============================================================================
 * ContentReviewDao —— 内容审核数据访问层
 * =============================================================================
 *
 * 负责 content_review 表的增删改查操作。
 *
 * 方法索引：
 *   1. getPendingReviews()       → 获取待审核内容
 *   2. getReviewStats()          → 获取审核统计数据
 *   3. approveReview()           → 通过审核
 *   4. rejectReview()            → 拒绝审核
 *   5. addReview()               → 新增待审核内容
 * =============================================================================
 */
public class ContentReviewDao {

    /** 获取待审核内容（按优先级和提交时间排列） */
    public ArrayList<Map<String, Object>> getPendingReviews(String contentType) throws ClassNotFoundException {
        ArrayList<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT * FROM content_review WHERE status = 'pending' ");
        if (contentType != null && !contentType.isEmpty() && !"all".equals(contentType)) {
            sql.append("AND content_type = ? ");
        }
        sql.append("ORDER BY FIELD(priority, 'high', 'report', 'normal', 'low'), submitted_at ASC");

        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (contentType != null && !contentType.isEmpty() && !"all".equals(contentType)) {
                ps.setString(1, contentType);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("id", rs.getInt("id"));
                    item.put("title", rs.getString("title"));
                    item.put("contentType", rs.getString("content_type"));
                    item.put("contentPreview", rs.getString("content_preview"));
                    item.put("submitter", rs.getString("submitter"));
                    item.put("priority", rs.getString("priority"));
                    item.put("status", rs.getString("status"));
                    item.put("submittedAt", rs.getTimestamp("submitted_at"));
                    item.put("aiScore", rs.getObject("ai_score"));
                    item.put("aiFeedback", rs.getString("ai_feedback"));
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ContentReviewDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /** 获取审核统计数据 */
    public Map<String, Object> getReviewStats() throws ClassNotFoundException {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT "
                   + "COUNT(*) AS total, "
                   + "SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending_count, "
                   + "SUM(CASE WHEN status = 'approved' AND DATE(reviewed_at) = CURDATE() THEN 1 ELSE 0 END) AS today_approved, "
                   + "SUM(CASE WHEN status = 'rejected' AND DATE(reviewed_at) = CURDATE() THEN 1 ELSE 0 END) AS today_rejected, "
                   + "SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) AS total_approved, "
                   + "SUM(CASE WHEN status IN ('approved','rejected') THEN 1 ELSE 0 END) AS total_reviewed, "
                   + "COALESCE(AVG(CASE WHEN status IN ('approved','rejected') AND reviewed_at IS NOT NULL "
                   + "THEN TIMESTAMPDIFF(MINUTE, submitted_at, reviewed_at) END), 0) AS avg_review_minutes, "
                   + "COALESCE(AVG(ai_score), 0) AS avg_ai_score "
                   + "FROM content_review";

        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int pending = rs.getInt("pending_count");
                int todayApproved = rs.getInt("today_approved");
                int todayRejected = rs.getInt("today_rejected");
                int todayTotal = todayApproved + todayRejected;
                int totalApproved = rs.getInt("total_approved");
                int totalReviewed = rs.getInt("total_reviewed");

                stats.put("pendingCount", pending);
                stats.put("todayReviews", todayTotal);
                stats.put("approvalRate", totalReviewed > 0 ? Math.round(totalApproved * 100.0 / totalReviewed) : 0);
                stats.put("avgTime", rs.getInt("avg_review_minutes"));
                stats.put("avgAiScore", rs.getDouble("avg_ai_score"));
                stats.put("totalApproved", totalApproved);
                stats.put("totalReviewed", totalReviewed);
            }
        } catch (SQLException e) {
            System.err.println("[ContentReviewDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            // 默认值
            stats.put("pendingCount", 0);
            stats.put("todayReviews", 0);
            stats.put("approvalRate", 0);
            stats.put("avgTime", 0);
            stats.put("avgAiScore", 0.0);
            stats.put("totalApproved", 0);
            stats.put("totalReviewed", 0);
        }
        return stats;
    }

    /** 通过审核 */
    public boolean approveReview(int id, String reviewerId) throws ClassNotFoundException {
        String sql = "UPDATE content_review SET status = 'approved', reviewer_id = ?, reviewed_at = NOW() WHERE id = ? AND status = 'pending'";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reviewerId);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[ContentReviewDao] approveReview 错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /** 拒绝审核 */
    public boolean rejectReview(int id, String reviewerId, String reason) throws ClassNotFoundException {
        String sql = "UPDATE content_review SET status = 'rejected', reviewer_id = ?, rejection_reason = ?, reviewed_at = NOW() WHERE id = ? AND status = 'pending'";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reviewerId);
            ps.setString(2, reason);
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[ContentReviewDao] rejectReview 错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /** 搜索审核内容（按标题/内容预览/提交者模糊匹配）—— 管理员全局搜索专用 */
    public ArrayList<Map<String, Object>> searchReviews(String keyword) throws ClassNotFoundException {
        ArrayList<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM content_review WHERE title LIKE ? OR content_preview LIKE ? OR submitter LIKE ? ORDER BY submitted_at DESC LIMIT 20";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String like = "%" + keyword + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("id", rs.getInt("id"));
                    item.put("title", rs.getString("title"));
                    item.put("contentType", rs.getString("content_type"));
                    item.put("contentPreview", rs.getString("content_preview"));
                    item.put("submitter", rs.getString("submitter"));
                    item.put("priority", rs.getString("priority"));
                    item.put("status", rs.getString("status"));
                    item.put("submittedAt", rs.getTimestamp("submitted_at"));
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ContentReviewDao] searchReviews 错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /** 新增待审核内容 */
    public boolean addReview(String title, String contentType, String contentPreview,
                              String submitter, String priority, double aiScore, String aiFeedback) throws ClassNotFoundException {
        String sql = "INSERT INTO content_review (title, content_type, content_preview, submitter, priority, status, submitted_at, ai_score, ai_feedback) "
                   + "VALUES (?, ?, ?, ?, ?, 'pending', NOW(), ?, ?)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, contentType);
            ps.setString(3, contentPreview);
            ps.setString(4, submitter);
            ps.setString(5, priority);
            ps.setDouble(6, aiScore);
            ps.setString(7, aiFeedback);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[ContentReviewDao] addReview 错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
