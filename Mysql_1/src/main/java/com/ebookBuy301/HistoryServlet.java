/**
 * ===========================================================================
 * HistoryServlet —— Servlet 控制器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301
 * 注解      @WebServlet
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * doGet(HttpServletRequest request, HttpServletResponse response)HTTP 请求处理入口
 * createRecord(String year, String title, String description)新增操作
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   dao = new CultureNotificationDao()
 *   records = dao.getAllHistoryRecords()
 *   record = new HistoryRecord()
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

import com.ebookBuy301.dao.CultureNotificationDao;
import com.ebookBuy301.db.DBManager;
import com.ebookBuy301.pojo.HistoryRecord;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.ArrayList;

/**
 * =============================================================================
 * HistoryServlet —— 数字史册页面展示
 * =============================================================================
 *
 * 从数据库动态加载历史记录，转发到史册页面（/pages/history.jsp）。
 * 如果数据库无数据，使用内置的兜底数据展示。
 *
 * 访问路径：/history
 * =============================================================================
 */
@WebServlet("/history")
public class HistoryServlet extends HttpServlet {

    private CultureNotificationDao dao = new CultureNotificationDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {
            // 从数据库读取历史记录
            ArrayList<HistoryRecord> records = dao.getAllHistoryRecords();

            // 如果数据库没有数据，先尝试种子数据初始化
            if (records == null || records.isEmpty()) {
                seedHistoryData();
                records = dao.getAllHistoryRecords();
            }

            // 再次尝试后仍为空，使用内置兜底数据
            if (records == null || records.isEmpty()) {
                records = new ArrayList<>();
                records.add(createRecord("2025", "创生纪元",
                        "博雅书院前瞻布局，以「人文+科技」双螺旋结构创建，设立文理交叉研究院。"));
                records.add(createRecord("2026", "生态扩展",
                        "建成八大智能学域，包括建筑智能、计算机科学、量子信息、计算艺术等。"));
                records.add(createRecord("2027", "智慧融合",
                        "打造全球智慧学园，赋能元宇宙教育，推动知识平权与科技向善。"));
            }

            request.setAttribute("records", records);
            request.getRequestDispatcher("/pages/history.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            // 异常时返回回退数据
            ArrayList<HistoryRecord> fallback = new ArrayList<>();
            fallback.add(createRecord("2025", "博雅书院", "博雅书院线上智慧校园正式运行。"));
            request.setAttribute("records", fallback);
            request.getRequestDispatcher("/pages/history.jsp").forward(request, response);
        }
    }

    /**
     * 首次访问时自动初始化种子历史数据到数据库
     */
    private void seedHistoryData() {
        String checkSql = "SELECT COUNT(*) FROM history_records";
        String insertSql = "INSERT INTO history_records (year, title, description, sort_order, is_active) VALUES (?, ?, ?, ?, 1)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement checkPs = conn.prepareStatement(checkSql);
             java.sql.ResultSet rs = checkPs.executeQuery()) {
            if (rs.next() && rs.getInt(1) == 0) {
                try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                    String[][] data = {
                        {"2025", "创生纪元", "博雅书院前瞻布局，以「人文+科技」双螺旋结构创建，设立文理交叉研究院。"},
                        {"2024", "AI教学助手上线", "推出智能教学助手，为每位学生提供个性化学习建议与24小时学术支持。"},
                        {"2023", "量子计算课程开设", "国内高校首批开设量子计算本科课程，引进顶尖师资，建设量子计算实验室。"},
                        {"2022", "数字人文研究院成立", "跨学科研究数字技术与人文科学的融合，推动传统文化数字化保护与创新。"},
                        {"2021", "星链教育计划", "发射首颗教育卫星，开启太空教育时代，实现全球远程教育覆盖。"},
                        {"2020", "智能选课系统", "上线AI驱动的智能选课推荐系统，基于学生兴趣与能力模型个性化推荐课程。"}
                    };
                    for (int i = 0; i < data.length; i++) {
                        insertPs.setString(1, data[i][0]);
                        insertPs.setString(2, data[i][1]);
                        insertPs.setString(3, data[i][2]);
                        insertPs.setInt(4, i + 1);
                        insertPs.executeUpdate();
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[HistoryServlet] 种子数据插入失败：" + e.getMessage());
        }
    }

    private HistoryRecord createRecord(String year, String title, String description) {
        HistoryRecord record = new HistoryRecord();
        record.setYear(year);
        record.setTitle(title);
        record.setDescription(description);
        return record;
    }
}
