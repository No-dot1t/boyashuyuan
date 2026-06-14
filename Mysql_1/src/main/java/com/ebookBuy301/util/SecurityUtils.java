package com.ebookBuy301.util;

import java.util.regex.Pattern;

/**
 * ===========================================================================
 * SecurityUtils —— 安全校验工具类
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.util
 * 底层技术    java.util.regex.Pattern（正则匹配）
 * 最后更新   2026-06-13
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 【SQL / XSS 攻击检测】
 *   containsSqlInjection(input)          → 检测 SQL 注入关键字
 *   containsXss(input)                   → 检测 XSS 脚本标签/伪协议
 *
 * 【格式校验】
 *   isValidEmail(email)                  → 邮箱格式校验（简化 RFC 5322）
 *   isValidPhone(phone)                  → 中国大陆手机号校验（13x-19x）
 *   isValidIdCard(idCard)                → 18 位居民身份证号校验
 *   isValidUsername(username)            → 用户名合法字符校验（3-20 位字母数字下划线）
 *   isValidPassword(password)            → 密码强度校验（≥8位，含字母+数字）
 *   isNumeric(str)                       → 纯数字检测
 *   isPositiveInteger(str)              → 正整数检测（不含前导零）
 *   isValidIntRange(value, min, max)     → 整数范围校验
 *   isValidLength(str, min, max)         → 字符串长度校验
 *
 * 【安全防护】
 *   isPathTraversal(path)                → 路径遍历攻击检测（.. / // / ~）
 *   isValidFileExtension(filename, ...)  → 文件扩展名白名单校验
 *
 * 【输入清洗】
 *   escapeHtml(input)                    → HTML 实体转义（防 XSS 输出）
 *   escapeUrl(input)                     → URL 编码（UTF-8）
 *
 * 【综合参数校验】
 *   validateParameter(param, name, max)  → 综合安全校验（空值/长度/SQL/XSS）
 *   validateIntParameter(param, name, ..)→ 整数参数校验（非空+类型+范围）
 *
 * ── 使用的关键 API ──────────────────────────────────────────────────────────
 *
 *   技术                            用途
 * ───────────────────────────────────────────────────────────────────
 *   Pattern.compile() + matcher()   正则编译 + 匹配引擎
 *   Pattern.CASE_INSENSITIVE        大小写不敏感标志（(?i) 内联写法）
 *   String.matches()                简单正则校验（用户名）
 *   URLEncoder.encode()             URL 百分号编码
 *   String.replace()                逐字符 HTML 转义
 *
 * ===========================================================================
 */
public class SecurityUtils {

    /**
     * SQL 注入攻击模式
     * 匹配规则：union select / select...from / insert into / update...set /
     *          delete from / drop table / exec / execute / sp_ / xp_ /
     *          0x 十六进制串 / 注释符 -- / 语句分隔符 ;
     *          恒真恒假 'or' / 'and' 等
     * 大小写不敏感（(?i)）。
     */
    private static final Pattern SQL_INJECTION_PATTERN = Pattern.compile(
        "(?i)(union\\s+select|select\\s+.+from|insert\\s+into|update\\s+.+set|delete\\s+from|drop\\s+table|exec\\s+|execute\\s+|sp_\\w+|xp_|0x[0-9a-f]+|--|;|'\\s*or\\s*'|'\\s*and\\s*')"
    );

    /**
     * XSS（跨站脚本）攻击模式
     * 匹配规则：&lt;script&gt; / &lt;iframe&gt; 标签、
     *          &lt;img&gt; 上的 on* 事件属性（onclick/onload/onerror）、
     *          javascript: / vbscript: 伪协议
     * 大小写不敏感（(?i)）。
     */
    private static final Pattern XSS_PATTERN = Pattern.compile(
        "(?i)(<script[^>]*>.*?</script>|<iframe[^>]*>.*?</iframe>|<img[^>]*on[^=]*=|onclick|onload|onerror|javascript:|vbscript:)"
    );

