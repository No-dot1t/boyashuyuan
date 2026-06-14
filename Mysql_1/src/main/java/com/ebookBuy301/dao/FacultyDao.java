/**
 * ===========================================================================
 * FacultyDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getAllActiveFaculty()              查询操作
 * getFacultyByDepartment(String department)查询操作
 * getFacultyById(int id)             查询操作
 * addFaculty(Faculty faculty)        新增操作
 * updateFaculty(Faculty faculty)     更新操作
 * deleteFaculty(int id)              删除操作
 * extractFaculty(ResultSet rs)       数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM faculty WHERE is_active = 1 ORDER BY sort_order ASC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) list.add(extractFaculty(rs))
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM faculty WHERE department = ? AND is_active = 1 ORDER BY sort_order ASC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, department)
 *   rs = ps.executeQuery()) {
                while (rs.next()) list.add(extractFaculty(rs))
 *   faculty = null
 *   sql = "SELECT * FROM faculty WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id)
 *   rs = ps.executeQuery()) {
                if (rs.next()) faculty = extractFaculty(rs)
 *   sql = "INSERT INTO faculty (name, title, avatar_icon, research_area, department, "
                   + "email, office, office_hours, bio, sort_order, is_active) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, faculty.getName())
 *   sql = "UPDATE faculty SET name=?, title=?, avatar_icon=?, research_area=?, "
                   + "department=?, email=?, office=?, office_hours=?, bio=?, sort_order=?, is_active=? WHERE id=?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, faculty.getName())
 *   sql = "DELETE FROM faculty WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id)
 *   f = new Faculty()
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
import com.ebookBuy301.pojo.Faculty;

import java.sql.*;
import java.util.ArrayList;

/**
 * =============================================================================
 * FacultyDao —— 导师（师资）数据访问层
 * =============================================================================
 *
 * 负责 faculty 表的增删改查操作。
 *
 * 方法索引：
 *   1. getAllActiveFaculty()       → 获取所有活跃导师
 *   2. getFacultyByDepartment()    → 按系别查询
 *   3. getFacultyById()            → 根据ID查询
 *   4. addFaculty()                → 添加导师
 *   5. updateFaculty()             → 更新导师
 *   6. deleteFaculty()             → 删除导师
 * =============================================================================
 */
public class FacultyDao {

