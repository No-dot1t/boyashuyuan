/**
 * ===========================================================================
 * CultureNotificationDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getAllCultureEvents()              查询操作
 * getAllHistoryRecords()             查询操作
 * addNotification(String title, String content, String notificationType, String targetType)新增操作
 * getAllNotifications()              查询操作
 * deleteNotification(long id)        删除操作
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   events = new ArrayList<>()
 *   sql = "SELECT * FROM culture_events WHERE is_active = 1 ORDER BY sort_order ASC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) {
                CultureEvent e = new CultureEvent()
 *   records = new ArrayList<>()
 *   sql = "SELECT * FROM history_records WHERE is_active = 1 ORDER BY year DESC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) {
                HistoryRecord r = new HistoryRecord()
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, title)
 *   notifications = new ArrayList<>()
 *   sql = "SELECT * FROM notification ORDER BY send_time DESC LIMIT 50"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) {
                Notification n = new Notification()
 *   sql = "DELETE FROM notification WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id)
 *   stats = new java.util.HashMap<>()
 *   sql = "SELECT "
                   + "COUNT(*) AS total, "
                   + "SUM(CASE WHEN status = 'sent' THEN 1 ELSE 0 END) AS sent_count, "
                   + "SUM(CASE WHEN status = 'scheduled' THEN 1 ELSE 0 END) AS scheduled_count, "
                   + "SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) AS failed_count, "
                   + "COALESCE(SUM(CASE WHEN status = 'sent' AND total_recipients > 0 "
                   + "THEN read_count ELSE 0 END), 0) AS total_read, "
                   + "COALESCE(SUM(CASE WHEN status = 'sent' AND total_recipients > 0 "
                   + "THEN total_recipients ELSE 0 END), 0) AS total_recipients "
                   + "FROM notification"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("sentCount", rs.getInt("sent_count"))
 *   totalRead = rs.getInt("total_read")
 *   totalRecipients = rs.getInt("total_recipients")
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   JDBC —— Connection / PreparedStatement / ResultSet 数据库访问
 *
 * ===========================================================================
 */

package com.ebookBuy301.dao;

import com.ebookBuy301.db.DBManager;
import com.ebookBuy301.pojo.CultureEvent;
import com.ebookBuy301.pojo.HistoryRecord;
import com.ebookBuy301.pojo.Notification;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * =============================================================================
 * CultureNotificationDao —— 文化·历史·通知综合数据访问层
 * =============================================================================
 *
 * 负责 culture_events、history_records、notification 三张表的查询操作。
 *
 * 方法索引：
 * 1. getAllCultureEvents() → 获取所有文化活动
 * 2. getAllHistoryRecords() → 获取所有历史记录
 * 3. getAllNotifications() → 获取所有通知公告
 * =============================================================================
 */
public class CultureNotificationDao {

