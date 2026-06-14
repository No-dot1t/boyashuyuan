/**
 * ===========================================================================
 * DBManager —— 业务逻辑类
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.db
 * 注解      @return, @throws, @param
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * initDataSource()                   初始化
 * getConnection()                    查询操作
 * close(Connection connection)       资源释放
 * shutdown()                         内部工具方法
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   config = new HikariConfig()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   JDBC —— Connection / PreparedStatement / ResultSet 数据库访问
 *   try-catch-finally —— JDBC 资源统一释放模式
 *
 * ===========================================================================
 */

package com.ebookBuy301.db;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.SQLException;
import java.io.InputStream;
import java.util.Properties;

/**
 * =============================================================================
 * DBManager —— 数据库管理类（HikariCP 连接池）
 * =============================================================================
 *
 * 使用 HikariCP 连接池管理 MySQL 数据库连接，提升性能和资源利用率。
 *
 * 数据库配置：
 *   - URL:      jdbc:mysql://localhost:3306/javaweb
 *   - 用户名:   root
 *   - 密码:     123456
 *   - 驱动:     com.mysql.cj.jdbc.Driver
 *
 * 连接池配置：
 *   - 最大连接数:  5
 *   - 最小空闲:    1
 *   - 空闲超时:    5 分钟
 *   - 连接超时:    10 秒
 * =============================================================================
 */
public class DBManager {

    /** HikariCP 连接池单例 */
    private static HikariDataSource dataSource;

    static {
        initDataSource();
    }

    /**
     * 初始化 HikariCP 连接池
     */
    private static void initDataSource() {
        Properties props = new Properties();
        try (InputStream input = DBManager.class.getClassLoader().getResourceAsStream("jdbc.properties")) {
            if (input == null) {
                System.err.println("[DBManager] 警告: 无法找到 jdbc.properties，使用默认配置");
                setDefaultConfig(props);
            } else {
                props.load(input);
                System.out.println("[DBManager] 配置文件加载成功");
            }

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(props.getProperty("jdbc.url", "jdbc:mysql://localhost:3306/javaweb?useSSL=false&serverTimezone=UTC"));
            config.setUsername(props.getProperty("jdbc.username", "root"));
            config.setPassword(props.getProperty("jdbc.password", "123456"));
            config.setDriverClassName(props.getProperty("jdbc.driver", "com.mysql.cj.jdbc.Driver"));

            // 连接池优化配置
            config.setMaximumPoolSize(Integer.parseInt(props.getProperty("pool.maxSize", "10")));
            config.setMinimumIdle(Integer.parseInt(props.getProperty("pool.minIdle", "2")));
            config.setIdleTimeout(Long.parseLong(props.getProperty("pool.idleTimeout", "300000")));
            config.setConnectionTimeout(Long.parseLong(props.getProperty("pool.connectionTimeout", "10000")));
            config.setMaxLifetime(Long.parseLong(props.getProperty("pool.maxLifetime", "1200000")));
            config.setPoolName("BoyaHikariPool");
            config.setConnectionTestQuery("SELECT 1");

            dataSource = new HikariDataSource(config);
            System.out.println("[DBManager] HikariCP 连接池初始化成功");

        } catch (Exception e) {
            System.err.println("[DBManager] 连接池初始化失败：" + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 设置默认配置（配置文件不存在时使用）
     */
    private static void setDefaultConfig(Properties props) {
        props.setProperty("jdbc.url", "jdbc:mysql://localhost:3306/javaweb?useSSL=false&serverTimezone=UTC");
        props.setProperty("jdbc.username", "root");
        props.setProperty("jdbc.password", "123456");
        props.setProperty("jdbc.driver", "com.mysql.cj.jdbc.Driver");
        props.setProperty("pool.maxSize", "10");
        props.setProperty("pool.minIdle", "2");
        props.setProperty("pool.idleTimeout", "300000");
        props.setProperty("pool.connectionTimeout", "10000");
        props.setProperty("pool.maxLifetime", "1200000");
    }

    /**
     * 从连接池获取数据库连接
     *
     * @return Connection 数据库连接对象
     * @throws SQLException 获取连接失败时抛出
     */
    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            initDataSource();
        }
        return dataSource.getConnection();
    }

    /**
     * 关闭数据库连接（归还到连接池，并非真正关闭）
     *
     * @param connection 要关闭的连接对象
     */
    public static void close(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * 关闭连接池（应用关闭时调用）
     */
    public static void shutdown() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            System.out.println("[DBManager] HikariCP 连接池已关闭");
        }
    }
}
