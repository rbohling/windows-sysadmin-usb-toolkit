@echo off
where pwsh.exe >nul 2>&1
if not errorlevel 1 (
  pwsh.exe -NoLogo -NoProfile -File "%~dp0Launch.ps1" %*
  exit /b
)
powershell.exe -NoLogo -NoProfile -File "%~dp0Launch.ps1" %*
