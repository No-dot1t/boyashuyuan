/**
 * ===========================================================================
 * MajorBooksServlet —— Servlet 控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet, @param, @param, @throws, @throws, @param, @return, @param, @return, @param, @return, @param, @return, @throws
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * doGet(HttpServletRequest request, HttpServletResponse response)HTTP 请求处理入口
 * getMajorById(int majorId)          查询操作
 * getBooksByMajorCode(String majorCode)查询操作
 * getLinkedBookTypes(String majorCode)查询操作
 * extractBook(ResultSet rs)          数据抽取
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   majorIdStr = request.getParameter("majorId")
 *   major = getMajorById(majorId)
 *   majorCode = major.getCode()
 *   books = getBooksByMajorCode(majorCode)
 *   linkedTypes = getLinkedBookTypes(majorCode)
 *   major = null
 *   sql = "SELECT * FROM major WHERE id = ? AND is_active = 1"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {

            ps.setInt(1, majorId)
 *   rs = ps.executeQuery()) {
                if (rs.next()) {
                    major = new Major()
 *   books = new ArrayList<>()
 *   sql = "SELECT b.*, bt.bTid, bt.bTypeName, bt.btText, bt.bTPerentId "
                   + "FROM book b "
                   + "INNER JOIN major_book_type mbt ON b.type_id = mbt.book_type_id "
                   + "LEFT JOIN booktype bt ON b.type_id = bt.bTid "
                   + "WHERE mbt.major_code = ? "
                   + "ORDER BY b.download_times DESC, b.id DESC"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {

            ps.setString(1, majorCode)
 *   rs = ps.executeQuery()) {
                while (rs.next()) {
                    Book book = extractBook(rs)
 *   types = new ArrayList<>()
 *   sql = "SELECT bt.bTid, bt.bTypeName, bt.btText, bt.bTPerentId "
                   + "FROM major_book_type mbt "
                   + "INNER JOIN booktype bt ON mbt.book_type_id = bt.bTid "
                   + "WHERE mbt.major_code = ? "
                   + "ORDER BY bt.bTypeName"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {

            ps.setString(1, majorCode)
 *   rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookType bt = new BookType()
 *   book = new Book()
 *   bookType = new BookType()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   @WebServlet —— 注解式 Servlet 路由映射
 *   Servlet API —— HttpServlet / HttpServletRequest / HttpServletResponse
 *   JDBC —— Connection / PreparedStatement / ResultSet 数据库访问
 *   doGet() —— GET 请求分发
 *   action 参数分发模式 —— 通过 request.getParameter("action") 分流操作
 *   ResultSet 行映射 —— 手动抽取字段 → POJO 对象
 *
 * ===========================================================================
 */

package com.ebookBuy301;

import com.ebookBuy301.dao.MajorDao;
import com.ebookBuy301.db.DBManager;
import com.ebookBuy301.pojo.Book;
import com.ebookBuy301.pojo.BookType;
import com.ebookBuy301.pojo.Major;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;

/**
 * =============================================================================
 * MajorBooksServlet —— 学域关联图书浏览
 * =============================================================================
 *
 * 根据学域 ID 查询关联的图书列表，转发到学域图书浏览页面。
 *
 * 访问路径：/majorBooks?majorId=1
 *
 * 工作流程：
 *   1. 接收 majorId 参数，查询 major 表获取学域信息
 *   2. 根据学域 code 查询关联的图书（通过 major_book_type 中间表）
 *   3. 同时查询该学域关联的分类列表（用于页面筛选）
 *   4. 转发到 /pages/majorBooks.jsp
 * =============================================================================
 */
@WebServlet("/majorBooks")
public class MajorBooksServlet extends HttpServlet {

