/**
 * ===========================================================================
 * RecommendEngine —— AI 驱动智能推荐引擎
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.service
 * 最后更新  2026-06-04
 *
 * ── 核心算法 ──────────────────────────────────────────────────────────
 *
 * 1. 用户画像构建：分析 user_activity(浏览/收藏/下载)、user_bookmark、
 *    history_records(阅读历史)、user_scene_visit(场景偏好)，多维度加权
 *    提取兴趣标签。
 *
 * 2. 协同过滤：找到行为相似的用户，推荐他们喜欢但当前用户未接触的内容。
 *
 * 3. 内容匹配：兴趣标签 LIKE 匹配课程/图书/讲座的名称、分类、描述。
 *
 * 4. 推荐解释：每项推荐附带"因为你对XX感兴趣"的理由。
 *
 * 权重配置：
 *   - 收藏行为(bookmark)     × 5.0
 *   - 下载行为(download)     × 3.0
 *   - 阅读行为(read)         × 2.0
 *   - 浏览行为(view)         × 1.0
 *   - 评分行为(rating ≥ 4)   × 4.0
 *   - 场景访问(scene_visit)   × 1.5
 *
 * ===========================================================================
 */

package com.ebookBuy301.service;

import com.ebookBuy301.db.DBManager;
import com.ebookBuy301.pojo.RecommendItem;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;
import java.util.stream.Collectors;

public class RecommendEngine {

    // ==================== 行为权重常量 ====================
    private static final double WEIGHT_BOOKMARK   = 5.0;
    private static final double WEIGHT_DOWNLOAD   = 3.0;
    private static final double WEIGHT_READ       = 2.0;
    private static final double WEIGHT_VIEW       = 1.0;
    private static final double WEIGHT_RATING     = 4.0;
    private static final double WEIGHT_SCENE      = 1.5;
    private static final double TIME_DECAY_DAYS   = 30.0;  // 30天衰减

    /**
     * 主推荐入口
     */
    public ArrayList<RecommendItem> recommend(String userId, String filterType, int limit) {
        ArrayList<RecommendItem> results = new ArrayList<>();
        Set<String> dedup = new HashSet<>();

        boolean all = (filterType == null || "all".equalsIgnoreCase(filterType));
        boolean course = "courses".equalsIgnoreCase(filterType);
        boolean book   = "books".equalsIgnoreCase(filterType);
        boolean lecture = "lectures".equalsIgnoreCase(filterType);

        // 1. AI 用户画像
        Map<String, Double> profile = buildUserProfile(userId);
        Map<String, String> profileReasons = buildTagReasons(userId);

        // 2. 已接触内容（排除）
        Set<String> known = getKnownIds(userId);

        // 3. 按类型推荐
        if ((all || course) && results.size() < limit)
            addItems(results, dedup, recommendCourses(profile, profileReasons, known, limit), limit);
        if ((all || book) && results.size() < limit)
            addItems(results, dedup, recommendBooks(profile, profileReasons, known, limit), limit);
        if ((all || lecture) && results.size() < limit)
            addItems(results, dedup, recommendLectures(profile, profileReasons, known, limit), limit);

        // 4. 协同过滤补充
        if (results.size() < limit)
            addItems(results, dedup, collaborativeFilter(userId, known, limit - results.size()), limit);

        return results;
    }

    // ==================== AI 用户画像构建 ====================

    /**
     * 构建用户兴趣画像：标签 → 权重
     * 综合 user_activity、user_bookmark、history_records、user_scene_visit
     */
    private Map<String, Double> buildUserProfile(String userId) {
        Map<String, Double> profile = new LinkedHashMap<>();
        if (isEmpty(userId)) return profile;

        addActivityTags(profile, userId);
        addBookmarkTags(profile, userId);
        addHistoryTags(profile, userId);
        addRatingTags(profile, userId);
        addSceneTags(profile, userId);

        // 归一化到 0-100
        if (!profile.isEmpty()) {
            double max = profile.values().stream().max(Double::compare).orElse(1.0);
            profile.replaceAll((k, v) -> Math.round(v / max * 100.0 * 10.0) / 10.0);
        }
        return profile;
    }

