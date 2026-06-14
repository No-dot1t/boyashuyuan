/**
 * ===========================================================================
 * MailService —— 业务逻辑类
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.util
 * 注解      @link, @param, @param, @param, @return
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * sendVerificationCode(String to, String code, int expireMinutes)内部工具方法
 * getPasswordAuthentication()        查询操作
 * buildEmailContent(String code, int expireMinutes)内部工具方法
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   props = new Properties()
 *   authenticator = new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(MailConfig.getUsername(), MailConfig.getPassword())
 *   session = Session.getInstance(props, authenticator)
 *   message = new MimeMessage(session)
 *   content = buildEmailContent(code, expireMinutes)
 *   charset = "UTF-8">
                <style>
                    body { font-family: 'Microsoft YaHei', Arial, sans-serif
 *   class = "container">
                    <div class="header"><h1>ebookBuy 书城</h1></div>
                    <p style="color: #333
 *   style = "color: #333
 *   class = "code-box"><div class="code">%s</div></div>
                    <div class="tips">
                        <p>提示：</p>
                        <ul>
                            <li>验证码有效期为 %d 分钟</li>
                            <li>请勿将验证码透露给他人</li>
                            <li>如果是您本人操作，请忽略此邮件</li>
                        </ul>
                    </div>
                    <p class="warning">注意：如您未发起找回密码请求，请忽略此邮件，您的账号安全不会受到影响。</p>
                    <div class="footer">
                        <p>此邮件由系统自动发送，请勿回复。</p>
                        <p>ebookBuy 书城 - 让阅读成为一种习惯</p>
                    </div>
                </div>
            </body>
            </html>
            """.formatted(code, expireMinutes)
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   标准 Java 语法 + JDK 内置 API
 *
 * ===========================================================================
 */

package com.ebookBuy301.util;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;

/**
 * =============================================================================
 * MailService —— 邮件发送服务类
 * =============================================================================
 *
 * 使用 JavaMail 库发送邮件，目前支持发送找回密码验证码。
 * 邮件服务器配置由 {@link MailConfig} 提供。
 *
 * 工作流程：
 *   1. 检查邮件配置是否完整
 *   2. 构建邮件会话（含认证）
 *   3. 创建 HTML 格式的验证码邮件
 *   4. 通过 Transport 发送
 * =============================================================================
 */
public class MailService {

