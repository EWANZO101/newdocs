@echo off
REM addLocale.bat with Auto Path Detection
REM This script performs the following:
REM 0. Automatically detects SnailyCAD v4 installation paths
REM 1. Runs existing SnailyCAD project setup commands.
REM 2. Clones the locale-manager repository.
REM 3. Runs the locale addition script.
REM 4. Replaces the i18n.config.mjs in snaily-cadv4/apps/client with the updated version.
REM 5. Checks for start.bat and downloads it if missing.
REM 6. Prompts the user to open start.bat.
REM 7. Cleans up temporary files.

SETLOCAL ENABLEDELAYEDEXPANSION

REM ================================
REM Auto-Detect SnailyCAD v4 Path
REM ================================
echo.
echo ================================
echo Detecting SnailyCAD v4 Installation
echo ================================
echo.

REM Create a temporary file to store found paths
SET "TEMP_PATHS=%TEMP%\snailycad_paths.txt"
IF EXIST "%TEMP_PATHS%" DEL "%TEMP_PATHS%"

REM Search for snaily-cadv4 or snailycadv4 directories on common drives
echo Searching for SnailyCAD v4 installations...
echo This may take a moment...
echo.

SET "SEARCH_COUNT=0"

REM Search in user directories first (faster)
FOR %%D IN (
    "%USERPROFILE%\Documents"
    "%USERPROFILE%\Desktop"
    "%USERPROFILE%"
    "C:\Users"
    "C:\Projects"
    "C:\Dev"
    "D:\Projects"
    "D:\Dev"
    "E:\Projects"
    "E:\Dev"
) DO (
    IF EXIST "%%~D" (
        FOR /F "delims=" %%P IN ('dir /b /s /a:d "%%~D\*snaily*cad*v4*" 2^>nul ^| findstr /I "snaily.*cad.*v4 snailycadv4"') DO (
            IF EXIST "%%P\package.json" (
                findstr /C:"@snailycad/types" "%%P\package.json" >nul 2>&1
                IF !ERRORLEVEL! EQU 0 (
                    echo %%P>> "%TEMP_PATHS%"
                    SET /A SEARCH_COUNT+=1
                )
            )
        )
    )
)

REM Check if any paths were found
IF NOT EXIST "%TEMP_PATHS%" (
    echo [ERROR] No SnailyCAD v4 installation found!
    echo.
    echo Please ensure SnailyCAD v4 is installed on your system.
    echo Common installation locations:
    echo   - %USERPROFILE%\Documents\snaily-cadv4
    echo   - %USERPROFILE%\Desktop\snaily-cadv4
    echo   - C:\Projects\snaily-cadv4
    echo.
    PAUSE
    EXIT /B 1
)

REM Count the number of found paths
SET "PATH_COUNT=0"
FOR /F %%A IN ('type "%TEMP_PATHS%" ^| find /c /v ""') DO SET "PATH_COUNT=%%A"

REM Handle multiple installations
IF %PATH_COUNT% GTR 1 (
    echo [WARNING] Multiple SnailyCAD v4 installations found:
    echo.
    SET "INDEX=0"
    FOR /F "delims=" %%P IN ('type "%TEMP_PATHS%"') DO (
        SET /A INDEX+=1
        echo   [!INDEX!] %%P
    )
    echo.
    echo Please select which installation to use:
    SET /P SELECTION="Enter number (1-%PATH_COUNT%): "
    
    SET "SELECTED_PATH="
    SET "INDEX=0"
    FOR /F "delims=" %%P IN ('type "%TEMP_PATHS%"') DO (
        SET /A INDEX+=1
        IF !INDEX! EQU !SELECTION! SET "SELECTED_PATH=%%P"
    )
    
    IF "!SELECTED_PATH!"=="" (
        echo Invalid selection. Exiting...
        DEL "%TEMP_PATHS%"
        PAUSE
        EXIT /B 1
    )
    
    SET "SNAILYCAD_PATH=!SELECTED_PATH!"
) ELSE (
    REM Only one installation found
    FOR /F "delims=" %%P IN ('type "%TEMP_PATHS%"') DO SET "SNAILYCAD_PATH=%%P"
    echo [32m[✓] Found SnailyCAD v4 installation:[0m
    echo     !SNAILYCAD_PATH!
    echo.
)

REM Clean up temp file
DEL "%TEMP_PATHS%"

REM ================================
REM Existing Project Setup Section
REM ================================
echo.
echo ================================
echo Starting SnailyCAD Project Setup
echo ================================
echo.

REM Navigate to the detected snaily-cadv4 project directory
cd /D "!SNAILYCAD_PATH!"
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to navigate to SnailyCAD directory.
    PAUSE
    EXIT /B 1
)

echo Current directory: !SNAILYCAD_PATH!
echo.

REM Execute the copy-env script for client and API
echo Running copy-env.mjs for client and API...
node scripts/copy-env.mjs --client --api
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to run copy-env.mjs. Please ensure Node.js is installed and the script exists.
    PAUSE
    EXIT /B 1
)

REM Pull the latest changes from the main branch
echo Pulling latest changes from Git...
git pull origin main
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to pull from Git. Please check your network connection and repository status.
    PAUSE
    EXIT /B 1
)

REM Stash any local changes and pull again to ensure the latest updates
echo Stashing local changes and pulling latest updates...
git stash && git pull origin main
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to stash or pull from Git. Please resolve any Git conflicts manually.
    PAUSE
    EXIT /B 1
)

REM Install project dependencies using pnpm
echo Installing project dependencies with pnpm...
pnpm install
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to install dependencies. Please ensure pnpm is installed correctly.
    PAUSE
    EXIT /B 1
)

REM Build the project
echo Building the project...
pnpm run build
IF %ERRORLEVEL% NEQ 0 (
    echo Build process failed. Please check the build scripts and dependencies.
    PAUSE
    EXIT /B 1
)

echo.
echo [32m[✓] All processes are completed.[0m
echo.
PAUSE

REM ================================
REM Post-Setup: Checking for start.bat
REM ================================
echo.
echo ================================
echo Post-Setup: Checking for start.bat
echo ================================
echo.

REM Define the path to start.bat
SET "START_BAT_PATH=!SNAILYCAD_PATH!\start.bat"

REM Check if start.bat exists
IF NOT EXIST "!START_BAT_PATH!" (
    echo start.bat not found. Downloading from GitHub...
    REM Download start.bat using PowerShell
    powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/EWANZO101/newdocs/main/caddownloads/start.bat' -OutFile '!START_BAT_PATH!'"
    IF %ERRORLEVEL% NEQ 0 (
        echo Failed to download start.bat. Please check your internet connection and try again.
        PAUSE
        EXIT /B 1
    )
    echo [32m[✓] start.bat has been downloaded successfully.[0m
) ELSE (
    echo [32m[✓] start.bat already exists.[0m
)

REM Prompt the user to open start.bat
set /p user_input=Do you want to open start.bat? (y/n): 
if /i "%user_input%"=="y" (
    start "" "!START_BAT_PATH!"
) else if /i "%user_input%"=="n" (
    echo Updater closed.
) else (
    echo Invalid input. Updater closed.
)

echo Press Enter to close the prompt.
pause >nul

ENDLOCAL
exit
