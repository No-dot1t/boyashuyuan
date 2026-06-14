/**
 * ===========================================================================
 * BookRating —— 图书评分实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   book_rating
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列           说明
 * ----------------------------------------------------------------------
 * id            int             id              主键
 * bookId        long            book_id         图书ID
 * userId        String          user_id         用户ID
 * rating        int             rating          评分(1-5)
 * createdAt     Timestamp       created_at      创建时间
 * updatedAt     Timestamp       updated_at      更新时间
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

import java.sql.Timestamp;

public class BookRating {
    private int id;                         // 主键
    private long bookId;                    // 图书ID
    private String userId;                  // 用户ID
    private int rating;                     // 评分(1-5)
    private Timestamp createdAt;            // 创建时间
    private Timestamp updatedAt;            // 更新时间

    public BookRating() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public long getBookId() { return bookId; }
    public void setBookId(long bookId) { this.bookId = bookId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
