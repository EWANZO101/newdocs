#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "⚠️ This script must be run as root. Re-running with sudo..."
  sudo "$0" "$@"
  exit
fi

# Prompt for database connection details
read -p "Enter Database Name: " DB_NAME
read -p "Enter Database User: " DB_USER
read -p "Enter Database Host (default: localhost): " DB_HOST
DB_HOST=${DB_HOST:-localhost} 
read -p "Enter Database Port (default: 5432): " DB_PORT
DB_PORT=${DB_PORT:-5432}
read -s -p "Enter Database Password: " DB_PASSWORD
echo

# Function to list users
list_users() {
  echo "📋 Listing users:"
  PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -t -A -F "," <<EOF
SELECT row_number() OVER () as num, username FROM public."User" ORDER BY username;
EOF
}

# Function to unlink Discord ID
unlink_discord() {
  read -p "Enter Discord ID to unlink: " discord_id
  PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" <<EOF
-- Show the user with this Discord ID
SELECT id, username, "discordId" FROM public."User" WHERE "discordId" = '$discord_id';

-- Unlink the Discord ID
UPDATE public."User" SET "discordId" = NULL WHERE "discordId" = '$discord_id';

-- Confirm unlink
SELECT id, username, "discordId" FROM public."User" WHERE "discordId" IS NULL AND username IS NOT NULL;
EOF
  echo "✅ Discord ID unlinked if it existed."
}

# Function to update CAD whitelist
update_cad() {
  PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" <<EOF
UPDATE public."cad" SET whitelisted = false;
SELECT id, whitelisted FROM public."cad";
EOF
  echo "✅ CAD whitelist updated."
}

# Function to update CadFeature settings
update_cadfeature() {
  PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" <<EOF
UPDATE public."CadFeature"
SET "isEnabled" = CASE
    WHEN feature = 'ALLOW_REGULAR_LOGIN' THEN true
    WHEN feature IN ('STEAM_OAUTH', 'DISCORD_AUTH') THEN false
END
WHERE feature IN ('ALLOW_REGULAR_LOGIN', 'STEAM_OAUTH', 'DISCORD_AUTH');

SELECT feature, "isEnabled" FROM public."CadFeature"
WHERE feature IN ('ALLOW_REGULAR_LOGIN', 'STEAM_OAUTH', 'DISCORD_AUTH');
EOF
  echo "✅ CadFeature settings updated."
}

# Function to reset user password (hashed)
reset_userpass() {
  list_users
  read -p "Enter the number of the user to reset password for: " user_num
  new_pass=""
  while [ -z "$new_pass" ]; do
    read -s -p "Enter the new password: " new_pass
    echo
  done
  read -s -p "Confirm new password: " confirm_pass
  echo
  if [ "$new_pass" != "$confirm_pass" ]; then
    echo "❌ Passwords do not match. Try again."
    return
  fi

  # Get the username from the selected number
  username=$(PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -t -A -F "," <<EOF
SELECT username FROM (
  SELECT row_number() OVER () as num, username FROM public."User" ORDER BY username
) t WHERE num = $user_num;
EOF
)

  if [ -z "$username" ]; then
    echo "❌ Invalid selection."
    return
  fi

  # Update password using bcrypt (PostgreSQL gen_salt)
  PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" <<EOF
UPDATE public."User" 
SET password = crypt('$new_pass', gen_salt('bf')) 
WHERE username = '$username';

SELECT id, username FROM public."User" WHERE username = '$username';
EOF

  echo "✅ Password reset for user '$username'."
}

# Main menu loop
while true; do
  echo
  echo "Select an option:"
  echo "1) Run ALL commands"
  echo "2) Unlink Discord ID"
  echo "3) Update CAD whitelist"
  echo "4) Update CadFeature settings"
  echo "5) Reset a user's password"
  echo "6) List all users"
  echo "0) Exit"
  read -p "Enter choice: " choice

  case $choice in
    1)
      unlink_discord
      update_cad
      update_cadfeature
      reset_userpass
      ;;
    2) unlink_discord ;;
    3) update_cad ;;
    4) update_cadfeature ;;
    5) reset_userpass ;;
    6) list_users ;;
    0) exit ;;
    *) echo "❌ Invalid choice." ;;
  esac
done
