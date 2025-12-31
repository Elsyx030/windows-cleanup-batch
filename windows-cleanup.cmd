@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ==================================================
REM  windows-cleanup-batch v1.2
REM
REM  Features:
REM   - Disk Cleanup via CleanMgr (profile 99)
REM   - TEMP cleanup (user + system)
REM   - Safe system caches
REM   - Extended system cleanup (WER, logs, caches)
REM   - Space Report (before/after, MB)
REM ==================================================

title Windows Cleanup Tool

REM ---------- Admin Check ----------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Please run this script as Administrator.
    pause
    exit /b 1
)

REM ---------- Measure free space BEFORE ----------
for /f %%A in ('powershell -NoProfile -Command "(Get-PSDrive C).Free"') do set FREE_BEFORE=%%A

REM ---------- Logging ----------
set "LOGROOT=%ProgramData%\windows-cleanup-batch\logs"
if not exist "%LOGROOT%" mkdir "%LOGROOT%" >nul 2>&1

for /f %%A in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HHmmss"') do set TS=%%A
set "LOG=%LOGROOT%\cleanup_%TS%.log"

echo ==== windows-cleanup-batch v1.2 ==== > "%LOG%"
echo Start: %DATE% %TIME% >> "%LOG%"
echo. >> "%LOG%"

echo [INFO] Log: "%LOG%"

REM ---------- Disk Cleanup ----------
echo [INFO] Running Disk Cleanup (CleanMgr profile 99)...
echo [INFO] Running Disk Cleanup (CleanMgr profile 99)... >> "%LOG%"

where cleanmgr >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] cleanmgr not found.
    echo [ERROR] cleanmgr not found. >> "%LOG%"
    pause
    exit /b 2
)

cleanmgr /sagerun:99 >> "%LOG%" 2>&1

REM ---------- TEMP Cleanup ----------
echo [INFO] Clearing TEMP folders...
echo [INFO] Clearing TEMP folders... >> "%LOG%"

call :ClearFolder "%TEMP%" "User TEMP"
call :ClearFolder "C:\Windows\Temp" "Windows TEMP"

REM ---------- Safe System Caches ----------
echo [INFO] Clearing safe system caches...
echo [INFO] Clearing safe system caches... >> "%LOG%"

call :ClearFolder "C:\Windows\SoftwareDistribution\Download" "Windows Update Cache"
call :ClearFolder "C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache" "Delivery Optimization Cache"

REM ---------- Extended System Cleanup (v1.2) ----------
echo [INFO] Running extended system cleanup...
echo [INFO] Running extended system cleanup... >> "%LOG%"

call :ClearFolder "C:\ProgramData\Microsoft\Windows\WER\ReportQueue" "WER ReportQueue"
call :ClearFolder "C:\ProgramData\Microsoft\Windows\WER\ReportArchive" "WER ReportArchive"
call :ClearFolder "C:\Windows\Logs\CBS" "CBS Logs"
call :ClearFolder "C:\Windows\Panther" "Windows Panther Logs"
call :ClearFolder "C:\ProgramData\Microsoft\Windows\Caches" "Windows Caches"

REM ---------- Measure free space AFTER ----------
for /f %%A in ('powershell -NoProfile -Command "(Get-PSDrive C).Free"') do set FREE_AFTER=%%A

REM ---------- Calculate & display Space Report ----------
set /a BEFORE_MB=FREE_BEFORE/1024/1024
set /a AFTER_MB=FREE_AFTER/1024/1024
set /a FREED_MB=AFTER_MB-BEFORE_MB

echo.
echo ================================
echo  Space Report (C:)
echo ================================
echo Free before: %BEFORE_MB% MB
echo Free after : %AFTER_MB% MB
echo Freed      : %FREED_MB% MB
echo ================================
echo.

echo Space Report (C:) >> "%LOG%"
echo Free before: %BEFORE_MB% MB >> "%LOG%"
echo Free after : %AFTER_MB% MB >> "%LOG%"
echo Freed      : %FREED_MB% MB >> "%LOG%"
echo End: %DATE% %TIME% >> "%LOG%"

echo [OK] Cleanup finished.
pause
exit /b 0


REM ---------- Helper: ClearFolder ----------
:ClearFolder
set "TARGET=%~1"
set "LABEL=%~2"

echo [INFO] %LABEL%: %TARGET%
echo [INFO] %LABEL%: %TARGET% >> "%LOG%"

if not exist "%TARGET%" (
    echo [WARN] Path not found: %TARGET%
    echo [WARN] Path not found: %TARGET% >> "%LOG%"
    goto :eof
)

del /f /s /q "%TARGET%\*" >nul 2>&1
for /d %%D in ("%TARGET%\*") do rd /s /q "%%D" >nul 2>&1

goto :eof
