/**
 * ===========================================================================
 * HomeNewsDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getAllPublishedNews()              查询操作
 * getTopNews()                       查询操作
 * getNewsByType(String newsType)     查询操作
 * getNewsById(long id)               查询操作
 * addNews(HomeNews news)             新增操作
 * updateNews(HomeNews news)          更新操作
 * deleteNews(long id)                删除操作
 * increaseViewCount(long id)         内部工具方法
 * extractHomeNews(ResultSet rs)      数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM home_news WHERE status = 'published' ORDER BY is_top DESC, publish_time DESC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) list.add(extractHomeNews(rs))
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM home_news WHERE is_top = 1 AND status = 'published' ORDER BY publish_time DESC LIMIT 5"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)
 *   rs = ps.executeQuery()) {
            while (rs.next()) list.add(extractHomeNews(rs))
 *   list = new ArrayList<>()
 *   sql = "SELECT * FROM home_news WHERE news_type = ? AND status = 'published' ORDER BY publish_time DESC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, newsType)
 *   rs = ps.executeQuery()) {
                while (rs.next()) list.add(extractHomeNews(rs))
 *   news = null
 *   sql = "SELECT * FROM home_news WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id)
 *   rs = ps.executeQuery()) {
                if (rs.next()) {
                    news = extractHomeNews(rs)
 *   sql = "INSERT INTO home_news (title, content, news_type, priority, cover_image, "
                   + "author, publish_time, is_top, view_count, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, news.getTitle())
 *   sql = "UPDATE home_news SET title=?, content=?, news_type=?, priority=?, "
                   + "cover_image=?, author=?, publish_time=?, is_top=?, status=? WHERE id=?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setString(1, news.getTitle())
 *   sql = "DELETE FROM home_news WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id)
 *   sql = "UPDATE home_news SET view_count = view_count + 1 WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id)
 *   n = new HomeNews()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   JDBC —— Connection / PreparedStatement / ResultSet 数据库访问
 *   ResultSet 行映射 —— 手动抽取字段 → POJO 对象
 *
 * ===========================================================================
 */

package com.ebookBuy301.dao;

import com.ebookBuy301.db.DBManager;
import com.ebookBuy301.pojo.HomeNews;

import java.sql.*;
import java.util.ArrayList;

/**
 * =============================================================================
 * HomeNewsDao —— 首页新闻数据访问层
 * =============================================================================
 *
 * 负责 home_news 表的增删改查操作。
 *
 * 方法索引：
 *   1. getAllPublishedNews()  → 获取所有已发布新闻
 *   2. getTopNews()          → 获取置顶新闻
 *   3. getNewsByType()       → 按类型查询
 *   4. getNewsById()         → 根据ID查询（自动增加浏览次数）
 *   5. addNews()             → 添加新闻
 *   6. updateNews()          → 更新新闻
 *   7. deleteNews()          → 删除新闻
 * =============================================================================
 */
public class HomeNewsDao {

