/**
 * ===========================================================================
 * BookActionServlet —— Servlet 控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * doGet(HttpServletRequest request, HttpServletResponse response)HTTP 请求处理入口
 * doPost(HttpServletRequest request, HttpServletResponse response)HTTP 请求处理入口
 * getUserId(HttpServletRequest request)查询操作
 * sendError(HttpServletResponse response, String msg)内部工具方法
 * getChapterContent(long bookId, int chapterNum)查询操作
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   ratingDao = new BookRatingDao()
 *   reviewDao = new BookReviewDao()
 *   bookmarkDao = new UserBookmarkDao()
 *   activityDao = new UserActivityDao()
 *   action = request.getParameter("action")
 *   bookId = Long.parseLong(request.getParameter("bookId"))
 *   userId = getUserId(request)
 *   result = new HashMap<>()
 *   userRating = ratingDao.getUserRating(bookId, userId)
 *   chapterNum = Integer.parseInt(request.getParameter("chapterNum"))
 *   action = request.getParameter("action")
 *   userId = getUserId(request)
 *   result = new HashMap<>()
 *   bookId = Long.parseLong(request.getParameter("bookId"))
 *   rating = Integer.parseInt(request.getParameter("rating"))
 *   ok = ratingDao.rateBook(bookId, userId, rating)
 *   bookId = Long.parseLong(request.getParameter("bookId"))
 *   content = request.getParameter("content")
 *   ok = reviewDao.addReview(bookId, userId, content)
 *   bookId = Long.parseLong(request.getParameter("bookId"))
 *   bookmarked = bookmarkDao.toggleBookmark(userId, bookId)
 *   user = (Users) request.getSession().getAttribute("currentUser")
 *   err = new HashMap<>()
 *   sql = "SELECT id, chapter_num, chapter_title, word_count FROM book_content WHERE book_id = ? ORDER BY sort_order"
 *   conn = com.ebookBuy301.db.DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId)
 *   rs = ps.executeQuery()
 *   ch = new HashMap<>()
 *   ch = new HashMap<>()
 *   sql = "SELECT id, chapter_num, chapter_title, content, word_count FROM book_content WHERE book_id = ? AND chapter_num = ?"
 *   conn = com.ebookBuy301.db.DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId)
 *   rs = ps.executeQuery()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   @WebServlet —— 注解式 Servlet 路由映射
 *   Servlet API —— HttpServlet / HttpServletRequest / HttpServletResponse
 *   JDBC —— Connection / PreparedStatement / ResultSet 数据库访问
 *   doGet() —— GET 请求分发
 *   doPost() —— POST 请求分发
 *   action 参数分发模式 —— 通过 request.getParameter("action") 分流操作
 *
 * ===========================================================================
 */

package com.ebookBuy301;

import com.alibaba.fastjson.JSON;
import com.ebookBuy301.dao.BookRatingDao;
import com.ebookBuy301.dao.BookReviewDao;
import com.ebookBuy301.dao.UserBookmarkDao;
import com.ebookBuy301.dao.UserActivityDao;
import com.ebookBuy301.pojo.Users;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 图书评分/评论/收藏 API
 */
@WebServlet("/api/bookAction")
public class BookActionServlet extends HttpServlet {

    private BookRatingDao ratingDao = new BookRatingDao();
    private BookReviewDao reviewDao = new BookReviewDao();
    private UserBookmarkDao bookmarkDao = new UserBookmarkDao();
    private UserActivityDao activityDao = new UserActivityDao();

    /**
     * 确保 book_content 表存在
     */
    private void ensureContentTableExists() {
        String sql = "CREATE TABLE IF NOT EXISTS book_content ("
                + "id INT AUTO_INCREMENT PRIMARY KEY, "
                + "book_id INT NOT NULL, "
                + "chapter_num INT NOT NULL, "
                + "chapter_title VARCHAR(200) NOT NULL, "
                + "content TEXT NOT NULL, "
                + "word_count INT DEFAULT 0, "
                + "sort_order INT DEFAULT 0, "
                + "UNIQUE KEY uk_book_chapter (book_id, chapter_num)"
                + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        try (Connection conn = com.ebookBuy301.db.DBManager.getConnection();
                java.sql.Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(sql);
        } catch (Exception e) {
            System.err.println("[BookActionServlet] 建表失败：" + e.getMessage());
        }
    }

