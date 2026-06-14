/**
 * ===========================================================================
 * BookTypeServlet —— Servlet 控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet, @param, @param, @throws, @throws, @param, @param, @throws, @throws
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * doGet(HttpServletRequest request, HttpServletResponse response)HTTP 请求处理入口
 * doPost(HttpServletRequest request, HttpServletResponse response)HTTP 请求处理入口
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   bookTypeDao = new BookTypeDao()
 *   basePath = request.getContextPath()
 *   action = request.getParameter("action")
 *   id = request.getParameter("id")
 *   searchName = request.getParameter("searchName")
 *   topTypes = bookTypeDao.getTopLevelTypes()
 *   basePath = request.getContextPath()
 *   action = request.getParameter("action")
 *   id = request.getParameter("id")
 *   bTypeName = request.getParameter("bTypeName")
 *   btText = request.getParameter("btText")
 *   bTPerentId = request.getParameter("bTPerentId")
 *   bookType = new BookType()
 *   bTid = request.getParameter("bTid")
 *   bTypeName = request.getParameter("bTypeName")
 *   btText = request.getParameter("btText")
 *   bTPerentId = request.getParameter("bTPerentId")
 *   bookType = new BookType()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   @WebServlet —— 注解式 Servlet 路由映射
 *   Servlet API —— HttpServlet / HttpServletRequest / HttpServletResponse
 *   doGet() —— GET 请求分发
 *   doPost() —— POST 请求分发
 *   action 参数分发模式 —— 通过 request.getParameter("action") 分流操作
 *
 * ===========================================================================
 */

package com.ebookBuy301;

import com.ebookBuy301.dao.BookTypeDao;
import com.ebookBuy301.pojo.BookType;
import com.ebookBuy301.util.CsrfUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.UUID;

/**
 * =============================================================================
 * BookTypeServlet —— 图书分类管理控制器
 * =============================================================================
 *
 * 处理图书分类的增删改查操作，支持多级分类管理。
 *
 * 访问路径：/bookTypeList
 *
 * GET 请求：
 *   - action=delete&id=xxx  → 删除分类
 *   - searchName=xxx        → 按名称搜索
 *   - 无参数                → 显示全部分类列表
 *
 * POST 请求：
 *   - action=delete  → 删除分类
 *   - action=add     → 添加分类（需 bTypeName、btText、bTPerentId）
 *   - action=update  → 修改分类（需 bTid、bTypeName、btText、bTPerentId）
 * =============================================================================
 */
@WebServlet("/bookTypeList")
public class BookTypeServlet extends HttpServlet {

    /** 分类数据访问层 */
    private BookTypeDao bookTypeDao = new BookTypeDao();

    // ======================== GET 请求处理 ========================

    /**
     * 处理 GET 请求 —— 查看分类列表、搜索、删除
     *
     * @param request  HTTP 请求对象
     * @param response HTTP 响应对象
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String basePath = request.getContextPath();
        String action = request.getParameter("action");

        try {
            // ---------- 2. 按名称搜索 ----------
            String searchName = request.getParameter("searchName");
            ArrayList<BookType> types;

            if (searchName != null && !searchName.trim().isEmpty()) {
                types = bookTypeDao.searchTypesByName(searchName.trim());
            } else {
                types = bookTypeDao.getAllTypes();
            }

            // 获取顶级分类（用于添加/编辑时的父分类选择）
            ArrayList<BookType> topTypes = bookTypeDao.getTopLevelTypes();

            // ---------- 3. 转发到 JSP ----------
            request.setAttribute("types", types);
            request.setAttribute("topTypes", topTypes);
            request.getRequestDispatcher("JAVAList/bookTypeList.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "操作失败：" + e.getMessage());
            request.setAttribute("types", new ArrayList<BookType>());
            request.setAttribute("topTypes", new ArrayList<BookType>());
            request.getRequestDispatcher("JAVAList/bookTypeList.jsp").forward(request, response);
        }
    }

    // ======================== POST 请求处理 ========================

    /**
     * 处理 POST 请求 —— 添加、修改、删除分类
     *
     * @param request  HTTP 请求对象
     * @param response HTTP 响应对象
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        String basePath = request.getContextPath();

        String action = request.getParameter("action");

        try {
            // CSRF 验证
            if (!CsrfUtil.requireValidToken(request, response)) return;

            // ---------- 1. 删除分类 ----------
            if ("delete".equals(action)) {
                String id = request.getParameter("id");
                if (id != null && !id.isEmpty()) {
                    bookTypeDao.deleteType(id);
                }
                response.sendRedirect(basePath + "/bookTypeList");

            // ---------- 2. 添加分类 ----------
            } else if ("add".equals(action)) {
                String bTypeName = request.getParameter("bTypeName");
                String btText = request.getParameter("btText");
                String bTPerentId = request.getParameter("bTPerentId");

                if (bTypeName == null || bTypeName.trim().isEmpty()) {
                    response.sendRedirect(basePath + "/bookTypeList");
                    return;
                }

                BookType bookType = new BookType();
                bookType.setbTid(UUID.randomUUID().toString());
                bookType.setbTypeName(bTypeName.trim());
                bookType.setBtText(btText != null ? btText : "");
                bookType.setbTPerentId(bTPerentId != null ? bTPerentId : "");

                bookTypeDao.addType(bookType);
                response.sendRedirect(basePath + "/bookTypeList");

            // ---------- 3. 修改分类 ----------
            } else if ("update".equals(action)) {
                String bTid = request.getParameter("bTid");
                String bTypeName = request.getParameter("bTypeName");
                String btText = request.getParameter("btText");
                String bTPerentId = request.getParameter("bTPerentId");

                if (bTid == null || bTypeName == null || bTypeName.trim().isEmpty()) {
                    response.sendRedirect(basePath + "/bookTypeList");
                    return;
                }

                BookType bookType = new BookType();
                bookType.setbTid(bTid);
                bookType.setbTypeName(bTypeName.trim());
                bookType.setBtText(btText != null ? btText : "");
                bookType.setbTPerentId(bTPerentId != null ? bTPerentId : "");

                bookTypeDao.updateType(bookType);
                response.sendRedirect(basePath + "/bookTypeList");

            } else {
                response.sendRedirect(basePath + "/bookTypeList");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(basePath + "/bookTypeList");
        }
    }
}
