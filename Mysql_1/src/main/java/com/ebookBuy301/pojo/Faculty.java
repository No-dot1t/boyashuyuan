/**
 * ===========================================================================
 * Faculty —— 师资信息实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   faculty
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列           说明
 * ----------------------------------------------------------------------
 * id            int             id              主键
 * name          String          name            姓名
 * title         String          title           职称/头衔
 * avatarIcon    String          avatar_icon     头像图标
 * researchArea  String          research_area   研究领域
 * department    String          department      所属院系
 * email         String          email           电子邮箱
 * office        String          office          办公室
 * officeHours   String          office_hours    办公时间
 * bio           String          bio             个人简介
 * sortOrder     int             sort_order      排序序号
 * isActive      boolean         is_active       是否启用
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + isActive() 判断方法 + toString()
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

public class Faculty {
    private int id;                         // 主键
    private String name;                    // 姓名
    private String title;                   // 职称/头衔
    private String avatarIcon;              // 头像图标
    private String researchArea;            // 研究领域
    private String department;              // 所属院系
    private String email;                   // 电子邮箱
    private String office;                  // 办公室
    private String officeHours;             // 办公时间
    private String bio;                     // 个人简介
    private int sortOrder;                  // 排序序号
    private boolean isActive;               // 是否启用

    public Faculty() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getAvatarIcon() {
        return avatarIcon;
    }

    public void setAvatarIcon(String avatarIcon) {
        this.avatarIcon = avatarIcon;
    }

    public String getResearchArea() {
        return researchArea;
    }

    public void setResearchArea(String researchArea) {
        this.researchArea = researchArea;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getOffice() {
        return office;
    }

    public void setOffice(String office) {
        this.office = office;
    }

    public String getOfficeHours() {
        return officeHours;
    }

    public void setOfficeHours(String officeHours) {
        this.officeHours = officeHours;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    @Override
    public String toString() {
        return "Faculty{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", title='" + title + '\'' +
                ", department='" + department + '\'' +
                ", email='" + email + '\'' +
                '}';
    }
}
