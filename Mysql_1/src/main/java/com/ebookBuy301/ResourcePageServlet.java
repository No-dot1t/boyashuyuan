/**
 * ===========================================================================
 * ResourcePageServlet —— 资源中心页面控制器 v2.0
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 路由      /resourcePage
 * 最后更新  2026-06-04
 *
 * GET /resourcePage → 渲染资源中心页面（加载图书分类和列表）
 * GET /resourcePage?action=list → JSON 图书列表（支持筛选、搜索、分页）
 * GET /resourcePage?action=categories → JSON 分类列表
 *
 * v2.0 改进：fastjson 替代手动 StringBuilder、分页支持
 * ===========================================================================
 */

package com.ebookBuy301;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.ebookBuy301.dao.BookDao;
import com.ebookBuy301.dao.BookTypeDao;
import com.ebookBuy301.pojo.Book;
import com.ebookBuy301.pojo.BookType;
import com.ebookBuy301.pojo.Users;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Comparator;

@WebServlet("/resourcePage")
public class ResourcePageServlet extends HttpServlet {

    private BookDao bookDao;
    private BookTypeDao bookTypeDao;
    private static final int PAGE_SIZE = 12;

    @Override
    public void init() throws ServletException {
        bookDao = new BookDao();
        bookTypeDao = new BookTypeDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        Users currentUser = (Users) request.getSession().getAttribute("currentUser");
        String action = request.getParameter("action");

        // API 模式
        if (action != null) {
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();

            try {
                switch (action) {
                    case "list": {
                        String keyword = request.getParameter("keyword");
                        String typeId = request.getParameter("typeId");
                        String sort = request.getParameter("sort");
                        int page = parseInt(request.getParameter("page"), 1);
                        int offset = (page - 1) * PAGE_SIZE;

                        ArrayList<Book> books;
                        long total;

                        if (keyword != null && !keyword.trim().isEmpty()) {
                            books = bookDao.searchBooks(keyword.trim());
                            total = books.size();
                            // 手动分页切片
                            if (offset < books.size()) {
                                int end = Math.min(offset + PAGE_SIZE, books.size());
                                books = new ArrayList<>(books.subList(offset, end));
                            } else {
                                books = new ArrayList<>();
                            }
                        } else if (typeId != null && !typeId.isEmpty()) {
                            books = bookDao.getBooksByType(typeId);
                            total = books.size();
                            if (offset < books.size()) {
                                int end = Math.min(offset + PAGE_SIZE, books.size());
                                books = new ArrayList<>(books.subList(offset, end));
                            } else {
                                books = new ArrayList<>();
                            }
                        } else {
                            total = bookDao.getTotalBookCount();
                            books = bookDao.getBooksPage(offset, PAGE_SIZE);
                        }

                        // 按下载量排序
                        if ("popular".equals(sort) && books != null) {
                            books.sort(Comparator.comparingLong(Book::getDownloadTimes).reversed());
                        }

                        out.print(buildListJson(books, total, page, PAGE_SIZE));
                        break;
                    }
                    case "categories": {
                        ArrayList<BookType> types = bookTypeDao.getAllTypes();
                        out.print(buildCategoriesJson(types));
                        break;
                    }
                    default:
                        out.print("{\"success\":false,\"message\":\"未知操作\"}");
                }
            } catch (Exception e) {
                JSONObject error = new JSONObject();
                error.put("success", false);
                error.put("message", e.getMessage() != null ? e.getMessage() : "服务端异常");
                out.print(error.toJSONString());
            }
            return;
        }

        // 页面模式 — 预加载分类和热门图书
        try {
            ArrayList<BookType> types = bookTypeDao.getAllTypes();
            request.setAttribute("bookTypes", types);

            ArrayList<Book> hotBooks = bookDao.getAllBooks();
            if (hotBooks != null && !hotBooks.isEmpty()) {
                hotBooks.sort(Comparator.comparingLong(Book::getDownloadTimes).reversed());
                if (hotBooks.size() > PAGE_SIZE) {
                    hotBooks = new ArrayList<>(hotBooks.subList(0, PAGE_SIZE));
                }
            }
            request.setAttribute("hotBooks", hotBooks);
            request.setAttribute("totalBooks", bookDao.getTotalBookCount());
        } catch (Exception e) {
            e.printStackTrace();
        }
        request.setAttribute("currentUser", currentUser);
        request.getRequestDispatcher("/pages/resources.jsp").forward(request, response);
    }

    // ==================== JSON 构建（fastjson） ====================

    private String buildListJson(ArrayList<Book> books, long total, int page, int pageSize) {
        JSONObject root = new JSONObject();
        root.put("success", true);
        root.put("total", total);
        root.put("page", page);
        root.put("pageSize", pageSize);
        root.put("totalPages", (int) Math.ceil((double) total / pageSize));

        JSONArray arr = new JSONArray();
        if (books != null) {
            for (Book b : books) {
                JSONObject item = new JSONObject();
                item.put("id", b.getId());
                item.put("title", b.getBookTitle());
                item.put("author", b.getBookAuthor());
                item.put("summary", b.getBookSummary() != null ? b.getBookSummary() : "");
                item.put("cover", b.getBookCover() != null ? b.getBookCover() : "");
                item.put("format", b.getBookFormat() != null ? b.getBookFormat() : "");
                item.put("downloads", b.getDownloadTimes());
                item.put("typeId", b.getTypeId() != null ? b.getTypeId() : "");
                item.put("typeName", b.getTypeName() != null ? b.getTypeName() : "");
                item.put("year", b.getBookPubYear() != null ? b.getBookPubYear().toString().substring(0, 4) : "");
                item.put("isHot", b.getDownloadTimes() > 1000);
                arr.add(item);
            }
        }
        root.put("books", arr);
        return root.toJSONString();
    }

    private String buildCategoriesJson(ArrayList<BookType> types) {
        JSONObject root = new JSONObject();
        root.put("success", true);
        JSONArray arr = new JSONArray();
        if (types != null) {
            for (BookType t : types) {
                JSONObject item = new JSONObject();
                item.put("id", t.getbTid());
                item.put("name", t.getbTypeName());
                arr.add(item);
            }
        }
        root.put("categories", arr);
        return root.toJSONString();
    }

    private int parseInt(String val, int defaultVal) {
        if (val == null || val.isEmpty()) return defaultVal;
        try {
            return Integer.parseInt(val);
        } catch (NumberFormatException e) {
            return defaultVal;
        }
    }
}
