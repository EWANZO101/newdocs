@echo off

:mainMenu
echo Actions:
echo   1 - Continue with the installation
echo   2 - Skip a step
echo   3 - End and exit
echo   4 - Open Visual Studio Code and minimize command prompt
echo   M - Shortcuts Menu (5-17)

set /p ACTION=Choose an action:

if /i "%ACTION%"=="3" (
    echo Exiting...
    timeout /t 3 /nobreak >nul
    exit
)

if /i "%ACTION%"=="M" goto :ShortcutMenu

:: Continue with the installation
if /i "%ACTION%"=="1" goto :ContinueInstallation

:: Skip a step
if /i "%ACTION%"=="2" goto :SkipStep

:: Open Visual Studio Code and minimize command prompt
if /i "%ACTION%"=="4" (
    start code .
    echo Opening Visual Studio Code...
    echo Minimizing the command prompt...
    start /min cmd /c exit
)

echo Invalid choice. Please try again.
timeout /t 2 /nobreak >nul
goto :mainMenu

:ShortcutMenu
echo Shortcuts Menu:
echo   5 - Git Installation
echo   6 - Node.js Installation
echo   7 - pnpm Installation
echo   8 - PostgreSQL Installation
echo   9 - Configure PostgreSQL
echo   10 - Restart Command Prompt
echo   11 - Clone SnailyCAD Repository
echo   12 - Install Project Dependencies
echo   13 - Copy .env.example to .env
echo   14 - Open .env file for editing with Visual Studio Code
echo   15 - Run the build script
echo   16 - Open Visual Studio Code and minimize command prompt
echo   17 - Clear old files from CD

:shortcutMenuLoop
set /p SHORTCUT_ACTION=Choose a shortcut:

:: Handle shortcuts
if /i "%SHORTCUT_ACTION%"=="5" goto :GitInstallation
if /i "%SHORTCUT_ACTION%"=="6" goto :NodeJSInstallation
if /i "%SHORTCUT_ACTION%"=="7" goto :PnpmInstallation
if /i "%SHORTCUT_ACTION%"=="8" goto :PostgreSQLInstallation
if /i "%SHORTCUT_ACTION%"=="9" goto :ConfigurePostgreSQL
if /i "%SHORTCUT_ACTION%"=="10" goto :RestartCommandPrompt
if /i "%SHORTCUT_ACTION%"=="11" goto :CloneRepository
if /i "%SHORTCUT_ACTION%"=="12" goto :InstallDependencies
if /i "%SHORTCUT_ACTION%"=="13" goto :CopyEnvFile
if /i "%SHORTCUT_ACTION%"=="14" goto :OpenEnvFile
if /i "%SHORTCUT_ACTION%"=="15" goto :RunBuildScript
if /i "%SHORTCUT_ACTION%"=="16" goto :OpenVSCodeAndMinimize
if /i "%SHORTCUT_ACTION%"=="17" goto :ClearOldFilesFromCD

echo Invalid choice. Please try again.
timeout /t 2 /nobreak >nul
goto :shortcutMenuLoop

:ContinueInstallation
echo Continue installation logic...
goto :mainMenu

:SkipStep
echo Skip step logic...
goto :mainMenu

:GitInstallation
echo Git installation logic...
goto :mainMenu

:NodeJSInstallation
echo Node.js installation logic...
goto :mainMenu

:PnpmInstallation
echo pnpm installation logic...
goto :mainMenu

:PostgreSQLInstallation
echo PostgreSQL installation logic...
goto :mainMenu

:ConfigurePostgreSQL
echo Configure PostgreSQL logic...
goto :mainMenu

:RestartCommandPrompt
echo Restart command prompt logic...
goto :mainMenu

:CloneRepository
echo Clone repository logic...
goto :mainMenu

:InstallDependencies
echo Install dependencies logic...
goto :mainMenu

:CopyEnvFile
echo Copy .env.example to .env logic...
goto :mainMenu

:OpenEnvFile
echo Open .env file logic...
goto :mainMenu

:RunBuildScript
echo Run build script logic...
goto :mainMenu

:OpenVSCodeAndMinimize
echo Open VS Code and minimize command prompt logic...
goto :mainMenu

:ClearOldFilesFromCD
echo Clear old files from CD logic...
goto :mainMenu
