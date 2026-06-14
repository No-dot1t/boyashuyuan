/**
 * ===========================================================================
 * Alumni —— 校友信息实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   alumni
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列           说明
 * ----------------------------------------------------------------------
 * id            int             id              主键
 * name          String          name            校友姓名
 * title         String          title           头衔/职称
 * achievement   String          achievement     成就描述
 * avatarUrl     String          avatar_url      头像URL
 * company       String          company         所属公司
 * graduationYear Integer        graduation_year 毕业年份
 * major         String          major           专业
 * isHonorary    boolean         is_honorary     是否荣誉校友
 * sortOrder     int             sort_order      排序序号
 * isActive      boolean         is_active       是否启用
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + isHonorary()/isActive() 判断方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

public class Alumni {
    private int id;                         // 主键
    private String name;                    // 校友姓名
    private String title;                   // 头衔/职称
    private String achievement;             // 成就描述
    private String avatarUrl;               // 头像URL
    private String company;                 // 所属公司
    private Integer graduationYear;         // 毕业年份
    private String major;                   // 专业
    private boolean isHonorary;             // 是否荣誉校友
    private int sortOrder;                  // 排序序号
    private boolean isActive;               // 是否启用

    public Alumni() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getAchievement() { return achievement; }
    public void setAchievement(String achievement) { this.achievement = achievement; }

    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }

    public String getCompany() { return company; }
    public void setCompany(String company) { this.company = company; }

    public Integer getGraduationYear() { return graduationYear; }
    public void setGraduationYear(Integer graduationYear) { this.graduationYear = graduationYear; }

    public String getMajor() { return major; }
    public void setMajor(String major) { this.major = major; }

    public boolean isHonorary() { return isHonorary; }
    public void setHonorary(boolean honorary) { isHonorary = honorary; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
}
