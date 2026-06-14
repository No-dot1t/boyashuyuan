/**
 * ===========================================================================
 * SelecTest1 —— 业务逻辑类
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.db
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * main(String[] args)                内部工具方法
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   connection = null
 *   preparedStatement = null
 *   rs = null
 *   metaData = rs.getMetaData()
 *   columnCount = metaData.getColumnCount()
 *   i = 1
 *   i = 1
 *   i = 1
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   JDBC —— Connection / PreparedStatement / ResultSet 数据库访问
 *
 * ===========================================================================
 */

package com.ebookBuy301.db;

import java.sql.*;

/**
 * =============================================================================
 * SelecTest1 —— 数据库查询测试类（命令行工具）
 * =============================================================================
 *
 * 用于测试数据库查询操作，直接运行 main 方法。
 * 查询 users 表所有数据，以表格形式打印到控制台。
 * =============================================================================
 */
public class SelecTest1 {
    public static void main(String[] args) throws ClassNotFoundException, SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet rs = null;
        try {
            connection = DBManager.getConnection();
            preparedStatement = connection.prepareStatement("SELECT * FROM users");
            rs = preparedStatement.executeQuery();

            ResultSetMetaData metaData = rs.getMetaData();
            int columnCount = metaData.getColumnCount();

            // 打印表头
            System.out.print(" ");
            for (int i = 1; i <= columnCount; i++) {
                System.out.printf("%-15s ", metaData.getColumnName(i));
            }
            System.out.println();

            // 打印分隔线
            System.out.print("-");
            for (int i = 1; i <= columnCount; i++) {
                System.out.print("--------------------");
            }
            System.out.println();

            // 打印数据行
            while (rs.next()) {
                System.out.print(" ");
                for (int i = 1; i <= columnCount; i++) {
                    System.out.printf("%-15s ", rs.getString(i));
                }
                System.out.println();
            }
        } finally {
            if (rs != null) rs.close();
            if (preparedStatement != null) preparedStatement.close();
            if (connection != null) DBManager.close(connection);
        }
    }
}
