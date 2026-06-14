package com.ebookBuy301.dao;

import com.ebookBuy301.pojo.PrivateMessage;
import com.ebookBuy301.db.DBManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * =============================================================================
 * PrivateMessageDao —— 私信数据访问层
 * =============================================================================
 *
 * 负责 private_message 表的增删改查操作，支持对话列表、未读计数、软删除。
 *
 * 方法索引：
 *   1. sendMessage()         → 发送私信
 *   2. getMessagesBetween()   → 获取两人对话记录
 *   3. getConversations()     → 获取最近联系人列表
 *   4. getMessagesSince()     → 获取指定时间后的新消息
 *   5. getUnreadCount()      → 获取未读消息数
 *   6. markAsRead()          → 标记消息为已读
 *   7. deleteMessage()        → 软删除单条消息
 *   8. deleteConversation()   → 软删除整个对话
 * =============================================================================
 */
public class PrivateMessageDao {

    /**
     * 发送私信记录。
     * <p>
     * 算法：INSERT INTO private_message → PreparedStatement 设置3个字段 → executeUpdate() > 0
     *
     * @param senderId   发送者用户ID
     * @param receiverId 接收者用户ID
     * @param content    私信内容
     * @return boolean true=发送成功，false=发送失败
     */
    public boolean sendMessage(String senderId, String receiverId, String content) {
        String sql = "INSERT INTO private_message (sender_id, receiver_id, content) VALUES (?, ?, ?)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, senderId);
            ps.setString(2, receiverId);
            ps.setString(3, content);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("[PrivateMessageDao] sendMessage Error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 获取两位用户之间的完整对话记录（双向，含软删除过滤）。
     * <p>
     * 算法：LEFT JOIN users 获取用户名/头像 → 双向 WHERE 条件 → 遍历 ResultSet → extractPrivateMessage() 逐行提取
     *
     * @param userId      当前用户ID
     * @param otherUserId 对方用户ID
     * @return List<PrivateMessage> 对话记录列表（按创建时间升序排序）
     */
    public List<PrivateMessage> getMessagesBetween(String userId, String otherUserId) {
        List<PrivateMessage> messages = new ArrayList<>();
        String sql = "SELECT pm.*, u1.username as sender_name, u1.avatar as sender_avatar, " +
                     "u2.username as receiver_name, u2.avatar as receiver_avatar " +
                     "FROM private_message pm " +
                     "LEFT JOIN users u1 ON pm.sender_id = u1.id " +
                     "LEFT JOIN users u2 ON pm.receiver_id = u2.id " +
                     "WHERE (sender_id = ? AND receiver_id = ? AND is_deleted_sender = 0) " +
                     "   OR (sender_id = ? AND receiver_id = ? AND is_deleted_receiver = 0) " +
                     "ORDER BY created_at ASC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, otherUserId);
            ps.setString(3, otherUserId);
            ps.setString(4, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    messages.add(extractPrivateMessage(rs));
                }
            }
        } catch (Exception e) {
            System.err.println("[PrivateMessageDao] getMessagesBetween Error: " + e.getMessage());
            e.printStackTrace();
        }
        return messages;
    }

