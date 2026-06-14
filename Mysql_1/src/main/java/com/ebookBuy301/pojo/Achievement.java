/**
 * ===========================================================================
 * Achievement —— 成就实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   achievement
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型                对应列            说明
 * ----------------------------------------------------------------------
 * id            int                 id              主键
 * icon          String              icon            图标
 * name          String              name            成就名称
 * description   String              description     成就描述
 * conditionType String              condition_type  条件类型
 * conditionValue int                condition_value 条件值
 * sortOrder     int                 sort_order      排序序号
 * earned        boolean             -               是否已获得(非DB字段)
 * earnedAt      java.sql.Timestamp  -               获得时间(非DB字段)
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + isEarned() 判断方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

public class Achievement {
    private int id;                         // 主键
    private String icon;                    // 图标
    private String name;                    // 成就名称
    private String description;             // 成就描述
    private String conditionType;           // 条件类型
    private int conditionValue;             // 条件值
    private int sortOrder;                  // 排序序号
    private boolean earned;                 // 是否已获得(非DB字段)
    private java.sql.Timestamp earnedAt;    // 获得时间(非DB字段)

    public Achievement() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getConditionType() { return conditionType; }
    public void setConditionType(String conditionType) { this.conditionType = conditionType; }
    public int getConditionValue() { return conditionValue; }
    public void setConditionValue(int conditionValue) { this.conditionValue = conditionValue; }
    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }
    public boolean isEarned() { return earned; }
    public void setEarned(boolean earned) { this.earned = earned; }
    public java.sql.Timestamp getEarnedAt() { return earnedAt; }
    public void setEarnedAt(java.sql.Timestamp earnedAt) { this.earnedAt = earnedAt; }
}
