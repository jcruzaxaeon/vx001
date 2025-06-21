#!/bin/bash

# ./database/ops/data.sh - Database backup and restore utility
set -euo pipefail

#VARIABLES
SCRIPT_DIR="$(dirname "$0")"
ACTION="${1:-help}"
ARG2="${2:-}"
ENV_DIR="$SCRIPT_DIR/../../.env"

# Only used in case of custom backup directory path set in environment variable BACKUP_DIR
BACKUP_BASE_DIR="${BACKUP_DIR:-$SCRIPT_DIR/../backups}"   #Usage: "$BACKUP_DIR="/custom/path" ./database/ops/data.sh backup"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DATE_ONLY=$(date +"%Y%m%d")
KEEP_DAYS="${BACKUP_KEEP_DAYS:-7}"

#FUNCTIONS

#[x] review
load_environment_variables() {
    local filename="$1"

    if [ -f "$filename" ]; then
        echo "📁 Loading environment variables from: $filename"
        set -o allexport
        source "$filename"
        set +o allexport
    else
        echo "⚠️  Environment file '$filename' not found!"
        exit 1
    fi
}

#[x] review
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

#[x] review
check_database_connection() {
    local connection_test

    connection_test=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" -e "SELECT 1" 2>/dev/null || echo "failed")

    if [ "$connection_test" = "failed" ]; then
        echo "❌ Cannot connect to database. Please check your connection settings."
        exit 1
    fi
}

#[ ] review
create_backup_directory() {
    local backup_dir="$1"
    
    if [ ! -d "$backup_dir" ]; then
        echo "📁 Creating backup directory: $backup_dir"
        mkdir -p "$backup_dir"
    fi
}

confirm_action() {
    local action="$1"
    local target="${2:-}"
    
    if [[ "$ARG2" == "--force" ]]; then
        echo "🚨 Force mode: Skipping confirmation"
        return 0
    fi
    
    case "$action" in
        "restore")
            echo "⚠️  WARNING: This will replace ALL data in database: $DB_NAME"
            echo "⚠️  Current data will be permanently lost!"
            [ -n "$target" ] && echo "⚠️  Restoring from: $target"
            ;;
        "cleanup")
            echo "⚠️  WARNING: This will delete backup files older than $KEEP_DAYS days"
            ;;
    esac
    
    echo ""
    read -p "Are you sure you want to proceed? (yes/no): " -r
    echo ""
    
    if [[ $REPLY != "yes" ]]; then
        echo "❌ Operation cancelled by user"
        exit 0
    fi
}

create_backup() {
    local description="${1:-}"
    # local backup_dir="$BACKUP_BASE_DIR/$DATE_ONLY"
    local backup_pathname="$BACKUP_BASE_DIR/bak_$TIMESTAMP.sql"
    local info_dir="$BACKUP_BASE_DIR/metadata"
    local info_pathname="$BACKUP_BASE_DIR/metadata/$TIMESTAMP.json"
    local log_pathname="$BACKUP_BASE_DIR/backup.log"
    
    echo "💾 Creating database backup..."
    mkdir -p "$info_dir"
    
    # create_backup_directory "$backup_dir"
    # echo "📂 Backup directory: $backup_dir"

    # Create backup
    echo "📤 Exporting database: $DB_NAME"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting backup for database: $DB_NAME" >> "$log_pathname"
    mysqldump -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        --opt \
        "$DB_NAME" > "$backup_pathname" 2>>"$log_pathname"
    
    # Create metadata
    cat > "$info_pathname" << EOF
{
    "timestamp": "$TIMESTAMP",
    "date": "$DATE_ONLY",
    "database": "$DB_NAME",
    "host": "$DB_HOST",
    "port": "$DB_PORT",
    "user": "$DB_DEV_USER",
    "description": "$description",
    "file_size": "$(stat -f%z "$backup_pathname" 2>/dev/null || stat -c%s "$backup_pathname" 2>/dev/null || echo 'unknown')",
    "tables_count": "$(grep -c "CREATE TABLE" "$backup_pathname" || echo 'unknown')",
    "created_by": "$(whoami)",
    "hostname": "$(hostname)"
}
EOF

# Create/update latest symlink
# local latest_link="$BACKUP_BASE_DIR/latest"
# if [ -L "$latest_link" ] || [ -e "$latest_link" ]; then
#     rm -f "$latest_link"
# fi
# ln -snf "$backup_dir" "$latest_link"

# Copy to latest fixed backup file
local latest_backup_file="$BACKUP_BASE_DIR/bak.sql"
cp "$backup_pathname" "$latest_backup_file"
echo "📎 Latest backup copied to: $latest_backup_file"

# Verify backup
if [ -f "$backup_pathname" ] && [ -s "$backup_pathname" ]; then
    echo "✅ Backup created successfully: $backup_pathname"
    echo "📊 Backup size: $(du -h "$backup_pathname" | cut -f1)"
    echo "📋 Tables backed up: $(grep -c "CREATE TABLE" "$backup_pathname" || echo 'unknown')"
    [ -n "$description" ] && echo "📝 Description: $description"
else
    echo "❌ Backup failed or file is empty"
    exit 1
fi

}