    @Override
    public void init() throws ServletException {
        super.init();
        ensureContentTableExists();
        System.out.println("[BookActionServlet] book_content 表已确认存在");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String action = request.getParameter("action");
        String userId = getUserId(request);

        try {
            Map<String, Object> result = new HashMap<>();

            // ---- 不需要 bookId 的 action ----
            switch (action != null ? action : "info") {
                case "bookmarks":    // 别名，兼容前端调用
                case "userBookmarks":
                    if (userId != null) {
                        result.put("books", getBookmarksWithDetails(userId));
                    } else {
                        result.put("books", new ArrayList<>());
                    }
                    result.put("success", true);
                    response.getWriter().write(JSON.toJSONString(result));
                    return;

                case "recentReads":
                    if (userId != null) {
                        result.put("books", getRecentReadsWithDetails(userId));
                    } else {
                        result.put("books", new ArrayList<>());
                    }
                    result.put("success", true);
                    response.getWriter().write(JSON.toJSONString(result));
                    return;

                case "downloadHistory":
                    if (userId != null) {
                        result.put("books", getDownloadHistoryWithDetails(userId));
                    } else {
                        result.put("books", new ArrayList<>());
                    }
                    result.put("success", true);
                    response.getWriter().write(JSON.toJSONString(result));
                    return;

                case "readingStreak":
                    if (userId != null) {
                        result.put("streakDays", calculateReadingStreak(userId));
                        result.put("dailyReads", getDailyReads(userId, 28));
                        result.put("totalPages", getTotalReadPages(userId));
                    } else {
                        result.put("streakDays", 0);
                        result.put("dailyReads", new ArrayList<>());
                        result.put("totalPages", 0);
                    }
                    result.put("success", true);
                    response.getWriter().write(JSON.toJSONString(result));
                    return;
            }

            // ---- 需要 bookId 的 action ----
            String bookIdParam = request.getParameter("bookId");
            if (bookIdParam == null) {
                sendError(response, "缺少图书ID");
                return;
            }
            long bookId = Long.parseLong(bookIdParam.trim());

            switch (action != null ? action : "info") {
                case "ratingInfo":
                    result.putAll(ratingDao.getAverageRating(bookId));
                    if (userId != null) {
                        var userRating = ratingDao.getUserRating(bookId, userId);
                        result.put("userRating", userRating != null ? userRating.getRating() : 0);
                    }
                    break;
                case "reviews":
                    result.put("reviews", reviewDao.getReviewsByBookId(bookId));
                    break;
                case "bookmarkStatus":
                    result.put("bookmarked", userId != null && bookmarkDao.isBookmarked(userId, bookId));
                    break;
                case "bookContent":
                    result.put("chapters", getBookChapters(bookId));
                    break;
                case "chapterContent": {
                    int chapterNum = Integer.parseInt(request.getParameter("chapterNum"));
                    result.put("chapter", getChapterContent(bookId, chapterNum));
                    break;
                }
                case "info":
                default:
                    result.putAll(ratingDao.getAverageRating(bookId));
                    if (userId != null) {
                        result.put("userRating",
                                ratingDao.getUserRating(bookId, userId) != null
                                        ? ratingDao.getUserRating(bookId, userId).getRating()
                                        : 0);
                        result.put("bookmarked", bookmarkDao.isBookmarked(userId, bookId));
                    }
                    result.put("reviews", reviewDao.getReviewsByBookId(bookId));
            }
            result.put("success", true);
            response.getWriter().write(JSON.toJSONString(result));
        } catch (Exception e) {
            System.err.println("[BookActionServlet] doGet 错误：" + e.getMessage());
            e.printStackTrace();
            sendError(response, "服务器内部错误，请稍后重试");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String action = request.getParameter("action");
        String userId = getUserId(request);
        if (userId == null) {
            sendError(response, "未登录");
            return;
        }

        try {
            Map<String, Object> result = new HashMap<>();
            switch (action != null ? action : "") {
                case "rate": {
                    long bookId = Long.parseLong(request.getParameter("bookId"));
                    int rating = Integer.parseInt(request.getParameter("rating"));
                    boolean ok = ratingDao.rateBook(bookId, userId, rating);
                    result.put("success", ok);
                    if (ok)
                        activityDao.logActivity(userId, "rate_book", String.valueOf(bookId), "评分" + rating);
                    // 返回新的平均评分
                    result.putAll(ratingDao.getAverageRating(bookId));
                    break;
                }
                case "review": {
                    long bookId = Long.parseLong(request.getParameter("bookId"));
                    String content = request.getParameter("content");
                    boolean ok = reviewDao.addReview(bookId, userId, content);
                    result.put("success", ok);
                    if (ok)
                        activityDao.logActivity(userId, "review_book", String.valueOf(bookId), "发表评论");
                    break;
                }
                case "toggleBookmark": {
                    long bookId = Long.parseLong(request.getParameter("bookId"));
                    boolean bookmarked = bookmarkDao.toggleBookmark(userId, bookId);
                    result.put("success", true);
                    result.put("bookmarked", bookmarked);
                    activityDao.logActivity(userId, bookmarked ? "bookmark" : "unbookmark", String.valueOf(bookId),
                            null);
                    break;
                }
                case "logRead": {
                    String bookIdParam = request.getParameter("bookId");
                    if (bookIdParam != null) {
                        activityDao.logActivity(userId, "read", bookIdParam, "开始阅读");
                    }
                    result.put("success", true);
                    break;
                }
                default:
                    result.put("success", false);
                    result.put("message", "未知操作");
            }
            response.getWriter().write(JSON.toJSONString(result));
        } catch (Exception e) {
            System.err.println("[BookActionServlet] doPost 错误：" + e.getMessage());
            e.printStackTrace();
            sendError(response, "服务器内部错误，请稍后重试");
        }
    }

    /**
     * 计算用户连续阅读天数（实时，从 user_activity 表计算）
     */
    private int calculateReadingStreak(String userId) {
        String sql = "SELECT DATE(created_at) AS learn_date FROM user_activity "
                + "WHERE user_id = ? AND activity_type IN ('read','view_book') "
                + "GROUP BY DATE(created_at) ORDER BY learn_date DESC";
        try (Connection conn = com.ebookBuy301.db.DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                int streak = 0;
                java.sql.Date today = java.sql.Date.valueOf(java.time.LocalDate.now());
                java.sql.Date expected = today;
                while (rs.next()) {
                    java.sql.Date learnDate = rs.getDate("learn_date");
                    if (learnDate.equals(expected)) {
                        streak++;
                        expected = java.sql.Date.valueOf(expected.toLocalDate().minusDays(1));
                    } else if (streak == 0 && learnDate.equals(java.sql.Date.valueOf(today.toLocalDate().minusDays(1)))) {
                        // 今天还没读但昨天读了
                        streak++;
                        expected = java.sql.Date.valueOf(expected.toLocalDate().minusDays(2));
                    } else {
                        break;
                    }
                }
                return streak;
            }
        } catch (SQLException e) {
            System.err.println("[BookActionServlet] calculateReadingStreak: " + e.getMessage());
        }
        return 0;
    }

