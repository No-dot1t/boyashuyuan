/**
 * ===========================================================================
 * Users —— 用户信息实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   users
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列           说明
 * ----------------------------------------------------------------------
 * id            String          id              用户唯一标识ID(UUID生成)
 * username      String          username        用户名(登录账号)
 * password      String          password        登录密码
 * sex           String          sex             性别(男/女/未知)
 * age           long            age             年龄
 * email         String          email           电子邮箱
 * role          String          role            用户角色(admin=管理员/user=普通用户)
 * avatar        String          avatar          头像路径
 * nickname      String          nickname        昵称
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + isAdmin() 判断方法 + toString()
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

public class Users {

  // ==================== 私有属性（对应数据库字段） ====================
  
  private String id;          // 用户唯一标识ID（UUID生成）
  private String username;    // 用户名（用于登录）
  private String password;    // 登录密码
  private String sex;          // 性别（男/女/未知）
  private long age;            // 年龄
  private String email;        // 电子邮箱地址
  private String role;         // 用户角色：admin(管理员) / user(普通用户)
  private String avatar;       // 头像路径
  private String nickname;     // 昵称


  public String getId() {
    return id;
  }

  public void setId(String id) {
    this.id = id;
  }


  public String getUsername() {
    return username;
  }

  public void setUsername(String username) {
    this.username = username;
  }


  public String getPassword() {
    return password;
  }

  public void setPassword(String password) {
    this.password = password;
  }


  public String getSex() {
    return sex;
  }

  public void setSex(String sex) {
    this.sex = sex;
  }


  public long getAge() {
    return age;
  }

  public void setAge(long age) {
    this.age = age;
  }


  public String getEmail() {
    return email;
  }

  public void setEmail(String email) {
    this.email = email;
  }

  public String getRole() {
    return role;
  }

  public void setRole(String role) {
    this.role = role;
  }

  public String getAvatar() {
    return avatar;
  }

  public void setAvatar(String avatar) {
    this.avatar = avatar;
  }

  public String getNickname() {
    return nickname;
  }

  public void setNickname(String nickname) {
    this.nickname = nickname;
  }

  // 判断是否为管理员
  public boolean isAdmin() {
    return "admin".equals(role);
  }

  public Users() {
  }

  public Users(String id, String username, String password, String sex, long age, String email) {
    this.id = id;
    this.username = username;
    this.password = password;
    this.sex = sex;
    this.age = age;
    this.email = email;
    this.role = "user"; // 默认普通用户
  }

  public Users(String id, String username, String password, String sex, long age, String email, String role) {
    this.id = id;
    this.username = username;
    this.password = password;
    this.sex = sex;
    this.age = age;
    this.email = email;
    this.role = role;
  }

  @Override
  public String toString() {
    return "Users{" +
            "id='" + id + '\'' +
            ", username='" + username + '\'' +
            ", password='" + password + '\'' +
            ", sex='" + sex + '\'' +
            ", age=" + age +
            ", email='" + email + '\'' +
            ", role='" + role + '\'' +
            ", avatar='" + avatar + '\'' +
            ", nickname='" + nickname + '\'' +
            '}';
  }
}
