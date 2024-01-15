@echo off
SETLOCAL EnableDelayedExpansion

rem Function to check if a command is available
:CheckCommand
where %1 >nul 2>nul
if %errorlevel% neq 0 (
    set Missing=!Missing! %1
)

rem Check and install Git
call :CheckCommand git
rem Check and install Node.js
call :CheckCommand node
rem Check and install Yarn
call :CheckCommand yarn

rem Check if anything is missing
if not "%Missing%"=="" (
    echo The following dependencies are missing:%Missing%
    echo Please install the missing dependencies and press Enter to continue...
    pause
)

rem Continue with the script
cd Documents

rem Clone the repository
git clone https://github.com/SnailyCAD/snailycad-bot.git
cd snailycad-bot

rem Install dependencies
yarn

rem Copy .env.example to .env
copy .env.example .env

rem Edit .env with Notepad (replace with your preferred text editor)
notepad .env

echo Press Enter after editing the .env file...

rem Build the project
yarn build

rem Install pm2
npm install -g pm2

echo Installation completed successfully.

ENDLOCAL
