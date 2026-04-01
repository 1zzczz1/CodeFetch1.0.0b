@echo off
chcp 65001 > nul
echo ================================================================================
echo CodeFetch 安装程序
echo ================================================================================
echo.

:: 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 请以管理员身份运行此安装程序！
    echo 右键点击此文件，选择"以管理员身份运行"。
    pause
    exit /b 1
)

:: 设置安装目录
set "INSTALL_DIR=%ProgramFiles%\CodeFetch"
echo 安装目录: %INSTALL_DIR%
echo.

:: 创建安装目录
if not exist "%INSTALL_DIR%" (
    echo 创建安装目录...
    mkdir "%INSTALL_DIR%"
    if %errorlevel% neq 0 (
        echo 无法创建安装目录，请以管理员身份运行此脚本。
        pause
        exit /b 1
    )
)

:: 复制应用文件
echo 1. 复制应用文件...
echo 正在复制应用程序文件到 %INSTALL_DIR%...

:: 复制主文件
xcopy "main.js" "%INSTALL_DIR%" /Y
xcopy "preload.js" "%INSTALL_DIR%" /Y
xcopy "package.json" "%INSTALL_DIR%" /Y

:: 复制后端文件
if not exist "%INSTALL_DIR%\backend" mkdir "%INSTALL_DIR%\backend"
xcopy "backend\*" "%INSTALL_DIR%\backend" /E /Y

:: 复制前端文件
if not exist "%INSTALL_DIR%\frontend" mkdir "%INSTALL_DIR%\frontend"
xcopy "frontend\*" "%INSTALL_DIR%\frontend" /E /Y

:: 复制依赖文件
xcopy "requirements.txt" "%INSTALL_DIR%" /Y

:: 复制安装脚本
xcopy "install_dependencies.bat" "%INSTALL_DIR%" /Y

:: 复制图标文件
if not exist "%INSTALL_DIR%\frontend\picture" mkdir "%INSTALL_DIR%\frontend\picture"
xcopy "frontend\picture\icon.png" "%INSTALL_DIR%\frontend\picture" /Y

echo 应用文件复制完成！
echo.

:: 检测并安装Python依赖
echo 2. 检测设备Python环境...
echo ================================================================================
call :check_and_install_python
echo ================================================================================
echo.

:: 创建桌面快捷方式
echo 3. 创建桌面快捷方式...
set "SHORTCUT_NAME=CodeFetch.lnk"
set "SHORTCUT_PATH=%USERPROFILE%\Desktop\%SHORTCUT_NAME%"
set "TARGET_EXE=%INSTALL_DIR%\CodeFetch.exe"

:: 检查应用程序是否存在
if exist "%TARGET_EXE%" (
    :: 使用PowerShell创建快捷方式
    powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%SHORTCUT_PATH%'); $Shortcut.TargetPath = '%TARGET_EXE%'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.IconLocation = '%INSTALL_DIR%\frontend\picture\icon.png'; $Shortcut.Save()"
    echo 桌面快捷方式创建成功！
) else (
    echo 警告：应用程序可执行文件不存在，跳过快捷方式创建。
    echo 请先运行 electron-builder 构建应用程序。
)

echo.
echo ================================================================================
echo 安装完成！
echo --------------------------------------------------------------------------------
echo 应用已安装到: %INSTALL_DIR%
echo 桌面快捷方式已创建: %SHORTCUT_PATH%
echo --------------------------------------------------------------------------------
echo 注意：
echo 1. 第一次运行应用时，可能需要等待后端服务启动
echo 2. 如果应用无法启动，请检查Python是否正确安装
echo 3. 如需卸载应用，请删除 %INSTALL_DIR% 目录
echo 4. 如需重新安装依赖，请运行 %INSTALL_DIR%\install_dependencies.bat
echo ================================================================================
echo.
pause
goto :eof

:: 检测并安装Python的函数
:check_and_install_python
setlocal EnableDelayedExpansion

:: 检查Python是否安装
set "python_found=false"
set "python_version="

echo 2.1 检查Python安装状态...
for /f "tokens=*" %%i in ('where python 2^>nul') do (
    set "python_found=true"
    for /f "tokens=*" %%j in ('python --version 2^>^&1') do set "python_version=%%j"
    goto python_check_done
)

:python_check_done
if "%python_found%" equ "false" (
    echo 未找到Python安装。正在下载并安装Python 3.10...
    echo 请稍候，这可能需要几分钟时间...
    
    :: 下载Python安装包
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe' -OutFile '%INSTALL_DIR%\python-installer.exe'"
    
    :: 安装Python
    "%INSTALL_DIR%\python-installer.exe" /quiet InstallAllUsers=1 PrependPath=1
    
    :: 清理安装文件
    del "%INSTALL_DIR%\python-installer.exe"
    
    echo Python安装完成！
    :: 重新检查Python
    for /f "tokens=*" %%i in ('where python 2^>nul') do (
        set "python_found=true"
        for /f "tokens=*" %%j in ('python --version 2^>^&1') do set "python_version=%%j"
    )
) else (
    echo Python已安装: %python_version%
)

:: 检查pip是否可用
echo.
echo 2.2 检查pip可用性...
python -m pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 正在安装pip...
    powershell -Command "Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile '%INSTALL_DIR%\get-pip.py'"
    python "%INSTALL_DIR%\get-pip.py"
    del "%INSTALL_DIR%\get-pip.py"
    echo pip安装完成！
) else (
    echo pip已可用
)

:: 升级pip
echo.
echo 2.3 升级pip...
python -m pip install --upgrade pip

:: 安装必要的依赖
echo.
echo 2.4 安装应用依赖...
echo 正在安装Flask, Flask-CORS, pymysql, cryptography, pyjwt...
python -m pip install flask flask-cors pymysql cryptography pyjwt

:: 验证安装
echo.
echo 2.5 验证依赖安装...
python -c "
try:
    import flask
    import flask_cors
    import pymysql
    import cryptography
    import jwt
    print('所有依赖安装成功！')
except ImportError as e:
    print('依赖安装失败:', e)
    exit(1)
"

if %errorlevel% neq 0 (
    echo 依赖安装失败，请检查网络连接或手动安装依赖。
    echo 依赖列表: flask flask-cors pymysql cryptography pyjwt
)

endlocal
goto :eof