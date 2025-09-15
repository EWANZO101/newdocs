@echo off
setlocal enabledelayedexpansion
:: cad_admin.bat - SnailyCAD Administration Tool for Windows (Fixed Version)

:: --- Initialize variables ---
set "PSQL_PATH="
set "DB_NAME="
set "DB_USER="
set "DB_HOST="
set "DB_PORT="
set "PGPASSWORD="

:: --- Function to find PostgreSQL installation ---
:FIND_PSQL
echo Looking for PostgreSQL installation...
for %%v in (16 15 14 13 12 11 10) do (
    if exist "C:\Program Files\PostgreSQL\%%v\bin\psql.exe" (
        set "PSQL_PATH=C:\Program Files\PostgreSQL\%%v\bin\psql.exe"
        echo Found PostgreSQL %%v at: !PSQL_PATH!
        goto FOUND_PSQL
    )
)

:: If not found, prompt user
set /p PG_VER="PostgreSQL not found automatically. Enter version (10-16): "
if "%PG_VER%"=="" (
    echo Error: PostgreSQL version required.
    pause
    exit /b 1
)

set "PSQL_PATH=C:\Program Files\PostgreSQL\%PG_VER%\bin\psql.exe"
if not exist "%PSQL_PATH%" (
    echo Error: PostgreSQL %PG_VER% not found at expected location.
    set /p PSQL_PATH="Enter full path to psql.exe: "
    if not exist "!PSQL_PATH!" (
        echo Error: psql.exe not found at specified path.
        pause
        exit /b 1
    )
)

:FOUND_PSQL
echo Using PostgreSQL at: %PSQL_PATH%
echo.

:: --- Database connection details ---
:GET_DB_DETAILS
set /p DB_NAME="Enter Database Name: "
if "%DB_NAME%"=="" (
    echo Error: Database name is required.
    goto GET_DB_DETAILS
)

set /p DB_USER="Enter Database User: "
if "%DB_USER%"=="" (
    echo Error: Database user is required.
    goto GET_DB_DETAILS
)

set /p DB_HOST="Enter Database Host (default: localhost): "
if "%DB_HOST%"=="" set DB_HOST=localhost

set /p DB_PORT="Enter Database Port (default: 5432): "
if "%DB_PORT%"=="" set DB_PORT=5432

:: --- Prompt for password ---
echo.
echo WARNING: Password will be temporarily stored in memory.
set /p DB_PASS="Enter PostgreSQL password: "
if "%DB_PASS%"=="" (
    echo Error: Password is required.
    goto GET_DB_DETAILS
)
set PGPASSWORD=%DB_PASS%

:: Test connection
echo Testing database connection...
"%PSQL_PATH%" -U "%DB_USER%" -d "%DB_NAME%" -h "%DB_HOST%" -p "%DB_PORT%" -c "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo Error: Could not connect to database. Please check your credentials.
    pause
    exit /b 1
)
echo Connection successful!
echo.

:MENU
cls
echo ===============================
echo SnailyCAD Admin Menu
echo ===============================
echo 1. List all users
echo 2. Unlink Discord ID
echo 3. Update CAD whitelist (disable all)
echo 4. Update CadFeature settings
echo 5. Reset a user's password
echo 6. Run maintenance commands
echo 0. Exit
echo ===============================
set /p choice="Enter your choice (0-6): "

if "%choice%"=="1" goto LIST_USERS
if "%choice%"=="2" goto UNLINK
if "%choice%"=="3" goto UPDATE_CAD
if "%choice%"=="4" goto UPDATE_FEATURE
if "%choice%"=="5" goto RESET_PASS
if "%choice%"=="6" goto MAINTENANCE
if "%choice%"=="0" goto CLEANUP_EXIT
echo Invalid choice. Please enter a number between 0-6.
pause
goto MENU

:: --- Functions ---
:LIST_USERS
cls
echo Fetching user list...
echo.
"%PSQL_PATH%" -U "%DB_USER%" -d "%DB_NAME%" -h "%DB_HOST%" -p "%DB_PORT%" -v ON_ERROR_STOP=1 -c "SELECT row_number() OVER () AS num, id, username, \"discordId\" FROM public.\"User\" ORDER BY username;"
if errorlevel 1 (
    echo Error executing query.
    pause
    goto MENU
)
echo.
pause
goto MENU

:UNLINK
cls
set /p DISCORD_ID="Enter Discord ID to unlink: "
if "%DISCORD_ID%"=="" (
    echo Error: Discord ID cannot be empty.
    pause
    goto MENU
)

