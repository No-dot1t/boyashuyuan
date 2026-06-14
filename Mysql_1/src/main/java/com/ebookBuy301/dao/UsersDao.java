/**
 * ===========================================================================
 * UsersDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getAllUsers()                      查询操作
 * getUserById(String id)             查询操作
 * getUserByUsername(String username) 查询操作
 * addUser(Users user)                新增操作
 * updateUser(Users user)             更新操作
 * getUserByEmail(String email)       查询操作
 * updatePassword(String email, String newPassword)更新操作
 * deleteUser(String id)              删除操作
 * searchUsers(String username, String sex)查询操作
 * extractUser(ResultSet rs)          数据抽取
 * closeResources(ResultSet rs, PreparedStatement ps, Connection conn)资源释放
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   users = new ArrayList<Users>()
 *   connection = null
 *   preparedStatement = null
 *   rs = null
 *   user = null
 *   connection = null
 *   preparedStatement = null
 *   rs = null
 *   id = ?")
 *   user = null
 *   connection = null
 *   preparedStatement = null
 *   rs = null
 *   username = ?")
 *   connection = null
 *   preparedStatement = null
 *   connection = null
 *   preparedStatement = null
 *   username = ?, password=?, sex=?, age=?, email=?, role=?, avatar=?, nickname=? WHERE id=?")
 *   user = null
 *   connection = null
 *   preparedStatement = null
 *   rs = null
 *   email = ?")
 *   connection = null
 *   preparedStatement = null
 *   password = ? WHERE email=?")
 *   connection = null
 *   preparedStatement = null
 *   id = ?")
 *   users = new ArrayList<Users>()
 *   connection = null
 *   preparedStatement = null
 *   rs = null
 *   sql = "SELECT * FROM users WHERE 1=1"
 *   user = new Users()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   JDBC —— Connection / PreparedStatement / ResultSet 数据库访问
 *   try-catch-finally —— JDBC 资源统一释放模式
 *   ResultSet 行映射 —— 手动抽取字段 → POJO 对象
 *
 * ===========================================================================
 */

package com.ebookBuy301.dao;

import com.ebookBuy301.db.DBManager;
import com.ebookBuy301.pojo.Users;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

/**
 * =============================================================================
 * UsersDao —— 用户数据访问层
 * =============================================================================
 *
 * 负责 users 表的增删改查操作。
 *
 * 方法索引：
 * 1. getAllUsers() → 获取所有用户
 * 2. getUserById() → 根据 ID 查询
 * 3. getUserByUsername() → 根据用户名查询（登录用）
 * 4. addUser() → 添加用户
 * 5. updateUser() → 更新用户
 * 6. getUserByEmail() → 根据邮箱查询
 * 7. updatePassword() → 更新密码
 * 8. deleteUser() → 删除用户
 * 9. searchUsers() → 条件搜索
 * =============================================================================
 */
public class UsersDao {

    // ==================== 1. 获取所有用户 ====================

