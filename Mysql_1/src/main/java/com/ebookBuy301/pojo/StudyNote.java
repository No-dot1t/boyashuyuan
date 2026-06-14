/**
 * ===========================================================================
 * StudyNote —— 学习笔记实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   study_note
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列           说明
 * ----------------------------------------------------------------------
 * id            int             id              主键
 * userId        String          user_id         用户ID
 * bookId        Integer         book_id         图书ID(可为空)
 * courseId      Integer         course_id       课程ID(可为空)
 * title         String          title           笔记标题
 * content       String          content         笔记内容
 * tags          String          tags            标签(逗号分隔)
 * isPinned      boolean         is_pinned       是否置顶
 * isPublic      boolean         is_public       是否公开
 * createdAt     Timestamp       created_at      创建时间
 * updatedAt     Timestamp       updated_at      更新时间
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + isPinned()/isPublic() 判断方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

import java.sql.Timestamp;

public class StudyNote {
    private int id;                         // 主键
    private String userId;                  // 用户ID
    private Integer bookId;                 // 图书ID(可为空)
    private Integer courseId;               // 课程ID(可为空)
    private String title;                   // 笔记标题
    private String content;                 // 笔记内容
    private String tags;                    // 标签(逗号分隔)
    private boolean isPinned;               // 是否置顶
    private boolean isPublic;               // 是否公开
    private Timestamp createdAt;            // 创建时间
    private Timestamp updatedAt;            // 更新时间

    public StudyNote() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public Integer getBookId() { return bookId; }
    public void setBookId(Integer bookId) { this.bookId = bookId; }
    public Integer getCourseId() { return courseId; }
    public void setCourseId(Integer courseId) { this.courseId = courseId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getTags() { return tags; }
    public void setTags(String tags) { this.tags = tags; }
    public boolean isPinned() { return isPinned; }
    public void setPinned(boolean pinned) { isPinned = pinned; }
    public boolean isPublic() { return isPublic; }
    public void setPublic(boolean aPublic) { isPublic = aPublic; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
