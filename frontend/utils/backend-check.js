// 后端服务检查和启动工具

class BackendChecker {
    constructor() {
        this.backendUrl = 'http://localhost:5000';
        this.isChecking = false;
        this.isStarting = false;
    }

    // 检查后端服务是否可用
    async checkBackend() {
        try {
            const response = await fetch(`${this.backendUrl}/api/check-email`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ email: 'test@example.com' }),
                timeout: 3000
            });
            return response.ok;
        } catch (error) {
            return false;
        }
    }

    // 启动后端服务
    async startBackend() {
        if (this.isStarting) {
            return new Promise(resolve => {
                const checkInterval = setInterval(() => {
                    if (!this.isStarting) {
                        clearInterval(checkInterval);
                        resolve(this.checkBackend());
                    }
                }, 1000);
            });
        }

        this.isStarting = true;

        return new Promise(async (resolve, reject) => {
            try {
                // 使用Electron的API启动后端
                if (window.electron) {
                    await window.electron.startBackend();
                    
                    // 等待3秒让后端启动
                    setTimeout(async () => {
                        this.isStarting = false;
                        const isUp = await this.checkBackend();
                        resolve(isUp);
                    }, 3000);
                } else {
                    // 非Electron环境，尝试使用Python直接启动
                    const { exec } = require('child_process');
                    
                    // 在后台启动Python后端
                    const process = exec('python backend/connect.py', {
                        cwd: process.cwd(),
                        detached: true,
                        stdio: 'ignore'
                    });

                    process.unref();

                    // 等待3秒让后端启动
                    setTimeout(async () => {
                        this.isStarting = false;
                        const isUp = await this.checkBackend();
                        resolve(isUp);
                    }, 3000);
                }
            } catch (error) {
                this.isStarting = false;
                console.error('启动后端服务失败:', error);
                resolve(false);
            }
        });
    }

    // 检查并在需要时启动后端
    async ensureBackend() {
        if (this.isChecking) {
            return new Promise(resolve => {
                const checkInterval = setInterval(() => {
                    if (!this.isChecking) {
                        clearInterval(checkInterval);
                        resolve(this.checkBackend());
                    }
                }, 1000);
            });
        }

        this.isChecking = true;

        try {
            const isUp = await this.checkBackend();
            
            if (!isUp) {
                console.log('后端服务未启动，正在启动...');
                const started = await this.startBackend();
                this.isChecking = false;
                return started;
            } else {
                this.isChecking = false;
                return true;
            }
        } catch (error) {
            this.isChecking = false;
            console.error('检查后端服务失败:', error);
            return false;
        }
    }

    // 显示加载状态
    showLoading(message = '正在检查服务...') {
        // 创建加载元素
        let loadingElement = document.getElementById('backend-loading');
        
        if (!loadingElement) {
            loadingElement = document.createElement('div');
            loadingElement.id = 'backend-loading';
            loadingElement.style.cssText = `
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(255, 255, 255, 0.9);
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
                z-index: 9999;
                font-size: 16px;
                color: #333;
            `;
            
            const spinner = document.createElement('div');
            spinner.style.cssText = `
                border: 4px solid #f3f3f3;
                border-top: 4px solid #3498db;
                border-radius: 50%;
                width: 40px;
                height: 40px;
                animation: spin 1s linear infinite;
                margin-bottom: 20px;
            `;
            
            const style = document.createElement('style');
            style.textContent = `
                @keyframes spin {
                    0% { transform: rotate(0deg); }
                    100% { transform: rotate(360deg); }
                }
            `;
            document.head.appendChild(style);
            
            loadingElement.appendChild(spinner);
            const textElement = document.createElement('div');
            textElement.textContent = message;
            loadingElement.appendChild(textElement);
            document.body.appendChild(loadingElement);
        } else {
            loadingElement.querySelector('div:last-child').textContent = message;
            loadingElement.style.display = 'flex';
        }
    }

    // 隐藏加载状态
    hideLoading() {
        const loadingElement = document.getElementById('backend-loading');
        if (loadingElement) {
            loadingElement.style.display = 'none';
        }
    }
}

// 导出单例实例
const backendChecker = new BackendChecker();

export default backendChecker;