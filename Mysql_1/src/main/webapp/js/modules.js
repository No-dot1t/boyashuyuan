/* 博雅书院功能模块 */

// ===== 全局常量 =====
const AI_DIAMOND_SVG = '<svg viewBox="0 0 40 40" width="18" height="18" fill="none" xmlns="http://www.w3.org/2000/svg"><defs><linearGradient id="bookGradJS" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="#ffffff"/><stop offset="50%" stop-color="#e8e8e8"/><stop offset="100%" stop-color="#d0d0d0"/></linearGradient><linearGradient id="starGradJS" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="#ffffff"/><stop offset="40%" stop-color="#fffde7"/><stop offset="100%" stop-color="#ffd54f"/></linearGradient><filter id="iconShadowJS"><feDropShadow dx="0" dy="1.5" stdDeviation="1" flood-color="#000" flood-opacity="0.2"/></filter><filter id="starGlowJS"><feGaussianBlur stdDeviation="1" result="blur"/><feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs><path d="M6 10C6 9.5 6.4 9 7 9H15V27H7C6.4 27 6 26.5 6 26V10Z" fill="url(#bookGradJS)" filter="url(#iconShadowJS)"/><path d="M6 10H15V12H6V10Z" fill="#b8b8b8" opacity="0.6"/><path d="M34 10C34 9.5 33.6 9 33 9H25V27H33C33.6 27 34 26.5 34 26V10Z" fill="url(#bookGradJS)" filter="url(#iconShadowJS)"/><path d="M25 10H34V12H25V10Z" fill="#b8b8b8" opacity="0.6"/><path d="M15 9V27" stroke="#c0c0c0" stroke-width="1.5"/><path d="M8 14H13" stroke="#b0b0b0" stroke-width="0.8"/><path d="M8 17H13" stroke="#b0b0b0" stroke-width="0.8"/><path d="M8 20H13" stroke="#b0b0b0" stroke-width="0.8"/><path d="M27 14H32" stroke="#b0b0b0" stroke-width="0.8"/><path d="M27 17H32" stroke="#b0b0b0" stroke-width="0.8"/><path d="M27 20H32" stroke="#b0b0b0" stroke-width="0.8"/><g filter="url(#starGlowJS)"><path d="M20 3L21.5 6.8L25 6L22.5 9L25 12L20 10.5L15 12L17.5 9L15 6L18.5 6.8L20 3Z" fill="url(#starGradJS)"/><ellipse cx="19" cy="7" rx="1" ry="0.8" fill="white" opacity="0.7"/></g></svg>';

