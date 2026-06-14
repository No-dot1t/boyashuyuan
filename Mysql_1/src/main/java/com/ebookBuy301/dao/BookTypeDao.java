/**
 * ===========================================================================
 * BookTypeDao —— 数据访问层
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.dao
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getAllTypes()                      查询操作
 * getTopLevelTypes()                 查询操作
 * getChildTypes(String parentId)     查询操作
 * searchTypesByName(String name)     查询操作
 * getTypeById(String id)             查询操作
 * addType(BookType bookType)         新增操作
 * updateType(BookType bookType)      更新操作
 * deleteType(String id)              删除操作
 * extractBookType(ResultSet rs)      数据抽取
 * extractBookTypeWithParent(ResultSet rs)数据抽取
 * closeResources(ResultSet rs, PreparedStatement ps, Connection conn)资源释放
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   types = new ArrayList<BookType>()
 *   connection = null
 *   preparedStatement = null
 *   rs = null
 *   sql = "SELECT t.*, p.bTypeName as parent_name FROM booktype t "
                       + "LEFT JOIN booktype p ON t.bTPerentId = p.bTid ORDER BY t.bTPerentId, t.bTid"
 *   types = new ArrayList<BookType>()
 *   connection = null
 *   preparedStatement = null
 *   rs = null
 *   sql = "SELECT * FROM booktype WHERE bTPerentId IS NULL OR bTPerentId = '' OR bTPerentId = '0' ORDER BY bTid"
 *   types = new ArrayList<BookType>()
 *   connection = null
 *   preparedStatement = null
 *   rs = null
 *   sql = "SELECT * FROM booktype WHERE bTPerentId = ? ORDER BY bTid"
 *   types = new ArrayList<BookType>()
 *   connection = null
 *   preparedStatement = null
 *   rs = null
 *   sql = "SELECT t.*, p.bTypeName as parent_name FROM booktype t "
                       + "LEFT JOIN booktype p ON t.bTPerentId = p.bTid "
                       + "WHERE t.bTypeName LIKE ? ORDER BY t.bTPerentId, t.bTid"
 *   type = null
 *   connection = null
 *   preparedStatement = null
 *   rs = null
 *   sql = "SELECT t.*, p.bTypeName as parent_name FROM booktype t "
                       + "LEFT JOIN booktype p ON t.bTPerentId = p.bTid WHERE t.bTid=?"
 *   connection = null
 *   preparedStatement = null
 *   parentId = bookType.getbTPerentId()
 *   connection = null
 *   preparedStatement = null
 *   bTypeName = ?, btText=?, bTPerentId=? WHERE bTid=?")
 *   parentId = bookType.getbTPerentId()
 *   connection = null
 *   preparedStatement = null
 *   bTid = ?")
 *   type = new BookType()
 *   type = extractBookType(rs)
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
import com.ebookBuy301.pojo.BookType;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

/**
 * =============================================================================
 * BookTypeDao —— 图书分类数据访问层
 * =============================================================================
 *
 * 负责 booktype 表的增删改查操作，支持多级树形分类管理。
 *
 * 方法索引：
 *   1. getAllTypes()          → 获取所有分类（含父分类名称）
 *   2. getTopLevelTypes()     → 获取顶级分类
 *   3. getChildTypes()        → 根据父ID获取子分类
 *   4. searchTypesByName()    → 按名称模糊搜索
 *   5. getTypeById()          → 根据ID查询
 *   6. addType()              → 添加分类
 *   7. updateType()           → 更新分类
 *   8. deleteType()           → 删除分类
 * =============================================================================
 */
public class BookTypeDao {

    // ==================== 1. 获取所有分类 ====================

