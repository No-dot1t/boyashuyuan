/**
 * ===========================================================================
 * AdminBackupServlet —— Servlet 控制器
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
 * doPost(HttpServletRequest req, HttpServletResponse res)HTTP 请求处理入口
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   result = new HashMap<>()
 *   conn = com.ebookBuy301.db.DBManager.getConnection()
 *   st = conn.createStatement()
 *   rs = st.executeQuery("SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS size_mb FROM information_schema.tables WHERE table_schema = 'javaweb'")
 *   size = "0"
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   @WebServlet —— 注解式 Servlet 路由映射
 *   Servlet API —— HttpServlet / HttpServletRequest / HttpServletResponse
 *   JDBC —— Connection / PreparedStatement / ResultSet 数据库访问
 *   doGet() —— GET 请求分发
 *   doPost() —— POST 请求分发
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
import java.io.File;
import java.io.IOException;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@WebServlet("/adminBackup")
public class AdminBackupServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.getRequestDispatcher("/pages/adminBackup.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        res.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        // 获取备份目录（WEB-INF/backups/）
        String backupDirPath = getServletContext().getRealPath("/WEB-INF/backups/");
        File backupDir = new File(backupDirPath);

        // 检查目录是否存在，不存在则尝试创建
        if (!backupDir.exists()) {
            if (!backupDir.mkdirs()) {
                result.put("success", false);
                result.put("message", "无法创建备份目录，请检查文件系统权限");
                res.getWriter().write(com.alibaba.fastjson.JSON.toJSONString(result));
                return;
            }
        }

        // 生成带时间戳和UUID的文件名，避免并发覆盖
        String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String uuid = UUID.randomUUID().toString().substring(0, 8);
        String backupFileName = "javaweb_backup_" + timestamp + "_" + uuid + ".sql";
        File backupFile = new File(backupDir, backupFileName);

        try {
            // 从系统环境变量获取数据库配置（必须配置，不再提供硬编码回退）
            String dbUser = System.getenv("DB_USER");
            String dbPassword = System.getenv("DB_PASSWORD");
            String dbName = "javaweb";

            if (dbUser == null || dbUser.isEmpty()) {
                res.getWriter().write("{\"success\":false,\"error\":\"数据库用户环境变量 DB_USER 未配置\"}");
                return;
            }
            if (dbPassword == null || dbPassword.isEmpty()) {
                res.getWriter().write("{\"success\":false,\"error\":\"数据库密码环境变量 DB_PASSWORD 未配置\"}");
                return;
            }

            // 执行 mysqldump
            // 使用 --user=xxx --password=xxx 形式更安全，避免密码中特殊字符被解析
            String[] cmd = {
                    "mysqldump",
                    "--user=" + dbUser,
                    "--password=" + dbPassword,
                    dbName,
                    "--routines",
                    "--single-transaction",
                    "--default-character-set=utf8mb4"
            };

            ProcessBuilder pb = new ProcessBuilder(cmd);
            pb.redirectOutput(backupFile);
            pb.redirectErrorStream(true);
            Process process = pb.start();
            int exitCode = process.waitFor();

            if (exitCode == 0) {
                long fileSizeKb = backupFile.length() / 1024;
                result.put("success", true);
                result.put("message", "备份成功！文件: " + backupFileName + " (" + fileSizeKb + " KB)");
                result.put("fileName", backupFileName);
                result.put("fileSize", fileSizeKb);
                result.put("time", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));
            } else {
                result.put("success", false);
                result.put("message", "mysqldump 执行失败，退出码: " + exitCode + "，请确认 mysqldump 已安装且在 PATH 中，或检查数据库密码配置");
            }
        } catch (IOException e) {
            result.put("success", false);
            result.put("message", "备份失败: mysqldump 命令未找到，请确保 MySQL 已安装且 mysqldump 在系统 PATH 中");
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "备份失败: " + e.getMessage());
        }
        res.getWriter().write(com.alibaba.fastjson.JSON.toJSONString(result));
    }
}
