@echo off

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
