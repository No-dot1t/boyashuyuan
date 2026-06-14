/**
 * ===========================================================================
 * DeepSeekService —— 业务逻辑类
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.service
 * 最后更新  2026-05-19
 *
 * ── 方法索引 ────────────────────────────────────────────────────────────────
 *
 * 方法                            用途
 * ----------------------------------------------------------------------
 * isExpired()                        内部工具方法
 * loadConfig()                       初始化
 * setDefaultDeepSeek()               更新操作
 * setDefaultQwen()                   更新操作
 * setDefaultKimi()                   更新操作
 * resolveProvider(String model)      内部工具方法
 * chat(String userMessage)           内部工具方法
 * testConnection()                   内部工具方法
 * cleanupCache()                     数据校验 / 净化
 * getDefaultModel()                  查询操作
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   PROVIDER_DEEPSEEK = "deepseek"
 *   PROVIDER_QWEN = "qwen"
 *   PROVIDER_KIMI = "kimi"
 *   DEFAULT_MODEL = "deepseek-chat"
 *   sessionCounter = new AtomicInteger(0)
 *   responseCache = new java.util.concurrent.ConcurrentHashMap<>()
 *   CACHE_TTL_MS = 5 * 60 * 1000
 *   MAX_CACHE_SIZE = 100
 *   SYSTEM_PROMPT = "你是一个名为'博雅小星'的智能学习助手，运行在博雅书院学习平台上。\n"
            + "\n## 核心原则\n1. **专业准确**：技术问题确保准确性，学术问题注重权威性\n"
            + "2. **结构清晰**：复杂回答使用分层结构，善用标题/列表/代码块\n"
            + "3. **实用导向**：提供可操作的方案、代码示例和具体建议\n"
            + "4. **简洁高效**：避免冗余修饰，直击问题核心\n"
            + "\n## 回答规范\n- 使用Markdown格式化输出\n- 代码块指定语言类型\n"
            + "- 技术回答包含：需求分析 → 方案设计 → 代码实现 → 测试验证\n"
            + "- 学习建议包含：核心概念 → 关键要点 → 实践路径 → 延伸阅读\n"
            + "\n## 技术栈覆盖\n- 编程：Java, JavaScript, Python, HTML/CSS, SQL, TypeScript\n"
            + "- 框架：Spring Boot, React, Vue, MyBatis, 微信小程序\n"
            + "- 工具：Git, Docker, Maven, Linux, Redis, MySQL\n"
            + "- 领域：人工智能、数据分析、网络安全、云计算\n"
            + "\n现在开始与用户对话。保持专业、耐心、有建设性。"
 *   requestConfig = RequestConfig.custom()
                .setConnectTimeout(Timeout.ofMilliseconds(15000))
                .setResponseTimeout(Timeout.ofMilliseconds(120000)).build()
 *   cm = new PoolingHttpClientConnectionManager()
 *   props = new Properties()
 *   input = DeepSeekService.class.getClassLoader().getResourceAsStream("mail.properties")) {
            if (input == null) { setDefaultDeepSeek()
 *   lower = model.toLowerCase().trim()
 *   provider = resolveProvider(model)
 *   cacheKey = userMessage.trim() + "|" + model + "|" + provider.name
 *   cached = responseCache.get(cacheKey)
 *   requestBody = new JSONObject()
 *   messages = new JSONArray()
 *   sysMsg = new JSONObject()
 *   usrMsg = new JSONObject()
 *   httpPost = new HttpPost(provider.apiUrl)
 *   resp = httpClient.execute(httpPost)) {
            int statusCode = resp.getCode()
 *   responseBody = EntityUtils.toString(resp.getEntity(), StandardCharsets.UTF_8)
 *   jsonResp = JSON.parseObject(responseBody)
 *   choice = jsonResp.getJSONArray("choices").getJSONObject(0)
 *   content = choice.getJSONObject("message").getString("content").trim()
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   标准 Java 语法 + JDK 内置 API
 *
 * ===========================================================================
 */

package com.ebookBuy301.service;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.config.RequestConfig;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.client5.http.impl.io.PoolingHttpClientConnectionManager;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.apache.hc.core5.http.io.entity.StringEntity;
import org.apache.hc.core5.util.Timeout;

import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import java.io.InputStream;
import java.util.Properties;

