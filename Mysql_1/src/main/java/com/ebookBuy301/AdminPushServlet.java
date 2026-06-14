/**
 * ===========================================================================
 * AdminPushServlet —— Servlet 控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet
 * 最后更新  2026-05-26
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * doGet(HttpServletRequest req, HttpServletResponse res)  HTTP 请求处理入口
 * doPost(HttpServletRequest req, HttpServletResponse res) HTTP 请求处理入口
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   @WebServlet —— 注解式 Servlet 路由映射
 *   Servlet API —— HttpServlet / HttpServletRequest / HttpServletResponse
 *   action 参数分发模式 —— 通过 request.getParameter("action") 分流操作
 *
 * ===========================================================================
 */

package com.ebookBuy301;

import com.alibaba.fastjson.JSON;
import com.ebookBuy301.dao.LectureDao;
import com.ebookBuy301.dao.FacultyDao;
import com.ebookBuy301.pojo.Lecture;
import com.ebookBuy301.pojo.Faculty;
import com.ebookBuy301.util.CsrfUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * =============================================================================
 * AdminPushServlet —— 管理员讲坛和导师管理 API
 * =============================================================================
 *
 * 提供前沿讲坛（Lecture）和导师（Faculty）的管理接口。
 *
 * 访问路径：/adminPush
 *
 * GET 请求：
 * - /adminPush?action=list&module=lecture → 获取讲坛列表
 * - /adminPush?action=list&module=faculty → 获取导师列表
 * - /adminPush?action=list → 获取讲坛和导师列表
 * - /adminPush?action=delete&module=xxx&id=1 → 删除指定记录
 * - /adminPush（无参数） → 转发到管理页面
 *
 * POST 请求：
 * - 添加/更新讲坛或导师信息
 * =============================================================================
 */
@WebServlet("/adminPush")
public class AdminPushServlet extends HttpServlet {

    private LectureDao lectureDao = new LectureDao();
    private FacultyDao facultyDao = new FacultyDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        String module = req.getParameter("module");

        res.setContentType("application/json;charset=UTF-8");

        try {
            if ("list".equals(action)) {
                if ("lecture".equals(module)) {
                    List<Lecture> lectures = lectureDao.getAllActiveLectures();
                    res.getWriter().write(JSON.toJSONString(lectures));
                } else if ("faculty".equals(module)) {
                    List<Faculty> faculty = facultyDao.getAllActiveFaculty();
                    res.getWriter().write(JSON.toJSONString(faculty));
                } else {
                    Map<String, Object> result = new HashMap<>();
                    result.put("lectures", lectureDao.getAllActiveLectures());
                    result.put("faculty", facultyDao.getAllActiveFaculty());
                    res.getWriter().write(JSON.toJSONString(result));
                }
            } else if ("delete".equals(action)) {
                // 删除操作已移至 POST（CSRF 保护），GET 请求仅返回错误
                Map<String, Object> result = new HashMap<>();
                result.put("success", false);
                result.put("message", "删除操作请使用 POST 请求");
                res.getWriter().write(JSON.toJSONString(result));
            } else {
                req.getRequestDispatcher("/pages/adminPush.jsp").forward(req, res);
            }
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "操作失败: " + e.getMessage());
            res.getWriter().write(JSON.toJSONString(result));
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        res.setContentType("application/json;charset=UTF-8");

