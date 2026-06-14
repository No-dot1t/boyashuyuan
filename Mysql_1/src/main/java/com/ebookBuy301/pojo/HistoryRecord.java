/**
 * ===========================================================================
 * HistoryRecord —— 历史记录实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   history_record
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列           说明
 * ----------------------------------------------------------------------
 * id            int             id              主键
 * year          String          year            年份
 * title         String          title           标题
 * description   String          description     描述
 * imageUrl      String          image_url       图片URL
 * sortOrder     int             sort_order      排序序号
 * isActive      boolean         is_active       是否启用
 * createdAt     Timestamp       created_at      创建时间
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + isActive() 判断方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

import java.sql.Timestamp;

public class HistoryRecord {
    private int id;                         // 主键
    private String year;                    // 年份
    private String title;                   // 标题
    private String description;             // 描述
    private String imageUrl;                // 图片URL
    private int sortOrder;                  // 排序序号
    private boolean isActive;               // 是否启用
    private Timestamp createdAt;            // 创建时间

    public HistoryRecord() {}

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getYear() { return year; }
    public void setYear(String year) { this.year = year; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
