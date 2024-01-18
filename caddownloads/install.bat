@echo off
:: Change to the Documents directory
cd /d %USERPROFILE%\Documents

:: Clone the SnailyCAD repository
git clone https://github.com/SnailyCAD/snaily-cadv4.git
cd snaily-cadv4

:: Pause and ask the user to press Enter to continue
echo.
echo Press Enter to continue...
pause

:: Install project dependencies using pnpm
pnpm install

:: Pause and ask the user to press Enter to continue
echo.
echo Press Enter to continue...
pause

:: Copy .env.example to .env
copy .env.example .env

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