    /**
     * 邮箱格式校验正则
     * 匹配规则：本地部分 [A-Za-z0-9+_.-]+ + @ + 域名部分 [A-Za-z0-9.-]+
     * 注意：完整 RFC 5322 较复杂，此处采用最常见的简化版本。
     */
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$"
    );

    /**
     * 中国大陆手机号校验正则
     * 匹配规则：以 1 开头，第二位 3-9（覆盖 13x-19x 号段），后接 9 位数字，共 11 位
     */
    private static final Pattern PHONE_PATTERN = Pattern.compile(
        "^1[3-9]\\d{9}$"
    );

    /**
     * 18 位居民身份证号校验正则
     * 匹配规则：6 位地区码 + 4 位年份（18/19/20 开头）+ 2 位月份（01-12）
     *          + 2 位日期（01-31）+ 3 位顺序码 + 1 位校验码（数字或 X/x）
     */
    private static final Pattern ID_CARD_PATTERN = Pattern.compile(
        "^[1-9]\\d{5}(18|19|20)\\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01])\\d{3}[\\dXx]$"
    );

    private SecurityUtils() {
    }

    /**
     * 检查是否存在SQL注入攻击
     */
    public static boolean containsSqlInjection(String input) {
        if (input == null || input.isEmpty()) {
            return false;
        }
        return SQL_INJECTION_PATTERN.matcher(input).find();
    }

    /**
     * 检查是否存在XSS攻击
     */
    public static boolean containsXss(String input) {
        if (input == null || input.isEmpty()) {
            return false;
        }
        return XSS_PATTERN.matcher(input).find();
    }

    /**
     * 验证邮箱格式
     */
    public static boolean isValidEmail(String email) {
        if (email == null || email.isEmpty()) {
            return false;
        }
        return EMAIL_PATTERN.matcher(email).matches();
    }

    /**
     * 验证手机号格式
     */
    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.isEmpty()) {
            return false;
        }
        return PHONE_PATTERN.matcher(phone).matches();
    }

    /**
     * 验证身份证号格式
     */
    public static boolean isValidIdCard(String idCard) {
        if (idCard == null || idCard.isEmpty()) {
            return false;
        }
        return ID_CARD_PATTERN.matcher(idCard).matches();
    }

    /**
     * 验证用户名（字母、数字、下划线，3-20位）
     */
    public static boolean isValidUsername(String username) {
        if (username == null || username.isEmpty()) {
            return false;
        }
        return username.matches("^[a-zA-Z0-9_]{3,20}$");
    }

    /**
     * 验证密码强度（至少8位，包含字母和数字）
     */
    public static boolean isValidPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        boolean hasLetter = false;
        boolean hasNumber = false;
        for (char c : password.toCharArray()) {
            if (Character.isLetter(c)) hasLetter = true;
            if (Character.isDigit(c)) hasNumber = true;
            if (hasLetter && hasNumber) break;
        }
        return hasLetter && hasNumber;
    }

    /**
     * 验证整数范围
     */
    public static boolean isValidIntRange(int value, int min, int max) {
        return value >= min && value <= max;
    }

    /**
     * 验证字符串长度
     */
    public static boolean isValidLength(String str, int min, int max) {
        if (str == null) {
            return min == 0;
        }
        return str.length() >= min && str.length() <= max;
    }

    /**
     * 验证是否为纯数字
     */
    public static boolean isNumeric(String str) {
        if (str == null || str.isEmpty()) {
            return false;
        }
        for (char c : str.toCharArray()) {
            if (!Character.isDigit(c)) {
                return false;
            }
        }
        return true;
    }

    /**
     * 验证是否为正整数
     */
    public static boolean isPositiveInteger(String str) {
        if (str == null || str.isEmpty()) {
            return false;
        }
        if (str.charAt(0) == '0') {
            return str.length() == 1;
        }
        return isNumeric(str);
    }

    /**
     * 防止路径遍历攻击
     */
    public static boolean isPathTraversal(String path) {
        if (path == null) {
            return false;
        }
        return path.contains("..") || path.contains("//") || 
               path.matches("^[/\\\\].*") || path.contains("~");
    }

    /**
     * HTML转义
     */
    public static String escapeHtml(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#x27;")
                   .replace("/", "&#x2F;");
    }

    /**
     * URL编码
     */
    public static String escapeUrl(String input) {
        if (input == null) {
            return "";
        }
        try {
            return java.net.URLEncoder.encode(input, "UTF-8");
        } catch (Exception e) {
            return input;
        }
    }

    /**
     * 验证文件扩展名（白名单机制）
     */
    public static boolean isValidFileExtension(String filename, String[] allowedExtensions) {
        if (filename == null || filename.isEmpty()) {
            return false;
        }
        int lastDot = filename.lastIndexOf('.');
        if (lastDot == -1) {
            return false;
        }
        String extension = filename.substring(lastDot + 1).toLowerCase();
        for (String allowed : allowedExtensions) {
            if (allowed.equalsIgnoreCase(extension)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 验证请求参数是否安全
     */
    public static String validateParameter(String param, String paramName, int maxLength) {
        if (param == null) {
            throw new IllegalArgumentException(paramName + " 不能为空");
        }
        if (param.length() > maxLength) {
            throw new IllegalArgumentException(paramName + " 长度超过限制");
        }
        if (containsSqlInjection(param)) {
            throw new IllegalArgumentException(paramName + " 包含非法字符");
        }
        if (containsXss(param)) {
            throw new IllegalArgumentException(paramName + " 包含非法脚本");
        }
        return param.trim();
    }

    /**
     * 验证整数参数
     */
    public static int validateIntParameter(String param, String paramName, int min, int max) {
        if (param == null || param.trim().isEmpty()) {
            throw new IllegalArgumentException(paramName + " 不能为空");
        }
        int value;
        try {
            value = Integer.parseInt(param.trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(paramName + " 必须是整数");
        }
        if (value < min || value > max) {
            throw new IllegalArgumentException(paramName + " 超出有效范围");
        }
        return value;
    }
}