    /**
     * 获取所有图书分类记录（含父分类名称）。
     * <p>
     * 算法：LEFT JOIN 自关联 → 遍历 ResultSet → extractBookTypeWithParent() 逐行提取
     *
     * @return ArrayList<BookType> 分类列表（按父ID、自身ID排序）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<BookType> getAllTypes() throws ClassNotFoundException {
        ArrayList<BookType> types = new ArrayList<BookType>();
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet rs = null;
        try {
            connection = DBManager.getConnection();
            String sql = "SELECT t.*, p.bTypeName as parent_name FROM booktype t "
                       + "LEFT JOIN booktype p ON t.bTPerentId = p.bTid ORDER BY t.bTPerentId, t.bTid";
            preparedStatement = connection.prepareStatement(sql);
            rs = preparedStatement.executeQuery();
            while (rs.next()) {
                types.add(extractBookTypeWithParent(rs));
            }
        } catch (SQLException e) {
            System.err.println("[BookTypeDao] SQL 错误：" + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, preparedStatement, connection);
        }
        return types;
    }

    // ==================== 2. 获取顶级分类 ====================

    /**
     * 获取所有顶级分类（父ID为空或为"0"的分类）。
     * <p>
     * 算法：筛选 bTPerentId IS NULL 或空 → 遍历 ResultSet → extractBookType() 逐行提取
     *
     * @return ArrayList<BookType> 顶级分类列表（按bTid排序）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<BookType> getTopLevelTypes() throws ClassNotFoundException {
        ArrayList<BookType> types = new ArrayList<BookType>();
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet rs = null;
        try {
            connection = DBManager.getConnection();
            String sql = "SELECT * FROM booktype WHERE bTPerentId IS NULL OR bTPerentId = '' OR bTPerentId = '0' ORDER BY bTid";
            preparedStatement = connection.prepareStatement(sql);
            rs = preparedStatement.executeQuery();
            while (rs.next()) {
                types.add(extractBookType(rs));
            }
        } catch (SQLException e) {
            System.err.println("[BookTypeDao] SQL 错误：" + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, preparedStatement, connection);
        }
        return types;
    }

    // ==================== 3. 根据父ID获取子分类 ====================

    /**
     * 根据父分类ID获取其子分类列表。
     * <p>
     * 算法：PreparedStatement 参数化查询 → 遍历 ResultSet → extractBookType() 逐行提取
     *
     * @param parentId 父分类ID
     * @return ArrayList<BookType> 子分类列表（按bTid排序）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<BookType> getChildTypes(String parentId) throws ClassNotFoundException {
        ArrayList<BookType> types = new ArrayList<BookType>();
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet rs = null;
        try {
            connection = DBManager.getConnection();
            String sql = "SELECT * FROM booktype WHERE bTPerentId = ? ORDER BY bTid";
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setString(1, parentId);
            rs = preparedStatement.executeQuery();
            while (rs.next()) {
                types.add(extractBookType(rs));
            }
        } catch (SQLException e) {
            System.err.println("[BookTypeDao] SQL 错误：" + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, preparedStatement, connection);
        }
        return types;
    }

    // ==================== 4. 按名称搜索 ====================

    /**
     * 按分类名称模糊搜索图书分类（含父分类名称）。
     * <p>
     * 算法：LEFT JOIN 自关联 + LIKE 模糊匹配 → 遍历 ResultSet → extractBookTypeWithParent() 逐行提取
     *
     * @param name 搜索关键词（自动包裹为 %name%）
     * @return ArrayList<BookType> 匹配的分类列表（按父ID、自身ID排序）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public ArrayList<BookType> searchTypesByName(String name) throws ClassNotFoundException {
        ArrayList<BookType> types = new ArrayList<BookType>();
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet rs = null;
        try {
            connection = DBManager.getConnection();
            String sql = "SELECT t.*, p.bTypeName as parent_name FROM booktype t "
                       + "LEFT JOIN booktype p ON t.bTPerentId = p.bTid "
                       + "WHERE t.bTypeName LIKE ? ORDER BY t.bTPerentId, t.bTid";
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setString(1, "%" + name + "%");
            rs = preparedStatement.executeQuery();
            while (rs.next()) {
                types.add(extractBookTypeWithParent(rs));
            }
        } catch (SQLException e) {
            System.err.println("[BookTypeDao] 搜索分类错误：" + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, preparedStatement, connection);
        }
        return types;
    }

    // ==================== 5. 根据ID查询 ====================

    /**
     * 根据分类ID查询单个分类记录（含父分类名称）。
     * <p>
     * 算法：PreparedStatement 参数化查询 → extractBookTypeWithParent() 提取单行
     *
     * @param id 分类ID
     * @return BookType 分类对象；未找到返回 null
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public BookType getTypeById(String id) throws ClassNotFoundException {
        BookType type = null;
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet rs = null;
        try {
            connection = DBManager.getConnection();
            String sql = "SELECT t.*, p.bTypeName as parent_name FROM booktype t "
                       + "LEFT JOIN booktype p ON t.bTPerentId = p.bTid WHERE t.bTid=?";
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setString(1, id);
            rs = preparedStatement.executeQuery();
            if (rs.next()) {
                type = extractBookTypeWithParent(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(rs, preparedStatement, connection);
        }
        return type;
    }

    // ==================== 6. 添加分类 ====================

    /**
     * 添加新图书分类记录。
     * <p>
     * 算法：INSERT INTO booktype → PreparedStatement 设置字段 → executeUpdate()
     *
     * @param bookType 待添加的BookType对象（bTid为必填）
     * @return int 受影响行数（1=成功，0=失败）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public int addType(BookType bookType) throws ClassNotFoundException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        try {
            connection = DBManager.getConnection();
            preparedStatement = connection.prepareStatement(
                "INSERT INTO booktype(bTid, bTypeName, btText, bTPerentId) VALUES(?,?,?,?)");
            preparedStatement.setString(1, bookType.getbTid());
            preparedStatement.setString(2, bookType.getbTypeName());
            preparedStatement.setString(3, bookType.getBtText());
            String parentId = bookType.getbTPerentId();
            if (parentId != null && parentId.trim().isEmpty()) {
                parentId = null;
            }
            preparedStatement.setString(4, parentId);
            return preparedStatement.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        } finally {
            closeResources(null, preparedStatement, connection);
        }
    }

    // ==================== 7. 更新分类 ====================

    /**
     * 更新已有图书分类记录。
     * <p>
     * 算法：UPDATE booktype SET 字段 → PreparedStatement 设置字段+WHERE条件 → executeUpdate()
     *
     * @param bookType 待更新的BookType对象（bTid为必填定位条件）
     * @return int 受影响行数（1=成功，0=失败）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public int updateType(BookType bookType) throws ClassNotFoundException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        try {
            connection = DBManager.getConnection();
            preparedStatement = connection.prepareStatement(
                "UPDATE booktype SET bTypeName=?, btText=?, bTPerentId=? WHERE bTid=?");
            preparedStatement.setString(1, bookType.getbTypeName());
            preparedStatement.setString(2, bookType.getBtText());
            String parentId = bookType.getbTPerentId();
            if (parentId != null && parentId.trim().isEmpty()) {
                parentId = null;
            }
            preparedStatement.setString(3, parentId);
            preparedStatement.setString(4, bookType.getbTid());
            return preparedStatement.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        } finally {
            closeResources(null, preparedStatement, connection);
        }
    }

    // ==================== 8. 删除分类 ====================

    /**
     * 根据分类ID删除图书分类记录。
     * <p>
     * 算法：DELETE FROM booktype WHERE bTid=? → PreparedStatement 设置参数 → executeUpdate()
     *
     * @param id 待删除的分类ID
     * @return int 受影响行数（1=成功，0=失败）
     * @throws ClassNotFoundException 数据库驱动未找到
     */
    public int deleteType(String id) throws ClassNotFoundException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        try {
            connection = DBManager.getConnection();
            preparedStatement = connection.prepareStatement("DELETE FROM booktype WHERE bTid=?");
            preparedStatement.setString(1, id);
            return preparedStatement.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        } finally {
            closeResources(null, preparedStatement, connection);
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    //  从 ResultSet 提取 BookType 对象（不含父分类名称）
    //   步骤：rs.getString("bTid") → new BookType() → setXxx()
    // ═════════════════════════════════════════════════════════════════════
    private BookType extractBookType(ResultSet rs) throws SQLException {
        BookType type = new BookType();
        type.setbTid(rs.getString("bTid"));
        type.setbTypeName(rs.getString("bTypeName"));
        type.setBtText(rs.getString("btText"));
        type.setbTPerentId(rs.getString("bTPerentId"));
        return type;
    }

    // ════════════════════════════════════════════════════════════════════
    //  从 ResultSet 提取 BookType 对象（含父分类名称）
    //   步骤：extractBookType(rs) → rs.getString("parent_name") → setParentName()
    // ════════════════════════════════════════════════════════════════════
    private BookType extractBookTypeWithParent(ResultSet rs) throws SQLException {
        BookType type = extractBookType(rs);
        type.setParentName(rs.getString("parent_name"));
        return type;
    }

    // ════════════════════════════════════════════════════════════════════
    //  统一释放 JDBC 资源（ResultSet / PreparedStatement / Connection）
    //   步骤：非空判断 → close() → 捕获 SQLException
    // ════════════════════════════════════════════════════════════════════
    private void closeResources(ResultSet rs, PreparedStatement ps, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) DBManager.close(conn);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
