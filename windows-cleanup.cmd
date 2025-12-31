@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ======================================
REM  windows-cleanup-batch v1.1
REM  Feature:
REM   - Shows freed disk space on drive C:
REM ======================================

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

echo ==== windows-cleanup-batch v1.1 ==== > "%LOG%"
echo Start: %DATE% %TIME% >> "%LOG%"
echo. >> "%LOG%"

echo [INFO] Log: "%LOG%"
echo [INFO] Running Disk Cleanup (profile 99)...
echo [INFO] Running Disk Cleanup (profile 99)... >> "%LOG%"

REM ---------- Disk Cleanup ----------
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

echo [INFO] User TEMP: %TEMP%
echo [INFO] User TEMP: %TEMP% >> "%LOG%"
del /f /s /q "%TEMP%\*" >nul 2>&1
for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" >nul 2>&1

echo [INFO] Windows TEMP: C:\Windows\Temp
echo [INFO] Windows TEMP: C:\Windows\Temp >> "%LOG%"
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
for /d %%D in ("C:\Windows\Temp\*") do rd /s /q "%%D" >nul 2>&1

REM ---------- Extra safe system caches ----------
echo [INFO] Clearing extra system caches...
echo [INFO] Clearing extra system caches... >> "%LOG%"

del /f /s /q "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
for /d %%D in ("C:\Windows\SoftwareDistribution\Download\*") do rd /s /q "%%D" >nul 2>&1

del /f /s /q "C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache\*" >nul 2>&1
for /d %%D in ("C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache\*") do rd /s /q "%%D" >nul 2>&1

REM ---------- Measure free space AFTER ----------
for /f %%A in ('powershell -NoProfile -Command "(Get-PSDrive C).Free"') do set FREE_AFTER=%%A

REM ---------- Calculate & display result ----------
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