echo Searching for users with Discord ID: %DISCORD_ID%
"%PSQL_PATH%" -U "%DB_USER%" -d "%DB_NAME%" -h "%DB_HOST%" -p "%DB_PORT%" -v ON_ERROR_STOP=1 -c "SELECT id, username, \"discordId\" FROM public.\"User\" WHERE \"discordId\" = '%DISCORD_ID%';"
if errorlevel 1 (
    echo Error executing query.
    pause
    goto MENU
)

echo.
set /p confirm="Proceed with unlinking? (y/N): "
if /i not "%confirm%"=="y" (
    echo Operation cancelled.
    pause
    goto MENU
)

echo Unlinking Discord ID...
"%PSQL_PATH%" -U "%DB_USER%" -d "%DB_NAME%" -h "%DB_HOST%" -p "%DB_PORT%" -v ON_ERROR_STOP=1 -c "UPDATE public.\"User\" SET \"discordId\" = NULL WHERE \"discordId\" = '%DISCORD_ID%';"
if errorlevel 1 (
    echo Error updating user.
    pause
    goto MENU
)

echo Discord ID unlinked successfully.
echo.
echo Users with no Discord ID:
"%PSQL_PATH%" -U "%DB_USER%" -d "%DB_NAME%" -h "%DB_HOST%" -p "%DB_PORT%" -v ON_ERROR_STOP=1 -c "SELECT id, username FROM public.\"User\" WHERE \"discordId\" IS NULL AND username IS NOT NULL LIMIT 10;"
pause
goto MENU

:UPDATE_CAD
cls
echo WARNING: This will disable whitelist for ALL CADs.
set /p confirm="Are you sure you want to continue? (y/N): "
if /i not "%confirm%"=="y" (
    echo Operation cancelled.
    pause
    goto MENU
)

echo Updating CAD whitelist settings...
"%PSQL_PATH%" -U "%DB_USER%" -d "%DB_NAME%" -h "%DB_HOST%" -p "%DB_PORT%" -v ON_ERROR_STOP=1 -c "UPDATE public.\"cad\" SET whitelisted = false;"
if errorlevel 1 (
    echo Error updating CAD settings.
    pause
    goto MENU
)

echo Current CAD whitelist status:
"%PSQL_PATH%" -U "%DB_USER%" -d "%DB_NAME%" -h "%DB_HOST%" -p "%DB_PORT%" -v ON_ERROR_STOP=1 -c "SELECT id, name, whitelisted FROM public.\"cad\";"
echo.
echo CAD whitelist updated successfully.
pause
goto MENU

:UPDATE_FEATURE
:FEATURE_MENU
cls
echo ===============================
echo Update CadFeature Settings
echo ===============================
echo Current feature status:
"%PSQL_PATH%" -U "%DB_USER%" -d "%DB_NAME%" -h "%DB_HOST%" -p "%DB_PORT%" -c "SELECT feature, \"isEnabled\" FROM public.\"CadFeature\" ORDER BY feature;" 2>nul
echo.
echo Available features:
echo 1. ALLOW_REGULAR_LOGIN
echo 2. STEAM_OAUTH
echo 3. DISCORD_AUTH
echo 0. Back to main menu
echo ===============================
set /p FEATURE_CHOICE="Enter choice (0-3): "

if "%FEATURE_CHOICE%"=="0" goto MENU
if "%FEATURE_CHOICE%"=="1" set "FEATURE=ALLOW_REGULAR_LOGIN" & goto ASK_VALUE
if "%FEATURE_CHOICE%"=="2" set "FEATURE=STEAM_OAUTH" & goto ASK_VALUE
if "%FEATURE_CHOICE%"=="3" set "FEATURE=DISCORD_AUTH" & goto ASK_VALUE

echo Invalid choice.
pause
goto FEATURE_MENU

:ASK_VALUE
echo.
echo Current status of %FEATURE%:
"%PSQL_PATH%" -U "%DB_USER%" -d "%DB_NAME%" -h "%DB_HOST%" -p "%DB_PORT%" -c "SELECT \"isEnabled\" FROM public.\"CadFeature\" WHERE feature = '%FEATURE%';" 2>nul
echo.
set /p RESP="Set '%FEATURE%' to true or false? (t/f): "
if /i "%RESP%"=="t" set VALUE=true & goto UPDATE_THIS
if /i "%RESP%"=="f" set VALUE=false & goto UPDATE_THIS
echo Please enter 't' for true or 'f' for false.
goto ASK_VALUE

