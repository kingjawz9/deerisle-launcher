@echo off
setlocal enableextensions
cd /d "%~dp0"
title Download new server mods
if not exist missing.txt (
  echo Nothing to download.
  pause
  exit /b 0
)
echo ===== Downloading the new mods =====
echo This uses your own Steam account. Steam will ask for your password and a Steam Guard code in this window.
echo Only Steam sees them. Leave the window open until it says it is finished.
echo.
if exist steamcmd\steamcmd.exe goto havesteamcmd
echo Getting SteamCMD...
mkdir steamcmd 2>nul
powershell -NoProfile -Command "Invoke-WebRequest https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip -OutFile steamcmd\s.zip; Expand-Archive steamcmd\s.zip steamcmd -Force"
steamcmd\steamcmd.exe +quit
:havesteamcmd
set /p SU=Your Steam username: 
if exist cmds.txt del cmds.txt
>>cmds.txt echo force_install_dir "%~dp0mods"
>>cmds.txt echo login %SU%
for /f %%i in (missing.txt) do >>cmds.txt echo workshop_download_item 221100 %%i validate
>>cmds.txt echo quit
"%~dp0steamcmd\steamcmd.exe" +runscript "%~dp0cmds.txt"
if exist cmds.txt del cmds.txt
echo.
echo Finished. Press any key to continue.
pause >nul
exit /b 0
