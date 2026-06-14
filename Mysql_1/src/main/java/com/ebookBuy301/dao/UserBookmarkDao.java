/**
 * ===========================================================================
 * UserBookmarkDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * isBookmarked(String userId, long bookId)内部工具方法
 * toggleBookmark(String userId, long bookId)内部工具方法
 * getBookmarksByUserId(String userId)查询操作
 * extractUserBookmark(ResultSet rs)  数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   sql = "SELECT COUNT(*) AS cnt FROM user_bookmark WHERE user_id = ? AND book_id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt") > 0
 *   sql = "DELETE FROM user_bookmark WHERE user_id = ? AND book_id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
                ps.setString(1, userId)
 *   sql = "INSERT INTO user_bookmark (user_id, book_id) VALUES (?, ?)"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
                ps.setString(1, userId)
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM user_bookmark WHERE user_id = ? ORDER BY created_at DESC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractUserBookmark(rs))
 *   bm = new UserBookmark()
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
import com.ebookBuy301.pojo.UserBookmark;

import java.sql.*;
import java.util.ArrayList;

/**
 * =============================================================================
 * UserBookmarkDao —— 用户收藏数据访问层
 * =============================================================================
 *
 * 负责 user_bookmark 表的增删改查操作。
 *
 * 方法索引：
 *   1. isBookmarked()         → 检查是否已收藏
 *   2. toggleBookmark()       → 切换收藏状态
 *   3. getBookmarksByUserId() → 获取用户收藏列表
 * =============================================================================
 */
public class UserBookmarkDao {

    /** 检查是否已收藏 */
    public boolean isBookmarked(String userId, long bookId) throws ClassNotFoundException {
        String sql = "SELECT COUNT(*) AS cnt FROM user_bookmark WHERE user_id = ? AND book_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setLong(2, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt") > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserBookmarkDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /** 切换收藏状态（已收藏则取消，否则添加）。返回切换后是否收藏 */
    public boolean toggleBookmark(String userId, long bookId) throws ClassNotFoundException {
        if (isBookmarked(userId, bookId)) {
            // 已收藏，取消
            String sql = "DELETE FROM user_bookmark WHERE user_id = ? AND book_id = ?";
            try (Connection conn = DBManager.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, userId);
                ps.setLong(2, bookId);
                ps.executeUpdate();
            } catch (SQLException e) {
                System.err.println("[UserBookmarkDao] SQL错误：" + e.getMessage());
                e.printStackTrace();
            }
            return false;
        } else {
            // 未收藏，添加
            String sql = "INSERT INTO user_bookmark (user_id, book_id) VALUES (?, ?)";
            try (Connection conn = DBManager.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, userId);
                ps.setLong(2, bookId);
                ps.executeUpdate();
            } catch (SQLException e) {
                System.err.println("[UserBookmarkDao] SQL错误：" + e.getMessage());
                e.printStackTrace();
            }
            return true;
        }
    }

    /** 获取用户收藏列表 */
    public ArrayList<UserBookmark> getBookmarksByUserId(String userId) throws ClassNotFoundException {
        ArrayList<UserBookmark> list = new ArrayList<>();
        String sql = "SELECT * FROM user_bookmark WHERE user_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractUserBookmark(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserBookmarkDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /** 从ResultSet提取UserBookmark对象 */
    private UserBookmark extractUserBookmark(ResultSet rs) throws SQLException {
        UserBookmark bm = new UserBookmark();
        bm.setId(rs.getInt("id"));
        bm.setUserId(rs.getString("user_id"));
        bm.setBookId(rs.getLong("book_id"));
        bm.setCreatedAt(rs.getTimestamp("created_at"));
        return bm;
    }
}
