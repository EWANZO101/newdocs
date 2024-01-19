@echo off
cd Documents

:menu
cls
echo 1. Continue
echo 2. Skip
echo 3. Stop
echo 4. Open .env in Visual Studio Code

set /p choice=Enter your choice (1, 2, 3, or 4): 

if "%choice%"=="1" goto continue
if "%choice%"=="2" goto skip
if "%choice%"=="3" goto stop
if "%choice%"=="4" goto open_env
goto menu
cd Documents
:continue
echo Cloning repository...
git clone https://github.com/SnailyCAD/snaily-cadv4.git

echo Navigating to snaily-cadv4 directory...
cd snaily-cadv4

echo Installing dependencies...
pnpm install

echo Copying .env.example to .env...
copy .env.example .env

echo Opening .env in Visual Studio Code...
start /min code .env

echo.
echo After editing the .env file, press Enter to continue...
pause > nul

echo Running additional commands...
node scripts/copy-env.mjs --client --api
pnpm run build

echo Installation completed.
pause
goto end

:skip
echo Skipping installation...
REM Add commands to skip installation if needed
goto end

:stop
echo Stopping installation...
REM Add commands to stop installation if needed
goto end

:open_env
echo Opening .env in Visual Studio Code...
start /min code .env
goto end

:end
echo Installation script completed.
pause
