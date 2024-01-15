@echo off

:: Change directory to Downloads
cd /d "C:\Downloads"

:: Download 7-Zip installer
powershell -command "(New-Object System.Net.WebClient).DownloadFile('https://www.7-zip.org/a/7z2301-x64.exe', 'C:\Downloads\7zInstaller.exe')"

:: Run 7-Zip installer silently
start /wait C:\Downloads\7zInstaller.exe /S

:: Download Mozilla Firefox installer
powershell -command "(New-Object System.Net.WebClient).DownloadFile('https://www.mozilla.org/en-GB/firefox/download/thanks/', 'C:\Downloads\FirefoxInstaller.exe')"

:: Run Mozilla Firefox installer silently
start /wait C:\Downloads\FirefoxInstaller.exe /S

:: Download FiveM server files
powershell -command "(New-Object System.Net.WebClient).DownloadFile('https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/', 'C:\Downloads\FiveM.zip')"

:: Unzip FiveM files
powershell Expand-Archive -Path 'C:\Downloads\FiveM.zip' -DestinationPath 'C:\Downloads\FiveM'

:: Set the txAdminPort variable
set "txAdminPort=40120"

:: Modify Fxserver.exe properties
powershell -Command "(Get-Content 'C:\Downloads\FiveM\Fxserver.exe' -Raw) -replace '(?<=\+set txAdminPort )\d+', '%txAdminPort%' | Set-Content 'C:\Downloads\FiveM\Fxserver.exe'"

:: Notify when installations and modifications are completed
echo 7-Zip, Mozilla Firefox, and FiveM server files downloaded, installed, modified, and set to run on startup!

:: Close the window after installations and setup
exit
