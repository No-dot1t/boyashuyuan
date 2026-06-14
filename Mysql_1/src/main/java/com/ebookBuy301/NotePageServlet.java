package com.ebookBuy301;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.ebookBuy301.dao.StudyNoteDao;
import com.ebookBuy301.pojo.StudyNote;
import com.ebookBuy301.pojo.Users;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.UUID;

/**
 * ===========================================================================
 * NotePageServlet —— 笔记中心页面控制器 + API
 * ===========================================================================
 *
 * 映射路径        /notesPage
 * 底层技术        Java EE Servlet
 * 数据访问        StudyNoteDao（JDBC + PreparedStatement）
 * 最后更新        2026-06-13
 *
 * ── 路由表 ─────────────────────────────────────────────────────────────────
 *
 * 【GET】
 *   无 action          → 渲染笔记中心页面（notes.jsp）
 *   action=list       → 返回 JSON 格式的笔记列表
 *   action=search&q=xxx → 返回 JSON 格式的搜索结果
 *   action=stats      → 返回 JSON 格式的笔记统计信息
 *
 * 【POST】
 *   action=add        → 新增笔记
 *   action=update     → 更新笔记
 *   action=delete     → 删除笔记
 *   action=togglePin  → 切换笔记置顶状态
 *
 * ── 使用的关键方法与算法 ────────────────────────────────────────────────────
 *
 * 方法 / 技术                  用途
 * ─────────────────────────────────────────────────────────────────
 * StudyNoteDao.getNotesByUserId()   查询用户所有笔记
 * StudyNoteDao.searchNotes()        搜索笔记
 * StudyNoteDao.getNoteStats()       获取笔记统计信息
 * StudyNoteDao.addNote()            新增笔记
 * StudyNoteDao.updateNote()         更新笔记
 * StudyNoteDao.deleteNote()         删除笔记
 * StudyNoteDao.togglePin()          切换置顶状态
 * HttpServletRequest                  获取请求参数/Session
 * response.getWriter().write()      输出 JSON 响应
 * UUID.randomUUID()                 生成 CSRF Token
 * ===========================================================================
 */
@WebServlet("/notesPage")
public class NotePageServlet extends HttpServlet {

    private StudyNoteDao noteDao;

