@echo off
cd Documents
cd snaily-cadv4
node scripts/copy-env.mjs --client --api
git pull origin main
git stash && git pull origin main
pnpm install
pnpm run build

echo All processes are completed.

pause

set /p user_input=Do you want to open start.bat? (y/n): 
if /i "%user_input%"=="y" (
    start "" "C:\Users\Administrator\Documents\snaily-cadv4\start.bat"
) else if /i "%user_input%"=="n" (
    echo Updater closed.
) else (
    echo Invalid input. Updater closed.
)

echo Press Enter to close the prompt.
pause >nul
exit
