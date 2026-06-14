/**
 * ===========================================================================
 * SmsService —— 短信发送服务（模拟实现）
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.util
 * 底层技术    java.util.Random（验证码生成）+ System.out（模拟发送日志）
 * 最后更新   2026-06-13
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 【发送】
 *   sendVerificationCode(phone, code)    → 发送验证码短信（控制台输出 + 掩码手机号）
 *   sendNotificationSms(phone, content)  → 发送通知短信（自动截断至 70 字符）
 *
 * 【验证码生成】
 *   generateCode()                        → 生成 6 位数字验证码（Random.nextInt + String.format）
 *   generateCode4()                       → 生成 4 位数字验证码
 *
 * 【工具（private）】
 *   maskPhone(phone)                      → 手机号脱敏（138****1234）
 *
 * ── 使用的关键 API ──────────────────────────────────────────────────────────
 *
 *   技术                      用途
 * ───────────────────────────────────────────────────────────────
 *   Random.nextInt(bound)    随机数生成（验证码）
 *   String.format("%06d", n)  零填充格式化
 *   String.substring()       手机号掩码截取
 *
 * ── 说明 ────────────────────────────────────────────────────────────────────
 *   本类为短信服务的模拟实现，实际生产环境中应替换为阿里云短信 / 腾讯云短信等
 *   第三方服务 SDK。当前版本将短信内容输出到控制台，方便开发调试。
 *
 * ===========================================================================
 */
package com.ebookBuy301.util;

import java.util.Random;

public class SmsService {

    /**
     * 发送短信验证码
     *
     * @param phone 手机号码
     * @param code  验证码
     * @return 发送结果
     */
    public static String sendVerificationCode(String phone, String code) {
        System.out.println("【短信发送】验证码 " + code + " 已发送至: " + maskPhone(phone));
        return "验证码已发送至手机: " + maskPhone(phone);
    }

    /**
     * 发送通知短信
     *
     * @param phone   手机号码
     * @param content 短信内容
     * @return 发送结果
     */
    public static String sendNotificationSms(String phone, String content) {
        // 限制短信内容长度（通常短信最大70字符）
        if (content.length() > 70) {
            content = content.substring(0, 67) + "...";
        }
        System.out.println("【短信发送】通知已发送至: " + maskPhone(phone) + ", 内容: " + content);
        return "短信已发送至: " + maskPhone(phone);
    }

    /**
     * 生成6位数字验证码
     *
     * @return 6位验证码
     */
    public static String generateCode() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(1000000));
    }

    /**
     * 生成4位数字验证码
     *
     * @return 4位验证码
     */
    public static String generateCode4() {
        Random random = new Random();
        return String.format("%04d", random.nextInt(10000));
    }

    /**
     * 掩码处理手机号（中间4位用*代替）
     *
     * @param phone 手机号
     * @return 掩码后的手机号
     */
    private static String maskPhone(String phone) {
        if (phone == null || phone.length() != 11) {
            return phone;
        }
        return phone.substring(0, 3) + "****" + phone.substring(7);
    }
}