/**
 * =============================================================================
 * DeepSeekService —— 多供应商 AI 服务
 * =============================================================================
 *
 * 支持 DeepSeek / 通义千问（Qwen）/ Kimi（Moonshot）三家供应商，
 * 均使用 OpenAI 兼容 API 格式，根据模型名称自动路由到对应供应商。
 *
 * 功能特性：智能路由、响应缓存、HTTP 连接池、会话隔离。
 * 配置文件：classpath:mail.properties（AI 配置项前缀 ai.）
 * =============================================================================
 */
public class DeepSeekService {

    private static final String PROVIDER_DEEPSEEK = "deepseek";
    private static final String PROVIDER_QWEN = "qwen";
    private static final String PROVIDER_KIMI = "kimi";

    private static String DEEPSEEK_API_URL;
    private static String DEEPSEEK_API_KEY;
    private static String QWEN_API_URL;
    private static String QWEN_API_KEY;
    private static String KIMI_API_URL;
    private static String KIMI_API_KEY;
    private static String DEFAULT_MODEL = "deepseek-chat";

    private static CloseableHttpClient httpClient;
    private static final AtomicInteger sessionCounter = new AtomicInteger(0);

    private static final Map<String, CacheEntry> responseCache = new java.util.concurrent.ConcurrentHashMap<>();
    private static final long CACHE_TTL_MS = 5 * 60 * 1000;
    private static final int MAX_CACHE_SIZE = 100;

    static {
        java.util.concurrent.ScheduledExecutorService scheduler = java.util.concurrent.Executors
                .newSingleThreadScheduledExecutor(r -> {
                    Thread t = new Thread(r, "DeepSeekService-CacheCleanup");
                    t.setDaemon(true);
                    return t;
                });
        scheduler.scheduleAtFixedRate(() -> cleanupExpiredCache(), 5, 5, java.util.concurrent.TimeUnit.MINUTES);
    }

    private static class CacheEntry {
        String response;
        long timestamp;

        CacheEntry(String response) {
            this.response = response;
            this.timestamp = System.currentTimeMillis();
        }

        boolean isExpired() {
            return System.currentTimeMillis() - timestamp > CACHE_TTL_MS;
        }
    }

    private static final String SYSTEM_PROMPT = "你是一个名为'博雅小星'的智能学习助手，运行在博雅书院学习平台上。\n"
            + "\n## 核心原则\n1. **专业准确**：技术问题确保准确性，学术问题注重权威性\n"
            + "2. **结构清晰**：复杂回答使用分层结构，善用标题/列表/代码块\n"
            + "3. **实用导向**：提供可操作的方案、代码示例和具体建议\n"
            + "4. **简洁高效**：避免冗余修饰，直击问题核心\n"
            + "\n## 回答规范\n- 使用Markdown格式化输出\n- 代码块指定语言类型\n"
            + "- 技术回答包含：需求分析 → 方案设计 → 代码实现 → 测试验证\n"
            + "- 学习建议包含：核心概念 → 关键要点 → 实践路径 → 延伸阅读\n"
            + "\n## 技术栈覆盖\n- 编程：Java, JavaScript, Python, HTML/CSS, SQL, TypeScript\n"
            + "- 框架：Spring Boot, React, Vue, MyBatis, 微信小程序\n"
            + "- 工具：Git, Docker, Maven, Linux, Redis, MySQL\n"
            + "- 领域：人工智能、数据分析、网络安全、云计算\n"
            + "\n现在开始与用户对话。保持专业、耐心、有建设性。";

    static {
        loadConfig();
        RequestConfig requestConfig = RequestConfig.custom()
                .setConnectTimeout(Timeout.ofMilliseconds(15000))
                .setResponseTimeout(Timeout.ofMilliseconds(120000)).build();
        PoolingHttpClientConnectionManager cm = new PoolingHttpClientConnectionManager();
        cm.setMaxTotal(10);
        cm.setDefaultMaxPerRoute(5);
        httpClient = HttpClients.custom().setDefaultRequestConfig(requestConfig).setConnectionManager(cm).build();
    }

