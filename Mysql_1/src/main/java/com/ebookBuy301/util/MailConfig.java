/**
 * ===========================================================================
 * MailConfig —— 业务逻辑类
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.util
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * loadConfig()                       初始化
 * reload()                           内部工具方法
 * getSmtpHost()                      查询操作
 * getSmtpPort()                      查询操作
 * getUsername()                      查询操作
 * getPassword()                      查询操作
 * isAuthEnabled()                    内部工具方法
 * isDebugEnabled()                   内部工具方法
 * isConfigured()                     内部工具方法
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   props = new Properties()
 *   is = MailConfig.class.getClassLoader().getResourceAsStream("mail.properties")
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   标准 Java 语法 + JDK 内置 API
 *
 * ===========================================================================
 */

package com.ebookBuy301.util;

import java.io.InputStream;
import java.util.Properties;

/**
 * =============================================================================
 * MailConfig —— 邮件配置类
 * =============================================================================
 *
 * 从 classpath 下的 mail.properties 配置文件读取邮件服务器配置。
 * 若配置文件不存在，则使用默认值（QQ邮箱 SMTP）。
 *
 * 配置项：
 *   - mail.smtp.host      SMTP 服务器地址（默认 smtp.qq.com）
 *   - mail.smtp.port      SMTP 端口（默认 587）
 *   - mail.username       邮箱用户名
 *   - mail.password       邮箱密码/授权码
 *   - mail.smtp.auth     是否启用认证（默认 true）
 *   - mail.debug         是否启用调试（默认 false）
 * =============================================================================
 */
public class MailConfig {
    private static final Properties props = new Properties();

    private static String smtpHost;
    private static int smtpPort;
    private static String username;
    private static String password;
    private static boolean authEnabled;
    private static boolean debugEnabled;

    static {
        loadConfig();
    }

    /**
     * 从 classpath 下的 mail.properties 加载邮件配置。
     * <p>
     * 算法流程：
     *   ① 通过 {@code ClassLoader.getResourceAsStream("mail.properties")} 加载流
     *   ② 若流为空（配置文件缺失）→ 使用默认配置（QQ 邮箱 SMTP/587/空账号）
     *   ③ 否则按 key 读取并设置 smtpHost / smtpPort / username / password
     *   ④ 解析认证与调试开关（mail.smtp.auth / mail.debug）
     *   ⑤ 捕获并打印 IO 异常，避免加载阶段崩溃容器
     * <p>
     * 配置项及默认值：
     * <ul>
     *   <li>mail.smtp.host  → smtp.qq.com</li>
     *   <li>mail.smtp.port  → 587</li>
     *   <li>mail.username   → ""</li>
     *   <li>mail.password   → ""</li>
     *   <li>mail.smtp.auth  → true</li>
     *   <li>mail.debug      → false</li>
     * </ul>
     */
    private static void loadConfig() {
        try {
            InputStream is = MailConfig.class.getClassLoader().getResourceAsStream("mail.properties");
            if (is != null) {
                props.load(is);
                is.close();

                smtpHost = props.getProperty("mail.smtp.host", "smtp.qq.com");
                smtpPort = Integer.parseInt(props.getProperty("mail.smtp.port", "587"));
                username = props.getProperty("mail.username", "");
                password = props.getProperty("mail.password", "");
                authEnabled = Boolean.parseBoolean(props.getProperty("mail.smtp.auth", "true"));
                debugEnabled = Boolean.parseBoolean(props.getProperty("mail.debug", "false"));
            } else {
                // 使用默认配置
                smtpHost = "smtp.qq.com";
                smtpPort = 587;
                username = "";
                password = "";
                authEnabled = true;
                debugEnabled = false;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 重新加载配置文件（运行时热更新）。
     * <p>
     * 用于在管理员修改 mail.properties 后无需重启 Web 容器即可生效。
     * 内部直接复用 {@link #loadConfig()} 的加载逻辑。
     */
    public static void reload() {
        loadConfig();
    }

    public static String getSmtpHost() { return smtpHost; }
    public static int getSmtpPort() { return smtpPort; }
    public static String getUsername() { return username; }
    public static String getPassword() { return password; }
    public static boolean isAuthEnabled() { return authEnabled; }
    public static boolean isDebugEnabled() { return debugEnabled; }

    /**
     * 检查邮件配置是否完整（用户名与密码均已设置）。
     * <p>
     * 算法：username 非 null 且非空 ∧ password 非 null 且非空。
     * 供 {@link MailService} 发送前判断是否需要跳过。
     *
     * @return true 表示配置完整可发送邮件
     */
    public static boolean isConfigured() {
        return username != null && !username.isEmpty()
            && password != null && !password.isEmpty();
    }
}