restore_backup() {
    local backup_date="${1:-latest}"
    local backup_pathname
    local info_pathname

    if [ "$backup_date" = "latest" ]; then
        echo "Breakpoint 1"
        backup_pathname="$BACKUP_BASE_DIR/bak.sql"
        # info_pathname=$(ls "$BACKUP_BASE_DIR/metadata/"*"$DATE_ONLY"*.json 2>/dev/null | tail -1)
    else
        backup_pathname="$BACKUP_BASE_DIR/bak_$backup_date.sql"
        # info_pathname="$BACKUP_BASE_DIR/metadata/${backup_date}.json"
    fi

    if [ ! -f "$backup_pathname" ]; then
        echo "❌ Backup file not found: $backup_pathname"
        exit 1
    fi

    echo "🔄 Restoring database from backup..."
    echo "📄 Backup file: $backup_pathname"

    # if [ -f "$info_pathname" ]; then
    #     echo "📊 Backup info:"
    #     grep -E '"(timestamp|description|file_size|tables_count)"' "$info_pathname" | sed 's/^/    /'
    # fi

    confirm_action "restore" "$backup_pathname"

    echo "🗄️  Restoring database: $DB_NAME"
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" < "$backup_pathname"

    echo "✅ Database restore completed successfully"
}

list_backups() {
    echo "📋 Available backups:"
    
    if [ ! -d "$BACKUP_BASE_DIR" ]; then
        echo "❌ No backups directory found: $BACKUP_BASE_DIR"
        return 1
    fi
    
    local found_backups=false
    for backup_dir in "$BACKUP_BASE_DIR"/*/; do
        if [ -d "$backup_dir" ] && [ -f "$backup_dir/database_backup.sql" ]; then
            found_backups=true
            local basename=$(basename "$backup_dir")
            local info_file="$backup_dir/backup_info.json"
            local size="$(du -h "$backup_dir/database_backup.sql" 2>/dev/null | cut -f1 || echo 'unknown')"
            
            echo "  📁 $basename (Size: $size)"
            
            if [ -f "$info_file" ]; then
                local description=$(grep '"description"' "$info_file" | cut -d'"' -f4)
                local timestamp=$(grep '"timestamp"' "$info_file" | cut -d'"' -f4)
                [ -n "$description" ] && echo "     📝 $description"
                [ -n "$timestamp" ] && echo "     🕒 $timestamp"
            fi
        fi
    done
    
    if [ "$found_backups" = false ]; then
        echo "❌ No backups found in: $BACKUP_BASE_DIR"
        return 1
    fi
    
    # Show latest link
    if [ -L "$BACKUP_BASE_DIR/latest" ]; then
        echo ""
        echo "🔗 latest -> $(readlink "$BACKUP_BASE_DIR/latest")"
    fi
}

show_backup_info() {
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
    
    local info_file="$backup_dir/backup_info.json"
    
    if [ ! -f "$info_file" ]; then
        echo "❌ Backup info not found: $info_file"
        exit 1
    fi
    
    echo "📊 Backup Information:"
    echo "📁 Location: $backup_dir"
    echo ""
    
    # Pretty print JSON
    if command -v jq >/dev/null 2>&1; then
        jq . "$info_file"
    else
        cat "$info_file"
    fi
}

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
    echo "  $0 backup \"Before update\"          # Create backup with description"
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
    echo "  BACKUP_KEEP_DAYS       Days to keep backups (default: 7)"
}

#MAIN EXECUTION
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
            create_backup "$ARG2"
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