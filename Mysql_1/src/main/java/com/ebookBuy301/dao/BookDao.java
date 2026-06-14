package com.ebookBuy301.dao;

import com.ebookBuy301.db.DBManager;
import com.ebookBuy301.pojo.Book;
import com.ebookBuy301.pojo.BookType;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

/**
 * ===========================================================================
 * BookDao —— 图书数据访问层（DAO）
 * ===========================================================================
 *
 * 底层技术    JDBC + PreparedStatement（全部参数化查询，防止 SQL 注入）
 * 连接管理    DBManager.getConnection() + closeResources() 统一释放
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                           用途
 * ─────────────────────────────────────────────────────────────────────────
 * getAllBooks()                  查询全部图书（LEFT JOIN booktype 获取分类名）
 * getBookById(long)              根据主键查询单本图书
 * addBook(Book)                  新增图书（10 个字段 INSERT）
 * updateBook(Book)               全字段更新图书（9 个字段 SET）
 * updateBookCover(long, String)  仅更新封面路径（封面管理弹窗专用）
 * deleteBook(long)               根据主键删除图书
 * searchBookByE(Book)            动态多条件搜索（参数化 IN 子句 + LIKE 模糊）
 * extractBook(ResultSet)         从结果集抽取 Book 对象（不含 JOIN）
 * extractBookWithJoin(ResultSet) 从结果集抽取 Book + BookType（含 LEFT JOIN）
 * closeResources()               统一释放 ResultSet / PreparedStatement / Connection
 *
 * ── 使用的关键算法 ──────────────────────────────────────────────────────────
 *
 * 算法 / 技术                    说明
 * ─────────────────────────────────────────────────────────────────────────
 * 参数化 SQL + 动态占位符         全部查询使用 PreparedStatement，IN 子句根据
 *                                参数个数动态生成 "?" 占位符
 * ArrayList<Object> 参数收集器    动态拼接 SQL 时同步收集参数，最后统一 setObject()
 * StringBuilder 拼接 SQL          逐条件追加 AND 子句，避免字符串常量池膨胀
 * LEFT JOIN 一次查询              一次 SQL 同时获取 book + booktype 两表数据
 * try-with-resources (外层)       标准 JDBC 资源管理范式
 *
 * @SpringBoot 注意：本项目使用原生 JDBC，无需 ORM 框架
 * ===========================================================================
 */
public class BookDao {

    // ═════════════════════════════════════════════════════════════════════
    //  1. 获取所有图书
    //    SQL：SELECT JOIN booktype，结果按 id 降序
    // ═════════════════════════════════════════════════════════════════════