// ========= AI助教系统（现代化重构） =========
function initAIAssistant() {
    console.log('[AI助手] initAIAssistant 开始...');
    const fab = document.getElementById('aiFab');
    const panel = document.getElementById('aiPanel');
    const overlay = document.getElementById('aiOverlay');
    const closeBtn = document.getElementById('aiCloseBtn');
    const sendBtn = document.getElementById('aiSendBtn');
    const input = document.getElementById('aiInput');
    const messages = document.getElementById('aiMessages');
    const welcome = document.getElementById('aiWelcome');
    const clearBtn = document.getElementById('aiClearBtn');
    const exportBtn = document.getElementById('aiExportBtn');
    const modelSelect = document.getElementById('aiModelSelect');
    const stats = document.getElementById('aiStats');
    const voiceBtn = document.getElementById('aiVoiceBtn');
    const fabBadge = document.getElementById('aiFabBadge');
    const settingsBtn = document.getElementById('aiModelSettingsBtn');

    if (!fab || !panel) {
        console.warn('[AI助手] 未找到AI面板元素');
        return;
    }

    const isAdmin = window.IS_ADMIN === true;
    let isOpen = false;
    let isLoading = false;
    let msgCount = 0;
    let lastMsgContent = '';

    // ===== API Key 存储（localStorage） =====
    const API_KEY_STORAGE_PREFIX = 'boya_ai_cfg_';
    function getStorageKey(modelPrefix) {
        var uid = window.USER_ID || 'anonymous';
        return API_KEY_STORAGE_PREFIX + uid + '_' + modelPrefix;
    }
    function getSavedApiKey(modelPrefix) {
        try {
            var data = localStorage.getItem(getStorageKey(modelPrefix));
            return data ? JSON.parse(data) : null;
        } catch (e) { return null; }
    }
    function saveApiKey(modelPrefix, cfg) {
        try {
            localStorage.setItem(getStorageKey(modelPrefix), JSON.stringify(cfg));
        } catch (e) { console.error('保存API Key失败:', e); }
    }
    function removeApiKey(modelPrefix) {
        try {
            localStorage.removeItem(getStorageKey(modelPrefix));
        } catch (e) { }
    }
    function updateSettingsBtnIndicator() {
        if (!settingsBtn) return;
        var hasAny = getSavedApiKey('deepseek') || getSavedApiKey('custom');
        if (hasAny) {
            settingsBtn.classList.add('has-key');
            settingsBtn.title = 'API Key 已设置';
        } else {
            settingsBtn.classList.remove('has-key');
            settingsBtn.title = 'API Key 设置';
        }
    }
    updateSettingsBtnIndicator();

    // ===== 获取当前模型需要用的自定义配置（仅非管理员） =====
    function getCurrentCustomConfig() {
        var model = modelSelect ? modelSelect.value : '';
        if (!model || isAdmin) return null;
        if (model === '__custom__') return getSavedApiKey('custom');
        if (model.indexOf('deepseek') === 0) return getSavedApiKey('deepseek');
        if (model.indexOf('moonshot') === 0) return getSavedApiKey('kimi');
        return null; // qwen 不需要
    }

    // ===== 打开 API Key 设置弹窗 =====
    function showApiKeyModal(modelPrefix, modelLabel, defaultUrl, defaultModel) {
        console.log('[AI助手] showApiKeyModal 被调用:', modelPrefix, modelLabel);

        // 获取所有 DOM 元素，每个都做 null 检查
        var overlay = document.getElementById('apiKeyModalOverlay');
        if (!overlay) { console.error('[AI助手] 未找到 apiKeyModalOverlay'); alert('弹窗加载失败，请刷新页面'); return; }
        var titleEl = document.getElementById('apiKeyModalTitle');
        var noticeEl = document.getElementById('apiKeyNotice');
        var noticeText = document.getElementById('apiKeyNoticeText');
        var urlInput = document.getElementById('apiKeyUrlInput');
        var keyInput = document.getElementById('apiKeyValueInput');
        var modelInput = document.getElementById('apiKeyModelInput');
        var modelField = document.getElementById('apiKeyModelField');
        var savedInfo = document.getElementById('apiKeySavedInfo');
        var presets = document.getElementById('apiKeyPresets');
        var clearBtn = document.getElementById('apiKeyClearBtn');
        var saveBtn = document.getElementById('apiKeySaveBtn');
        var cancelBtn = document.getElementById('apiKeyCancelBtn');
        var closeBtn = document.getElementById('apiKeyModalClose');
        var toggleVis = document.getElementById('apiKeyToggleVis');

        // 关键元素缺失直接报错
        if (!titleEl || !urlInput || !keyInput || !saveBtn || !cancelBtn) {
            console.error('[AI助手] 弹窗关键元素缺失');
            alert('弹窗组件加载不完整，请刷新页面');
            return;
        }

        var isCustom = modelPrefix === 'custom';

        // 设置标题
        titleEl.textContent = isCustom ? '🔧 自定义模型配置' : ('🔑 ' + modelLabel + ' API Key');

        // 设置提示
        if (noticeEl && noticeText) {
            if (isCustom) {
                noticeEl.style.display = 'flex';
                noticeText.textContent = '填入你想使用的任意 OpenAI 兼容 API 地址和 Key';
            } else {
                noticeEl.style.display = isAdmin ? 'none' : 'flex';
                noticeText.textContent = isAdmin ? '' : '此模型需要你填入自己的 API Key 才能使用';
            }
        }

        // 读取已保存的配置
        var saved = getSavedApiKey(modelPrefix);
        urlInput.value = (saved && saved.url) ? saved.url : (defaultUrl || '');
        keyInput.value = (saved && saved.key) ? saved.key : '';
        if (modelInput) {
            modelInput.value = (saved && saved.model) ? saved.model : (defaultModel || '');
        }

        // 自定义模型时显示额外字段
        if (modelField) modelField.style.display = isCustom ? 'block' : '';
        if (presets) presets.style.display = isCustom ? 'flex' : '';
        if (savedInfo) savedInfo.style.display = saved ? 'block' : 'none';
        if (clearBtn) clearBtn.style.display = saved ? '' : 'none';

        // 绑定预设
        var presetsList = document.querySelectorAll('.preset-chip');
        presetsList.forEach(function(chip) {
            chip.onclick = function() {
                urlInput.value = this.getAttribute('data-url') || '';
                if (modelInput) modelInput.value = this.getAttribute('data-model') || '';
            };
        });

        // === 核心：用 classList 控制显隐 ===
        overlay.classList.add('active');
        console.log('[AI助手] 弹窗已打开，active class=', overlay.classList.contains('active'));

        // 保存按钮
        saveBtn.onclick = function() {
            var url = urlInput.value.trim();
            var key = keyInput.value.trim();
            var model = modelInput ? modelInput.value.trim() : '';
            if (!key) { alert('API Key 不能为空'); return; }
            if (isCustom && !url) { alert('API 地址不能为空'); return; }
            if (isCustom && !model) { alert('模型名称不能为空'); return; }
            var cfg = {
                url: url || (defaultUrl || ''),
                key: key,
                model: model || (defaultModel || ''),
                label: isCustom ? '自定义模型' : modelLabel
            };
            saveApiKey(modelPrefix, cfg);
            overlay.classList.remove('active');
            // 保存成功后，切换到对应的模型选择
            if (isCustom && modelSelect) {
                modelSelect.value = '__custom__';
            } else if (modelSelect && modelPrefix === 'deepseek') {
                modelSelect.value = defaultModel || 'deepseek-chat';
            } else if (modelSelect && modelPrefix === 'kimi') {
                modelSelect.value = defaultModel || 'moonshot-v1-8k';
            }
            updateSettingsBtnIndicator();
            updateModelSelectorHighlight();
            console.log('[AI助手] API Key 已保存:', modelPrefix);
        };

        // 取消按钮
        cancelBtn.onclick = function() {
            overlay.classList.remove('active');
            // 如果当前模型需要 Key 但用户没有保存，切回 qwen
            var currentModel = modelSelect ? modelSelect.value : '';
            if (currentModel === '__custom__' && !getSavedApiKey('custom')) {
                modelSelect.value = 'qwen-turbo';
            }
            if (currentModel.indexOf('deepseek') === 0 && !getSavedApiKey('deepseek') && !isAdmin) {
                modelSelect.value = 'qwen-turbo';
            }
            if (currentModel.indexOf('moonshot') === 0 && !getSavedApiKey('kimi') && !isAdmin) {
                modelSelect.value = 'qwen-turbo';
            }
            console.log('[AI助手] 弹窗已关闭');
        };

        // 关闭按钮 (X)
        if (closeBtn) {
            closeBtn.onclick = function() { cancelBtn.click(); };
        }

        // 清除配置按钮
        if (clearBtn) {
            clearBtn.onclick = function() {
                if (confirm('确定清除已保存的 API Key 配置吗？')) {
                    removeApiKey(modelPrefix);
                    urlInput.value = defaultUrl || '';
                    keyInput.value = '';
                    if (modelInput) modelInput.value = defaultModel || '';
                    if (savedInfo) savedInfo.style.display = 'none';
                    clearBtn.style.display = 'none';
                    updateSettingsBtnIndicator();
                    updateModelSelectorHighlight();
                    if (modelSelect) modelSelect.value = 'qwen-turbo';
                }
            };
        }

        // 显示/隐藏 Key
        if (toggleVis) {
            toggleVis.onclick = function() {
                var t = keyInput.type;
                keyInput.type = t === 'password' ? 'text' : 'password';
                this.textContent = t === 'password' ? '🙈' : '👁';
            };
        }

        // 点击遮罩关闭
        overlay.onclick = function(e) {
            if (e.target === overlay) {
                cancelBtn.click();
            }
        };
    }

    // 更新模型选择器高亮
    function updateModelSelectorHighlight() {
        if (!modelSelect) return;
        var opts = modelSelect.options;
        for (var i = 0; i < opts.length; i++) {
            var v = opts[i].value;
            if (v === '__custom__') continue;
            if (v.indexOf('deepseek') === 0) {
                opts[i].textContent = getSavedApiKey('deepseek') ? '🔑 ' + opts[i].textContent.replace('🔑 ', '') : opts[i].textContent.replace('🔑 ', '');
            }
        }
    }

    // ===== 打开/关闭面板 =====
    function openPanel() {
        isOpen = true;
        panel.classList.add('open');
        overlay.classList.add('show');
        fabBadge.classList.remove('show');
        setTimeout(() => input.focus(), 400);
        messages.scrollTop = messages.scrollHeight;
    }

    function closePanel() {
        isOpen = false;
        panel.classList.remove('open');
        overlay.classList.remove('show');
    }

    fab.addEventListener('click', openPanel);
    closeBtn.addEventListener('click', closePanel);
    overlay.addEventListener('click', closePanel);

    // ESC 关闭
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && isOpen) closePanel();
    });

    // ===== 建议词点击 =====
    document.querySelectorAll('.ai-suggestion-chip').forEach(chip => {
        chip.addEventListener('click', () => {
            const text = chip.getAttribute('data-text');
            if (text) {
                input.value = text;
                autoResize();
                sendMessage();
            }
        });
    });

    // ===== 发送消息 =====
    async function sendMessage() {
        const text = input.value.trim();
        if (!text || isLoading) return;

        // 非管理员 + DeepSeek 模型 → 检查是否已保存 Key
        var model = modelSelect ? modelSelect.value : '';
        if (!isAdmin && model.indexOf('deepseek') === 0) {
            var saved = getSavedApiKey('deepseek');
            if (!saved || !saved.key) {
                showApiKeyModal('deepseek', 'DeepSeek', 'https://api.deepseek.com/chat/completions', model);
                return;
            }
        }
        if (model === '__custom__') {
            var savedCustom = getSavedApiKey('custom');
            if (!savedCustom || !savedCustom.key) {
                showApiKeyModal('custom', '自定义模型', 'https://api.openai.com/v1/chat/completions', 'gpt-3.5-turbo');
                return;
            }
        }
        if (!isAdmin && model.indexOf('moonshot') === 0) {
            var savedKimi = getSavedApiKey('kimi');
            if (!savedKimi || !savedKimi.key) {
                showApiKeyModal('kimi', 'Kimi', 'https://api.moonshot.cn/v1/chat/completions', model);
                return;
            }
        }

        // 隐藏欢迎页
        if (welcome) welcome.style.display = 'none';

        // 添加用户消息
        addMessage('user', text);
        input.value = '';
        autoResize();
        sendBtn.disabled = true;

        // 显示打字指示器
        isLoading = true;
        showTyping();

        try {
            const aiText = await fetchAI(text);
            hideTyping();
            // 模拟逐字输出
            await typeMessage(aiText);
        } catch (err) {
            hideTyping();
            addMessage('error', '出错了: ' + err.message);
        } finally {
            isLoading = false;
            sendBtn.disabled = false;
            input.focus();
        }
    }

    // ===== 添加消息 =====
    function addMessage(role, content, skipHistory) {
        const div = document.createElement('div');
        div.className = 'ai-msg ' + role;

        const now = new Date();
        const time = now.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });

        const avatarHtml = role === 'user'
            ? '<div class="ai-msg-avatar user-avatar">👤</div>'
            : '<div class="ai-msg-avatar bot-avatar">' + AI_DIAMOND_SVG + '</div>';

        const bubbleClass = role === 'error' ? 'ai-msg-bubble' : 'ai-msg-bubble';

        div.innerHTML = `
            ${role !== 'user' ? avatarHtml : ''}
            <div class="ai-msg-body">
                <div class="${bubbleClass}">${role === 'user' ? escapeHtml(content) : '<span class="ai-msg-plain">' + escapeHtml(content) + '</span>'}</div>
                <div class="ai-msg-time">${time}</div>
            </div>
            ${role === 'user' ? avatarHtml : ''}
        `;

        messages.appendChild(div);
        scrollBottom();

        if (!skipHistory) {
            msgCount++;
            stats.textContent = msgCount + ' 条消息';
        }

        return div;
    }

    // ===== 渐入渲染消息（带打字效果） =====
    async function typeMessage(text) {
        // 先创建消息容器
        const div = document.createElement('div');
        div.className = 'ai-msg bot';
        const now = new Date();
        const time = now.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });

        div.innerHTML = `
            <div class="ai-msg-avatar bot-avatar">${AI_DIAMOND_SVG}</div>
            <div class="ai-msg-body">
                <div class="ai-msg-bubble ai-type-target"></div>
                <div class="ai-msg-time">${time}</div>
            </div>
        `;
        messages.appendChild(div);
        scrollBottom();

        // 关键修复：用 querySelector 定位当前消息的气泡，避免 getElementById 拿到旧消息
        const bubble = div.querySelector('.ai-type-target');
        bubble.classList.remove('ai-type-target');
        const fullHtml = await renderMarkdown(text);

        // 逐字渲染
        await typeWriter(bubble, fullHtml);

        // 添加操作按钮
        addMsgActions(div, text);

        msgCount++;
        stats.textContent = msgCount + ' 条消息';
        lastMsgContent = text;
    }

    // ===== 打字机效果 =====
    async function typeWriter(container, html) {
        // 将 HTML 分解为 token：文本片段和 HTML 标签
        const tokens = tokenizeHtml(html);
        container.innerHTML = '';
        const cursor = document.createElement('span');
        cursor.className = 'ai-type-cursor';
        container.appendChild(cursor);

        let currentText = '';

        for (let i = 0; i < tokens.length; i++) {
            const token = tokens[i];
            if (token.type === 'tag') {
                currentText += token.value;
                container.innerHTML = currentText;
                container.appendChild(cursor);
            } else {
                // 逐字符输出文本
                for (let c = 0; c < token.value.length; c++) {
                    currentText += token.value[c];
                    container.innerHTML = currentText;
                    container.appendChild(cursor);
                    await sleep(15 + Math.random() * 15);
                }
            }
            scrollBottom();
        }

        // 移除光标
        cursor.remove();
    }

    // ===== HTML 分词 =====
    function tokenizeHtml(html) {
        const tokens = [];
        const tagRegex = /<[^>]*>/g;
        let lastIdx = 0;
        let match;

        while ((match = tagRegex.exec(html)) !== null) {
            if (match.index > lastIdx) {
                tokens.push({ type: 'text', value: html.slice(lastIdx, match.index) });
            }
            tokens.push({ type: 'tag', value: match[0] });
            lastIdx = tagRegex.lastIndex;
        }

        if (lastIdx < html.length) {
            tokens.push({ type: 'text', value: html.slice(lastIdx) });
        }

        return tokens;
    }

    // ===== 获取 AI 回复（支持自定义 API） =====
    async function fetchAI(text) {
        var model = modelSelect ? modelSelect.value : 'qwen-turbo';
        var contextPath = window.CONTEXT_PATH || '';

        var customCfg = getCurrentCustomConfig();
        // 实际发给后端的模型名：自定义模型用配置里的，系统模型用下拉框的
        var actualModel = (model === '__custom__' && customCfg) ? customCfg.model : model;

        if (model === '__custom__' && (!customCfg || !customCfg.model)) {
            throw new Error('请先配置自定义模型');
        }

        var body = 'message=' + encodeURIComponent(text) + '&model=' + encodeURIComponent(actualModel);

        // 附加自定义 API 配置
        if (customCfg) {
            body += '&custom_api_url=' + encodeURIComponent(customCfg.url || '');
            body += '&custom_api_key=' + encodeURIComponent(customCfg.key || '');
            if (customCfg.label) body += '&custom_provider=' + encodeURIComponent(customCfg.label);
        }

        var response = await fetch(contextPath + '/api/ai', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: body
        });
        if (!response.ok) throw new Error('HTTP错误: ' + response.status);
        var data = await response.json();
        if (data.success) return data.message;
        throw new Error(data.error || '服务暂不可用');
    }

    // ===== 打字指示器 =====
    function showTyping() {
        const div = document.createElement('div');
        div.className = 'ai-typing';
        div.id = 'aiTyping';
        div.innerHTML = `
            <div class="ai-msg-avatar bot-avatar">${AI_DIAMOND_SVG}</div>
            <div class="ai-typing-dots">
                <span class="ai-typing-dot"></span>
                <span class="ai-typing-dot"></span>
                <span class="ai-typing-dot"></span>
                <span class="ai-typing-label">思考中...</span>
            </div>
        `;
        messages.appendChild(div);
        scrollBottom();
    }

    function hideTyping() {
        const el = document.getElementById('aiTyping');
        if (el) el.remove();
    }

    // ===== Markdown 渲染 =====
    async function renderMarkdown(text) {
        if (!text) return '';
        if (typeof marked !== 'undefined') {
            try {
                // 预处理思考过程
                let processed = text;
                processed = processed.replace(/✨\s*思考：|🧠\s*分析：|🤔\s*推理：/g,
                    match => `</p><div class="ai-thinking-block">`);
                processed = processed.replace(/✅\s*结论：|📝\s*示例：|💡\s*建议：/g,
                    match => `</div><p><strong>${match}</strong>`);
                processed = processed.replace(/```(\w*)\n/g, (match, lang) => {
                    return `<div class="ai-code-header"><span class="ai-code-lang">${lang || 'code'}</span></div>\`\`\`${lang}\n`;
                });

                let html = await marked.parse(processed);
                const temp = document.createElement('div');
                temp.innerHTML = html;

                // 包装代码块
                temp.querySelectorAll('pre').forEach(pre => {
                    const code = pre.querySelector('code');
                    if (code) {
                        const lang = (code.className.match(/language-(\w+)/) || [])[1] || 'code';
                        const header = document.createElement('div');
                        header.className = 'ai-code-header';
                        header.innerHTML = `
                            <span class="ai-code-lang">${lang}</span>
                            <button class="ai-code-copy" onclick="aiCopyCode(this)">📋 复制</button>
                        `;
                        pre.parentNode.insertBefore(header, pre);
                        try { hljs.highlightElement(code); } catch (e) { }
                    }
                });

                // 表格样式
                temp.querySelectorAll('table').forEach(t => {
                    if (!t.closest('.ai-msg-bubble')) t.style.width = '100%';
                });

                return temp.innerHTML;
            } catch (e) {
                console.error('Markdown渲染错误:', e);
            }
        }
        return '<p>' + escapeHtml(text) + '</p>';
    }

    // ===== 消息操作按钮 =====
    function addMsgActions(msgDiv, content) {
        const actions = document.createElement('div');
        actions.className = 'ai-msg-actions always-show';
        actions.innerHTML = `
            <button class="ai-msg-action-btn" onclick="aiCopyMsg(this, '${escapeHtmlAttr(content)}')">📋 复制</button>
            <button class="ai-msg-action-btn" onclick="aiFeedback(this, 'positive')">👍 有帮助</button>
            <button class="ai-msg-action-btn" onclick="aiFeedback(this, 'negative')">👎 需改进</button>
        `;
        msgDiv.querySelector('.ai-msg-body').appendChild(actions);
    }

    // ===== 清空对话 =====
    function clearChat() {
        if (msgCount > 0 && !confirm('确定清空所有对话吗？')) return;
        messages.innerHTML = '';
        msgCount = 0;
        stats.textContent = '0 条消息';
        lastMsgContent = '';

        // 恢复欢迎页
        const welcomeClone = document.createElement('div');
        welcomeClone.className = 'ai-welcome';
        welcomeClone.id = 'aiWelcome';
        welcomeClone.innerHTML = `
            <div class="ai-welcome-icon">${AI_DIAMOND_SVG}</div>
            <div class="ai-welcome-title">你好，我是博雅小星</div>
            <div class="ai-welcome-sub">我是你的智能学习助手，可以帮你解答问题、编写代码、提供学习建议</div>
            <div class="ai-welcome-suggestions">
                <span class="ai-suggestion-chip" data-text="帮我推荐一些Java学习资源">📚 推荐学习资源</span>
                <span class="ai-suggestion-chip" data-text="Python和Java有什么区别">💡 语言对比</span>
                <span class="ai-suggestion-chip" data-text="用CSS写一个漂亮的按钮">🎨 写段代码</span>
                <span class="ai-suggestion-chip" data-text="解释一下什么是微服务架构">🔍 概念解释</span>
            </div>
        `;
        messages.appendChild(welcomeClone);
        document.querySelectorAll('.ai-suggestion-chip').forEach(chip => {
            chip.addEventListener('click', () => {
                const text = chip.getAttribute('data-text');
                if (text) { input.value = text; autoResize(); sendMessage(); }
            });
        });
        scrollBottom();
    }

    // ===== 导出对话 =====
    function exportChat() {
        const items = messages.querySelectorAll('.ai-msg:not(.ai-typing)');
        if (items.length === 0) return alert('暂无对话可导出');

        let md = '# 博雅小星 AI 对话记录\n\n';
        md += '导出时间: ' + new Date().toLocaleString() + '\n\n---\n\n';

        items.forEach(item => {
            const role = item.classList.contains('user') ? '👤 **你**' : '✦ **博雅小星**';
            const bubble = item.querySelector('.ai-msg-bubble');
            const text = bubble ? bubble.textContent.trim() : '';
            if (text) {
                md += `### ${role}\n${text}\n\n---\n\n`;
            }
        });

        const blob = new Blob([md], { type: 'text/markdown;charset=utf-8' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = `博雅小星对话_${new Date().toISOString().slice(0, 10)}.md`;
        link.click();
        URL.revokeObjectURL(link.href);
    }

    // ===== 输入框自适应 =====
    function autoResize() {
        input.style.height = 'auto';
        input.style.height = Math.min(input.scrollHeight, 120) + 'px';
    }

    function scrollBottom() {
        requestAnimationFrame(() => {
            messages.scrollTo({ top: messages.scrollHeight, behavior: 'smooth' });
        });
    }

    // ===== 输入事件 =====
    input.addEventListener('input', () => {
        autoResize();
        sendBtn.disabled = !input.value.trim();
    });

    input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });

    sendBtn.addEventListener('click', sendMessage);
    clearBtn.addEventListener('click', clearChat);
    exportBtn.addEventListener('click', exportChat);

    // ===== 语音输入 =====
    if (voiceBtn && ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window)) {
        const SR = window.SpeechRecognition || window.webkitSpeechRecognition;
        const recog = new SR();
        recog.lang = 'zh-CN';
        recog.interimResults = false;
        voiceBtn.addEventListener('click', () => {
            try {
                recog.start();
                voiceBtn.style.color = '#667eea';
                voiceBtn.textContent = '🔴';
            } catch (e) { console.warn(e); }
        });
        recog.onresult = (e) => {
            input.value = e.results[0][0].transcript;
            voiceBtn.textContent = '🎤';
            voiceBtn.style.color = '';
            autoResize();
            sendBtn.disabled = false;
        };
        recog.onerror = () => { voiceBtn.textContent = '🎤'; voiceBtn.style.color = ''; };
        recog.onend = () => { voiceBtn.textContent = '🎤'; voiceBtn.style.color = ''; };
    } else if (voiceBtn) {
        voiceBtn.style.display = 'none';
    }

    // ===== 模型选择变更 =====
    if (modelSelect) {
        modelSelect.addEventListener('change', function() {
            try {
                var v = this.value;
                console.log('[AI助手] 模型切换:', v);
                // 自定义模型：始终弹窗让用户查看/填写配置卡片
                if (v === '__custom__') {
                    showApiKeyModal('custom', '自定义模型', 'https://api.openai.com/v1/chat/completions', 'gpt-3.5-turbo');
                    return;
                }
                // DeepSeek 模型需要检查权限
                if (v.indexOf('deepseek') === 0 && !isAdmin) {
                    var saved = getSavedApiKey('deepseek');
                    if (!saved || !saved.key) {
                        showApiKeyModal('deepseek', 'DeepSeek', 'https://api.deepseek.com/chat/completions', v);
                        return;
                    }
                }
                // Kimi 也检查
                if (v.indexOf('moonshot') === 0 && !isAdmin) {
                    var savedKimi = getSavedApiKey('kimi');
                    if (!savedKimi || !savedKimi.key) {
                        showApiKeyModal('kimi', 'Kimi', 'https://api.moonshot.cn/v1/chat/completions', v);
                        return;
                    }
                }
                updateSettingsBtnIndicator();
            } catch (e) {
                console.error('[AI助手] 模型切换出错:', e);
                alert('模型切换失败: ' + e.message);
            }
        });
    }

    // ===== API Key 设置按钮（根据当前选择模型打开对应弹窗） =====
    if (settingsBtn) {
        settingsBtn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            var model = modelSelect ? modelSelect.value : 'qwen-turbo';
            if (model === '__custom__') {
                showApiKeyModal('custom', '自定义模型', 'https://api.openai.com/v1/chat/completions', 'gpt-3.5-turbo');
            } else if (model.indexOf('moonshot') === 0) {
                showApiKeyModal('kimi', 'Kimi', 'https://api.moonshot.cn/v1/chat/completions', model);
            } else if (model.indexOf('deepseek') === 0) {
                showApiKeyModal('deepseek', 'DeepSeek', 'https://api.deepseek.com/chat/completions', model);
            } else {
                // Qwen 等系统模型：默认打开 DeepSeek 配置入口
                showApiKeyModal('deepseek', 'DeepSeek', 'https://api.deepseek.com/chat/completions', 'deepseek-chat');
            }
        });
    }

    // 点击弹窗外关闭
    var apiKeyOverlay = document.getElementById('apiKeyModalOverlay');
    if (apiKeyOverlay) {
        apiKeyOverlay.addEventListener('click', function(e) {
            if (e.target === apiKeyOverlay) {
                apiKeyOverlay.classList.remove('active');
            }
        });
    }

    console.log('[AI助手] 现代化初始化完成 (admin=' + isAdmin + ')');
}

