#!/bin/bash

# ./database/ops/migrate.sh
set -euo pipefail



#VARIABLES
#
#
#
SCRIPT_DIR="$(dirname "$0")"
MIGRATIONS_DIR="$SCRIPT_DIR/../migrations"
ACTION="${1:-up}"  #`1:` = First argument. `-up` = Default: 'up'
MIGRATION_NAME="${2:-}"  #`2:` = Second argument. Optional specific migration file.
ENV_DIR="$SCRIPT_DIR/../../.env"



#FUNCTIONS
#
#
#
load_environment_variables() {
    local filename="$1"

    if [ -f "$filename" ]; then
        echo "📁 Loading environment variables from: $filename"
        #export $(grep -v '^#' "$filename" | grep -v '^$' | xargs)
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

run_migration() {
    local direction="$1"
    local migration_name="$2"
    local path_and_filename="$MIGRATIONS_DIR/${migration_name}.${direction}.sql"

    #If direction is down,

    if [[ ! -f "$path_and_filename" ]]; then
        echo "❌ Migration file not found: $path_and_filename"
        exit 1
    fi

    echo "🔄 Running migration: ${migration_name}.${direction}.sql"

    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" < "$path_and_filename"

    echo "✅ Migration completed: ${migration_name}.${direction}.sql"
}

check_migrations_table() {
    local migrations_table_exists

    migrations_table_exists=$( \
        mysql -h"$DB_HOST" -P"$DB_PORT" \
            -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" -sN -e \
                "SELECT COUNT(*) FROM information_schema.tables \
                    WHERE table_schema='$DB_NAME' \
                    AND table_name='migrations'" \
    )

    if [ "$migrations_table_exists" -eq 0 ]; then
        echo "❌ Migrations table doesn't exist. Run setup.sh first."
        exit 1
    fi
}

run_all_pending_migrations() {
    echo "🔍 Checking for pending migrations..."

    #PLACE ALL `*.up.sql` INTO AN ARRAY-VARIABLE, `migration_files`
    local migration_files   #[array]

    #Breakdown:
    #    - `find [directory] [options]`: searches for files in the specified directory
    #        - `-print0`: output filenames terminated by a null character (`\0`) instead of newline
    #    - `-name "*.up.sql"`: only include files whose name ends with `.up.sql`
    #    - `-type f`: only include files (not directories)
    #    - `| sort`: pipe list of pathnames to `sort` (ascending lexicographical order)
    #        - `-z`: use null character (`\0`) as delimiter (instead of newline)
    #    - `<(...)`: process substitution; run (...) in a subshell, and redirect output as if it were a file
    #        - e.g.     <(...)       ~=       "find-sort-output_temp.txt"
    #        - holds a list of pathnames for all migration files in a temporary file
    #    - `mapfile [options] var < input`: place lines from `input` into var[array]
    #        - one line per array element
    #        - `input`: standard input, input stream, file, or process-substitution output
    #        - `var`: array-variable
    #    - `-t`: remove trailing newlines from each line of input
    #    - `xargs`: takes standard input and builds command lines arguments out of that input
    #        - `-0`: expect input items to be delimited by a null character
    #        - `-n1`: use one argument per command line
    # mapfile -t migration_files < <(find "$MIGRATIONS_DIR" -name "*.up.sql" -type f | sort)
    mapfile -t migration_files < <(
        find "$MIGRATIONS_DIR" -type f -name "*.up.sql" -print0 \
            | sort -z \
            | xargs -0 -n1
    )

    if [[ ${#migration_files[@]} -eq 0 ]]; then
        echo "📭 No migration files found in $MIGRATIONS_DIR"
        return
    fi

    #Breakdown:
    #    - `basename [pathname] [sufix]`: strip path and suffix from pathname
    for pathname in "${migration_files[@]}"; do
        local stem
        #BASH
        #stem=$(basename "$pathname" .up.sql)
        #POSIX-safe
        stem="${pathname##*/}"      # Strip path
        stem="${stem%.up.sql}"  # Strip suffix

        # Check if migration already ran
        local already_ran
        already_ran=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" \
            -sN -e "SELECT COUNT(*) FROM migrations WHERE migration='$stem'")

        if [[ "$already_ran" -eq 0 ]]; then
            echo "📦 Found pending migration: $stem"
            run_migration "up" "$stem"
        else
            echo "⏭️  Skipping (already ran): $stem"
        fi
    done
}

#ROLLBACK LATEST DOWN MIGRATION
rollback_last_migration() {
    echo "🔍 Finding latest migration to roll back..."
    
    local last_migration
    # last_migration=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" \
    #     -sN -e "SELECT migration FROM migrations ORDER BY executed_at DESC LIMIT 1")
    # last_migration=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" \
    #     -sN -e "SELECT migration FROM migrations ORDER BY executed_at DESC, migration DESC LIMIT 1")
    last_migration=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" \
        -sN -e "SELECT migration FROM migrations ORDER BY CAST(SUBSTRING_INDEX(migration, '_', 1) \
        AS UNSIGNED) DESC LIMIT 1")

    if [[ -z "$last_migration" ]]; then
        echo "📭 No migrations to roll back"
        return
    fi
    echo "⏪ Rolling back latest migration: $last_migration"
    run_migration "down" "$last_migration"
}

show_usage() {
    echo "Usage: $0 [up|down] [migration_name]"
    echo ""
    echo "Examples:"
    echo "  $0 up                    # Run all pending up migrations"
    echo "  $0 down                  # Run latest down migration"
    echo "  $0 up 001_create_users   # Run specific up migration"
    echo "  $0 down 001_create_users # Run specific down migration"
    exit 1
}



# MAIN SCRIPT
#
#
#
load_environment_variables "$ENV_DIR"
validate_environment_variables
if [[ -n "$MIGRATION_NAME" ]]; then
    MIGRATION_FILE="$MIGRATION_NAME"
else
    MIGRATION_FILE=""
fi

echo "🚀 Database Migration Runner"
echo "   Database: $DB_NAME"
echo "   Action: $ACTION"

# Validate arguments
if [[ "$ACTION" != "up" && "$ACTION" != "down" ]]; then
    echo "❌ Invalid action: $ACTION"
    show_usage
fi

# Check if migrations directory exists
if [[ ! -d "$MIGRATIONS_DIR" ]]; then
    echo "❌ Migrations directory not found: $MIGRATIONS_DIR"
    exit 1
fi

# Check migrations table exists
check_migrations_table

# Run migrations based on arguments
if [[ -n "$MIGRATION_FILE" ]]; then
    # Run specific migration
    run_migration "$ACTION" "$MIGRATION_FILE"
elif [[ "$ACTION" == "up" ]]; then
    # Run all pending up migrations
    run_all_pending_migrations
elif [[ "$ACTION" == "down" ]]; then
    # Run latest down migration
    rollback_last_migration
fi

echo "🎉 Migration process completed!"

# Show current migration status
echo ""
echo "📊 Current migration status:"
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" \
    -e "SELECT migration, executed_at FROM migrations ORDER BY executed_at DESC LIMIT 5"