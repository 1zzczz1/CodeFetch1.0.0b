const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const { spawn } = require('child_process');
const http = require('http');
const fs = require('fs');

// 设置日志文件
let logFile;
if (app.isPackaged) {
  // 生产模式下，将日志文件放在用户数据目录
  const userDataPath = app.getPath('userData');
  logFile = path.join(userDataPath, 'app.log');
} else {
  // 开发模式下，将日志文件放在当前目录
  logFile = path.join(__dirname, 'app.log');
}
// 确保日志目录存在
const logDir = path.dirname(logFile);
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}
// 清空日志文件
fs.writeFileSync(logFile, '=== Application Start ===\n');

// 重定向console.log到文件
const originalLog = console.log;
const originalError = console.error;

console.log = function(...args) {
  const message = args.map(arg => typeof arg === 'object' ? JSON.stringify(arg) : arg).join(' ');
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] INFO: ${message}\n`;
  fs.appendFileSync(logFile, logMessage);
  originalLog.apply(console, args);
};

console.error = function(...args) {
  const message = args.map(arg => typeof arg === 'object' ? JSON.stringify(arg) : arg).join(' ');
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] ERROR: ${message}\n`;
  fs.appendFileSync(logFile, logMessage);
  originalError.apply(console, args);
};

let mainWindow = null;
let backendProcess = null;

// 启动后端服务
function startBackend() {
  console.log('=== Starting Backend Service ===');
  
  let pythonPath;
  let scriptPath;
  let cwdPath;

  console.log('App is packaged:', app.isPackaged);
  console.log('Current directory:', __dirname);
  console.log('App path:', app.getAppPath());
  console.log('Resources path:', process.resourcesPath);
  
  if (app.isPackaged) {
    // 生产模式下的路径
    const resourcesPath = process.resourcesPath;
    
    // 首先尝试使用打包的Python运行时
    const bundledPython = path.join(resourcesPath, 'python-runtime', 'Scripts', 'python.exe');
    const bundledPythonAlt = path.join(resourcesPath, 'app', 'python-runtime', 'Scripts', 'python.exe');
    
    // 检查后端脚本路径
    scriptPath = path.join(resourcesPath, 'app', 'backend', 'connect.py');
    if (!fs.existsSync(scriptPath)) {
      scriptPath = path.join(resourcesPath, 'backend', 'connect.py');
    }
    
    // 确定Python路径
    if (fs.existsSync(bundledPython)) {
      pythonPath = bundledPython;
      console.log('使用打包的Python:', pythonPath);
    } else if (fs.existsSync(bundledPythonAlt)) {
      pythonPath = bundledPythonAlt;
      console.log('使用打包的Python(备选路径):', pythonPath);
    } else {
      // 回退到系统Python
      pythonPath = 'python';
      console.log('打包的Python未找到，使用系统Python:', pythonPath);
    }
    
    cwdPath = path.dirname(scriptPath);
  } else {
    // 开发模式下的路径
    // 首先尝试使用虚拟环境
    const venvPython = path.join(__dirname, '.venv', 'Scripts', 'python.exe');
    if (fs.existsSync(venvPython)) {
      pythonPath = venvPython;
      console.log('使用虚拟环境Python:', pythonPath);
    } else {
      pythonPath = 'python';
      console.log('使用系统Python:', pythonPath);
    }
    scriptPath = path.join(__dirname, 'backend', 'connect.py');
    cwdPath = __dirname;
  }
  
  console.log('Backend config:', {
    pythonPath,
    scriptPath,
    cwdPath,
    scriptExists: fs.existsSync(scriptPath),
    pythonExists: fs.existsSync(pythonPath)
  });

  // 检查脚本是否存在
  if (!fs.existsSync(scriptPath)) {
    console.error('Backend script not found at:', scriptPath);
    return false;
  }

  // 检查Python是否存在（如果是文件路径）
  if (!pythonPath.includes('\\') && !pythonPath.includes('/')) {
    // 是相对路径或命令，不需要检查文件存在性
    console.log('Using Python command:', pythonPath);
  } else if (!fs.existsSync(pythonPath)) {
    console.error('Python executable not found at:', pythonPath);
    // 尝试使用系统Python
    pythonPath = 'python';
    console.log('Trying system Python:', pythonPath);
  }

  try {
    console.log('Attempting to spawn backend process...');
    // 启动后端作为子进程
    backendProcess = spawn(pythonPath, [scriptPath], {
      cwd: cwdPath,
      detached: false,
      stdio: ['pipe', 'pipe', 'pipe'],
      shell: true // 使用shell以便更好地处理路径
    });

    console.log('Backend process spawned with PID:', backendProcess.pid);

    // 监听 stdout
    if (backendProcess.stdout) {
      backendProcess.stdout.on('data', (data) => {
        const output = data.toString();
        console.log(`Backend stdout: ${output}`);
      });
    }

    // 监听 stderr
    if (backendProcess.stderr) {
      backendProcess.stderr.on('data', (data) => {
        const output = data.toString();
        console.error(`Backend stderr: ${output}`);
      });
    }

    backendProcess.on('error', (err) => {
      console.error('Backend process error:', err);
      console.error('Error code:', err.code);
      console.error('Error message:', err.message);
    });

    backendProcess.on('exit', (code, signal) => {
      console.log(`Backend process exited - code: ${code}, signal: ${signal}`);
      backendProcess = null;
      // 后端退出时，应用也应该退出
      if (!app.isQuitting) {
        console.log('Backend exited, quitting app...');
        app.quit();
      }
    });

    // 等待一段时间后检查后端是否还在运行
    setTimeout(() => {
      if (backendProcess && backendProcess.pid) {
        console.log('Backend process is still running after 5 seconds');
      } else {
        console.error('Backend process has exited prematurely');
      }
    }, 5000);

    console.log('=== Backend Startup Complete ===');
    return true;
  } catch (error) {
    console.error('Error spawning backend process:', error);
    console.error('Error stack:', error.stack);
    return false;
  }
}

