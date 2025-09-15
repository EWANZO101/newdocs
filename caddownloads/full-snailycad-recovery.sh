#!/bin/bash
# cad_admin.sh - SnailyCAD Administration Tool for Unix/Linux/macOS

set -e  # Exit on error
trap cleanup EXIT  # Cleanup on exit

# Initialize variables
PSQL_PATH=""
DB_NAME=""
DB_USER=""
DB_HOST=""
DB_PORT=""
PGPASSWORD=""

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Cleanup function
cleanup() {
    unset PGPASSWORD
    unset DB_PASS
}

# Function to find PostgreSQL installation
find_psql() {
    print_info "Looking for PostgreSQL installation..."
    
    # Common PostgreSQL locations
    local psql_locations=(
        "/usr/bin/psql"
        "/usr/local/bin/psql"
        "/opt/postgresql/bin/psql"
        "/usr/local/pgsql/bin/psql"
        "/Applications/Postgres.app/Contents/Versions/latest/bin/psql"  # macOS Postgres.app
        "/opt/homebrew/bin/psql"  # Apple Silicon Homebrew
        "/usr/local/Cellar/postgresql@*/bin/psql"  # Intel Homebrew (wildcard)
    )
    
    # Check common locations
    for location in "${psql_locations[@]}"; do
        if [[ "$location" == *"*"* ]]; then
            # Handle wildcard paths
            for path in $location; do
                if [[ -x "$path" ]]; then
                    PSQL_PATH="$path"
                    print_success "Found PostgreSQL at: $PSQL_PATH"
                    return 0
                fi
            done
        elif [[ -x "$location" ]]; then
            PSQL_PATH="$location"
            print_success "Found PostgreSQL at: $PSQL_PATH"
            return 0
        fi
    done
    
    # Check if psql is in PATH
    if command -v psql >/dev/null 2>&1; then
        PSQL_PATH=$(command -v psql)
        print_success "Found PostgreSQL in PATH: $PSQL_PATH"
        return 0
    fi
    
    # If not found, prompt user
    print_warning "PostgreSQL not found automatically."
    while true; do
        read -p "Enter full path to psql binary: " PSQL_PATH
        if [[ -z "$PSQL_PATH" ]]; then
            print_error "Path cannot be empty."
            continue
        fi
        if [[ -x "$PSQL_PATH" ]]; then
            print_success "Using PostgreSQL at: $PSQL_PATH"
            break
        else
            print_error "psql not found or not executable at: $PSQL_PATH"
        fi
    done
}

# Function to get database details
get_db_details() {
    while true; do
        read -p "Enter Database Name: " DB_NAME
        [[ -n "$DB_NAME" ]] && break
        print_error "Database name is required."
    done
    
    while true; do
        read -p "Enter Database User: " DB_USER
        [[ -n "$DB_USER" ]] && break
        print_error "Database user is required."
    done
    
    read -p "Enter Database Host (default: localhost): " DB_HOST
    [[ -z "$DB_HOST" ]] && DB_HOST="localhost"
    
    read -p "Enter Database Port (default: 5432): " DB_PORT
    [[ -z "$DB_PORT" ]] && DB_PORT="5432"
    
    echo
    print_warning "Password will be temporarily stored in memory."
    while true; do
        read -s -p "Enter PostgreSQL password: " DB_PASS
        echo
        [[ -n "$DB_PASS" ]] && break
        print_error "Password is required."
    done
    
    export PGPASSWORD="$DB_PASS"
}

# Function to test database connection
test_connection() {
    print_info "Testing database connection..."
    if "$PSQL_PATH" -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -c "SELECT 1;" >/dev/null 2>&1; then
        print_success "Connection successful!"
        echo
        return 0
    else
        print_error "Could not connect to database. Please check your credentials."
        exit 1
    fi
}

# Function to execute SQL and handle errors
execute_sql() {
    local sql="$1"
    local description="$2"
    
    if [[ -n "$description" ]]; then
        print_info "$description"
    fi
    
    if "$PSQL_PATH" -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -v ON_ERROR_STOP=1 -c "$sql"; then
        return 0
    else
        print_error "Failed to execute SQL command."
        return 1
    fi
}

# Function to pause and wait for user input
pause() {
    echo
    read -p "Press Enter to continue..."
}