    /**
     * 获取所有活跃（is_active=1）的导师记录。
     * <p>
     * 算法：SELECT * FROM faculty WHERE is_active=1 → 遍历 ResultSet → extractFaculty() 逐行提取
     *
     * @return ArrayList<Faculty> 导师列表（按sort_order升序排序）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<Faculty> getAllActiveFaculty() throws ClassNotFoundException {
        ArrayList<Faculty> list = new ArrayList<>();
        String sql = "SELECT * FROM faculty WHERE is_active = 1 ORDER BY sort_order ASC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(extractFaculty(rs));
        } catch (SQLException e) {
            System.err.println("[FacultyDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * 按系别查询活跃（is_active=1）的导师记录。
     * <p>
     * 算法：PreparedStatement 参数化查询 → 遍历 ResultSet → extractFaculty() 逐行提取
     *
     * @param department 系别名
     * @return ArrayList<Faculty> 导师列表（按sort_order升序排序）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<Faculty> getFacultyByDepartment(String department) throws ClassNotFoundException {
        ArrayList<Faculty> list = new ArrayList<>();
        String sql = "SELECT * FROM faculty WHERE department = ? AND is_active = 1 ORDER BY sort_order ASC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, department);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(extractFaculty(rs));
            }
        } catch (SQLException e) {
            System.err.println("[FacultyDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * 根据导师ID查询单个导师记录。
     * <p>
     * 算法：PreparedStatement 参数化查询 → extractFaculty() 提取单行
     *
     * @param id 导师ID
     * @return Faculty 导师对象；未找到返回 null
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public Faculty getFacultyById(int id) throws ClassNotFoundException {
        Faculty faculty = null;
        String sql = "SELECT * FROM faculty WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) faculty = extractFaculty(rs);
            }
        } catch (SQLException e) {
            System.err.println("[FacultyDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return faculty;
    }

    /**
     * 添加新导师记录。
     * <p>
     * 算法：INSERT INTO faculty → PreparedStatement 设置11个字段 → executeUpdate() > 0
     *
     * @param faculty 待添加的Faculty对象
     * @return boolean true=添加成功，false=添加失败
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public boolean addFaculty(Faculty faculty) throws ClassNotFoundException {
        String sql = "INSERT INTO faculty (name, title, avatar_icon, research_area, department, "
                   + "email, office, office_hours, bio, sort_order, is_active) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, faculty.getName());
            ps.setString(2, faculty.getTitle());
            ps.setString(3, faculty.getAvatarIcon());
            ps.setString(4, faculty.getResearchArea());
            ps.setString(5, faculty.getDepartment());
            ps.setString(6, faculty.getEmail());
            ps.setString(7, faculty.getOffice());
            ps.setString(8, faculty.getOfficeHours());
            ps.setString(9, faculty.getBio());
            ps.setInt(10, faculty.getSortOrder());
            ps.setBoolean(11, faculty.isActive());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[FacultyDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 更新已有导师记录。
     * <p>
     * 算法：UPDATE faculty SET 11个字段 → PreparedStatement 设置字段+WHERE条件 → executeUpdate() > 0
     *
     * @param faculty 待更新的Faculty对象（id为必填定位条件）
     * @return boolean true=更新成功，false=更新失败
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public boolean updateFaculty(Faculty faculty) throws ClassNotFoundException {
        String sql = "UPDATE faculty SET name=?, title=?, avatar_icon=?, research_area=?, "
                   + "department=?, email=?, office=?, office_hours=?, bio=?, sort_order=?, is_active=? WHERE id=?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, faculty.getName());
            ps.setString(2, faculty.getTitle());
            ps.setString(3, faculty.getAvatarIcon());
            ps.setString(4, faculty.getResearchArea());
            ps.setString(5, faculty.getDepartment());
            ps.setString(6, faculty.getEmail());
            ps.setString(7, faculty.getOffice());
            ps.setString(8, faculty.getOfficeHours());
            ps.setString(9, faculty.getBio());
            ps.setInt(10, faculty.getSortOrder());
            ps.setBoolean(11, faculty.isActive());
            ps.setInt(12, faculty.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[FacultyDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 根据导师ID删除导师记录。
     * <p>
     * 算法：DELETE FROM faculty WHERE id=? → PreparedStatement 设置参数 → executeUpdate() > 0
     *
     * @param id 待删除的导师ID
     * @return boolean true=删除成功，false=删除失败
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public boolean deleteFaculty(int id) throws ClassNotFoundException {
        String sql = "DELETE FROM faculty WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[FacultyDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 关键词搜索活跃（is_active=1）的导师记录。
     * <p>
     * 算法：PreparedStatement 模糊匹配 name/title/research_area/department/bio → 遍历 ResultSet → extractFaculty() 逐行提取
     *
     * @param keyword 搜索关键词（自动包裹为 %keyword%，最多返回20条）
     * @return ArrayList<Faculty> 匹配的导师列表（按sort_order升序排序）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<Faculty> searchFaculty(String keyword) throws ClassNotFoundException {
        ArrayList<Faculty> list = new ArrayList<>();
        String sql = "SELECT * FROM faculty WHERE is_active = 1 AND "
                   + "(name LIKE ? OR title LIKE ? OR research_area LIKE ? OR "
                   + "department LIKE ? OR bio LIKE ?) ORDER BY sort_order ASC LIMIT 20";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String pattern = "%" + keyword + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            ps.setString(3, pattern);
            ps.setString(4, pattern);
            ps.setString(5, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(extractFaculty(rs));
            }
        } catch (SQLException e) {
            System.err.println("[FacultyDao] 搜索错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  从 ResultSet 提取 Faculty 对象
    //   步骤：rs.getInt("id") → new Faculty() → setXxx()
    // ═════════════════════════════════════════════════════════════════════
    private Faculty extractFaculty(ResultSet rs) throws SQLException {
        Faculty f = new Faculty();
        f.setId(rs.getInt("id"));
        f.setName(rs.getString("name"));
        f.setTitle(rs.getString("title"));
        f.setAvatarIcon(rs.getString("avatar_icon"));
        f.setResearchArea(rs.getString("research_area"));
        f.setDepartment(rs.getString("department"));
        f.setEmail(rs.getString("email"));
        f.setOffice(rs.getString("office"));
        f.setOfficeHours(rs.getString("office_hours"));
        f.setBio(rs.getString("bio"));
        f.setSortOrder(rs.getInt("sort_order"));
        f.setActive(rs.getBoolean("is_active"));
        return f;
    }
}
