/**
 * ===========================================================================
 * BookReview —— 图书评论实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   book_review
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列           说明
 * ----------------------------------------------------------------------
 * id            int             id              主键
 * bookId        long            book_id         图书ID
 * userId        String          user_id         用户ID
 * content       String          content         评论内容
 * createdAt     Timestamp       created_at      评论时间
 * username      String          -               用户名(非DB字段,用于展示)
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

import java.sql.Timestamp;

public class BookReview {
    private int id;                         // 主键
    private long bookId;                    // 图书ID
    private String userId;                  // 用户ID
    private String content;                 // 评论内容
    private Timestamp createdAt;            // 评论时间
    private String username;                // 用户名(非DB字段,用于展示)

    public BookReview() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public long getBookId() { return bookId; }
    public void setBookId(long bookId) { this.bookId = bookId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
}
