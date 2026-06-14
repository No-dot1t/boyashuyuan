/**
 * ===========================================================================
 * PomodoroSession —— 番茄钟实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   pomodoro_session
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列             说明
 * ----------------------------------------------------------------------
 * id            int             id                主键
 * userId        String          user_id           用户ID
 * focusDuration int             focus_duration    专注时长(分钟)
 * breakDuration int             break_duration    休息时长(分钟)
 * startedAt     Timestamp       started_at        开始时间
 * completedAt   Timestamp       completed_at      完成时间
 * isCompleted   boolean         is_completed      是否已完成
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + isCompleted() 判断方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

import java.sql.Timestamp;

public class PomodoroSession {
    private int id;                         // 主键
    private String userId;                  // 用户ID
    private int focusDuration;              // 专注时长(分钟)
    private int breakDuration;              // 休息时长(分钟)
    private Timestamp startedAt;            // 开始时间
    private Timestamp completedAt;          // 完成时间
    private boolean isCompleted;            // 是否已完成

    public PomodoroSession() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public int getFocusDuration() { return focusDuration; }
    public void setFocusDuration(int focusDuration) { this.focusDuration = focusDuration; }
    public int getBreakDuration() { return breakDuration; }
    public void setBreakDuration(int breakDuration) { this.breakDuration = breakDuration; }
    public Timestamp getStartedAt() { return startedAt; }
    public void setStartedAt(Timestamp startedAt) { this.startedAt = startedAt; }
    public Timestamp getCompletedAt() { return completedAt; }
    public void setCompletedAt(Timestamp completedAt) { this.completedAt = completedAt; }
    public boolean isCompleted() { return isCompleted; }
    public void setCompleted(boolean completed) { isCompleted = completed; }
}
