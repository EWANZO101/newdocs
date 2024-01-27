@echo off
cd Documents
cd snaily-cadv4

rem Check for errors during pnpm install
pnpm install
if not %errorlevel% == 0 (
    echo Something went wrong during the installation.
    pause
    exit /b %errorlevel%
)

echo Installation completed successfully.
pause
