@echo off
:menu
cls
echo 1. Install Git for Windows
echo 2. Install Node.js latest for Windows
echo 3. Exit
echo 4. Open Visual Studio Code
echo 5. Open Shortcut Menu
set /p choice=Enter the number of your choice: 

if "%choice%"=="1" (
    echo Installing Git for Windows...
    REM Add the command to install Git for Windows
    REM Example: choco install git -y
    pause
) else if "%choice%"=="2" (
    echo Installing Node.js latest for Windows...
    REM Add the command to install Node.js for Windows
    REM Example: choco install nodejs -y
    pause
) else if "%choice%"=="3" (
    exit
) else if "%choice%"=="4" (
    code
    pause
) else if "%choice%"=="5" (
    :shortcut_menu
    cls
    echo 1. Install pnpm
    echo 2. Install PostgreSQL 16 latest
    echo 3. Clone SnailyCAD repository and install dependencies
    echo 4. Copy .env.example to .env
    echo 5. Open Visual Studio Code
    echo 6. Execute SnailyCAD setup script
    echo 7. Close and get start.bat from https://www.swiftpeakhosting.co.uk/Downloads
    set /p sub_choice=Enter the number of your choice: 

    if "%sub_choice%"=="1" (
        echo Installing pnpm...
        iwr https://get.pnpm.io/install.ps1 -useb | iex
        pause
    ) else if "%sub_choice%"=="2" (
        echo Installing PostgreSQL 16 latest...
        REM Add the command to install PostgreSQL
        pause
    ) else if "%sub_choice%"=="3" (
        cd Documents
        git clone https://github.com/SnailyCAD/snaily-cadv4.git
        cd snaily-cadv4
        pnpm install
        pause
    ) else if "%sub_choice%"=="4" (
        copy .env.example .env
        pause
    ) else if "%sub_choice%"=="5" (
        code
        pause
    ) else if "%sub_choice%"=="6" (
        echo Running SnailyCAD setup script...
        node scripts/copy-env.mjs --client --api
        pnpm run build
        pause
    ) else if "%sub_choice%"=="7" (
        echo Close this window and get start.bat from https://www.swiftpeakhosting.co.uk/Downloads
        pause
    ) else (
        echo Invalid choice. Please try again.
        goto shortcut_menu
    )
    goto shortcut_menu
) else (
    echo Invalid choice. Please try again.
    goto menu
)
goto menu