# Main menu function
show_menu() {
    clear
    echo "==============================="
    echo "    SnailyCAD Admin Menu"
    echo "==============================="
    echo "1. List all users"
    echo "2. Unlink Discord ID"
    echo "3. Update CAD whitelist (disable all) ie re enable user login or turn off force discord"
    echo "4. Update CadFeature settings"
    echo "5. Reset a user's password"
    echo "6. Run maintenance commands"
    echo "0. Exit"
    echo "==============================="
}

# Function to list all users
list_users() {
    clear
    print_info "Fetching user list..."
    echo
    
    local sql="SELECT row_number() OVER () AS num, id, username, \"discordId\" FROM public.\"User\" ORDER BY username;"
    execute_sql "$sql" && pause
}

# Function to unlink Discord ID
unlink_discord() {
    clear
    while true; do
        read -p "Enter Discord ID to unlink: " DISCORD_ID
        [[ -n "$DISCORD_ID" ]] && break
        print_error "Discord ID cannot be empty."
    done
    
    print_info "Searching for users with Discord ID: $DISCORD_ID"
    local search_sql="SELECT id, username, \"discordId\" FROM public.\"User\" WHERE \"discordId\" = '$DISCORD_ID';"
    
    if ! execute_sql "$search_sql"; then
        pause
        return 1
    fi
    
    echo
    read -p "Proceed with unlinking? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        print_info "Operation cancelled."
        pause
        return 0
    fi
    
    local unlink_sql="UPDATE public.\"User\" SET \"discordId\" = NULL WHERE \"discordId\" = '$DISCORD_ID';"
    if execute_sql "$unlink_sql" "Unlinking Discord ID..."; then
        print_success "Discord ID unlinked successfully."
        echo
        print_info "Users with no Discord ID (showing first 10):"
        local list_sql="SELECT id, username FROM public.\"User\" WHERE \"discordId\" IS NULL AND username IS NOT NULL LIMIT 10;"
        execute_sql "$list_sql"
    fi
    pause
}

# Function to update CAD whitelist
update_cad_whitelist() {
    clear
    print_warning "This will disable whitelist for ALL CADs."
    read -p "Are you sure you want to continue? (y/N): " confirm
    
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        print_info "Operation cancelled."
        pause
        return 0
    fi
    
    local update_sql="UPDATE public.\"cad\" SET whitelisted = false;"
    if execute_sql "$update_sql" "Updating CAD whitelist settings..."; then
        print_success "CAD whitelist updated successfully."
        echo
        print_info "Current CAD whitelist status:"
        local status_sql="SELECT id, name, whitelisted FROM public.\"cad\";"
        execute_sql "$status_sql"
    fi
    pause
}

# Function to show feature menu
show_feature_menu() {
    clear
    echo "==============================="
    echo " Update CadFeature Settings"
    echo "==============================="
    
    print_info "Current feature status:"
    local status_sql="SELECT feature, \"isEnabled\" FROM public.\"CadFeature\" ORDER BY feature;"
    execute_sql "$status_sql" 2>/dev/null || true
    
    echo
    echo "Available features:"
    echo "1. ALLOW_REGULAR_LOGIN"
    echo "2. STEAM_OAUTH" 
    echo "3. DISCORD_AUTH"
    echo "0. Back to main menu"
    echo "==============================="
}

# Function to update feature settings
update_feature_settings() {
    while true; do
        show_feature_menu
        read -p "Enter choice (0-3): " FEATURE_CHOICE
        
        case $FEATURE_CHOICE in
            0) return 0 ;;
            1) FEATURE="ALLOW_REGULAR_LOGIN" ;;
            2) FEATURE="STEAM_OAUTH" ;;
            3) FEATURE="DISCORD_AUTH" ;;
            *) 
                print_error "Invalid choice."
                pause
                continue
                ;;
        esac
        
        echo
        print_info "Current status of $FEATURE:"
        local current_sql="SELECT \"isEnabled\" FROM public.\"CadFeature\" WHERE feature = '$FEATURE';"
        execute_sql "$current_sql" 2>/dev/null || true
        
        echo
        while true; do
            read -p "Set '$FEATURE' to true or false? (t/f): " RESP
            case $RESP in
                t|T) VALUE="true"; break ;;
                f|F) VALUE="false"; break ;;
                *) print_error "Please enter 't' for true or 'f' for false." ;;
            esac
        done
        
        local update_sql="UPDATE public.\"CadFeature\" SET \"isEnabled\" = $VALUE WHERE feature = '$FEATURE';"
        if execute_sql "$update_sql" "Updating $FEATURE to $VALUE..."; then
            print_success "'$FEATURE' successfully set to $VALUE"
        fi
        pause
    done
}

