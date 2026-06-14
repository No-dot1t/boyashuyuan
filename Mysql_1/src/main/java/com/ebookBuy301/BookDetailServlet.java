/**
 * ===========================================================================
 * BookDetailServlet —— Servlet 控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet, @param, @param, @throws, @throws, @param, @return
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * doGet(HttpServletRequest request, HttpServletResponse response)HTTP 请求处理入口
 * getBookById(long bookId)           查询操作
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   bookIdStr = request.getParameter("bookId")
 *   bookId = Long.parseLong(bookIdStr.trim())
 *   book = getBookById(bookId)
 *   book = null
 *   sql = "SELECT b.*, bt.bTid, bt.bTypeName, bt.btText, bt.bTPerentId "
                   + "FROM book b LEFT JOIN booktype bt ON b.type_id = bt.bTid WHERE b.id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {

            ps.setLong(1, bookId)
 *   rs = ps.executeQuery()) {
                if (rs.next()) {
                    // 提取图书基本字段
                    book = new Book()
 *   bt = new BookType()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   @WebServlet —— 注解式 Servlet 路由映射
 *   Servlet API —— HttpServlet / HttpServletRequest / HttpServletResponse
 *   JDBC —— Connection / PreparedStatement / ResultSet 数据库访问
 *   doGet() —— GET 请求分发
 *   action 参数分发模式 —— 通过 request.getParameter("action") 分流操作
 *
 * ===========================================================================
 */

package com.ebookBuy301;

import com.ebookBuy301.db.DBManager;
import com.ebookBuy301.pojo.Book;
import com.ebookBuy301.pojo.BookType;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * =============================================================================
 * BookDetailServlet —— 图书详情展示
 * =============================================================================
 *
 * 根据图书 ID 查询图书完整信息（含分类），
 * 转发到图书详情页和在线阅读页面。
 *
 * 访问路径：/bookDetail?bookId=xxx
 *
 * 流程：
 *   1. 接收 bookId 参数
 *   2. 调用 getBookById() 查询数据库（LEFT JOIN booktype）
 *   3. 将 Book 对象存入 request，转发至 /pages/bookDetail.jsp
 * =============================================================================
 */
@WebServlet("/bookDetail")
public class BookDetailServlet extends HttpServlet {

    /**
     * 处理 GET 请求 —— 根据 bookId 展示图书详情
     *
     * @param request  HTTP 请求对象，需包含 bookId 参数
     * @param response HTTP 响应对象
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ===== 1. 校验 bookId 参数 =====
        String bookIdStr = request.getParameter("bookId");
        if (bookIdStr == null || bookIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/majorsPage");
            return;
        }

        // ===== 2. 查询图书信息并转发 =====
        try {
            long bookId = Long.parseLong(bookIdStr.trim());
            Book book = getBookById(bookId);

            if (book == null) {
                response.sendRedirect(request.getContextPath() + "/majorsPage");
                return;
            }

            request.setAttribute("book", book);
            request.getRequestDispatcher("/pages/bookDetail.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/majorsPage");
        }
    }

    /**
     * 根据图书 ID 从数据库查询完整信息（含分类 JOIN）
     *
     * @param bookId 图书 ID
     * @return Book 对象（含 BookType 分类信息），未找到返回 null
     */
    private Book getBookById(long bookId) {
        Book book = null;

        String sql = "SELECT b.*, bt.bTid, bt.bTypeName, bt.btText, bt.bTPerentId "
                   + "FROM book b LEFT JOIN booktype bt ON b.type_id = bt.bTid WHERE b.id = ?";

        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, bookId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // 提取图书基本字段
                    book = new Book();
                    book.setId(rs.getLong("id"));
                    book.setBookTitle(rs.getString("book_title"));
                    book.setBookAuthor(rs.getString("book_author"));
                    book.setBookSummary(rs.getString("book_summary"));
                    book.setTypeId(rs.getString("type_id"));
                    book.setDownloadTimes(rs.getLong("download_times"));
                    book.setBookPubYear(rs.getDate("book_pubYear"));
                    book.setBookFile(rs.getString("book_file"));
                    book.setBookCover(rs.getString("book_cover"));
                    book.setBookFormat(rs.getString("book_format"));

                    // 提取关联的分类信息
                    BookType bt = new BookType();
                    bt.setbTid(rs.getString("bTid"));
                    bt.setbTypeName(rs.getString("bTypeName"));
                    bt.setBtText(rs.getString("btText"));
                    bt.setbTPerentId(rs.getString("bTPerentId"));
                    book.setBookType(bt);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return book;
    }
}
