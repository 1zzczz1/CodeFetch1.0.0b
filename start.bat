@echo off

:: 启动后端服务
start "Backend Server" python backend\connect.py

:: 等待后端服务启动
timeout /t 3 /nobreak >nul

:: 启动Electron应用
start "PlanB App" "dist\PlanB 1.0.0.exe"

:: 退出脚本
exit