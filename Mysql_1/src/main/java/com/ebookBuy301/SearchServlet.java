/**
 * ===========================================================================
 * SearchServlet —— 全局搜索控制器（v2.0 权限感知版）
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet
 *
 * ── 用途 ─────────────────────────────────────────────────────────────────
 *  处理 index.jsp 全局搜索弹窗的 AJAX 请求，跨模块搜索课程、导师、图书、
 *  讲座、校友数据；管理员额外可搜索用户、分类、通知、审核等内容。
 *
 * ── 请求参数 ─────────────────────────────────────────────────────────────
 *  keyword  搜索关键词（必填）
 *  type     搜索类型：all / courses / teachers / books / lectures / alumni
 *                    [管理员专属] users / booktypes / notifications / reviews
 *
 * ── 权限说明 ─────────────────────────────────────────────────────────────
 *  普通用户只能搜索公开内容（课程/导师/图书/讲座/校友）。
 *  管理员额外可搜索：用户列表、图书分类、通知公告、内容审核。
 *  "all" 模式自动根据角色合并搜索范围。
 *
 * ── 响应格式 ─────────────────────────────────────────────────────────────
 *  {
 *    "success": true,
 *    "keyword": "...",
 *    "type": "...",
 *    "isAdmin": false,
 *    "total": 5,
 *    "results": [
 *      { "type": "course", "typeLabel": "课程", "id": 1, "title": "人工智能导论",
 *        "subtitle": "基础课程", "url": "recommend", "adminOnly": false },
 *      ...
 *    ]
 *  }
 * ===========================================================================
 */

package com.ebookBuy301;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.ebookBuy301.dao.*;
import com.ebookBuy301.pojo.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/search")
public class SearchServlet extends HttpServlet {

    // DAO 实例缓存，避免每次请求重复创建
    private CourseDao courseDao;
    private FacultyDao facultyDao;
    private BookDao bookDao;
    private LectureDao lectureDao;
    private AlumniDao alumniDao;
    private UsersDao usersDao;
    private BookTypeDao bookTypeDao;
    private CultureNotificationDao cultureNotificationDao;
    private ContentReviewDao contentReviewDao;

    @Override
    public void init() throws ServletException {
        courseDao = new CourseDao();
        facultyDao = new FacultyDao();
        bookDao = new BookDao();
        lectureDao = new LectureDao();
        alumniDao = new AlumniDao();
        usersDao = new UsersDao();
        bookTypeDao = new BookTypeDao();
        cultureNotificationDao = new CultureNotificationDao();
        contentReviewDao = new ContentReviewDao();
    }

    /** 权限检查：判断当前请求是否为管理员 */
    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        Users user = (Users) session.getAttribute("currentUser");
        return user != null && user.isAdmin();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String keyword = request.getParameter("keyword");
        String type = request.getParameter("type");
        boolean admin = isAdmin(request);

        // 参数校验
        if (keyword == null || keyword.trim().isEmpty()) {
            JSONObject err = new JSONObject();
            err.put("success", false);
            err.put("error", "请输入搜索关键词");
            response.getWriter().write(err.toString());
            return;
        }

        keyword = keyword.trim();
        if (type == null || type.trim().isEmpty()) {
            type = "all";
        }

        // 管理员专属搜索类型：非管理员拒绝访问
        boolean adminOnlyType = "users".equals(type) || "booktypes".equals(type)
                || "notifications".equals(type) || "reviews".equals(type);
        if (adminOnlyType && !admin) {
            JSONObject err = new JSONObject();
            err.put("success", false);
            err.put("error", "您没有权限搜索此内容");
            response.getWriter().write(err.toString());
            return;
        }

