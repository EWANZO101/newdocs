@echo off

:: Download and install Git
curl -o GitInstaller.exe https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe
start /wait GitInstaller.exe /VERYSILENT /NORESTART
pause

:: Download and install Node.js
curl -o NodeInstaller.msi https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi
start /wait msiexec /i NodeInstaller.msi /quiet /qn /norestart
pause

:: Install pnpm
iwr https://get.pnpm.io/install.ps1 -useb | iex
pause

:: Download and install PostgreSQL
curl -o PostgreSQLInstaller.exe https://sbp.enterprisedb.com/getfile.jsp?fileid=1258792
start /wait PostgreSQLInstaller.exe --mode unattended
pause

:: Change to the Documents directory
cd %USERPROFILE%\Documents
pause

:: Clone the SnailyCAD repository
git clone https://github.com/SnailyCAD/snaily-cadv4.git
cd snaily-cadv4
pause

:: Install project dependencies using pnpm
pnpm install
pause

:: Copy .env.example to .env
copy .env.example .env
pause

:: Open .env file for editing with Visual Studio Code
code -r .env
pause

:: Display message to the user
echo Please edit the .env file, then save and close it.
pause

:: Run the build script
pnpm run build --client --api
pause