        try {
            String module = req.getParameter("module");
            String action = req.getParameter("action");

            // CSRF 验证
            if (!CsrfUtil.requireValidToken(req, res)) return;

            if ("delete".equals(action)) {
                String id = req.getParameter("id");
                boolean success = false;
                if ("lecture".equals(module)) {
                    success = lectureDao.deleteLecture(Integer.parseInt(id));
                } else if ("faculty".equals(module)) {
                    success = facultyDao.deleteFaculty(Integer.parseInt(id));
                }
                Map<String, Object> result = new HashMap<>();
                result.put("success", success);
                result.put("message", success ? "删除成功" : "删除失败");
                res.getWriter().write(JSON.toJSONString(result));
                return;
            }

            System.out.println("=== AdminPushServlet Debug ===");
            System.out.println("Received module: '" + module + "'");
            System.out.println("Received action: '" + action + "'");
            System.out.println("Content-Type: " + req.getContentType());

            if ("lecture".equals(module)) {
                if ("add".equals(action)) {
                    addLecture(req, res);
                } else if ("update".equals(action)) {
                    updateLecture(req, res);
                } else {
                    sendErrorResponse(res, "无效的操作类型: " + action);
                }
            } else if ("faculty".equals(module)) {
                if ("add".equals(action)) {
                    addFaculty(req, res);
                } else if ("update".equals(action)) {
                    updateFaculty(req, res);
                } else {
                    sendErrorResponse(res, "无效的操作类型: " + action);
                }
            } else {
                sendErrorResponse(res, "无效的模块: " + module);
            }

        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "操作失败: " + e.getMessage());
            res.getWriter().write(JSON.toJSONString(result));
        }
    }

    private void addLecture(HttpServletRequest req, HttpServletResponse res) throws IOException {
        try {
            Lecture lecture = new Lecture();
            lecture.setTitle(req.getParameter("title"));
            lecture.setSpeaker(req.getParameter("speaker"));
            lecture.setSpeakerTitle(req.getParameter("speakerTitle"));
            lecture.setSpeakerAvatar(req.getParameter("speakerAvatar"));
            // 使用当前时间作为默认时间
            lecture.setLectureDate(new Timestamp(System.currentTimeMillis()));
            lecture.setLectureTime(req.getParameter("lectureTime"));
            lecture.setDescription(req.getParameter("description"));
            lecture.setOnline("true".equals(req.getParameter("isOnline")));
            lecture.setMeetingUrl(req.getParameter("meetingUrl"));
            // 使用用户选择的状态
            lecture.setStatus(req.getParameter("status"));
            lecture.setSortOrder(0);

            boolean success = lectureDao.addLecture(lecture);

            Map<String, Object> result = new HashMap<>();
            result.put("success", success);
            result.put("message", success ? "讲座添加成功" : "讲座添加失败");
            res.getWriter().write(JSON.toJSONString(result));

        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "添加失败: " + e.getMessage());
            res.getWriter().write(JSON.toJSONString(result));
        }
    }

    private void updateLecture(HttpServletRequest req, HttpServletResponse res) throws IOException {
        try {
            Lecture lecture = new Lecture();
            lecture.setId(Integer.parseInt(req.getParameter("id")));
            lecture.setTitle(req.getParameter("title"));
            lecture.setSpeaker(req.getParameter("speaker"));
            lecture.setSpeakerTitle(req.getParameter("speakerTitle"));
            lecture.setSpeakerAvatar(req.getParameter("speakerAvatar"));
            // 更新时保持原有时间，暂时不允许修改日期
            lecture.setLectureDate(new Timestamp(System.currentTimeMillis()));
            lecture.setLectureTime(req.getParameter("lectureTime"));
            lecture.setDescription(req.getParameter("description"));
            lecture.setOnline("true".equals(req.getParameter("isOnline")));
            lecture.setMeetingUrl(req.getParameter("meetingUrl"));
            lecture.setStatus(req.getParameter("status"));
            lecture.setSortOrder(0);

            boolean success = lectureDao.updateLecture(lecture);

            Map<String, Object> result = new HashMap<>();
            result.put("success", success);
            result.put("message", success ? "讲座更新成功" : "讲座更新失败");
            res.getWriter().write(JSON.toJSONString(result));

        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "更新失败: " + e.getMessage());
            res.getWriter().write(JSON.toJSONString(result));
        }
    }

    private void addFaculty(HttpServletRequest req, HttpServletResponse res) throws IOException {
        try {
            Faculty faculty = new Faculty();
            faculty.setName(req.getParameter("facultyName"));
            faculty.setTitle(req.getParameter("facultyTitle"));
            faculty.setDepartment(req.getParameter("department"));
            faculty.setEmail(req.getParameter("email"));
            faculty.setOffice(req.getParameter("office"));
            faculty.setBio(req.getParameter("bio"));
            faculty.setResearchArea(req.getParameter("researchArea"));
            faculty.setOfficeHours(req.getParameter("officeHours"));
            faculty.setSortOrder(0);
            faculty.setActive(true);

            boolean success = facultyDao.addFaculty(faculty);

            Map<String, Object> result = new HashMap<>();
            result.put("success", success);
            result.put("message", success ? "导师添加成功" : "导师添加失败");
            res.getWriter().write(JSON.toJSONString(result));

        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "添加失败: " + e.getMessage());
            res.getWriter().write(JSON.toJSONString(result));
        }
    }

    private void updateFaculty(HttpServletRequest req, HttpServletResponse res) throws IOException {
        try {
            Faculty faculty = new Faculty();
            faculty.setId(Integer.parseInt(req.getParameter("id")));
            faculty.setName(req.getParameter("facultyName"));
            faculty.setTitle(req.getParameter("facultyTitle"));
            faculty.setDepartment(req.getParameter("department"));
            faculty.setEmail(req.getParameter("email"));
            faculty.setOffice(req.getParameter("office"));
            faculty.setBio(req.getParameter("bio"));
            faculty.setResearchArea(req.getParameter("researchArea"));
            faculty.setOfficeHours(req.getParameter("officeHours"));
            faculty.setSortOrder(0);
            faculty.setActive(true);

            boolean success = facultyDao.updateFaculty(faculty);

            Map<String, Object> result = new HashMap<>();
            result.put("success", success);
            result.put("message", success ? "导师更新成功" : "导师更新失败");
            res.getWriter().write(JSON.toJSONString(result));

        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "更新失败: " + e.getMessage());
            res.getWriter().write(JSON.toJSONString(result));
        }
    }

    private void sendErrorResponse(HttpServletResponse res, String message) throws IOException {
        Map<String, Object> result = new HashMap<>();
        result.put("success", false);
        result.put("message", message);
        res.getWriter().write(JSON.toJSONString(result));
    }
}
