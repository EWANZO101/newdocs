@echo off
setlocal

:: Prompt for PostgreSQL password
set /p db_password=Enter PostgreSQL password (it will be visible): 

:: Set environment variables
set DB_NAME=snaily-cad-v4
set DB_USER=postgres

:: Set the password for psql
set PGPASSWORD=%db_password%

echo Disabling FORCE_DISCORD_AUTH in SnailyCAD...

:: Run the SQL
psql -U %DB_USER% -d %DB_NAME% -c "UPDATE public.\"CadFeature\" SET \"isEnabled\" = false WHERE feature = 'FORCE_DISCORD_AUTH';"
psql -U %DB_USER% -d %DB_NAME% -c "SELECT feature, \"isEnabled\" FROM public.\"CadFeature\" WHERE feature = 'FORCE_DISCORD_AUTH';"

:: Cleanup
set PGPASSWORD=

echo ✅ FORCE_DISCORD_AUTH has been disabled.
pause
endlocal
