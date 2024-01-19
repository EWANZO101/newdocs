@echo off

REM Check if Node.js is installed
where node > nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Node.js is not installed or not in the system PATH.
    echo Please install Node.js and ensure it is added to the PATH.
    pause
    exit /b 1
)

REM Check Node.js version
echo Checking Node.js version...
node -v

REM Open download pages in the default web browser
echo Opening Git for Windows download page...
start https://git-scm.com/downloads

echo Opening Node.js (v20.11.0) download page...
start https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi

echo Opening pnpm installation page in PowerShell...
start powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr https://get.pnpm.io/install.ps1 -useb | iex"

echo Opening PostgreSQL download page...
start https://sbp.enterprisedb.com/getfile.jsp?fileid=1258792

echo.
echo After installing the required software, press Enter to continue...
pause > nul

REM Continue with the rest of the script
cd Documents

git clone https://github.com/SnailyCAD/snaily-cadv4.git
cd snaily-cadv4

pnpm install
copy .env.example .env

echo Opening .env in Visual Studio Code...
start code .env

echo.
echo After editing the .env file, press Enter to continue...
pause > nul

echo Running additional commands...
node scripts/copy-env.mjs --client --api
pnpm run build

echo Installation completed.
pause
