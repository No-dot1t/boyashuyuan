/**
 * ===========================================================================
 * StudyGroup —— 学习小组实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   study_group
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列           说明
 * ----------------------------------------------------------------------
 * id            int             id              主键
 * name          String          name            小组名称
 * icon          String          icon            图标
 * description   String          description     小组描述
 * creatorId     String          creator_id      创建者ID
 * memberCount   int             member_count    成员数量
 * createdAt     Timestamp       created_at      创建时间
 * isActive      boolean         is_active       是否启用
 * joined        boolean         -               当前用户是否已加入(非DB字段)
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + isActive()/isJoined() 判断方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

import java.sql.Timestamp;

public class StudyGroup {
    private int id;                         // 主键
    private String name;                    // 小组名称
    private String icon;                    // 图标
    private String description;             // 小组描述
    private String creatorId;               // 创建者ID
    private int memberCount;                // 成员数量
    private Timestamp createdAt;            // 创建时间
    private boolean isActive;               // 是否启用
    private boolean joined;                 // 当前用户是否已加入(非DB字段)

    public StudyGroup() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getCreatorId() { return creatorId; }
    public void setCreatorId(String creatorId) { this.creatorId = creatorId; }
    public int getMemberCount() { return memberCount; }
    public void setMemberCount(int memberCount) { this.memberCount = memberCount; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    public boolean isJoined() { return joined; }
    public void setJoined(boolean joined) { this.joined = joined; }
}