    public ArrayList<Book> getAllBooks() {
        ArrayList<Book> books = new ArrayList<>();
        String sql = "SELECT b.*, bt.bTid, bt.bTypeName, bt.btText, bt.bTPerentId "
                   + "FROM book b LEFT JOIN booktype bt ON b.type_id = bt.bTid";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                books.add(extractBookWithJoin(rs));
            }
        } catch (SQLException e) {
            System.err.println("[BookDao] SQL 错误：" + e.getMessage());
            e.printStackTrace();
        }
        return books;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  2. 根据 ID 查询图书
    //    SQL：WHERE b.id = ?（参数化查询）
    // ═════════════════════════════════════════════════════════════════════

    public Book getBookById(long id) throws ClassNotFoundException {
        Book book = null;
        String sql = "SELECT b.*, bt.bTid, bt.bTypeName, bt.btText, bt.bTPerentId "
                   + "FROM book b LEFT JOIN booktype bt ON b.type_id = bt.bTid WHERE b.id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    book = extractBookWithJoin(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return book;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  3. 添加图书
    //    SQL：INSERT INTO book (10 个字段) VALUES (10 个 ?)
    //    使用 PreparedStatement 依次 setXxx()，避免 SQL 注入
    // ═════════════════════════════════════════════════════════════════════

    public int addBook(Book book) throws ClassNotFoundException {
        String sql = "INSERT INTO book(id, book_title, book_author, book_summary, type_id, "
                   + "download_times, book_pubYear, book_file, book_cover, book_format) "
                   + "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1,   book.getId());
            ps.setString(2,  book.getBookTitle());
            ps.setString(3,  book.getBookAuthor());
            ps.setString(4,  book.getBookSummary());
            ps.setString(5,  book.getTypeId());
            ps.setLong(6,    book.getDownloadTimes());
            ps.setDate(7,    book.getBookPubYear());
            ps.setString(8,  book.getBookFile());
            ps.setString(9,  book.getBookCover());
            ps.setString(10, book.getBookFormat());
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    //  4. 更新图书（全字段）
    //    SQL：UPDATE book SET 9 个字段 = ? WHERE id = ?
    // ═════════════════════════════════════════════════════════════════════

    public int updateBook(Book book) throws ClassNotFoundException {
        String sql = "UPDATE book SET book_title=?, book_author=?, book_summary=?, type_id=?, "
                   + "download_times=?, book_pubYear=?, book_file=?, book_cover=?, book_format=? "
                   + "WHERE id=?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, book.getBookTitle());
            ps.setString(2, book.getBookAuthor());
            ps.setString(3, book.getBookSummary());
            ps.setString(4, book.getTypeId());
            ps.setLong(5,   book.getDownloadTimes());
            ps.setDate(6,   book.getBookPubYear());
            ps.setString(7, book.getBookFile());
            ps.setString(8, book.getBookCover());
            ps.setString(9, book.getBookFormat());
            ps.setLong(10,  book.getId());
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    //  5. 仅更新图书封面路径
    //    SQL：UPDATE book SET book_cover = ? WHERE id = ?
    //    专用于封面管理弹窗的上传 / 删除封面操作
    // ═════════════════════════════════════════════════════════════════════

    public int updateBookCover(long id, String coverPath) {
        String sql = "UPDATE book SET book_cover=? WHERE id=?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, coverPath);
            ps.setLong(2, id);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    //  6. 删除图书
    //    SQL：DELETE FROM book WHERE id = ?
    //    注意：物理文件清理由 Servlet 层的 deleteBookFiles() 处理
    // ═════════════════════════════════════════════════════════════════════

    public int deleteBook(long id) throws ClassNotFoundException {
        String sql = "DELETE FROM book WHERE id=?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    //  7. 多条件动态搜索
    //
    //   算法：根据 Book 对象中的非空字段动态拼接 WHERE 子句，
    //         同时用 ArrayList<Object> 收集所有参数值，
    //         最后统一用 preparedStatement.setObject() 设置占位符。
    //
    //   支持的条件：
    //     书名 / 作者 / 简介    → LIKE %keyword%（参数化）
    //     分类 ID               → 单个 = ?，多个 IN (?,?,?)（动态生成占位符）
    //     文件格式              → = ?（精确匹配）
    //
    //   安全：全部使用 PreparedStatement 占位符，0 次字符串拼接用户输入
    // ═════════════════════════════════════════════════════════════════════

    public ArrayList<Book> searchBookByE(Book book) throws ClassNotFoundException, SQLException {
        ArrayList<Book> books = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT b.*, bt.bTid, bt.bTypeName, bt.btText, bt.bTPerentId "
          + "FROM book b LEFT JOIN booktype bt ON b.type_id = bt.bTid WHERE 1=1");

        ArrayList<Object> params = new ArrayList<>();

        if (book != null) {
            if (book.getBookTitle() != null && !book.getBookTitle().trim().isEmpty()) {
                sql.append(" AND b.book_title LIKE ?");
                params.add("%" + book.getBookTitle().trim() + "%");
            }
            if (book.getBookAuthor() != null && !book.getBookAuthor().trim().isEmpty()) {
                sql.append(" AND b.book_author LIKE ?");
                params.add("%" + book.getBookAuthor().trim() + "%");
            }
            if (book.getTypeId() != null && !book.getTypeId().trim().isEmpty()) {
                String typeIdVal = book.getTypeId().trim();
                if (typeIdVal.contains(",")) {
                    String[] ids = typeIdVal.split(",");
                    sql.append(" AND b.type_id IN (");
                    for (int i = 0; i < ids.length; i++) {
                        if (i > 0) sql.append(",");
                        sql.append("?");
                        params.add(ids[i].trim());
                    }
                    sql.append(")");
                } else {
                    sql.append(" AND b.type_id = ?");
                    params.add(typeIdVal);
                }
            }
            if (book.getBookSummary() != null && !book.getBookSummary().trim().isEmpty()) {
                sql.append(" AND b.book_summary LIKE ?");
                params.add("%" + book.getBookSummary().trim() + "%");
            }
            if (book.getBookFormat() != null && !book.getBookFormat().trim().isEmpty()) {
                sql.append(" AND b.book_format = ?");
                params.add(book.getBookFormat().trim());
            }
        }

        sql.append(" ORDER BY b.id DESC");
        System.out.println("[searchBookByE] SQL: " + sql);

        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    books.add(extractBookWithJoin(rs));
                }
            }
        }
        return books;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  8. 关键词搜索图书（书名 + 作者 + 简介三字段模糊匹配）
    // ═════════════════════════════════════════════════════════════════════

    public ArrayList<Book> searchBooks(String keyword) {
        ArrayList<Book> books = new ArrayList<>();
        String sql = "SELECT b.*, bt.bTid, bt.bTypeName, bt.btText, bt.bTPerentId "
                   + "FROM book b LEFT JOIN booktype bt ON b.type_id = bt.bTid "
                   + "WHERE b.book_title LIKE ? OR b.book_author LIKE ? OR b.book_summary LIKE ? "
                   + "ORDER BY b.id DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String kw = "%" + keyword.trim() + "%";
            ps.setString(1, kw);
            ps.setString(2, kw);
            ps.setString(3, kw);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    books.add(extractBookWithJoin(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[BookDao] searchBooks SQL 错误：" + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
        return books;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  9. 按分类获取图书
    // ═════════════════════════════════════════════════════════════════════

    public ArrayList<Book> getBooksByType(String typeId) {
        ArrayList<Book> books = new ArrayList<>();
        String sql = "SELECT b.*, bt.bTid, bt.bTypeName, bt.btText, bt.bTPerentId "
                   + "FROM book b LEFT JOIN booktype bt ON b.type_id = bt.bTid "
                   + "WHERE b.type_id = ? ORDER BY b.download_times DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, typeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    books.add(extractBookWithJoin(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[BookDao] getBooksByType SQL 错误：" + e.getMessage());
            e.printStackTrace();
        }
        return books;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  9b. 分页查询图书
    // ═════════════════════════════════════════════════════════════════════

    public ArrayList<Book> getBooksPage(int offset, int limit) {
        ArrayList<Book> books = new ArrayList<>();
        String sql = "SELECT b.*, bt.bTid, bt.bTypeName, bt.btText, bt.bTPerentId "
                   + "FROM book b LEFT JOIN booktype bt ON b.type_id = bt.bTid "
                   + "ORDER BY b.id DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    books.add(extractBookWithJoin(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[BookDao] getBooksPage SQL 错误：" + e.getMessage());
            e.printStackTrace();
        }
        return books;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  10. 获取图书总数
    // ═════════════════════════════════════════════════════════════════════

    public long getTotalBookCount() throws ClassNotFoundException {
        String sql = "SELECT COUNT(*) AS cnt FROM book";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getLong("cnt");
            }
        } catch (SQLException e) {
            System.err.println("[BookDao] getTotalBookCount SQL 错误：" + e.getMessage());
        }
        return 0;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  11. 抽取图书对象（不含分类 JOIN）
    //    使用 ResultSet.getXxx() 逐字段提取 book 表自身字段
    // ═════════════════════════════════════════════════════════════════════

    private Book extractBook(ResultSet rs) throws SQLException {
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
        return book;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  9. 抽取图书对象（含 LEFT JOIN 的分类信息）
    //    提取 book 表字段后，额外构建 BookType 对象并关联
    // ═════════════════════════════════════════════════════════════════════

    private Book extractBookWithJoin(ResultSet rs) throws SQLException {
        Book book = extractBook(rs);  // 复用基本字段抽取

        BookType bookType = new BookType();
        bookType.setbTid(rs.getString("bTid"));
        bookType.setbTypeName(rs.getString("bTypeName"));
        bookType.setBtText(rs.getString("btText"));
        bookType.setbTPerentId(rs.getString("bTPerentId"));
        book.setBookType(bookType);

        return book;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  10. 统一释放 JDBC 资源
    //     关闭顺序：ResultSet → PreparedStatement → Connection
    //     任一资源为 null 则跳过，异常仅打印不抛出
    // ═════════════════════════════════════════════════════════════════════

    private void closeResources(ResultSet rs, PreparedStatement ps, Connection conn) {
        try {
            if (rs   != null) rs.close();
            if (ps   != null) ps.close();
            if (conn != null) DBManager.close(conn);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
