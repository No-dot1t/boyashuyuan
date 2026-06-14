/**
 * ===========================================================================
 * AlumniDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getAllActiveAlumni()               查询操作
 * getHonoraryAlumni()                查询操作
 * getAlumniById(int id)              查询操作
 * addAlumni(Alumni alumni)           新增操作
 * executeUpdate(sql, alumni, false)  内部工具方法
 * updateAlumni(Alumni alumni)        更新操作
 * deleteAlumni(int id)               删除操作
 * executeQuery(String sql, ArrayList<Alumni> list, Object ignored)内部工具方法
 * extractAlumni(ResultSet rs)        数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   alumniList = new ArrayList<>()
 *   sql = "SELECT * FROM alumni WHERE is_active = 1 ORDER BY is_honorary DESC, sort_order ASC"
 *   alumniList = new ArrayList<>()
 *   sql = "SELECT * FROM alumni WHERE is_honorary = 1 AND is_active = 1 ORDER BY sort_order ASC"
 *   alumni = null
 *   sql = "SELECT * FROM alumni WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id)
 *   rs = ps.executeQuery()) {
                if (rs.next()) alumni = extractAlumni(rs)
 *   sql = "INSERT INTO alumni (name, title, achievement, avatar_url, company, "
                   + "graduation_year, major, is_honorary, sort_order, is_active) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
 *   sql = "UPDATE alumni SET name=?, title=?, achievement=?, avatar_url=?, "
                   + "company=?, graduation_year=?, major=?, is_honorary=?, sort_order=?, is_active=? WHERE id=?"
 *   sql = "DELETE FROM alumni WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id)
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) list.add(extractAlumni(rs))
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, alumni.getName())
 *   a = new Alumni()
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
import com.ebookBuy301.pojo.Alumni;

import java.sql.*;
import java.util.ArrayList;

/**
 * =============================================================================
 * AlumniDao —— 校友数据访问层
 * =============================================================================
 *
 * 负责 alumni 表的增删改查操作。
 *
 * 方法索引：
 *   1. getAllActiveAlumni()  → 获取所有活跃校友
 *   2. getHonoraryAlumni()   → 获取荣誉校友
 *   3. getAlumniById()       → 根据ID查询
 *   4. addAlumni()           → 添加校友
 *   5. updateAlumni()        → 更新校友
 *   6. deleteAlumni()        → 删除校友
 * =============================================================================
 */
public class AlumniDao {

    /** 获取所有活跃校友（荣誉校友优先、按排序序号排列） */
    public ArrayList<Alumni> getAllActiveAlumni() throws ClassNotFoundException {
        ArrayList<Alumni> alumniList = new ArrayList<>();
        String sql = "SELECT * FROM alumni WHERE is_active = 1 ORDER BY is_honorary DESC, sort_order ASC";
        executeQuery(sql, alumniList, null);
        return alumniList;
    }

    /** 获取荣誉校友列表 */
    public ArrayList<Alumni> getHonoraryAlumni() throws ClassNotFoundException {
        ArrayList<Alumni> alumniList = new ArrayList<>();
        String sql = "SELECT * FROM alumni WHERE is_honorary = 1 AND is_active = 1 ORDER BY sort_order ASC";
        executeQuery(sql, alumniList, null);
        return alumniList;
    }

    /** 根据ID查询校友 */
    public Alumni getAlumniById(int id) throws ClassNotFoundException {
        Alumni alumni = null;
        String sql = "SELECT * FROM alumni WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) alumni = extractAlumni(rs);
            }
        } catch (SQLException e) {
            System.err.println("[AlumniDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return alumni;
    }

    /** 添加校友 */
    public boolean addAlumni(Alumni alumni) throws ClassNotFoundException {
        String sql = "INSERT INTO alumni (name, title, achievement, avatar_url, company, "
                   + "graduation_year, major, is_honorary, sort_order, is_active) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        return executeUpdate(sql, alumni, false);
    }

    /** 更新校友 */
    public boolean updateAlumni(Alumni alumni) throws ClassNotFoundException {
        String sql = "UPDATE alumni SET name=?, title=?, achievement=?, avatar_url=?, "
                   + "company=?, graduation_year=?, major=?, is_honorary=?, sort_order=?, is_active=? WHERE id=?";
        return executeUpdate(sql, alumni, true);
    }

    /** 删除校友 */
    public boolean deleteAlumni(int id) throws ClassNotFoundException {
        String sql = "DELETE FROM alumni WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[AlumniDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    private void executeQuery(String sql, ArrayList<Alumni> list, Object ignored) {
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(extractAlumni(rs));
        } catch (Exception e) {
            System.err.println("[AlumniDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
    }

    private boolean executeUpdate(String sql, Alumni alumni, boolean isUpdate) {
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, alumni.getName());
            ps.setString(2, alumni.getTitle());
            ps.setString(3, alumni.getAchievement());
            ps.setString(4, alumni.getAvatarUrl());
            ps.setString(5, alumni.getCompany());
            ps.setObject(6, alumni.getGraduationYear());
            ps.setString(7, alumni.getMajor());
            ps.setBoolean(8, alumni.isHonorary());
            ps.setInt(9, alumni.getSortOrder());
            ps.setBoolean(10, alumni.isActive());
            if (isUpdate) ps.setInt(11, alumni.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("[AlumniDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 关键词搜索校友（匹配姓名、职称、成就、专业、公司、毕业年份）
     * @param keyword 搜索关键词
     * @return 匹配的校友列表（最多20条）
     */
    public ArrayList<Alumni> searchAlumni(String keyword) throws ClassNotFoundException {
        ArrayList<Alumni> list = new ArrayList<>();
        String sql = "SELECT * FROM alumni WHERE is_active = 1 AND "
                   + "(name LIKE ? OR title LIKE ? OR achievement LIKE ? OR "
                   + "major LIKE ? OR company LIKE ?) ORDER BY is_honorary DESC, sort_order ASC LIMIT 20";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String pattern = "%" + keyword + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            ps.setString(3, pattern);
            ps.setString(4, pattern);
            ps.setString(5, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(extractAlumni(rs));
            }
        } catch (SQLException e) {
            System.err.println("[AlumniDao] 搜索错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    private Alumni extractAlumni(ResultSet rs) throws SQLException {
        Alumni a = new Alumni();
        a.setId(rs.getInt("id"));
        a.setName(rs.getString("name"));
        a.setTitle(rs.getString("title"));
        a.setAchievement(rs.getString("achievement"));
        a.setAvatarUrl(rs.getString("avatar_url"));
        a.setCompany(rs.getString("company"));
        a.setGraduationYear(rs.getObject("graduation_year", Integer.class));
        a.setMajor(rs.getString("major"));
        a.setHonorary(rs.getBoolean("is_honorary"));
        a.setSortOrder(rs.getInt("sort_order"));
        a.setActive(rs.getBoolean("is_active"));
        return a;
    }
}
