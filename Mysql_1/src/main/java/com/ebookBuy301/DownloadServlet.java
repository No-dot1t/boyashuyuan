/**
 * ===========================================================================
 * DownloadServlet —— Servlet 控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet, @param, @param, @throws, @throws, @param
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * doGet(HttpServletRequest request, HttpServletResponse response)HTTP 请求处理入口
 * incrementDownloadCount(long bookId)内部工具方法
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   bookDao = new BookDao()
 *   bookIdStr = request.getParameter("bookId")
 *   bookId = Long.parseLong(bookIdStr.trim())
 *   book = bookDao.getBookById(bookId)
 *   bookFilePath = book.getBookFile()
 *   realPath = this.getServletContext().getRealPath("/") + bookFilePath
 *   file = new File(realPath)
 *   fileName = file.getName()
 *   underscoreIdx = fileName.indexOf('_')
 *   displayName = (underscoreIdx > 0) ? fileName.substring(underscoreIdx + 1) : fileName
 *   fis = new FileInputStream(file)
 *   os = response.getOutputStream()) {

                byte[] buffer = new byte[8192]
 *   sql = "UPDATE book SET download_times = download_times + 1 WHERE id = ?"
 *   conn = DBManager.getConnection()
 *   ps = conn.prepareStatement(sql)) {

            ps.setLong(1, bookId)
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

import com.ebookBuy301.dao.BookDao;
import com.ebookBuy301.db.DBManager;
import com.ebookBuy301.pojo.Book;
import com.ebookBuy301.util.SecurityUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * =============================================================================
 * DownloadServlet —— 图书文件下载服务
 * =============================================================================
 *
 * 负责接收客户端的图书下载请求，从服务端读取文件并流式输出到浏览器。
 * 同时自动更新数据库中的下载次数统计。
 *
 * 访问路径：/download?bookId={图书ID}
 *
 * 工作流程：
 *   1. 接收 bookId 参数，从数据库查询图书信息
 *   2. 根据 bookFile 字段获取文件在服务器上的物理路径
 *   3. 设置 Content-Disposition 响应头，触发浏览器下载
 *   4. 以 8KB 缓冲区流式推送文件（支持大文件断点续传兼容）
 *   5. 下载成功后，该图书的 download_times 字段 +1
 *
 * 异常处理：
 *   - bookId 为空/无效 → 400 Bad Request
 *   - 图书不存在      → 404 Not Found
 *   - 文件不存在       → 404 Not Found
 *   - 其他异常        → 500 Internal Server Error
 * =============================================================================
 */
@WebServlet("/download")
public class DownloadServlet extends HttpServlet {

    /** 图书数据访问层 */
    private BookDao bookDao = new BookDao();

    // ======================== GET 请求处理 ========================

