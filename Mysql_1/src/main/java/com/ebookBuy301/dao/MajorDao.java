/**
 * ===========================================================================
 * MajorDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getAllActiveMajors()               查询操作
 * getMajorsByCategory(String category)查询操作
 * getMajorById(int id)               查询操作
 * addMajor(Major major)              新增操作
 * updateMajor(Major major)           更新操作
 * deleteMajor(int id)                删除操作
 * extractMajor(ResultSet rs)         数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM major WHERE is_active = 1 ORDER BY sort_order ASC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) list.add(extractMajor(rs))
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM major WHERE category = ? AND is_active = 1 ORDER BY sort_order ASC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, category)
 *   rs = ps.executeQuery()) {
                while (rs.next()) list.add(extractMajor(rs))
 *   major = null
 *   sql = "SELECT * FROM major WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id)
 *   rs = ps.executeQuery()) {
                if (rs.next()) major = extractMajor(rs)
 *   sql = "INSERT INTO major (name, code, icon, description, category, "
                   + "is_interdisciplinary, department, degree_type, duration, sort_order, is_active) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, major.getName())
 *   sql = "UPDATE major SET name=?, code=?, icon=?, description=?, category=?, "
                   + "is_interdisciplinary=?, department=?, degree_type=?, duration=?, "
                   + "sort_order=?, is_active=? WHERE id=?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, major.getName())
 *   sql = "DELETE FROM major WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id)
 *   m = new Major()
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
import com.ebookBuy301.pojo.Major;

import java.sql.*;
import java.util.ArrayList;

/**
 * =============================================================================
 * MajorDao —— 学域（专业）数据访问层
 * =============================================================================
 *
 * 负责 major 表的增删改查操作。
 *
 * 方法索引：
 *   1. getAllActiveMajors()  → 获取所有活跃学域
 *   2. getMajorsByCategory() → 按分类查询
 *   3. getMajorById()       → 根据ID查询
 *   4. addMajor()           → 添加学域
 *   5. updateMajor()        → 更新学域
 *   6. deleteMajor()        → 删除学域
 * =============================================================================
 */
public class MajorDao {