// ===== 全局函数 =====
function aiCopyMsg(btn, text) {
    navigator.clipboard.writeText(text).then(() => {
        btn.textContent = '✅ 已复制';
        setTimeout(() => btn.textContent = '📋 复制', 2000);
    });
}

function aiCopyCode(btn) {
    const header = btn.closest('.ai-code-header');
    let pre = header.nextElementSibling;
    while (pre && pre.tagName !== 'PRE') pre = pre.nextElementSibling;
    if (pre) {
        navigator.clipboard.writeText(pre.textContent).then(() => {
            btn.textContent = '✅ 已复制';
            setTimeout(() => btn.textContent = '📋 复制', 2000);
        });
    }
}

function aiFeedback(btn, type) {
    btn.classList.add('active');
    btn.textContent = type === 'positive' ? '✅ 已反馈' : '✅ 已记录';
    console.log('[AI反馈]', type);
}

// ===== 工具函数 =====
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function escapeHtmlAttr(text) {
    if (!text) return '';
    return text.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/'/g, '&#39;')
        .replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// ========= 搜索系统 =========
function initSearch() {
    const searchBtn = document.getElementById('searchBtn');
    const searchModal = document.getElementById('searchModal');
    const closeSearch = document.getElementById('closeSearch');
    const searchInput = document.getElementById('searchInput');
    const searchSubmit = document.getElementById('searchSubmit');
    const historyTags = document.getElementById('historyTags');
    const hotTags = document.getElementById('hotTags');

    if (!searchBtn || !searchModal) return;

    var currentType = 'all';
    var searchHistory = JSON.parse(localStorage.getItem('boya_search_history') || '[]');

    // 渲染搜索历史
    function renderHistory() {
        if (!historyTags || searchHistory.length === 0) return;
        historyTags.innerHTML = searchHistory.slice(0, 5).map(function(h) {
            return '<span class="history-tag" data-keyword="' + h + '">' + h + '</span>';
        }).join('');
        historyTags.querySelectorAll('.history-tag').forEach(function(tag) {
            tag.addEventListener('click', function() {
                var kw = this.getAttribute('data-keyword');
                if (searchInput) searchInput.value = kw;
                performSearch(kw, currentType);
            });
        });
    }
    renderHistory();

    // 加载热门搜索
    function loadHotSearch() {
        if (!hotTags) return;
        fetch((window.CONTEXT_PATH || '') + '/api/search?keyword=&type=hot')
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success && data.results) {
                    // 使用模拟热门关键词（后端无专门热门表，用最近搜索历史代替）
                }
            })
            .catch(function() {
                // 静默失败，保留默认热门词
            });
    }
    // 热门词保持静态，后续可接入 Redis 热搜榜
    // loadHotSearch();

    // 打开搜索
    searchBtn.addEventListener('click', () => {
        searchModal.style.display = 'flex';
        setTimeout(() => {
            searchModal.classList.add('show');
            if (searchInput) searchInput.focus();
        }, 10);
    });

    // 关闭搜索
    if (closeSearch) {
        closeSearch.addEventListener('click', () => {
            searchModal.classList.remove('show');
            setTimeout(() => {
                searchModal.style.display = 'none';
            }, 300);
        });
    }

    // 点击遮罩层关闭
    searchModal.addEventListener('click', (e) => {
        if (e.target === searchModal) {
            closeSearch.click();
        }
    });

    // Tab 切换
    document.querySelectorAll('.search-tab').forEach(function(tab) {
        tab.addEventListener('click', function() {
            document.querySelectorAll('.search-tab').forEach(function(t) { t.classList.remove('active'); });
            this.classList.add('active');
            currentType = this.getAttribute('data-type');
        });
    });

    // ===== 核心：执行搜索 =====
    function performSearch(query, type) {
        if (!query.trim()) return;

        // "论文"暂无独立数据表，映射到全局搜索
        if (type === 'papers') type = 'all';

        // 保存搜索历史
        if (searchHistory.indexOf(query) === -1) {
            searchHistory.unshift(query);
            if (searchHistory.length > 10) searchHistory.pop();
            localStorage.setItem('boya_search_history', JSON.stringify(searchHistory));
            renderHistory();
        }

        // 显示加载中
        console.log('[搜索] 查询:', query, '类型:', type);

        // 发起 AJAX 请求
        var ctx = window.CONTEXT_PATH || '';
        var url = ctx + '/api/search?keyword=' + encodeURIComponent(query) + '&type=' + encodeURIComponent(type);
        fetch(url)
            .then(function(response) {
                if (!response.ok) throw new Error('Network error');
                return response.json();
            })
            .then(function(data) {
                if (data.success) {
                    showSearchResults(data);
                } else {
                    alert('搜索失败：' + (data.error || '未知错误'));
                }
            })
            .catch(function(err) {
                console.error('[搜索] 请求失败:', err);
                alert('搜索请求失败，请稍后重试');
            });
    }

    // 展示搜索结果
    function showSearchResults(data) {
        var results = data.results || [];
        if (results.length === 0) {
            alert('未找到与 "' + data.keyword + '" 相关的结果');
            return;
        }

        var isAdmin = window.USER_ROLE === 'admin';
        var typeIcons = {
            course: '📚', teacher: '👨‍🏫', book: '📖', lecture: '🎤', alumni: '🎓',
            paper: '📄',
            user: '👤', booktype: '📂', notification: '📢', review: '✅'
        };

        var html = '<div class="search-results-container"><h3 style="color:var(--primary-holo,#0ff);margin-bottom:16px">' +
            '🔍 搜索 "' + data.keyword + '" 共找到 ' + data.total + ' 条结果';
        if (data.isAdmin) {
            html += ' <span style="font-size:12px;color:var(--accent-primary,#f90);margin-left:8px">[含后台数据]</span>';
        }
        html += '</h3>';

        results.forEach(function(item) {
            var icon = typeIcons[item.type] || '📌';
            var isAdminItem = item.adminOnly === true;
            var borderColor = isAdminItem ? 'var(--accent-primary, #f90)' : 'var(--primary-holo, #0ff)';
            var adminBadge = isAdminItem ? '<span class="search-admin-badge">🔒 管理</span>' : '';

            html += '<div class="search-result-item" data-url="' + item.url + '" data-id="' + item.id + '" ' +
                'style="padding:12px;margin-bottom:8px;background:rgba(255,255,255,0.05);border-radius:8px;' +
                'cursor:pointer;border-left:3px solid ' + borderColor + ';transition:all .2s"' +
                'onmouseover="this.style.background=\'rgba(0,242,255,0.1)\'" ' +
                'onmouseout="this.style.background=\'rgba(255,255,255,0.05)\'">' +
                '<span style="margin-right:8px;font-size:14px">[' + item.typeLabel + ']</span>' +
                '<span style="font-weight:600;color:#fff">' + icon + ' ' + escapeHtml(item.title || '') + '</span>' +
                adminBadge +
                '<br><span style="font-size:12px;color:#888;margin-left:4em">' + escapeHtml(item.subtitle || '') + '</span>' +
                '</div>';
        });

        html += '<div style="text-align:center;margin-top:12px">' +
            '<button id="searchResultCloseBtn" ' +
            'style="background:transparent;border:1px solid var(--border-glow,#333);color:#aaa;padding:6px 20px;' +
            'border-radius:6px;cursor:pointer">关闭</button></div>' +
            '</div>';

        // 使用独立的结果容器，不再替换整个弹窗内容
        var modalContent = document.querySelector('.search-modal-content');
        if (!modalContent) return;

        // 保存原始内容引用
        var originalHTML = modalContent.innerHTML;
        modalContent.innerHTML = html;

        // 绑定结果项点击事件
        modalContent.querySelectorAll('.search-result-item').forEach(function(item) {
            item.addEventListener('click', function() {
                var url = this.getAttribute('data-url');
                restoreAndClose();
                if (url) {
                    var iframe = document.getElementById('academicFrame');
                    if (iframe) { iframe.src = url; }
                }
            });
        });

        // 返回按钮
        var backBtn = document.createElement('button');
        backBtn.textContent = '← 返回';
        backBtn.style.cssText = 'background:transparent;border:none;color:var(--primary-holo,#0ff);cursor:pointer;' +
            'padding:4px 0;margin-bottom:10px;font-size:13px';
        backBtn.addEventListener('click', function() {
            modalContent.innerHTML = originalHTML;
        });
        modalContent.querySelector('h3').before(backBtn);

        // 关闭按钮：通过 ID 绑定
        var closeBtn = document.getElementById('searchResultCloseBtn');
        if (closeBtn) {
            closeBtn.addEventListener('click', restoreAndClose);
        }

        // 统一的恢复并关闭函数
        function restoreAndClose() {
            if (modalContent) {
                modalContent.innerHTML = originalHTML;
            }
            searchModal.classList.remove('show');
            setTimeout(function() {
                searchModal.style.display = 'none';
            }, 300);
        }

        // 覆盖关闭按钮行为
        closeSearch.onclick = restoreAndClose;
        closeSearch.click = restoreAndClose;
    }

    // 提交按钮
    if (searchSubmit) {
        searchSubmit.addEventListener('click', () => {
            if (searchInput) {
                performSearch(searchInput.value.trim(), currentType);
            }
        });
    }

    // 回车提交
    if (searchInput) {
        searchInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                performSearch(searchInput.value.trim(), currentType);
            }
        });
        // 实时搜索建议（防抖 350ms）
        var searchDebounceTimer = null;
        searchInput.addEventListener('input', function() {
            var query = this.value.trim();
            if (query.length < 2) return;
            clearTimeout(searchDebounceTimer);
            searchDebounceTimer = setTimeout(function() {
                fetchSuggestions(query, currentType);
            }, 350);
        });
    }
}

