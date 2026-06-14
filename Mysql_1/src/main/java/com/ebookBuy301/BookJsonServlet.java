/**
 * ===========================================================================
 * BookJsonServlet —— Servlet 控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet, @param, @param, @throws, @throws
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * doGet(HttpServletRequest request, HttpServletResponse response)HTTP 请求处理入口
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   bookDao = new BookDao()
 *   bTPerentId = request.getParameter("bTPerentId")
 *   bookType = new BookType()
 *   typeId = request.getParameter("typeId")
 *   searchTitle = request.getParameter("searchTitle")
 *   searchAuthor = request.getParameter("searchAuthor")
 *   hasCondition = (typeId != null && !typeId.trim().isEmpty()) ||
                                   (searchTitle != null && !searchTitle.trim().isEmpty()) ||
                                   (searchAuthor != null && !searchAuthor.trim().isEmpty())
 *   book = new Book()
 *   jsonString = JSON.toJSONString(books)
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   @WebServlet —— 注解式 Servlet 路由映射
 *   Servlet API —— HttpServlet / HttpServletRequest / HttpServletResponse
 *   doGet() —— GET 请求分发
 *   action 参数分发模式 —— 通过 request.getParameter("action") 分流操作
 *
 * ===========================================================================
 */

package com.ebookBuy301;

import com.alibaba.fastjson.JSON;
import com.ebookBuy301.dao.BookDao;
import com.ebookBuy301.dao.BookTypeDao;
import com.ebookBuy301.pojo.Book;
import com.ebookBuy301.pojo.BookType;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

/**
 * =============================================================================
 * BookJsonServlet —— 图书 JSON 数据接口
 * =============================================================================
 *
 * 返回 JSON 格式的图书数据，供前端通过 Axios 异步获取。
 *
 * 访问路径：/bookJson
 *
 * 请求参数（均为可选）：
 * - typeId → 按分类 ID 筛选
 * - searchTitle → 按书名关键词模糊搜索
 * - searchAuthor → 按作者关键词模糊搜索
 * - bTPerentId → 父分类 ID（获取该父分类下所有子分类的图书）
 *
 * 无参数时返回全部图书列表。
 * =============================================================================
 */
@WebServlet("/bookJson")
public class BookJsonServlet extends HttpServlet {

    /** 图书数据访问层 */
    private BookDao bookDao = new BookDao();

    /**
     * 处理 GET 请求 —— 返回 JSON 格式的图书数据
     * <p>
     * 支持按分类、书名、作者多条件筛选。
     *
     * @param request  HTTP 请求对象
     * @param response HTTP 响应对象（Content-Type: text/json）
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // ===== 1. 获取查询参数 =====
            String bTPerentId = request.getParameter("bTPerentId");
            String typeId = request.getParameter("typeId");
            String searchTitle = request.getParameter("searchTitle");
            String searchAuthor = request.getParameter("searchAuthor");

            ArrayList<Book> books;

            // ===== 2. 判断是否有筛选条件 =====
            boolean hasCondition = (typeId != null && !typeId.trim().isEmpty()) ||
                    (searchTitle != null && !searchTitle.trim().isEmpty()) ||
                    (searchAuthor != null && !searchAuthor.trim().isEmpty()) ||
                    (bTPerentId != null && !bTPerentId.trim().isEmpty());

            if (hasCondition) {
                // 有筛选条件 → 使用条件查询
                Book book = new Book();

                if (typeId != null && !typeId.trim().isEmpty()) {
                    book.setTypeId(typeId.trim());
                }
                if (searchTitle != null && !searchTitle.trim().isEmpty()) {
                    book.setBookTitle(searchTitle.trim());
                }
                if (searchAuthor != null && !searchAuthor.trim().isEmpty()) {
                    book.setBookAuthor(searchAuthor.trim());
                }

                // 处理父分类查询：获取父分类下所有子分类的图书
                if (bTPerentId != null && !bTPerentId.trim().isEmpty() && typeId == null) {
                    BookTypeDao typeDao = new BookTypeDao();
                    ArrayList<BookType> childTypes = typeDao.getChildTypes(bTPerentId.trim());
                    if (!childTypes.isEmpty()) {
                        StringBuilder typeIds = new StringBuilder();
                        for (BookType child : childTypes) {
                            if (typeIds.length() > 0)
                                typeIds.append(",");
                            typeIds.append(child.getbTid());
                        }
                        book.setTypeId(typeIds.toString());
                    }
                }

                books = bookDao.searchBookByE(book);

            } else {
                // 无条件 → 查询全部图书
                books = bookDao.getAllBooks();
            }

            // ===== 3. 输出 JSON =====
            String jsonString = JSON.toJSONString(books);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write(jsonString);

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"获取图书列表失败，请稍后重试\"}");
        }
    }
}
