/**
 * ===========================================================================
 * Book —— 业务逻辑类
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.pojo
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * getId()                            查询操作
 * setId(long id)                     更新操作
 * getBookTitle()                     查询操作
 * setBookTitle(String bookTitle)     更新操作
 * getBookAuthor()                    查询操作
 * setBookAuthor(String bookAuthor)   更新操作
 * getBookSummary()                   查询操作
 * setBookSummary(String bookSummary) 更新操作
 * getTypeId()                        查询操作
 * setTypeId(String typeId)           更新操作
 * getBookType()                      查询操作
 * setBookType(BookType bookType)     更新操作
 * getTypeName()                      查询操作
 * getParentTypeId()                  查询操作
 * getDownloadTimes()                 查询操作
 * setDownloadTimes(long downloadTimes)更新操作
 * setBookPubYear(java.sql.Date bookPubYear)更新操作
 * getBookFile()                      查询操作
 * setBookFile(String bookFile)       更新操作
 * getBookCover()                     查询操作
 * setBookCover(String bookCover)     更新操作
 * getBookFormat()                    查询操作
 * setBookFormat(String bookFormat)   更新操作
 * toString()                         对象字符串表示
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   标准 Java 语法 + JDK 内置 API
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

/**
 * Book 图书实体类
 * 用于存储图书的相关信息，对应数据库中的 book 表
 * 
 * 字段说明：
 * - id           : 图书ID（主键）
 * - bookTitle    : 图书标题/书名
 * - bookAuthor   : 图书作者
 * - bookSummary  : 图书简介/摘要
 * - typeId       : 图书分类ID
 * - downloadTimes: 下载次数
 * - bookPubYear  : 出版年份
 * - bookFile     : 图书文件路径
 * - bookCover    : 图书封面图片路径
 * - bookFormat   : 图书格式（如PDF、EPUB等）
 */
public class Book {

  // ==================== 私有属性（对应数据库字段） ====================
  
  private long id;                      // 图书唯一标识ID
  private String bookTitle;              // 图书标题（书名）
  private String bookAuthor;             // 图书作者
  private String bookSummary;            // 图书简介/内容摘要
  private String typeId;                   // 图书分类ID（关联分类表，VARCHAR类型）
  private BookType bookType;             // 图书分类对象（关联查询时使用）
  private long downloadTimes;            // 下载次数统计
  private java.sql.Date bookPubYear;      // 出版年份（日期类型）
  private String bookFile;               // 图书文件存放路径
  private String bookCover;              // 图书封面图片路径
  private String bookFormat;             // 图书格式（PDF/EPUB/MOBI等）


  public long getId() {
    return id;
  }

  public void setId(long id) {
    this.id = id;
  }


  public String getBookTitle() {
    return bookTitle;
  }

  public void setBookTitle(String bookTitle) {
    this.bookTitle = bookTitle;
  }


  public String getBookAuthor() {
    return bookAuthor;
  }

  public void setBookAuthor(String bookAuthor) {
    this.bookAuthor = bookAuthor;
  }


  public String getBookSummary() {
    return bookSummary;
  }

  public void setBookSummary(String bookSummary) {
    this.bookSummary = bookSummary;
  }


  public String getTypeId() {
    return typeId;
  }

  public void setTypeId(String typeId) {
    this.typeId = typeId;
  }

  public BookType getBookType() {
    return bookType;
  }

  public void setBookType(BookType bookType) {
    this.bookType = bookType;
  }

  /**
   * 获取分类名称（便捷方法）
   */
  public String getTypeName() {
    if (bookType != null) {
      return bookType.getbTypeName();
    }
    return "";
  }

  /**
   * 获取父分类ID（便捷方法）
   */
  public String getParentTypeId() {
    if (bookType != null) {
      return bookType.getbTPerentId();
    }
    return "";
  }


  public long getDownloadTimes() {
    return downloadTimes;
  }

  public void setDownloadTimes(long downloadTimes) {
    this.downloadTimes = downloadTimes;
  }


  public java.sql.Date getBookPubYear() {
    return bookPubYear;
  }

  public void setBookPubYear(java.sql.Date bookPubYear) {
    this.bookPubYear = bookPubYear;
  }


  public String getBookFile() {
    return bookFile;
  }

  public void setBookFile(String bookFile) {
    this.bookFile = bookFile;
  }


  public String getBookCover() {
    return bookCover;
  }

  public void setBookCover(String bookCover) {
    this.bookCover = bookCover;
  }


  public String getBookFormat() {
    return bookFormat;
  }

  public void setBookFormat(String bookFormat) {
    this.bookFormat = bookFormat;
  }

  @Override
  public String toString() {
    return "Book{" +
            "id=" + id +
            ", bookTitle='" + bookTitle + '\'' +
            ", bookAuthor='" + bookAuthor + '\'' +
            ", bookSummary='" + bookSummary + '\'' +
            ", typeId=" + typeId +
            ", bookType=" + bookType +
            ", downloadTimes=" + downloadTimes +
            ", bookPubYear=" + bookPubYear +
            ", bookFile='" + bookFile + '\'' +
            ", bookCover='" + bookCover + '\'' +
            ", bookFormat='" + bookFormat + '\'' +
            '}';
  }
}
