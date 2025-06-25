#!/bin/bash

# AR
# - [ ] Eliminate symlink usage
# - [ ] Move common functions to `utils.sh`.  Find [MOVE] tags.

# ./database/ops/data.sh - Database backup and restore utility
set -euo pipefail

# VARIABLES
SCRIPT_DIR="$(dirname "$0")"
ACTION="${1:-help}"
ARG2="${2:-}"
ENV_DIR="$SCRIPT_DIR/../../.env"

# Only used in case of custom backup directory path set in environment variable BACKUP_DIR
BACKUP_BASE_DIR="${BACKUP_DIR:-$SCRIPT_DIR/../backups}"   #Usage: "$BACKUP_DIR="/custom/path" ./database/ops/data.sh backup"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DATE_ONLY=$(date +"%Y%m%d")

# [ ] [TEST]
KEEP_DAYS="${BACKUP_KEEP_DAYS:-2}"

# FUNCTIONS

# [x] [REV-A] Keep
# [ ] [MOVE] Move to `utils.sh`
load_environment_variables() {
    local filename="$1"

    if [ -f "$filename" ]; then
        # [x] [REV-C] Remove
        # echo "📁 Loading environment variables from: $filename"
        set -o allexport
        source "$filename"
        set +o allexport
    else
        echo "⚠️  Environment variable file not found!"
        exit 1
    fi
}

# [x] [REV-A] Keep
# [ ] [MOVE] Move to `utils.sh`
validate_environment_variables() {
    local vars=(
        "DB_NAME" "DB_HOST" "DB_PORT"
        "DB_DEV_USER" "DB_DEV_PASS"
    )

    for var in "${vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            echo "❌ Required environment variable '$var' is not set in $ENV_DIR"
            exit 1
        fi
    done
}

# [x] [REV-A] Keep
# [ ] [MOVE] Move to `utils.sh`
check_database_connection() {
    local connection_test

    connection_test=$(mysql -h"$DB_HOST" -P"$DB_PORT" \
        -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" \
        -e "SELECT 1" 2>/dev/null || echo "failed")

    if [ "$connection_test" = "failed" ]; then
        echo "❌ Cannot connect to database. Please check your \
            connection settings."
        exit 1
    fi
}

# [x] [REV-B] Remove
# create_backup_directory() {
#     local backup_dir="$1"
    
#     if [ ! -d "$backup_dir" ]; then
#         echo "📁 Creating backup directory: $backup_dir"
#         mkdir -p "$backup_dir"
#     fi
# }

# [x] [REV-B] Keep
confirm_action() {
    local action="$1"       # [restore|cleanup]
    local target="${2:-}"   # [backup pathname]
    
    # [ ] [TEST]
    if [[ "$ARG2" == "--force" ]]; then
        echo "🚨 Force mode: Skipping confirmation"
        return 0
    fi
    
    case "$action" in
        "restore")
            echo "⚠️  WARNING: This will replace ALL data in database: $DB_NAME"
            echo "⚠️  Current data will be permanently lost!"
            # [LEARN] If `target` is not empty (-n), echo
            [ -n "$target" ] && echo "⚠️  Restoring from: $target"
            ;;
        # [ ] [TEST]
        "cleanup")
            echo "⚠️  WARNING: This will delete backup files older than $KEEP_DAYS days"
            ;;
    esac
    
    echo ""
    read -p "Are you sure you want to proceed? (yes/no): " -r
    echo ""
    
    local response="${REPLY,,}"   # [LEARN] Convert to lowercase

    if [[ $response != y* ]]; then
        echo "❌ Operation cancelled by user"
        # [LEARN] 
        # - `exit 0` exits the script with success code 
        # - (`return 1`, `-e`) exit in caller.  Allows caller to handle with `if` statement, if needed.
        # [x] [REV-B] Remove
        # exit 0 
        return 1
    fi
}