# Function to reset user password
reset_user_password() {
    clear
    print_info "Ensuring pgcrypto extension exists..."
    local ext_sql="CREATE EXTENSION IF NOT EXISTS pgcrypto;"
    if ! execute_sql "$ext_sql"; then
        pause
        return 1
    fi
    
    echo
    print_info "User list:"
    local users_sql="SELECT row_number() OVER () AS num, username, id FROM public.\"User\" WHERE username IS NOT NULL ORDER BY username;"
    if ! execute_sql "$users_sql"; then
        pause
        return 1
    fi
    
    echo
    while true; do
        read -p "Enter the number of the user to reset password for: " USER_NUM
        [[ -n "$USER_NUM" ]] && [[ "$USER_NUM" =~ ^[0-9]+$ ]] && break
        print_error "Please enter a valid user number."
    done
    
    while true; do
        read -s -p "Enter the new password: " NEW_PASS
        echo
        [[ -n "$NEW_PASS" ]] && break
        print_error "Password cannot be empty."
    done
    
    echo
    read -p "Confirm password reset for user #$USER_NUM? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        print_info "Operation cancelled."
        pause
        return 0
    fi
    
    local reset_sql="UPDATE public.\"User\" SET password = crypt('$NEW_PASS', gen_salt('bf')) WHERE username = (SELECT username FROM (SELECT row_number() OVER () AS num, username FROM public.\"User\" WHERE username IS NOT NULL ORDER BY username) t WHERE num = $USER_NUM);"
    
    if execute_sql "$reset_sql" "Resetting password..."; then
        print_success "Password reset successfully."
    fi
    pause
}

# Function to show maintenance menu
show_maintenance_menu() {
    clear
    echo "==============================="
    echo "   Maintenance Operations"
    echo "==============================="
    print_warning "These operations may affect system performance."
    echo "1. Vacuum database"
    echo "2. Update statistics"
    echo "3. Check database integrity"
    echo "4. Show database size"
    echo "5. Show active connections"
    echo "0. Back to main menu"
    echo "==============================="
}

# Function to handle maintenance operations
maintenance_operations() {
    while true; do
        show_maintenance_menu
        read -p "Enter choice (0-5): " MAINT_CHOICE
        
        case $MAINT_CHOICE in
            0) return 0 ;;
            1)
                if execute_sql "VACUUM ANALYZE;" "Running database vacuum..."; then
                    print_success "Database vacuum completed."
                fi
                pause
                ;;
            2)
                if execute_sql "ANALYZE;" "Updating database statistics..."; then
                    print_success "Statistics updated."
                fi
                pause
                ;;
            3)
                execute_sql "SELECT schemaname, tablename, attname, n_distinct, correlation FROM pg_stats WHERE schemaname = 'public' LIMIT 10;" "Checking database integrity..."
                pause
                ;;
            4)
                execute_sql "SELECT pg_size_pretty(pg_database_size('$DB_NAME')) as database_size;" "Checking database size..."
                pause
                ;;
            5)
                execute_sql "SELECT pid, usename, application_name, client_addr, state, query_start FROM pg_stat_activity WHERE state = 'active';" "Showing active connections..."
                pause
                ;;
            *)
                print_error "Invalid choice."
                pause
                ;;
        esac
    done
}

# Main function
main() {
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_warning "Running as root. Consider using a non-root user for database operations."
        echo
    fi
    
    # Find PostgreSQL and get database details
    find_psql
    echo
    get_db_details
    test_connection
    
    # Main menu loop
    while true; do
        show_menu
        read -p "Enter your choice (0-6): " choice
        
        case $choice in
            1) list_users ;;
            2) unlink_discord ;;
            3) update_cad_whitelist ;;
            4) update_feature_settings ;;
            5) reset_user_password ;;
            6) maintenance_operations ;;
            0) 
                print_info "Cleaning up..."
                print_success "Thank you for using SnailyCAD Admin Tool!"
                exit 0
                ;;
            *) 
                print_error "Invalid choice. Please enter a number between 0-6."
                pause
                ;;
        esac
    done
}

# Make sure we're not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