    @Override
    public void init() throws ServletException {
        noteDao = new StudyNoteDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        Users currentUser = (Users) request.getSession().getAttribute("currentUser");
        String action = request.getParameter("action");

        // API 模式：JSON 响应
        if (action != null) {
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();

            if (currentUser == null) {
                out.print("{\"success\":false,\"message\":\"请先登录\"}");
                return;
            }

            String userId = currentUser.getId().toString();
            try {
                switch (action) {
                    case "list": {
                        ArrayList<StudyNote> notes = noteDao.getNotesByUserId(userId);
                        out.print(notesToJson(notes));
                        break;
                    }
                    case "search": {
                        String q = request.getParameter("q");
                        ArrayList<StudyNote> notes = noteDao.searchNotes(userId, q != null ? q : "");
                        out.print(notesToJson(notes));
                        break;
                    }
                    case "stats": {
                        java.util.Map<String, Object> stats = noteDao.getNoteStats(userId);
                        out.print(statsToJson(stats));
                        break;
                    }
                    default:
                        out.print("{\"success\":false,\"message\":\"未知操作\"}");
                }
            } catch (Exception e) {
                out.print("{\"success\":false,\"message\":\"" + escapeJson(e.getMessage()) + "\"}");
            }
            return;
        }

        // 页面模式：渲染 JSP
        request.setAttribute("currentUser", currentUser);
        // 生成 CSRF Token（每次页面加载刷新）
        String csrfToken = UUID.randomUUID().toString();
        request.getSession().setAttribute("csrfToken_notes", csrfToken);
        request.setAttribute("csrfToken", csrfToken);
        request.getRequestDispatcher("/pages/notes.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // CSRF 校验
        HttpSession session = request.getSession(false);
        if (session == null) {
            out.print("{\"success\":false,\"message\":\"会话已过期，请刷新页面\"}");
            return;
        }
        String sessionToken = (String) session.getAttribute("csrfToken_notes");
        String requestToken = request.getParameter("csrfToken");
        if (sessionToken == null || requestToken == null || !sessionToken.equals(requestToken)) {
            out.print("{\"success\":false,\"message\":\"请求校验失败，请刷新页面后重试\"}");
            return;
        }

        Users currentUser = (Users) session.getAttribute("currentUser");
        if (currentUser == null) {
            out.print("{\"success\":false,\"message\":\"请先登录\"}");
            return;
        }

        String userId = currentUser.getId().toString();
        String action = request.getParameter("action");

        if (action == null || action.isEmpty()) {
            out.print("{\"success\":false,\"message\":\"缺少操作参数\"}");
            return;
        }

        try {
            switch (action) {
                case "add": {
                    String title = request.getParameter("title");
                    String content = request.getParameter("content");
                    String tags = request.getParameter("tags");
                    String bookIdStr = request.getParameter("bookId");
                    String courseIdStr = request.getParameter("courseId");
                    if (title == null || title.trim().isEmpty()) {
                        out.print("{\"success\":false,\"message\":\"标题不能为空\"}");
                        return;
                    }
                    Integer bookId = (bookIdStr != null && !bookIdStr.isEmpty()) ? Integer.parseInt(bookIdStr) : null;
                    Integer courseId = (courseIdStr != null && !courseIdStr.isEmpty()) ? Integer.parseInt(courseIdStr) : null;
                    int noteId = noteDao.addNote(userId, title.trim(), content, tags, bookId, courseId);
                    out.print("{\"success\":" + (noteId > 0) + ",\"noteId\":" + noteId + "}");
                    break;
                }
                case "update": {
                    int noteId = Integer.parseInt(request.getParameter("noteId"));
                    String title = request.getParameter("title");
                    String content = request.getParameter("content");
                    String tags = request.getParameter("tags");
                    boolean ok = noteDao.updateNote(noteId, title, content, tags, userId);
                    out.print("{\"success\":" + ok + "}");
                    break;
                }
                case "delete": {
                    int noteId = Integer.parseInt(request.getParameter("noteId"));
                    boolean ok = noteDao.deleteNote(noteId, userId);
                    out.print("{\"success\":" + ok + "}");
                    break;
                }
                case "togglePin": {
                    int noteId = Integer.parseInt(request.getParameter("noteId"));
                    boolean ok = noteDao.togglePin(noteId, userId);
                    out.print("{\"success\":" + ok + "}");
                    break;
                }
                default:
                    out.print("{\"success\":false,\"message\":\"未知操作\"}");
            }
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private String notesToJson(ArrayList<StudyNote> notes) {
        JSONArray arr = new JSONArray();
        for (StudyNote n : notes) {
            JSONObject obj = new JSONObject();
            obj.put("id", n.getId());
            obj.put("title", n.getTitle());
            obj.put("content", n.getContent());
            obj.put("tags", n.getTags());
            obj.put("bookId", n.getBookId());
            obj.put("courseId", n.getCourseId());
            obj.put("isPinned", n.isPinned());
            obj.put("isPublic", n.isPublic());
            obj.put("createdAt", n.getCreatedAt());
            obj.put("updatedAt", n.getUpdatedAt());
            arr.add(obj);
        }
        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("notes", arr);
        return result.toJSONString();
    }

    /** 将统计 Map 转为 JSON（嵌套结构由 fastjson 自动处理） */
    @SuppressWarnings("unchecked")
    private String statsToJson(java.util.Map<String, Object> stats) {
        JSONObject result = new JSONObject();
        result.put("success", true);

        JSONObject summary = new JSONObject();
        summary.put("totalNotes", stats.getOrDefault("totalNotes", 0));
        summary.put("pinnedCount", stats.getOrDefault("pinnedCount", 0));
        summary.put("weekCount", stats.getOrDefault("weekCount", 0));
        summary.put("totalChars", stats.getOrDefault("totalChars", 0));
        result.put("summary", summary);

        // dailyTrend
        java.util.List<java.util.Map<String, Object>> dailyTrend =
                (java.util.List<java.util.Map<String, Object>>) stats.getOrDefault("dailyTrend", new java.util.ArrayList<>());
        JSONArray dlArr = new JSONArray();
        for (java.util.Map<String, Object> e : dailyTrend) {
            JSONObject obj = new JSONObject();
            obj.put("date", String.valueOf(e.get("date")));
            obj.put("count", e.get("count"));
            dlArr.add(obj);
        }
        result.put("dailyTrend", dlArr);

        // tagDistribution
        java.util.List<java.util.Map<String, Object>> tagDist =
                (java.util.List<java.util.Map<String, Object>>) stats.getOrDefault("tagDistribution", new java.util.ArrayList<>());
        JSONArray tdArr = new JSONArray();
        for (java.util.Map<String, Object> e : tagDist) {
            JSONObject obj = new JSONObject();
            obj.put("name", e.get("name"));
            obj.put("value", e.get("value"));
            tdArr.add(obj);
        }
        result.put("tagDistribution", tdArr);

        // lengthDistribution
        java.util.List<java.util.Map<String, Object>> lenDist =
                (java.util.List<java.util.Map<String, Object>>) stats.getOrDefault("lengthDistribution", new java.util.ArrayList<>());
        JSONArray ldArr = new JSONArray();
        for (java.util.Map<String, Object> e : lenDist) {
            JSONObject obj = new JSONObject();
            obj.put("label", e.get("label"));
            obj.put("count", e.get("count"));
            ldArr.add(obj);
        }
        result.put("lengthDistribution", ldArr);

        return result.toJSONString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
