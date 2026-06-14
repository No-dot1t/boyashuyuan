/**
 * ===========================================================================
 * CourseDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getAllCourses()                    查询操作
 * getCoursesByCategory(String category)查询操作
 * getCoursesByLevel(String level)    查询操作
 * getCourseById(long id)             查询操作
 * addCourse(Course course)           新增操作
 * updateCourse(Course course)        更新操作
 * deleteCourse(long id)              删除操作
 * searchCourses(String keyword)      查询操作
 * extractCourse(ResultSet rs)        数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   courses = new ArrayList<>()
 *   sql = "SELECT * FROM course WHERE status = 'active' ORDER BY rating DESC, enrolled_count DESC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) courses.add(extractCourse(rs))
 *   courses = new ArrayList<>()
 *   sql = "SELECT * FROM course WHERE course_category = ? AND status = 'active' ORDER BY rating DESC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, category)
 *   rs = ps.executeQuery()) {
                while (rs.next()) courses.add(extractCourse(rs))
 *   courses = new ArrayList<>()
 *   sql = "SELECT * FROM course WHERE course_level = ? AND status = 'active' ORDER BY rating DESC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, level)
 *   rs = ps.executeQuery()) {
                while (rs.next()) courses.add(extractCourse(rs))
 *   course = null
 *   sql = "SELECT * FROM course WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id)
 *   rs = ps.executeQuery()) {
                if (rs.next()) course = extractCourse(rs)
 *   sql = "INSERT INTO course (course_name, course_category, course_level, instructor_id, "
                   + "instructor_name, course_hours, rating, enrolled_count, cover_image, description, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, course.getCourseName())
 *   sql = "UPDATE course SET course_name=?, course_category=?, course_level=?, "
                   + "instructor_id=?, instructor_name=?, course_hours=?, rating=?, "
                   + "enrolled_count=?, cover_image=?, description=?, status=? WHERE id=?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, course.getCourseName())
 *   sql = "DELETE FROM course WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id)
 *   courses = new ArrayList<>()
 *   sql = "SELECT * FROM course WHERE (course_name LIKE ? OR description LIKE ?) AND status = 'active'"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            String pattern = "%" + keyword + "%"
 *   rs = ps.executeQuery()) {
                while (rs.next()) courses.add(extractCourse(rs))
 *   c = new Course()
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
import com.ebookBuy301.pojo.Course;

import java.sql.*;
import java.util.ArrayList;

/**
 * =============================================================================
 * CourseDao —— 课程数据访问层
 * =============================================================================
 *
 * 负责 course 表的增删改查操作。
 *
 * 方法索引：
 * 1. getAllCourses() → 获取所有活跃课程
 * 2. getCoursesByCategory() → 按分类获取
 * 3. getCoursesByLevel() → 按难度级别获取
 * 4. getCourseById() → 根据ID查询
 * 5. addCourse() → 添加课程
 * 6. updateCourse() → 更新课程
 * 7. deleteCourse() → 删除课程
 * 8. searchCourses() → 关键词搜索
 * =============================================================================
 */
public class CourseDao {

