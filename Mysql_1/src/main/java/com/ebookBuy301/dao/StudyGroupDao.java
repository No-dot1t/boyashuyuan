/**
 * ===========================================================================
 * StudyGroupDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getAllActiveGroups()               查询操作
 * getGroupsByUserId(String userId)   查询操作
 * getGroupsWithUserStatus(String userId)查询操作
 * joinGroup(int groupId, String userId)内部工具方法
 * leaveGroup(int groupId, String userId)内部工具方法
 * createGroup(String name, String icon, String desc, String creatorId)新增操作
 * updateMemberCount(int groupId)     更新操作
 * extractStudyGroup(ResultSet rs)    数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM study_group WHERE is_active = 1 ORDER BY created_at DESC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(extractStudyGroup(rs))
 *   list = new ArrayList<>()
 *   sql = "SELECT sg.* FROM study_group sg "
                   + "INNER JOIN study_group_member sgm ON sg.id = sgm.group_id "
                   + "WHERE sgm.user_id = ? AND sg.is_active = 1 ORDER BY sg.created_at DESC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractStudyGroup(rs))
 *   list = new ArrayList<>()
 *   joinedIds = new HashSet<>()
 *   joinSql = "SELECT group_id FROM study_group_member WHERE user_id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(joinSql)) {
            ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                while (rs.next()) {
                    joinedIds.add(rs.getInt("group_id"))
 *   sql = "SELECT * FROM study_group WHERE is_active = 1 ORDER BY created_at DESC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) {
                StudyGroup g = extractStudyGroup(rs)
 *   sql = "INSERT IGNORE INTO study_group_member (group_id, user_id) VALUES (?, ?)"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId)
 *   rows = ps.executeUpdate()
 *   sql = "DELETE FROM study_group_member WHERE group_id = ? AND user_id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId)
 *   rows = ps.executeUpdate()
 *   sql = "INSERT INTO study_group (name, icon, description, creator_id, member_count) VALUES (?, ?, ?, ?, 1)"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, name)
 *   rows = ps.executeUpdate()
 *   rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int newId = rs.getInt(1)
 *   sql = "UPDATE study_group SET member_count = "
                   + "(SELECT COUNT(*) FROM study_group_member WHERE group_id = ?) "
                   + "WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId)
 *   group = new StudyGroup()
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
import com.ebookBuy301.pojo.StudyGroup;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashSet;

/**
 * =============================================================================
 * StudyGroupDao —— 学习小组数据访问层
 * =============================================================================
 *
 * 负责 study_group 和 study_group_member 表的增删改查操作。
 *
 * 方法索引：
 *   1. getAllActiveGroups()   → 获取所有活跃小组
 *   2. getGroupsByUserId()    → 获取用户已加入的小组
 *   3. getGroupsWithUserStatus() → 获取所有小组（标记joined状态）
 *   4. joinGroup()            → 加入小组
 *   4. leaveGroup()           → 退出小组
 *   5. createGroup()          → 创建小组（返回新ID）
 *   6. updateMemberCount()    → 重新统计成员数
 * =============================================================================
 */
public class StudyGroupDao {

    /** 获取所有活跃小组 */
    public ArrayList<StudyGroup> getAllActiveGroups() throws SQLException {
        ArrayList<StudyGroup> list = new ArrayList<>();
        String sql = "SELECT * FROM study_group WHERE is_active = 1 ORDER BY created_at DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(extractStudyGroup(rs));
            }
        }
        return list;
    }

    /** 获取用户已加入的小组 */
    public ArrayList<StudyGroup> getGroupsByUserId(String userId) throws SQLException {
        ArrayList<StudyGroup> list = new ArrayList<>();
        String sql = "SELECT sg.* FROM study_group sg "
                   + "INNER JOIN study_group_member sgm ON sg.id = sgm.group_id "
                   + "WHERE sgm.user_id = ? AND sg.is_active = 1 ORDER BY sg.created_at DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractStudyGroup(rs));
                }
            }
        }
        return list;
    }

    /** 获取所有活跃小组，并标记当前用户是否已加入 */
    public ArrayList<StudyGroup> getGroupsWithUserStatus(String userId) throws SQLException {
        ArrayList<StudyGroup> list = new ArrayList<>();
        // 先获取用户已加入的小组ID集合
        HashSet<Integer> joinedIds = new HashSet<>();
        String joinSql = "SELECT group_id FROM study_group_member WHERE user_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(joinSql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    joinedIds.add(rs.getInt("group_id"));
                }
            }
        }
        // 获取所有活跃小组并标记joined状态
        String sql = "SELECT * FROM study_group WHERE is_active = 1 ORDER BY created_at DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                StudyGroup g = extractStudyGroup(rs);
                g.setJoined(joinedIds.contains(g.getId()));
                list.add(g);
            }
        }
        return list;
    }

    /** 加入小组 */
    public boolean joinGroup(int groupId, String userId) throws SQLException {
        String sql = "INSERT IGNORE INTO study_group_member (group_id, user_id) VALUES (?, ?)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ps.setString(2, userId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                updateMemberCount(groupId);
            }
            return rows > 0;
        }
    }

    /** 退出小组 */
    public boolean leaveGroup(int groupId, String userId) throws SQLException {
        String sql = "DELETE FROM study_group_member WHERE group_id = ? AND user_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ps.setString(2, userId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                updateMemberCount(groupId);
            }
            return rows > 0;
        }
    }

    /** 创建小组，返回新ID（失败返回-1） */
    public int createGroup(String name, String icon, String desc, String creatorId) throws SQLException {
        String sql = "INSERT INTO study_group (name, icon, description, creator_id, member_count) VALUES (?, ?, ?, ?, 1)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, name);
            ps.setString(2, icon);
            ps.setString(3, desc);
            ps.setString(4, creatorId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int newId = rs.getInt(1);
                        // 创建者自动加入小组
                        joinGroup(newId, creatorId);
                        return newId;
                    }
                }
                // 回退方案
                try (Statement st = conn.createStatement();
                     ResultSet rs2 = st.executeQuery("SELECT LAST_INSERT_ID()")) {
                    if (rs2.next()) {
                        int newId = rs2.getInt(1);
                        if (newId > 0) {
                            joinGroup(newId, creatorId);
                            return newId;
                        }
                    }
                }
            }
            return -1;
        }
    }

    /** 重新统计成员数 */
    public void updateMemberCount(int groupId) throws SQLException {
        String sql = "UPDATE study_group SET member_count = "
                   + "(SELECT COUNT(*) FROM study_group_member WHERE group_id = ?) "
                   + "WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ps.setInt(2, groupId);
            ps.executeUpdate();
        }
    }

    /** 从ResultSet提取StudyGroup对象 */
    private StudyGroup extractStudyGroup(ResultSet rs) throws SQLException {
        StudyGroup group = new StudyGroup();
        group.setId(rs.getInt("id"));
        group.setName(rs.getString("name"));
        group.setIcon(rs.getString("icon"));
        group.setDescription(rs.getString("description"));
        group.setCreatorId(rs.getString("creator_id"));
        group.setMemberCount(rs.getInt("member_count"));
        group.setCreatedAt(rs.getTimestamp("created_at"));
        group.setActive(rs.getBoolean("is_active"));
        return group;
    }
}
