@echo off
REM addLocale.bat
REM This script automates SnailyCAD locale setup and configuration with saved preferences.

REM ================================
REM Configuration Section
REM ================================

SET "LOCALE_MANAGER_REPO=https://github.com/EWANZO101/newdocs.git"
SET "CLONE_DIR=%TEMP%\locale-manager-temp"
SET "TARGET_CONFIG_PATH=%USERPROFILE%\Documents\snaily-cadv4\apps\client\i18n.config.mjs"
SET "TARGET_LOCALES_DIR=%USERPROFILE%\Documents\snaily-cadv4\apps\client\locales"
SET "START_BAT_PATH=%USERPROFILE%\Documents\snaily-cadv4\start.bat"
SET "LOG_FILE=%USERPROFILE%\Documents\locale-manager-log.txt"
SET "CONFIG_FILE=%USERPROFILE%\Documents\locale-manager-config.txt"

REM ================================
REM Locale Setup Section
REM ================================

echo.
echo ================================
echo Locale Manager Setup
echo ================================
echo.

REM Check if log file exists
IF EXIST "%LOG_FILE%" (
    for /f "tokens=1" %%A in (%LOG_FILE%) do (
        SET "SAVED_LOCALE=%%A"
    )
    echo Found saved locale: %SAVED_LOCALE%
    goto CloneRepo
)

REM Display available locales
echo Select a locale from the list:
echo 1. en - English
echo 2. en-gb - English (Great Britain)
echo 3. ru - Russian
echo 4. cn - Chinese (Simplified)
echo 5. tc - Chinese (Traditional)
echo 6. fr-FR - French (France)
echo 7. de-DE - German (Germany)
echo 8. pt-BR - Portuguese (Brazil)
echo 9. cs-CZ - Czech (Czech Republic)
echo 10. nl-BE - Dutch (Belgium)
echo 11. zh-CN - Chinese (China)
echo 12. sv - Swedish

REM Prompt user for locale selection
set /p locale_choice=Enter the number for your locale: 

REM Map user input to locale codes
SET "SAVED_LOCALE="
IF "%locale_choice%"=="1" SET "SAVED_LOCALE=en"
IF "%locale_choice%"=="2" SET "SAVED_LOCALE=en-gb"
IF "%locale_choice%"=="3" SET "SAVED_LOCALE=ru"
IF "%locale_choice%"=="4" SET "SAVED_LOCALE=cn"
IF "%locale_choice%"=="5" SET "SAVED_LOCALE=tc"
IF "%locale_choice%"=="6" SET "SAVED_LOCALE=fr-FR"
IF "%locale_choice%"=="7" SET "SAVED_LOCALE=de-DE"
IF "%locale_choice%"=="8" SET "SAVED_LOCALE=pt-BR"
IF "%locale_choice%"=="9" SET "SAVED_LOCALE=cs-CZ"
IF "%locale_choice%"=="10" SET "SAVED_LOCALE=nl-BE"
IF "%locale_choice%"=="11" SET "SAVED_LOCALE=zh-CN"
IF "%locale_choice%"=="12" SET "SAVED_LOCALE=sv"

IF "%SAVED_LOCALE%"=="" (
    echo Invalid selection. Exiting...
    PAUSE
    EXIT /B 1
)

REM Save the selected locale to the log file
echo %SAVED_LOCALE% > "%LOG_FILE%"

REM ================================
REM Clone Locale Manager Repository
REM ================================

:CloneRepo
echo.
echo ================================
echo Cloning Locale Manager Repository
echo ================================
echo.

git clone %LOCALE_MANAGER_REPO% "%CLONE_DIR%"
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to clone repository. Check internet connection.
    PAUSE
    EXIT /B 1
)

REM Navigate to the locale-manager folder
cd /D "%CLONE_DIR%\caddownloads\locale-manager"
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to navigate to locale-manager folder.
    PAUSE
    EXIT /B 1
)

REM Install dependencies
npm install
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to install dependencies.
    PAUSE
    EXIT /B 1
)

REM Run locale addition script with saved locale
echo Adding locale: %SAVED_LOCALE%
npm run add-locale --locale=%SAVED_LOCALE%
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to add locale.
    PAUSE
    EXIT /B 1
)

REM Replace the i18n.config.mjs file
COPY /Y "%CLONE_DIR%\apps\client\i18n.config.mjs" "%TARGET_CONFIG_PATH%"
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to replace i18n.config.mjs.
    PAUSE
    EXIT /B 1
)

REM Clean up temporary files
rd /S /Q "%CLONE_DIR%"

echo.
echo Locale setup completed successfully.
echo.
PAUSE

REM ================================
REM Post-Setup Section
REM ================================

echo.
echo ================================
echo Checking for start.bat
echo ================================
echo.

REM Download start.bat if missing
IF NOT EXIST "%START_BAT_PATH%" (
    echo start.bat not found. Downloading...
    powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/EWANZO101/newdocs/main/caddownloads/start%282%29.bat' -OutFile '%START_BAT_PATH%'"
    IF %ERRORLEVEL% NEQ 0 (
        echo Failed to download start.bat.
        PAUSE
        EXIT /B 1
    )
)

REM ================================
REM Open start.bat Preference
REM ================================

REM Check if config file exists
SET "OPEN_START_BAT="
IF EXIST "%CONFIG_FILE%" (
    for /f "tokens=2 delims==" %%A in ('findstr "OpenStartBat" "%CONFIG_FILE%"') do (
        SET "OPEN_START_BAT=%%A"
    )
)

REM Prompt user for preference or use saved preference
IF /I "%OPEN_START_BAT%"=="y" (
    start "" "%START_BAT_PATH%"
) ELSE IF /I "%OPEN_START_BAT%"=="n" (
    echo Skipping start.bat.
) ELSE (
    set /p user_input=Do you want to open start.bat? (y/n): 
    IF /I "%user_input%"=="y" (
        echo OpenStartBat=y > "%CONFIG_FILE%"
        start "" "%START_BAT_PATH%"
    ) ELSE (
        echo OpenStartBat=n > "%CONFIG_FILE%"
        echo Skipping start.bat.
    )
)

echo.
echo Process complete. Press Enter to exit.
pause >nul
exit
