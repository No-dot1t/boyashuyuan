/**
 * ===========================================================================
 * LearningStep —— 学习步骤实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   learning_step
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列             说明
 * ----------------------------------------------------------------------
 * id            int             id                主键
 * userId        String          user_id           用户ID
 * stepNumber    int             step_number       步骤序号
 * title         String          title             标题
 * description   String          description       描述
 * status        String          status            状态(completed/in_progress/upcoming)
 * progressPercent int           progress_percent  进度百分比
 * createdAt     Timestamp       created_at        创建时间
 * updatedAt     Timestamp       updated_at        更新时间
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + 带参构造方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

import java.sql.Timestamp;

public class LearningStep {
    private int id;                         // 主键
    private String userId;                  // 用户ID
    private int stepNumber;                 // 步骤序号
    private String title;                   // 标题
    private String description;             // 描述
    private String status;                  // 状态(completed/in_progress/upcoming)
    private int progressPercent;            // 进度百分比
    private Timestamp createdAt;            // 创建时间
    private Timestamp updatedAt;            // 更新时间

    public LearningStep() {}

    public LearningStep(int stepNumber, String title, String description, String status, int progressPercent) {
        this.stepNumber = stepNumber;
        this.title = title;
        this.description = description;
        this.status = status;
        this.progressPercent = progressPercent;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public int getStepNumber() { return stepNumber; }
    public void setStepNumber(int stepNumber) { this.stepNumber = stepNumber; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getProgressPercent() { return progressPercent; }
    public void setProgressPercent(int progressPercent) { this.progressPercent = progressPercent; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
