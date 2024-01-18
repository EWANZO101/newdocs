@echo off

set /p CONTINUE_INSTALL=Do you want to continue with the installation? (Type 'exit' to cancel): 
if /i "%CONTINUE_INSTALL%"=="exit" (
    echo Installation cancelled. Exiting...
    timeout /t 3 /nobreak >nul
    exit
)

echo Installing Git for Windows...
choco install git -y

set /p CONTINUE_INSTALL=Do you want to continue with the installation? (Type 'exit' to cancel): 
if /i "%CONTINUE_INSTALL%"=="exit" (
    echo Installation cancelled. Exiting...
    timeout /t 3 /nobreak >nul
    exit
)

echo.
echo Installing Node.js 20.11.0...
choco install nodejs --version=20.11.0 -y

set /p CONTINUE_INSTALL=Do you want to continue with the installation? (Type 'exit' to cancel): 
if /i "%CONTINUE_INSTALL%"=="exit" (
    echo Installation cancelled. Exiting...
    timeout /t 3 /nobreak >nul
    exit
)

echo.
echo Installing pnpm...
iwr https://get.pnpm.io/install.ps1 -useb | iex

set /p CONTINUE_INSTALL=Do you want to continue with the installation? (Type 'exit' to cancel): 
if /i "%CONTINUE_INSTALL%"=="exit" (
    echo Installation cancelled. Exiting...
    timeout /t 3 /nobreak >nul
    exit
)

echo.
echo Installing PostgreSQL 16...
choco install postgresql -y

set /p CONTINUE_INSTALL=Do you want to continue with the installation? (Type 'exit' to cancel): 
if /i "%CONTINUE_INSTALL%"=="exit" (
    echo Installation cancelled. Exiting...
    timeout /t 3 /nobreak >nul
    exit
)

echo.
echo Configuring PostgreSQL...
echo Please set a password for the 'postgres' user during the installation.

:: Add PostgreSQL bin directory to the system PATH
setx /M PATH "%PATH%;C:\Program Files\PostgreSQL\*\bin"

set /p CONTINUE_INSTALL=Do you want to continue with the installation? (Type 'exit' to cancel): 
if /i "%CONTINUE_INSTALL%"=="exit" (
    echo Installation cancelled. Exiting...
    timeout /t 3 /nobreak >nul
    exit
)

:: Restart the command prompt to apply changes
echo.
echo Restarting the command prompt...
timeout /t 5 /nobreak >nul

:: Change to the Documents directory
cd /d %USERPROFILE%\Documents

:: Clone the SnailyCAD repository
git clone https://github.com/SnailyCAD/snaily-cadv4.git
cd snaily-cadv4

set /p CONTINUE_INSTALL=Do you want to continue with the installation? (Type 'exit' to cancel): 
if /i "%CONTINUE_INSTALL%"=="exit" (
    echo Installation cancelled. Exiting...
    timeout /t 3 /nobreak >nul
    exit
)

:: Pause and ask the user to press Enter to continue
echo.
echo Press Enter to continue...
pause

:: Install project dependencies using pnpm
pnpm install

set /p CONTINUE_INSTALL=Do you want to continue with the installation? (Type 'exit' to cancel): 
if /i "%CONTINUE_INSTALL%"=="exit" (
    echo Installation cancelled. Exiting...
    timeout /t 3 /nobreak >nul
    exit
)

:: Pause and ask the user to press Enter to continue
echo.
echo Press Enter to continue...
pause

:: Copy .env.example to .env
copy .env.example .env

set /p CONTINUE_INSTALL=Do you want to continue with the installation? (Type 'exit' to cancel): 
if /i "%CONTINUE_INSTALL%"=="exit" (
    echo Installation cancelled. Exiting...
    timeout /t 3 /nobreak >nul
    exit
)

:: Pause and ask the user to press Enter to continue
echo.
echo Press Enter to continue...
pause

:: Open .env file for editing with Visual Studio Code
code -r .env

:: Display message to the user
echo.
echo Please edit the .env file, then save and close it.

:: Run the build script
pnpm run build --client --api

:: Pause to keep the command prompt window open
pause

echo.
echo Installation complete. You can now close the command prompt and open the start.bat file from https://www.swiftpeakhosting.co.uk.
pause