    /**
     * 确保 major 和 major_book_type 表存在（CREATE TABLE IF NOT EXISTS）。
     * <p>
     * 算法：CREATE TABLE IF NOT EXISTS major + major_book_type → Statement.executeUpdate()
     *
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public void ensureTableExists() {
        String createMajor = "CREATE TABLE IF NOT EXISTS major ("
                           + "id INT AUTO_INCREMENT PRIMARY KEY, "
                           + "name VARCHAR(255) NOT NULL, "
                           + "code VARCHAR(100) NOT NULL, "
                           + "icon VARCHAR(255) DEFAULT NULL, "
                           + "description TEXT DEFAULT NULL, "
                           + "category VARCHAR(100) DEFAULT NULL, "
                           + "is_interdisciplinary TINYINT(1) DEFAULT 0, "
                           + "department VARCHAR(255) DEFAULT NULL, "
                           + "degree_type VARCHAR(100) DEFAULT NULL, "
                           + "duration INT DEFAULT 4, "
                           + "sort_order INT DEFAULT 0, "
                           + "is_active TINYINT(1) DEFAULT 1"
                           + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

        String createMajorBookType = "CREATE TABLE IF NOT EXISTS major_book_type ("
                                   + "id BIGINT AUTO_INCREMENT PRIMARY KEY, "
                                   + "major_code VARCHAR(100) NOT NULL, "
                                   + "book_type_id VARCHAR(50) NOT NULL, "
                                   + "INDEX idx_major_code (major_code), "
                                   + "INDEX idx_book_type_id (book_type_id)"
                                   + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

        try (Connection conn = DBManager.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(createMajor);
            stmt.executeUpdate(createMajorBookType);
            System.out.println("[MajorDao] 表已确认存在：major, major_book_type");
        } catch (Exception e) {
            System.err.println("[MajorDao] 建表失败：" + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 获取所有活跃（is_active=1）的学域（专业）记录。
     * <p>
     * 算法：SELECT * FROM major WHERE is_active=1 → 遍历 ResultSet → extractMajor() 逐行提取
     *
     * @return ArrayList<Major> 学域列表（按sort_order升序排序）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<Major> getAllActiveMajors() throws ClassNotFoundException {
        ensureTableExists();
        ArrayList<Major> list = new ArrayList<>();
        String sql = "SELECT * FROM major WHERE is_active = 1 ORDER BY sort_order ASC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(extractMajor(rs));
        } catch (SQLException e) {
            System.err.println("[MajorDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * 按分类查询活跃（is_active=1）的学域（专业）记录。
     * <p>
     * 算法：PreparedStatement 参数化查询 → 遍历 ResultSet → extractMajor() 逐行提取
     *
     * @param category 学域分类名称
     * @return ArrayList<Major> 学域列表（按sort_order升序排序）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<Major> getMajorsByCategory(String category) throws ClassNotFoundException {
        ArrayList<Major> list = new ArrayList<>();
        String sql = "SELECT * FROM major WHERE category = ? AND is_active = 1 ORDER BY sort_order ASC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(extractMajor(rs));
            }
        } catch (SQLException e) {
            System.err.println("[MajorDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * 根据学域（专业）ID查询单个记录。
     * <p>
     * 算法：PreparedStatement 参数化查询 → extractMajor() 提取单行
     *
     * @param id 学域ID
     * @return Major 学域对象；未找到返回 null
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public Major getMajorById(int id) throws ClassNotFoundException {
        Major major = null;
        String sql = "SELECT * FROM major WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) major = extractMajor(rs);
            }
        } catch (SQLException e) {
            System.err.println("[MajorDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return major;
    }

    /**
     * 添加新学域（专业）记录。
     * <p>
     * 算法：INSERT INTO major → PreparedStatement 设置11个字段 → executeUpdate() > 0
     *
     * @param major 待添加的Major对象
     * @return boolean true=添加成功，false=添加失败
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public boolean addMajor(Major major) throws ClassNotFoundException {
        String sql = "INSERT INTO major (name, code, icon, description, category, "
                   + "is_interdisciplinary, department, degree_type, duration, sort_order, is_active) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, major.getName());
            ps.setString(2, major.getCode());
            ps.setString(3, major.getIcon());
            ps.setString(4, major.getDescription());
            ps.setString(5, major.getCategory());
            ps.setBoolean(6, major.isInterdisciplinary());
            ps.setString(7, major.getDepartment());
            ps.setString(8, major.getDegreeType());
            ps.setInt(9, major.getDuration());
            ps.setInt(10, major.getSortOrder());
            ps.setBoolean(11, major.isActive());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[MajorDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 更新已有学域（专业）记录。
     * <p>
     * 算法：UPDATE major SET 11个字段 → PreparedStatement 设置字段+WHERE条件 → executeUpdate() > 0
     *
     * @param major 待更新的Major对象（id为必填定位条件）
     * @return boolean true=更新成功，false=更新失败
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public boolean updateMajor(Major major) throws ClassNotFoundException {
        String sql = "UPDATE major SET name=?, code=?, icon=?, description=?, category=?, "
                   + "is_interdisciplinary=?, department=?, degree_type=?, duration=?, "
                   + "sort_order=?, is_active=? WHERE id=?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, major.getName());
            ps.setString(2, major.getCode());
            ps.setString(3, major.getIcon());
            ps.setString(4, major.getDescription());
            ps.setString(5, major.getCategory());
            ps.setBoolean(6, major.isInterdisciplinary());
            ps.setString(7, major.getDepartment());
            ps.setString(8, major.getDegreeType());
            ps.setInt(9, major.getDuration());
            ps.setInt(10, major.getSortOrder());
            ps.setBoolean(11, major.isActive());
            ps.setInt(12, major.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[MajorDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 根据学域（专业）ID删除记录。
     * <p>
     * 算法：DELETE FROM major WHERE id=? → PreparedStatement 设置参数 → executeUpdate() > 0
     *
     * @param id 待删除的学域ID
     * @return boolean true=删除成功，false=删除失败
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public boolean deleteMajor(int id) throws ClassNotFoundException {
        String sql = "DELETE FROM major WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[MajorDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ════════════════════════════════════════════════════════════════════
    //  从 ResultSet 提取 Major 对象
    //   步骤：rs.getInt("id") → new Major() → setXxx()
    // ════════════════════════════════════════════════════════════════════
    private Major extractMajor(ResultSet rs) throws SQLException {
        Major m = new Major();
        m.setId(rs.getInt("id"));
        m.setName(rs.getString("name"));
        m.setCode(rs.getString("code"));
        m.setIcon(rs.getString("icon"));
        m.setDescription(rs.getString("description"));
        m.setCategory(rs.getString("category"));
        m.setInterdisciplinary(rs.getBoolean("is_interdisciplinary"));
        m.setDepartment(rs.getString("department"));
        m.setDegreeType(rs.getString("degree_type"));
        m.setDuration(rs.getInt("duration"));
        m.setSortOrder(rs.getInt("sort_order"));
        m.setActive(rs.getBoolean("is_active"));
        return m;
    }
}