    /**
     * 获取用户的最近联系人列表（每个对话的最新一条消息，含未读数）。
     * <p>
     * 算法：嵌套子查询 GROUP BY 取最新消息 → LEFT JOIN 统计未读数 → 遍历 ResultSet → 手动封装 PrivateMessage 对象
     *
     * @param userId 当前用户ID
     * @return List<PrivateMessage> 最近联系人列表（按最后消息时间降序排序）
     */
    public List<PrivateMessage> getConversations(String userId) {
        List<PrivateMessage> conversations = new ArrayList<>();
        // 使用 MAX(id) GROUP BY 取每个对话的最新消息（兼容 MySQL 5.x）
        String sql = "SELECT pm.id, pm.sender_id, pm.receiver_id, pm.content, pm.is_read, pm.created_at, " +
                     "pm.other_id, pm.other_name, pm.other_avatar, " +
                     "COALESCE(unread.cnt, 0) AS unread_count " +
                     "FROM (" +
                     "  SELECT pm2.*, " +
                     "    CASE WHEN pm2.sender_id = ? THEN pm2.receiver_id ELSE pm2.sender_id END AS other_id, " +
                     "    CASE WHEN pm2.sender_id = ? THEN ru.username ELSE su.username END AS other_name, " +
                     "    CASE WHEN pm2.sender_id = ? THEN ru.avatar ELSE su.avatar END AS other_avatar " +
                     "  FROM private_message pm2 " +
                     "  LEFT JOIN users ru ON pm2.receiver_id = ru.id " +
                     "  LEFT JOIN users su ON pm2.sender_id = su.id " +
                     "  WHERE (pm2.sender_id = ? AND pm2.is_deleted_sender = 0) " +
                     "     OR (pm2.receiver_id = ? AND pm2.is_deleted_receiver = 0) " +
                     ") pm " +
                     "INNER JOIN (" +
                     "  SELECT MAX(id) AS max_id, " +
                     "    CASE WHEN sender_id = ? THEN receiver_id ELSE sender_id END AS gid " +
                     "  FROM private_message " +
                     "  WHERE (sender_id = ? AND is_deleted_sender = 0) " +
                     "     OR (receiver_id = ? AND is_deleted_receiver = 0) " +
                     "  GROUP BY gid" +
                     ") latest ON pm.id = latest.max_id " +
                     "LEFT JOIN (" +
                     "  SELECT " +
                     "    CASE WHEN sender_id = ? THEN receiver_id ELSE sender_id END AS other_id2, " +
                     "    COUNT(*) AS cnt " +
                     "  FROM private_message " +
                     "  WHERE receiver_id = ? AND is_read = 0 AND is_deleted_receiver = 0 " +
                     "  GROUP BY CASE WHEN sender_id = ? THEN receiver_id ELSE sender_id END " +
                     ") unread ON pm.other_id = unread.other_id2 " +
                     "ORDER BY pm.created_at DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);   // other_id
            ps.setString(2, userId);   // other_name
            ps.setString(3, userId);   // other_avatar (NEW)
            ps.setString(4, userId);   // WHERE sender_id
            ps.setString(5, userId);   // WHERE receiver_id
            ps.setString(6, userId);   // INNER JOIN gid
            ps.setString(7, userId);   // INNER JOIN sender_id
            ps.setString(8, userId);   // INNER JOIN receiver_id
            ps.setString(9, userId);   // unread other_id2
            ps.setString(10, userId);  // unread receiver_id
            ps.setString(11, userId);  // unread GROUP BY
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PrivateMessage pm = new PrivateMessage();
                    pm.setId(rs.getLong("id"));
                    pm.setSenderId(rs.getString("sender_id"));
                    pm.setReceiverId(rs.getString("receiver_id"));
                    pm.setContent(rs.getString("content"));
                    pm.setIsRead(rs.getInt("is_read"));
                    pm.setCreatedAt(rs.getTimestamp("created_at"));
                    pm.setSenderName(rs.getString("other_name"));
                    pm.setReceiverName(rs.getString("other_name"));
                    pm.setSenderAvatar(rs.getString("other_avatar"));
                    pm.setUnreadCount(rs.getInt("unread_count"));
                    conversations.add(pm);
                }
            }
        } catch (Exception e) {
            System.err.println("[PrivateMessageDao] getConversations Error: " + e.getMessage());
            e.printStackTrace();
        }
        return conversations;
    }

    /**
     * 获取两位用户之间、指定时间之后的新消息（用于轮询）。
     * <p>
     * 算法：LEFT JOIN users 获取用户名/头像 → 双向 WHERE + 时间过滤 → 遍历 ResultSet → extractPrivateMessage() 逐行提取
     *
     * @param userId      当前用户ID
     * @param otherUserId 对方用户ID
     * @param since      基准时间（只获取此时间之后的消息）
     * @return List<PrivateMessage> 新消息列表（按创建时间升序排序）
     */
    public List<PrivateMessage> getMessagesSince(String userId, String otherUserId, Timestamp since) {
        List<PrivateMessage> messages = new ArrayList<>();
        String sql = "SELECT pm.*, u1.username as sender_name, u1.avatar as sender_avatar, " +
                     "u2.username as receiver_name, u2.avatar as receiver_avatar " +
                     "FROM private_message pm " +
                     "LEFT JOIN users u1 ON pm.sender_id = u1.id " +
                     "LEFT JOIN users u2 ON pm.receiver_id = u2.id " +
                     "WHERE ((sender_id = ? AND receiver_id = ? AND is_deleted_sender = 0) " +
                     "    OR (sender_id = ? AND receiver_id = ? AND is_deleted_receiver = 0)) " +
                     "  AND created_at > ? " +
                     "ORDER BY created_at ASC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, otherUserId);
            ps.setString(3, otherUserId);
            ps.setString(4, userId);
            ps.setTimestamp(5, since);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    messages.add(extractPrivateMessage(rs));
                }
            }
        } catch (Exception e) {
            System.err.println("[PrivateMessageDao] getMessagesSince Error: " + e.getMessage());
            e.printStackTrace();
        }
        return messages;
    }

    /**
     * 获取用户的未读私信数量。
     * <p>
     * 算法：SELECT COUNT(*) FROM private_message WHERE receiver_id=? AND is_read=0 AND is_deleted_receiver=0 → 取结果集第1列
     *
     * @param userId 当前用户ID（作为接收者统计）
     * @return int 未读消息数；异常时返回 0
     */
    public int getUnreadCount(String userId) {
        String sql = "SELECT COUNT(*) FROM private_message WHERE receiver_id = ? AND is_read = 0 AND is_deleted_receiver = 0";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            System.err.println("[PrivateMessageDao] getUnreadCount Error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * 标记指定对话中所有来自对方的消息为已读。
     * <p>
     * 算法：UPDATE private_message SET is_read=1 WHERE receiver_id=? AND sender_id=? AND is_read=0 → executeUpdate() > 0
     *
     * @param userId      当前用户ID（作为接收者）
     * @param otherUserId 对方用户ID（作为发送者）
     * @return boolean true=标记成功，false=标记失败
     */
    public boolean markAsRead(String userId, String otherUserId) {
        String sql = "UPDATE private_message SET is_read = 1 WHERE receiver_id = ? AND sender_id = ? AND is_read = 0";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, otherUserId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("[PrivateMessageDao] markAsRead Error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 软删除单条私信（仅对当前用户隐藏）。
     * <p>
     * 算法：UPDATE private_message SET is_deleted_sender/receiver=1（根据 userId 是发送者还是接收者） WHERE id=?
     *
     * @param userId    当前用户ID（用于判断是发送者还是接收者）
     * @param messageId 待删除的消息ID
     * @return boolean true=删除成功，false=删除失败
     */
    public boolean deleteMessage(String userId, Long messageId) {
        String sql = "UPDATE private_message SET " +
                     "is_deleted_sender = IF(sender_id = ?, 1, is_deleted_sender), " +
                     "is_deleted_receiver = IF(receiver_id = ?, 1, is_deleted_receiver) " +
                     "WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, userId);
            ps.setLong(3, messageId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("[PrivateMessageDao] deleteMessage Error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 软删除整个对话（对当前用户隐藏所有双向消息）。
     * <p>
     * 算法：事务中执行两条 UPDATE → SET is_deleted_sender/receiver=1 → commit()
     *
     * @param userId      当前用户ID
     * @param otherUserId 对方用户ID
     * @return boolean true=删除成功，false=删除失败
     */
    public boolean deleteConversation(String userId, String otherUserId) {
        String sql1 = "UPDATE private_message SET is_deleted_sender = 1 WHERE sender_id = ? AND receiver_id = ?";
        String sql2 = "UPDATE private_message SET is_deleted_receiver = 1 WHERE receiver_id = ? AND sender_id = ?";
        try (Connection conn = DBManager.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps1 = conn.prepareStatement(sql1);
                 PreparedStatement ps2 = conn.prepareStatement(sql2)) {
                ps1.setString(1, userId);
                ps1.setString(2, otherUserId);
                ps1.executeUpdate();

                ps2.setString(1, userId);
                ps2.setString(2, otherUserId);
                ps2.executeUpdate();

                conn.commit();
                return true;
            } catch (Exception e) {
                try { conn.rollback(); } catch (Exception ignored) {}
                throw e;
            }
        } catch (Exception e) {
            System.err.println("[PrivateMessageDao] deleteConversation Error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // ════════════════════════════════════════════════════════════════════
    //  从 ResultSet 提取 PrivateMessage 对象（含关联的用户名/头像）
    //   步骤：rs.getLong("id") → new PrivateMessage() → setXxx()
    // ════════════════════════════════════════════════════════════════════
    private PrivateMessage extractPrivateMessage(ResultSet rs) throws SQLException {
        PrivateMessage pm = new PrivateMessage();
        pm.setId(rs.getLong("id"));
        pm.setSenderId(rs.getString("sender_id"));
        pm.setReceiverId(rs.getString("receiver_id"));
        pm.setContent(rs.getString("content"));
        pm.setIsRead(rs.getInt("is_read"));
        pm.setIsDeletedSender(rs.getInt("is_deleted_sender"));
        pm.setIsDeletedReceiver(rs.getInt("is_deleted_receiver"));
        pm.setCreatedAt(rs.getTimestamp("created_at"));
        pm.setSenderName(rs.getString("sender_name"));
        pm.setReceiverName(rs.getString("receiver_name"));
        String sa = rs.getString("sender_avatar");
        if (sa != null) pm.setSenderAvatar(sa);
        String ra = rs.getString("receiver_avatar");
        if (ra != null) pm.setReceiverAvatar(ra);
        return pm;
    }
}