// ===== 搜索建议 =====
function fetchSuggestions(query, type) {
    if (!query || query.length < 2) return;
    if (type === 'papers') type = 'all';
    var ctx = window.CONTEXT_PATH || '';
    var isAdmin = window.USER_ROLE === 'admin';
    fetch(ctx + '/api/search?keyword=' + encodeURIComponent(query) + '&type=' + encodeURIComponent(type || 'all') + '&limit=5')
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (!data.success || !data.results || data.results.length === 0) return;
            // 在搜索框下方展示建议列表
            var container = document.querySelector('.search-suggestions');
            if (!container) {
                container = document.createElement('div');
                container.className = 'search-suggestions';
                var inputContainer = document.querySelector('.search-input-container');
                if (inputContainer) inputContainer.appendChild(container);
            }
            container.innerHTML = data.results.map(function(item) {
                var isAdminItem = item.adminOnly === true;
                var icon = isAdminItem ? '🔒' : '🔍';
                var cls = isAdminItem ? ' search-suggestion-item search-suggestion-admin' : 'search-suggestion-item';
                return '<div class="' + cls + '" data-url="' + (item.url || '') + '">' +
                    '<span class="suggestion-icon">' + icon + '</span>' +
                    '<span class="suggestion-title">' + escapeHtml(item.title || '') + '</span>' +
                    '<span class="suggestion-sub">' + escapeHtml(item.subtitle || '') + '</span>' +
                    '</div>';
            }).join('');
            container.style.display = 'block';
            // 点击建议跳转
            container.querySelectorAll('.search-suggestion-item').forEach(function(item) {
                item.addEventListener('click', function() {
                    var url = this.getAttribute('data-url');
                    var closeBtn = document.getElementById('closeSearch');
                    if (closeBtn && closeBtn.click) closeBtn.click();
                    if (url) {
                        var iframe = document.getElementById('academicFrame');
                        if (iframe) iframe.src = url;
                    }
                });
            });
        })
        .catch(function() {});
}

