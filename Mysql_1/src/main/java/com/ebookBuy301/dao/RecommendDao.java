/**
 * ===========================================================================
 * RecommendDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getStudySummary(String userId)     查询操作
 * getAllStudySummary()               查询操作
 * getSkills(String userId)           查询操作
 * getAllSkills()                     查询操作
 * getAllRecommendItems(String type)  查询操作
 * getLearningSteps(String userId)    查询操作
 * getAllLearningSteps()              查询操作
 * extractSkill(ResultSet rs)         数据抽取
 * extractStep(ResultSet rs)          数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   summary = null
 *   sql = "SELECT * FROM user_study_summary WHERE user_id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                if (rs.next()) {
                    summary = new StudySummary()
 *   summary = new StudySummary()
 *   sql = "SELECT COALESCE(SUM(total_courses), 0) as total_courses, "
                   + "COALESCE(SUM(total_study_hours), 0) as total_study_hours, "
                   + "COALESCE(AVG(campus_points), 0) as avg_campus_points, "
                   + "COALESCE(AVG(week_progress), 0) as avg_week_progress, "
                   + "COALESCE(MAX(streak_days), 0) as max_streak_days, "
                   + "COUNT(*) as user_count FROM user_study_summary"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            if (rs.next()) {
                summary.setTotalCourses(rs.getInt("total_courses"))
 *   skills = new ArrayList<>()
 *   sql = "SELECT * FROM knowledge_skills WHERE user_id = ? ORDER BY skill_value DESC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                while (rs.next()) skills.add(extractSkill(rs))
 *   skills = new ArrayList<>()
 *   sql = "SELECT * FROM knowledge_skills ORDER BY skill_value DESC LIMIT 10"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) skills.add(extractSkill(rs))
 *   items = new ArrayList<>()
 *   hasFilter = type != null && !type.isEmpty() && !"all".equalsIgnoreCase(type)
 *   sql = hasFilter
                   ? "SELECT * FROM recommendations WHERE type = ? AND is_active = 1 ORDER BY sort_order ASC LIMIT 20"
                   : "SELECT * FROM recommendations WHERE is_active = 1 ORDER BY sort_order ASC LIMIT 20"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            if (hasFilter) ps.setString(1, type)
 *   rs = ps.executeQuery()) {
                while (rs.next()) {
                    RecommendItem item = new RecommendItem()
 *   steps = new ArrayList<>()
 *   sql = "SELECT * FROM learning_paths WHERE user_id = ? ORDER BY step_number ASC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId)
 *   rs = ps.executeQuery()) {
                while (rs.next()) steps.add(extractStep(rs))
 *   steps = new ArrayList<>()
 *   sql = "SELECT * FROM learning_paths ORDER BY step_number ASC LIMIT 10"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) steps.add(extractStep(rs))
 *   s = new Skill()
 *   s = new LearningStep()
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
import com.ebookBuy301.pojo.*;

import java.sql.*;
import java.util.ArrayList;

/**
 * =============================================================================
 * RecommendDao —— 推荐系统数据访问层
 * =============================================================================
 *
 * 负责推荐系统的数据查询，所有数据均从数据库获取。
 *
 * 方法索引：
 *   1. getStudySummary()        → 获取用户学习汇总
 *   2. getAllStudySummary()     → 获取所有用户聚合数据
 *   3. getSkills()              → 获取用户技能列表
 *   4. getAllSkills()           → 获取所有技能
 *   5. getAllRecommendItems()   → 获取推荐内容
 *   6. getLearningSteps()       → 获取用户学习路径
 *   7. getAllLearningSteps()    → 获取所有学习路径
 * =============================================================================
 */
public class RecommendDao {

