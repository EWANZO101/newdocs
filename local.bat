@echo off
setlocal

:: Define variables
set "SNAILY_PATH=%USERPROFILE%\Documents\snaily-cadv4"
set "LOCALES_PATH=%SNAILY_PATH%\apps\client\locales"
set "I18N_CONFIG=%SNAILY_PATH%\apps\client\i18n.config.mjs"
set "LOCALE_CODE=pl"

:: Step 1: Navigate to locales directory
cd /d "%LOCALES_PATH%" || (
    echo Failed to access %LOCALES_PATH%
    exit /b 1
)

:: Step 2: Duplicate the "en" folder and rename it to "pl"
if exist "%LOCALES_PATH%\%LOCALE_CODE%" (
    echo Polish locale folder already exists.
) else (
    xcopy /E /I "en" "%LOCALE_CODE%"
    echo Created Polish locale folder.
)

:: Step 3: Modify the i18n.config.mjs file
powershell -Command "(Get-Content '%I18N_CONFIG%') -replace 'locales: \[', 'locales: [\"pl\", ' -replace 'defaultLocale: .*', 'defaultLocale: \"pl\",' | Set-Content '%I18N_CONFIG%'" 

echo Updated i18n.config.mjs with Polish locale.

:: Step 4: Rebuild SnailyCAD and restart
cd /d "%SNAILY_PATH%" || (
    echo Failed to access SnailyCAD directory.
    exit /b 1
)

pnpm run build
pm2 restart all

echo Polish locale added successfully!
pause