// ========= 通知系统 v3.0（桌面通知 + 音效 + 动画 + 分页） =========
function initNotifications() {
    const notificationBtn = document.getElementById('notificationBtn');
    const notificationPanel = document.getElementById('notificationPanel');
    const closeNotifications = document.getElementById('closeNotifications');
    const notificationBadge = document.getElementById('notificationBadge');
    const notificationList = document.getElementById('notificationList');
    const markAllReadBtn = document.getElementById('markAllReadBtn');
    const clearReadBtn = document.getElementById('clearReadBtn');
    const notifCount = document.getElementById('notifCount');
    const loadMoreBtn = document.getElementById('loadMoreBtn');
    const notificationFooter = document.getElementById('notificationFooter');
    const sendMessageBtn = document.getElementById('sendMessageBtn');
    const chatContainer = document.getElementById('chatContainer');
    const chatSidebar = document.getElementById('chatSidebar');
    const chatContactList = document.getElementById('chatContactList');
    const chatMain = document.getElementById('chatMain');
    const chatMessages = document.getElementById('chatMessages');
    const chatInput = document.getElementById('chatInput');
    const chatHeader = document.getElementById('chatHeader');
    const notificationDetailModal = document.getElementById('notificationDetailModal');
    const newChatBtn = document.getElementById('newChatBtn');
    const chatSearchCancel = document.getElementById('chatSearchCancel');
    const chatSidebarSearch = document.getElementById('chatSidebarSearch');
    const chatSidebarUsers = document.getElementById('chatSidebarUsers');
    const chatSidebarTitle = document.getElementById('chatSidebarTitle');
    const userSearchInput = document.getElementById('userSearchInput');
    const userList = document.getElementById('userList');

    if (!notificationBtn || !notificationPanel) return;

    let pollTimer = null;
    let isPanelOpen = false;
    let currentOffset = 0;
    const PAGE_SIZE = 50;
    let loadedIds = {}; // 去重
    let lastUnreadCount = -1; // 记录上次未读数，用于检测新通知
    let bellAnimTimer = null;
    let currentChatUserId = null;
    let currentChatUserName = null;
    let chatPollTimer = null;
    let lastMessageTime = null; // 上次收到消息的时间戳，用于轮询
    const currentUserId = (window._currentUserInfo && window._currentUserInfo.id) || "";

    // ═══════════════════════════════════════════════════════════
    // 1. 桌面通知（Notification API）
    // ═══════════════════════════════════════════════════════════
    function requestDesktopPermission() {
        if (!('Notification' in window)) return;
        if (Notification.permission === 'default') {
            Notification.requestPermission();
        }
    }

    function sendDesktopNotification(title, body) {
        if (!('Notification' in window)) return;
        if (Notification.permission !== 'granted') return;
        // 页面已聚焦时不弹桌面通知
        if (!document.hidden) return;
        try {
            var n = new Notification('博雅书院 - ' + title, {
                body: body,
                icon: '/favicon.ico'
            });
            setTimeout(function () { n.close(); }, 5000);
            n.addEventListener('click', function () {
                window.focus();
                this.close();
                // 打开通知面板
                isPanelOpen = true;
                notificationPanel.classList.add('show');
                loadNotifications();
            });
        } catch (e) { }
    }

    // ═══════════════════════════════════════════════════════════
    // 2. 通知音效（Web Audio API，无需音频文件）
    // ═══════════════════════════════════════════════════════════
    var _audioCtx = null;
    function playNotifSound() {
        try {
            if (!_audioCtx) _audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            if (_audioCtx.state === 'suspended') _audioCtx.resume();
            var osc = _audioCtx.createOscillator();
            var gain = _audioCtx.createGain();
            osc.connect(gain);
            gain.connect(_audioCtx.destination);
            osc.type = 'sine';
            osc.frequency.setValueAtTime(880, _audioCtx.currentTime); // A5
            osc.frequency.setValueAtTime(1108, _audioCtx.currentTime + 0.1); // C#6
            gain.gain.setValueAtTime(0.15, _audioCtx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, _audioCtx.currentTime + 0.3);
            osc.start(_audioCtx.currentTime);
            osc.stop(_audioCtx.currentTime + 0.3);
        } catch (e) { /* 静默降级 */ }
    }

    // ═══════════════════════════════════════════════════════════
    // 3. 铃铛动画
    // ═══════════════════════════════════════════════════════════
    function triggerBellAnimation() {
        if (!notificationBtn) return;
        notificationBtn.classList.add('bell-shake');
        if (bellAnimTimer) clearTimeout(bellAnimTimer);
        bellAnimTimer = setTimeout(function () {
            notificationBtn.classList.remove('bell-shake');
            bellAnimTimer = null;
        }, 1000);
    }

    // ═══════════════════════════════════════════════════════════
    // 4. 加载通知列表（带分页）
    // ═══════════════════════════════════════════════════════════
    function loadNotifications(reset) {
        if (reset === undefined) reset = true;
        if (reset) { currentOffset = 0; loadedIds = {}; }
        // 请求前显示加载状态
        if (reset && notificationList) {
            notificationList.innerHTML = '<div class="notif-empty"><div class="empty-icon">⏳</div><div class="empty-text">加载中...</div></div>';
        }
        fetch(getCtx() + '/api/userNotifications?action=list&offset=' + currentOffset + '&limit=' + PAGE_SIZE)
            .then(function (r) {
                if (!r.ok) {
                    throw new Error('HTTP error ' + r.status);
                }
                return r.json();
            })
            .then(function (data) {
                if (!data.success) {
                    // 显示错误信息而不是卡在"加载中"
                    if (notificationList) {
                        notificationList.innerHTML = '<div class="notif-empty"><div class="empty-icon">❌</div><div class="empty-text">' + escapeHtml(data.message || '加载失败，请稍后重试') + '</div></div>';
                    }
                    return;
                }
                var items = data.data || [];
                var hasMore = data.hasMore || false;

                // 去重
                var newItems = [];
                items.forEach(function (n) {
                    if (!loadedIds[n.id]) {
                        loadedIds[n.id] = true;
                        newItems.push(n);
                    }
                });

                if (reset) {
                    renderNotifications(newItems);
                } else {
                    appendNotifications(newItems);
                }
                currentOffset += items.length;
                updateBadgeFromDOM();

                // 检测是否有新通知
                if (items.length > 0) checkNewNotifications(items);

                // 分页按钮
                if (notificationFooter) {
                    notificationFooter.style.display = hasMore ? 'block' : 'none';
                }
            })
            .catch(function (err) {
                // 网络错误等，显示友好提示
                if (notificationList) {
                    notificationList.innerHTML = '<div class="notif-empty"><div class="empty-icon">🌐</div><div class="empty-text">网络错误，无法加载通知</div></div>';
                }
            });
    }

    // ═══════════════════════════════════════════════════════════
    // 检测新通知 → 触发桌面通知 + 音效 + 动画
    // ═══════════════════════════════════════════════════════════
    function checkNewNotifications(items) {
        var currentUnread = 0;
        items.forEach(function (n) { if (!n.isRead) currentUnread++; });
        if (lastUnreadCount >= 0 && currentUnread > lastUnreadCount) {
            // 找到新通知
            playNotifSound();
            triggerBellAnimation();
            var newestTitle = items[0].title;
            sendDesktopNotification(newestTitle, items[0].content || '有一条新通知');
            showToast('🔔 新通知: ' + newestTitle);
        }
        lastUnreadCount = currentUnread;
    }

    // ═══════════════════════════════════════════════════════════
    // 渲染通知列表（首次/重置）
    // ═══════════════════════════════════════════════════════════
    function renderNotifications(items) {
        if (!notificationList) return;
        if (!items || items.length === 0) {
            notificationList.innerHTML = '<div class="notif-empty">'
                + '<div class="empty-icon">🔔</div>'
                + '<div class="empty-text">暂无通知</div></div>';
            if (notifCount) notifCount.textContent = '0 条通知';
            return;
        }
        notificationList.innerHTML = buildNotifHTML(items);
        bindNotifEvents();
        updateNotifCountUI();
    }

    // ═══════════════════════════════════════════════════════════
    // 追加通知（分页加载更多）
    // ═══════════════════════════════════════════════════════════
    function appendNotifications(items) {
        if (!items || items.length === 0) return;
        var html = buildNotifHTML(items);
        notificationList.insertAdjacentHTML('beforeend', html);
        bindNotifEvents();
        updateNotifCountUI();
    }

    // ═══════════════════════════════════════════════════════════
    // 构建通知 HTML — v2 升级版
    // ═══════════════════════════════════════════════════════════
    function buildNotifHTML(items) {
        var html = '';
        items.forEach(function (n, idx) {
            var type = n.type || 'info';
            var iconMap = { success: '✅', warning: '⚠️', error: '❌', info: '📚', system: '📢' };
            var icon = iconMap[type] || '📢';
            var typeLabel = { success: '成功', warning: '警告', error: '错误', info: '信息', system: '公告' };
            var isUnread = !n.isRead;
            var timeStr = formatTimeAgo(n.time);
            var animDelay = (idx < 10 ? (idx * 0.04) : 0) + 's';
            html += '<div class="notif-item' + (isUnread ? ' unread' : '') + '"'
                + ' data-id="' + n.id + '" data-type="' + escapeHtml(type) + '" data-read="' + (n.isRead ? '1' : '0') + '"'
                + ' data-title="' + escapeHtml(n.title || '') + '" data-content="' + escapeHtml(n.content || '') + '"'
                + ' data-time="' + escapeHtml(n.time || '') + '" data-type-label="' + typeLabel[type] + '"'
                + ' style="animation-delay:' + animDelay + '">';
            html += '  <div class="notif-item-icon">' + icon + '</div>';
            html += '  <div class="notif-item-body">';
            html += '    <div class="notif-item-title">' + escapeHtml(n.title) + '</div>';
            html += '    <div class="notif-item-text">' + escapeHtml(n.content) + '</div>';
            html += '    <div class="notif-item-meta">';
            html += '      <span class="notif-item-time">' + timeStr + '</span>';
            html += '      <span class="notif-item-type" data-type-badge="' + type + '">' + typeLabel[type] + '</span>';
            html += '      <button class="notif-item-detail" data-id="' + n.id + '" title="查看详情">👁</button>';
            html += '      <button class="notif-item-del" data-id="' + n.id + '" title="删除">✕</button>';
            html += '    </div>';
            html += '  </div>';
            html += '</div>';
        });
        return html;
    }

    // ═══════════════════════════════════════════════════════════
    // 绑定通知项事件
    // ═══════════════════════════════════════════════════════════
    function bindNotifEvents() {
        if (!notificationList) return;
        var items = notificationList.querySelectorAll('.notif-item:not(.bound)');
        items.forEach(function (item) {
            item.classList.add('bound');
            // 点击已读
            item.addEventListener('click', function (e) {
                if (e.target.closest('.notif-item-del') || e.target.closest('.notif-item-detail')) return;
                var id = this.getAttribute('data-id');
                var isRead = this.getAttribute('data-read') === '1';
                if (!isRead) markAsRead(id, this);
            });
            // 查看详情按钮
            var detailBtn = item.querySelector('.notif-item-detail');
            if (detailBtn) {
                detailBtn.addEventListener('click', function (e) {
                    e.stopPropagation();
                    var itemEl = this.closest('.notif-item');
                    showNotificationDetail(itemEl);
                });
            }
            // 删除按钮
            var delBtn = item.querySelector('.notif-item-del');
            if (delBtn) {
                delBtn.addEventListener('click', function (e) {
                    e.stopPropagation();
                    var id = this.getAttribute('data-id');
                    deleteNotification(id, this);
                });
            }
        });
    }

    // ═══════════════════════════════════════════════════════════
    // 显示通知详情
    // ═══════════════════════════════════════════════════════════
    function showNotificationDetail(item) {
        if (!notificationDetailModal) return;
        var title = item.getAttribute('data-title');
        var content = item.getAttribute('data-content');
        var time = item.getAttribute('data-time');
        var typeLabel = item.getAttribute('data-type-label');
        var type = item.getAttribute('data-type');

        document.getElementById('detailTitle').textContent = title || '通知详情';
        document.getElementById('detailContent').textContent = content || '暂无内容';

        var typeColors = { success: '#10b981', warning: '#f59e0b', error: '#ef4444', info: '#3b82f6', system: '#8b5cf6' };
        document.getElementById('detailType').innerHTML = '<span style="color:' + (typeColors[type] || '#3b82f6') + '">📌 ' + (typeLabel || '信息') + '</span>';

        document.getElementById('detailMeta').innerHTML = '<p>🕐 ' + formatTimeAgo(time) + '</p>';

        notificationDetailModal.style.display = 'block';
        document.body.style.overflow = 'hidden';
    }

    // ═══════════════════════════════════════════════════════════
    // 关闭详情弹窗
    // ═══════════════════════════════════════════════════════════
    function closeDetailModal() {
        if (!notificationDetailModal) return;
        notificationDetailModal.style.display = 'none';
        document.body.style.overflow = '';
    }

    // ═══════════════════════════════════════════════════════════
    // 切换发起新对话（侧栏内联搜索）
    // ═══════════════════════════════════════════════════════════
    function toggleNewChat() {
        if (!chatSidebarSearch || !chatSidebarUsers) return;
        var isSearch = chatSidebarSearch.style.display !== 'none';
        if (isSearch) {
            // 关闭搜索，恢复对话列表
            exitNewChatMode();
        } else {
            // 打开搜索
            enterNewChatMode();
        }
    }

    function enterNewChatMode() {
        if (!chatSidebarSearch || !chatSidebarUsers) return;
        chatSidebarTitle.textContent = '新对话';
        chatSidebarSearch.style.display = 'block';
        chatSidebarUsers.style.display = 'block';
        chatContactList.style.display = 'none';
        if (newChatBtn) newChatBtn.style.display = 'none';
        if (chatSearchCancel) chatSearchCancel.style.display = 'inline-block';
        userSearchInput.value = '';
        userSearchInput.focus();
        loadUserList();
    }

    function exitNewChatMode() {
        if (!chatSidebarSearch || !chatSidebarUsers) return;
        chatSidebarTitle.textContent = '私信列表';
        chatSidebarSearch.style.display = 'none';
        chatSidebarUsers.style.display = 'none';
        chatContactList.style.display = '';
        if (newChatBtn) newChatBtn.style.display = '';
        if (chatSearchCancel) chatSearchCancel.style.display = 'none';
        userSearchInput.value = '';
        loadConversations();
    }

    // ═══════════════════════════════════════════════════════════
    // 加载用户列表
    // ═══════════════════════════════════════════════════════════
    function loadUserList() {
        fetch(getCtx() + '/api/users?action=list')
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (!data.success || !data.data) {
                    userList.innerHTML = '<div class="notif-empty">暂无用户</div>';
                    return;
                }
                var filtered = data.data.filter(function (user) {
                    return user.id !== currentUserId;
                });
                if (filtered.length === 0) {
                    userList.innerHTML = '<div class="notif-empty">没有其他用户</div>';
                    return;
                }
                userList.innerHTML = filtered.map(function (user) {
                    var name = user.nickname || user.username || '未知用户';
                    var avatarUrl = user.avatar || '';
                    var avatarHtml = renderChatAvatar(avatarUrl, name);
                    return '<div class="user-item" data-user-id="' + escapeHtml(user.id) + '" data-user-name="' + escapeHtml(name) + '">' +
                        avatarHtml +
                        '<div class="user-info">' +
                        '<div class="user-name">' + escapeHtml(name) + '</div>' +
                        '<div class="user-role">' + (user.role === 'admin' ? '管理员' : '用户') + '</div>' +
                        '</div>' +
                        '<span class="user-check">›</span>' +
                        '</div>';
                }).join('');
            })
            .catch(function () {
                userList.innerHTML = '<div class="notif-empty">加载失败</div>';
            });
    }

    // ═══════════════════════════════════════════════════════════
    // 搜索用户（前端过滤）
    // ═══════════════════════════════════════════════════════════
    function searchUsers() {
        var keyword = userSearchInput.value.toLowerCase().trim();
        var items = userList.querySelectorAll('.user-item');
        items.forEach(function (item) {
            var name = item.getAttribute('data-user-name').toLowerCase();
            item.style.display = name.includes(keyword) ? 'flex' : 'none';
        });
    }

    // ═══════════════════════════════════════════════════════════
    // 选择用户发起对话（侧栏内联）
    // ═══════════════════════════════════════════════════════════
    function selectUserForChat(userId, userName) {
        // 退出搜索模式，恢复界面
        if (!chatSidebarSearch || !chatSidebarUsers) return;
        chatSidebarTitle.textContent = '私信列表';
        chatSidebarSearch.style.display = 'none';
        chatSidebarUsers.style.display = 'none';
        chatContactList.style.display = '';
        if (newChatBtn) newChatBtn.style.display = '';
        if (chatSearchCancel) chatSearchCancel.style.display = 'none';
        userSearchInput.value = '';
        // 直接打开聊天（不重新加载对话列表，由 selectChatContact 完成后刷新）
        selectChatContact(userId, userName);
        loadConversations();
    }

    // ═══════════════════════════════════════════════════════════
    // 更新计数 UI
    // ═══════════════════════════════════════════════════════════
    function updateNotifCountUI() {
        if (!notifCount || !notificationList) return;
        var total = notificationList.querySelectorAll('.notif-item').length;
        var unread = notificationList.querySelectorAll('.notif-item.unread').length;
        notifCount.textContent = total + ' 条通知（' + unread + ' 条未读）';
    }

    // ═══════════════════════════════════════════════════════════
    // 标记单条已读
    // ═══════════════════════════════════════════════════════════
    function markAsRead(notificationId, el) {
        fetch(getCtx() + '/api/userNotifications', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action: 'markRead', notificationId: notificationId })
        })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (data.success && el) {
                    el.classList.remove('unread');
                    el.setAttribute('data-read', '1');
                    updateBadgeFromDOM();
                }
            })
            .catch(function () { });
    }

    // ═══════════════════════════════════════════════════════════
    // 一键全部已读
    // ═══════════════════════════════════════════════════════════
    function markAllRead() {
        fetch(getCtx() + '/api/userNotifications', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action: 'markAllRead' })
        })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (data.success) {
                    var items = notificationList.querySelectorAll('.notif-item.unread');
                    items.forEach(function (item) { item.classList.remove('unread'); item.setAttribute('data-read', '1'); });
                    updateBadgeFromDOM();
                    showToast('✅ 已全部标记为已读');
                }
            })
            .catch(function () { });
    }

    // ═══════════════════════════════════════════════════════════
    // 删除单条通知
    // ═══════════════════════════════════════════════════════════
    function deleteNotification(notificationId, btn) {
        fetch(getCtx() + '/api/userNotifications', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action: 'delete', notificationId: notificationId })
        })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (data.success) {
                    var item = btn.closest('.notif-item');
                    if (item) {
                        item.style.opacity = '0';
                        item.style.transform = 'translateX(30px)';
                        setTimeout(function () { item.remove(); updateBadgeFromDOM(); }, 300);
                    }
                    showToast('🗑️ 通知已删除');
                }
            })
            .catch(function () { });
    }

    // ═══════════════════════════════════════════════════════════
    // 清除所有已读通知
    // ═══════════════════════════════════════════════════════════
    function clearRead() {
        fetch(getCtx() + '/api/userNotifications', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action: 'deleteRead' })
        })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (data.success) {
                    var readItems = notificationList.querySelectorAll('.notif-item[data-read="1"]');
                    readItems.forEach(function (item) {
                        item.style.opacity = '0';
                        item.style.transform = 'translateX(30px)';
                        setTimeout(function () { item.remove(); }, 300);
                    });
                    updateBadgeFromDOM();
                    showToast('🗑️ 已清除已读通知');
                }
            })
            .catch(function () { });
    }

    // ═══════════════════════════════════════════════════════════
    // 角标工具
    // ═══════════════════════════════════════════════════════════
    function updateBadgeFromList(items) {
        var count = 0;
        if (items) { items.forEach(function (n) { if (!n.isRead) count++; }); }
        updateNotificationBadge(count);
    }

    function updateBadgeFromDOM() {
        var count = notificationList ? notificationList.querySelectorAll('.notif-item.unread').length : 0;
        updateNotificationBadge(count);
        updateNotifCountUI();
    }

    function updateNotificationBadge(count) {
        if (notificationBadge) {
            if (count > 0) {
                notificationBadge.textContent = count;
                notificationBadge.style.display = 'flex';
            } else {
                notificationBadge.style.display = 'none';
            }
        }
    }

    // ═══════════════════════════════════════════════════════════
    // 工具函数
    // ═══════════════════════════════════════════════════════════
    function formatTimeAgo(timeStr) {
        if (!timeStr) return '';
        try {
            var now = new Date();
            var t = new Date(timeStr.replace(/-/g, '/'));
            var diff = (now - t) / 1000;
            if (diff < 60) return '刚刚';
            if (diff < 3600) return Math.floor(diff / 60) + '分钟前';
            if (diff < 86400) return Math.floor(diff / 3600) + '小时前';
            if (diff < 2592000) return Math.floor(diff / 86400) + '天前';
            return timeStr.substring(0, 10);
        } catch (e) { return timeStr; }
    }

    function escapeHtml(s) {
        if (s == null) return '';
        return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    function getCtx() { return window.CONTEXT_PATH || ''; }

    var toastIsLight = null;
    function showToast(msg) {
        if (toastIsLight === null) {
            toastIsLight = (document.documentElement.getAttribute('data-theme')||'').indexOf('-light')>-1;
        }
        var isLight = toastIsLight;
        var t = document.createElement('div');
        t.textContent = msg;
        Object.assign(t.style, {
            position: 'fixed', bottom: '80px', left: '50%', transform: 'translateX(-50%)',
            background: isLight ? 'rgba(238,233,222,.96)' : 'rgba(12,16,28,.92)',
            color: isLight ? '#3d3929' : 'rgba(255,255,255,.8)',
            border: isLight ? '1px solid rgba(37,99,235,.12)' : '1px solid rgba(255,255,255,.06)',
            boxShadow: isLight ? '0 4px 20px rgba(139,119,80,.12)' : 'none',
            padding: '8px 20px', borderRadius: '10px', fontSize: '0.78rem',
            zIndex: '10001', transition: 'opacity 0.3s', pointerEvents: 'none'
        });
        document.body.appendChild(t);
        setTimeout(function () { t.style.opacity = '0'; setTimeout(function () { t.remove(); }, 300); }, 2000);
    }

    // ═══════════════════════════════════════════════════════════
    // 事件绑定
    // ═══════════════════════════════════════════════════════════

    requestDesktopPermission(); // 页面加载时请求通知权限

    // 打开面板
    notificationBtn.addEventListener('click', function (e) {
        e.stopPropagation();
        isPanelOpen = true;
        notificationPanel.classList.add('show');
        loadNotifications(true);
        // 启动轮询（每30秒检查新通知）
        if (pollTimer) clearInterval(pollTimer);
        pollTimer = setInterval(function () {
            loadNotifications(true);
        }, 30000);
    });

    // 关闭面板
    function closePanel() {
        isPanelOpen = false;
        notificationPanel.classList.remove('show');
        if (pollTimer) { clearInterval(pollTimer); pollTimer = null; }
        stopChatPolling();
    }
    if (closeNotifications) closeNotifications.addEventListener('click', closePanel);

    // 点击外部关闭
    document.addEventListener('click', function (e) {
        if (isPanelOpen && !notificationPanel.contains(e.target) && e.target !== notificationBtn) {
            closePanel();
        }
    });

    // 一键已读
    if (markAllReadBtn) markAllReadBtn.addEventListener('click', markAllRead);

    // 清除已读
    if (clearReadBtn) clearReadBtn.addEventListener('click', clearRead);

    // 加载更多
    if (loadMoreBtn) {
        loadMoreBtn.addEventListener('click', function () {
            this.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 加载中...';
            loadNotifications(false);
        });
    }

    // Tab 切换（通知/私信）
    var tabs = notificationPanel.querySelectorAll('.notif-tab');
    tabs.forEach(function (tab) {
        tab.addEventListener('click', function () {
            tabs.forEach(function (t) { t.classList.remove('active'); });
            this.classList.add('active');
            var tabType = this.getAttribute('data-tab');

            if (tabType === 'notifications') {
                notificationList.style.display = 'block';
                chatContainer.style.display = 'none';
                stopChatPolling();
                loadNotifications(true);
            } else if (tabType === 'messages') {
                notificationList.style.display = 'none';
                chatContainer.style.display = 'flex';
                loadConversations();
            }
        });
    });

    // 发私信按钮
    if (sendMessageBtn) {
        sendMessageBtn.addEventListener('click', function () {
            tabs.forEach(function (t) { t.classList.remove('active'); });
            notificationPanel.querySelector('.notif-tab[data-tab="messages"]').classList.add('active');
            notificationList.style.display = 'none';
            chatContainer.style.display = 'flex';
            loadConversations();
        });
    }

    // ═══════════════════════════════════════════════════════════
    // 加载对话列表
    // ═══════════════════════════════════════════════════════════
    function loadConversations() {
        fetch(getCtx() + '/api/privateMessages?action=list')
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (!data.success || !data.data) {
                    chatContactList.innerHTML = '<div class="notif-empty">暂无对话</div>';
                    return;
                }
                if (data.data.length === 0) {
                    chatContactList.innerHTML = '<div class="notif-empty">暂无对话，点击上方 + 发起对话</div>';
                    return;
                }
                chatContactList.innerHTML = data.data.map(function (item) {
                    var otherUserId = (item.senderId === currentUserId) ? item.receiverId : item.senderId;
                    var name = (item.senderId === currentUserId) ? (item.receiverName || '未知用户') : (item.senderName || '未知用户');
                    var avatarUrl = item.senderAvatar || '';
                    var avatarHtml = renderChatAvatar(avatarUrl, name);
                    var preview = item.content || '';
                    if (preview.length > 25) preview = preview.substring(0, 25) + '...';
                    var isMe = item.senderId === currentUserId;
                    var unreadCount = item.unreadCount || 0;
                    var unreadBadge = unreadCount > 0 ? '<span class="chat-unread-badge">' + (unreadCount > 99 ? '99+' : unreadCount) + '</span>' : '';
                    var timeStr = formatChatTime(item.createdAt);
                    var isActive = currentChatUserId === otherUserId;
                    return '<div class="chat-contact' + (isActive ? ' active' : '') + (unreadCount > 0 ? ' has-unread' : '') + '" data-user-id="' + escapeHtml(otherUserId) + '" data-user-name="' + escapeHtml(name) + '">' +
                        avatarHtml +
                        '<div class="chat-contact-info">' +
                        '<div class="chat-contact-top">' +
                        '<span class="chat-contact-name">' + escapeHtml(name) + '</span>' +
                        '<span class="chat-contact-time">' + timeStr + '</span>' +
                        '</div>' +
                        '<div class="chat-contact-bottom">' +
                        '<span class="chat-contact-preview">' + (isMe ? '<span class="chat-preview-tag">我:</span>' : '') + escapeHtml(preview) + '</span>' +
                        unreadBadge +
                        '</div>' +
                        '</div>' +
                        '</div>';
                }).join('');
            })
            .catch(function () {
                chatContactList.innerHTML = '<div class="notif-empty">加载失败</div>';
            });
    }

    // ═══════════════════════════════════════════════════════════
    // 选择聊天联系人
    // ═══════════════════════════════════════════════════════════
    function selectChatContact(userId, userName, noMobileSwitch) {
        currentChatUserId = userId;
        currentChatUserName = userName;
        lastMessageTime = null;
        chatHeader.querySelector('.chat-user-name').textContent = userName;

        // 移动端：显示聊天主区域，隐藏侧栏
        if (window.innerWidth <= 500 && !noMobileSwitch) {
            chatMain.classList.add('show-mobile');
            chatSidebar.style.display = 'none';
        }

        chatMessages.innerHTML = '<div class="chat-loading">加载消息中...</div>';

        fetch(getCtx() + '/api/privateMessages?action=list&otherUserId=' + userId)
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (!data.success || !data.data) {
                    chatMessages.innerHTML = '<div class="chat-empty">暂无消息</div>';
                    return;
                }
                var html = '';
                var lastDate = '';
                data.data.forEach(function (item) {
                    // 日期分隔线
                    var msgDate = formatChatDate(item.createdAt);
                    if (msgDate !== lastDate) {
                        html += '<div class="chat-date-divider"><span>' + msgDate + '</span></div>';
                        lastDate = msgDate;
                    }
                    var isSent = item.senderId === currentUserId;
                    var senderName = isSent ? '我' : (item.senderName || userName);
                    var timeStr = formatChatTime(item.createdAt);
                    html += '<div class="chat-message ' + (isSent ? 'sent' : 'received') + '">' +
                        '<div class="chat-message-sender">' + (!isSent ? escapeHtml(senderName) : '') + '</div>' +
                        '<div class="chat-message-bubble">' +
                        '<div class="chat-message-content">' + escapeHtml(item.content) + '</div>' +
                        '</div>' +
                        '<div class="chat-message-time">' + timeStr + '</div>' +
                        '</div>';
                    // 记录最新消息时间用于轮询
                    lastMessageTime = item.createdAt;
                });
                chatMessages.innerHTML = html || '<div class="chat-empty">暂无消息</div>';
                chatMessages.scrollTop = chatMessages.scrollHeight;
                // 刷新侧栏高亮
                updateContactHighlight();
                // 启动聊天轮询
                startChatPolling();
            })
            .catch(function () {
                chatMessages.innerHTML = '<div class="chat-empty">加载失败</div>';
            });
    }

    // ═══════════════════════════════════════════════════════════
    // 发送聊天消息
    // ═══════════════════════════════════════════════════════════
    function sendChatMessage() {
        var content = chatInput.value.trim();
        if (!content || !currentChatUserId) return;

        // 乐观更新：先显示发送中
        var sendBtn = document.getElementById('sendChatBtn');
        if (sendBtn) { sendBtn.disabled = true; sendBtn.textContent = '...'; }

        fetch(getCtx() + '/api/privateMessages', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action: 'send', receiverId: currentChatUserId, content: content })
        })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (sendBtn) { sendBtn.disabled = false; sendBtn.textContent = '发送'; }
                if (data.success) {
                    chatInput.value = '';
                    selectChatContact(currentChatUserId, currentChatUserName);
                    // 同时刷新对话列表（让刚刚发的对话排到最上面）
                    loadConversations();
                } else {
                    showToast('发送失败');
                }
            })
            .catch(function () {
                if (sendBtn) { sendBtn.disabled = false; sendBtn.textContent = '发送'; }
                showToast('发送失败');
            });
    }

    // ═══════════════════════════════════════════════════════════
    // 关闭聊天
    // ═══════════════════════════════════════════════════════════
    function closeChat() {
        currentChatUserId = null;
        currentChatUserName = null;
        lastMessageTime = null;
        stopChatPolling();
        chatHeader.querySelector('.chat-user-name').textContent = '选择一个对话';
        chatMessages.innerHTML = '<div class="chat-empty">选择对话开始聊天</div>';
        updateContactHighlight();
        // 移动端：返回侧栏
        if (window.innerWidth <= 500) {
            chatMain.classList.remove('show-mobile');
            chatSidebar.style.display = '';
        }
    }

    // 移动端返回按钮
    function goBackToSidebar() {
        chatMain.classList.remove('show-mobile');
        chatSidebar.style.display = '';
        loadConversations();
    }

    // ═══════════════════════════════════════════════════════════
    // 聊天轮询：每 10 秒拉取新消息
    // ═══════════════════════════════════════════════════════════
    function startChatPolling() {
        stopChatPolling();
        if (!currentChatUserId || !isPanelOpen) return;
        chatPollTimer = setInterval(function () {
            pollNewMessages();
        }, 10000);
    }

    function stopChatPolling() {
        if (chatPollTimer) { clearInterval(chatPollTimer); chatPollTimer = null; }
    }

    function pollNewMessages() {
        if (!currentChatUserId || !lastMessageTime) return;
        fetch(getCtx() + '/api/privateMessages?action=poll&otherUserId=' + currentChatUserId + '&since=' + encodeURIComponent(lastMessageTime))
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (!data.success || !data.data || data.data.length === 0) return;
                // 追加新消息（不重新渲染全部）
                data.data.forEach(function (item) {
                    if (item.senderId !== currentUserId) {
                        // 新消息来自对方，追加到聊天区
                        appendChatMessage(item);
                    }
                    // 更新时间戳
                    if (item.createdAt > lastMessageTime) {
                        lastMessageTime = item.createdAt;
                    }
                });
                // 同时刷新未读总数
                fetchUnreadTotal();
            })
            .catch(function () { /* 静默失败 */ });
    }

    function appendChatMessage(item) {
        var isSent = item.senderId === currentUserId;
        var senderName = isSent ? '我' : (item.senderName || currentChatUserName);
        var timeStr = formatChatTime(item.createdAt);
        var html = '<div class="chat-message ' + (isSent ? 'sent' : 'received') + '">' +
            '<div class="chat-message-sender">' + (!isSent ? escapeHtml(senderName) : '') + '</div>' +
            '<div class="chat-message-bubble">' +
            '<div class="chat-message-content">' + escapeHtml(item.content) + '</div>' +
            '</div>' +
            '<div class="chat-message-time">' + timeStr + '</div>' +
            '</div>';
        chatMessages.insertAdjacentHTML('beforeend', html);
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    function updateContactHighlight() {
        var contacts = chatContactList.querySelectorAll('.chat-contact');
        contacts.forEach(function (c) {
            if (currentChatUserId && c.getAttribute('data-user-id') === currentChatUserId) {
                c.classList.add('active');
            } else {
                c.classList.remove('active');
            }
        });
    }

    // ═══════════════════════════════════════════════════════════
    // 工具：解析相对 avatar 路径
    // ═══════════════════════════════════════════════════════════
    function resolveAvatarUrl(url) {
        if (!url || !url.trim()) return '';
        var u = url.trim();
        if (u.indexOf('http://') === 0 || u.indexOf('https://') === 0 ||
            u.indexOf('data:') === 0 || u.indexOf('//') === 0) {
            return u;
        }
        return (window.CONTEXT_PATH || '') + u;
    }

    // ═══════════════════════════════════════════════════════════
    // 渲染头像（带 contextPath 解析 + 图片回退）
    // ═══════════════════════════════════════════════════════════
    function renderChatAvatar(avatarUrl, fallbackName) {
        var resolved = resolveAvatarUrl(avatarUrl);
        var initial = (fallbackName || '?').charAt(0).toUpperCase();
        if (resolved) {
            return '<div class="chat-contact-avatar">' +
                '<img src="' + resolved + '" style="width:100%;height:100%;border-radius:50%;object-fit:cover;" onerror="this.style.display=\'none\';this.parentElement.textContent=\'' + initial + '\'">' +
                '</div>';
        }
        return '<div class="chat-contact-avatar">' + initial + '</div>';
    }

    // ═══════════════════════════════════════════════════════════
    // 聊天时间格式化工具
    // ═══════════════════════════════════════════════════════════
    function formatChatTime(timeStr) {
        if (!timeStr) return '';
        try {
            var t = new Date(timeStr.replace(/-/g, '/'));
            var now = new Date();
            var h = t.getHours(), m = t.getMinutes();
            var hh = (h < 10 ? '0' : '') + h;
            var mm = (m < 10 ? '0' : '') + m;
            if (t.toDateString() === now.toDateString()) {
                return hh + ':' + mm;
            }
            var yesterday = new Date(now);
            yesterday.setDate(yesterday.getDate() - 1);
            if (t.toDateString() === yesterday.toDateString()) {
                return '昨天 ' + hh + ':' + mm;
            }
            return (t.getMonth() + 1) + '/' + t.getDate() + ' ' + hh + ':' + mm;
        } catch (e) { return ''; }
    }

    function formatChatDate(timeStr) {
        if (!timeStr) return '';
        try {
            var t = new Date(timeStr.replace(/-/g, '/'));
            var now = new Date();
            if (t.toDateString() === now.toDateString()) return '今天';
            var yesterday = new Date(now);
            yesterday.setDate(yesterday.getDate() - 1);
            if (t.toDateString() === yesterday.toDateString()) return '昨天';
            var y = t.getFullYear(), m = t.getMonth() + 1, d = t.getDate();
            return y + '年' + m + '月' + d + '日';
        } catch (e) { return ''; }
    }

    // ESC 键关闭
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && isPanelOpen) closePanel();
    });

    // 移动端返回按钮（小屏幕时在头部添加返回按钮）
    function ensureMobileBackBtn() {
        if (window.innerWidth > 480) return;
        var existing = notificationPanel.querySelector('.notif-mobile-back');
        if (existing) return;
        var headerRight = notificationPanel.querySelector('.notif-header-right');
        if (!headerRight) return;
        var backBtn = document.createElement('button');
        backBtn.className = 'notif-mobile-back';
        backBtn.textContent = '← 返回';
        backBtn.addEventListener('click', closePanel);
        headerRight.insertBefore(backBtn, headerRight.firstChild);
    }
    notificationBtn.addEventListener('click', function() { setTimeout(ensureMobileBackBtn, 50); });
    window.addEventListener('resize', function() {
        if (window.innerWidth <= 480 && isPanelOpen) ensureMobileBackBtn();
    });

    // 页面隐藏/可见切换 → 回到页面时刷新未读数（通知+私信合计）
    document.addEventListener('visibilitychange', function () {
        if (!document.hidden) {
            fetchUnreadTotal();
        }
    });

    // 初始化时获取综合未读数（通知+私信）
    fetchUnreadTotal();

    // ═══════════════════════════════════════════════════════════
    // 综合未读计数（通知 + 私信汇总）
    // ═══════════════════════════════════════════════════════════
    function fetchUnreadTotal() {
        var p1 = fetch(getCtx() + '/api/userNotifications?action=unreadCount')
            .then(function (r) { return r.json(); })
            .then(function (d) { return d.success ? d.count : 0; })
            .catch(function () { return 0; });
        var p2 = fetch(getCtx() + '/api/privateMessages?action=unreadCount')
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (d.success && d.data && typeof d.data.unreadCount === 'number') return d.data.unreadCount;
                return 0;
            })
            .catch(function () { return 0; });
        Promise.all([p1, p2]).then(function (vals) {
            var total = (vals[0] || 0) + (vals[1] || 0);
            updateNotificationBadge(total);
            lastUnreadCount = total;
        });
    }

    // 绑定聊天相关事件
    const closeChatBtn = document.getElementById('closeChatBtn');
    const sendChatBtn = document.getElementById('sendChatBtn');
    const chatBackBtn = document.getElementById('chatBackBtn');
    if (closeChatBtn) {
        closeChatBtn.addEventListener('click', closeChat);
    }
    if (chatBackBtn) {
        chatBackBtn.addEventListener('click', goBackToSidebar);
    }
    if (chatInput) {
        chatInput.addEventListener('keyup', function (e) {
            if (e.key === 'Enter') sendChatMessage();
        });
    }
    if (sendChatBtn) {
        sendChatBtn.addEventListener('click', function (e) {
            e.preventDefault();
            sendChatMessage();
        });
    }
    if (chatContactList) {
        chatContactList.addEventListener('click', function (e) {
            var chatContact = e.target.closest('.chat-contact');
            if (chatContact) {
                var userId = chatContact.getAttribute('data-user-id');
                var userName = chatContact.getAttribute('data-user-name');
                selectChatContact(userId, userName);
            }
        });
    }

    // 绑定详情弹窗事件
    const detailModalOverlay = document.getElementById('detailModalOverlay');
    const closeDetailBtn = document.getElementById('closeDetailBtn');
    const closeDetailModalBtn = document.getElementById('closeDetailModalBtn');
    if (detailModalOverlay) {
        detailModalOverlay.addEventListener('click', closeDetailModal);
    }
    if (closeDetailBtn) {
        closeDetailBtn.addEventListener('click', closeDetailModal);
    }
    if (closeDetailModalBtn) {
        closeDetailModalBtn.addEventListener('click', closeDetailModal);
    }

    // 发起新对话按钮（侧栏内联搜索）
    if (newChatBtn) {
        newChatBtn.addEventListener('click', function (e) {
            e.preventDefault();
            toggleNewChat();
        });
    }
    // 取消搜索按钮
    if (chatSearchCancel) {
        chatSearchCancel.addEventListener('click', function (e) {
            e.preventDefault();
            exitNewChatMode();
        });
    }
    if (userSearchInput) {
        userSearchInput.addEventListener('input', searchUsers);
    }
    if (userList) {
        userList.addEventListener('click', function (e) {
            const userItem = e.target.closest('.user-item');
            if (userItem) {
                const userId = userItem.getAttribute('data-user-id');
                const userName = userItem.getAttribute('data-user-name');
                selectUserForChat(userId, userName);
            }
        });
    }
}

