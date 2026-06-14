/**
 * ===========================================================================
 * Major —— 学域信息实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   major
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段               类型            对应列               说明
 * ----------------------------------------------------------------------
 * id                int             id                  主键
 * name              String          name                学域名称
 * code              String          code                学域编号
 * icon              String          icon                图标
 * description       String          description         学域描述
 * category          String          category            分类
 * isInterdisciplinary boolean       is_interdisciplinary 是否跨学科
 * department        String          department          所属院系
 * degreeType        String          degree_type         学位类型
 * duration          int             duration            学制年限
 * sortOrder         int             sort_order          排序序号
 * isActive          boolean         is_active           是否启用
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + isInterdisciplinary()/isActive() 判断方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

public class Major {
    private int id;                         // 主键
    private String name;                    // 学域名称
    private String code;                    // 学域编号
    private String icon;                    // 图标
    private String description;             // 学域描述
    private String category;                // 分类
    private boolean isInterdisciplinary;    // 是否跨学科
    private String department;              // 所属院系
    private String degreeType;              // 学位类型
    private int duration;                   // 学制年限
    private int sortOrder;                  // 排序序号
    private boolean isActive;               // 是否启用

    public Major() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public boolean isInterdisciplinary() { return isInterdisciplinary; }
    public void setInterdisciplinary(boolean interdisciplinary) { isInterdisciplinary = interdisciplinary; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getDegreeType() { return degreeType; }
    public void setDegreeType(String degreeType) { this.degreeType = degreeType; }

    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
}
