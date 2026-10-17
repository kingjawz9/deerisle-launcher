@echo off
setlocal enableextensions
cd /d "%~dp0"
title Banov
echo ===============================
echo           BANOV
echo ===============================
echo.
call :makeicon
call :fetchscripts
call :updatelist
call :cleanstale
call :checkmods
call :checkrefresh
if defined DZ_TEST exit /b 0
if defined NEEDMODS goto needmods
call :markrefresh
call "%~dp02b_START_DAYZ_MENU.bat"
exit /b 0

:needmods
echo.
echo Some mods are new or missing. They have to be downloaded first.
echo This is normal after the server adds something. Follow the steps in the next window.
echo.
pause
call "%~dp0Update_Missing_Mods.bat"
call :checkmods
if defined NEEDMODS goto stillmissing
call :markrefresh
call "%~dp02b_START_DAYZ_MENU.bat"
exit /b 0

:stillmissing
echo.
echo Still missing some mods. Send a screenshot of this window to KingJawz.
type missing.txt
pause
exit /b 1

:makeicon
if defined DZ_TEST exit /b 0
powershell -NoProfile -Command "$d=[Environment]::GetFolderPath('Desktop'); $p=$d+'\Banov.lnk'; if(-not (Test-Path $p)){$s=(New-Object -ComObject WScript.Shell).CreateShortcut($p); $s.TargetPath='%~dp0PLAY_DEERISLE.bat'; $s.WorkingDirectory='%~dp0'; $s.IconLocation='%SystemRoot%\System32\shell32.dll,13'; $s.Save(); Write-Host 'Made a Banov icon on your desktop.'}" 2>nul
exit /b 0

:updatelist
if not exist mod_list_url.txt exit /b 0
set "URL="
set /p URL=<mod_list_url.txt
if not defined URL exit /b 0
echo Checking for mod list updates...
if exist mods.new del mods.new
curl.exe -L -f -s -m 25 -o mods.new "%URL%"
if errorlevel 1 goto updfail
if exist mods.chk del mods.chk
set /a N=0
for /f "delims=" %%c in (mods.new) do call :addid %%c
if %N% LSS 50 goto updfail
copy /y mods.txt mods.old >nul 2>nul
move /y mods.chk mods.txt >nul
del mods.new 2>nul
echo Mod list is up to date: %N% mods.
exit /b 0
:updfail
echo Could not check for updates right now. Using the saved list.
if exist mods.new del mods.new
if exist mods.chk del mods.chk
exit /b 0

:checkmods
set "NEEDMODS="
set "MODROOT=%~dp0mods\steamapps\workshop\content\221100"
if exist missing.txt del missing.txt
for /f %%i in (mods.txt) do if not exist "%MODROOT%\%%i\meta.cpp" call :addmissing %%i
exit /b 0
:addmissing
>>missing.txt echo %1
set "NEEDMODS=1"
exit /b 0
:cleanstale
rem stale.txt on GitHub: old mod files the author removed or renamed. Left behind they cause "Multiple declaration" errors, so delete them.
if not exist mod_list_url.txt exit /b 0
set "URL="
set /p URL=<mod_list_url.txt
if not defined URL exit /b 0
set "SURL=%URL:mods.txt=stale.txt%"
set "MODROOT=%~dp0mods\steamapps\workshop\content\221100"
if exist stale.new del stale.new
curl.exe -L -f -s -m 25 -o stale.new "%SURL%"
if errorlevel 1 goto stalefail
for /f "delims=" %%f in (stale.new) do call :delstale "%%f"
:stalefail
if exist stale.new del stale.new
exit /b 0
:delstale
set "SF=%~1"
if not defined SF exit /b 0
echo %SF%| findstr /c:".." >nul
if not errorlevel 1 exit /b 0
if exist "%MODROOT%\%SF%" del /f /q "%MODROOT%\%SF%" >nul 2>nul
exit /b 0
:checkrefresh
rem refresh.txt on GitHub: first line = version tag, then the mod IDs that changed. A new tag = download those mods again.
set "RTAG="
set "RSKIP="
set "RFIRST=1"
if not exist mod_list_url.txt exit /b 0
set "URL="
set /p URL=<mod_list_url.txt
if not defined URL exit /b 0
set "RURL=%URL:mods.txt=refresh.txt%"
if exist refresh.new del refresh.new
curl.exe -L -f -s -m 25 -o refresh.new "%RURL%"
if errorlevel 1 goto reffail
set "RDONE="
if exist refresh_done.txt set /p RDONE=<refresh_done.txt
for /f "delims=" %%c in (refresh.new) do call :refline %%c
:reffail
if exist refresh.new del refresh.new
exit /b 0
:refline
echo %1| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 exit /b 0
if not defined RFIRST goto refid
set "RFIRST="
set "RTAG=%1"
if "%1"=="%RDONE%" set "RSKIP=1"
exit /b 0
:refid
if defined RSKIP exit /b 0
>>missing.txt echo %1
set "NEEDMODS=1"
exit /b 0
:markrefresh
if defined RTAG if not defined RSKIP >refresh_done.txt echo %RTAG%
exit /b 0
:addid
echo %1| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 exit /b 0
>>mods.chk echo %1
set /a N+=1
exit /b 0

:fetchscripts
rem pull the other scripts from GitHub too, so nothing ever has to be swapped by hand
if not exist mod_list_url.txt exit /b 0
set "URL="
set /p URL=<mod_list_url.txt
if not defined URL exit /b 0
set "BASE=%URL:mods.txt=%"
call :fetchone 2b_START_DAYZ_MENU.bat
call :fetchone Update_Missing_Mods.bat
exit /b 0
:fetchone
if exist "%1.new" del "%1.new"
curl.exe -L -f -s -m 25 -o "%1.new" "%BASE%%1"
if exist "%1.new" move /y "%1.new" "%1" >nul
exit /b 0
