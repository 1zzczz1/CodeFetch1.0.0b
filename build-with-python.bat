@echo off
chcp 65001 > nul
echo ================================================================================
echo CodeFetch 打包脚本（含Python运行时）
echo ================================================================================
echo.

:: 检查Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未找到Node.js，请先安装Node.js
    pause
    exit /b 1
)

:: 检查electron-builder
if not exist "node_modules\.bin\electron-builder.cmd" (
    echo 正在安装electron-builder...
    npm install
)

echo.
echo 步骤 1: 准备Python运行时环境
echo --------------------------------------------------------------------------------
node scripts/prepare-python.js
if %errorlevel% neq 0 (
    echo Python运行时准备失败
    pause
    exit /b 1
)

echo.
echo 步骤 2: 清理旧的构建文件
echo --------------------------------------------------------------------------------
if exist "dist" (
    echo 删除旧的dist目录...
    rmdir /s /q "dist" 2>nul
    timeout /t 2 /nobreak >nul
)

echo.
echo 步骤 3: 构建应用程序
echo --------------------------------------------------------------------------------
npm run build:win

if %errorlevel% neq 0 (
    echo.
    echo 构建失败！请检查错误信息。
    pause
    exit /b 1
)

echo.
echo ================================================================================
echo 构建成功！
echo --------------------------------------------------------------------------------
echo 安装程序位置: dist\CodeFetch Setup 1.0.0.exe
echo 便携版位置: dist\win-unpacked\
echo --------------------------------------------------------------------------------
echo.
echo 安装程序已包含：
echo   - 应用程序文件
echo   - Python 3.14 运行时
echo   - 所有Python依赖（Flask, Flask-CORS, PyMySQL, Cryptography, PyJWT）
echo   - 后端服务脚本
echo.
echo 用户无需单独安装Python即可运行！
echo ================================================================================
pause