    /**
     * 获取最近 N 天每日阅读次数（用于日历热力图）
     */
    private List<Map<String, Object>> getDailyReads(String userId, int days) {
        List<Map<String, Object>> dailyReads = new ArrayList<>();
        String sql = "SELECT DATE(created_at) AS read_date, COUNT(*) AS read_count "
                + "FROM user_activity "
                + "WHERE user_id = ? "
                + "AND activity_type IN ('read','view_book') "
                + "AND created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY) "
                + "GROUP BY DATE(created_at) ORDER BY read_date ASC";
        try (Connection conn = com.ebookBuy301.db.DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setInt(2, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> entry = new HashMap<>();
                    entry.put("date", rs.getString("read_date"));
                    entry.put("count", rs.getInt("read_count"));
                    dailyReads.add(entry);
                }
            }
        } catch (SQLException e) {
            System.err.println("[BookActionServlet] getDailyReads: " + e.getMessage());
        }
        return dailyReads;
    }

    /**
     * 获取用户累计阅读页数
     */
    private int getTotalReadPages(String userId) {
        String sql = "SELECT COALESCE(SUM(current_page), 0) AS total_pages FROM book_read_record WHERE user_id = ?";
        try (Connection conn = com.ebookBuy301.db.DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total_pages");
                }
            }
        } catch (SQLException e) {
            System.err.println("[BookActionServlet] getTotalReadPages: " + e.getMessage());
        }
        return 0;
    }

    /**
     * 获取用户收藏的图书详情列表
     */
    private List<Map<String, Object>> getBookmarksWithDetails(String userId) {
        List<Map<String, Object>> books = new ArrayList<>();
        String sql = "SELECT b.id AS bookId, b.book_title, b.book_author, b.book_cover, b.book_format, "
                + "b.download_times, b.book_summary, ub.created_at "
                + "FROM user_bookmark ub "
                + "JOIN book b ON ub.book_id = b.id "
                + "WHERE ub.user_id = ? "
                + "ORDER BY ub.created_at DESC";
        try (Connection conn = com.ebookBuy301.db.DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    books.add(extractBookMap(rs, "bookmark"));
                }
            }
        } catch (Exception e) {
            System.err.println("[BookActionServlet] getBookmarksWithDetails: " + e.getMessage());
        }
        return books;
    }

    /**
     * 获取用户最近阅读的图书详情列表
     */
    private List<Map<String, Object>> getRecentReadsWithDetails(String userId) {
        List<Map<String, Object>> books = new ArrayList<>();
        String sql = "SELECT b.id AS bookId, b.book_title, b.book_author, b.book_cover, b.book_format, "
                + "b.download_times, b.book_summary, MAX(ua.created_at) AS created_at "
                + "FROM user_activity ua "
                + "JOIN book b ON ua.reference_id = b.id "
                + "WHERE ua.user_id = ? AND ua.activity_type IN ('read', 'view_book') "
                + "GROUP BY b.id "
                + "ORDER BY MAX(ua.created_at) DESC LIMIT 30";
        try (Connection conn = com.ebookBuy301.db.DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    books.add(extractBookMap(rs, "recent"));
                }
            }
        } catch (Exception e) {
            System.err.println("[BookActionServlet] getRecentReadsWithDetails: " + e.getMessage());
        }
        return books;
    }

    /**
     * 获取用户下载历史的图书详情列表
     */
    private List<Map<String, Object>> getDownloadHistoryWithDetails(String userId) {
        List<Map<String, Object>> books = new ArrayList<>();
        String sql = "SELECT b.id AS bookId, b.book_title, b.book_author, b.book_cover, b.book_format, "
                + "b.download_times, b.book_summary, ua.created_at "
                + "FROM user_activity ua "
                + "JOIN book b ON ua.reference_id = b.id "
                + "WHERE ua.user_id = ? AND ua.activity_type = 'download' "
                + "ORDER BY ua.created_at DESC LIMIT 30";
        try (Connection conn = com.ebookBuy301.db.DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    books.add(extractBookMap(rs, "download"));
                }
            }
        } catch (Exception e) {
            System.err.println("[BookActionServlet] getDownloadHistoryWithDetails: " + e.getMessage());
        }
        return books;
    }

    /**
     * 从 ResultSet 提取图书 Map（用于 JSON 序列化）
     */
    private Map<String, Object> extractBookMap(ResultSet rs, String source) throws SQLException {
        Map<String, Object> book = new HashMap<>();
        book.put("bookId", rs.getLong("bookId"));
        book.put("bookTitle", rs.getString("book_title"));
        book.put("bookAuthor", rs.getString("book_author"));
        book.put("bookCover", rs.getString("book_cover"));
        book.put("bookFormat", rs.getString("book_format"));
        book.put("downloadTimes", rs.getLong("download_times"));
        book.put("bookSummary", rs.getString("book_summary"));
        book.put("createdAt", rs.getTimestamp("created_at") != null
                ? rs.getTimestamp("created_at").toString() : "");
        book.put("source", source);
        return book;
    }

    private String getUserId(HttpServletRequest request) {
        Users user = (Users) request.getSession().getAttribute("currentUser");
        return user != null ? user.getId() : null;
    }

    private void sendError(HttpServletResponse response, String msg) throws IOException {
        Map<String, Object> err = new HashMap<>();
        err.put("success", false);
        err.put("message", msg);
        response.getWriter().write(JSON.toJSONString(err));
    }

    private List<Map<String, Object>> getBookChapters(long bookId) throws Exception {
        List<Map<String, Object>> chapters = new ArrayList<>();
        String sql = "SELECT id, chapter_num, chapter_title, word_count FROM book_content WHERE book_id = ? ORDER BY sort_order";
        try (Connection conn = com.ebookBuy301.db.DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> ch = new HashMap<>();
                    ch.put("id", rs.getInt("id"));
                    ch.put("chapterNum", rs.getInt("chapter_num"));
                    ch.put("title", rs.getString("chapter_title"));
                    ch.put("wordCount", rs.getInt("word_count"));
                    chapters.add(ch);
                }
            }
        }
        return chapters;
    }

    private Map<String, Object> getChapterContent(long bookId, int chapterNum) throws Exception {
        Map<String, Object> ch = new HashMap<>();
        String sql = "SELECT id, chapter_num, chapter_title, content, word_count FROM book_content WHERE book_id = ? AND chapter_num = ?";
        try (Connection conn = com.ebookBuy301.db.DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId);
            ps.setInt(2, chapterNum);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ch.put("id", rs.getInt("id"));
                    ch.put("chapterNum", rs.getInt("chapter_num"));
                    ch.put("title", rs.getString("chapter_title"));
                    ch.put("content", rs.getString("content"));
                    ch.put("wordCount", rs.getInt("word_count"));
                }
            }
        }
        return ch;
    }
}
