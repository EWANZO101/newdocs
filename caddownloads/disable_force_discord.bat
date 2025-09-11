@echo off
setlocal

:: Prompt for PostgreSQL version, username, database, and password
set /p PG_VERSION=Enter PostgreSQL version (e.g., 15 u can find this in C:\Program Files\PostgreSQL\): 
set /p DB_USER=Enter PostgreSQL username: 
set /p DB_NAME=Enter PostgreSQL database name: 
set /p db_password=Enter PostgreSQL password (it will be visible): 

:: Set the password for psql
set PGPASSWORD=%db_password%

:: Build full path to psql.exe based on version
set PSQL_PATH="C:\Program Files\PostgreSQL\%PG_VERSION%\bin\psql.exe"

echo Disabling FORCE_DISCORD_AUTH in SnailyCAD...

:: Run the SQL
%PSQL_PATH% -U %DB_USER% -d %DB_NAME% -c "UPDATE public.\"CadFeature\" SET \"isEnabled\" = false WHERE feature = 'FORCE_DISCORD_AUTH';"
%PSQL_PATH% -U %DB_USER% -d %DB_NAME% -c "SELECT feature, \"isEnabled\" FROM public.\"CadFeature\" WHERE feature = 'FORCE_DISCORD_AUTH';"

:: Cleanup
set "PGPASSWORD="

echo ✅ FORCE_DISCORD_AUTH has been disabled.

endlocal
pause