    private static void loadConfig() {
        Properties props = new Properties();
        try (InputStream input = DeepSeekService.class.getClassLoader().getResourceAsStream("ai.properties")) {
            if (input == null) {
                System.err.println("[DeepSeekService] 警告：未找到 ai.properties 配置文件，使用默认配置");
                setDefaultDeepSeek();
                setDefaultQwen();
                setDefaultKimi();
                return;
            }
            props.load(input);

            DEEPSEEK_API_URL = props.getProperty("ai.deepseek.api_url");
            DEEPSEEK_API_KEY = props.getProperty("ai.deepseek.api_key");
            QWEN_API_URL = props.getProperty("ai.qwen.api_url");
            QWEN_API_KEY = props.getProperty("ai.qwen.api_key");
            KIMI_API_URL = props.getProperty("ai.kimi.api_url");
            KIMI_API_KEY = props.getProperty("ai.kimi.api_key");
            DEFAULT_MODEL = props.getProperty("ai.deepseek.default_model", "deepseek-chat");

            if (DEEPSEEK_API_URL == null || DEEPSEEK_API_URL.isEmpty())
                setDefaultDeepSeek();
            if (QWEN_API_URL == null || QWEN_API_URL.isEmpty())
                setDefaultQwen();
            if (KIMI_API_URL == null || KIMI_API_URL.isEmpty())
                setDefaultKimi();

            System.out.println("[DeepSeekService] AI配置加载成功");
        } catch (Exception e) {
            System.err.println("[DeepSeekService] 配置加载失败: " + e.getMessage());
            setDefaultDeepSeek();
            setDefaultQwen();
            setDefaultKimi();
        }
    }

    /**
     * 设置 DeepSeek 供应商的默认 API 地址和空 Key。
     * <p>
     * 当 {@code ai.properties} 未配置或配置项为空时调用此方法兜底。
     * Key 留空，调用方在 {@link #chatWithConfig} 阶段会发现并抛出异常。
     */
    private static void setDefaultDeepSeek() {
        DEEPSEEK_API_URL = "https://api.deepseek.com/chat/completions";
        DEEPSEEK_API_KEY = "";
    }

    /**
     * 设置通义千问（Qwen）供应商的默认 API 地址和空 Key。
     * <p>
     * 阿里云 DashScope 兼容 OpenAI Chat Completions 协议。
     */
    private static void setDefaultQwen() {
        QWEN_API_URL = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions";
        QWEN_API_KEY = "";
    }

    /**
     * 设置 Kimi（Moonshot）供应商的默认 API 地址和空 Key。
     * <p>
     * Moonshot AI 官方 OpenAI 兼容接口。
     */
    private static void setDefaultKimi() {
        KIMI_API_URL = "https://api.moonshot.cn/v1/chat/completions";
        KIMI_API_KEY = "";
    }

    /**
     * 根据模型名称解析对应的供应商信息。
     * <p>
     * 算法：模型名小写后按前缀匹配：
     *   - {@code qwen*}    → Qwen（阿里云 DashScope）
     *   - {@code moonshot*} → Kimi（Moonshot AI）
     *   - 其他 / null      → 默认走 DeepSeek
     *
     * @param model 模型名称（可为 null，会回退到 {@code DEFAULT_MODEL}）
     * @return 包含 apiUrl / apiKey / name 三元组的 {@link ProviderInfo}
     */
    private static ProviderInfo resolveProvider(String model) {
        if (model == null)
            model = DEFAULT_MODEL;
        String lower = model.toLowerCase().trim();
        if (lower.startsWith("qwen"))
            return new ProviderInfo(QWEN_API_URL, QWEN_API_KEY, PROVIDER_QWEN);
        if (lower.startsWith("moonshot"))
            return new ProviderInfo(KIMI_API_URL, KIMI_API_KEY, PROVIDER_KIMI);
        return new ProviderInfo(DEEPSEEK_API_URL, DEEPSEEK_API_KEY, PROVIDER_DEEPSEEK);
    }

    private static class ProviderInfo {
        String apiUrl, apiKey, name;

        ProviderInfo(String apiUrl, String apiKey, String name) {
            this.apiUrl = apiUrl;
            this.apiKey = apiKey;
            this.name = name;
        }
    }

    public String chat(String userMessage) throws Exception {
        return chat(userMessage, DEFAULT_MODEL);
    }

    public String chat(String userMessage, String model) throws Exception {
        return chatWithConfig(userMessage, model, null, null, null);
    }

    /**
     * 支持自定义 API 配置的聊天方法
     *
     * @param userMessage   用户消息
     * @param model         模型名称
     * @param customApiUrl  自定义 API URL（可为 null，使用系统配置）
     * @param customApiKey  自定义 API Key（可为 null，使用系统配置）
     * @param customProvider 自定义供应商名称（可为 null）
     */
    public String chat(String userMessage, String model, String customApiUrl, String customApiKey, String customProvider) throws Exception {
        return chatWithConfig(userMessage, model, customApiUrl, customApiKey, customProvider);
    }

