/**
 * ===========================================================================
 * BookRatingDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getAverageRating(long bookId)      查询操作
 * getUserRating(long bookId, String userId)查询操作
 * rateBook(long bookId, String userId, int rating)内部工具方法
 * getRatingsByBookId(long bookId)    查询操作
 * extractBookRating(ResultSet rs)    数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   result = new HashMap<>()
 *   sql = "SELECT COALESCE(AVG(rating), 0) AS avg_rating, COUNT(*) AS rating_count "
                   + "FROM book_rating WHERE book_id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId)
 *   rs = ps.executeQuery()) {
                if (rs.next()) {
                    result.put("avgRating", Math.round(rs.getDouble("avg_rating") * 10.0) / 10.0)
 *   rating = null
 *   sql = "SELECT * FROM book_rating WHERE book_id = ? AND user_id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId)
 *   rs = ps.executeQuery()) {
                if (rs.next()) {
                    rating = extractBookRating(rs)
 *   sql = "INSERT INTO book_rating (book_id, user_id, rating) VALUES (?, ?, ?) "
                   + "ON DUPLICATE KEY UPDATE rating = VALUES(rating)"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId)
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM book_rating WHERE book_id = ? ORDER BY created_at DESC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId)
 *   rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractBookRating(rs))
 *   br = new BookRating()
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
import com.ebookBuy301.pojo.BookRating;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * =============================================================================
 * BookRatingDao —— 图书评分数据访问层
 * =============================================================================
 *
 * 负责 book_rating 表的增删改查操作。
 *
 * 方法索引：
 *   1. getAverageRating()   → 获取图书平均评分
 *   2. getUserRating()      → 获取用户对某书的评分
 *   3. rateBook()           → 评分（INSERT ON DUPLICATE KEY UPDATE）
 *   4. getRatingsByBookId() → 获取图书所有评分
 * =============================================================================
 */
public class BookRatingDao {

    /** 获取图书平均评分，返回含avgRating和ratingCount的Map */
    public Map<String, Object> getAverageRating(long bookId) throws ClassNotFoundException {
        Map<String, Object> result = new HashMap<>();
        result.put("avgRating", 0.0);
        result.put("ratingCount", 0);
        String sql = "SELECT COALESCE(AVG(rating), 0) AS avg_rating, COUNT(*) AS rating_count "
                   + "FROM book_rating WHERE book_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    result.put("avgRating", Math.round(rs.getDouble("avg_rating") * 10.0) / 10.0);
                    result.put("ratingCount", rs.getInt("rating_count"));
                }
            }
        } catch (SQLException e) {
            System.err.println("[BookRatingDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    /** 获取用户对某书的评分（未评分返回null） */
    public BookRating getUserRating(long bookId, String userId) throws ClassNotFoundException {
        BookRating rating = null;
        String sql = "SELECT * FROM book_rating WHERE book_id = ? AND user_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId);
            ps.setString(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    rating = extractBookRating(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[BookRatingDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return rating;
    }

    /** 评分（INSERT ON DUPLICATE KEY UPDATE，已评分则更新） */
    public boolean rateBook(long bookId, String userId, int rating) throws ClassNotFoundException {
        String sql = "INSERT INTO book_rating (book_id, user_id, rating) VALUES (?, ?, ?) "
                   + "ON DUPLICATE KEY UPDATE rating = VALUES(rating)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId);
            ps.setString(2, userId);
            ps.setInt(3, rating);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[BookRatingDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /** 获取图书所有评分 */
    public ArrayList<BookRating> getRatingsByBookId(long bookId) throws ClassNotFoundException {
        ArrayList<BookRating> list = new ArrayList<>();
        String sql = "SELECT * FROM book_rating WHERE book_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractBookRating(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[BookRatingDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /** 从ResultSet提取BookRating对象 */
    private BookRating extractBookRating(ResultSet rs) throws SQLException {
        BookRating br = new BookRating();
        br.setId(rs.getInt("id"));
        br.setBookId(rs.getLong("book_id"));
        br.setUserId(rs.getString("user_id"));
        br.setRating(rs.getInt("rating"));
        br.setCreatedAt(rs.getTimestamp("created_at"));
        br.setUpdatedAt(rs.getTimestamp("updated_at"));
        return br;
    }
}