    /**
     * 发送验证码邮件
     *
     * @param to            收件人邮箱
     * @param code          验证码
     * @param expireMinutes 有效期（分钟）
     * @return 发送结果消息
     */
    public static String sendVerificationCode(String to, String code, int expireMinutes) {
        if (!MailConfig.isConfigured()) {
            return "邮件服务未配置，请联系管理员";
        }

        // ===== 1. 配置邮件属性 =====
        Properties props = new Properties();
        props.put("mail.smtp.host", MailConfig.getSmtpHost());
        props.put("mail.smtp.port", MailConfig.getSmtpPort());
        props.put("mail.smtp.auth", MailConfig.isAuthEnabled() ? "true" : "false");
        props.put("mail.smtp.starttls.enable", "true");

        // ===== 2. 创建认证器 =====
        Authenticator authenticator = new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(MailConfig.getUsername(), MailConfig.getPassword());
            }
        };

        // ===== 3. 创建邮件会话 =====
        Session session = Session.getInstance(props, authenticator);
        session.setDebug(MailConfig.isDebugEnabled());

        try {
            // ===== 4. 创建邮件消息 =====
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(MailConfig.getUsername(), "ebookBuy书城"));
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(to));
            message.setSubject("【ebookBuy书城】找回密码验证码");

            // ===== 5. 设置 HTML 内容 =====
            String content = buildEmailContent(code, expireMinutes);
            message.setContent(content, "text/html;charset=UTF-8");

            // ===== 6. 发送邮件 =====
            Transport.send(message);
            System.out.println("【邮件发送】验证码已发送至: " + to);
            return "验证码已发送至您的邮箱";

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("【邮件发送失败】至: " + to + ", 错误: " + e.getMessage());
            return "邮件发送失败，请稍后重试";
        }
    }

    /**
     * 发送通用通知邮件
     *
     * @param to      收件人邮箱
     * @param subject 邮件标题
     * @param content 邮件内容（支持HTML）
     * @return 发送结果消息
     */
    public static String sendNotificationEmail(String to, String subject, String content) {
        if (!MailConfig.isConfigured()) {
            return "邮件服务未配置";
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", MailConfig.getSmtpHost());
        props.put("mail.smtp.port", MailConfig.getSmtpPort());
        props.put("mail.smtp.auth", MailConfig.isAuthEnabled() ? "true" : "false");
        props.put("mail.smtp.starttls.enable", "true");

        Authenticator authenticator = new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(MailConfig.getUsername(), MailConfig.getPassword());
            }
        };

        Session session = Session.getInstance(props, authenticator);
        session.setDebug(MailConfig.isDebugEnabled());

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(MailConfig.getUsername(), "博雅书院"));
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(to));
            message.setSubject(subject);
            message.setContent(content, "text/html;charset=UTF-8");

            Transport.send(message);
            System.out.println("【邮件发送】通知已发送至: " + to);
            return "邮件发送成功";

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("【邮件发送失败】至: " + to + ", 错误: " + e.getMessage());
            return "邮件发送失败: " + e.getMessage();
        }
    }

    /** 构建通知邮件的 HTML 内容 */
    public static String buildNotificationContent(String title, String content) {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: 'Microsoft YaHei', Arial, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px; }
                    .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 12px; padding: 35px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
                    .header { background: linear-gradient(135deg, #4A90D9 0%, #6E7BD4 100%); border-radius: 8px; padding: 20px; text-align: center; margin-bottom: 25px; }
                    .header h1 { color: white; margin: 0; font-size: 20px; }
                    .title { color: #2c3e50; font-size: 18px; font-weight: bold; margin-bottom: 15px; }
                    .content { color: #555; font-size: 15px; line-height: 1.8; }
                    .footer { text-align: center; margin-top: 30px; color: #999; font-size: 13px; border-top: 1px solid #eee; padding-top: 20px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header"><h1>📚 博雅书院</h1></div>
                    <div class="title">%s</div>
                    <div class="content">%s</div>
                    <div class="footer">
                        <p>此邮件由系统自动发送，请勿回复。</p>
                        <p>博雅书院 - 让阅读成为一种习惯</p>
                    </div>
                </div>
            </body>
            </html>
            """.formatted(title, content);
    }

    /** 构建验证码邮件的 HTML 内容 */
    private static String buildEmailContent(String code, int expireMinutes) {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: 'Microsoft YaHei', Arial, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px; }
                    .container { max-width: 500px; margin: 0 auto; background: white; border-radius: 10px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
                    .header { text-align: center; margin-bottom: 30px; }
                    .header h1 { color: #4A90D9; margin: 0; font-size: 24px; }
                    .code-box { background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); border-radius: 8px; padding: 25px; text-align: center; margin: 20px 0; }
                    .code { font-size: 36px; font-weight: bold; color: white; letter-spacing: 8px; }
                    .tips { color: #666; font-size: 14px; line-height: 1.8; }
                    .warning { color: #e74c3c; font-size: 12px; }
                    .footer { text-align: center; margin-top: 20px; color: #999; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header"><h1>ebookBuy 书城</h1></div>
                    <p style="color: #333;">您好，</p>
                    <p style="color: #333;">您申请了找回密码服务，请在 15 分钟内输入以下验证码完成验证：</p>
                    <div class="code-box"><div class="code">%s</div></div>
                    <div class="tips">
                        <p>提示：</p>
                        <ul>
                            <li>验证码有效期为 %d 分钟</li>
                            <li>请勿将验证码透露给他人</li>
                            <li>如果是您本人操作，请忽略此邮件</li>
                        </ul>
                    </div>
                    <p class="warning">注意：如您未发起找回密码请求，请忽略此邮件，您的账号安全不会受到影响。</p>
                    <div class="footer">
                        <p>此邮件由系统自动发送，请勿回复。</p>
                        <p>ebookBuy 书城 - 让阅读成为一种习惯</p>
                    </div>
                </div>
            </body>
            </html>
            """.formatted(code, expireMinutes);
    }
}
