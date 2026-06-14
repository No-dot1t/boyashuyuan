/**
 * ===========================================================================
 * VirtualClassroomServlet —— Servlet 控制器
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
 * doGet(HttpServletRequest req, HttpServletResponse res)HTTP 请求处理入口
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   m = new HashMap<>()
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

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * VirtualClassroomServlet - 虚拟教室/课表
 * GET: 加载课表页面
 */
@WebServlet("/virtualClassroom")
public class VirtualClassroomServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        // 课表种子数据（周一到周日，1-8节）
        ArrayList<Map<String, String>> schedule = new ArrayList<>();
        String[][] data = {
            {"周一", "1", "高等数学", "张教授", "A301", "必修", "blue"},
            {"周一", "3", "大学英语", "李老师", "B205", "必修", "green"},
            {"周一", "5", "数据结构", "王教授", "C102", "专业课", "purple"},
            {"周二", "1", "线性代数", "赵教授", "A302", "必修", "blue"},
            {"周二", "3", "计算机网络", "孙教授", "D401", "专业课", "orange"},
            {"周二", "5", "体育", "刘老师", "操场", "必修", "green"},
            {"周三", "1", "高等数学", "张教授", "A301", "必修", "blue"},
            {"周三", "3", "操作系统", "钱教授", "C201", "专业课", "purple"},
            {"周三", "5", "思想政治", "周老师", "B301", "必修", "red"},
            {"周四", "1", "大学英语", "李老师", "B205", "必修", "green"},
            {"周四", "3", "数据结构实验", "王教授", "机房E101", "实验", "orange"},
            {"周四", "5", "概率论", "吴教授", "A201", "必修", "blue"},
            {"周五", "1", "线性代数", "赵教授", "A302", "必修", "blue"},
            {"周五", "3", "软件工程", "郑教授", "D302", "专业课", "purple"},
            {"周五", "5", "选修：人工智能导论", "陈教授", "A101", "选修", "cyan"},
        };
        for (String[] d : data) {
            Map<String, String> m = new HashMap<>();
            m.put("day", d[0]); m.put("period", d[1]); m.put("name", d[2]);
            m.put("teacher", d[3]); m.put("location", d[4]); m.put("type", d[5]); m.put("color", d[6]);
            schedule.add(m);
        }
        req.setAttribute("schedule", schedule);
        req.getRequestDispatcher("/pages/virtualClassroom.jsp").forward(req, res);
    }
}
