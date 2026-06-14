/**
 * ===========================================================================
 * EnhancedAIService —— 业务逻辑类
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
 * buildEnhancedSystemPrompt()        内部工具方法
 * buildTools()                       内部工具方法
 * enhancedChat(String userMessage)   内部工具方法
 * shouldUseTools(String userMessage) 内部工具方法
 * processToolCalls(JSONObject message, String userMessage)内部工具方法
 * simulateToolExecution(String functionName, JSONObject arguments)内部工具方法
 * simulateCodeExecution(language, code)内部工具方法
 * simulateKnowledgeSearch(query, category)内部工具方法
 * generateFinalAnswer(String userMessage, String toolResults)内部工具方法
 * postProcessResponse(String content, String userMessage)内部工具方法
 * isComplexQuestion(String message)  内部工具方法
 * testConnection()                   内部工具方法
 * cleanupCache()                     数据校验 / 净化
 *
 * ── 常量 ──────────────────────────────────────────────────────────────────
 *
 *   PROVIDER_DEEPSEEK = "deepseek"
 *   PROVIDER_QWEN = "qwen"
 *   PROVIDER_KIMI = "kimi"
 *   DEFAULT_MODEL = "deepseek-chat"
 *   ENHANCED_SYSTEM_PROMPT = buildEnhancedSystemPrompt()
 *   TOOLS = buildTools()
 *   responseCache = new java.util.concurrent.ConcurrentHashMap<>()
 *   CACHE_TTL_MS = 5 * 60 * 1000
 *   MAX_CACHE_SIZE = 100
 *   requestConfig = RequestConfig.custom()
                .setConnectTimeout(Timeout.ofMilliseconds(15000))
                .setResponseTimeout(Timeout.ofMilliseconds(120000))
                .build()
 *   connectionManager = new PoolingHttpClientConnectionManager()
 *   props = new Properties()
 *   input = EnhancedAIService.class.getClassLoader()
                .getResourceAsStream("mail.properties")) {
            if (input == null) {
                System.err.println("[EnhancedAIService] 警告: 无法找到 mail.properties，使用默认配置")
 *   lower = model.toLowerCase()
 *   tools = new ArrayList<>()
 *   codeExecutor = new JSONObject()
 *   codeExecutorFunc = new JSONObject()
 *   codeExecutorParams = new JSONObject()
 *   codeExecutorProps = new JSONObject()
 *   languageProp = new JSONObject()
 *   codeProp = new JSONObject()
 *   knowledgeSearch = new JSONObject()
 *   knowledgeSearchFunc = new JSONObject()
 *   knowledgeSearchParams = new JSONObject()
 *   knowledgeSearchProps = new JSONObject()
 *   queryProp = new JSONObject()
 *   categoryProp = new JSONObject()
 *   provider = resolveProvider(model)
 *   cacheKey = userMessage.trim() + "|" + model + "|enhanced"
 *   cached = responseCache.get(cacheKey)
 *   requestBody = new JSONObject()
 *   messages = new JSONArray()
 *   systemMessage = new JSONObject()
 *   userMessageObj = new JSONObject()
 *   toolsArray = new JSONArray()
 *   httpPost = new HttpPost(provider.apiUrl)
 *   response = httpClient.execute(httpPost)) {
            int statusCode = response.getCode()
 *   entity = response.getEntity()
 *   responseBody = EntityUtils.toString(entity, StandardCharsets.UTF_8)
 *   jsonResponse = JSON.parseObject(responseBody)
 *   error = jsonResponse.getJSONObject("error")
 *   errorMessage = error.containsKey("message") ? error.getString("message") : "未知错误"
 *   choice = jsonResponse.getJSONArray("choices").getJSONObject(0)
 *   message = choice.getJSONObject("message")
 *   result = processToolCalls(message, userMessage)
 *   content = message.getString("content").trim()
 *   lowerMessage = userMessage.toLowerCase()
 *   result = new StringBuilder()
 *   toolCalls = message.getJSONArray("tool_calls")
 *   i = 0
 *   toolCall = toolCalls.getJSONObject(i)
 *   function = toolCall.getJSONObject("function")
 *   functionName = function.getString("name")
 *   arguments = JSON.parseObject(function.getString("arguments"))
 *   toolResult = simulateToolExecution(functionName, arguments)
 *   finalAnswer = generateFinalAnswer(userMessage, result.toString())
 *   language = arguments.getString("language")
 *   code = arguments.getString("code")
 *   query = arguments.getString("query")
 *   category = arguments.containsKey("category") ? arguments.getString("category") : "general"
 *   results = new HashMap<>()
 *   result = results.getOrDefault(category, results.get("general"))
 *   lowerMessage = message.toLowerCase()
 *   response = enhancedChat("你好", DEFAULT_MODEL, false)
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
import java.util.concurrent.atomic.AtomicInteger;
import java.util.*;
import java.io.InputStream;
import java.util.Properties;

/**
 * 增强版AI服务类（多供应商）
 * 支持 DeepSeek / 通义千问(Qwen) / Kimi(Moonshot)
 * 支持深度思考、工具调用、结构化输出等功能
 */
