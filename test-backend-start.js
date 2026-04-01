const path = require('path');
const { spawn } = require('child_process');
const fs = require('fs');

console.log('=== Testing Backend Start Logic ===');

// 模拟 main.js 中的后端启动逻辑
function testBackendStart() {
  console.log('Current directory:', __dirname);
  
  let pythonPath = 'python';
  let scriptPath = path.join(__dirname, 'backend', 'connect.py');
  let cwdPath = __dirname;

  console.log('Testing with:', {
    pythonPath,
    scriptPath,
    cwdPath,
    scriptExists: fs.existsSync(scriptPath)
  });

  // 检查脚本是否存在
  if (!fs.existsSync(scriptPath)) {
    console.error('Backend script not found at:', scriptPath);
    return false;
  }

  try {
    console.log('Spawning backend process...');
    // 启动后端作为独立进程
    const backendProcess = spawn(pythonPath, [scriptPath], {
      cwd: cwdPath,
      detached: true,
      stdio: ['ignore', 'pipe', 'pipe'],
      shell: false
    });

    console.log('Backend process spawned with PID:', backendProcess.pid);

    // 监听 stdout
    if (backendProcess.stdout) {
      backendProcess.stdout.on('data', (data) => {
        console.log(`Backend stdout: ${data}`);
      });
    }

    // 监听 stderr
    if (backendProcess.stderr) {
      backendProcess.stderr.on('data', (data) => {
        console.error(`Backend stderr: ${data}`);
      });
    }

    backendProcess.on('error', (err) => {
      console.error('Backend process error:', err);
      console.error('Error code:', err.code);
      console.error('Error message:', err.message);
    });

    backendProcess.on('exit', (code, signal) => {
      console.log(`Backend process exited - code: ${code}, signal: ${signal}`);
    });

    // 5秒后停止进程
    setTimeout(() => {
      console.log('Stopping backend process...');
      if (process.platform === 'win32') {
        spawn('taskkill', ['/PID', backendProcess.pid, '/F', '/T']);
      } else {
        backendProcess.kill('SIGTERM');
      }
    }, 5000);

    return true;
  } catch (error) {
    console.error('Error spawning backend process:', error);
    return false;
  }
}

// 运行测试
testBackendStart();

console.log('=== Test Complete ===');
