@echo off
setlocal
cd /d "%~dp0"
set "MODROOT=%~dp0mods\steamapps\workshop\content\221100"
if exist "dayz_path.txt" set /p DAYZ=<dayz_path.txt
if not defined DAYZ if exist "C:\Program Files (x86)\Steam\steamapps\common\DayZ\DayZ_BE.exe" set "DAYZ=C:\Program Files (x86)\Steam\steamapps\common\DayZ"
if defined DAYZ goto havepath
echo Could not find DayZ automatically.
echo Paste the folder that contains DayZ_BE.exe, then press Enter.
echo Steam: right click DayZ, Manage, Browse local files, click the address bar and copy it.
set /p DAYZ=Folder:
:havepath
set "DAYZ=%DAYZ:"=%"
if exist "%DAYZ%\DayZ_BE.exe" goto okpath
echo.
echo DayZ_BE.exe was not found in that folder.
echo Delete dayz_path.txt in this folder and run this file again.
pause
exit /b 1
:okpath
>dayz_path.txt echo %DAYZ%
if exist password.txt set /p PW=<password.txt
if "%PW%"=="" set /p PW=Server password:
if defined PW >password.txt echo %PW%
set "PWARG=-password=%PW%"
if defined NOPW set "PWARG="
set /p NAME=<player_name.txt 2>nul
if defined NAME goto havename
set /p NAME=Pick your in-game name:
:havename
>player_name.txt echo %NAME%
set "MODLINK=%SystemDrive%\dzm"
if exist "%MODLINK%" rmdir "%MODLINK%"
mklink /J "%MODLINK%" "%MODROOT%" >nul
set "MODS="
for /f %%i in (mods.txt) do call set "MODS=%%MODS%%;%MODLINK%\%%i"
set "MODS=%MODS:~1%"
cd /d "%DAYZ%"
echo.
echo DayZ will open to the main menu. Wait until it is fully loaded, then choose:
echo   PLAY  then  DIRECT CONNECT  then type  207.244.245.37:28100  then the server password.
echo.
start "" DayZ_BE.exe -name=%NAME% -nosplash -skipIntro "-mod=%MODS%"
