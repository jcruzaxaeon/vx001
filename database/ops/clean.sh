#!/bin/bash

# ./database/ops/clean.sh
set -euo pipefail

#VARIABLES
SCRIPT_DIR="$(dirname "$0")"
ACTION="${1:-clean}"  # First argument. Default: 'clean'
ENV_DIR="$SCRIPT_DIR/../../.env"

#FUNCTIONS
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

validate_environment_variables() {
    local vars=(
        "DB_NAME" "DB_HOST" "DB_PORT"
        "DB_DEV_USER" "DB_DEV_PASS"
        "DB_APP_USER" "DB_APP_PASS"
    )

    for var in "${vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            echo "❌ Required environment variable '$var' is not set in $ENV_DIR"
            exit 1
        fi
    done
}

confirm_action() {
    local db_name="$1"
    
    echo "⚠️  WARNING: This will remove all seeded data from database: $db_name"
    echo "⚠️  This action cannot be undone!"
    echo ""
    read -p "Are you sure you want to proceed? (yes/no): " -r
    echo ""
    
    if [[ $REPLY != "yes" ]]; then
        echo "❌ Operation cancelled by user"
        exit 0
    fi
}

run_clean() {
    echo "🧹 Cleaning seeded data from database: $DB_NAME"
    echo "Connected as user: $DB_DEV_USER"

    # Execute the cleaning SQL directly
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" << 'EOF'
SET FOREIGN_KEY_CHECKS = 0;

-- Add your table cleanup statements here
-- Order matters: clean child tables before parent tables to avoid foreign key constraints

-- Example cleanup statements (uncomment and modify as needed):
TRUNCATE TABLE nodes;
TRUNCATE TABLE users;

-- Alternative: Delete with WHERE clauses if you want to preserve some data
-- DELETE FROM users WHERE email LIKE '%@seed.example.com';
-- DELETE FROM products WHERE created_by = 'seed_script';

-- Reset AUTO_INCREMENT counters (optional)
ALTER TABLE users AUTO_INCREMENT = 1;
ALTER TABLE nodes AUTO_INCREMENT = 1;

SET FOREIGN_KEY_CHECKS = 1;
EOF

    echo "✅ Database cleanup completed"
}

run_clean_and_reseed() {
    # First clean
    run_clean

    echo "🧹 Database cleaned successfully. Now re-seeding..."
    
    # Then reseed
    local seed_script="$SCRIPT_DIR/seed.sh"
    
    if [[ ! -f "$seed_script" ]]; then
        echo "❌ Seed script not found: $seed_script"
        echo "💡 Please run seeds manually after cleanup"
        exit 1
    fi
    
    echo ""
    echo "🌱 Re-seeding database..."
    "$seed_script"
}

show_table_counts() {
    echo "📊 Current table record counts:"
    
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" << 'EOF'
SELECT 
    TABLE_NAME as 'Table',
    TABLE_ROWS as 'Rows'
FROM 
    information_schema.TABLES 
WHERE 
    TABLE_SCHEMA = DATABASE()
    AND TABLE_TYPE = 'BASE TABLE'
ORDER BY 
    TABLE_NAME;
EOF
}

check_database_connection() {
    local connection_test
    connection_test=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" -e "SELECT 1" 2>/dev/null || echo "failed")

    if [ "$connection_test" = "failed" ]; then
        echo "❌ Cannot connect to database. Please check your connection settings."
        exit 1
    fi
}

show_usage() {
    echo "Usage: $0 [ACTION]"
    echo ""
    echo "Actions:"
    echo "  clean       Remove all seeded data (default)"
    echo "  reseed      Clean database and re-run all seeds"
    echo "  force       Clean without confirmation prompt"
    echo "  status      Show current table record counts"
    echo ""
    echo "Examples:"
    echo "  $0                    # Clean with confirmation"
    echo "  $0 clean              # Clean with confirmation"
    echo "  $0 reseed             # Clean and re-seed"
    echo "  $0 force              # Clean without confirmation"
    echo "  $0 status             # Show table counts"
}

#MAIN EXECUTION
main() {
    # Load environment variables
    load_environment_variables "$ENV_DIR"
    
    # Validate required environment variables
    validate_environment_variables
    
    # Check database connection
    check_database_connection

    case "$ACTION" in
        "clean")
            confirm_action "$DB_NAME"
            run_clean
            ;;
        "reseed")
            confirm_action "$DB_NAME"
            run_clean_and_reseed
            ;;
        "force")
            echo "🚨 Force mode: Skipping confirmation"
            run_clean
            ;;
        "status")
            show_table_counts
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