        try {
            List<Map<String, Object>> results = new ArrayList<>();

            // 根据类型分发搜索
            switch (type) {
                case "all":
                    searchAll(keyword, results, admin);
                    break;
                case "courses":
                    searchCourses(keyword, results);
                    break;
                case "teachers":
                    searchFaculty(keyword, results);
                    break;
                case "books":
                    searchBooks(keyword, results);
                    break;
                case "lectures":
                    searchLectures(keyword, results);
                    break;
                case "alumni":
                    searchAlumni(keyword, results);
                    break;
                // ===== 管理员专属 =====
                case "users":
                    searchUsers(keyword, results);
                    break;
                case "booktypes":
                    searchBookTypes(keyword, results);
                    break;
                case "notifications":
                    searchNotifications(keyword, results);
                    break;
                case "reviews":
                    searchReviews(keyword, results);
                    break;
                default:
                    // 未知类型，默认搜全部
                    searchAll(keyword, results, admin);
            }

            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("keyword", keyword);
            result.put("type", type);
            result.put("isAdmin", admin);
            result.put("total", results.size());
            result.put("results", results);
            response.getWriter().write(result.toString());

        } catch (Exception e) {
            System.err.println("[SearchServlet] 搜索异常：" + e.getMessage());
            e.printStackTrace();
            JSONObject err = new JSONObject();
            err.put("success", false);
            err.put("error", "搜索失败，请稍后重试");
            response.getWriter().write(err.toString());
        }
    }

    /** 搜索全部模块 —— 管理员自动包含后台内容 */
    private void searchAll(String keyword, List<Map<String, Object>> results, boolean admin)
            throws ClassNotFoundException {
        searchCourses(keyword, results);
        searchFaculty(keyword, results);
        searchBooks(keyword, results);
        searchLectures(keyword, results);
        searchAlumni(keyword, results);
        if (admin) {
            searchUsers(keyword, results);
            searchBookTypes(keyword, results);
            searchNotifications(keyword, results);
            searchReviews(keyword, results);
        }
    }

    // ==================== 公开搜索 ====================

    /** 搜索课程 */
    private void searchCourses(String keyword, List<Map<String, Object>> results)
            throws ClassNotFoundException {
        ArrayList<Course> courses = courseDao.searchCourses(keyword);
        for (Course c : courses) {
            Map<String, Object> item = new HashMap<>();
            item.put("type", "course");
            item.put("typeLabel", "课程");
            item.put("id", c.getId());
            item.put("title", c.getCourseName());
            item.put("subtitle", c.getDescription());
            item.put("url", "recommend");
            item.put("adminOnly", false);
            results.add(item);
        }
    }

    /** 搜索导师 */
    private void searchFaculty(String keyword, List<Map<String, Object>> results)
            throws ClassNotFoundException {
        ArrayList<Faculty> list = facultyDao.searchFaculty(keyword);
        for (Faculty f : list) {
            Map<String, Object> item = new HashMap<>();
            item.put("type", "teacher");
            item.put("typeLabel", "导师");
            item.put("id", f.getId());
            item.put("title", f.getName());
            item.put("subtitle", f.getTitle() + " · " + f.getDepartment());
            item.put("url", "facultyPage");
            item.put("adminOnly", false);
            results.add(item);
        }
    }

    /** 搜索图书 */
    private void searchBooks(String keyword, List<Map<String, Object>> results)
            throws ClassNotFoundException {
        try {
            Book query = new Book();
            query.setBookTitle(keyword);
            ArrayList<Book> list = bookDao.searchBookByE(query);
            for (Book b : list) {
                Map<String, Object> item = new HashMap<>();
                item.put("type", "book");
                item.put("typeLabel", "图书");
                item.put("id", b.getId());
                item.put("title", b.getBookTitle());
                item.put("subtitle", b.getBookAuthor() != null ? b.getBookAuthor() : "");
                item.put("url", "recommend");
                item.put("adminOnly", false);
                results.add(item);
            }
        } catch (java.sql.SQLException e) {
            System.err.println("[SearchServlet] 图书搜索错误：" + e.getMessage());
        }
    }

    /** 搜索讲座 */
    private void searchLectures(String keyword, List<Map<String, Object>> results)
            throws ClassNotFoundException {
        ArrayList<Lecture> list = lectureDao.searchLectures(keyword);
        for (Lecture l : list) {
            Map<String, Object> item = new HashMap<>();
            item.put("type", "lecture");
            item.put("typeLabel", "讲座");
            item.put("id", l.getId());
            item.put("title", l.getTitle());
            item.put("subtitle", l.getSpeaker() + " · " + l.getSpeakerTitle());
            item.put("url", "lecturePage");
            item.put("adminOnly", false);
            results.add(item);
        }
    }

    /** 搜索校友 */
    private void searchAlumni(String keyword, List<Map<String, Object>> results)
            throws ClassNotFoundException {
        ArrayList<Alumni> list = alumniDao.searchAlumni(keyword);
        for (Alumni a : list) {
            Map<String, Object> item = new HashMap<>();
            item.put("type", "alumni");
            item.put("typeLabel", "校友");
            item.put("id", a.getId());
            item.put("title", a.getName());
            item.put("subtitle", a.getTitle() + " · " + a.getCompany());
            item.put("url", "alumniPage");
            item.put("adminOnly", false);
            results.add(item);
        }
    }

    // ==================== 管理员专属搜索 ====================

    /** 搜索用户（管理员） */
    private void searchUsers(String keyword, List<Map<String, Object>> results)
            throws ClassNotFoundException {
        ArrayList<Users> list = usersDao.searchUsers(keyword, null);
        for (Users u : list) {
            Map<String, Object> item = new HashMap<>();
            item.put("type", "user");
            item.put("typeLabel", "用户管理");
            item.put("id", u.getId());
            item.put("title", u.getUsername());
            String roleLabel = "admin".equals(u.getRole()) ? "管理员" : "普通用户";
            item.put("subtitle", roleLabel + (u.getEmail() != null ? " · " + u.getEmail() : ""));
            item.put("url", "usersList");
            item.put("adminOnly", true);
            results.add(item);
        }
    }

    /** 搜索图书分类（管理员） */
    private void searchBookTypes(String keyword, List<Map<String, Object>> results)
            throws ClassNotFoundException {
        ArrayList<BookType> list = bookTypeDao.searchTypesByName(keyword);
        for (BookType bt : list) {
            Map<String, Object> item = new HashMap<>();
            item.put("type", "booktype");
            item.put("typeLabel", "图书分类");
            item.put("id", bt.getbTid());
            item.put("title", bt.getbTypeName());
            item.put("subtitle", bt.getDisplayName() + (bt.getBtText() != null ? " · " + bt.getBtText() : ""));
            item.put("url", "bookTypeList");
            item.put("adminOnly", true);
            results.add(item);
        }
    }

    /** 搜索通知公告（管理员） */
    private void searchNotifications(String keyword, List<Map<String, Object>> results)
            throws ClassNotFoundException {
        ArrayList<Notification> list = cultureNotificationDao.searchNotifications(keyword);
        for (Notification n : list) {
            Map<String, Object> item = new HashMap<>();
            item.put("type", "notification");
            item.put("typeLabel", "通知公告");
            item.put("id", n.getId());
            item.put("title", n.getTitle());
            String statusLabel = "sent".equals(n.getStatus()) ? "已发送"
                    : "scheduled".equals(n.getStatus()) ? "定时" : n.getStatus();
            item.put("subtitle", "状态:" + statusLabel + " · 类型:" + (n.getNotificationType() != null ? n.getNotificationType() : "-"));
            item.put("url", "notifications");
            item.put("adminOnly", true);
            results.add(item);
        }
    }

    /** 搜索内容审核（管理员） */
    private void searchReviews(String keyword, List<Map<String, Object>> results)
            throws ClassNotFoundException {
        ArrayList<Map<String, Object>> list = contentReviewDao.searchReviews(keyword);
        for (Map<String, Object> r : list) {
            Map<String, Object> item = new HashMap<>();
            item.put("type", "review");
            item.put("typeLabel", "内容审核");
            item.put("id", r.get("id"));
            item.put("title", r.get("title"));
            item.put("subtitle", "提交者:" + r.get("submitter") + " · 优先级:" + r.get("priority")
                    + " · " + ("pending".equals(r.get("status")) ? "待审核" : r.get("status")));
            item.put("url", "contentReview");
            item.put("adminOnly", true);
            results.add(item);
        }
    }
}
