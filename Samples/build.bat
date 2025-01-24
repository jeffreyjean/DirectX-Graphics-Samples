@echo off

set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

echo Retarget the solution files
powershell -ExecutionPolicy Bypass -File "retarget.ps1"

echo This will generate the build script build.cmd to compile each project and lunch binaries after built.
powershell -ExecutionPolicy Bypass -File "build.ps1"

echo Start task manager
start taskmgr

echo Kick-off build.cmd
call ".\build.cmd"

echo Continue other task here..
