@echo off

REM Change the drive and directory to Documents
cd /d C:\Documents


REM Clone the repository
git clone https://github.com/SnailyCAD/snaily-cadv4.git
cd snaily-cadv4

REM Install dependencies
pnpm install

REM Copy the example environment file
copy .env.example .env

REM Open .env in Visual Studio Code
echo Opening .env in Visual Studio Code...
start code .env

REM Prompt the user to edit the .env file
echo.
echo After editing the .env file, press Enter to continue...
pause > nul

REM Run additional commands
echo Running additional commands...
node scripts/copy-env.mjs --client --api
pnpm run build

echo Installation completed.
pause
