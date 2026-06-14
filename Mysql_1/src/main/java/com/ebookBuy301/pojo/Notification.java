/**
 * ===========================================================================
 * Notification —— 通知实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   notification
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段              类型            对应列              说明
 * ----------------------------------------------------------------------
 * id               long            id                 主键
 * title            String          title              标题
 * content          String          content            内容
 * notificationType String          notification_type  通知类型
 * targetType       String          target_type        目标类型
 * senderId         String          sender_id          发送者ID
 * sendTime         Timestamp       send_time          发送时间
 * scheduledTime    Timestamp       scheduled_time     预约发送时间
 * status           String          status             状态
 * readCount        int             read_count         已读人数
 * totalRecipients  int             total_recipients   总接收人数
 * createdAt        Timestamp       created_at         创建时间
 * updatedAt        Timestamp       updated_at         更新时间
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

import java.sql.Timestamp;

public class Notification {
    private long id;                        // 主键
    private String title;                   // 标题
    private String content;                 // 内容
    private String notificationType;        // 通知类型
    private String targetType;              // 目标类型
    private String senderId;                // 发送者ID
    private Timestamp sendTime;             // 发送时间
    private Timestamp scheduledTime;        // 预约发送时间
    private String status;                  // 状态
    private int readCount;                  // 已读人数
    private int totalRecipients;            // 总接收人数
    private Timestamp createdAt;            // 创建时间
    private Timestamp updatedAt;            // 更新时间

    public Notification() {}

    // Getters and Setters
    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getNotificationType() { return notificationType; }
    public void setNotificationType(String notificationType) { this.notificationType = notificationType; }

    public String getTargetType() { return targetType; }
    public void setTargetType(String targetType) { this.targetType = targetType; }

    public String getSenderId() { return senderId; }
    public void setSenderId(String senderId) { this.senderId = senderId; }

    public Timestamp getSendTime() { return sendTime; }
    public void setSendTime(Timestamp sendTime) { this.sendTime = sendTime; }

    public Timestamp getScheduledTime() { return scheduledTime; }
    public void setScheduledTime(Timestamp scheduledTime) { this.scheduledTime = scheduledTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getReadCount() { return readCount; }
    public void setReadCount(int readCount) { this.readCount = readCount; }

    public int getTotalRecipients() { return totalRecipients; }
    public void setTotalRecipients(int totalRecipients) { this.totalRecipients = totalRecipients; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