    /**
     * 获取所有已发布（status='published'）的新闻记录。
     * <p>
     * 算法：SELECT * FROM home_news WHERE status='published' → 遍历 ResultSet → extractHomeNews() 逐行提取
     *
     * @return ArrayList<HomeNews> 新闻列表（置顶优先，按发布时间降序排序）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<HomeNews> getAllPublishedNews() throws ClassNotFoundException {
        ensureTableExists();
        ArrayList<HomeNews> list = new ArrayList<>();
        String sql = "SELECT * FROM home_news WHERE status = 'published' ORDER BY is_top DESC, publish_time DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(extractHomeNews(rs));
        } catch (SQLException e) {
            System.err.println("[HomeNewsDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * 获取置顶（is_top=1）且已发布（status='published'）的新闻记录。
     * <p>
     * 算法：PreparedStatement 筛选 → 遍历 ResultSet → extractHomeNews() 逐行提取
     *
     * @return ArrayList<HomeNews> 置顶新闻列表（按发布时间降序，最多5条）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<HomeNews> getTopNews() throws ClassNotFoundException {
        ArrayList<HomeNews> list = new ArrayList<>();
        String sql = "SELECT * FROM home_news WHERE is_top = 1 AND status = 'published' ORDER BY publish_time DESC LIMIT 5";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(extractHomeNews(rs));
        } catch (SQLException e) {
            System.err.println("[HomeNewsDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * 按新闻类型查询已发布（status='published'）的新闻记录。
     * <p>
     * 算法：PreparedStatement 参数化查询 → 遍历 ResultSet → extractHomeNews() 逐行提取
     *
     * @param newsType 新闻类型（如 notice/activity 等）
     * @return ArrayList<HomeNews> 新闻列表（按发布时间降序排序）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<HomeNews> getNewsByType(String newsType) throws ClassNotFoundException {
        ArrayList<HomeNews> list = new ArrayList<>();
        String sql = "SELECT * FROM home_news WHERE news_type = ? AND status = 'published' ORDER BY publish_time DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newsType);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(extractHomeNews(rs));
            }
        } catch (SQLException e) {
            System.err.println("[HomeNewsDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * 根据新闻ID查询单个新闻记录，并自动增加浏览次数。
     * <p>
     * 算法：PreparedStatement 参数化查询 → extractHomeNews() 提取单行 → increaseViewCount() 递增浏览数
     *
     * @param id 新闻ID
     * @return HomeNews 新闻对象；未找到返回 null
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public HomeNews getNewsById(long id) throws ClassNotFoundException {
        HomeNews news = null;
        String sql = "SELECT * FROM home_news WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    news = extractHomeNews(rs);
                    increaseViewCount(id);
                }
            }
        } catch (SQLException e) {
            System.err.println("[HomeNewsDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return news;
    }

    /**
     * 添加新新闻记录。
     * <p>
     * 算法：INSERT INTO home_news → PreparedStatement 设置10个字段 → executeUpdate() > 0
     *
     * @param news 待添加的HomeNews对象
     * @return boolean true=添加成功，false=添加失败
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public boolean addNews(HomeNews news) throws ClassNotFoundException {
        String sql = "INSERT INTO home_news (title, content, news_type, priority, cover_image, "
                   + "author, publish_time, is_top, view_count, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, news.getTitle());
            ps.setString(2, news.getContent());
            ps.setString(3, news.getNewsType());
            ps.setString(4, news.getPriority());
            ps.setString(5, news.getCoverImage());
            ps.setString(6, news.getAuthor());
            ps.setTimestamp(7, news.getPublishTime());
            ps.setBoolean(8, news.isTop());
            ps.setInt(9, news.getViewCount());
            ps.setString(10, news.getStatus() != null ? news.getStatus() : "published");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[HomeNewsDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 更新已有新闻记录（不含浏览次数）。
     * <p>
     * 算法：UPDATE home_news SET 9个字段 → PreparedStatement 设置字段+WHERE条件 → executeUpdate() > 0
     *
     * @param news 待更新的HomeNews对象（id为必填定位条件）
     * @return boolean true=更新成功，false=更新失败
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public boolean updateNews(HomeNews news) throws ClassNotFoundException {
        String sql = "UPDATE home_news SET title=?, content=?, news_type=?, priority=?, "
                   + "cover_image=?, author=?, publish_time=?, is_top=?, status=? WHERE id=?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, news.getTitle());
            ps.setString(2, news.getContent());
            ps.setString(3, news.getNewsType());
            ps.setString(4, news.getPriority());
            ps.setString(5, news.getCoverImage());
            ps.setString(6, news.getAuthor());
            ps.setTimestamp(7, news.getPublishTime());
            ps.setBoolean(8, news.isTop());
            ps.setString(9, news.getStatus());
            ps.setLong(10, news.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[HomeNewsDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 根据新闻ID删除新闻记录。
     * <p>
     * 算法：DELETE FROM home_news WHERE id=? → PreparedStatement 设置参数 → executeUpdate() > 0
     *
     * @param id 待删除的新闻ID
     * @return boolean true=删除成功，false=删除失败
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public boolean deleteNews(long id) throws ClassNotFoundException {
        String sql = "DELETE FROM home_news WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[HomeNewsDao] SQL错误：" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ════════════════════════════════════════════════════════════════════
    //  递增新闻浏览次数（内部工具方法）
    //   步骤：UPDATE home_news SET view_count+1 WHERE id=?
    // ════════════════════════════════════════════════════════════════════
    private void increaseViewCount(long id) throws SQLException {
        String sql = "UPDATE home_news SET view_count = view_count + 1 WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.executeUpdate();
        }
    }

    // ════════════════════════════════════════════════════════════════════
    //  确保 home_news 表存在（自动建表）
    //   步骤：CREATE TABLE IF NOT EXISTS home_news
    // ════════════════════════════════════════════════════════════════════
    private void ensureTableExists() {
        String sql = "CREATE TABLE IF NOT EXISTS home_news ("
                   + "id BIGINT AUTO_INCREMENT PRIMARY KEY,"
                   + "title VARCHAR(200) NOT NULL,"
                   + "content TEXT,"
                   + "news_type VARCHAR(50) DEFAULT 'notice',"
                   + "priority VARCHAR(10) DEFAULT 'normal',"
                   + "cover_image VARCHAR(500),"
                   + "author VARCHAR(100),"
                   + "publish_time DATETIME DEFAULT CURRENT_TIMESTAMP,"
                   + "is_top TINYINT(1) DEFAULT 0,"
                   + "view_count INT DEFAULT 0,"
                   + "status VARCHAR(20) DEFAULT 'published',"
                   + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"
                   + "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"
                   + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.execute();
        } catch (Exception e) {
            System.err.println("[HomeNewsDao] 建表失败：" + e.getMessage());
        }
    }

    // ════════════════════════════════════════════════════════════════════
    //  从 ResultSet 提取 HomeNews 对象
    //   步骤：rs.getLong("id") → new HomeNews() → setXxx()
    // ════════════════════════════════════════════════════════════════════
    private HomeNews extractHomeNews(ResultSet rs) throws SQLException {
        HomeNews n = new HomeNews();
        n.setId(rs.getLong("id"));
        n.setTitle(rs.getString("title"));
        n.setContent(rs.getString("content"));
        n.setNewsType(rs.getString("news_type"));
        n.setPriority(rs.getString("priority"));
        n.setCoverImage(rs.getString("cover_image"));
        n.setAuthor(rs.getString("author"));
        n.setPublishTime(rs.getTimestamp("publish_time"));
        n.setTop(rs.getBoolean("is_top"));
        n.setViewCount(rs.getInt("view_count"));
        n.setStatus(rs.getString("status"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        n.setUpdatedAt(rs.getTimestamp("updated_at"));
        return n;
    }
}