    /** 从 user_activity 提取标签：浏览/下载/阅读 */
    private void addActivityTags(Map<String, Double> p, String userId) {
        String sql = "SELECT ua.activity_type, ua.reference_id, ua.detail, ua.created_at " +
                     "FROM user_activity ua WHERE ua.user_id = ? ORDER BY ua.created_at DESC";
        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String type = rs.getString("activity_type");
                    String detail = rs.getString("detail");
                    double w = 0;
                    if ("bookmark".equals(type)) w = WEIGHT_BOOKMARK;
                    else if ("download".equals(type)) w = WEIGHT_DOWNLOAD;
                    else if ("read".equals(type)) w = WEIGHT_READ;
                    else if ("view".equals(type)) w = WEIGHT_VIEW;
                    else continue;

                    w *= timeDecay(rs.getTimestamp("created_at"));
                    final double weight = w;
                    extractKeywords(detail).forEach(kw ->
                        p.merge(kw, weight, Double::sum));
                }
            }
        } catch (Exception ignored) {}
    }

    /** 从 user_bookmark 提取收藏标签 */
    private void addBookmarkTags(Map<String, Double> p, String userId) {
        String sql = "SELECT b.book_title, bt.bTypeName FROM user_bookmark ub " +
                     "JOIN book b ON ub.book_id = b.id " +
                     "LEFT JOIN booktype bt ON b.type_id = bt.bTid " +
                     "WHERE ub.user_id = ?";
        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String title = rs.getString("book_title");
                    String cat = rs.getString("bTypeName");
                    if (cat != null) p.merge(cat, WEIGHT_BOOKMARK, Double::sum);
                    if (title != null) extractKeywords(title).forEach(kw ->
                        p.merge(kw, WEIGHT_BOOKMARK * 0.8, Double::sum));
                }
            }
        } catch (Exception ignored) {}
    }

    /** 从 history_records 提取阅读历史标签 */
    private void addHistoryTags(Map<String, Double> p, String userId) {
        String sql = "SELECT h.keyword, h.created_at FROM history_records h WHERE h.user_id = ?";
        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String kw = rs.getString("keyword");
                    double w = WEIGHT_READ * timeDecay(rs.getTimestamp("created_at"));
                    if (kw != null) extractKeywords(kw).forEach(k ->
                        p.merge(k, w, Double::sum));
                }
            }
        } catch (Exception ignored) {}
    }

    /** 从 book_rating 提取高分评价标签 */
    private void addRatingTags(Map<String, Double> p, String userId) {
        String sql = "SELECT br.rating, b.book_title, bt.bTypeName FROM book_rating br " +
                     "JOIN book b ON br.book_id = b.id " +
                     "LEFT JOIN booktype bt ON b.type_id = bt.bTid " +
                     "WHERE br.user_id = ? AND br.rating >= 4";
        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    double w = WEIGHT_RATING * (rs.getInt("rating") / 5.0);
                    String cat = rs.getString("bTypeName");
                    String title = rs.getString("book_title");
                    if (cat != null) p.merge(cat, w, Double::sum);
                    if (title != null) extractKeywords(title).forEach(kw ->
                        p.merge(kw, w * 0.7, Double::sum));
                }
            }
        } catch (Exception ignored) {}
    }

    /** 从 user_scene_visit 提取场景偏好，映射为兴趣 */
    private void addSceneTags(Map<String, Double> p, String userId) {
        String sql = "SELECT scene_name, visit_count FROM user_scene_visit WHERE user_id = ?";
        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String scene = rs.getString("scene_name");
                    int count = rs.getInt("visit_count");
                    if (scene == null) continue;
                    double w = WEIGHT_SCENE * Math.min(count, 10);
                    // 场景名映射为兴趣标签
                    if (scene.contains("计算机") || scene.contains("编程")) p.merge("计算机", w, Double::sum);
                    if (scene.contains("数学")) p.merge("数学", w, Double::sum);
                    if (scene.contains("艺术") || scene.contains("设计")) p.merge("设计", w, Double::sum);
                    if (scene.contains("人文") || scene.contains("文学")) p.merge("人文", w, Double::sum);
                    if (scene.contains("AI") || scene.contains("人工智能")) p.merge("人工智能", w, Double::sum);
                }
            }
        } catch (Exception ignored) {}
    }

    /** 标签来源解释 */
    private Map<String, String> buildTagReasons(String userId) {
        // 返回前3个标签的来源说明
        Map<String, Double> p = buildUserProfile(userId);
        return p.entrySet().stream()
            .sorted((a, b) -> b.getValue().compareTo(a.getValue()))
            .limit(6)
            .collect(Collectors.toMap(
                Map.Entry::getKey,
                e -> "你在这方面的活跃度高",
                (a, b) -> a, LinkedHashMap::new));
    }

    // ==================== 协同过滤 ====================

    private List<RecommendItem> collaborativeFilter(String userId, Set<String> known, int limit) {
        if (isEmpty(userId)) return Collections.emptyList();
        List<RecommendItem> results = new ArrayList<>();

        // 找到与你相似的用户（有共同收藏/阅读行为的）
        String sql = "SELECT DISTINCT ub2.user_id, COUNT(*) as common " +
                     "FROM user_bookmark ub1 JOIN user_bookmark ub2 " +
                     "ON ub1.book_id = ub2.book_id AND ub1.user_id != ub2.user_id " +
                     "WHERE ub1.user_id = ? GROUP BY ub2.user_id ORDER BY common DESC LIMIT 5";
        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                Set<String> similarUsers = new HashSet<>();
                while (rs.next()) similarUsers.add(rs.getString("user_id"));

                if (!similarUsers.isEmpty()) {
                    // 推荐相似用户收藏但当前用户没有的书
                    String inClause = similarUsers.stream().map(u -> "?").collect(Collectors.joining(","));
                    String bSql = "SELECT DISTINCT b.id, b.book_title, b.book_author, b.book_summary, b.book_cover, " +
                                  "b.download_times, bt.bTypeName " +
                                  "FROM user_bookmark ub JOIN book b ON ub.book_id = b.id " +
                                  "LEFT JOIN booktype bt ON b.type_id = bt.bTid " +
                                  "WHERE ub.user_id IN (" + inClause + ") ORDER BY b.download_times DESC LIMIT ?";
                    try (PreparedStatement bps = c.prepareStatement(bSql)) {
                        int idx = 1;
                        for (String u : similarUsers) bps.setString(idx++, u);
                        bps.setInt(idx, limit);
                        try (ResultSet brs = bps.executeQuery()) {
                            while (brs.next()) {
                                String bid = String.valueOf(brs.getInt("id"));
                                if (known.contains("b_" + bid)) continue;
                                RecommendItem item = new RecommendItem();
                                item.setType("books");
                                item.setRefId(bid);
                                item.setTitle(brs.getString("book_title"));
                                item.setCategory(brs.getString("bTypeName") != null ? brs.getString("bTypeName") : "图书");
                                item.setDescription(brs.getString("book_summary") != null ? brs.getString("book_summary") : "");
                                item.setBadge("social");
                                item.setAuthor(brs.getString("book_author") != null ? brs.getString("book_author") : "未知");
                                item.setMetaInfo("与你相似的用户也收藏了");
                                item.setRating(BigDecimal.valueOf(4.5));
                                item.setActionText("立即阅读");
                                item.setCoverImage(brs.getString("book_cover"));
                                results.add(item);
                                if (results.size() >= limit) break;
                            }
                        }
                    }
                }
            }
        } catch (Exception ignored) {}
        return results;
    }

    // ==================== 课程推荐 ====================

    private List<RecommendItem> recommendCourses(Map<String, Double> profile,
            Map<String, String> reasons, Set<String> known, int limit) {
        if (profile.isEmpty()) return getHotCourses(limit);

        List<RecommendItem> items = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT c.id, c.course_name, c.course_category, c.description, " +
            "c.instructor_name, c.course_hours, c.rating, c.enrolled_count " +
            "FROM course c WHERE c.status = 'active' AND (");

        List<String> tags = new ArrayList<>(profile.keySet());
        for (int i = 0; i < tags.size(); i++) {
            if (i > 0) sql.append(" OR ");
            sql.append("c.course_name LIKE ? OR c.course_category LIKE ? OR c.description LIKE ?");
        }
        sql.append(") ORDER BY (c.rating * 0.6 + c.enrolled_count * 0.4) DESC LIMIT ?");

        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            int idx = 1;
            for (String tag : tags) {
                String p = "%" + tag + "%";
                ps.setString(idx++, p); ps.setString(idx++, p); ps.setString(idx++, p);
            }
            ps.setInt(idx, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String rid = String.valueOf(rs.getInt("id"));
                    if (known.contains("c_" + rid)) continue;
                    RecommendItem item = buildCourseItem(rs, "personal", tags);
                    items.add(item);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }

        return items.isEmpty() ? getHotCourses(limit) : items;
    }

    // ==================== 图书推荐 ====================

    private List<RecommendItem> recommendBooks(Map<String, Double> profile,
            Map<String, String> reasons, Set<String> known, int limit) {
        if (profile.isEmpty()) return getHotBooks(limit);

        List<RecommendItem> items = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT b.id, b.book_title, b.book_author, b.book_summary, b.book_cover, " +
            "b.download_times, bt.bTypeName FROM book b " +
            "LEFT JOIN booktype bt ON b.type_id = bt.bTid WHERE 1=1 AND (");

        List<String> tags = new ArrayList<>(profile.keySet());
        for (int i = 0; i < tags.size(); i++) {
            if (i > 0) sql.append(" OR ");
            sql.append("b.book_title LIKE ? OR bt.bTypeName LIKE ? OR b.book_summary LIKE ?");
        }
        sql.append(") ORDER BY b.download_times DESC LIMIT ?");

        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            int idx = 1;
            for (String tag : tags) {
                String p = "%" + tag + "%";
                ps.setString(idx++, p); ps.setString(idx++, p); ps.setString(idx++, p);
            }
            ps.setInt(idx, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String rid = String.valueOf(rs.getInt("id"));
                    if (known.contains("b_" + rid)) continue;
                    RecommendItem item = buildBookItem(rs, "personal", tags);
                    items.add(item);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }

        return items.isEmpty() ? getHotBooks(limit) : items;
    }

    // ==================== 讲座推荐 ====================

    private List<RecommendItem> recommendLectures(Map<String, Double> profile,
            Map<String, String> reasons, Set<String> known, int limit) {
        if (profile.isEmpty()) return getHotLectures(limit);

        List<RecommendItem> items = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT l.id, l.title, l.speaker, l.description, l.lecture_date, l.view_count " +
            "FROM lecture l WHERE l.status = 'upcoming' AND (");

        List<String> tags = new ArrayList<>(profile.keySet());
        for (int i = 0; i < tags.size(); i++) {
            if (i > 0) sql.append(" OR ");
            sql.append("l.title LIKE ? OR l.description LIKE ?");
        }
        sql.append(") ORDER BY l.lecture_date ASC, l.view_count DESC LIMIT ?");

        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            int idx = 1;
            for (String tag : tags) {
                String p = "%" + tag + "%";
                ps.setString(idx++, p); ps.setString(idx++, p);
            }
            ps.setInt(idx, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String rid = String.valueOf(rs.getInt("id"));
                    if (known.contains("l_" + rid)) continue;
                    RecommendItem item = buildLectureItem(rs, "personal", tags);
                    items.add(item);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }

        return items.isEmpty() ? getHotLectures(limit) : items;
    }

    // ==================== 热门后备 ====================

    private List<RecommendItem> getHotCourses(int limit) {
        List<RecommendItem> items = new ArrayList<>();
        String sql = "SELECT id, course_name, course_category, description, instructor_name, " +
                     "course_hours, rating, enrolled_count FROM course WHERE status = 'active' " +
                     "ORDER BY (rating * 0.5 + enrolled_count * 0.5) DESC LIMIT ?";
        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RecommendItem item = new RecommendItem();
                    item.setType("courses");
                    item.setRefId(String.valueOf(rs.getInt("id")));
                    item.setTitle(rs.getString("course_name"));
                    item.setCategory(rs.getString("course_category") != null ? rs.getString("course_category") : "热门课程");
                    item.setDescription(rs.getString("description") != null ? rs.getString("description") : "");
                    item.setBadge("hot");
                    item.setAuthor(rs.getString("instructor_name") != null ? rs.getString("instructor_name") : "资深讲师");
                    item.setMetaInfo(rs.getInt("course_hours") + "课时 · " + rs.getInt("enrolled_count") + "人学习");
                    item.setRating(rs.getBigDecimal("rating"));
                    item.setActionText("立即学习");
                    items.add(item);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return items;
    }

    private List<RecommendItem> getHotBooks(int limit) {
        List<RecommendItem> items = new ArrayList<>();
        String sql = "SELECT b.id, b.book_title, b.book_author, b.book_summary, b.book_cover, " +
                     "b.download_times, bt.bTypeName FROM book b " +
                     "LEFT JOIN booktype bt ON b.type_id = bt.bTid ORDER BY b.download_times DESC LIMIT ?";
        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RecommendItem item = new RecommendItem();
                    item.setType("books");
                    item.setRefId(String.valueOf(rs.getInt("id")));
                    item.setTitle(rs.getString("book_title"));
                    item.setCategory(rs.getString("bTypeName") != null ? rs.getString("bTypeName") : "热门图书");
                    item.setDescription(rs.getString("book_summary") != null ? rs.getString("book_summary") : "");
                    item.setBadge("hot");
                    item.setAuthor(rs.getString("book_author") != null ? rs.getString("book_author") : "未知作者");
                    item.setMetaInfo(rs.getInt("download_times") + "次下载 · 热门推荐");
                    item.setRating(BigDecimal.valueOf(4.5));
                    item.setActionText("立即阅读");
                    item.setCoverImage(rs.getString("book_cover"));
                    items.add(item);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return items;
    }

    private List<RecommendItem> getHotLectures(int limit) {
        List<RecommendItem> items = new ArrayList<>();
        String sql = "SELECT id, title, speaker, description, lecture_date, view_count " +
                     "FROM lecture WHERE status = 'upcoming' ORDER BY view_count DESC, lecture_date ASC LIMIT ?";
        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RecommendItem item = new RecommendItem();
                    item.setType("lectures");
                    item.setRefId(String.valueOf(rs.getInt("id")));
                    item.setTitle(rs.getString("title"));
                    item.setCategory("前沿讲座");
                    item.setDescription(rs.getString("description") != null ? rs.getString("description") : "");
                    item.setBadge("hot");
                    item.setAuthor(rs.getString("speaker") != null ? rs.getString("speaker") : "知名学者");
                    java.sql.Date d = rs.getDate("lecture_date");
                    item.setMetaInfo((d != null ? d.toString() : "待定") + " · " + rs.getInt("view_count") + "次观看");
                    item.setRating(BigDecimal.valueOf(4.8));
                    item.setActionText("预约参加");
                    items.add(item);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return items;
    }

    // ==================== 工具方法 ====================

    private RecommendItem buildCourseItem(ResultSet rs, String badge, List<String> topTags) throws Exception {
        RecommendItem item = new RecommendItem();
        item.setType("courses");
        item.setRefId(String.valueOf(rs.getInt("id")));
        item.setTitle(rs.getString("course_name"));
        item.setCategory(rs.getString("course_category") != null ? rs.getString("course_category") : "课程");
        item.setDescription(rs.getString("description") != null ? rs.getString("description") : "");
        item.setBadge(badge);
        item.setAuthor(rs.getString("instructor_name") != null ? rs.getString("instructor_name") : "资深讲师");
        // AI 推荐理由
        String reason = topTags.size() > 0 ? "根据你对「" + topTags.get(0) + "」的兴趣推荐" : "智能匹配";
        item.setMetaInfo(rs.getInt("course_hours") + "课时 · " + reason);
        item.setRating(rs.getBigDecimal("rating"));
        item.setActionText("开始学习");
        return item;
    }

    private RecommendItem buildBookItem(ResultSet rs, String badge, List<String> topTags) throws Exception {
        RecommendItem item = new RecommendItem();
        item.setType("books");
        item.setRefId(String.valueOf(rs.getInt("id")));
        item.setTitle(rs.getString("book_title"));
        item.setCategory(rs.getString("bTypeName") != null ? rs.getString("bTypeName") : "图书");
        item.setDescription(rs.getString("book_summary") != null ? rs.getString("book_summary") : "");
        item.setBadge(badge);
        item.setAuthor(rs.getString("book_author") != null ? rs.getString("book_author") : "未知作者");
        String reason = topTags.size() > 0 ? "根据你对「" + topTags.get(0) + "」的兴趣推荐" : "智能匹配";
        item.setMetaInfo(rs.getInt("download_times") + "次下载 · " + reason);
        item.setRating(BigDecimal.valueOf(4.5));
        item.setActionText("立即阅读");
        item.setCoverImage(rs.getString("book_cover"));
        return item;
    }

    private RecommendItem buildLectureItem(ResultSet rs, String badge, List<String> topTags) throws Exception {
        RecommendItem item = new RecommendItem();
        item.setType("lectures");
        item.setRefId(String.valueOf(rs.getInt("id")));
        item.setTitle(rs.getString("title"));
        item.setCategory("前沿讲座");
        item.setDescription(rs.getString("description") != null ? rs.getString("description") : "");
        item.setBadge(badge);
        item.setAuthor(rs.getString("speaker") != null ? rs.getString("speaker") : "知名学者");
        java.sql.Date d = rs.getDate("lecture_date");
        String reason = topTags.size() > 0 ? "根据你对「" + topTags.get(0) + "」的兴趣推荐" : "智能匹配";
        item.setMetaInfo((d != null ? d.toString() : "待定") + " · " + reason);
        item.setRating(BigDecimal.valueOf(4.8));
        item.setActionText("预约参加");
        return item;
    }

    /** 获取用户已接触的所有内容ID */
    private Set<String> getKnownIds(String userId) {
        Set<String> ids = new HashSet<>();
        if (isEmpty(userId)) return ids;
        // 收藏的图书
        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT book_id FROM user_bookmark WHERE user_id = ?")) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ids.add("b_" + rs.getLong("book_id"));
            }
        } catch (Exception ignored) {}
        // 已选课程
        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT course_id FROM user_course_record WHERE user_id = ?")) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ids.add("c_" + rs.getString("course_id"));
            }
        } catch (Exception ignored) {}
        return ids;
    }

    /** 中文关键词提取（简易分词） */
    private Set<String> extractKeywords(String text) {
        Set<String> kw = new LinkedHashSet<>();
        if (text == null || text.isEmpty()) return kw;
        // 常见学科关键词库
        String[] dict = {
            "计算机", "人工智能", "编程", "算法", "数据结构", "机器学习", "深度学习",
            "数学", "物理", "化学", "生物", "统计", "概率",
            "人文", "历史", "哲学", "文学", "文化", "社会",
            "艺术", "设计", "音乐", "绘画", "美学",
            "经济", "管理", "金融", "市场", "商业",
            "教育", "心理", "认知", "语言",
            "大数据", "云计算", "区块链", "物联网", "量子",
            "数字媒体", "交互", "UI", "UX", "用户体验"
        };
        for (String d : dict) {
            if (text.contains(d)) kw.add(d);
        }
        return kw;
    }

    /** 时间衰减函数 */
    private double timeDecay(java.util.Date date) {
        if (date == null) return 1.0;
        long days = (System.currentTimeMillis() - date.getTime()) / 86400000L;
        return Math.max(0.1, 1.0 - days / TIME_DECAY_DAYS);
    }

    private void addItems(List<RecommendItem> target, Set<String> dedup,
                          List<RecommendItem> source, int limit) {
        for (RecommendItem item : source) {
            if (target.size() >= limit) break;
            if (dedup.add(item.getTitle())) target.add(item);
        }
    }

    private boolean isEmpty(String s) { return s == null || s.isEmpty(); }

    // ==================== Dashboard 数据 ====================

    public ArrayList<com.ebookBuy301.pojo.Skill> getSkills(String userId) {
        ArrayList<com.ebookBuy301.pojo.Skill> skills = new ArrayList<>();
        if (isEmpty(userId)) return skills;  // 未登录直接返回空，不做无意义查询
        String sql = "SELECT * FROM knowledge_skills WHERE user_id = ? ORDER BY skill_value DESC";
        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    com.ebookBuy301.pojo.Skill s = new com.ebookBuy301.pojo.Skill();
                    s.setId(rs.getInt("id"));
                    s.setUserId(rs.getString("user_id"));
                    s.setSkillName(rs.getString("skill_name"));
                    s.setSkillValue(rs.getInt("skill_value"));
                    s.setSkillColor(rs.getString("skill_color"));
                    skills.add(s);
                }
            }
        } catch (Exception ignored) {}
        return skills;
    }

    public com.ebookBuy301.pojo.StudySummary getStudySummary(String userId) {
        com.ebookBuy301.pojo.StudySummary summary = new com.ebookBuy301.pojo.StudySummary();
        boolean hasUser = !isEmpty(userId);
        String sql = hasUser
            ? "SELECT * FROM user_study_summary WHERE user_id = ?"
            : "SELECT COALESCE(SUM(total_courses),0) AS total_courses, " +
              "COALESCE(SUM(total_study_hours),0) AS total_study_hours, " +
              "COALESCE(AVG(campus_points),0) AS avg_campus_points, " +
              "COALESCE(AVG(week_progress),0) AS avg_week_progress " +
              "FROM user_study_summary";
        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            if (hasUser) ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    summary.setTotalCourses(rs.getInt("total_courses"));
                    summary.setTotalHours(rs.getBigDecimal(hasUser ? "total_study_hours" : "total_study_hours"));
                    summary.setCampusPoints(rs.getInt(hasUser ? "campus_points" : "avg_campus_points"));
                    summary.setWeekProgress(rs.getInt(hasUser ? "week_progress" : "avg_week_progress"));
                }
            }
        } catch (Exception ignored) {}
        return summary;
    }

    public ArrayList<com.ebookBuy301.pojo.LearningStep> getLearningSteps(String userId) {
        ArrayList<com.ebookBuy301.pojo.LearningStep> steps = new ArrayList<>();
        String sql = "SELECT * FROM learning_paths WHERE user_id = ? ORDER BY step_number ASC";
        if (isEmpty(userId)) sql = "SELECT * FROM learning_paths ORDER BY step_number ASC LIMIT 6";
        try (Connection c = DBManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            if (!isEmpty(userId)) ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    com.ebookBuy301.pojo.LearningStep s = new com.ebookBuy301.pojo.LearningStep();
                    s.setId(rs.getInt("id"));
                    s.setUserId(rs.getString("user_id"));
                    s.setStepNumber(rs.getInt("step_number"));
                    s.setTitle(rs.getString("title"));
                    s.setDescription(rs.getString("description"));
                    s.setStatus(rs.getString("status"));
                    s.setProgressPercent(rs.getInt("progress_percent"));
                    steps.add(s);
                }
            }
        } catch (Exception ignored) {}
        return steps;
    }

    /** AI 用户兴趣标签（展示用） */
    public Map<String, Double> getUserProfileForDisplay(String userId) {
        return buildUserProfile(userId);
    }
}
