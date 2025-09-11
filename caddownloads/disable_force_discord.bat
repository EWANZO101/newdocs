@echo off
setlocal

:: ================================
:: PostgreSQL connection settings
:: ================================

:: Ask for PostgreSQL version (this matches the folder name in Program Files)
set /p PG_VERSION=Enter your PostgreSQL version (e.g., 15 if installed under C:\Program Files\PostgreSQL\15): 

:: Ask for PostgreSQL username (often "postgres" unless you made a custom user)
set /p DB_USER=Enter PostgreSQL username (default is usually "postgres"): 

:: Ask for the database name (the CAD system’s database, e.g., "snailycad")
set /p DB_NAME=Enter the PostgreSQL database name: 

:: Ask for the PostgreSQL password (visible as you type – not hidden)
set /p db_password=Enter PostgreSQL password (note: will be visible): 

:: Set the password so psql can use it without prompting
set PGPASSWORD=%db_password%

:: Build the full path to psql.exe dynamically
set PSQL_PATH="C:\Program Files\PostgreSQL\%PG_VERSION%\bin\psql.exe"

:: ================================
:: Run SQL commands
:: ================================
echo Disabling FORCE_DISCORD_AUTH in SnailyCAD...

%PSQL_PATH% -U %DB_USER% -d %DB_NAME% -c "UPDATE public.\"CadFeature\" SET \"isEnabled\" = false WHERE feature = 'FORCE_DISCORD_AUTH';"
%PSQL_PATH% -U %DB_USER% -d %DB_NAME% -c "SELECT feature, \"isEnabled\" FROM public.\"CadFeature\" WHERE feature = 'FORCE_DISCORD_AUTH';"

:: ================================
:: Cleanup and finish
:: ================================
set "PGPASSWORD="

echo ✅ FORCE_DISCORD_AUTH has been disabled.

endlocal
pause
