/**
 * ===========================================================================
 * RecommendItem —— 推荐结果POJO / 非数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   - (非DB表,推荐算法结果封装)
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列           说明
 * ----------------------------------------------------------------------
 * id            int             id              主键
 * refId         String          ref_id          引用ID(用于跳转)
 * title         String          title           标题
 * category      String          category        分类
 * description   String          description     描述
 * type          String          type            类型(courses/books/lectures/articles)
 * badge         String          badge           标签
 * author        String          author          作者/讲师
 * metaInfo      String          meta_info       元信息(课时/页数等)
 * rating        BigDecimal      rating          评分
 * actionText    String          action_text     按钮文字
 * coverImage    String          cover_image     封面图片路径
 * sortOrder     int             sort_order      排序序号
 * isActive      boolean         is_active       是否启用
 * createdAt     Timestamp       created_at      创建时间
 * updatedAt     Timestamp       updated_at      更新时间
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + isActive() 判断方法 + 带参构造方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class RecommendItem {
    private int id;                         // 主键
    private String refId;                   // 引用ID(用于跳转)
    private String title;                   // 标题
    private String category;                // 分类
    private String description;             // 描述
    private String type;                    // 类型(courses/books/lectures/articles)
    private String badge;                   // 标签
    private String author;                  // 作者/讲师
    private String metaInfo;                // 元信息(课时/页数等)
    private BigDecimal rating;              // 评分
    private String actionText;              // 按钮文字
    private String coverImage;              // 封面图片路径
    private int sortOrder;                  // 排序序号
    private boolean isActive;               // 是否启用
    private Timestamp createdAt;            // 创建时间
    private Timestamp updatedAt;            // 更新时间

    public RecommendItem() {
    }

    public RecommendItem(String type, String title, String category, String badge,
            String description, String author, String metaInfo,
            BigDecimal rating, String actionText) {
        this.type = type;
        this.title = title;
        this.category = category;
        this.badge = badge;
        this.description = description;
        this.author = author;
        this.metaInfo = metaInfo;
        this.rating = rating;
        this.actionText = actionText;
        this.isActive = true;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getRefId() {
        return refId;
    }

    public void setRefId(String refId) {
        this.refId = refId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getBadge() {
        return badge;
    }

    public void setBadge(String badge) {
        this.badge = badge;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getMetaInfo() {
        return metaInfo;
    }

    public void setMetaInfo(String metaInfo) {
        this.metaInfo = metaInfo;
    }

    public BigDecimal getRating() {
        return rating;
    }

    public void setRating(BigDecimal rating) {
        this.rating = rating;
    }

    public String getActionText() {
        return actionText;
    }

    public void setActionText(String actionText) {
        this.actionText = actionText;
    }

    public String getCoverImage() {
        return coverImage;
    }

    public void setCoverImage(String coverImage) {
        this.coverImage = coverImage;
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

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