:UPDATE_THIS
echo Updating %FEATURE% to %VALUE%...
"%PSQL_PATH%" -U "%DB_USER%" -d "%DB_NAME%" -h "%DB_HOST%" -p "%DB_PORT%" -v ON_ERROR_STOP=1 -c "UPDATE public.\"CadFeature\" SET \"isEnabled\" = %VALUE% WHERE feature = '%FEATURE%';"
if errorlevel 1 (
    echo Error updating feature.
    pause
    goto FEATURE_MENU
)

echo '%FEATURE%' successfully set to %VALUE%
pause
goto FEATURE_MENU

:RESET_PASS
cls
echo Ensuring pgcrypto extension exists...
"%PSQL_PATH%" -U "%DB_USER%" -d "%DB_NAME%" -h "%DB_HOST%" -p "%DB_PORT%" -v ON_ERROR_STOP=1 -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
if errorlevel 1 (
    echo Error creating pgcrypto extension.
    pause
    goto MENU
)

echo.
echo User list:
"%PSQL_PATH%" -U "%DB_USER%" -d "%DB_NAME%" -h "%DB_HOST%" -p "%DB_PORT%" -v ON_ERROR_STOP=1 -c "SELECT row_number() OVER () AS num, username, id FROM public.\"User\" WHERE username IS NOT NULL ORDER BY username;"
if errorlevel 1 (
    echo Error fetching users.
    pause
    goto MENU
)

echo.
set /p USER_NUM="Enter the number of the user to reset password for: "
if "%USER_NUM%"=="" (
    echo Error: Please enter a valid user number.
    pause
    goto MENU
)

set /p NEW_PASS="Enter the new password: "
if "%NEW_PASS%"=="" (
    echo Error: Password cannot be empty.
    pause
    goto MENU
)

echo.
set /p confirm="Confirm password reset for user #%USER_NUM%? (y/N): "
if /i not "%confirm%"=="y" (
    echo Operation cancelled.
    pause
    goto MENU
)

echo Resetting password...
"%PSQL_PATH%" -U "%DB_USER%" -d "%DB_NAME%" -h "%DB_HOST%" -p "%DB_PORT%" -v ON_ERROR_STOP=1 -c "UPDATE public.\"User\" SET password = crypt('%NEW_PASS%', gen_salt('bf')) WHERE username = (SELECT username FROM (SELECT row_number() OVER () AS num, username FROM public.\"User\" WHERE username IS NOT NULL ORDER BY username) t WHERE num = %USER_NUM%);"
if errorlevel 1 (
    echo Error resetting password.
    pause
    goto MENU
)

echo Password reset successfully.
pause
goto MENU

:MAINTENANCE
cls
echo ===============================
echo Maintenance Operations
echo ===============================
echo WARNING: These operations may affect system performance.
echo 1. Vacuum database
echo 2. Update statistics
echo 3. Check database integrity
echo 0. Back to main menu
echo ===============================
set /p MAINT_CHOICE="Enter choice (0-3): "

if "%MAINT_CHOICE%"=="0" goto MENU
if "%MAINT_CHOICE%"=="1" goto VACUUM_DB
if "%MAINT_CHOICE%"=="2" goto UPDATE_STATS
if "%MAINT_CHOICE%"=="3" goto CHECK_INTEGRITY

echo Invalid choice.
pause
goto MAINTENANCE

:VACUUM_DB
echo Running database vacuum...
"%PSQL_PATH%" -U "%DB_USER%" -d "%DB_NAME%" -h "%DB_HOST%" -p "%DB_PORT%" -c "VACUUM ANALYZE;"
echo Database vacuum completed.
pause
goto MAINTENANCE

:UPDATE_STATS
echo Updating database statistics...
"%PSQL_PATH%" -U "%DB_USER%" -d "%DB_NAME%" -h "%DB_HOST%" -p "%DB_PORT%" -c "ANALYZE;"
echo Statistics updated.
pause
goto MAINTENANCE

:CHECK_INTEGRITY
echo Checking database integrity...
"%PSQL_PATH%" -U "%DB_USER%" -d "%DB_NAME%" -h "%DB_HOST%" -p "%DB_PORT%" -c "SELECT schemaname, tablename, attname, n_distinct, correlation FROM pg_stats WHERE schemaname = 'public' LIMIT 10;"
pause
goto MAINTENANCE

:CLEANUP_EXIT
echo Cleaning up...
set PGPASSWORD=
set DB_PASS=
echo.
echo Thank you for using SnailyCAD Admin Tool!
pause
exit /b 0