# [x] [REV-B] Keep
create_backup() {
    # Usage: {$0 [ACTION] [OPTION/"ARG2"]} // {$0 backup [NULL|description]}
    # Examples: {$0 backup} // {$0 backup "Before update"}
    # Runs: create_backup "ARG2" # ARG2 = description
    local description="${1:-}"
    # local backup_dir="$BACKUP_BASE_DIR/"
    local backup_pathname="$BACKUP_BASE_DIR/bak_$TIMESTAMP.sql"
    local info_dir="$BACKUP_BASE_DIR/metadata"
    local info_pathname="$info_dir/info_$TIMESTAMP.json"
    local log_pathname="$BACKUP_BASE_DIR/backup.log"
    
    echo "💾 Creating database backup..."
    
    # Failsafe, idempotent directory creation
    mkdir -p "$info_dir"
    mkdir -p "$BACKUP_BASE_DIR"

    # [x] [REV-B] Remove
    # create_backup_directory "$backup_dir"
    # echo "📂 Backup directory: $backup_dir"

    # [x] [REV-B] Keep
    # Create backup
    echo "📤 Exporting database: $DB_NAME"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting backup for database: $DB_NAME" >> "$log_pathname"
    mysqldump -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        --opt \
        "$DB_NAME" > "$backup_pathname" 2>> "$log_pathname"
    
    # Create metadata
    # [ ] [LEARN] breakdown syntax: "file_size"
    cat > "$info_pathname" << EOF
    {
        "timestamp": "$TIMESTAMP",
        "date": "$DATE_ONLY",
        "database": "$DB_NAME",
        "host": "$DB_HOST",
        "port": "$DB_PORT",
        "user": "$DB_DEV_USER",
        "description": "$description",
        "file_size": "$(stat -f%z "$backup_pathname" 2>/dev/null \
            || stat -c%s "$backup_pathname" 2>/dev/null \
            || echo 'unknown')",
        "tables_count": "$(grep -c "CREATE TABLE" "$backup_pathname" || echo 'unknown')",
        "created_by": "$(whoami)",
        "hostname": "$(hostname)"
    }
EOF

    # [x] [REV-B] Remove. Disprefer symlinks.
    # Create/update latest symlink
    # local latest_link="$BACKUP_BASE_DIR/latest"
    # if [ -L "$latest_link" ] || [ -e "$latest_link" ]; then
    #     rm -f "$latest_link"
    # fi
    # ln -snf "$backup_dir" "$latest_link"

    # [x] [REV-B] Keep
    # Verify backup
    # [LEARN] Syntax breakdown:
    # - $(...): command substitution, runs command and returns output
    # - -f: checks if file exists
    # - -s: checks if file is not empty
    # - du: disk usage command returns file size
    # - -h: human-readable format
    # - cut -f1: cut/extracts the first field (f1) (size) from `du` output
    # - grep -c [PATTERN] [FILE]: counts occurrences of pattern in file
    # - [-n "$description"]: checks if description is not empty
    # - [ ] && [COMMAND]: executes COMMAND if previous command was successful (exit code 0)
    if [ -f "$backup_pathname" ] && [ -s "$backup_pathname" ]; then
        echo "✅ Backup created successfully: $backup_pathname"
        echo "📊 Backup size: $(du -h "$backup_pathname" | cut -f1)"
        echo "📋 Tables backed up: $(grep -c "CREATE TABLE" "$backup_pathname" || echo 'unknown')"
        [ -n "$description" ] && echo "📝 Description: $description"
    else
        echo "❌ Backup failed or file is empty"
        exit 1
    fi

    if [ -f "$info_pathname" ] && [ -s "$info_pathname" ]; then
        echo "📊 Backup info saved to: $info_pathname"
    else
        echo "❌ Failed to create backup info file: $info_pathname"
        exit 1
    fi

    # [x] [REV-B] Keep
    # Copy to latest fixed backup file
    local latest_backup_file="$BACKUP_BASE_DIR/bak.sql"
    local latest_info_file="$info_dir/info.json"
    cp "$backup_pathname" "$latest_backup_file"
    cp "$info_pathname" "$latest_info_file"
    echo "📎 Latest backup copied to: $latest_backup_file"
    echo "📎 Latest info copied to: $latest_info_file"

}