    /** 获取指定用户的学习汇总 */
    public StudySummary getStudySummary(String userId) {
        StudySummary summary = null;
        String sql = "SELECT * FROM user_study_summary WHERE user_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    summary = new StudySummary();
                    summary.setId(rs.getInt("id"));
                    summary.setUserId(rs.getString("user_id"));
                    summary.setTotalCourses(rs.getInt("total_courses"));
                    summary.setTotalHours(rs.getBigDecimal("total_study_hours"));
                    summary.setCampusPoints(rs.getInt("campus_points"));
                    summary.setWeekProgress(rs.getInt("week_progress"));
                    summary.setStreakDays(rs.getInt("streak_days"));
                    summary.setLastStudyDate(rs.getTimestamp("last_study_date"));
                    summary.setCreatedAt(rs.getTimestamp("created_at"));
                    summary.setUpdatedAt(rs.getTimestamp("updated_at"));
                }
            }
        } catch (SQLException e) {
            System.err.println("[RecommendDao] 获取学习汇总失败：" + e.getMessage());
        }
        return summary;
    }

    /** 获取所有用户的学习汇总聚合数据 */
    public StudySummary getAllStudySummary() {
        StudySummary summary = new StudySummary();
        String sql = "SELECT COALESCE(SUM(total_courses), 0) as total_courses, "
                   + "COALESCE(SUM(total_study_hours), 0) as total_study_hours, "
                   + "COALESCE(AVG(campus_points), 0) as avg_campus_points, "
                   + "COALESCE(AVG(week_progress), 0) as avg_week_progress, "
                   + "COALESCE(MAX(streak_days), 0) as max_streak_days, "
                   + "COUNT(*) as user_count FROM user_study_summary";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                summary.setTotalCourses(rs.getInt("total_courses"));
                summary.setTotalHours(rs.getBigDecimal("total_study_hours"));
                summary.setCampusPoints(rs.getInt("avg_campus_points"));
                summary.setWeekProgress(rs.getInt("avg_week_progress"));
                summary.setStreakDays(rs.getInt("max_streak_days"));
            }
        } catch (SQLException e) {
            System.err.println("[RecommendDao] 获取聚合数据失败：" + e.getMessage());
        }
        return summary;
    }

    /** 获取用户的知识技能列表 */
    public ArrayList<Skill> getSkills(String userId) {
        ArrayList<Skill> skills = new ArrayList<>();
        String sql = "SELECT * FROM knowledge_skills WHERE user_id = ? ORDER BY skill_value DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) skills.add(extractSkill(rs));
            }
        } catch (SQLException e) {
            System.err.println("[RecommendDao] 获取技能列表失败：" + e.getMessage());
        }
        return skills;
    }

    /** 获取所有技能数据（无用户筛选） */
    public ArrayList<Skill> getAllSkills() {
        ArrayList<Skill> skills = new ArrayList<>();
        String sql = "SELECT * FROM knowledge_skills ORDER BY skill_value DESC LIMIT 10";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) skills.add(extractSkill(rs));
        } catch (SQLException e) {
            System.err.println("[RecommendDao] 获取所有技能失败：" + e.getMessage());
        }
        return skills;
    }

    /** 获取推荐内容列表（支持按类型筛选） */
    public ArrayList<RecommendItem> getAllRecommendItems(String type) {
        ArrayList<RecommendItem> items = new ArrayList<>();
        boolean hasFilter = type != null && !type.isEmpty() && !"all".equalsIgnoreCase(type);
        String sql = hasFilter
                   ? "SELECT * FROM recommendations WHERE type = ? AND is_active = 1 ORDER BY sort_order ASC LIMIT 20"
                   : "SELECT * FROM recommendations WHERE is_active = 1 ORDER BY sort_order ASC LIMIT 20";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (hasFilter) ps.setString(1, type);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RecommendItem item = new RecommendItem();
                    item.setId(rs.getInt("id"));
                    item.setTitle(rs.getString("title"));
                    item.setCategory(rs.getString("category"));
                    item.setDescription(rs.getString("description"));
                    item.setType(rs.getString("type"));
                    item.setBadge(rs.getString("badge"));
                    item.setAuthor(rs.getString("author"));
                    item.setMetaInfo(rs.getString("meta_info"));
                    item.setRating(rs.getBigDecimal("rating"));
                    item.setActionText(rs.getString("action_text"));
                    item.setSortOrder(rs.getInt("sort_order"));
                    item.setActive(rs.getBoolean("is_active"));
                    item.setCreatedAt(rs.getTimestamp("created_at"));
                    item.setUpdatedAt(rs.getTimestamp("updated_at"));
                    items.add(item);
                }
            }
        } catch (SQLException e) {
            System.err.println("[RecommendDao] 获取推荐内容失败：" + e.getMessage());
        }
        return items;
    }

    /** 获取用户学习路径 */
    public ArrayList<LearningStep> getLearningSteps(String userId) {
        ArrayList<LearningStep> steps = new ArrayList<>();
        String sql = "SELECT * FROM learning_paths WHERE user_id = ? ORDER BY step_number ASC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) steps.add(extractStep(rs));
            }
        } catch (SQLException e) {
            System.err.println("[RecommendDao] 获取学习路径失败：" + e.getMessage());
        }
        return steps;
    }

    /** 获取所有学习路径数据 */
    public ArrayList<LearningStep> getAllLearningSteps() {
        ArrayList<LearningStep> steps = new ArrayList<>();
        String sql = "SELECT * FROM learning_paths ORDER BY step_number ASC LIMIT 10";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) steps.add(extractStep(rs));
        } catch (SQLException e) {
            System.err.println("[RecommendDao] 获取所有学习路径失败：" + e.getMessage());
        }
        return steps;
    }

    private Skill extractSkill(ResultSet rs) throws SQLException {
        Skill s = new Skill();
        s.setId(rs.getInt("id"));
        s.setUserId(rs.getString("user_id"));
        s.setSkillName(rs.getString("skill_name"));
        s.setSkillValue(rs.getInt("skill_value"));
        s.setSkillColor(rs.getString("skill_color"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        s.setUpdatedAt(rs.getTimestamp("updated_at"));
        return s;
    }

    private LearningStep extractStep(ResultSet rs) throws SQLException {
        LearningStep s = new LearningStep();
        s.setId(rs.getInt("id"));
        s.setUserId(rs.getString("user_id"));
        s.setStepNumber(rs.getInt("step_number"));
        s.setTitle(rs.getString("title"));
        s.setDescription(rs.getString("description"));
        s.setStatus(rs.getString("status"));
        s.setProgressPercent(rs.getInt("progress_percent"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        s.setUpdatedAt(rs.getTimestamp("updated_at"));
        return s;
    }
}