    /** 获取所有文化活动（按排序序号排列） */
    public ArrayList<CultureEvent> getAllCultureEvents() throws ClassNotFoundException {
        ArrayList<CultureEvent> events = new ArrayList<>();
        String sql = "SELECT * FROM culture_events WHERE is_active = 1 ORDER BY sort_order ASC";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                CultureEvent e = new CultureEvent();
                e.setId(rs.getInt("id"));
                e.setSeason(rs.getString("season"));
                e.setEventName(rs.getString("event_name"));
                e.setDescription(rs.getString("description"));
                e.setEventType(rs.getString("event_type"));
                e.setEventDate(rs.getDate("event_date"));
                e.setLocation(rs.getString("location"));
                e.setImageUrl(rs.getString("image_url"));
                e.setActive(rs.getBoolean("is_active"));
                e.setSortOrder(rs.getInt("sort_order"));
                e.setCreatedAt(rs.getTimestamp("created_at"));
                events.add(e);
            }
        } catch (SQLException e) {
            System.err.println("[CultureNotificationDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return events;
    }

    /** 获取所有历史记录（按年份降序排列） */
    public ArrayList<HistoryRecord> getAllHistoryRecords() throws ClassNotFoundException {
        ArrayList<HistoryRecord> records = new ArrayList<>();
        String sql = "SELECT * FROM history_records WHERE is_active = 1 ORDER BY year DESC";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                HistoryRecord r = new HistoryRecord();
                r.setId(rs.getInt("id"));
                r.setYear(rs.getString("year"));
                r.setTitle(rs.getString("title"));
                r.setDescription(rs.getString("description"));
                r.setImageUrl(rs.getString("image_url"));
                r.setSortOrder(rs.getInt("sort_order"));
                r.setActive(rs.getBoolean("is_active"));
                r.setCreatedAt(rs.getTimestamp("created_at"));
                records.add(r);
            }
        } catch (SQLException e) {
            System.err.println("[CultureNotificationDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return records;
    }

    /** 新增通知 */
    public boolean addNotification(String title, String content, String notificationType, String targetType)
            throws ClassNotFoundException {
        return addNotification(title, content, notificationType, targetType, false, null);
    }

    /** 新增通知（支持定时） */
    public boolean addNotification(String title, String content, String notificationType, String targetType,
            boolean scheduled, String scheduledTime) throws ClassNotFoundException {
        String sql;
        if (scheduled && scheduledTime != null && !scheduledTime.isEmpty()) {
            sql = "INSERT INTO notification (title, content, notification_type, target_type, scheduled_time, status, created_at, updated_at) "
                    + "VALUES (?, ?, ?, ?, ?, 'scheduled', NOW(), NOW())";
        } else {
            sql = "INSERT INTO notification (title, content, notification_type, target_type, send_time, status, created_at, updated_at) "
                    + "VALUES (?, ?, ?, ?, NOW(), 'sent', NOW(), NOW())";
        }
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, content);
            ps.setString(3, notificationType);
            ps.setString(4, targetType);
            if (scheduled && scheduledTime != null && !scheduledTime.isEmpty()) {
                ps.setString(5, scheduledTime);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[CultureNotificationDao] addNotification 错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /** 获取所有通知公告（按发送时间降序，最多50条） */
    public ArrayList<Notification> getAllNotifications() throws ClassNotFoundException {
        return getNotificationsByFilter(null, null);
    }

    /** 按类型和状态过滤通知 */
    public ArrayList<Notification> getNotificationsByFilter(String type, String status) throws ClassNotFoundException {
        ArrayList<Notification> notifications = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM notification WHERE 1=1");
        if (type != null && !type.isEmpty()) {
            sql.append(" AND notification_type = ?");
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND status = ?");
        }
        sql.append(" ORDER BY send_time DESC LIMIT 50");
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (type != null && !type.isEmpty()) {
                ps.setString(idx++, type);
            }
            if (status != null && !status.isEmpty()) {
                ps.setString(idx, status);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setId(rs.getLong("id"));
                    n.setTitle(rs.getString("title"));
                    n.setContent(rs.getString("content"));
                    n.setNotificationType(rs.getString("notification_type"));
                    n.setTargetType(rs.getString("target_type"));
                    n.setSenderId(rs.getString("sender_id"));
                    n.setSendTime(rs.getTimestamp("send_time"));
                    n.setScheduledTime(rs.getTimestamp("scheduled_time"));
                    n.setStatus(rs.getString("status"));
                    n.setReadCount(rs.getInt("read_count"));
                    n.setTotalRecipients(rs.getInt("total_recipients"));
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    n.setUpdatedAt(rs.getTimestamp("updated_at"));
                    notifications.add(n);
                }
            }
        } catch (SQLException e) {
            System.err.println("[CultureNotificationDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return notifications;
    }

    /** 标记通知为已读 */
    public boolean markNotificationRead(String userId, long notificationId) throws ClassNotFoundException {
        String sql = "INSERT IGNORE INTO user_notification_read (user_id, notification_id, is_read, read_at) "
                + "VALUES (?, ?, 1, NOW())";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setLong(2, notificationId);
            boolean inserted = ps.executeUpdate() > 0;
            if (inserted) {
                // 更新通知表的已读计数
                try (PreparedStatement updatePs = conn.prepareStatement(
                        "UPDATE notification SET read_count = read_count + 1 WHERE id = ?")) {
                    updatePs.setLong(1, notificationId);
                    updatePs.executeUpdate();
                }
            }
            return inserted;
        } catch (SQLException e) {
            System.err.println("[CultureNotificationDao] markNotificationRead 错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /** 搜索通知（按标题和内容模糊匹配）—— 管理员全局搜索专用 */
    public ArrayList<Notification> searchNotifications(String keyword) throws ClassNotFoundException {
        ArrayList<Notification> notifications = new ArrayList<>();
        String sql = "SELECT * FROM notification WHERE (title LIKE ? OR content LIKE ?) ORDER BY send_time DESC LIMIT 20";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            String like = "%" + keyword + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setId(rs.getLong("id"));
                    n.setTitle(rs.getString("title"));
                    n.setContent(rs.getString("content"));
                    n.setNotificationType(rs.getString("notification_type"));
                    n.setTargetType(rs.getString("target_type"));
                    n.setSenderId(rs.getString("sender_id"));
                    n.setSendTime(rs.getTimestamp("send_time"));
                    n.setStatus(rs.getString("status"));
                    n.setReadCount(rs.getInt("read_count"));
                    n.setTotalRecipients(rs.getInt("total_recipients"));
                    notifications.add(n);
                }
            }
        } catch (SQLException e) {
            System.err.println("[CultureNotificationDao] searchNotifications 错误：" + e.getMessage());
            e.printStackTrace();
        }
        return notifications;
    }

    /** 删除通知 */
    public boolean deleteNotification(long id) {
        String sql = "DELETE FROM notification WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("[CultureNotificationDao] deleteNotification 错误：" + e.getMessage());
            return false;
        }
    }

    /** 根据ID获取通知详情 */
    public Notification getNotificationById(long id) {
        String sql = "SELECT * FROM notification WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Notification n = new Notification();
                    n.setId(rs.getLong("id"));
                    n.setTitle(rs.getString("title"));
                    n.setContent(rs.getString("content"));
                    n.setNotificationType(rs.getString("notification_type"));
                    n.setTargetType(rs.getString("target_type"));
                    n.setSenderId(rs.getString("sender_id"));
                    n.setSendTime(rs.getTimestamp("send_time"));
                    n.setScheduledTime(rs.getTimestamp("scheduled_time"));
                    n.setStatus(rs.getString("status"));
                    n.setReadCount(rs.getInt("read_count"));
                    n.setTotalRecipients(rs.getInt("total_recipients"));
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    n.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return n;
                }
            }
        } catch (Exception e) {
            System.err.println("[CultureNotificationDao] getNotificationById 错误：" + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /** 获取所有定时通知（状态为scheduled且到达发送时间） */
    public List<Notification> getScheduledNotifications() {
        List<Notification> notifications = new ArrayList<>();
        String sql = "SELECT * FROM notification WHERE status = 'scheduled' AND scheduled_time <= NOW() ORDER BY scheduled_time ASC";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Notification n = new Notification();
                n.setId(rs.getLong("id"));
                n.setTitle(rs.getString("title"));
                n.setContent(rs.getString("content"));
                n.setNotificationType(rs.getString("notification_type"));
                n.setTargetType(rs.getString("target_type"));
                n.setSenderId(rs.getString("sender_id"));
                n.setSendTime(rs.getTimestamp("send_time"));
                n.setScheduledTime(rs.getTimestamp("scheduled_time"));
                n.setStatus(rs.getString("status"));
                n.setReadCount(rs.getInt("read_count"));
                n.setTotalRecipients(rs.getInt("total_recipients"));
                notifications.add(n);
            }
        } catch (Exception e) {
            System.err.println("[CultureNotificationDao] getScheduledNotifications 错误：" + e.getMessage());
            e.printStackTrace();
        }
        return notifications;
    }

    /** 更新通知状态（转为 sent 时自动设置 send_time = NOW()） */
    public boolean updateNotificationStatus(long id, String status) {
        String sql;
        if ("sent".equals(status)) {
            sql = "UPDATE notification SET status = ?, send_time = NOW(), updated_at = NOW() WHERE id = ?";
        } else {
            sql = "UPDATE notification SET status = ?, updated_at = NOW() WHERE id = ?";
        }
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("[CultureNotificationDao] updateNotificationStatus 错误：" + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /** 向所有目标用户发送通知 */
    public boolean sendNotificationToAll(Notification notification) {
        try {
            String targetType = notification.getTargetType();
            int recipientCount = 0;
            
            if ("all".equals(targetType)) {
                String countSql = "SELECT COUNT(*) FROM users";
                try (Connection conn = DBManager.getConnection();
                        PreparedStatement ps = conn.prepareStatement(countSql);
                        ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        recipientCount = rs.getInt(1);
                    }
                }
            } else if ("students".equals(targetType)) {
                String countSql = "SELECT COUNT(*) FROM users WHERE role = 'student'";
                try (Connection conn = DBManager.getConnection();
                        PreparedStatement ps = conn.prepareStatement(countSql);
                        ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        recipientCount = rs.getInt(1);
                    }
                }
            } else if ("teachers".equals(targetType)) {
                String countSql = "SELECT COUNT(*) FROM users WHERE role = 'teacher'";
                try (Connection conn = DBManager.getConnection();
                        PreparedStatement ps = conn.prepareStatement(countSql);
                        ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        recipientCount = rs.getInt(1);
                    }
                }
            } else if ("vip".equals(targetType)) {
                String countSql = "SELECT COUNT(*) FROM users WHERE is_vip = 1";
                try (Connection conn = DBManager.getConnection();
                        PreparedStatement ps = conn.prepareStatement(countSql);
                        ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        recipientCount = rs.getInt(1);
                    }
                }
            }
            
            notification.setTotalRecipients(recipientCount);
            notification.setSendTime(new java.sql.Timestamp(System.currentTimeMillis()));
            
            return true;
        } catch (Exception e) {
            System.err.println("[CultureNotificationDao] sendNotificationToAll 错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ========== 用户端通知 API 方法 ==========

    /** 确保 user_notification_read 表存在并包含所需列 */
    private void ensureHiddenColumn() throws ClassNotFoundException {
        // 第1步：检查表是否存在，不存在则创建
        try (Connection conn = DBManager.getConnection();
                PreparedStatement chk = conn.prepareStatement(
                        "SHOW TABLES LIKE 'user_notification_read'");
                java.sql.ResultSet rs = chk.executeQuery()) {
            if (!rs.next()) {
                // 表不存在，创建
                try (java.sql.Statement st = conn.createStatement()) {
                    st.execute("CREATE TABLE IF NOT EXISTS user_notification_read ("
                            + "id BIGINT PRIMARY KEY AUTO_INCREMENT,"
                            + "user_id VARCHAR(50) NOT NULL COMMENT '用户ID',"
                            + "notification_id BIGINT NOT NULL COMMENT '通知ID',"
                            + "is_read TINYINT(1) DEFAULT 0 COMMENT '是否已读：0未读 1已读',"
                            + "is_hidden TINYINT(1) DEFAULT 0 COMMENT '是否对用户隐藏',"
                            + "is_deleted_for_user TINYINT(1) DEFAULT 0 COMMENT '用户是否删除了此通知',"
                            + "read_at DATETIME DEFAULT NULL COMMENT '阅读时间',"
                            + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"
                            + "UNIQUE KEY uk_user_notification (user_id, notification_id),"
                            + "INDEX idx_user (user_id),"
                            + "INDEX idx_notification (notification_id)"
                            + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='user notification read table'");
                    System.out.println("[CultureNotificationDao] 已自动创建 user_notification_read 表");
                }
                return; // 刚创建的表已包含所需列，无需再检查列
            }
        } catch (SQLException e) {
            System.err.println("[CultureNotificationDao] 检查/创建 user_notification_read 表失败: " + e.getMessage());
        }
        // 第2步：表已存在，检查 is_hidden 列
        try (Connection conn = DBManager.getConnection();
                PreparedStatement chk = conn.prepareStatement(
                        "SHOW COLUMNS FROM user_notification_read LIKE 'is_hidden'");
                java.sql.ResultSet rs = chk.executeQuery()) {
            if (!rs.next()) {
                try (java.sql.Statement st = conn.createStatement()) {
                    st.execute("ALTER TABLE user_notification_read ADD COLUMN is_hidden TINYINT(1) DEFAULT 0");
                }
            }
        } catch (SQLException e) {
            System.err.println("[CultureNotificationDao] 添加 is_hidden 列失败: " + e.getMessage());
        }
        // 第3步：检查 is_deleted_for_user 列
        try (Connection conn = DBManager.getConnection();
                PreparedStatement chk = conn.prepareStatement(
                        "SHOW COLUMNS FROM user_notification_read LIKE 'is_deleted_for_user'");
                java.sql.ResultSet rs = chk.executeQuery()) {
            if (!rs.next()) {
                try (java.sql.Statement st = conn.createStatement()) {
                    st.execute(
                            "ALTER TABLE user_notification_read ADD COLUMN is_deleted_for_user TINYINT(1) DEFAULT 0");
                }
            }
        } catch (SQLException e) {
            System.err.println("[CultureNotificationDao] 添加 is_deleted_for_user 列失败: " + e.getMessage());
        }
    }

    /** 获取当前用户的通知列表（已发送的、未被该用户删除的），附阅读状态，支持分页 */
    public java.util.ArrayList<Notification> getNotificationsForUser(String userId)
            throws ClassNotFoundException, SQLException {
        return getNotificationsForUser(userId, 0, 50);
    }

    /** 获取当前用户的通知列表，支持分页（offset/limit） */
    public java.util.ArrayList<Notification> getNotificationsForUser(String userId, int offset, int limit)
            throws ClassNotFoundException, SQLException {
        ensureHiddenColumn();
        java.util.ArrayList<Notification> list = new java.util.ArrayList<>();
        String sql = "SELECT n.*, unr.is_read AS my_read, unr.is_deleted_for_user AS my_deleted "
                + "FROM notification n "
                + "LEFT JOIN user_notification_read unr "
                + "  ON n.id = unr.notification_id AND unr.user_id = ? "
                + "WHERE n.status = 'sent' "
                + "  AND (unr.is_deleted_for_user IS NULL OR unr.is_deleted_for_user = 0) "
                + "ORDER BY n.send_time DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setInt(2, limit);
            ps.setInt(3, offset);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setId(rs.getLong("id"));
                    n.setTitle(rs.getString("title"));
                    n.setContent(rs.getString("content"));
                    n.setNotificationType(rs.getString("notification_type"));
                    n.setTargetType(rs.getString("target_type"));
                    n.setSenderId(rs.getString("sender_id"));
                    n.setSendTime(rs.getTimestamp("send_time"));
                    n.setScheduledTime(rs.getTimestamp("scheduled_time"));
                    n.setStatus(rs.getString("status"));
                    n.setReadCount(rs.getInt("read_count"));
                    n.setTotalRecipients(rs.getInt("total_recipients"));
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    n.setUpdatedAt(rs.getTimestamp("updated_at"));
                    // 用 readCount 字段暂时存储当前用户是否已读 (1=已读, 0=未读)
                    int myRead = rs.getInt("my_read");
                    if (rs.wasNull())
                        myRead = 0;
                    n.setReadCount(myRead);
                    list.add(n);
                }
            }
        }
        return list;
    }

    /** 获取当前用户未读通知数 */
    public int getUnreadCountForUser(String userId) throws ClassNotFoundException {
        ensureHiddenColumn();
        String sql = "SELECT COUNT(*) AS cnt FROM notification n "
                + "LEFT JOIN user_notification_read unr "
                + "  ON n.id = unr.notification_id AND unr.user_id = ? "
                + "WHERE n.status = 'sent' "
                + "  AND (unr.id IS NULL OR unr.is_read IS NULL OR unr.is_read = 0) "
                + "  AND (unr.is_deleted_for_user IS NULL OR unr.is_deleted_for_user = 0)";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt("cnt");
            }
        } catch (SQLException e) {
            System.err.println("[CultureNotificationDao] getUnreadCountForUser 错误：" + e.getMessage());
        }
        return 0;
    }

    /** 标记该用户所有通知为已读 */
    public boolean markAllNotificationsRead(String userId) throws ClassNotFoundException {
        ensureHiddenColumn();
        // 对每条未读通知插入阅读记录
        String sql = "INSERT IGNORE INTO user_notification_read (user_id, notification_id, is_read, read_at) "
                + "SELECT ?, n.id, 1, NOW() FROM notification n "
                + "WHERE n.status = 'sent' "
                + "  AND n.id NOT IN (SELECT notification_id FROM user_notification_read WHERE user_id = ? AND is_read = 1)";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, userId);
            int affected = ps.executeUpdate();
            // 更新通知表的已读计数（不准确但可作参考）
            try (PreparedStatement up = conn.prepareStatement(
                    "UPDATE notification SET read_count = read_count + 1 WHERE id IN "
                            + "(SELECT notification_id FROM user_notification_read WHERE user_id = ? AND is_read = 1 AND is_hidden = 0)")) {
                up.setString(1, userId);
                up.executeUpdate();
            }
            return affected > 0;
        } catch (SQLException e) {
            System.err.println("[CultureNotificationDao] markAllNotificationsRead 错误：" + e.getMessage());
            return false;
        }
    }

    /** 用户隐藏（删除）一条通知 */
    public boolean hideNotificationForUser(long notificationId, String userId) throws ClassNotFoundException {
        ensureHiddenColumn();
        // 先看看是否有记录，有则更新，无则插入
        String sql = "INSERT INTO user_notification_read (user_id, notification_id, is_deleted_for_user, is_hidden, is_read, read_at) "
                + "VALUES (?, ?, 1, 1, 1, NOW()) "
                + "ON DUPLICATE KEY UPDATE is_deleted_for_user=1, is_hidden=1";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setLong(2, notificationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[CultureNotificationDao] hideNotificationForUser 错误：" + e.getMessage());
            return false;
        }
    }

    /** 用户删除所有已读通知 */
    public boolean hideAllReadNotifications(String userId) throws ClassNotFoundException {
        ensureHiddenColumn();
        String sql = "UPDATE user_notification_read SET is_deleted_for_user=1, is_hidden=1 "
                + "WHERE user_id = ? AND is_read = 1 AND (is_deleted_for_user IS NULL OR is_deleted_for_user = 0)";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("[CultureNotificationDao] hideAllReadNotifications 错误：" + e.getMessage());
            return false;
        }
    }

    /** 获取通知统计数据 */
    public java.util.Map<String, Object> getNotificationStats() throws ClassNotFoundException {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        String sql = "SELECT "
                + "COUNT(*) AS total, "
                + "SUM(CASE WHEN status = 'sent' THEN 1 ELSE 0 END) AS sent_count, "
                + "SUM(CASE WHEN status = 'scheduled' THEN 1 ELSE 0 END) AS scheduled_count, "
                + "SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) AS failed_count, "
                + "COALESCE(SUM(CASE WHEN status = 'sent' AND total_recipients > 0 "
                + "THEN read_count ELSE 0 END), 0) AS total_read, "
                + "COALESCE(SUM(CASE WHEN status = 'sent' AND total_recipients > 0 "
                + "THEN total_recipients ELSE 0 END), 0) AS total_recipients "
                + "FROM notification";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("sentCount", rs.getInt("sent_count"));
                stats.put("scheduledCount", rs.getInt("scheduled_count"));
                stats.put("failedCount", rs.getInt("failed_count"));
                int totalRead = rs.getInt("total_read");
                int totalRecipients = rs.getInt("total_recipients");
                stats.put("deliveryRate", totalRecipients > 0 ? Math.round(totalRead * 100.0 / totalRecipients) : 0);
            }
        } catch (SQLException e) {
            System.err.println("[CultureNotificationDao] getNotificationStats 错误：" + e.getMessage());
            stats.put("sentCount", 0);
            stats.put("scheduledCount", 0);
            stats.put("failedCount", 0);
            stats.put("deliveryRate", 0);
        }
        return stats;
    }
}