// 停止后端服务
function stopBackend() {
  if (backendProcess) {
    console.log('Stopping backend server with PID:', backendProcess.pid);
    try {
      if (process.platform === 'win32') {
        // 使用taskkill命令强制终止进程及其子进程
        const taskkill = spawn('taskkill', ['/PID', backendProcess.pid, '/F', '/T'], {
          shell: true
        });
        taskkill.on('exit', (code) => {
          console.log('Taskkill exited with code:', code);
        });
      } else {
        // 非Windows系统使用kill命令
        backendProcess.kill('SIGTERM');
        setTimeout(() => {
          if (backendProcess && !backendProcess.killed) {
            console.log('Forcing backend process termination');
            backendProcess.kill('SIGKILL');
          }
        }, 2000);
      }
      // 等待一段时间后再设置为null，确保进程有时间被终止
      setTimeout(() => {
        backendProcess = null;
        console.log('Backend process reference cleared');
      }, 1000);
    } catch (error) {
      console.error('Error stopping backend process:', error);
      backendProcess = null;
    }
  } else {
    console.log('No backend process to stop');
  }
}

// 创建前端窗口
function createWindow() {
  // 检查图标文件是否存在
  const iconPath = path.join(__dirname, 'frontend', 'picture', 'icon.png');
  console.log('Icon path:', iconPath);
  console.log('Icon file exists:', fs.existsSync(iconPath));
  
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true
    },
    icon: iconPath
  });

  // 直接加载前端登录页面
  const possibleLoginPaths = [
    path.join(app.getAppPath(), 'frontend', 'login', 'login.html'),
    path.join(process.resourcesPath, 'frontend', 'login', 'login.html'),
    path.join(__dirname, 'frontend', 'login', 'login.html')
  ];
  
  let loginPath = possibleLoginPaths[0];
  for (const lp of possibleLoginPaths) {
    if (fs.existsSync(lp)) {
      loginPath = lp;
      console.log('Found login page at:', loginPath);
      break;
    }
  }
  
  console.log('Loading frontend from:', loginPath);
  mainWindow.loadFile(loginPath);

  // 打开开发者工具以便调试
  // mainWindow.webContents.openDevTools();
}

// 保存用户设置
function saveUserSettings() {
  return new Promise((resolve) => {
    const options = {
      hostname: 'localhost',
      port: 5000,
      path: '/api/save-all-settings',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        console.log('Settings saved:', data);
        resolve(true);
      });
    });

    req.on('error', (err) => {
      console.error('Failed to save settings:', err);
      resolve(false);
    });

    req.write(JSON.stringify({}));
    req.end();

    setTimeout(() => {
      resolve(false);
    }, 3000);
  });
}

// 暴露IPC接口
ipcMain.handle('trigger-save-settings', async () => {
  return await saveUserSettings();
});

// 处理前端启动后端的请求
ipcMain.handle('start-backend', async () => {
  console.log('Received request to start backend from frontend');
  if (!backendProcess) {
    console.log('Backend process not running, starting...');
    return startBackend();
  } else {
    console.log('Backend process is already running');
    return true;
  }
});

// 应用启动
console.log('=== Application Starting ===');
console.log('App path:', app.getAppPath());
console.log('Current directory:', __dirname);

// 优先启动后端服务（作为主进程的核心部分）
const backendStarted = startBackend();

if (!backendStarted) {
  console.error('Failed to start backend, exiting...');
  app.quit();
}

app.whenReady().then(() => {
  console.log('=== App whenReady triggered ===');
  console.log('Backend is already running as main process');
  
  // 后端启动成功后，启动前端
  console.log('Starting frontend...');
  setTimeout(() => {
    console.log('Creating window...');
    createWindow();
    console.log('Window created');
  }, 2000); // 给后端一些启动时间

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

// 应用关闭
app.on('window-all-closed', async () => {
  await saveUserSettings();
  stopBackend();
  
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// 应用退出前
app.on('before-quit', async (e) => {
  if (!app.isQuitting) {
    e.preventDefault();
    app.isQuitting = true;
    
    await saveUserSettings();
    stopBackend();
    
    app.quit();
  }
});

// 应用退出
app.on('quit', () => {
  stopBackend();
  console.log('Application quit');
});
