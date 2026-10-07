@echo off
title StyleMe Backend Server
echo ==========================================
echo Starting StyleMe Backend (serverapi_ts)...
echo Connected to MySQL Database: styleme_app
echo ==========================================
cd /d "%~dp0"
npx ts-node server.ts
pause