    /**
     * 处理图书文件下载请求
     * <p>
     * 完整的下载处理流程：参数校验 → 图书查询 → 文件路径解析 → 文件校验
     * → 设置响应头 → 流式输出 → 更新下载次数
     *
     * @param request  HTTP 请求对象，需包含 bookId 参数
     * @param response HTTP 响应对象，输出文件流
     * @throws ServletException Servlet 处理异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ===== 1. 校验 bookId 参数 =====
        String bookIdStr = request.getParameter("bookId");
        String mode = request.getParameter("mode");
        boolean isViewMode = "view".equals(mode);   // view 模式：强制 inline 预览

        if (bookIdStr == null || bookIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "缺少图书ID");
            return;
        }

        // 安全校验：防止SQL注入和非法字符
        if (SecurityUtils.containsSqlInjection(bookIdStr)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "包含非法字符");
            return;
        }

        try {
            long bookId = Long.parseLong(bookIdStr.trim());
            
            // 验证 bookId 范围
            if (bookId <= 0 || bookId > 1000000) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "图书ID超出有效范围");
                return;
            }

            // ===== 2. 查询图书信息 =====
            Book book = bookDao.getBookById(bookId);
            if (book == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "图书不存在");
                return;
            }

            // ===== 3. 解析文件路径（支持逗号分隔的多文件） =====
            String bookFilePath = book.getBookFile();
            if (bookFilePath == null || bookFilePath.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "图书文件不存在");
                return;
            }

            // bookFile 可能包含多条路径，如 "/books/a.pdf,/books/b.epub"
            // 取第一个存在的文件
            String[] candidatePaths = bookFilePath.split(",");
            File file = null;
            String matchedFormat = null;
            for (String candidate : candidatePaths) {
                if (candidate == null || candidate.trim().isEmpty()) continue;
                String realPath = this.getServletContext().getRealPath("/") + candidate.trim();
                File f = new File(realPath);
                if (f.exists() && f.isFile()) {
                    file = f;
                    // 从路径中推断格式
                    String lower = candidate.trim().toLowerCase();
                    if (lower.endsWith(".pdf")) matchedFormat = "pdf";
                    else if (lower.endsWith(".epub")) matchedFormat = "epub";
                    else if (lower.endsWith(".mobi")) matchedFormat = "mobi";
                    else if (lower.endsWith(".txt")) matchedFormat = "txt";
                    break;
                }
            }

            if (file == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "文件未找到");
                return;
            }

            // ===== 4. 提取原始文件名（去掉 UUID 前缀） =====
            // 上传时文件名格式：UUID_原文件名.pdf
            // 下载时展示：原文件名.pdf
            String fileName = file.getName();
            int underscoreIdx = fileName.indexOf('_');
            String displayName = (underscoreIdx > 0) ? fileName.substring(underscoreIdx + 1) : fileName;

            // ===== 5. 根据文件类型设置 Content-Type =====
            String contentType;
            if ("pdf".equals(matchedFormat)) contentType = "application/pdf";
            else if ("epub".equals(matchedFormat)) contentType = "application/epub+zip";
            else if ("mobi".equals(matchedFormat)) contentType = "application/x-mobipocket-ebook";
            else if ("txt".equals(matchedFormat)) contentType = "text/plain;charset=UTF-8";
            else contentType = "application/octet-stream";

            response.setContentType(contentType);
            
            // 添加安全响应头，防止浏览器拦截
            response.setHeader("X-Content-Type-Options", "nosniff");
            response.setHeader("X-Frame-Options", "SAMEORIGIN");
            response.setHeader("X-XSS-Protection", "1; mode=block");
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate, max-age=0");
            response.setHeader("Pragma", "no-cache");
            response.setHeader("Expires", "Thu, 01 Jan 1970 00:00:00 GMT");
            
            // view 模式强制 inline 预览（浏览器内渲染），否则 attachment 下载
            String disposition = isViewMode ? "inline" : "attachment";
            String encodedName = URLEncoder.encode(displayName, "UTF-8").replace("+", "%20");
            response.setHeader("Content-Disposition", disposition + "; filename=\"" + encodedName + "\"; filename*=UTF-8''" + encodedName);
            response.setContentLengthLong(file.length());

            // ===== 6. 流式输出文件到浏览器 =====
            boolean downloadSuccess = false;
            try (FileInputStream fis = new FileInputStream(file);
                 OutputStream os = response.getOutputStream()) {

                byte[] buffer = new byte[8192];
                int bytesRead;
                while ((bytesRead = fis.read(buffer)) != -1) {
                    os.write(buffer, 0, bytesRead);
                }
                os.flush();
                downloadSuccess = true;
            }

            // ===== 7. 下载成功后更新下载次数 =====
            if (downloadSuccess) {
                incrementDownloadCount(bookId);
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "无效的图书ID");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "下载失败");
        }
    }

    // ======================== 私有方法 ========================

    /**
     * 增加指定图书的下载次数（download_times + 1）
     * <p>
     * 在文件成功输出到浏览器后调用。此操作在文件流推送完之后执行，
     * 即使更新失败也不影响用户已获取的文件内容。
     *
     * @param bookId 图书ID
     */
    private void incrementDownloadCount(long bookId) {
        String sql = "UPDATE book SET download_times = download_times + 1 WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, bookId);
            ps.executeUpdate();

        } catch (SQLException e) {
            // 下载次数更新失败不应阻塞用户下载体验，仅记录日志
            e.printStackTrace();
        }
    }
}
