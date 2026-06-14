/**
 * ===========================================================================
 * BookType —— 业务逻辑类
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.pojo
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getbTid()                          查询操作
 * setbTid(String bTid)               更新操作
 * getbTypeName()                     查询操作
 * setbTypeName(String bTypeName)     更新操作
 * getBtText()                        查询操作
 * setBtText(String btText)           更新操作
 * getbTPerentId()                    查询操作
 * setbTPerentId(String bTPerentId)   更新操作
 * getParentName()                    查询操作
 * setParentName(String parentName)   更新操作
 * isTopLevel()                       内部工具方法
 * getDisplayName()                   查询操作
 * toString()                         对象字符串表示
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   bTPerentId = = null || bTPerentId.trim().isEmpty()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   标准 Java 语法 + JDK 内置 API
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

/**
 * BookType 图书分类实体类
 * 用于存储图书分类信息，对应数据库中的 booktype 表
 * 支持多级分类（树形结构）
 * 
 * 字段说明：
 * - bTid        : 分类ID（主键，VARCHAR）
 * - bTypeName   : 分类名称
 * - btText      : 分类描述
 * - bTPerentId  : 父分类ID（空字符串=顶级分类）
 */
public class BookType {

    // ==================== 私有属性（对应数据库字段） ====================
    
    private String bTid;              // 分类唯一标识ID (VARCHAR)
    private String bTypeName;         // 分类名称
    private String btText;            // 分类描述
    private String bTPerentId;        // 父分类ID（空或null=顶级分类）
    private String parentName;        // 父分类名称（非数据库字段，用于展示）

    // Getter & Setter
    public String getbTid() {
        return bTid;
    }

    public void setbTid(String bTid) {
        this.bTid = bTid;
    }

    public String getbTypeName() {
        return bTypeName;
    }

    public void setbTypeName(String bTypeName) {
        this.bTypeName = bTypeName;
    }

    public String getBtText() {
        return btText;
    }

    public void setBtText(String btText) {
        this.btText = btText;
    }

    public String getbTPerentId() {
        return bTPerentId;
    }

    public void setbTPerentId(String bTPerentId) {
        this.bTPerentId = bTPerentId;
    }

    public String getParentName() {
        return parentName;
    }

    public void setParentName(String parentName) {
        this.parentName = parentName;
    }

    /**
     * 判断是否为顶级分类
     */
    public boolean isTopLevel() {
        return bTPerentId == null || bTPerentId.trim().isEmpty();
    }

    /**
     * 获取显示用的层级名称
     * 格式：顶级分类直接显示名称，子分类显示为 "父分类名 > 子分类名"
     */
    public String getDisplayName() {
        if (isTopLevel() || parentName == null || parentName.isEmpty()) {
            return bTypeName;
        }
        return parentName + " > " + bTypeName;
    }

    public BookType() {
    }

    public BookType(String bTid, String bTypeName, String btText, String bTPerentId) {
        this.bTid = bTid;
        this.bTypeName = bTypeName;
        this.btText = btText;
        this.bTPerentId = bTPerentId;
    }

    @Override
    public String toString() {
        return "BookType{" +
                "bTid='" + bTid + '\'' +
                ", bTypeName='" + bTypeName + '\'' +
                ", btText='" + btText + '\'' +
                ", bTPerentId='" + bTPerentId + '\'' +
                ", parentName='" + parentName + '\'' +
                '}';
    }
}
