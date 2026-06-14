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
 * ===========================================================================
 * CreativeWorkshopServlet —— 创意工坊页面转发
 * ===========================================================================
 *
 * 映射路径        /creativeWorkshop
 * 底层技术        Java EE Servlet
 * 数据访问        内存种子数据（无 DAO）
 * 最后更新        2026-06-13
 *
 * ── 路由表 ─────────────────────────────────────────────────────────────────
 *
 * 【GET】
 *   无 action          → 加载创意作品数据，forward 到 creativeWorkshop.jsp
 *   category=all/x     → 按分类筛选作品
 *
 * ── 使用的关键方法与算法 ────────────────────────────────────────────────────
 *
 * 方法 / 技术                  用途
 * ─────────────────────────────────────────────────────────────────
 * req.getParameter("category")   获取分类筛选参数
 * HashMap / ArrayList            构建作品数据与统计信息
 * RequestDispatcher.forward()     JSP 页面转发
 * ===========================================================================
 */
@WebServlet("/creativeWorkshop")
public class CreativeWorkshopServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String category = req.getParameter("category");

        // 创意作品种子数据
        ArrayList<Map<String, Object>> works = new ArrayList<>();
        String[][] data = {
            {"1", "赛博朋克城市", "3d", "3D建模", "张同学", "以未来都市为灵感的3D场景建模，包含全息广告牌和飞行汽车", "2026-05-15", "328"},
            {"2", "水墨山水动画", "animation", "动画", "李同学", "将传统水墨画与现代动画技术结合，展现江南水乡之美", "2026-05-14", "256"},
            {"3", "数字肖像系列", "digital", "数字艺术", "王同学", "使用数字绘画工具创作的肖像作品集，探索人物表情的数字化表达", "2026-05-13", "189"},
            {"4", "校园导视系统", "design", "设计", "赵同学", "为博雅书院设计的全套导视系统，包含路牌、楼层指引和电子地图", "2026-05-12", "412"},
            {"5", "机械臂模型", "3d", "3D建模", "孙同学", "工业机械臂的精细3D建模，包含完整的关节运动系统", "2026-05-11", "567"},
            {"6", "粒子特效合集", "animation", "动画", "周同学", "多种粒子特效的动画展示，包括火焰、水流、光效等", "2026-05-10", "234"},
            {"7", "复古海报设计", "design", "设计", "吴同学", "借鉴20世纪海报设计风格创作的系列作品", "2026-05-09", "178"},
            {"8", "概念汽车渲染", "3d", "3D建模", "郑同学", "未来概念汽车的高质量3D渲染图", "2026-05-08", "345"},
            {"9", "动态字体设计", "digital", "数字艺术", "陈同学", "将汉字笔画与动态效果结合的创新字体设计", "2026-05-07", "267"},
            {"10", "虚拟展览空间", "design", "设计", "林同学", "线上艺术展览的虚拟空间设计方案", "2026-05-06", "198"},
            {"11", "分形艺术生成器", "digital", "数字艺术", "黄同学", "基于数学公式的分形图案自动生成工具", "2026-05-05", "421"},
            {"12", "角色动画短片", "animation", "动画", "许同学", "原创角色设计的30秒动画短片", "2026-05-04", "389"},
        };
        for (String[] d : data) {
            if (category != null && !"all".equals(category) && !category.equals(d[1])) continue;
            Map<String, Object> m = new HashMap<>();
            m.put("id", d[0]); m.put("name", d[2]); m.put("category", d[1]);
            m.put("categoryLabel", d[3]); m.put("author", d[4]);
            m.put("description", d[5]); m.put("date", d[6]); m.put("likes", d[7]);
            works.add(m);
        }
        req.setAttribute("works", works);
        req.setAttribute("currentCategory", category != null ? category : "all");

        // 统计
        Map<String, Integer> stats = new HashMap<>();
        stats.put("total", data.length);
        stats.put("3d", 3); stats.put("animation", 3); stats.put("digital", 3); stats.put("design", 3);
        req.setAttribute("stats", stats);

        req.getRequestDispatcher("/pages/creativeWorkshop.jsp").forward(req, res);
    }
}
