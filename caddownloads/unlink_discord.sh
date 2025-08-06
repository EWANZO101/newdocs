#!/bin/bash

# Prompt for Discord ID
read -p "Enter the Discord ID to unlink: " discord_id

# Prompt for PostgreSQL password (input hidden)
read -s -p "Enter your PostgreSQL password: " db_password
echo

# Optional: change these if needed
DB_NAME="snaily-cad-v4"
DB_USER="postgres"
DB_HOST="localhost"

# Run the SQL commands using the password
PGPASSWORD="$db_password" psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" <<EOF
-- Step 1: Show the user with this Discord ID
SELECT id, username, "discordId" FROM public."User" WHERE "discordId" = '$discord_id';

-- Step 2: Unlink the Discord ID
UPDATE public."User" SET "discordId" = NULL WHERE "discordId" = '$discord_id';

-- Step 3: Confirm the unlink
SELECT id, username, "discordId" FROM public."User" WHERE "discordId" IS NULL AND username IS NOT NULL;
EOF

echo "✅ Done. If the Discord ID existed, it has been unlinked."
