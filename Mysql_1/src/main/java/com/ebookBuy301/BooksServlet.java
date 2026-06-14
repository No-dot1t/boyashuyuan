package com.ebookBuy301;

import com.ebookBuy301.dao.BookDao;
import com.ebookBuy301.pojo.Book;
import com.ebookBuy301.db.DBManager;
import com.ebookBuy301.util.CsrfUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * ===========================================================================
 * BooksServlet —— 图书管理控制器
 * ===========================================================================
 *
 * 映射路径        /booksList
 * 底层技术        Java EE Servlet + @MultipartConfig
 * 数据访问        BookDao（JDBC + PreparedStatement）
 *
 * ── 路由表 ─────────────────────────────────────────────────────────────────
 *
 * 【GET】
 *   action=delete     → 删除图书（URL 参数方式）
 *   action=edit       → 重定向到列表页锚点 #edit-modal-{id}
 *   无 action          → 展示图书列表（支持多条件搜索 + 学域关联查询）
 *
 * 【POST】
 *   action=delete       → 删除图书（表单提交）
 *   action=updateCover  → 封面管理：上传新封面 / 删除封面
 *   action=add          → 添加图书（含封面 + 多文件上传）
 *   action=update       → 更新图书（含封面 + 多文件上传 + 旧文件清理）
 *
 * ── 使用的关键方法与算法 ────────────────────────────────────────────────────
 *
 * 方法 / 技术                用途
 * ─────────────────────────────────────────────────────────────────
 * request.getParts()         遍历 multipart 请求的所有 Part
 * Part.getSubmittedFileName() 获取上传文件的原始文件名
 * Part.getContentType()       获取 MIME 类型
 * Part.getSize()              获取文件大小（字节）
 * Part.write()                将上传文件写入磁盘
 * UUID.randomUUID()           生成唯一文件名，避免并发竞态覆盖
 * sanitizeFileName()          正则替换：移除路径遍历字符（\\ / : * ? " < > |）
 * deleteBookFiles()           删除图书关联的封面 + 所有图书物理文件
 * System.currentTimeMillis()  用作图书 ID（时间戳级别唯一）
 * String.join(",")            将多个文件路径拼接为逗号分隔字符串写入 DB
 * String.split(",")           从 DB 读取后拆分回多个路径用于清理
 * ServletContext.getRealPath() 将虚拟路径 /covers/ 转换为磁盘绝对路径
 * session flash message       将 POST 异常存入 session，GET 时取出展示
 * MIME 白名单 + 后缀校验      双重文件类型检测（白名单列表 + endsWith）
 * 分段大小限制                按文件后缀决定上限（txt→10MB, epub→50MB, pdf→100MB）
 * DB 补偿清理                 DB 写入失败时自动删除已上传的物理文件
 *
 * ── 文件上传目录 ────────────────────────────────────────────────────────────
 *   封面图片  →  {项目根}/covers/
 *   图书文件  →  {项目根}/books/
 *
 * @SpringBoot 注意：本项目使用原生 Java EE Servlet，无需框架依赖
 * ===========================================================================
 */
@WebServlet("/booksList")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,       // 1 MB：低于此值写内存，高于写临时文件
    maxFileSize       = 104857600,         // 100 MB：单个文件上限（适配最大场景——高清扫描PDF）
    maxRequestSize    = 115343360          // 110 MB：整个 multipart 请求上限（含表单字段 + 多个文件）
)
public class BooksServlet extends HttpServlet {

    // ═════════════════════════════════════════════════════════════════════
    //  文件大小常量
    //   普通文本电子书（ .txt ）     5–10  MB
    //   含图片电子书（ .epub/.mobi） 50    MB
    //   高清扫描图书（ .pdf ）       100   MB
    //   封面图片                     10    MB
    // ═════════════════════════════════════════════════════════════════════
    private static final long MAX_FILE_SIZE_COVER  = 10L * 1024 * 1024;  // 10 MB
    private static final long MAX_FILE_SIZE_TXT    = 10L * 1024 * 1024;  // 10 MB
    private static final long MAX_FILE_SIZE_EPUB   = 50L * 1024 * 1024;  // 50 MB
    private static final long MAX_FILE_SIZE_MOBI   = 50L * 1024 * 1024;  // 50 MB
    private static final long MAX_FILE_SIZE_PDF    = 100L * 1024 * 1024; // 100 MB

