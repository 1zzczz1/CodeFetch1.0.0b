@echo off
chcp 65001 > nul
echo ================================================================================
echo CodeFetch 依赖安装脚本
echo ================================================================================
echo.

:: 检查Python是否安装
set "python_found=false"
set "python_version="

echo 1. 检查Python安装状态...
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
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe' -OutFile 'python-installer.exe'"
    
    :: 安装Python
    python-installer.exe /quiet InstallAllUsers=1 PrependPath=1
    
    :: 清理安装文件
    del python-installer.exe
    
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
echo 2. 检查pip可用性...
python -m pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 正在安装pip...
    powershell -Command "Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile 'get-pip.py'"
    python get-pip.py
    del get-pip.py
    echo pip安装完成！
) else (
    echo pip已可用
)

:: 升级pip
echo.
echo 3. 升级pip...
python -m pip install --upgrade pip

:: 安装必要的依赖
echo.
echo 4. 安装应用依赖...
echo 正在安装Flask, Flask-CORS, pymysql, cryptography, pyjwt...
python -m pip install flask flask-cors pymysql cryptography pyjwt

:: 验证安装
echo.
echo 5. 验证依赖安装...
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
"

echo.
echo ================================================================================
echo 安装完成！
echo 您现在可以运行 CodeFetch 应用了。
echo ================================================================================
echo.
pause