    /**
     * 获取所有用户记录。
     * <p>
     * 算法：SELECT * FROM users → 遍历 ResultSet → extractUser() 逐行提取
     *
     * @return ArrayList<Users> 用户列表
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<Users> getAllUsers() throws ClassNotFoundException {
        ArrayList<Users> users = new ArrayList<Users>();
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM users");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                users.add(extractUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    // ==================== 2. 根据 ID 查询 ====================

    /**
     * 根据用户ID查询单个用户记录。
     * <p>
     * 算法：PreparedStatement 参数化查询 → extractUser() 提取单行
     *
     * @param id 用户ID
     * @return Users 用户对象；未找到返回 null
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public Users getUserById(String id) throws ClassNotFoundException {
        Users user = null;
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE id=?")) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user = extractUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }

    // ==================== 3. 根据用户名查询 ====================

    /**
     * 根据用户名查询单个用户记录（登录用）。
     * <p>
     * 算法：PreparedStatement 参数化查询 → extractUser() 提取单行
     *
     * @param username 用户名
     * @return Users 用户对象；未找到返回 null
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public Users getUserByUsername(String username) throws ClassNotFoundException {
        Users user = null;
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE username=?")) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user = extractUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }

    // ==================== 4. 添加用户 ====================

    /**
     * 添加新用户记录。
     * <p>
     * 算法：INSERT INTO users → PreparedStatement 设置9个字段 → executeUpdate()
     *
     * @param user 待添加的Users对象（id为必填）
     * @return int 受影响行数（1=成功，0=失败）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public int addUser(Users user) throws ClassNotFoundException {
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO users(id, username, password, sex, age, email, role, avatar, nickname) "
                            + "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)")) {
            ps.setString(1, user.getId());
            ps.setString(2, user.getUsername());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getSex());
            ps.setLong(5, user.getAge());
            ps.setString(6, user.getEmail());
            ps.setString(7, user.getRole() != null ? user.getRole() : "user");
            ps.setString(8, user.getAvatar() != null && !user.getAvatar().isEmpty() ? user.getAvatar() : "/avatars/1.png");
            ps.setString(9, user.getNickname() != null ? user.getNickname() : "");
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ==================== 5. 更新用户（全字段） ====================

    /**
     * 更新已有用户记录（全字段覆盖，含密码）。
     * <p>
     * 算法：UPDATE users SET 9个字段 → PreparedStatement 设置字段+WHERE条件 → executeUpdate()
     *
     * @param user 待更新的Users对象（id为必填定位条件）
     * @return int 受影响行数（1=成功，0=失败）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public int updateUser(Users user) throws ClassNotFoundException {
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                    "UPDATE users SET username=?, password=?, sex=?, age=?, email=?, role=?, avatar=?, nickname=? WHERE id=?")) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getSex());
            ps.setLong(4, user.getAge());
            ps.setString(5, user.getEmail());
            ps.setString(6, user.getRole() != null ? user.getRole() : "user");
            ps.setString(7, user.getAvatar() != null && !user.getAvatar().isEmpty() ? user.getAvatar() : "/avatars/1.png");
            ps.setString(8, user.getNickname() != null ? user.getNickname() : "");
            ps.setString(9, user.getId());
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ==================== 5.1 更新用户资料（不动密码/用户名/年龄/角色） ====================

    /**
     * 更新用户基本资料（仅 sex/email/avatar/nickname，不改密码/用户名/年龄/角色）。
     * <p>
     * 算法：UPDATE users SET 4个字段 → PreparedStatement 设置字段+WHERE条件 → executeUpdate()
     *
     * @param user 待更新的Users对象（id为必填定位条件）
     * @return int 受影响行数（1=成功，0=失败）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public int updateProfile(Users user) throws ClassNotFoundException {
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                    "UPDATE users SET sex=?, email=?, avatar=?, nickname=? WHERE id=?")) {
            ps.setString(1, user.getSex() != null ? user.getSex() : "");
            ps.setString(2, user.getEmail() != null ? user.getEmail() : "");
            ps.setString(3, user.getAvatar() != null && !user.getAvatar().isEmpty() ? user.getAvatar() : "/avatars/1.png");
            ps.setString(4, user.getNickname() != null ? user.getNickname() : "");
            ps.setString(5, user.getId());
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ==================== 6. 根据邮箱查询 ====================

    /**
     * 根据邮箱查询单个用户记录（用于找回密码等场景）。
     * <p>
     * 算法：PreparedStatement 参数化查询 → extractUser() 提取单行
     *
     * @param email 用户邮箱
     * @return Users 用户对象；未找到返回 null
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public Users getUserByEmail(String email) throws ClassNotFoundException {
        Users user = null;
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE email=?")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user = extractUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }

    // ==================== 7. 更新密码（按邮箱）====================

    /**
     * 根据邮箱更新用户密码。
     * <p>
     * 算法：UPDATE users SET password=? WHERE email=? → PreparedStatement 设置参数 → executeUpdate()
     *
     * @param email        用户邮箱（定位条件）
     * @param newPassword 新密码（明文或加密后）
     * @return int 受影响行数（1=成功，0=失败）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public int updatePassword(String email, String newPassword) throws ClassNotFoundException {
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE users SET password=? WHERE email=?")) {
            ps.setString(1, newPassword);
            ps.setString(2, email);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ==================== 7.1 更新密码（按用户名）====================

    /**
     * 根据用户名更新用户密码。
     * <p>
     * 算法：UPDATE users SET password=? WHERE username=? → PreparedStatement 设置参数 → executeUpdate()
     *
     * @param username     用户名（定位条件）
     * @param newPassword 新密码（明文或加密后）
     * @return int 受影响行数（1=成功，0=失败）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public int updatePasswordByUsername(String username, String newPassword) throws ClassNotFoundException {
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE users SET password=? WHERE username=?")) {
            ps.setString(1, newPassword);
            ps.setString(2, username);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ==================== 8. 删除用户 ====================

    /**
     * 根据用户ID删除用户记录。
     * <p>
     * 算法：DELETE FROM users WHERE id=? → PreparedStatement 设置参数 → executeUpdate()
     *
     * @param id 待删除的用户ID
     * @return int 受影响行数（1=成功，0=失败）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public int deleteUser(String id) throws ClassNotFoundException {
        try (Connection conn = DBManager.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE id=?")) {
            ps.setString(1, id);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ==================== 9. 条件搜索 ====================

    /**
     * 按用户名（模糊）和/或性别（精确）条件搜索用户。
     * <p>
     * 算法：动态拼接 SQL WHERE 条件 → PreparedStatement 设置参数 → 遍历 ResultSet → extractUser() 逐行提取
     *
     * @param username 用户名关键词（可为null/空，表示不限）
     * @param sex      性别（可为null/空，表示不限）
     * @return ArrayList<Users> 匹配的用户列表
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<Users> searchUsers(String username, String sex) throws ClassNotFoundException {
        ArrayList<Users> users = new ArrayList<Users>();
        try {
            StringBuilder sql = new StringBuilder("SELECT * FROM users WHERE 1=1");
            ArrayList<Object> params = new ArrayList<>();

            if (username != null && !username.trim().isEmpty()) {
                sql.append(" AND username LIKE ?");
                params.add("%" + username.trim() + "%");
            }
            if (sex != null && !sex.trim().isEmpty()) {
                sql.append(" AND sex = ?");
                params.add(sex.trim());
            }

            try (Connection conn = DBManager.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        users.add(extractUser(rs));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    // ==================== 通用工具方法 ====================

    // ════════════════════════════════════════════════════════════════════
    //  从 ResultSet 提取 Users 对象
    //   步骤：rs.getString("id") → new Users() → setXxx()
    // ════════════════════════════════════════════════════════════════════
    private Users extractUser(ResultSet rs) throws SQLException {
        Users user = new Users();
        user.setId(rs.getString("id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setSex(rs.getString("sex"));
        user.setAge(rs.getLong("age"));
        user.setEmail(rs.getString("email"));
        user.setRole(rs.getString("role") != null ? rs.getString("role") : "user");
        user.setAvatar(rs.getString("avatar") != null && !rs.getString("avatar").isEmpty() ? rs.getString("avatar") : "/avatars/1.png");
        user.setNickname(rs.getString("nickname") != null ? rs.getString("nickname") : "");
        return user;
    }

    // ==================== 获取用户总数 ====================

    /**
     * 获取用户表的总记录数。
     * <p>
     * 算法：SELECT COUNT(*) FROM users → 取结果集第1列
     *
     * @return int 用户总数；异常时返回 0
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public int getUserCount() throws ClassNotFoundException {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection conn = DBManager.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[UsersDao] getUserCount SQL错误：" + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    // ==================== 通用工具方法 ====================

    // ════════════════════════════════════════════════════════════════════
    //  统一释放 JDBC 资源（ResultSet / PreparedStatement / Connection）
    //   步骤：非空判断 → close() → 捕获 SQLException
    // ════════════════════════════════════════════════════════════════════
    private void closeResources(ResultSet rs, PreparedStatement ps, Connection conn) {
        try {
            if (rs != null)
                rs.close();
            if (ps != null)
                ps.close();
            if (conn != null)
                DBManager.close(conn);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
