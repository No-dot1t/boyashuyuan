/**
 * ===========================================================================
 * BookReviewDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getReviewsByBookId(long bookId)    查询操作
 * addReview(long bookId, String userId, String content)新增操作
 * deleteReview(int reviewId)         删除操作
 * extractBookReview(ResultSet rs)    数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   list = new ArrayList<>()
 *   sql = "SELECT br.*, u.username FROM book_review br "
                   + "LEFT JOIN users u ON br.user_id = u.id "
                   + "WHERE br.book_id = ? ORDER BY br.created_at DESC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId)
 *   rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookReview review = extractBookReview(rs)
 *   sql = "INSERT INTO book_review (book_id, user_id, content) VALUES (?, ?, ?)"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId)
 *   sql = "DELETE FROM book_review WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId)
 *   review = new BookReview()
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
import com.ebookBuy301.pojo.BookReview;

import java.sql.*;
import java.util.ArrayList;

/**
 * =============================================================================
 * BookReviewDao —— 图书评论数据访问层
 * =============================================================================
 *
 * 负责 book_review 表的增删改查操作。
 *
 * 方法索引：
 *   1. getReviewsByBookId() → 获取图书评论（LEFT JOIN users获取username）
 *   2. addReview()          → 添加评论
 *   3. deleteReview()       → 删除评论
 * =============================================================================
 */
public class BookReviewDao {

    /** 获取图书评论（LEFT JOIN users获取username） */
    public ArrayList<BookReview> getReviewsByBookId(long bookId) throws ClassNotFoundException {
        ArrayList<BookReview> list = new ArrayList<>();
        String sql = "SELECT br.*, u.username FROM book_review br "
                   + "LEFT JOIN users u ON br.user_id = u.id "
                   + "WHERE br.book_id = ? ORDER BY br.created_at DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookReview review = extractBookReview(rs);
                    review.setUsername(rs.getString("username"));
                    list.add(review);
                }
            }
        } catch (SQLException e) {
            System.err.println("[BookReviewDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /** 添加评论 */
    public boolean addReview(long bookId, String userId, String content) throws ClassNotFoundException {
        String sql = "INSERT INTO book_review (book_id, user_id, content) VALUES (?, ?, ?)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId);
            ps.setString(2, userId);
            ps.setString(3, content);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[BookReviewDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /** 删除评论 */
    public boolean deleteReview(int reviewId) throws ClassNotFoundException {
        String sql = "DELETE FROM book_review WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[BookReviewDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /** 从ResultSet提取BookReview对象 */
    private BookReview extractBookReview(ResultSet rs) throws SQLException {
        BookReview review = new BookReview();
        review.setId(rs.getInt("id"));
        review.setBookId(rs.getLong("book_id"));
        review.setUserId(rs.getString("user_id"));
        review.setContent(rs.getString("content"));
        review.setCreatedAt(rs.getTimestamp("created_at"));
        return review;
    }
}
