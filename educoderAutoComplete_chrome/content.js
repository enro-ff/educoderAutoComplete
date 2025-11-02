class EducoderFloatingAssistant {
    constructor() {
        this.socket = null;
        this.isVisible = false;
        this.isMinimized = false;
        this.generatedCode = null;
        this.dragging = false;
        this.dragOffset = { x: 0, y: 0 };
        this.autoConnectAttempted = false; // 新增：标记是否已尝试自动连接

        this.init();
    }

    async init() { // 改为异步方法
        this.createFloatingWindow();
        this.attachEventListeners();
        await this.loadSettings(); // 等待设置加载完成
        this.extractPageContent();

        // 新增：自动连接服务器
        await this.autoConnect();
    }

    createFloatingWindow() {
        // 创建主容器
        this.container = document.createElement('div');
        this.container.id = 'educoder-assistant-floating';
        this.container.className = 'educoder-assistant';

        this.container.innerHTML = `
            <div class="ea-header">
                <div class="ea-title">
                    <span class="ea-icon"></span>
                    <span>Educoder 助手 
                    <br>
                    <span class = 'fast-show'>(显示/隐藏快捷键Ctrl+shift+E)</span>
                    </span>
                    
                </div>
                <div class="ea-controls">
                    <button class="ea-btn" id = "minimizeBtn" title="最小化">−</button>
                    <button class="ea-btn" id = "closeBtn" title="关闭">×</button>
                </div>
            </div>
            
            <div class="ea-body">
                <!-- 连接状态 -->
                <div class="ea-status">
                    <div class="ea-status-item">
                        <span>服务器:</span>
                        <span class="ea-status-value" id="eaServerStatus">未连接</span>
                        <div class="ea-status-indicator" id="eaStatusIndicator"></div>
                    </div>
                    <div class="ea-status-item">
                        <span>页面:</span>
                        <span class="ea-status-value" id="eaPageStatus">就绪</span>
                    </div>
                </div>

                <!-- 连接配置 -->
                <div class="ea-section">
                    <div class="ea-input-group">
                        <label for="eaServerUrl">服务器地址:</label>
                        <input type="text" id="eaServerUrl" placeholder="ws://localhost:8000" 
                               class="ea-input">
                    </div>
                    <div class="ea-button-group">
                        <button id="eaConnectBtn" class="ea-btn ea-primary">连接</button>
                        <button id="eaDisconnectBtn" class="ea-btn ea-secondary" disabled>断开</button>
                    </div>
                </div>

                <!-- 内容操作 -->
                <div class="ea-section">
                    <h4>题目处理</h4>
                    <div class="ea-button-group">
                        <button id="eaGetContentBtn" class="ea-btn ea-primary" disabled>
                            获取题目并开始输入
                        </button>
                        <button id="eaAutoInputBtn" class="ea-btn ea-success" disabled>
                            准备输入
                        </button>
                    </div>
                    
                    <div class="ea-preview-section">
                        <div class="ea-preview">
                            <div class="ea-preview-header">
                                <span>题目内容</span>
                                <span class="ea-preview-count" id="eaContentCount">0 字符</span>
                            </div>
                            <div id="eaContentPreview" class="ea-preview-content">
                                <div class="ea-placeholder">点击"获取题目"加载内容...</div>
                            </div>
                        </div>

                        <!--
                        <div class="ea-preview">
                            <div class="ea-preview-header">
                                <span>生成代码</span>
                                <span class="ea-preview-count" id="eaCodeCount">0 字符</span>
                            </div>
                            <div id="eaCodePreview" class="ea-preview-content ea-code-preview">
                                <div class="ea-placeholder">代码生成后将显示在这里...</div>
                            </div>
                        </div>
                       -->
                    </div>
                </div>

                <!-- 操作日志 -->
                <div class="ea-section">
                    <div class="ea-log-header">
                        <h4>操作日志</h4>
                        <button id="eaClearLogsBtn" class="ea-btn ea-small">清空</button>
                    </div>
                    <div id="eaMessagesContainer" class="ea-log-container">
                        <div class="ea-placeholder">暂无操作记录</div>
                    </div>
                </div>
            </div>
        `;

        document.body.appendChild(this.container);
        this.initializeElements();

        // 显示窗口
        this.show();
    }

    initializeElements() {
        // 连接相关
        this.serverUrlInput = document.getElementById('eaServerUrl');
        this.connectBtn = document.getElementById('eaConnectBtn');
        this.disconnectBtn = document.getElementById('eaDisconnectBtn');
        this.header = this.container.querySelector('.ea-header');

        // 功能按钮
        this.getContentBtn = document.getElementById('eaGetContentBtn');
        this.autoInputBtn = document.getElementById('eaAutoInputBtn');
        this.clearLogsBtn = document.getElementById('eaClearLogsBtn');

        // 预览区域
        this.contentPreview = document.getElementById('eaContentPreview');
        this.codePreview = document.getElementById('eaCodePreview');
        this.contentCount = document.getElementById('eaContentCount');
        this.codeCount = document.getElementById('eaCodeCount');

        // 状态显示
        this.serverStatus = document.getElementById('eaServerStatus');
        this.pageStatus = document.getElementById('eaPageStatus');
        this.statusIndicator = document.getElementById('eaStatusIndicator');

        // 日志容器
        this.messagesContainer = document.getElementById('eaMessagesContainer');

        // 控制按钮
        this.minimizeBtn = this.container.querySelector('#minimizeBtn');
        this.closeBtn = this.container.querySelector('#closeBtn');
    }

    attachEventListeners() {
        // 连接按钮事件 - 修改为重新连接功能
        this.connectBtn.addEventListener('click', () => {
            this.showMessage('正在手动连接服务器...', 'system');
            this.connect();
        });
        this.disconnectBtn.addEventListener('click', () => this.disconnect());

        // 功能按钮事件
        this.getContentBtn.addEventListener('click', () => this.getEducoderContent());
        this.autoInputBtn.addEventListener('click', () => this.prepareAutoInput());
        this.clearLogsBtn.addEventListener('click', () => this.clearLogs());

        // 控制按钮事件
        this.minimizeBtn.addEventListener('click', () => {
            if (this.isMinimized) {
                this.restore();
            } else {
                this.minimize();
            }
        });
        this.closeBtn.addEventListener('click', () => this.hide());

        // 输入框事件 - 修改为实时保存并尝试重新连接
        this.serverUrlInput.addEventListener('change', () => {
            this.saveSettings();
            // 如果当前已连接，使用新地址重新连接
            if (this.socket && this.socket.readyState === WebSocket.OPEN) {
                this.showMessage('服务器地址已更新，正在重新连接...', 'system');
                setTimeout(() => this.connect(), 500);
            }
        });

        // 拖拽功能
        this.attachDragEvents();
    }

    attachDragEvents() {
        this.header.addEventListener('mousedown', (e) => {
            if (e.target.closest('.ea-controls')) return;

            this.dragging = true;
            const rect = this.container.getBoundingClientRect();
            this.dragOffset.x = e.clientX - rect.left;
            this.dragOffset.y = e.clientY - rect.top;

            e.preventDefault();
        });

        document.addEventListener('mousemove', (e) => {
            if (!this.dragging) return;

            const x = e.clientX - this.dragOffset.x;
            const y = e.clientY - this.dragOffset.y;

            // 限制在窗口范围内
            const maxX = window.innerWidth - this.container.offsetWidth;
            const maxY = window.innerHeight - this.container.offsetHeight;

            this.container.style.left = Math.max(0, Math.min(x, maxX)) + 'px';
            this.container.style.top = Math.max(0, Math.min(y, maxY)) + 'px';
        });

        document.addEventListener('mouseup', () => {
            this.dragging = false;
        });
    }

    async loadSettings() {
        try {
            const result = await chrome.storage.local.get(['serverUrl', 'windowPosition']);
            if (result.serverUrl && this.serverUrlInput) {
                this.serverUrlInput.value = result.serverUrl;
            }
            if (result.windowPosition && this.container) {
                this.container.style.left = result.windowPosition.x + 'px';
                this.container.style.top = result.windowPosition.y + 'px';
            }
            return result; // 返回设置结果
        } catch (error) {
            this.showMessage(`加载设置失败: ${error.message}`, 'error');
            return {};
        }
    }

    saveSettings() {
        const rect = this.container.getBoundingClientRect();
        chrome.storage.local.set({
            serverUrl: this.serverUrlInput.value,
            windowPosition: { x: rect.left, y: rect.top }
        });
    }

    // 新增：自动连接方法
    async autoConnect() {
        const url = this.serverUrlInput.value.trim();

        if (!url) {
            this.showMessage('未配置服务器地址，请手动连接', 'system');
            return;
        }

        if (this.autoConnectAttempted) {
            return; // 防止重复尝试
        }

        this.autoConnectAttempted = true;
        this.showMessage('正在自动连接服务器...', 'system');

        try {
            await this.connectWebSocket(url);
        } catch (error) {
            this.showMessage(`自动连接失败: ${error.message}`, 'error');
            this.updateConnectionState('CLOSED');
        }
    }

    // 新增：WebSocket连接封装方法
    connectWebSocket(url) {
        return new Promise((resolve, reject) => {
            if (!url) {
                reject(new Error('服务器地址为空'));
                return;
            }

            try {
                this.socket = new WebSocket(url);
                this.updateConnectionState('CONNECTING');

                this.socket.onopen = (event) => {
                    this.updateConnectionState('OPEN');
                    this.showMessage('✅ 连接服务器成功', 'system');
                    resolve(event);
                };

                this.socket.onmessage = (event) => {
                    this.handleServerMessage(event.data);
                };

                this.socket.onerror = (error) => {
                    this.updateConnectionState('CLOSED');
                    this.showMessage('❌ 连接错误', 'error');
                    reject(error);
                };

                this.socket.onclose = (event) => {
                    this.updateConnectionState('CLOSED');
                    const reason = event.code === 1000 ? '正常关闭' : `异常关闭 (代码: ${event.code})`;
                    this.showMessage(`连接关闭: ${reason}`, 'system');

                    // 如果不是正常关闭且不是第一次连接失败，可以尝试重连
                    if (event.code !== 1000 && this.autoConnectAttempted) {
                        setTimeout(() => {
                            this.showMessage('尝试重新连接...', 'system');
                            this.autoConnect();
                        }, 3000);
                    }
                };

            } catch (error) {
                reject(error);
            }
        });
    }

    // 修改原有的 connect 方法
    connect() {
        const url = this.serverUrlInput.value.trim();

        if (!url) {
            this.showMessage('请输入服务器地址', 'error');
            return;
        }

        // 如果已有连接，先关闭
        if (this.socket && this.socket.readyState === WebSocket.OPEN) {
            this.socket.close(1000, '重新连接');
        }

        this.connectWebSocket(url).catch(error => {
            this.showMessage(`手动连接失败: ${error.message}`, 'error');
        });
    }

    handleServerMessage(message) {
        try {
            const data = JSON.parse(message);

            if (data.type === 'code_solution') {
                this.handleCodeSolution(data);
            } else {
                this.showMessage(`服务器: ${JSON.stringify(data)}`, 'received');
            }

        } catch (e) {
            this.showMessage(`服务器: ${message}`, 'received');

            if (message.includes('代码已生成') || message.includes('自动输入')) {
                this.pageStatus.textContent = '代码就绪';
                this.pageStatus.style.color = '#28a745';
            }
        }
    }

    handleCodeSolution(data) {
        this.generatedCode = data.code;
        this.showCodePreview(this.generatedCode);
        this.autoInputBtn.disabled = false;
        this.showMessage('✅ 代码生成完成，点击"准备输入"按钮', 'system');
    }

    disconnect() {
        if (this.socket) {
            if (this.socket.readyState === WebSocket.OPEN) {
                this.socket.close(1000, '用户主动断开');
            }
            this.socket = null;
        }
        this.updateConnectionState('CLOSED');
        this.showMessage('已断开服务器连接', 'system');
    }

    async getEducoderContent() {
        if (!this.socket || this.socket.readyState !== WebSocket.OPEN) {
            this.showMessage('请先建立服务器连接', 'error');
            return;
        }

        try {
            this.showMessage('正在获取题目内容...', 'system');

            const content = this.extractPageContent();

            if (content.text) {
                this.showContentPreview(content);
                this.sendContentToServer(content);
            } else {
                this.showMessage('未找到题目内容', 'error');
                this.clearContentPreview();
            }

        } catch (error) {
            this.showMessage(`获取内容失败: ${error.message}`, 'error');
            console.error('获取内容错误:', error);
        }
    }

    extractPageContent() {
        const targetSelectors = [
            '.tab-panel-body___iueV_.markdown-body.mdBody___raKXb',
            '.markdown-body',
            '.tab-panel-body',
            '.problem-content',
            '.question-content',
            '.problem-description',
            '.shixun-content'
        ];

        let elements = [];
        let allText = '';

        for (const selector of targetSelectors) {
            const foundElements = document.querySelectorAll(selector);
            if (foundElements.length > 0) {
                elements = Array.from(foundElements);
                break;
            }
        }

        if (elements.length === 0) {
            const possibleElements = document.querySelectorAll('div, section, article');
            elements = Array.from(possibleElements).filter(el => {
                const text = el.textContent || '';
                const hasContent = text.length > 200 &&
                    (text.includes('题目') ||
                        text.includes('要求') ||
                        text.includes('编程') ||
                        text.includes('代码') ||
                        text.includes('function') ||
                        text.includes('def ') ||
                        text.includes('public'));
                return hasContent;
            });
        }

        if (elements.length > 0) {
            allText = elements.map(el => {
                let text = el.textContent || '';
                text = text.replace(/\s+/g, ' ').trim();
                return text;
            }).join('\n\n');
        }

        return {
            elements: elements.map(el => ({
                tagName: el.tagName,
                className: el.className,
                textLength: (el.textContent || '').length
            })),
            text: allText,
            timestamp: new Date().toISOString(),
            url: window.location.href
        };
    }

    sendContentToServer(content) {
        try {
            const messageData = {
                type: 'educoder_content',
                timestamp: new Date().toISOString(),
                url: window.location.href,
                content: content
            };

            this.socket.send(JSON.stringify(messageData, null, 2));
            this.showMessage('题目内容已发送到服务器', 'sent');

        } catch (error) {
            this.showMessage(`发送失败: ${error.message}`, 'error');
        }
    }

    prepareAutoInput() {
        if (!this.generatedCode) {
            this.showMessage('请先生成代码', 'warning');
            return;
        }

        this.showMessage('请点击网页中的代码输入框，然后开始自动输入...', 'system');

        if (this.socket && this.socket.readyState === WebSocket.OPEN) {
            this.socket.send(JSON.stringify({
                type: 'ready_for_input',
                code: this.generatedCode
            }));
        }
    }

    showContentPreview(content) {
        const charCount = content.text.length;
        const lineCount = content.text.split('\n').length;

        this.contentPreview.innerHTML = `
            <div class="ea-preview-meta">${content.elements.length}个元素, ${charCount}字符, ${lineCount}行</div>
            <div class="ea-preview-text">${this.escapeHtml(content.text.substring(0, 300))}${charCount > 300 ? '...' : ''}</div>
        `;
        this.contentCount.textContent = `${charCount} 字符`;
    }

    showCodePreview(code) {
        const charCount = code.length;
        const lineCount = code.split('\n').length;

        this.codePreview.innerHTML = `
            <div class="ea-preview-meta">${lineCount}行代码, ${charCount}字符</div>
            <div class="ea-preview-text">${this.escapeHtml(code.substring(0, 500))}${charCount > 500 ? '...' : ''}</div>
        `;
        this.codeCount.textContent = `${charCount} 字符`;
    }

    clearContentPreview() {
        this.contentPreview.innerHTML = '<div class="ea-placeholder">点击"获取题目"加载内容...</div>';
        this.contentCount.textContent = '0 字符';
    }

    clearLogs() {
        this.messagesContainer.innerHTML = '<div class="ea-placeholder">暂无操作记录</div>';
    }

    updateConnectionState(state) {
        const stateTexts = {
            'CONNECTING': '连接中...',
            'OPEN': '已连接',
            'CLOSING': '关闭中...',
            'CLOSED': '未连接'
        };

        this.serverStatus.textContent = stateTexts[state] || state;

        this.statusIndicator.className = 'ea-status-indicator';
        if (state === 'OPEN') {
            this.statusIndicator.classList.add('ea-connected');
            this.connectBtn.textContent = '已连接';
        } else if (state === 'CONNECTING') {
            this.statusIndicator.classList.add('ea-connecting');
            this.connectBtn.textContent = '连接中...';
        } else {
            this.statusIndicator.classList.add('ea-disconnected');
            this.connectBtn.textContent = '连接';
        }

        const isConnected = state === 'OPEN';
        this.connectBtn.disabled = isConnected;
        this.disconnectBtn.disabled = !isConnected;
        this.getContentBtn.disabled = !isConnected;
    }

    showMessage(text, type = 'system') {
        const messageElement = document.createElement('div');
        messageElement.className = `ea-log-item ea-${type}`;

        const timestamp = new Date().toLocaleTimeString();
        messageElement.innerHTML = `
            <div class="ea-log-time">[${timestamp}]</div>
            <div class="ea-log-text">${this.escapeHtml(text)}</div>
        `;

        const placeholder = this.messagesContainer.querySelector('.ea-placeholder');
        if (placeholder) {
            placeholder.remove();
        }

        this.messagesContainer.appendChild(messageElement);
        this.messagesContainer.scrollTop = this.messagesContainer.scrollHeight;
    }

    show() {
        this.container.classList.add('ea-visible');
        this.isVisible = true;
        this.isMinimized = false;
    }

    hide() {
        this.container.classList.remove('ea-visible');
        this.isVisible = false;
    }

    minimize() {
        this.container.style.resize = 'none'
        this.container.classList.add('ea-minimized-state');
        this.isMinimized = true;
        this.minimizeBtn.setAttribute('title', '恢复');
        this.minimizeBtn.textContent = '↗';
        this.currentStyle = [this.container.style.width, this.container.style.height];
        this.container.style.height = '52px';
        console.log(this.header.style.height);
    }

    restore() {
        this.container.style.resize = 'both'
        this.container.classList.remove('ea-minimized-state');
        this.isMinimized = false;
        this.minimizeBtn.setAttribute('title', '最小化');
        this.minimizeBtn.textContent = '-';
        this.container.style.height = this.currentStyle[1];
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// 初始化浮动窗口
let assistant;

function initAssistant() {
    if (document.getElementById('educoder-assistant-floating')) {
        return; // 防止重复初始化
    }

    assistant = new EducoderFloatingAssistant();

    // 添加全局快捷键 (Ctrl+Shift+E)
    document.addEventListener('keydown', (e) => {
        if (e.ctrlKey && e.shiftKey && e.key === 'E') {
            e.preventDefault();
            if (assistant.isVisible) {
                assistant.hide();
            } else {
                assistant.show();
            }
        }
    });
}

// 页面加载完成后初始化
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAssistant);
} else {
    initAssistant();
}
