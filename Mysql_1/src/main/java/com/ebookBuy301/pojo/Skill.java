/**
 * ===========================================================================
 * Skill —— 技能实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   skill
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列           说明
 * ----------------------------------------------------------------------
 * id            int             id              主键
 * userId        String          user_id         用户ID
 * skillName     String          skill_name      技能名称
 * skillValue    int             skill_value     技能值(0-100)
 * skillColor    String          skill_color     颜色代码
 * createdAt     Timestamp       created_at      创建时间
 * updatedAt     Timestamp       updated_at      更新时间
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + 带参构造方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

import java.sql.Timestamp;

public class Skill {
    private int id;                         // 主键
    private String userId;                  // 用户ID
    private String skillName;               // 技能名称
    private int skillValue;                 // 技能值(0-100)
    private String skillColor;              // 颜色代码
    private Timestamp createdAt;            // 创建时间
    private Timestamp updatedAt;            // 更新时间

    public Skill() {}

    public Skill(String skillName, int skillValue, String skillColor) {
        this.skillName = skillName;
        this.skillValue = skillValue;
        this.skillColor = skillColor;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getSkillName() { return skillName; }
    public void setSkillName(String skillName) { this.skillName = skillName; }

    public int getSkillValue() { return skillValue; }
    public void setSkillValue(int skillValue) { this.skillValue = skillValue; }

    public String getSkillColor() { return skillColor; }
    public void setSkillColor(String skillColor) { this.skillColor = skillColor; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
