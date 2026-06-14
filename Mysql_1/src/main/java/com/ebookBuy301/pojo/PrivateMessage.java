/**
 * ===========================================================================
 * PrivateMessage —— 私信实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   private_message
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段              类型            对应列               说明
 * ----------------------------------------------------------------------
 * id               Long            id                  主键
 * senderId         String          sender_id           发送者ID
 * receiverId       String          receiver_id         接收者ID
 * content          String          content             消息内容
 * isRead           Integer         is_read             是否已读(0未读/1已读)
 * isDeletedSender  Integer         is_deleted_sender   发送者是否删除(0否/1是)
 * isDeletedReceiver Integer        is_deleted_receiver 接收者是否删除(0否/1是)
 * createdAt        Timestamp       created_at          发送时间
 * senderName       String          -                   发送者名称(非DB扩展字段)
 * senderAvatar     String          -                   发送者头像(非DB扩展字段)
 * receiverName     String          -                   接收者名称(非DB扩展字段)
 * receiverAvatar   String          -                   接收者头像(非DB扩展字段)
 * unreadCount      Integer         -                   未读消息数(非DB扩展字段)
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + 带参构造方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

import java.sql.Timestamp;

public class PrivateMessage {
    private Long id;                        // 主键
    private String senderId;                // 发送者ID
    private String receiverId;              // 接收者ID
    private String content;                 // 消息内容
    private Integer isRead;                 // 是否已读(0未读/1已读)
    private Integer isDeletedSender;        // 发送者是否删除(0否/1是)
    private Integer isDeletedReceiver;      // 接收者是否删除(0否/1是)
    private Timestamp createdAt;            // 发送时间

    // 扩展字段（用于显示）
    private String senderName;              // 发送者名称(非DB扩展字段)
    private String senderAvatar;            // 发送者头像(非DB扩展字段)
    private String receiverName;            // 接收者名称(非DB扩展字段)
    private String receiverAvatar;          // 接收者头像(非DB扩展字段)
    private Integer unreadCount;            // 未读消息数(非DB扩展字段)

    public PrivateMessage() {}

    public PrivateMessage(String senderId, String receiverId, String content) {
        this.senderId = senderId;
        this.receiverId = receiverId;
        this.content = content;
        this.isRead = 0;
        this.isDeletedSender = 0;
        this.isDeletedReceiver = 0;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getSenderId() { return senderId; }
    public void setSenderId(String senderId) { this.senderId = senderId; }

    public String getReceiverId() { return receiverId; }
    public void setReceiverId(String receiverId) { this.receiverId = receiverId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Integer getIsRead() { return isRead; }
    public void setIsRead(Integer isRead) { this.isRead = isRead; }

    public Integer getIsDeletedSender() { return isDeletedSender; }
    public void setIsDeletedSender(Integer isDeletedSender) { this.isDeletedSender = isDeletedSender; }

    public Integer getIsDeletedReceiver() { return isDeletedReceiver; }
    public void setIsDeletedReceiver(Integer isDeletedReceiver) { this.isDeletedReceiver = isDeletedReceiver; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }

    public String getSenderAvatar() { return senderAvatar; }
    public void setSenderAvatar(String senderAvatar) { this.senderAvatar = senderAvatar; }

    public String getReceiverName() { return receiverName; }
    public void setReceiverName(String receiverName) { this.receiverName = receiverName; }

    public String getReceiverAvatar() { return receiverAvatar; }
    public void setReceiverAvatar(String receiverAvatar) { this.receiverAvatar = receiverAvatar; }

    public Integer getUnreadCount() { return unreadCount; }
    public void setUnreadCount(Integer unreadCount) { this.unreadCount = unreadCount; }
}