// ========= 移动端菜单 =========
function initMobileMenu() {
    const mobileMenuBtn = document.getElementById('mobileMenuBtn');
    const mobileMenuOverlay = document.getElementById('mobileMenuOverlay');
    const sidebar = document.getElementById('sidebar');

    if (!mobileMenuBtn || !mobileMenuOverlay || !sidebar) return;

    function openMobileMenu() {
        sidebar.classList.add('open');
        mobileMenuOverlay.classList.add('show');
        document.body.style.overflow = 'hidden';
    }

    function closeMobileMenu() {
        sidebar.classList.remove('open');
        mobileMenuOverlay.classList.remove('show');
        document.body.style.overflow = '';
    }

    mobileMenuBtn.addEventListener('click', openMobileMenu);
    mobileMenuOverlay.addEventListener('click', closeMobileMenu);

    function checkResponsive() {
        if (window.innerWidth <= 780) {
            mobileMenuBtn.style.display = 'flex';
        } else {
            mobileMenuBtn.style.display = 'none';
            closeMobileMenu();
        }
    }

    window.addEventListener('resize', checkResponsive);
    checkResponsive();
}

// ========= 侧边栏系统 =========
function initSidebarSystem() {
    const sidebar = document.getElementById('sidebar');
    const collapseToggle = document.getElementById('collapseToggle');

    // 侧边栏折叠
    if (collapseToggle && sidebar) {
        collapseToggle.addEventListener('click', () => {
            sidebar.classList.toggle('collapsed');
            collapseToggle.textContent = sidebar.classList.contains('collapsed') ? '▶' : '◀';
        });

        const wasCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
        if (wasCollapsed) {
            sidebar.classList.add('collapsed');
            collapseToggle.textContent = '▶';
        }
    }

    // 管理员状态检查
    checkAdminStatus();
}

