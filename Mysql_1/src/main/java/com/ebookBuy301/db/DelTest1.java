/**
 * ===========================================================================
 * DelTest1 —— 业务逻辑类
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
 *   id = ?")
 *   rows = preparedStatement.executeUpdate()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   JDBC —— Connection / PreparedStatement / ResultSet 数据库访问
 *
 * ===========================================================================
 */

package com.ebookBuy301.db;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * =============================================================================
 * DelTest1 —— 数据库删除测试类（命令行工具）
 * =============================================================================
 *
 * 用于测试数据库删除操作，直接运行 main 方法。
 * 测试从 users 表中删除指定 ID 的用户。
 * =============================================================================
 */
public class DelTest1 {
    public static void main(String[] args) throws SQLException, ClassNotFoundException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        try {
            connection = DBManager.getConnection();
            preparedStatement = connection.prepareStatement("DELETE FROM users WHERE id=?");
            preparedStatement.setString(1, "u010");
            int rows = preparedStatement.executeUpdate();
            System.out.println("删除了 " + rows + " 行记录");
        } finally {
            if (preparedStatement != null) preparedStatement.close();
            if (connection != null) DBManager.close(connection);
        }
    }
}
