@echo off
title Windows Cleanup Tool
color 0A

echo ================================
echo  Windows Datenträgerbereinigung
echo ================================
echo.

REM --- Check for Admin ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [FEHLER] Bitte als Administrator ausführen!
    pause
    exit /b
)

echo [INFO] Starte Datenträgerbereinigung (Profil 99)...
cleanmgr /sagerun:99

echo.
echo ================================
echo  Leere TEMP-Ordner
echo ================================
echo.

REM --- User TEMP ---
echo [INFO] Leere Benutzer-TEMP...
del /f /s /q "%TEMP%\*" >nul 2>&1
for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" >nul 2>&1

REM --- Windows TEMP ---
echo [INFO] Leere Windows-TEMP...
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
for /d %%D in ("C:\Windows\Temp\*") do rd /s /q "%%D" >nul 2>&1

echo.
echo [OK] Bereinigung abgeschlossen.
pause