function checkAdminStatus() {
    const adminSection = document.getElementById('adminSection');
    const sessionRole = document.getElementById('sessionRole')?.value;
    const userRole = localStorage.getItem('userRole');

    if (adminSection) {
        // 仅当管理员登录时才显示系统管理
        if (sessionRole === 'admin' || userRole === 'admin') {
            adminSection.classList.add('admin-visible');
        } else {
            adminSection.classList.remove('admin-visible');
        }
    }
}

// ========= 全局初始化函数 =========
function initBoyaAcademy() {
    console.log('[博雅书院] 初始化中...');
    initMobileMenu();
    initSearch();
    initNotifications();
    initAIAssistant();
    initSidebarSystem();
    console.log('[博雅书院] 初始化完成');
}

// ========= 页面加载完成后执行 =========
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initBoyaAcademy);
} else {
    initBoyaAcademy();
}

// ========= 全局导出 =========
window.boyaAcademy = {
    init: initBoyaAcademy,
    search: initSearch,
    notifications: initNotifications,
    ai: initAIAssistant
};

// ========= 全局函数 =========
// 复制代码功能
function copyCode(btn) {
    const codeBlock = btn.parentElement;
    const code = codeBlock.querySelector('code');
    if (code) {
        navigator.clipboard.writeText(code.textContent).then(() => {
            btn.textContent = '已复制!';
            setTimeout(() => btn.textContent = '复制', 2000);
        });
    }
}
