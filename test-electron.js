const { app, BrowserWindow } = require('electron');
const path = require('path');

console.log('=== Test Electron App Starting ===');
console.log('App path:', app.getAppPath());
console.log('Current directory:', __dirname);

app.whenReady().then(() => {
  console.log('=== App whenReady triggered ===');
  
  const mainWindow = new BrowserWindow({
    width: 800,
    height: 600
  });
  
  console.log('Window created');
  
  mainWindow.loadFile('frontend/login/login.html');
  
  console.log('Frontend loaded');
  
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

console.log('=== Test App Setup Complete ===');
