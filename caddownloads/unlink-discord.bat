@echo off
setlocal enabledelayedexpansion

:: Prompt for Discord ID
set /p discord_id=Enter the Discord ID to unlink: 

:: Prompt for PostgreSQL password securely (no built-in mask in .bat, sadly)
set /p db_password=Enter your PostgreSQL password (it will be visible): 

:: Set database credentials
set DB_NAME=snaily-cad-v4
set DB_USER=postgres

:: Set password environment variable for psql to use
set PGPASSWORD=%db_password%

echo ----------------------------------------
echo Checking user with this Discord ID...
psql -U %DB_USER% -d %DB_NAME% -c "SELECT id, username, \"discordId\" FROM public.\"User\" WHERE \"discordId\" = '%discord_id%';"

echo ----------------------------------------
echo Unlinking the Discord ID...
psql -U %DB_USER% -d %DB_NAME% -c "UPDATE public.\"User\" SET \"discordId\" = NULL WHERE \"discordId\" = '%discord_id%';"

echo ----------------------------------------
echo Verifying unlink...
psql -U %DB_USER% -d %DB_NAME% -c "SELECT id, username FROM public.\"User\" WHERE \"discordId\" IS NULL AND username IS NOT NULL;"

:: Clean up the password variable
set PGPASSWORD=

echo ----------------------------------------
echo ✅ Done. If the Discord ID existed, it has been unlinked.
pause
endlocal
