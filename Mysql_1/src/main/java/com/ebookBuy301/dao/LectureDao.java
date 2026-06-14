/**
 * ===========================================================================
 * LectureDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getAllActiveLectures()             查询操作
 * getUpcomingLectures()              查询操作
 * getLectureById(int id)             查询操作
 * addLecture(Lecture lecture)        新增操作
 * updateLecture(Lecture lecture)     更新操作
 * deleteLecture(int id)              删除操作
 * extractLecture(ResultSet rs)       数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM lecture WHERE is_active = 1 ORDER BY lecture_date ASC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) list.add(extractLecture(rs))
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM lecture WHERE status = 'upcoming' AND is_active = 1 ORDER BY lecture_date ASC LIMIT 10"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) list.add(extractLecture(rs))
 *   lecture = null
 *   sql = "SELECT * FROM lecture WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id)
 *   rs = ps.executeQuery()) {
                if (rs.next()) lecture = extractLecture(rs)
 *   sql = "INSERT INTO lecture (title, speaker, speaker_title, speaker_avatar, "
                   + "lecture_date, lecture_time, description, is_online, meeting_url, status, sort_order, is_active) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, lecture.getTitle())
 *   sql = "UPDATE lecture SET title=?, speaker=?, speaker_title=?, speaker_avatar=?, "
                   + "lecture_date=?, lecture_time=?, description=?, is_online=?, meeting_url=?, "
                   + "status=?, sort_order=?, is_active=? WHERE id=?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, lecture.getTitle())
 *   sql = "DELETE FROM lecture WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id)
 *   l = new Lecture()
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
import com.ebookBuy301.pojo.Lecture;

import java.sql.*;
import java.util.ArrayList;

/**
 * =============================================================================
 * LectureDao —— 讲座数据访问层
 * =============================================================================
 *
 * 负责 lecture 表的增删改查操作。
 *
 * 方法索引：
 * 1. getAllActiveLectures() → 获取所有活跃讲座
 * 2. getUpcomingLectures() → 获取即将开始的讲座
 * 3. getLectureById() → 根据ID查询
 * 4. addLecture() → 添加讲座
 * 5. updateLecture() → 更新讲座
 * 6. deleteLecture() → 删除讲座
 * =============================================================================
 */
public class LectureDao {

