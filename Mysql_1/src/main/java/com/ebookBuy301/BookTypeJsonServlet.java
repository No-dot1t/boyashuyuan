package com.ebookBuy301;

import com.alibaba.fastjson.JSON;
import com.ebookBuy301.dao.BookTypeDao;
import com.ebookBuy301.pojo.BookType;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

/**
 * ===========================================================================
 * BookTypeJsonServlet —— 图书分类 JSON 数据接口
 * ===========================================================================
 *
 * 映射路径        /bookTypeJson
 * 底层技术        Java EE Servlet
 * 数据访问        BookTypeDao（JDBC + PreparedStatement）
 * 最后更新        2026-06-13
 *
 * ── 路由表 ─────────────────────────────────────────────────────────────────
 *
 * 【GET】
 *   无 action          → 返回所有图书分类的 JSON 数据
 *
 * ── 使用的关键方法与算法 ────────────────────────────────────────────────────
 *
 * 方法 / 技术                  用途
 * ─────────────────────────────────────────────────────────────────
 * BookTypeDao.getAllTypes()      查询所有图书分类
 * JSON.toJSONString()           fastjson 对象转 JSON 字符串
 * response.getWriter().write()  输出 JSON 响应
 * response.setContentType()     设置响应类型为 application/json
 * ===========================================================================
 */
@WebServlet("/bookTypeJson")
public class BookTypeJsonServlet extends HttpServlet {

    /** 图书分类数据访问层 */
    private BookTypeDao bookTypeDao = new BookTypeDao();

    /**
     * 处理 GET 请求 —— 返回 JSON 格式的所有图书分类数据
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
            // ===== 1. 查询所有分类 =====
            ArrayList<BookType> types = bookTypeDao.getAllTypes();

            // ===== 2. 转 JSON 并输出 =====
            String jsonString = JSON.toJSONString(types);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write(jsonString);

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"获取分类列表失败，请稍后重试\"}");
        }
    }
}
