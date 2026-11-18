@echo off
title Charting Craft
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serveur-windows.ps1"
if errorlevel 1 pause
