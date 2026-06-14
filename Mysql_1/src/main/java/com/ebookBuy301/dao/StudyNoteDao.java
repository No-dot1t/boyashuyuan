/**
 * =============================================================================
 * StudyNoteDao —— 学习笔记数据访问层
 * =============================================================================
 *
 * 负责 study_note 表的增删改查操作，支持按用户、关键词查询及统计分析。
 *
 * 方法索引：
 *   1. getNotesByUserId()    → 获取用户的所有笔记
 *   2. getNoteById()         → 根据ID查询单条笔记
 *   3. addNote()             → 创建新笔记
 *   4. updateNote()          → 更新笔记
 *   5. deleteNote()          → 删除笔记
 *   6. togglePin()           → 切换置顶状态
 *   7. searchNotes()         → 搜索笔记
 *   8. getNoteCount()        → 获取笔记总数
 *   9. getNoteStats()        → 获取笔记统计数据
 * =============================================================================
 */

package com.ebookBuy301.dao;

import com.ebookBuy301.db.DBManager;
import com.ebookBuy301.pojo.StudyNote;

import java.sql.*;
import java.util.ArrayList;

public class StudyNoteDao {

    /**
     * 根据用户ID获取该用户的所有笔记列表（置顶优先，按更新时间降序）。
     * <p>
     * 算法：SELECT * FROM study_note WHERE user_id=? → 遍历 ResultSet → extractNote() 逐行提取
     *
     * @param userId 用户ID
     * @return ArrayList<StudyNote> 笔记列表
     * @throws SQLException SQL异常
     */
    public ArrayList<StudyNote> getNotesByUserId(String userId) throws SQLException {
        ArrayList<StudyNote> list = new ArrayList<>();
        String sql = "SELECT * FROM study_note WHERE user_id = ? ORDER BY is_pinned DESC, updated_at DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractNote(rs));
                }
            }
        }
        return list;
    }

    /**
     * 根据笔记ID获取单条笔记记录。
     * <p>
     * 算法：PreparedStatement 参数化查询 → extractNote() 提取单行
     *
     * @param noteId 笔记ID
     * @return StudyNote 笔记对象；未找到返回 null
     * @throws SQLException SQL异常
     */
    public StudyNote getNoteById(int noteId) throws SQLException {
        String sql = "SELECT * FROM study_note WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, noteId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractNote(rs);
                }
            }
        }
        return null;
    }

    /**
     * 创建新笔记记录，返回自增主键ID。
     * <p>
     * 算法：INSERT INTO study_note → PreparedStatement 设置字段 → executeUpdate() → getGeneratedKeys()
     *
     * @param userId   所属用户ID
     * @param title    笔记标题
     * @param content  笔记内容（可为null）
     * @param tags     标签（可为null）
     * @param bookId   关联图书ID（可为null）
     * @param courseId 关联课程ID（可为null）
     * @return int 新笔记的自增ID；失败返回 -1
     * @throws SQLException SQL异常
     */
    public int addNote(String userId, String title, String content, String tags,
                        Integer bookId, Integer courseId) throws SQLException {
        String sql = "INSERT INTO study_note (user_id, title, content, tags, book_id, course_id) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, userId);
            ps.setString(2, title);
            ps.setString(3, content != null ? content : "");
            ps.setString(4, tags != null ? tags : "");
            if (bookId != null) ps.setInt(5, bookId); else ps.setNull(5, Types.INTEGER);
            if (courseId != null) ps.setInt(6, courseId); else ps.setNull(6, Types.INTEGER);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
                // 回退方案：部分 JDBC 驱动不返回 generated keys
                try (Statement st = conn.createStatement();
                     ResultSet rs2 = st.executeQuery("SELECT LAST_INSERT_ID()")) {
                    if (rs2.next()) {
                        int id = rs2.getInt(1);
                        if (id > 0) return id;
                    }
                }
            }
        }
        return -1;
    }

    /**
     * 更新笔记标题和内容（需验证归属）。
     * <p>
     * 算法：UPDATE study_note SET 字段 WHERE id=? AND user_id=? → PreparedStatement 设置参数 → executeUpdate() > 0
     *
     * @param noteId 笔记ID
     * @param title  新标题
     * @param content 新内容（可为null）
     * @param tags   新标签（可为null）
     * @param userId 所属用户ID（用于验证归属）
     * @return boolean true=更新成功，false=更新失败或无权限
     * @throws SQLException SQL异常
     */
    public boolean updateNote(int noteId, String title, String content, String tags, String userId) throws SQLException {
        String sql = "UPDATE study_note SET title = ?, content = ?, tags = ? WHERE id = ? AND user_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, content != null ? content : "");
            ps.setString(3, tags != null ? tags : "");
            ps.setInt(4, noteId);
            ps.setString(5, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * 删除笔记（需验证归属）。
     * <p>
     * 算法：DELETE FROM study_note WHERE id=? AND user_id=? → PreparedStatement 设置参数 → executeUpdate() > 0
     *
     * @param noteId 待删除的笔记ID
     * @param userId 所属用户ID（用于验证归属）
     * @return boolean true=删除成功，false=删除失败或无权限
     * @throws SQLException SQL异常
     */
    public boolean deleteNote(int noteId, String userId) throws SQLException {
        String sql = "DELETE FROM study_note WHERE id = ? AND user_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, noteId);
            ps.setString(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * 切换笔记置顶状态（需验证归属）。
     * <p>
     * 算法：UPDATE study_note SET is_pinned=CASE WHEN...END WHERE id=? AND user_id=? → executeUpdate() > 0
     *
     * @param noteId 笔记ID
     * @param userId 所属用户ID（用于验证归属）
     * @return boolean true=切换成功，false=切换失败或无权限
     * @throws SQLException SQL异常
     */
    public boolean togglePin(int noteId, String userId) throws SQLException {
        String sql = "UPDATE study_note SET is_pinned = CASE WHEN is_pinned = 0 THEN 1 ELSE 0 END WHERE id = ? AND user_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, noteId);
            ps.setString(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * 搜索用户的笔记（按标题或内容模糊匹配）。
     * <p>
     * 算法：PreparedStatement 模糊匹配 title/content → 遍历 ResultSet → extractNote() 逐行提取
     *
     * @param userId  所属用户ID
     * @param keyword 搜索关键词（自动包裹为 %keyword%）
     * @return ArrayList<StudyNote> 匹配的笔记列表（置顶优先，按更新时间降序排序）
     * @throws SQLException SQL异常
     */
    public ArrayList<StudyNote> searchNotes(String userId, String keyword) throws SQLException {
        ArrayList<StudyNote> list = new ArrayList<>();
        String sql = "SELECT * FROM study_note WHERE user_id = ? AND (title LIKE ? OR content LIKE ?) ORDER BY is_pinned DESC, updated_at DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            String likeKw = "%" + keyword + "%";
            ps.setString(2, likeKw);
            ps.setString(3, likeKw);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractNote(rs));
                }
            }
        }
        return list;
    }

    /**
     * 获取用户的笔记总数。
     * <p>
     * 算法：SELECT COUNT(*) AS cnt FROM study_note WHERE user_id=? → 取结果集cnt列
     *
     * @param userId 用户ID
     * @return int 笔记总数；异常时返回 0
     * @throws SQLException SQL异常
     */
    public int getNoteCount(String userId) throws SQLException {
        String sql = "SELECT COUNT(*) AS cnt FROM study_note WHERE user_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("cnt");
            }
        }
        return 0;
    }

    /**
     * 获取笔记统计数据（每日趋势、标签分布、长度分布、汇总）。
     * <p>
     * 算法：多条SQL聚合查询 → 封装为 Map 返回
     *
     * @param userId 用户ID
     * @return Map&lt;String, Object&gt; 统计数据（含 totalNotes/pinnedCount/weekCount/totalChars/dailyTrend/tagDistribution/lengthDistribution）
     * @throws SQLException SQL异常
     */
    public java.util.Map<String, Object> getNoteStats(String userId) throws SQLException {
        java.util.Map<String, Object> stats = new java.util.LinkedHashMap<>();
        try (Connection conn = DBManager.getConnection()) {

            // ── 汇总统计 ──
            String sumSql = "SELECT COUNT(*) AS total, "
                    + "COALESCE(SUM(CASE WHEN is_pinned=1 THEN 1 ELSE 0 END),0) AS pinned, "
                    + "COALESCE(SUM(CASE WHEN created_at >= DATE_SUB(CURDATE(),INTERVAL 7 DAY) THEN 1 ELSE 0 END),0) AS week_count, "
                    + "COALESCE(SUM(CHAR_LENGTH(COALESCE(content,''))),0) AS total_chars "
                    + "FROM study_note WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sumSql)) {
                ps.setString(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        stats.put("totalNotes", rs.getInt("total"));
                        stats.put("pinnedCount", rs.getInt("pinned"));
                        stats.put("weekCount", rs.getInt("week_count"));
                        stats.put("totalChars", rs.getInt("total_chars"));
                    }
                }
            }

            // ── 近 14 天每日创建趋势 ──
            String trendSql = "SELECT DATE(created_at) AS dt, COUNT(*) AS cnt "
                    + "FROM study_note WHERE user_id = ? "
                    + "AND created_at >= DATE_SUB(CURDATE(), INTERVAL 14 DAY) "
                    + "GROUP BY DATE(created_at) ORDER BY dt ASC";
            java.util.List<java.util.Map<String, Object>> dailyTrend = new java.util.ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(trendSql)) {
                ps.setString(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        java.util.Map<String, Object> entry = new java.util.LinkedHashMap<>();
                        entry.put("date", rs.getString("dt"));
                        entry.put("count", rs.getInt("cnt"));
                        dailyTrend.add(entry);
                    }
                }
            }
            stats.put("dailyTrend", dailyTrend);

            // ── 标签分布（Top 10） ──
            String tagSql = "SELECT tags FROM study_note WHERE user_id = ? AND tags IS NOT NULL AND tags != ''";
            java.util.Map<String, Integer> tagMap = new java.util.LinkedHashMap<>();
            try (PreparedStatement ps = conn.prepareStatement(tagSql)) {
                ps.setString(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String raw = rs.getString("tags");
                        if (raw != null && !raw.isEmpty()) {
                            for (String t : raw.split(",")) {
                                String tag = t.trim();
                                if (!tag.isEmpty()) {
                                    tagMap.merge(tag, 1, Integer::sum);
                                }
                            }
                        }
                    }
                }
            }
            java.util.List<java.util.Map<String, Object>> tagDist = new java.util.ArrayList<>();
            tagMap.entrySet().stream()
                    .sorted((a, b) -> b.getValue().compareTo(a.getValue()))
                    .limit(10)
                    .forEach(e -> {
                        java.util.Map<String, Object> entry = new java.util.LinkedHashMap<>();
                        entry.put("name", e.getKey());
                        entry.put("value", e.getValue());
                        tagDist.add(entry);
                    });
            stats.put("tagDistribution", tagDist);

            // ── 内容长度分布 ──
            String lenSql = "SELECT "
                    + "SUM(CASE WHEN CHAR_LENGTH(COALESCE(content,'')) < 200 THEN 1 ELSE 0 END) AS s, "
                    + "SUM(CASE WHEN CHAR_LENGTH(COALESCE(content,'')) BETWEEN 200 AND 499 THEN 1 ELSE 0 END) AS m, "
                    + "SUM(CASE WHEN CHAR_LENGTH(COALESCE(content,'')) BETWEEN 500 AND 999 THEN 1 ELSE 0 END) AS l, "
                    + "SUM(CASE WHEN CHAR_LENGTH(COALESCE(content,'')) >= 1000 THEN 1 ELSE 0 END) AS xl "
                    + "FROM study_note WHERE user_id = ?";
            java.util.List<java.util.Map<String, Object>> lenDist = new java.util.ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(lenSql)) {
                ps.setString(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        addLenEntry(lenDist, "简短 (<200字)", rs.getInt("s"));
                        addLenEntry(lenDist, "中等 (200-500字)", rs.getInt("m"));
                        addLenEntry(lenDist, "较长 (500-1000字)", rs.getInt("l"));
                        addLenEntry(lenDist, "长篇 (1000+字)", rs.getInt("xl"));
                    }
                }
            }
            stats.put("lengthDistribution", lenDist);

        }
        return stats;
    }

    // ════════════════════════════════════════════════════════════════════
    //  辅助方法：向长度分布列表添加一条条目
    //   步骤：new Map → put("label",...) → put("count",...) → list.add()
    // ════════════════════════════════════════════════════════════════════
    private void addLenEntry(java.util.List<java.util.Map<String, Object>> list, String label, int count) {
        java.util.Map<String, Object> entry = new java.util.LinkedHashMap<>();
        entry.put("label", label);
        entry.put("count", count);
        list.add(entry);
    }

    // ════════════════════════════════════════════════════════════════════
    //  从 ResultSet 提取 StudyNote 对象
    //   步骤：rs.getInt("id") → new StudyNote() → setXxx()
    // ════════════════════════════════════════════════════════════════════
    private StudyNote extractNote(ResultSet rs) throws SQLException {
        StudyNote note = new StudyNote();
        note.setId(rs.getInt("id"));
        note.setUserId(rs.getString("user_id"));
        note.setBookId(rs.getObject("book_id") != null ? rs.getInt("book_id") : null);
        note.setCourseId(rs.getObject("course_id") != null ? rs.getInt("course_id") : null);
        note.setTitle(rs.getString("title"));
        note.setContent(rs.getString("content"));
        note.setTags(rs.getString("tags"));
        note.setPinned(rs.getInt("is_pinned") == 1);
        note.setPublic(rs.getInt("is_public") == 1);
        note.setCreatedAt(rs.getTimestamp("created_at"));
        note.setUpdatedAt(rs.getTimestamp("updated_at"));
        return note;
    }
}