    private BookDao bookDao = new BookDao();

    // ═════════════════════════════════════════════════════════════════════
    //  GET 请求处理
    // ═════════════════════════════════════════════════════════════════════

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String contextPath = request.getContextPath();

        try {
            // ── 读取 session flash 错误消息（一次性消费） ──
            //  算法：POST 异常 → session.setAttribute → 302 → doGet 读取后 remove
            Object errorAttr = request.getSession().getAttribute("uploadError");
            if (errorAttr != null) {
                request.setAttribute("uploadError", errorAttr);
                request.getSession().removeAttribute("uploadError");
            }

            // ── [GET] 删除图书 → 已移至 POST（CSRF 保护）
            if ("delete".equals(action)) {
                response.sendRedirect(contextPath + "/booksList");
                return;
            }

            // ── [GET] 编辑图书（重定向到列表页锚点弹窗） ──
            if ("edit".equals(action)) {
                String idStr = request.getParameter("id");
                if (idStr != null && !idStr.trim().isEmpty()) {
                    response.sendRedirect(contextPath + "/booksList#edit-modal-" + idStr.trim());
                } else {
                    response.sendRedirect(contextPath + "/booksList");
                }
                return;
            }

            // ── 提取搜索参数 ──
            String searchTitle  = request.getParameter("searchTitle");
            String searchAuthor = request.getParameter("searchAuthor");
            String searchTypeId = request.getParameter("searchTypeId");
            String majorIdParam = request.getParameter("majorId");

            ArrayList<Book> books;

            // ── 学域关联：majorId → major.code → major_book_type → book_type_ids ──
            if (majorIdParam != null && !majorIdParam.trim().isEmpty()) {
                String majorTypeIds = getTypeIdsByMajorId(majorIdParam.trim());
                if (majorTypeIds != null && !majorTypeIds.isEmpty()) {
                    searchTypeId = majorTypeIds;
                    String majorName = getMajorNameById(majorIdParam.trim());
                    request.setAttribute("majorName", majorName);
                    request.setAttribute("fromMajor", true);
                }
            }

            // ── 判断是否有搜索条件 ──
            boolean isSearch = (searchTitle  != null && !searchTitle.trim().isEmpty()) ||
                               (searchAuthor != null && !searchAuthor.trim().isEmpty()) ||
                               (searchTypeId != null && !searchTypeId.trim().isEmpty() && !"0".equals(searchTypeId));

            if (isSearch) {
                // 多条件搜索 → 组装 Book 对象 → BookDao.searchBookByE()
                Book searchBook = new Book();
                if (searchTitle  != null && !searchTitle.trim().isEmpty())  searchBook.setBookTitle(searchTitle.trim());
                if (searchAuthor != null && !searchAuthor.trim().isEmpty()) searchBook.setBookAuthor(searchAuthor.trim());
                if (searchTypeId != null && !searchTypeId.trim().isEmpty() && !"0".equals(searchTypeId))
                    searchBook.setTypeId(searchTypeId.trim());

                try {
                    books = bookDao.searchBookByE(searchBook);
                } catch (Exception e) {
                    e.printStackTrace();
                    books = new ArrayList<>();
                }

                request.setAttribute("searchTitle",  searchTitle);
                request.setAttribute("searchAuthor", searchAuthor);
                request.setAttribute("searchTypeId", searchTypeId);
                request.setAttribute("isSearch",     true);
                request.setAttribute("showSearchPanel", true);
            } else {
                books = bookDao.getAllBooks();
            }

            // ── 转发到 JSP ──
            request.setAttribute("books", books);
            request.getRequestDispatcher("/JAVAList/booksList.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(contextPath + "/booksList");
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    //  POST 请求处理
    // ═════════════════════════════════════════════════════════════════════

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String contextPath = request.getContextPath();

        try {
            // CSRF 验证
            if (!CsrfUtil.requireValidToken(request, response)) {
                response.sendRedirect(contextPath + "/booksList?error=安全验证失败");
                return;
            }
            if ("delete".equals(action)) {
                handleDelete(request, response, contextPath);
                return;
            }
            if ("updateCover".equals(action)) {
                handleCoverManagement(request, response, contextPath);
                return;
            }
            handleAddOrUpdate(request, response, contextPath, action);

        } catch (Exception e) {
            e.printStackTrace();
            // session flash message：POST 错误 → 存 session → 302 → doGet 读取展示
            request.getSession().setAttribute("uploadError", e.getMessage());
            response.sendRedirect(contextPath + "/booksList");
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    //  删除图书
    //   算法：bookDao.getBookById() → deleteBookFiles()（磁盘清理）→ bookDao.deleteBook()（DB清理）
    // ═════════════════════════════════════════════════════════════════════

    private void handleDelete(HttpServletRequest request, HttpServletResponse response, String contextPath)
            throws IOException, ClassNotFoundException {

        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.trim().isEmpty()) {
            long id = parseLong(idStr, -1);
            if (id > 0) {
                Book book = bookDao.getBookById(id);
                if (book != null) {
                    deleteBookFiles(book);
                }
                bookDao.deleteBook(id);
            }
            response.sendRedirect(contextPath + "/booksList");
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    //  封面管理（弹窗专用）
    //   使用的 Servlet API：request.getPart("bookCover")
    //  ├─ "deleteCover" 分支：查询 → 删文件 → 更新 DB book_cover = ""
    //  └─ 上传分支        ：查旧封面 → UUID 写新文件 → 更新 DB → 删旧封面
    //   补偿机制：DB 更新失败时删除已写入的新封面文件
    // ═════════════════════════════════════════════════════════════════════

    private void handleCoverManagement(HttpServletRequest request, HttpServletResponse response, String contextPath)
            throws ServletException, IOException, ClassNotFoundException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(contextPath + "/booksList");
            return;
        }
        long bookId = parseLong(idStr, 0);
        String deleteCoverFlag = request.getParameter("deleteCover");

        if ("true".equals(deleteCoverFlag)) {
            // ── 删除封面分支 ──
            Book existing = bookDao.getBookById(bookId);
            String oldCover = (existing != null) ? existing.getBookCover() : "";
            if (oldCover != null && !oldCover.isEmpty()) {
                new File(this.getServletContext().getRealPath("/") + oldCover).delete();
            }
            bookDao.updateBookCover(bookId, "");
        } else {
            // ── 上传新封面分支 ──
            Part coverPart = request.getPart("bookCover");
            String fileName = (coverPart != null) ? coverPart.getSubmittedFileName() : null;

            if (fileName != null && !fileName.trim().isEmpty()) {
                // 第 1 步：DB 更新前查询旧封面路径
                Book existing = bookDao.getBookById(bookId);
                String oldCover = (existing != null) ? existing.getBookCover() : "";

                // 第 2 步：写入新封面（UUID + sanitize 防止竞态和路径遍历）
                String uploadPath = this.getServletContext().getRealPath("/") + "covers";
                new File(uploadPath).mkdirs();
                String safeName = sanitizeFileName(fileName);
                String uniqueName = UUID.randomUUID().toString() + "_" + safeName;
                coverPart.write(uploadPath + File.separator + uniqueName);
                String newCoverPath = "/covers/" + uniqueName;

                // 第 3 步：更新 DB → 失败则补偿删除新文件
                int result = bookDao.updateBookCover(bookId, newCoverPath);
                if (result <= 0) {
                    new File(uploadPath + File.separator + uniqueName).delete();
                    throw new ServletException("数据库更新封面失败");
                }

                // 第 4 步：DB 成功后才删除旧封面
                if (oldCover != null && !oldCover.isEmpty()) {
                    new File(this.getServletContext().getRealPath("/") + oldCover).delete();
                }
            }
        }
        response.sendRedirect(contextPath + "/booksList");
    }

    // ═════════════════════════════════════════════════════════════════════
    //  添加 / 更新图书（核心方法）
    //   流程：校验 → 获取旧数据 → req.getParts() 遍历处理 → 组装 Book → DB 写入
    //   使用的关键技术与算法：
    //   ① request.getParts()      遍历所有 multipart Part
    //   ② MIME 白名单 + 后缀校验  双重文件类型检测
    //   ③ 分段大小限制             按后缀区分上限（txt/epub/pdf）
    //   ④ UUID + sanitize         唯一文件名 + 防路径遍历
    //   ⑤ 更新时旧文件清理         逗号分隔路径拆解后逐个 delete()
    //   ⑥ DB 补偿清理             DB 写失败时自动删除已上传文件
    // ═════════════════════════════════════════════════════════════════════

    private void handleAddOrUpdate(HttpServletRequest request, HttpServletResponse response,
                                   String contextPath, String action)
            throws ServletException, IOException, ClassNotFoundException {

        // ── 1. 书名校验 ──
        String bookTitle = request.getParameter("bookTitle");
        if (bookTitle == null || bookTitle.trim().isEmpty()) {
            response.sendRedirect(contextPath + "/booksList");
            return;
        }

        // ── 2. 解析图书 ID ──
        String idStr = request.getParameter("id");
        long bookId = parseLong(idStr, 0);

        // ── 3. 更新操作 → 获取旧数据（用于保留旧文件路径 + 清理旧文件） ──
        Book existingBook = null;
        if ("update".equals(action) && bookId > 0) {
            existingBook = bookDao.getBookById(bookId);
        }

        // ── 4. 获取前端选中的文件格式（用于后续扩展名校验） ──
        String selectedFormat = request.getParameter("bookFormat");

        // ── 5. 使用 req.getParts() 统一遍历所有文件上传 ──
        //  算法：for each Part → 按 fieldName 分流 bookCover / bookFiles
        //  校验链：后缀白名单 → MIME 白名单 → 格式匹配 → 大小限制
        String coverFileName = null;
        boolean hasNewCover = false;
        List<String> uploadedBookFilePaths = new ArrayList<>();
        List<String> uploadedTxtRealPaths = new ArrayList<>(); // 跟踪 TXT 文件的磁盘路径

        Collection<Part> allParts = request.getParts();
        for (Part part : allParts) {
            String fieldName        = part.getName();
            String submittedFileName = part.getSubmittedFileName();
            String contentType       = part.getContentType();

            // 跳过空文件和表单文本字段
            if (part.getSize() <= 0 || submittedFileName == null || submittedFileName.trim().isEmpty()) {
                continue;
            }

            /* ── 封面图片（bookCover）── */
            if ("bookCover".equals(fieldName)) {
                String fileExt = submittedFileName.toLowerCase();

                // ① 后缀白名单校验（正则遍历：endsWith 逐一匹配）
                if (!(fileExt.endsWith(".jpg") || fileExt.endsWith(".jpeg") ||
                      fileExt.endsWith(".png")  || fileExt.endsWith(".gif") ||
                      fileExt.endsWith(".webp"))) {
                    throw new ServletException("封面只允许上传 JPG/PNG/GIF/WEBP 格式：" + submittedFileName);
                }
                // ② MIME 类型白名单校验（Arrays.asList().contains()）
                if (contentType != null && !Arrays.asList(
                        "image/jpeg", "image/png", "image/gif", "image/webp").contains(contentType)) {
                    throw new ServletException("封面不允许的文件类型：" + contentType);
                }
                // ③ 大小校验
                if (part.getSize() > MAX_FILE_SIZE_COVER) {
                    throw new ServletException("封面超过 10 MB：" + submittedFileName
                            + "（" + (part.getSize() / (1024 * 1024)) + " MB）");
                }

                // ④ 写入磁盘（UUID 防竞态 + sanitize 防路径遍历）
                String uploadPath = this.getServletContext().getRealPath("/") + "covers";
                new File(uploadPath).mkdirs();
                String uniqueCoverName = UUID.randomUUID().toString() + "_" + sanitizeFileName(submittedFileName);
                part.write(uploadPath + File.separator + uniqueCoverName);

                coverFileName = uniqueCoverName;
                hasNewCover = true;

                // ⑤ 更新操作 → 删除旧封面
                if (existingBook != null && existingBook.getBookCover() != null
                        && !existingBook.getBookCover().isEmpty()) {
                    String oldPath = getServletContext().getRealPath("/") + existingBook.getBookCover();
                    File f = new File(oldPath);
                    if (f.exists()) f.delete();
                }
            }

            /* ── 图书文件（bookFiles，支持 multiple）── */
            if ("bookFiles".equals(fieldName)) {
                String fileExt = submittedFileName.toLowerCase();

                // ① 后缀白名单
                if (!(fileExt.endsWith(".pdf") || fileExt.endsWith(".epub") ||
                      fileExt.endsWith(".mobi") || fileExt.endsWith(".txt"))) {
                    throw new ServletException("只允许 PDF/EPUB/MOBI/TXT，当前：" + submittedFileName);
                }
                // ② MIME 类型白名单
                if (contentType != null && !Arrays.asList(
                        "application/pdf", "application/epub+zip",
                        "application/x-mobipocket-ebook", "text/plain").contains(contentType)) {
                    throw new ServletException("图书不允许的文件类型：" + contentType);
                }
                // ③ 格式匹配：上传文件后缀必须与选中的 bookFormat 一致
                if (selectedFormat != null && !selectedFormat.trim().isEmpty()) {
                    String formatExt = "." + selectedFormat.trim().toLowerCase();
                    if (!fileExt.endsWith(formatExt)) {
                        throw new ServletException("文件格式不匹配：选择了 \"" + selectedFormat
                                + "\"，上传的文件 \"" + submittedFileName + "\" 不是 " + formatExt + " 格式");
                    }
                }
                // ④ 分段大小限制（按后缀决定上限）
                long maxSize;
                String sizeHint;
                if (fileExt.endsWith(".txt")) {
                    maxSize = MAX_FILE_SIZE_TXT;  sizeHint = "10 MB";
                } else if (fileExt.endsWith(".epub") || fileExt.endsWith(".mobi")) {
                    maxSize = MAX_FILE_SIZE_EPUB; sizeHint = "50 MB";
                } else {
                    maxSize = MAX_FILE_SIZE_PDF;  sizeHint = "100 MB";
                }
                if (part.getSize() > maxSize) {
                    throw new ServletException("文件超过 " + sizeHint + "：" + submittedFileName
                            + "（" + (part.getSize() / (1024 * 1024)) + " MB）");
                }

                // ⑤ 写入磁盘
                String uploadPath = this.getServletContext().getRealPath("/") + "books";
                new File(uploadPath).mkdirs();
                String uniqueFileName = UUID.randomUUID().toString() + "_" + sanitizeFileName(submittedFileName);
                part.write(uploadPath + File.separator + uniqueFileName);
                uploadedBookFilePaths.add("/books/" + uniqueFileName);

                // ⑥ 记录 TXT 文件的磁盘路径（后续解析章节用）
                if (fileExt.endsWith(".txt")) {
                    uploadedTxtRealPaths.add(uploadPath + File.separator + uniqueFileName);
                }
            }
        }

        boolean hasNewFiles = !uploadedBookFilePaths.isEmpty();

        // ── 6. 更新操作 → 删除旧的图书文件（逗号分隔路径逐个清理） ──
        //  算法：String.split(",") 拆分多条路径 → for each → File.delete()
        if (hasNewFiles && existingBook != null
                && existingBook.getBookFile() != null
                && !existingBook.getBookFile().isEmpty()) {
            String[] oldPaths = existingBook.getBookFile().split(",");
            for (String path : oldPaths) {
                if (path != null && !path.trim().isEmpty()) {
                    File f = new File(this.getServletContext().getRealPath("/") + path.trim());
                    if (f.exists()) f.delete();
                }
            }
        }

        // ── 7. 组装 Book 对象 ──
        Book book = new Book();
        book.setBookTitle(bookTitle.trim());
        book.setBookAuthor(getParam(request, "bookAuthor", ""));
        book.setBookSummary(getParam(request, "bookSummary", ""));
        book.setTypeId(getParam(request, "typeId", "0"));
        book.setDownloadTimes(parseLong(request.getParameter("downloadTimes"), 0));
        book.setBookPubYear(parseSqlDate(request.getParameter("bookPubYear")));
        book.setBookFormat(getParam(request, "bookFormat", ""));

        // 封面路径：新上传 / 保留旧 / 空
        if (hasNewCover) {
            book.setBookCover("/covers/" + coverFileName);
        } else if (existingBook != null) {
            book.setBookCover(existingBook.getBookCover());
        } else {
            book.setBookCover("");
        }

        // 图书文件路径：多个用逗号拼接（String.join()）
        if (hasNewFiles) {
            book.setBookFile(String.join(",", uploadedBookFilePaths));
        } else if (existingBook != null) {
            book.setBookFile(existingBook.getBookFile());
        } else {
            book.setBookFile("");
        }

        // ── 8. 执行 DB 写入 + 补偿清理 ──
        //  补偿算法：try → DB 操作 → 失败则自动删除已上传的文件 → rethrow
        try {
            if ("add".equals(action)) {
                book.setId(System.currentTimeMillis());
                if (bookDao.addBook(book) <= 0) {
                    throw new ServletException("数据库写入失败，图书未保存");
                }
                // 解析 TXT 章节内容
                for (String txtPath : uploadedTxtRealPaths) {
                    parseAndSaveTxtChapters(book.getId(), txtPath);
                }
                response.sendRedirect(contextPath + "/booksList");

            } else if ("update".equals(action)) {
                if (bookId > 0) {
                    book.setId(bookId);
                    if (bookDao.updateBook(book) <= 0) {
                        throw new ServletException("数据库更新失败，图书未修改");
                    }
                }
                // 如果有新的 TXT 文件，先删除旧章节再解析新章节
                if (!uploadedTxtRealPaths.isEmpty()) {
                    deleteBookChapters(bookId);
                    for (String txtPath : uploadedTxtRealPaths) {
                        parseAndSaveTxtChapters(bookId, txtPath);
                    }
                }
                response.sendRedirect(contextPath + "/booksList");
            }
        } catch (Exception e) {
            // 补偿：DB 失败 → 清理本次上传的物理文件
            if (hasNewCover && book.getBookCover() != null && !book.getBookCover().isEmpty()) {
                new File(this.getServletContext().getRealPath("/") + book.getBookCover()).delete();
            }
            if (hasNewFiles) {
                for (String path : uploadedBookFilePaths) {
                    new File(this.getServletContext().getRealPath("/") + path).delete();
                }
            }
            throw e;
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    //  工具方法
    // ═════════════════════════════════════════════════════════════════════

    /**
     * 安全获取请求参数，为空时返回默认值。
     *
     * @param request      HTTP 请求对象
     * @param name         参数名
     * @param defaultValue 默认值
     * @return 参数值（去空格），为空则返回 defaultValue
     */
    private String getParam(HttpServletRequest request, String name, String defaultValue) {
        String value = request.getParameter(name);
        return (value != null && !value.trim().isEmpty()) ? value.trim() : defaultValue;
    }

    /**
     * 安全解析长整型，解析失败返回默认值。
     * 使用 Long.parseLong() + NumberFormatException 捕获。
     *
     * @param value        字符串数值
     * @param defaultValue 默认值
     * @return 解析后的 long，失败返回 defaultValue
     */
    private long parseLong(String value, long defaultValue) {
        if (value == null || value.trim().isEmpty()) return defaultValue;
        try {
            return Long.parseLong(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /**
     * 安全解析 SQL Date，解析失败返回 null。
     * 使用 java.sql.Date.valueOf(dateStr) + IllegalArgumentException 捕获。
     *
     * @param dateStr 日期字符串（yyyy-MM-dd）
     * @return java.sql.Date，失败返回 null
     */
    private java.sql.Date parseSqlDate(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) return null;
        try {
            return java.sql.Date.valueOf(dateStr.trim());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    /**
     * 删除图书关联的所有物理文件（封面 + 所有图书文件）。
     * <p>
     * 算法：bookCover 单个删除 + bookFile 逗号分隔后逐个删除。
     * 用于删除图书时先清理磁盘再删 DB，防止孤儿文件。
     *
     * @param book 图书对象（需包含 bookCover 和 bookFile 路径）
     */
    private void deleteBookFiles(Book book) {
        if (book.getBookCover() != null && !book.getBookCover().isEmpty()) {
            File f = new File(this.getServletContext().getRealPath("/") + book.getBookCover());
            if (f.exists()) f.delete();
        }
        if (book.getBookFile() != null && !book.getBookFile().isEmpty()) {
            for (String path : book.getBookFile().split(",")) {
                if (path != null && !path.trim().isEmpty()) {
                    File f = new File(this.getServletContext().getRealPath("/") + path.trim());
                    if (f.exists()) f.delete();
                }
            }
        }
    }

    /**
     * 净化文件名，移除路径分隔符和特殊字符，防止路径遍历攻击。
     * <p>
     * 算法：String.replaceAll() 正则替换
     *   \\ / : * ? " < > |  → 下划线 _
     *   空白字符               → 下划线 _
     *
     * @param fileName 原始文件名
     * @return 净化后的安全文件名
     */
    private String sanitizeFileName(String fileName) {
        if (fileName == null) return "";
        return fileName.replaceAll("[\\\\/:*?\"<>|]", "_").replaceAll("\\s+", "_");
    }

    /**
     * 根据 majorId 查询关联的所有图书分类 ID（逗号分隔）。
     * <p>
     * 查询链路：
     *   major.id → major.code → major_book_type.major_code → book_type_id
     * 使用 SQL：两条 PreparedStatement 查询，逐行拼接逗号分隔字符串。
     *
     * @param majorIdStr 学域ID
     * @return 逗号分隔的图书分类ID字符串，e.g. "1,3,5"
     */
    private String getTypeIdsByMajorId(String majorIdStr) {
        String majorCode = null;
        String codeSql = "SELECT code FROM major WHERE id = ? AND is_active = 1";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(codeSql)) {
            ps.setInt(1, Integer.parseInt(majorIdStr));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) majorCode = rs.getString("code");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
        if (majorCode == null) return null;

        StringBuilder sb = new StringBuilder();
        String linkSql = "SELECT book_type_id FROM major_book_type WHERE major_code = ? ORDER BY book_type_id";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(linkSql)) {
            ps.setString(1, majorCode);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    if (sb.length() > 0) sb.append(",");
                    sb.append(rs.getString("book_type_id"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return sb.length() > 0 ? sb.toString() : null;
    }

    /**
     * 根据 majorId 查询学域名称。
     * 使用 PreparedStatement 参数化查询。
     *
     * @param majorIdStr 学域ID
     * @return 学域名称，未找到返回 null
     */
    private String getMajorNameById(String majorIdStr) {
        String sql = "SELECT name FROM major WHERE id = ? AND is_active = 1";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(majorIdStr));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("name");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  TXT 图书章节解析
    //  原理：读取 TXT 文件内容 → 正则匹配章节标题 → 拆分章节 → 逐条写入 book_content
    //  章节标题支持格式：
    //    第X章 / 第X节 / 第X篇 / Chapter X / Section X
    //    其中 X 可以是中文数字（一二三）或阿拉伯数字（123）
    //  如果未检测到章节标题，整本书作为单章插入
    // ═════════════════════════════════════════════════════════════════════

    /**
     * 章节标题匹配正则
     * 匹配形如：第1章、第一章、第01章、Chapter 1、Section 1 的行首标题
     */
    private static final Pattern CHAPTER_PATTERN = Pattern.compile(
            "^(第[一二三四五六七八九十百零\\d零一二三四五六七八九十百千]+[章节篇部])" +
            "|^(Chapter\\s+\\d+)" +
            "|^(Section\\s+\\d+)" +
            "|^(Part\\s+\\d+)",
            Pattern.MULTILINE
    );

    /**
     * 删除指定图书的所有章节数据
     */
    private void deleteBookChapters(long bookId) {
        String sql = "DELETE FROM book_content WHERE book_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId);
            ps.executeUpdate();
        } catch (Exception e) {
            System.err.println("[BooksServlet] 删除旧章节失败：" + e.getMessage());
        }
    }

    /**
     * 解析 TXT 文件内容，提取章节并存入 book_content 表。
     * <p>
     * 解析策略：
     *   1. 按行读取 TXT 文件（UTF-8 编码）
     *   2. 用正则匹配行首的章节标题
     *   3. 根据标题位置将全文切割为多个章节
     *   4. 若未找到任何章节标题，将全文作为单章插入
     *   5. 自动创建 book_content 表（如不存在）
     *
     * @param bookId      图书 ID
     * @param realFilePath TXT 文件的磁盘绝对路径
     */
    private void parseAndSaveTxtChapters(long bookId, String realFilePath) {
        // 确保表存在
        try (Connection conn = DBManager.getConnection();
             java.sql.Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS book_content ("
                + "id INT AUTO_INCREMENT PRIMARY KEY, "
                + "book_id INT NOT NULL, "
                + "chapter_num INT NOT NULL, "
                + "chapter_title VARCHAR(200) NOT NULL, "
                + "content TEXT NOT NULL, "
                + "word_count INT DEFAULT 0, "
                + "sort_order INT DEFAULT 0, "
                + "UNIQUE KEY uk_book_chapter (book_id, chapter_num)"
                + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            );
        } catch (Exception e) {
            System.err.println("[BooksServlet] 建表失败：" + e.getMessage());
            return;
        }

        try {
            // 读取所有行
            List<String> lines = Files.readAllLines(Paths.get(realFilePath), StandardCharsets.UTF_8);
            if (lines.isEmpty()) return;

            // 构建全文（含换行）
            StringBuilder fullText = new StringBuilder();
            for (String line : lines) {
                fullText.append(line).append("\n");
            }
            String content = fullText.toString();

            // 查找所有章节标题的位置
            Matcher matcher = CHAPTER_PATTERN.matcher(content);
            List<int[]> chapterBoundaries = new ArrayList<>(); // [start, end] in content
            List<String> chapterTitles = new ArrayList<>();

            while (matcher.find()) {
                int start = matcher.start();
                String title = matcher.group().trim();
                // 取第一个非空的分组
                for (int g = 1; g <= matcher.groupCount(); g++) {
                    if (matcher.group(g) != null) {
                        title = matcher.group(g).trim();
                        break;
                    }
                }
                chapterBoundaries.add(new int[]{start, 0});
                chapterTitles.add(title);
            }

            // 如果没有找到章节标题，整本书作为单章
            if (chapterBoundaries.isEmpty()) {
                saveSingleChapter(bookId, content);
                return;
            }

            // 设置每个章节的结束位置（下一章的起始位置或文件末尾）
            for (int i = 0; i < chapterBoundaries.size(); i++) {
                int end = (i + 1 < chapterBoundaries.size())
                        ? chapterBoundaries.get(i + 1)[0]
                        : content.length();
                chapterBoundaries.get(i)[1] = end;
            }

            // 批量写入章节
            String insertSql = "INSERT INTO book_content (book_id, chapter_num, chapter_title, content, word_count, sort_order) "
                             + "VALUES (?, ?, ?, ?, ?, ?) "
                             + "ON DUPLICATE KEY UPDATE chapter_title=VALUES(chapter_title), content=VALUES(content), word_count=VALUES(word_count)";
            try (Connection conn = DBManager.getConnection();
                 PreparedStatement ps = conn.prepareStatement(insertSql)) {
                for (int i = 0; i < chapterBoundaries.size(); i++) {
                    int[] bound = chapterBoundaries.get(i);
                    String chapterContent = content.substring(bound[0], bound[1]).trim();
                    int wordCount = countWords(chapterContent);

                    ps.setLong(1, bookId);
                    ps.setInt(2, i + 1);
                    ps.setString(3, chapterTitles.get(i));
                    ps.setString(4, chapterContent);
                    ps.setInt(5, wordCount);
                    ps.setInt(6, i + 1);
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            System.out.println("[BooksServlet] 已解析 TXT 章节：" + chapterBoundaries.size() + " 章，图书 ID=" + bookId);

        } catch (Exception e) {
            System.err.println("[BooksServlet] TXT 章节解析失败：" + e.getMessage());
            // 非致命错误，不影响图书上传
        }
    }

    /**
     * 整本书作为一个章节保存（未检测到章节标题时使用）
     */
    private void saveSingleChapter(long bookId, String content) {
        String title = content.length() > 50 ? content.substring(0, 50).trim() + "..." : content.trim();
        // 取第一行作为标题
        int newlineIdx = content.indexOf('\n');
        if (newlineIdx > 0) {
            title = content.substring(0, newlineIdx).trim();
            if (title.length() > 100) title = title.substring(0, 100);
        }
        int wordCount = countWords(content);

        String sql = "INSERT INTO book_content (book_id, chapter_num, chapter_title, content, word_count, sort_order) "
                   + "VALUES (?, 1, ?, ?, ?, 1) "
                   + "ON DUPLICATE KEY UPDATE chapter_title=VALUES(chapter_title), content=VALUES(content), word_count=VALUES(word_count)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId);
            ps.setString(2, title);
            ps.setString(3, content);
            ps.setInt(4, wordCount);
            ps.executeUpdate();
            System.out.println("[BooksServlet] 已保存单章内容，图书 ID=" + bookId);
        } catch (Exception e) {
            System.err.println("[BooksServlet] 单章保存失败：" + e.getMessage());
        }
    }

    /**
     * 统计文本字数（去除空白字符后的字符数）
     */
    private int countWords(String text) {
        if (text == null || text.isEmpty()) return 0;
        return text.replaceAll("\\s+", "").length();
    }
}