public class EnhancedAIService {

    // ===== 供应商配置 =====
    private static final String PROVIDER_DEEPSEEK = "deepseek";
    private static final String PROVIDER_QWEN = "qwen";
    private static final String PROVIDER_KIMI = "kimi";

    private static String DEEPSEEK_API_URL;
    private static String DEEPSEEK_API_KEY;

    private static String QWEN_API_URL;
    private static String QWEN_API_KEY;

    private static String KIMI_API_URL;
    private static String KIMI_API_KEY;

    // 默认模型
    private static String DEFAULT_MODEL = "deepseek-chat";

    // HTTP客户端
    private static CloseableHttpClient httpClient;

    // 增强版系统提示词
    private static final String ENHANCED_SYSTEM_PROMPT = buildEnhancedSystemPrompt();

    // 工具定义
    private static final List<JSONObject> TOOLS = buildTools();

    // 响应缓存
    private static final java.util.Map<String, CacheEntry> responseCache = new java.util.concurrent.ConcurrentHashMap<>();
    private static final long CACHE_TTL_MS = 5 * 60 * 1000;
    private static final int MAX_CACHE_SIZE = 100;

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

    static {
        loadConfig();

        RequestConfig requestConfig = RequestConfig.custom()
                .setConnectTimeout(Timeout.ofMilliseconds(15000))
                .setResponseTimeout(Timeout.ofMilliseconds(120000))
                .build();

        PoolingHttpClientConnectionManager connectionManager = new PoolingHttpClientConnectionManager();
        connectionManager.setMaxTotal(10);
        connectionManager.setDefaultMaxPerRoute(5);

        httpClient = HttpClients.custom()
                .setDefaultRequestConfig(requestConfig)
                .setConnectionManager(connectionManager)
                .build();
    }

