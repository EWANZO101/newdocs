#!/bin/bash

# Prompt for PostgreSQL version, username, database, and password
read -p "Enter PostgreSQL version (e.g., 15): " PG_VERSION
read -p "Enter PostgreSQL username: " DB_USER
read -p "Enter PostgreSQL database name: " DB_NAME
read -s -p "Enter PostgreSQL password: " DB_PASSWORD
echo ""

# Build full path to psql
PSQL_PATH="/usr/lib/postgresql/$PG_VERSION/bin/psql"

# Check if psql exists
if [ ! -x "$PSQL_PATH" ]; then
  echo "❌ psql not found at $PSQL_PATH"
  echo "Please check the version number or adjust the path."
  exit 1
fi

echo "Disabling FORCE_DISCORD_AUTH in SnailyCAD..."

# Export password for psql
export PGPASSWORD="$DB_PASSWORD"

# Run the SQL commands
"$PSQL_PATH" -U "$DB_USER" -d "$DB_NAME" -c "UPDATE public.\"CadFeature\" SET \"isEnabled\" = false WHERE feature = 'FORCE_DISCORD_AUTH';"
"$PSQL_PATH" -U "$DB_USER" -d "$DB_NAME" -c "SELECT feature, \"isEnabled\" FROM public.\"CadFeature\" WHERE feature = 'FORCE_DISCORD_AUTH';"

# Cleanup
unset PGPASSWORD

echo "✅ FORCE_DISCORD_AUTH has been disabled."