    /**
     * 处理 GET 请求 —— 展示学域关联的图书列表
     *
     * @param request  HTTP 请求对象（需含 majorId 参数）
     * @param response HTTP 响应对象
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ===== 0. 确保 major_book_type 中间表存在 =====
        ensureMajorBookTypeTable();

        // ===== 1. 校验 majorId 参数 =====
        String majorIdStr = request.getParameter("majorId");
        if (majorIdStr == null || majorIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/majorMatrix");
            return;
        }

        int majorId;
        try {
            majorId = Integer.parseInt(majorIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/majorMatrix");
            return;
        }

        // ===== 2. 查询学域信息及关联数据 =====
        try {
            // 查询学域信息
            Major major = new MajorDao().getMajorById(majorId);
            if (major == null) {
                response.sendRedirect(request.getContextPath() + "/majorMatrix");
                return;
            }
            request.setAttribute("major", major);

            // 查询关联图书（按下载量降序排列）
            String majorCode = major.getCode();
            ArrayList<Book> books = getBooksByMajorCode(majorCode);
            request.setAttribute("books", books);

            // 查询关联的图书分类列表
            ArrayList<BookType> linkedTypes = getLinkedBookTypes(majorCode);
            request.setAttribute("linkedTypes", linkedTypes);

            // ===== 3. 转发到学域图书页面 =====
            request.getRequestDispatcher("/pages/majorBooks.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/majorMatrix");
        }
    }

    /**
     * 确保 major_book_type 中间表存在
     */
    private void ensureMajorBookTypeTable() {
        String sql = "CREATE TABLE IF NOT EXISTS major_book_type ("
                   + "id BIGINT AUTO_INCREMENT PRIMARY KEY, "
                   + "major_code VARCHAR(100) NOT NULL, "
                   + "book_type_id VARCHAR(50) NOT NULL, "
                   + "INDEX idx_major_code (major_code), "
                   + "INDEX idx_book_type_id (book_type_id)"
                   + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        try (Connection conn = DBManager.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(sql);
        } catch (Exception e) {
            System.err.println("[MajorBooksServlet] 建表失败：" + e.getMessage());
        }
    }

    /**
     * 根据学域 code 查询关联的所有图书
     * <p>
     * 通过 major_book_type 中间表关联 book 表，按下载量降序排列。
     *
     * @param majorCode 学域代码
     * @return 图书列表
     */
    private ArrayList<Book> getBooksByMajorCode(String majorCode) {
        ArrayList<Book> books = new ArrayList<>();

        String sql = "SELECT b.*, bt.bTid, bt.bTypeName, bt.btText, bt.bTPerentId "
                   + "FROM book b "
                   + "INNER JOIN major_book_type mbt ON b.type_id = mbt.book_type_id "
                   + "LEFT JOIN booktype bt ON b.type_id = bt.bTid "
                   + "WHERE mbt.major_code = ? "
                   + "ORDER BY b.download_times DESC, b.id DESC";

        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, majorCode);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Book book = extractBook(rs);
                    books.add(book);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return books;
    }

    /**
     * 根据学域 code 查询关联的图书分类列表
     *
     * @param majorCode 学域代码
     * @return 图书分类列表
     */
    private ArrayList<BookType> getLinkedBookTypes(String majorCode) {
        ArrayList<BookType> types = new ArrayList<>();

        String sql = "SELECT bt.bTid, bt.bTypeName, bt.btText, bt.bTPerentId "
                   + "FROM major_book_type mbt "
                   + "INNER JOIN booktype bt ON mbt.book_type_id = bt.bTid "
                   + "WHERE mbt.major_code = ? "
                   + "ORDER BY bt.bTypeName";

        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, majorCode);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookType bt = new BookType();
                    bt.setbTid(rs.getString("bTid"));
                    bt.setbTypeName(rs.getString("bTypeName"));
                    bt.setBtText(rs.getString("btText"));
                    bt.setbTPerentId(rs.getString("bTPerentId"));
                    types.add(bt);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return types;
    }

    /**
     * 从 ResultSet 中提取 Book 对象（含分类 JOIN 信息）
     *
     * @param rs 数据库结果集
     * @return Book 对象
     * @throws Exception 数据库访问异常
     */
    private Book extractBook(ResultSet rs) throws Exception {
        Book book = new Book();
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

        BookType bookType = new BookType();
        bookType.setbTid(rs.getString("bTid"));
        bookType.setbTypeName(rs.getString("bTypeName"));
        bookType.setBtText(rs.getString("btText"));
        bookType.setbTPerentId(rs.getString("bTPerentId"));
        book.setBookType(bookType);

        return book;
    }
}
