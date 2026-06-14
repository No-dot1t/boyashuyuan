/**
 * ===========================================================================
 * SelecTest2 —— 业务逻辑类
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
 *   id = ?")
 *   users = new Users()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   JDBC —— Connection / PreparedStatement / ResultSet 数据库访问
 *
 * ===========================================================================
 */

package com.ebookBuy301.db;

import com.ebookBuy301.pojo.Users;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * =============================================================================
 * SelecTest2 —— 数据库查询测试类（命令行工具）
 * =============================================================================
 *
 * 用于测试根据 ID 查询用户的数据库操作，直接运行 main 方法。
 * 查询 users 表中指定 ID 的用户信息并打印。
 * =============================================================================
 */
public class SelecTest2 {
    public static void main(String[] args) throws ClassNotFoundException, SQLException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet rs = null;
        try {
            connection = DBManager.getConnection();
            preparedStatement = connection.prepareStatement("SELECT * FROM users WHERE id=?");
            preparedStatement.setString(1, "u009");
            rs = preparedStatement.executeQuery();
            if (rs.next()) {
                Users users = new Users();
                users.setId(rs.getString("id"));
                users.setUsername(rs.getString("username"));
                users.setPassword(rs.getString("password"));
                users.setSex(rs.getString("sex"));
                users.setAge(rs.getLong("age"));
                users.setEmail(rs.getString("email"));
                System.out.println(users);
            }
        } finally {
            if (rs != null) rs.close();
            if (preparedStatement != null) preparedStatement.close();
            if (connection != null) DBManager.close(connection);
        }
    }
}