    /**
     * 获取所有已发布（status='active'）的课程记录。
     * <p>
     * 算法：SELECT * FROM course WHERE status='active' → 遍历 ResultSet → extractCourse() 逐行提取
     *
     * @return ArrayList<Course> 课程列表（按评分降序、报名人数降序排序）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<Course> getAllCourses() throws ClassNotFoundException {
        ArrayList<Course> courses = new ArrayList<>();
        String sql = "SELECT * FROM course WHERE status = 'active' ORDER BY rating DESC, enrolled_count DESC";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                courses.add(extractCourse(rs));
        } catch (SQLException e) {
            System.err.println("[CourseDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return courses;
    }

    /**
     * 按课程分类查询已发布（status='active'）的课程记录。
     * <p>
     * 算法：PreparedStatement 参数化查询 → 遍历 ResultSet → extractCourse() 逐行提取
     *
     * @param category 课程分类名称
     * @return ArrayList<Course> 课程列表（按评分降序排序）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<Course> getCoursesByCategory(String category) throws ClassNotFoundException {
        ArrayList<Course> courses = new ArrayList<>();
        String sql = "SELECT * FROM course WHERE course_category = ? AND status = 'active' ORDER BY rating DESC";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    courses.add(extractCourse(rs));
            }
        } catch (SQLException e) {
            System.err.println("[CourseDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return courses;
    }

    /**
     * 按课程难度级别查询已发布（status='active'）的课程记录。
     * <p>
     * 算法：PreparedStatement 参数化查询 → 遍历 ResultSet → extractCourse() 逐行提取
     *
     * @param level 课程难度级别（如 beginner/intermediate/advanced）
     * @return ArrayList<Course> 课程列表（按评分降序排序）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<Course> getCoursesByLevel(String level) throws ClassNotFoundException {
        ArrayList<Course> courses = new ArrayList<>();
        String sql = "SELECT * FROM course WHERE course_level = ? AND status = 'active' ORDER BY rating DESC";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, level);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    courses.add(extractCourse(rs));
            }
        } catch (SQLException e) {
            System.err.println("[CourseDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return courses;
    }

    /**
     * 根据课程ID查询单个课程记录。
     * <p>
     * 算法：PreparedStatement 参数化查询 → extractCourse() 提取单行
     *
     * @param id 课程ID
     * @return Course 课程对象；未找到返回 null
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public Course getCourseById(long id) throws ClassNotFoundException {
        Course course = null;
        String sql = "SELECT * FROM course WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    course = extractCourse(rs);
            }
        } catch (SQLException e) {
            System.err.println("[CourseDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return course;
    }

    /**
     * 添加新课程记录。
     * <p>
     * 算法：INSERT INTO course → PreparedStatement 设置11个字段 → executeUpdate() > 0
     *
     * @param course 待添加的Course对象
     * @return boolean true=添加成功，false=添加失败
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public boolean addCourse(Course course) throws ClassNotFoundException {
        String sql = "INSERT INTO course (course_name, course_category, course_level, instructor_id, "
                + "instructor_name, course_hours, rating, enrolled_count, cover_image, description, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, course.getCourseName());
            ps.setString(2, course.getCourseCategory());
            ps.setString(3, course.getCourseLevel());
            ps.setObject(4, course.getInstructorId());
            ps.setString(5, course.getInstructorName());
            ps.setInt(6, course.getCourseHours());
            ps.setDouble(7, course.getRating());
            ps.setInt(8, course.getEnrolledCount());
            ps.setString(9, course.getCoverImage());
            ps.setString(10, course.getDescription());
            ps.setString(11, course.getStatus() != null ? course.getStatus() : "active");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[CourseDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 更新已有课程记录。
     * <p>
     * 算法：UPDATE course SET 11个字段 → PreparedStatement 设置字段+WHERE条件 → executeUpdate() > 0
     *
     * @param course 待更新的Course对象（id为必填定位条件）
     * @return boolean true=更新成功，false=更新失败
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public boolean updateCourse(Course course) throws ClassNotFoundException {
        String sql = "UPDATE course SET course_name=?, course_category=?, course_level=?, "
                + "instructor_id=?, instructor_name=?, course_hours=?, rating=?, "
                + "enrolled_count=?, cover_image=?, description=?, status=? WHERE id=?";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, course.getCourseName());
            ps.setString(2, course.getCourseCategory());
            ps.setString(3, course.getCourseLevel());
            ps.setObject(4, course.getInstructorId());
            ps.setString(5, course.getInstructorName());
            ps.setInt(6, course.getCourseHours());
            ps.setDouble(7, course.getRating());
            ps.setInt(8, course.getEnrolledCount());
            ps.setString(9, course.getCoverImage());
            ps.setString(10, course.getDescription());
            ps.setString(11, course.getStatus());
            ps.setLong(12, course.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[CourseDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 根据课程ID删除课程记录。
     * <p>
     * 算法：DELETE FROM course WHERE id=? → PreparedStatement 设置参数 → executeUpdate() > 0
     *
     * @param id 待删除的课程ID
     * @return boolean true=删除成功，false=删除失败
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public boolean deleteCourse(long id) throws ClassNotFoundException {
        String sql = "DELETE FROM course WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[CourseDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 关键词搜索已发布（status='active'）的课程记录。
     * <p>
     * 算法：PreparedStatement 模糊匹配 course_name/description → 遍历 ResultSet → extractCourse() 逐行提取
     *
     * @param keyword 搜索关键词（自动包裹为 %keyword%）
     * @return ArrayList<Course> 匹配的课程列表
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<Course> searchCourses(String keyword) throws ClassNotFoundException {
        ArrayList<Course> courses = new ArrayList<>();
        String sql = "SELECT * FROM course WHERE (course_name LIKE ? OR description LIKE ?) AND status = 'active'";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            String pattern = "%" + keyword + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    courses.add(extractCourse(rs));
            }
        } catch (SQLException e) {
            System.err.println("[CourseDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return courses;
    }

    /**
     * 获取已发布（status='active'）课程的总数。
     * <p>
     * 算法：SELECT COUNT(*) FROM course WHERE status='active' → 取结果集第1列
     *
     * @return int 课程总数；异常时返回 0
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public int getCourseCount() throws ClassNotFoundException {
        String sql = "SELECT COUNT(*) FROM course WHERE status = 'active'";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[CourseDao] getCourseCount SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    // ════════════════════════════════════════════════════════════════════
    //  从 ResultSet 提取 Course 对象
    //   步骤：rs.getLong("id") → new Course() → setXxx()
    // ════════════════════════════════════════════════════════════════════
    private Course extractCourse(ResultSet rs) throws SQLException {
        Course c = new Course();
        c.setId(rs.getLong("id"));
        c.setCourseName(rs.getString("course_name"));
        c.setCourseCategory(rs.getString("course_category"));
        c.setCourseLevel(rs.getString("course_level"));
        c.setInstructorId(rs.getInt("instructor_id"));
        c.setInstructorName(rs.getString("instructor_name"));
        c.setCourseHours(rs.getInt("course_hours"));
        c.setRating(rs.getDouble("rating"));
        c.setEnrolledCount(rs.getInt("enrolled_count"));
        c.setCoverImage(rs.getString("cover_image"));
        c.setDescription(rs.getString("description"));
        c.setStatus(rs.getString("status"));
        return c;
    }
}
