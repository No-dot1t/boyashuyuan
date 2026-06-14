/**
 * ===========================================================================
 * CultureEvent —— 文化活动实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   culture_event
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列           说明
 * ----------------------------------------------------------------------
 * id            int             id              主键
 * season        String          season          季节/学期
 * eventName     String          event_name      活动名称
 * description   String          description     活动描述
 * eventType     String          event_type      活动类型
 * eventDate     Date            event_date      活动日期
 * location      String          location        活动地点
 * imageUrl      String          image_url       活动图片URL
 * isActive      boolean         is_active       是否启用
 * sortOrder     int             sort_order      排序序号
 * createdAt     Timestamp       created_at      创建时间
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + isActive() 判断方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

import java.sql.Date;
import java.sql.Timestamp;

public class CultureEvent {
    private int id;                         // 主键
    private String season;                  // 季节/学期
    private String eventName;               // 活动名称
    private String description;             // 活动描述
    private String eventType;               // 活动类型
    private Date eventDate;                 // 活动日期
    private String location;                // 活动地点
    private String imageUrl;                // 活动图片URL
    private boolean isActive;               // 是否启用
    private int sortOrder;                  // 排序序号
    private Timestamp createdAt;            // 创建时间

    public CultureEvent() {}

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getSeason() { return season; }
    public void setSeason(String season) { this.season = season; }

    public String getEventName() { return eventName; }
    public void setEventName(String eventName) { this.eventName = eventName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getEventType() { return eventType; }
    public void setEventType(String eventType) { this.eventType = eventType; }

    public Date getEventDate() { return eventDate; }
    public void setEventDate(Date eventDate) { this.eventDate = eventDate; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