    /**
     * 获取所有讲座记录（按排序号和讲座日期升序）。
     * <p>
     * 算法：SELECT * FROM lecture → 遍历 ResultSet → extractLecture() 逐行提取
     *
     * @return ArrayList<Lecture> 讲座列表
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<Lecture> getAllActiveLectures() throws ClassNotFoundException {
        ArrayList<Lecture> list = new ArrayList<>();
        String sql = "SELECT * FROM lecture ORDER BY sort_order ASC, lecture_date ASC";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                list.add(extractLecture(rs));
        } catch (SQLException e) {
            System.err.println("[LectureDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * 获取即将开始的（status='upcoming'）讲座记录。
     * <p>
     * 算法：PreparedStatement 筛选 → 遍历 ResultSet → extractLecture() 逐行提取
     *
     * @return ArrayList<Lecture> 讲座列表（按排序号和讲座日期升序，最多10条）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<Lecture> getUpcomingLectures() throws ClassNotFoundException {
        ArrayList<Lecture> list = new ArrayList<>();
        String sql = "SELECT * FROM lecture WHERE status = 'upcoming' ORDER BY sort_order ASC, lecture_date ASC LIMIT 10";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                list.add(extractLecture(rs));
        } catch (SQLException e) {
            System.err.println("[LectureDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * 根据讲座ID查询单个讲座记录。
     * <p>
     * 算法：PreparedStatement 参数化查询 → extractLecture() 提取单行
     *
     * @param id 讲座ID
     * @return Lecture 讲座对象；未找到返回 null
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public Lecture getLectureById(int id) throws ClassNotFoundException {
        Lecture lecture = null;
        String sql = "SELECT * FROM lecture WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    lecture = extractLecture(rs);
            }
        } catch (SQLException e) {
            System.err.println("[LectureDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return lecture;
    }

    /**
     * 添加新讲座记录。
     * <p>
     * 算法：INSERT INTO lecture → PreparedStatement 设置11个字段 → executeUpdate() > 0
     *
     * @param lecture 待添加的Lecture对象
     * @return boolean true=添加成功，false=添加失败
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public boolean addLecture(Lecture lecture) throws ClassNotFoundException {
        String sql = "INSERT INTO lecture (title, speaker, speaker_title, speaker_avatar, "
                + "lecture_date, lecture_time, description, is_online, meeting_url, status, sort_order) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, lecture.getTitle());
            ps.setString(2, lecture.getSpeaker());
            ps.setString(3, lecture.getSpeakerTitle());
            ps.setString(4, lecture.getSpeakerAvatar());
            ps.setTimestamp(5, lecture.getLectureDate());
            ps.setString(6, lecture.getLectureTime());
            ps.setString(7, lecture.getDescription());
            ps.setBoolean(8, lecture.isOnline());
            ps.setString(9, lecture.getMeetingUrl());
            ps.setString(10, lecture.getStatus());
            ps.setInt(11, lecture.getSortOrder());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[LectureDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 更新已有讲座记录。
     * <p>
     * 算法：UPDATE lecture SET 11个字段 → PreparedStatement 设置字段+WHERE条件 → executeUpdate() > 0
     *
     * @param lecture 待更新的Lecture对象（id为必填定位条件）
     * @return boolean true=更新成功，false=更新失败
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public boolean updateLecture(Lecture lecture) throws ClassNotFoundException {
        String sql = "UPDATE lecture SET title=?, speaker=?, speaker_title=?, speaker_avatar=?, "
                + "lecture_date=?, lecture_time=?, description=?, is_online=?, meeting_url=?, "
                + "status=?, sort_order=? WHERE id=?";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, lecture.getTitle());
            ps.setString(2, lecture.getSpeaker());
            ps.setString(3, lecture.getSpeakerTitle());
            ps.setString(4, lecture.getSpeakerAvatar());
            ps.setTimestamp(5, lecture.getLectureDate());
            ps.setString(6, lecture.getLectureTime());
            ps.setString(7, lecture.getDescription());
            ps.setBoolean(8, lecture.isOnline());
            ps.setString(9, lecture.getMeetingUrl());
            ps.setString(10, lecture.getStatus());
            ps.setInt(11, lecture.getSortOrder());
            ps.setInt(12, lecture.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[LectureDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 根据讲座ID删除讲座记录。
     * <p>
     * 算法：DELETE FROM lecture WHERE id=? → PreparedStatement 设置参数 → executeUpdate() > 0
     *
     * @param id 待删除的讲座ID
     * @return boolean true=删除成功，false=删除失败
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public boolean deleteLecture(int id) throws ClassNotFoundException {
        String sql = "DELETE FROM lecture WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[LectureDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 关键词搜索讲座记录。
     * <p>
     * 算法：PreparedStatement 模糊匹配 title/speaker/speaker_title/description → 遍历 ResultSet → extractLecture() 逐行提取
     *
     * @param keyword 搜索关键词（自动包裹为 %keyword%，最多返回20条）
     * @return ArrayList<Lecture> 匹配的讲座列表（按排序号升序、讲座日期升序排序）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<Lecture> searchLectures(String keyword) throws ClassNotFoundException {
        ArrayList<Lecture> list = new ArrayList<>();
        String sql = "SELECT * FROM lecture WHERE "
                   + "(title LIKE ? OR speaker LIKE ? OR speaker_title LIKE ? OR description LIKE ?) "
                   + "ORDER BY sort_order ASC, lecture_date ASC LIMIT 20";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String pattern = "%" + keyword + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            ps.setString(3, pattern);
            ps.setString(4, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(extractLecture(rs));
            }
        } catch (SQLException e) {
            System.err.println("[LectureDao] 搜索错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // ════════════════════════════════════════════════════════════════════
    //  从 ResultSet 提取 Lecture 对象
    //   步骤：rs.getInt("id") → new Lecture() → setXxx()
    // ════════════════════════════════════════════════════════════════════
    private Lecture extractLecture(ResultSet rs) throws SQLException {
        Lecture l = new Lecture();
        l.setId(rs.getInt("id"));
        l.setTitle(rs.getString("title"));
        l.setSpeaker(rs.getString("speaker"));
        l.setSpeakerTitle(rs.getString("speaker_title"));
        l.setSpeakerAvatar(rs.getString("speaker_avatar"));
        l.setLectureDate(rs.getTimestamp("lecture_date"));
        l.setLectureTime(rs.getString("lecture_time"));
        l.setDescription(rs.getString("description"));
        l.setOnline(rs.getBoolean("is_online"));
        l.setMeetingUrl(rs.getString("meeting_url"));
        l.setStatus(rs.getString("status"));
        l.setSortOrder(rs.getInt("sort_order"));
        return l;
    }
}