# [x] [REV-B] Keep - Fixed and synced with create_backup()
restore_backup() {
    # Usage: {$0 [ACTION] [OPTION/"ARG2"]} // {$0 restore [NULL|date]}
    # Examples: {$0 restore} // {$0 restore 2024-12-25}
    # Runs: restore_backup "ARG2"   # ARG2 = YYYY-MM-DD or NULL
    local backup_date="${1:-latest}"
    local backup_pathname
    local info_pathname
    local info_dir="$BACKUP_BASE_DIR/metadata"

    if [ "$backup_date" = "latest" ]; then
        echo "🔍 Using latest backup..."
        backup_pathname="$BACKUP_BASE_DIR/bak.sql"
        # Find the most recent info file for latest backup
        # info_pathname=$(ls "$info_dir"/info_*.json 2>/dev/null | sort | tail -1)
        info_pathname="$info_dir/info.json"
    else
        echo -e "\n🔍 Looking for backup from date: $backup_date"
        # Convert YYYY-MM-DD to YYYYMMDD format to match create_backup() naming
        local timestamp_format=$(echo "$backup_date" | tr -d '-')
        
        # Look for backup files that start with the date (could have time component)
        backup_pathname=$(find "$BACKUP_BASE_DIR" -type f -name "bak_${timestamp_format}_*.sql" \
            | sort -r \
            | head -n 1)

        # If exact date format doesn't work, try finding any backup from that date
        if [ ! -f "$backup_pathname" ]; then
            backup_pathname=$(find "$BACKUP_BASE_DIR" -type f -name "*${timestamp_format}*.sql" \
                | sort -r \
                | head -n 1)
        fi

        if [ -n "$backup_pathname" ] && [ -f "$backup_pathname" ]; then
            echo "✅ Found backup: $backup_pathname"
        else
            echo "❌ No backup found for date: $backup_date"
            list_backups
            exit 1
        fi

        # Find corresponding info file
        if [ -f "$backup_pathname" ]; then
            # Extract the full timestamp from the backup filename
            local full_timestamp=$(basename "$backup_pathname" .sql | sed 's/bak_//')
            info_pathname="$info_dir/info_${full_timestamp}.json"
        else
            echo "❌ No backup info file found for date: $backup_date"
            exit 1
        fi
    fi

    # [ ] [FEAT] If requested backup not found, show available backups
    #         echo "💡 Available backups:"
    #         ls "$BACKUP_BASE_DIR"/bak_*.sql 2>/dev/null | while read -r file; do
    #             if [ -f "$file" ]; then
    #                 # Extract date from filename for display
    #                 local filename=$(basename "$file" .sql)
    #                 local timestamp_part=$(echo "$filename" | sed 's/bak_//')
    #                 local display_date=$(echo "$timestamp_part" \
    #                     | sed 's/^\([0-9]\{8\}\).*/\1/' \
    #                     | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3/')
    #                 echo "   - $display_date ($filename)"
    #             fi

    echo "🔄 Restoring database from backup..."
    echo "📄 Backup file: $backup_pathname"

    # [x] [REV-B] Keep
    # Display backup info if metadata file exists
    if [ -f "$info_pathname" ]; then
        echo "📊 Backup info:"
        # Extract and display key information from JSON
        if command -v jq >/dev/null 2>&1; then
            # Use jq if available for clean JSON parsing
            # [ ] [LEARN] breakdown syntax
            echo "    Date: $(jq -r '.date // "unknown"' "$info_pathname")"
            echo "    Description: $(jq -r '.description // "No description"' "$info_pathname")"
            echo "    Size: $(jq -r '.file_size // "unknown"' "$info_pathname") bytes"
            echo "    Tables: $(jq -r '.tables_count // "unknown"' "$info_pathname")"
            echo "    Created by: $(jq -r '.created_by // "unknown"' "$info_pathname")"
        else
            # Fallback to grep/sed if jq not available
            # [ ] [LEARN] breakdown syntax
            echo "    $(grep '"date"' "$info_pathname" | sed 's/.*: *"\([^"]*\)".*/Date: \1/')"
            echo "    $(grep '"description"' "$info_pathname" | sed 's/.*: *"\([^"]*\)".*/Description: \1/')"
            echo "    $(grep '"file_size"' "$info_pathname" | sed 's/.*: *"\([^"]*\)".*/Size: \1 bytes/')"
            echo "    $(grep '"tables_count"' "$info_pathname" | sed 's/.*: *"\([^"]*\)".*/Tables: \1/')"
            echo "    $(grep '"created_by"' "$info_pathname" | sed 's/.*: *"\([^"]*\)".*/Created by: \1/')"
        fi
    else
        echo '⚠️  "$info_pathname" not found'
    fi

    # [x] [REV-B] Keep
    # Confirm before proceeding
    confirm_action "restore" "$backup_pathname"
    echo "🗄️  Restoring database: $DB_NAME"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting restore for database: $DB_NAME from $backup_pathname" >> "$BACKUP_BASE_DIR/backup.log"
    
    # [x] [REV-B] Keep
    # [LEARN] `$?` reserved shell-variable containing exit status of the last command
    # - mysql [OPTIONS] [DB_NAME] < [.SQL FILE as input stream for `mysql` command] 2>> [LOG FILE]
    # - `2>>` appends stderr output to the log file
    if timeout 5s mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" < "$backup_pathname" 2>> "$BACKUP_BASE_DIR/backup.log"; then
        echo "✅ Database restore completed successfully"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Restore completed successfully" >> "$BACKUP_BASE_DIR/backup.log"
    else
        echo "❌ Database restore failed"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Restore failed" >> "$BACKUP_BASE_DIR/backup.log"
        exit 1
    fi
}

# [x] [REV-C] Keep. Reviewed and tested manually.
list_backups() {
    # [LEARN] [-d "$VAR"] - Order of operations?
    # - `-d` => [Does VAR exist?] && [Is VAR a directory?]
    if [ ! -d "$BACKUP_BASE_DIR" ]; then
        echo "❌ Backups directory not found: $BACKUP_BASE_DIR"
        return 1
    fi
    
    local found_backups=false
    echo -e "\n📋 Checking for available backups:"

    # Find all bak*.sql files in the backup directory
    for backup_file in "$BACKUP_BASE_DIR"/bak*.sql; do
        # Check if the glob matched any files (handle case where no files match)
        if [ -f "$backup_file" ]; then
            found_backups=true
            local basename=$(basename "$backup_file")
            local size="$(du -h "$backup_file" 2>/dev/null | cut -f1 || echo 'unknown')"
            
            echo "  📄 $basename (Size: $size)"
            
            # Extract YYYYMMDD_HHMMSS pattern from filename
            local timestamp_pattern=$(echo "$basename" | grep -o '[0-9]\{8\}_[0-9]\{6\}')
            
            # Look for corresponding info file in metadata subdirectory
            if [ -n "$timestamp_pattern" ]; then
                local info_file="$BACKUP_BASE_DIR/metadata/info_${timestamp_pattern}.json"
                if [ -f "$info_file" ]; then
                    local description=$(grep '"description"' "$info_file" | cut -d'"' -f4)
                    [ -n "$description" ] && echo "     📝 $description"
                fi
            fi
        fi
    done
    
    echo ""

    if [ "$found_backups" = false ]; then
        echo -e "\n❌ No backups found in: $BACKUP_BASE_DIR\n"
        return 1
    fi
}

# [x] [REV-C] Keep
show_backup_info() {
    local backup_date="${1:-latest}"   # backup_date format: YYYY-MM-DD
    local search_date                  # search_date format: YYYYMMDD
    local backup_pathname
    local info_pathname
    
    if [ "$backup_date" = "latest" ]; then
        backup_pathname="$BACKUP_BASE_DIR/bak.sql"
        info_pathname="$BACKUP_BASE_DIR/metadata/info.json"
    else
        search_date=$(echo "$backup_date" | tr -d '-')
        backup_pathname=$(find "$BACKUP_BASE_DIR" -maxdepth 1 \
            -name "bak_${search_date}_*.sql" -type f \
            2>/dev/null \
            | sort -t_ -k3 -r \
            | head -1 \
        )
        # backup_pathname="$BACKUP_BASE_DIR/bak_$backup_date*.sql"   # format: bak_YYYYMMDD_HHMMSS.sql
        if [ -n "$backup_pathname" ]; then
            local full_timestamp=$(basename "$backup_pathname" \
                | grep -o '[0-9]\{8\}_[0-9]\{6\}'
            )
            info_pathname="$BACKUP_BASE_DIR/metadata/info_${full_timestamp}.json"   ## format: info_YYYYMMDD_HHMMSS.json
        else
            backup_pathname=""
            info_pathname=""
        fi
    fi

    if [ -z "$backup_pathname" ] || [ ! -f "$backup_pathname" ]; then
        echo "❌ No backup found for: $backup_date"
        exit 1
    fi
    
    if [ -z "$info_pathname" ] || [ ! -f "$info_pathname" ]; then
        echo "❌ No info file found for: $backup_date"
        exit 1
    fi
    
    echo -e "\n📊 Backup Information for: $backup_date"
    echo "📁 Backup: $(basename "$backup_pathname")"
    echo "📄 Info: $(basename "$info_pathname")"
    
    # Pretty print JSON
    if command -v jq >/dev/null 2>&1; then
        jq . "$info_pathname"
    else
        cat "$info_pathname"
    fi

    echo ""
}

# [ ] [REV-X]
verify_backup() {
    local backup_date="${1:-latest}"
    local backup_dir
    
    if [ "$backup_date" = "latest" ]; then
        backup_dir="$BACKUP_BASE_DIR/latest"
        if [ ! -L "$backup_dir" ]; then
            echo "❌ No latest backup found"
            exit 1
        fi
        backup_dir="$BACKUP_BASE_DIR/$(readlink "$backup_dir")"
    else
        backup_dir="$BACKUP_BASE_DIR/$backup_date"
    fi
    
    local backup_file="$backup_dir/database_backup.sql"
    local verify_log="$backup_dir/verification.log"
    
    echo "🔍 Verifying backup: $backup_dir"
    
    if [ ! -f "$backup_file" ]; then
        echo "❌ Backup file not found: $backup_file"
        exit 1
    fi
    
    # Basic file checks
    if [ ! -s "$backup_file" ]; then
        echo "❌ Backup file is empty"
        exit 1
    fi
    
    # Check if file looks like a valid SQL dump
    if ! head -20 "$backup_file" | grep -q "mysqldump"; then
        echo "⚠️  File doesn't appear to be a mysqldump backup"
    fi
    
    # Check for basic SQL structure
    local checks=(
        "CREATE TABLE"
        "INSERT INTO"
        "UNLOCK TABLES"
    )
    
    echo "🔎 Running integrity checks..." > "$verify_log"
    
    for check in "${checks[@]}"; do
        if grep -q "$check" "$backup_file"; then
            echo "✅ Found: $check" | tee -a "$verify_log"
        else
            echo "⚠️  Missing: $check" | tee -a "$verify_log"
        fi
    done
    
    # File size check
    local file_size=$(stat -f%z "$backup_file" 2>/dev/null || stat -c%s "$backup_file" 2>/dev/null || echo 0)
    if [ "$file_size" -gt 1024 ]; then
        echo "✅ File size: $(du -h "$backup_file" | cut -f1)" | tee -a "$verify_log"
    else
        echo "⚠️  File size suspiciously small: $file_size bytes" | tee -a "$verify_log"
    fi
    
    echo "✅ Backup verification completed. See: $verify_log"
}

# [ ] [REV-X]
cleanup_old_backups() {
    echo "🧹 Cleaning up backups older than $KEEP_DAYS days..."
    
    confirm_action "cleanup"
    
    local deleted_count=0
    local cutoff_date=$(date -d "$KEEP_DAYS days ago" +%Y-%m-%d 2>/dev/null || date -v-${KEEP_DAYS}d +%Y-%m-%d 2>/dev/null)
    
    for backup_dir in "$BACKUP_BASE_DIR"/*/; do
        if [ -d "$backup_dir" ]; then
            local basename=$(basename "$backup_dir")
            
            # Skip if not a date directory
            if [[ ! "$basename" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                continue
            fi
            
            # Compare dates
            if [[ "$basename" < "$cutoff_date" ]]; then
                echo "🗑️  Deleting old backup: $basename"
                rm -rf "$backup_dir"
                ((deleted_count++))
            fi
        fi
    done
    
    # Update latest symlink if it's broken
    if [ -L "$BACKUP_BASE_DIR/latest" ] && [ ! -d "$BACKUP_BASE_DIR/latest" ]; then
        rm "$BACKUP_BASE_DIR/latest"
        # Find the newest backup and link to it
        local newest=$(ls -1 "$BACKUP_BASE_DIR" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' | sort | tail -1)
        if [ -n "$newest" ]; then
            ln -sf "$newest" "$BACKUP_BASE_DIR/latest"
            echo "🔗 Updated latest link to: $newest"
        fi
    fi
    
    echo "✅ Cleanup completed. Deleted $deleted_count old backups."
}

# [ ] [REV-X] !mark
# [ ] add support for date-option in `info [date]`.  currently only shows latest backup info.
# echo "  info [date]            Show backup information (default: latest)"
show_usage() {
    echo "Usage: $0 [ACTION] [OPTIONS]"
    echo ""
    echo "Actions:"
    echo "  backup [description]   Create a new database backup"
    echo "  restore [date]         Restore from backup (default: latest)"
    echo "  list                   List all available backups"
    echo "  info [date]            Show backup information (default: latest)"
    echo "  verify [date]          Verify backup integrity (default: latest)"
    echo "  cleanup                Remove old backups (keeps last $KEEP_DAYS days)"
    echo ""
    echo "Options:"
    echo "  --force                Skip confirmation prompts"
    echo ""
    echo "Examples:"
    echo "  $0 backup                           # Create backup"
    echo "  $0 backup \"Before update\"           # Create backup with description"
    echo "  $0 restore                          # Restore from latest"
    echo "  $0 restore 2024-12-25               # Restore from specific date"
    echo "  $0 restore --force                  # Restore without confirmation"
    echo "  $0 list                             # List all backups"
    echo "  $0 info                             # Show latest backup info"
    echo "  $0 verify 2024-12-25                # Verify specific backup"
    echo "  $0 cleanup                          # Clean old backups"
    echo ""
    echo "Environment Variables:"
    echo "  BACKUP_DIR             Custom backup directory (default: ../backups)"
    echo "  BACKUP_KEEP_DAYS       Days to keep backups (default: 2)"
}

#MAIN EXECUTION !mark
main() {
    # Load environment variables
    load_environment_variables "$ENV_DIR"
    
    # Validate required environment variables
    validate_environment_variables
    
    # Check database connection for actions that need it
    if [[ "$ACTION" != "list" && "$ACTION" != "info" && "$ACTION" != "verify" && "$ACTION" != "cleanup" && "$ACTION" != "help" ]]; then
        check_database_connection
    fi

    case "$ACTION" in
        "backup")
            create_backup "$ARG2"   # description
            ;;
        "restore")
            restore_backup "$ARG2"
            ;;
        "list")
            list_backups
            ;;
        "info")
            show_backup_info "$ARG2"
            ;;
        "verify")
            verify_backup "$ARG2"
            ;;
        "cleanup")
            cleanup_old_backups
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            echo "❌ Unknown action: $ACTION"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"