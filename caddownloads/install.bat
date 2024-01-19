@echo off

echo Installing Git for Windows...
choco install git -y

echo Installing Node.js (latest version) for Windows...
choco install nodejs -y

echo Installing pnpm...
iwr https://get.pnpm.io/install.ps1 -useb | iex

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

node scripts/copy-env.mjs --client --api
pnpm run build

echo Installation completed.
pause
