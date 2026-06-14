/**
 * ===========================================================================
 * StudyTask —— 学习任务实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   study_task
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列           说明
 * ----------------------------------------------------------------------
 * id            int             id              主键
 * userId        String          user_id         用户ID
 * title         String          title           任务标题
 * status        String          status          任务状态
 * createdAt     Timestamp       created_at      创建时间
 * completedAt   Timestamp       completed_at    完成时间
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

import java.sql.Timestamp;

public class StudyTask {
    private int id;                         // 主键
    private String userId;                  // 用户ID
    private String title;                   // 任务标题
    private String status;                  // 任务状态
    private Timestamp createdAt;            // 创建时间
    private Timestamp completedAt;          // 完成时间

    public StudyTask() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getCompletedAt() { return completedAt; }
    public void setCompletedAt(Timestamp completedAt) { this.completedAt = completedAt; }
}