    /**
     * 使用自定义 API 配置进行对话（核心方法）。
     * <p>
     * 算法流程：
     *   ① 判断是否提供完整自定义配置（url + key 均非空）
     *   ② 若自定义则使用 {@code customApiUrl/customApiKey}，否则按 model 路由供应商
     *   ③ 校验 API Key 不能为空，否则抛出异常提示用户在设置中填入
     *   ④ 拼接 cacheKey = userMessage + model + provider，命中缓存则直接返回
     *   ⑤ 构造请求体（model/2048 tokens/0.7 temperature/system+user 消息）
     *   ⑥ 发送 HTTP POST → 解析 choices[0].message.content
     *   ⑦ 写入响应缓存，返回最终内容
     *
     * @param userMessage    用户消息
     * @param model          模型名称（用于供应商路由）
     * @param customApiUrl   自定义 API URL（可为 null，走系统配置）
     * @param customApiKey   自定义 API Key（可为 null，走系统配置）
     * @param customProvider 自定义供应商名称（可为 null）
     * @return AI 回复内容
     * @throws Exception 当 API Key 未配置、API 返回非 200 或响应解析失败时抛出
     */
    private String chatWithConfig(String userMessage, String model,
            String customApiUrl, String customApiKey, String customProvider) throws Exception {
        // 如果提供了完整的自定义配置，使用自定义配置
        boolean useCustom = customApiUrl != null && !customApiUrl.trim().isEmpty()
                && customApiKey != null && !customApiKey.trim().isEmpty();

        ProviderInfo provider;
        if (useCustom) {
            provider = new ProviderInfo(customApiUrl.trim(), customApiKey.trim(),
                    customProvider != null ? customProvider : "custom");
        } else {
            provider = resolveProvider(model);
        }

        // 验证 API Key
        if (provider.apiKey == null || provider.apiKey.trim().isEmpty()) {
            throw new Exception(provider.name + " API Key 未配置，请在设置中填入");
        }

        String cacheKey = userMessage.trim() + "|" + model + "|" + provider.name;
        CacheEntry cached = responseCache.get(cacheKey);
        if (cached != null && !cached.isExpired())
            return cached.response;

        JSONObject requestBody = new JSONObject();
        requestBody.put("model", useCustom ? model : model); // 自定义时用用户指定的model
        requestBody.put("max_tokens", 2048);
        requestBody.put("temperature", 0.7);
        requestBody.put("stream", false);
        JSONArray messages = new JSONArray();
        JSONObject sysMsg = new JSONObject();
        sysMsg.put("role", "system");
        sysMsg.put("content", SYSTEM_PROMPT);
        messages.add(sysMsg);
        JSONObject usrMsg = new JSONObject();
        usrMsg.put("role", "user");
        usrMsg.put("content", userMessage);
        messages.add(usrMsg);
        requestBody.put("messages", messages);
        HttpPost httpPost = new HttpPost(provider.apiUrl);
        httpPost.setHeader("Content-Type", "application/json");
        httpPost.setHeader("Authorization", "Bearer " + provider.apiKey);
        httpPost.setEntity(new StringEntity(JSON.toJSONString(requestBody), StandardCharsets.UTF_8));
        try (CloseableHttpResponse resp = httpClient.execute(httpPost)) {
            int statusCode = resp.getCode();
            String responseBody = EntityUtils.toString(resp.getEntity(), StandardCharsets.UTF_8);
            if (statusCode != 200)
                throw new Exception(provider.name + " API失败: " + statusCode);
            JSONObject jsonResp = JSON.parseObject(responseBody);
            if (jsonResp.containsKey("error"))
                throw new Exception(jsonResp.getJSONObject("error").getString("message"));
            if (jsonResp.containsKey("choices") && jsonResp.getJSONArray("choices").size() > 0) {
                JSONObject choice = jsonResp.getJSONArray("choices").getJSONObject(0);
                if (choice.containsKey("message") && choice.getJSONObject("message").containsKey("content")) {
                    String content = choice.getJSONObject("message").getString("content").trim();
                    responseCache.put(cacheKey, new CacheEntry(content));
                    cleanupExpiredCache();
                    return content;
                }
            }
            return "抱歉，我暂时无法回答这个问题。";
        }
    }

    public boolean testConnection() {
        try {
            return chat("你好") != null;
        } catch (Exception e) {
            return false;
        }
    }

    private static void cleanupExpiredCache() {
        int initialSize = responseCache.size();
        responseCache.entrySet().removeIf(e -> e.getValue().isExpired());
        int cleaned = initialSize - responseCache.size();
        if (cleaned > 0) {
            System.out.println("[DeepSeekService] 缓存清理完成，清理过期条目: " + cleaned + " 个");
        }
    }

    public static String getDefaultModel() {
        return DEFAULT_MODEL;
    }
}