    /**
     * 从配置文件加载所有AI供应商配置
     */
    private static void loadConfig() {
        Properties props = new Properties();
        try (InputStream input = EnhancedAIService.class.getClassLoader()
                .getResourceAsStream("ai.properties")) {
            if (input == null) {
                System.err.println("[EnhancedAIService] 警告: 无法找到 ai.properties，使用默认配置");
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

            if (DEEPSEEK_API_URL == null || DEEPSEEK_API_URL.isEmpty()) setDefaultDeepSeek();
            if (QWEN_API_URL == null || QWEN_API_URL.isEmpty()) setDefaultQwen();
            if (KIMI_API_URL == null || KIMI_API_URL.isEmpty()) setDefaultKimi();

            System.out.println("[EnhancedAIService] 多供应商配置加载成功");
            System.out.println("[EnhancedAIService] DeepSeek: " + DEEPSEEK_API_URL);
            System.out.println("[EnhancedAIService] Qwen: " + QWEN_API_URL);
            System.out.println("[EnhancedAIService] Kimi: " + KIMI_API_URL);
        } catch (Exception e) {
            System.err.println("[EnhancedAIService] 加载配置文件失败: " + e.getMessage());
            setDefaultDeepSeek();
            setDefaultQwen();
            setDefaultKimi();
        }
    }

    private static void setDefaultDeepSeek() {
        DEEPSEEK_API_URL = "https://api.deepseek.com/chat/completions";
        DEEPSEEK_API_KEY = "";
    }

    private static void setDefaultQwen() {
        QWEN_API_URL = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions";
        QWEN_API_KEY = "";
    }

    private static void setDefaultKimi() {
        KIMI_API_URL = "https://api.moonshot.cn/v1/chat/completions";
        KIMI_API_KEY = "";
    }

    /**
     * 根据模型名称确定供应商信息
     */
    private static ProviderInfo resolveProvider(String model) {
        if (model == null) model = DEFAULT_MODEL;
        String lower = model.toLowerCase();

        if (lower.startsWith("qwen")) {
            return new ProviderInfo(QWEN_API_URL, QWEN_API_KEY, PROVIDER_QWEN);
        } else if (lower.startsWith("moonshot")) {
            return new ProviderInfo(KIMI_API_URL, KIMI_API_KEY, PROVIDER_KIMI);
        } else {
            return new ProviderInfo(DEEPSEEK_API_URL, DEEPSEEK_API_KEY, PROVIDER_DEEPSEEK);
        }
    }

    private static class ProviderInfo {
        String apiUrl;
        String apiKey;
        String name;
        ProviderInfo(String apiUrl, String apiKey, String name) {
            this.apiUrl = apiUrl;
            this.apiKey = apiKey;
            this.name = name;
        }
    }

    private static String buildEnhancedSystemPrompt() {
        return "你是'博雅小星'，一个运行在博雅书院学习平台上的智能学习助手。\n" +
               "\n" +
               "## 核心特质\n" +
               "- **深度思考**：对复杂问题进行系统化分析，展示清晰的推理链路\n" +
               "- **技术严谨**：提供准确、可运行的代码示例，确保最佳实践\n" +
               "- **学习引导**：注重启发式教学，引导用户自主思考和探索\n" +
               "\n" +
               "## 回答结构\n" +
               "### 技术问题\n" +
               "```\n" +
               "🛠 问题分析：分析用户需求和技术难点\n" +
               "📐 方案设计：选择合适的技术方案和架构\n" +
               "💻 代码实现：提供完整、可运行的代码\n" +
               "🧪 测试验证：提供测试用例或验证方法\n" +
               "📖 延伸学习：推荐相关学习资源\n" +
               "```\n" +
               "\n" +
               "### 学习问题\n" +
               "```\n" +
               "🎯 核心概念：提炼问题的本质和关键\n" +
               "📋 知识要点：列出主要知识点\n" +
               "🏃 学习路径：规划从入门到精通的学习路线\n" +
               "💡 实践建议：提供动手实践的具体方向\n" +
               "```\n" +
               "\n" +
               "## 格式要求\n" +
               "- 使用Markdown格式化输出\n" +
               "- 代码块必须指定语言类型（```java、```python、```html等）\n" +
               "- 表格使用标准Markdown表格语法\n" +
               "- 保持段落简洁，适当使用标题层级\n" +
               "\n" +
               "## 技术领域\n" +
               "Java, JavaScript, Python, Spring Boot, React, Vue, MySQL, Redis, Docker, Git, Linux, 微信小程序, 人工智能, 数据结构与算法等。\n" +
               "\n" +
               "现在开始与用户对话，展示你的专业能力。";
    }

    private static List<JSONObject> buildTools() {
        List<JSONObject> tools = new ArrayList<>();

        JSONObject codeExecutor = new JSONObject();
        codeExecutor.put("type", "function");
        JSONObject codeExecutorFunc = new JSONObject();
        codeExecutorFunc.put("name", "code_executor");
        codeExecutorFunc.put("description", "执行代码片段并返回结果，支持Java、JavaScript、Python等语言");

        JSONObject codeExecutorParams = new JSONObject();
        codeExecutorParams.put("type", "object");
        JSONObject codeExecutorProps = new JSONObject();

        JSONObject languageProp = new JSONObject();
        languageProp.put("type", "string");
        languageProp.put("description", "编程语言");
        languageProp.put("enum", JSON.parseArray("[\"java\", \"javascript\", \"python\", \"html\", \"css\", \"sql\"]"));
        codeExecutorProps.put("language", languageProp);

        JSONObject codeProp = new JSONObject();
        codeProp.put("type", "string");
        codeProp.put("description", "要执行的代码");
        codeExecutorProps.put("code", codeProp);

        codeExecutorParams.put("properties", codeExecutorProps);
        codeExecutorParams.put("required", JSON.parseArray("[\"language\", \"code\"]"));
        codeExecutorFunc.put("parameters", codeExecutorParams);
        codeExecutor.put("function", codeExecutorFunc);
        tools.add(codeExecutor);

        JSONObject knowledgeSearch = new JSONObject();
        knowledgeSearch.put("type", "function");
        JSONObject knowledgeSearchFunc = new JSONObject();
        knowledgeSearchFunc.put("name", "knowledge_search");
        knowledgeSearchFunc.put("description", "搜索博雅书院知识库");

        JSONObject knowledgeSearchParams = new JSONObject();
        knowledgeSearchParams.put("type", "object");
        JSONObject knowledgeSearchProps = new JSONObject();

        JSONObject queryProp = new JSONObject();
        queryProp.put("type", "string");
        queryProp.put("description", "搜索关键词");
        knowledgeSearchProps.put("query", queryProp);

        JSONObject categoryProp = new JSONObject();
        categoryProp.put("type", "string");
        categoryProp.put("description", "搜索类别");
        categoryProp.put("enum", JSON.parseArray("[\"courses\", \"teachers\", \"books\", \"papers\", \"general\"]"));
        knowledgeSearchProps.put("category", categoryProp);

        knowledgeSearchParams.put("properties", knowledgeSearchProps);
        knowledgeSearchParams.put("required", JSON.parseArray("[\"query\"]"));
        knowledgeSearchFunc.put("parameters", knowledgeSearchParams);
        knowledgeSearch.put("function", knowledgeSearchFunc);
        tools.add(knowledgeSearch);

        return tools;
    }

    /**
     * 增强版对话 - 使用默认模型
     */
    public String enhancedChat(String userMessage) throws Exception {
        return enhancedChat(userMessage, DEFAULT_MODEL, true);
    }

    /**
     * 增强版对话 - 完整实现（支持工具调用、缓存、响应后处理）
     * <p>
     * 算法流程：
     *   ① 解析模型对应的供应商信息（{@link #resolveProvider}）
     *   ② 查询响应缓存（5 分钟 TTL），命中则直接返回
     *   ③ 构造请求体：model/max_tokens/temperature + system 提示词 + user 消息
     *   ④ 如启用工具且 {@link #shouldUseTools} 为 true，则附加 tools 参数
     *   ⑤ 通过 HTTP 客户端发送 POST 请求
     *   ⑥ 解析响应：处理 tool_calls（{@link #processToolCalls}）或普通 content
     *   ⑦ 对普通响应执行 {@link #postProcessResponse} 后处理
     *   ⑧ 写入缓存并返回结果
     *
     * @param userMessage 用户消息
     * @param model       模型名称（qwen* / moonshot* / 其他视为 deepseek）
     * @param useTools    是否允许模型使用工具
     * @return AI 回复内容
     * @throws Exception 当 API 返回非 200 / 错误字段 / 响应为空时抛出
     */
    public String enhancedChat(String userMessage, String model, boolean useTools) throws Exception {
        ProviderInfo provider = resolveProvider(model);
        System.out.println("[EnhancedAIService] 发送请求 -> " + provider.name + ", 模型: " + model);

        // 检查缓存
        String cacheKey = userMessage.trim() + "|" + model + "|enhanced";
        CacheEntry cached = responseCache.get(cacheKey);
        if (cached != null && !cached.isExpired()) {
            return cached.response;
        }

        JSONObject requestBody = new JSONObject();
        requestBody.put("model", model);
        requestBody.put("max_tokens", 4096);
        requestBody.put("temperature", 0.7);
        requestBody.put("stream", false);

        JSONArray messages = new JSONArray();

        JSONObject systemMessage = new JSONObject();
        systemMessage.put("role", "system");
        systemMessage.put("content", ENHANCED_SYSTEM_PROMPT);
        messages.add(systemMessage);

        JSONObject userMessageObj = new JSONObject();
        userMessageObj.put("role", "user");
        userMessageObj.put("content", userMessage);
        messages.add(userMessageObj);

        requestBody.put("messages", messages);

        if (useTools && shouldUseTools(userMessage)) {
            JSONArray toolsArray = new JSONArray();
            for (JSONObject tool : TOOLS) {
                toolsArray.add(tool);
            }
            requestBody.put("tools", toolsArray);
            requestBody.put("tool_choice", "auto");
        }

        HttpPost httpPost = new HttpPost(provider.apiUrl);
        httpPost.setHeader("Content-Type", "application/json");
        httpPost.setHeader("Authorization", "Bearer " + provider.apiKey);
        httpPost.setEntity(new StringEntity(JSON.toJSONString(requestBody), StandardCharsets.UTF_8));

        try (CloseableHttpResponse response = httpClient.execute(httpPost)) {
            int statusCode = response.getCode();

            var entity = response.getEntity();
            if (entity == null) {
                throw new Exception("API响应为空");
            }

            String responseBody = EntityUtils.toString(entity, StandardCharsets.UTF_8);

            if (statusCode != 200) {
                System.err.println("[EnhancedAIService] " + provider.name + " API请求失败: " + statusCode);
                throw new Exception(provider.name + " API请求失败: " + statusCode);
            }

            JSONObject jsonResponse = JSON.parseObject(responseBody);

            if (jsonResponse.containsKey("error")) {
                JSONObject error = jsonResponse.getJSONObject("error");
                String errorMessage = error.containsKey("message") ? error.getString("message") : "未知错误";
                throw new Exception(provider.name + " API错误: " + errorMessage);
            }

            if (jsonResponse.containsKey("choices") && jsonResponse.getJSONArray("choices").size() > 0) {
                JSONObject choice = jsonResponse.getJSONArray("choices").getJSONObject(0);

                if (choice.containsKey("message")) {
                    JSONObject message = choice.getJSONObject("message");

                    if (message.containsKey("tool_calls")) {
                        String result = processToolCalls(message, userMessage);
                        responseCache.put(cacheKey, new CacheEntry(result));
                        cleanupCache();
                        return result;
                    }

                    if (message.containsKey("content")) {
                        String content = message.getString("content").trim();
                        content = postProcessResponse(content, userMessage);
                        responseCache.put(cacheKey, new CacheEntry(content));
                        cleanupCache();
                        return content;
                    }
                }
            }

            return "抱歉，我暂时无法回答这个问题。";

        } catch (Exception e) {
            System.err.println("[EnhancedAIService] 请求异常: " + e.getMessage());
            throw e;
        }
    }

    /**
     * 判断用户消息是否需要触发工具调用（代码执行 / 知识搜索）。
     * <p>
     * 算法：关键词黑名单匹配。遍历 {@code toolTriggers} 数组中的中文触发词，
     * 若消息中（小写）包含任一关键词则返回 true。
     *
     * @param userMessage 用户原始消息
     * @return true 表示需要附加 tools 参数并允许模型选择工具
     */
    private boolean shouldUseTools(String userMessage) {
        String lowerMessage = userMessage.toLowerCase();
        String[] toolTriggers = {
            "代码", "程序", "编程", "运行", "执行", "实现",
            "搜索", "查找", "查询", "资料", "文档",
            "文件", "处理", "分析", "数据", "统计"
        };
        for (String trigger : toolTriggers) {
            if (lowerMessage.contains(trigger)) return true;
        }
        return false;
    }

    /**
     * 处理模型返回的 tool_calls 字段，组织多轮工具调用结果并生成最终回答。
     * <p>
     * 算法流程：
     *   ① 遍历 {@code tool_calls} 数组中每个工具调用
     *   ② 解析函数名和参数 → 调用 {@link #simulateToolExecution} 执行
     *   ③ 将所有结果拼装为 Markdown 报告
     *   ④ 调用 {@link #generateFinalAnswer} 生成最终回答追加到末尾
     *
     * @param message     模型返回的 message 对象（包含 tool_calls 字段）
     * @param userMessage 用户原始消息（用于最终回答生成）
     * @return 包含工具调用记录与最终回答的 Markdown 文本
     */
    private String processToolCalls(JSONObject message, String userMessage) {
        StringBuilder result = new StringBuilder();
        result.append("🛠️ **检测到工具调用需求**\n\n");

        JSONArray toolCalls = message.getJSONArray("tool_calls");
        for (int i = 0; i < toolCalls.size(); i++) {
            JSONObject toolCall = toolCalls.getJSONObject(i);
            JSONObject function = toolCall.getJSONObject("function");
            String functionName = function.getString("name");
            JSONObject arguments = JSON.parseObject(function.getString("arguments"));

            result.append("### 工具调用 #").append(i + 1).append("\n");
            result.append("- **工具名称**: `").append(functionName).append("`\n");
            result.append("- **调用参数**: \n```json\n").append(JSON.toJSONString(arguments)).append("\n```\n");

            String toolResult = simulateToolExecution(functionName, arguments);
            result.append("- **执行结果**: \n```\n").append(toolResult).append("\n```\n\n");
        }

        result.append("✨ **思考过程总结**\n");
        result.append("基于工具调用结果，我将为您提供最终答案：\n\n");

        String finalAnswer = generateFinalAnswer(userMessage, result.toString());
        result.append(finalAnswer);

        return result.toString();
    }

    /**
     * 模拟工具执行（实际未调用真实工具，仅返回模拟结果）。
     * <p>
     * 算法：switch 分支路由，根据 {@code functionName} 路由到对应的
     * 代码执行模拟或知识搜索模拟方法。
     *
     * @param functionName 工具函数名（code_executor / knowledge_search）
     * @param arguments    工具调用参数（JSON 对象）
     * @return 模拟执行结果字符串
     */
    private String simulateToolExecution(String functionName, JSONObject arguments) {
        switch (functionName) {
            case "code_executor":
                String language = arguments.getString("language");
                String code = arguments.getString("code");
                return simulateCodeExecution(language, code);
            case "knowledge_search":
                String query = arguments.getString("query");
                String category = arguments.containsKey("category") ? arguments.getString("category") : "general";
                return simulateKnowledgeSearch(query, category);
            default:
                return "工具执行完成（模拟）";
        }
    }

    private String simulateCodeExecution(String language, String code) {
        return String.format(
            "✅ 代码执行模拟完成\n" +
            "• 语言: %s\n" +
            "• 代码长度: %d 字符\n" +
            "• 执行状态: 成功\n" +
            "• 输出: [模拟输出] 代码语法检查通过，逻辑正确\n\n" +
            "💡 实际环境中需要真实执行环境",
            language, code.length()
        );
    }

    private String simulateKnowledgeSearch(String query, String category) {
        Map<String, String> results = new HashMap<>();
        results.put("courses", "找到相关课程: 《人工智能导论》《机器学习基础》《深度学习实践》");
        results.put("teachers", "找到相关导师: 张教授（AI方向）、李教授（数据科学）、王教授（软件开发）");
        results.put("books", "找到相关图书: 《Python编程从入门到实践》《Java核心技术》《算法导论》");
        results.put("papers", "找到相关论文: 《深度学习在自然语言处理中的应用》《量子计算研究进展》");
        results.put("general", "找到相关资料: 请参考博雅书院知识库或联系图书馆管理员");

        String result = results.getOrDefault(category, results.get("general"));
        return String.format(
            "🔍 知识搜索完成\n" +
            "• 查询: %s\n" +
            "• 类别: %s\n" +
            "• 结果: %s\n\n" +
            "📚 更多信息请访问博雅书院资源中心",
            query, category, result
        );
    }

    private String generateFinalAnswer(String userMessage, String toolResults) {
        return String.format(
            "## 📋 最终回答\n\n" +
            "**问题**: %s\n\n" +
            "### 🧠 我的分析\n" +
            "通过工具调用和分析，我理解了您的问题需求。\n\n" +
            "### ✅ 解决方案\n" +
            "1. **核心要点**: 根据分析结果，问题的关键点在于...\n" +
            "2. **实施步骤**: \n" +
            "   - 第一步: 准备环境\n" +
            "   - 第二步: 实施核心逻辑\n" +
            "   - 第三步: 测试验证\n" +
            "3. **注意事项**: 需要注意...\n\n" +
            "### 💡 建议\n" +
            "- 建议进一步学习相关知识\n" +
            "- 实践是最好的学习方式\n" +
            "- 遇到问题可以随时向我咨询\n\n" +
            "---\n" +
            "✨ 如果您有更多问题或需要更详细的解释，请随时告诉我！",
            userMessage
        );
    }

    private String postProcessResponse(String content, String userMessage) {
        if (!content.contains("✨") && !content.contains("🧠") && !content.contains("✅")) {
            if (isComplexQuestion(userMessage)) {
                content = "✨ **思考过程**\n" +
                         "让我先分析一下您的问题...\n\n" +
                         content +
                         "\n\n✅ **总结**\n以上是我对您问题的分析和回答。";
            }
        }
        content = content.replaceAll("```(\\s*)$", "```text$1");
        return content;
    }

    /**
     * 判断用户消息是否属于"复杂问题"，用于决定是否在响应前后追加思考过程标记。
     * <p>
     * 算法：
     *   ① 关键词黑名单匹配（如何/为什么/怎样/分析/对比/架构 等）
     *   ② 消息长度阈值（&gt; 50 字符视为复杂）
     *  满足任一条件即返回 true。
     *
     * @param message 用户原始消息
     * @return true 表示问题复杂，需要在响应中追加结构化思考过程
     */
    private boolean isComplexQuestion(String message) {
        String lowerMessage = message.toLowerCase();
        String[] complexityIndicators = {
            "如何", "为什么", "怎样", "解释", "分析", "对比",
            "优缺点", "区别", "实现", "设计", "架构", "系统"
        };
        for (String indicator : complexityIndicators) {
            if (lowerMessage.contains(indicator)) return true;
        }
        return message.length() > 50;
    }

    public boolean testConnection() {
        try {
            String response = enhancedChat("你好", DEFAULT_MODEL, false);
            return response != null && !response.isEmpty();
        } catch (Exception e) {
            System.err.println("[EnhancedAIService] 连接测试失败: " + e.getMessage());
            return false;
        }
    }

    private void cleanupCache() {
        if (responseCache.size() > MAX_CACHE_SIZE) {
            responseCache.entrySet().removeIf(entry -> entry.getValue().isExpired());
        }
    }
}