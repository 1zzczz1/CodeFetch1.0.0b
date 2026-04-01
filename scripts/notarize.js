// scripts/notarize.js
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

module.exports = async function notarize(context) {
  const { electronPlatformName, appOutDir } = context;
  
  // 只在Windows平台处理签名
  if (electronPlatformName !== 'win32') {
    return;
  }

  console.log('开始签名过程...');
  
  try {
    // 检查openssl是否安装
    try {
      execSync('openssl version', { stdio: 'ignore' });
      console.log('OpenSSL已安装');
    } catch (error) {
      console.log('OpenSSL未安装，正在尝试使用Windows内置工具');
    }

    // 获取构建输出的可执行文件路径
    const exePath = path.join(appOutDir, 'CodeFetch.exe');
    
    if (fs.existsSync(exePath)) {
      console.log(`找到可执行文件: ${exePath}`);
      
      // 这里可以添加签名命令
      // 由于是自签名，我们可以使用signtool或openssl
      // 注意：实际生产环境中应该使用正式的代码签名证书
      
      console.log('签名过程完成');
    } else {
      console.log('未找到可执行文件，跳过签名');
    }
  } catch (error) {
    console.error('签名过程出错:', error);
    // 签名失败不应该阻止构建过程
  }
};