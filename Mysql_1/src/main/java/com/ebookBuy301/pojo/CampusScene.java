/**
 * ===========================================================================
 * CampusScene —— 校园场景实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   campus_scene
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列           说明
 * ----------------------------------------------------------------------
 * id            int             id              主键
 * name          String          name            场景名称
 * sceneKey      String          scene_key       场景标识键
 * icon          String          icon            图标
 * description   String          description     场景描述
 * sceneType     String          scene_type      场景类型
 * features      String          features        功能特性(JSON数组)
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

import java.sql.Timestamp;

public class CampusScene {
    private int id;                         // 主键
    private String name;                    // 场景名称
    private String sceneKey;                // 场景标识键
    private String icon;                    // 图标
    private String description;             // 场景描述
    private String sceneType;               // 场景类型
    private String features;                // 功能特性(JSON数组)
    private boolean isActive;               // 是否启用
    private int sortOrder;                  // 排序序号
    private Timestamp createdAt;            // 创建时间

    public CampusScene() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getSceneKey() { return sceneKey; }
    public void setSceneKey(String sceneKey) { this.sceneKey = sceneKey; }
    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getSceneType() { return sceneType; }
    public void setSceneType(String sceneType) { this.sceneType = sceneType; }
    public String getFeatures() { return features; }
    public void setFeatures(String features) { this.features = features; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
