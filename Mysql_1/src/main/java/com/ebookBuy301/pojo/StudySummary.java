/**
 * ===========================================================================
 * StudySummary —— 学习总结实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   study_summary
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列             说明
 * ----------------------------------------------------------------------
 * id            int             id                主键
 * userId        String          user_id           用户ID
 * totalCourses  int             total_courses     已修课程数
 * totalHours    BigDecimal      total_hours       学习时长
 * campusPoints  int             campus_points     校园积分
 * weekProgress  int             week_progress     周学习进度(%)
 * streakDays    int             streak_days       连续学习天数
 * lastStudyDate Timestamp       last_study_date   最后学习日期
 * createdAt     Timestamp       created_at        创建时间
 * updatedAt     Timestamp       updated_at        更新时间
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class StudySummary {
    private int id;                         // 主键
    private String userId;                  // 用户ID
    private int totalCourses;               // 已修课程数
    private BigDecimal totalHours;          // 学习时长
    private int campusPoints;               // 校园积分
    private int weekProgress;               // 周学习进度(%)
    private int streakDays;                 // 连续学习天数
    private Timestamp lastStudyDate;        // 最后学习日期
    private Timestamp createdAt;            // 创建时间
    private Timestamp updatedAt;            // 更新时间

    public StudySummary() {}

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public int getTotalCourses() { return totalCourses; }
    public void setTotalCourses(int totalCourses) { this.totalCourses = totalCourses; }

    public BigDecimal getTotalHours() { return totalHours; }
    public void setTotalHours(BigDecimal totalHours) { this.totalHours = totalHours; }

    public int getCampusPoints() { return campusPoints; }
    public void setCampusPoints(int campusPoints) { this.campusPoints = campusPoints; }

    public int getWeekProgress() { return weekProgress; }
    public void setWeekProgress(int weekProgress) { this.weekProgress = weekProgress; }

    public int getStreakDays() { return streakDays; }
    public void setStreakDays(int streakDays) { this.streakDays = streakDays; }

    public Timestamp getLastStudyDate() { return lastStudyDate; }
    public void setLastStudyDate(Timestamp lastStudyDate) { this.lastStudyDate = lastStudyDate; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
