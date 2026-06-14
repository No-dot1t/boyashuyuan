/**
 * ===========================================================================
 * CampusSceneDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getAllActiveScenes()               查询操作
 * getSceneByKey(String sceneKey)     查询操作
 * recordVisit(String userId, int sceneId)内部工具方法
 * getSceneVisitCount(int sceneId)    查询操作
 * getOnlineUserCount()               查询操作
 * extractCampusScene(ResultSet rs)   数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM campus_scene WHERE is_active = 1 ORDER BY sort_order ASC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(extractCampusScene(rs))
 *   scene = null
 *   sql = "SELECT * FROM campus_scene WHERE scene_key = ? AND is_active = 1"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, sceneKey)
 *   rs = ps.executeQuery()) {
                if (rs.next()) {
                    scene = extractCampusScene(rs)
 *   sql = "INSERT INTO user_scene_visit (user_id, scene_id) VALUES (?, ?)"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   sql = "SELECT COUNT(*) AS cnt FROM user_scene_visit WHERE scene_id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sceneId)
 *   rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt")
 *   sql = "SELECT COUNT(DISTINCT user_id) AS cnt FROM user_activity "
                   + "WHERE created_at >= DATE_SUB(NOW(), INTERVAL 5 MINUTE) AND user_id IS NOT NULL"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("cnt")
 *   scene = new CampusScene()
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
import com.ebookBuy301.pojo.CampusScene;

import java.sql.*;
import java.util.ArrayList;

/**
 * =============================================================================
 * CampusSceneDao —— 虚拟校园场景数据访问层
 * =============================================================================
 *
 * 负责 campus_scene 和 user_scene_visit 表的增删改查操作。
 *
 * 方法索引：
 *   1. getAllActiveScenes()  → 获取所有活跃场景
 *   2. getSceneByKey()       → 根据sceneKey查询场景
 *   3. recordVisit()         → 记录用户场景访问
 *   4. getSceneVisitCount()  → 获取场景访问次数
 *   5. getOnlineUserCount()  → 获取在线用户数（最近5分钟有活动）
 * =============================================================================
 */
public class CampusSceneDao {

    /** 获取所有活跃场景 */
    public ArrayList<CampusScene> getAllActiveScenes() throws ClassNotFoundException {
        ArrayList<CampusScene> list = new ArrayList<>();
        String sql = "SELECT * FROM campus_scene WHERE is_active = 1 ORDER BY sort_order ASC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(extractCampusScene(rs));
            }
        } catch (SQLException e) {
            System.err.println("[CampusSceneDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /** 根据sceneKey查询场景 */
    public CampusScene getSceneByKey(String sceneKey) throws ClassNotFoundException {
        CampusScene scene = null;
        String sql = "SELECT * FROM campus_scene WHERE scene_key = ? AND is_active = 1";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sceneKey);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    scene = extractCampusScene(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[CampusSceneDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return scene;
    }

    /** 记录用户场景访问 */
    public boolean recordVisit(String userId, int sceneId) throws ClassNotFoundException {
        String sql = "INSERT INTO user_scene_visit (user_id, scene_id) VALUES (?, ?)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setInt(2, sceneId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[CampusSceneDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /** 获取场景访问次数 */
    public int getSceneVisitCount(int sceneId) throws ClassNotFoundException {
        String sql = "SELECT COUNT(*) AS cnt FROM user_scene_visit WHERE scene_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sceneId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt");
                }
            }
        } catch (SQLException e) {
            System.err.println("[CampusSceneDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /** 获取在线用户数（最近5分钟有活动的用户数） */
    public int getOnlineUserCount() throws ClassNotFoundException {
        String sql = "SELECT COUNT(DISTINCT user_id) AS cnt FROM user_activity "
                   + "WHERE created_at >= DATE_SUB(NOW(), INTERVAL 5 MINUTE) AND user_id IS NOT NULL";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("cnt");
            }
        } catch (SQLException e) {
            System.err.println("[CampusSceneDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /** 从ResultSet提取CampusScene对象 */
    private CampusScene extractCampusScene(ResultSet rs) throws SQLException {
        CampusScene scene = new CampusScene();
        scene.setId(rs.getInt("id"));
        scene.setName(rs.getString("name"));
        scene.setSceneKey(rs.getString("scene_key"));
        scene.setIcon(rs.getString("icon"));
        scene.setDescription(rs.getString("description"));
        scene.setSceneType(rs.getString("scene_type"));
        scene.setFeatures(rs.getString("features"));
        scene.setActive(rs.getBoolean("is_active"));
        scene.setSortOrder(rs.getInt("sort_order"));
        scene.setCreatedAt(rs.getTimestamp("created_at"));
        return scene;
    }
}
