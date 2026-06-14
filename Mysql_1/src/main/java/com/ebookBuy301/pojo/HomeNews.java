/**
 * ===========================================================================
 * HomeNews —— 首页资讯实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   home_news
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列           说明
 * ----------------------------------------------------------------------
 * id            long            id              主键
 * title         String          title           标题
 * content       String          content         内容
 * newsType      String          news_type       资讯类型(news/announcement/event)
 * priority      String          priority        优先级(low/normal/high/urgent)
 * coverImage    String          cover_image     封面图片
 * author        String          author          作者
 * publishTime   Timestamp       publish_time    发布时间
 * isTop         boolean         is_top          是否置顶
 * viewCount     int             view_count      浏览次数
 * status        String          status          状态(draft/published/archived)
 * createdAt     Timestamp       created_at      创建时间
 * updatedAt     Timestamp       updated_at      更新时间
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + isTop() 判断方法 + toString()
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

import java.sql.Timestamp;

public class HomeNews {
    private long id;                        // 主键
    private String title;                   // 标题
    private String content;                 // 内容
    private String newsType;                // 资讯类型(news/announcement/event)
    private String priority;                // 优先级(low/normal/high/urgent)
    private String coverImage;              // 封面图片
    private String author;                  // 作者
    private Timestamp publishTime;          // 发布时间
    private boolean isTop;                  // 是否置顶
    private int viewCount;                  // 浏览次数
    private String status;                  // 状态(draft/published/archived)
    private Timestamp createdAt;            // 创建时间
    private Timestamp updatedAt;            // 更新时间

    public HomeNews() {
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getNewsType() {
        return newsType;
    }

    public void setNewsType(String newsType) {
        this.newsType = newsType;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public String getCoverImage() {
        return coverImage;
    }

    public void setCoverImage(String coverImage) {
        this.coverImage = coverImage;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public Timestamp getPublishTime() {
        return publishTime;
    }

    public void setPublishTime(Timestamp publishTime) {
        this.publishTime = publishTime;
    }

    public boolean isTop() {
        return isTop;
    }

    public void setTop(boolean top) {
        isTop = top;
    }

    public int getViewCount() {
        return viewCount;
    }

    public void setViewCount(int viewCount) {
        this.viewCount = viewCount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    @Override
    public String toString() {
        return "HomeNews{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", newsType='" + newsType + '\'' +
                ", priority='" + priority + '\'' +
                ", author='" + author + '\'' +
                ", isTop=" + isTop +
                ", viewCount=" + viewCount +
                ", status='" + status + '\'' +
                '}';
    }
}
