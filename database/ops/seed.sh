#!/bin/bash

# ./database/ops/seed.sh
set -euo pipefail



#VARIABLES
#
#
#
SCRIPT_DIR="$(dirname "$0")"
SEEDS_DIR="$SCRIPT_DIR/../seeds"
ACTION="${1:-run}"  # First argument. Default: 'run' (could also support 'clear' later)
SEED_NAME="${2:-}"  # Second argument. Optional specific seed file.
ENV_DIR="$SCRIPT_DIR/../../.env"



#FUNCTIONS
#
#
#
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

run_single_seed() {
    local seed_name="$1"
    local seed_file="$SEEDS_DIR/${seed_name}.seed.sql"

    if [[ ! -f "$seed_file" ]]; then
        echo "❌ Seed file not found: $seed_file"
        exit 1
    fi

    echo "🌱 Running seed: ${seed_name}.seed.sql"

    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" < "$seed_file"

    echo "✅ Seed completed: ${seed_name}.seed.sql"
}

run_all_seeds() {
    if [[ ! -d "$SEEDS_DIR" ]]; then
        echo "❌ Seeds directory not found: $SEEDS_DIR"
        exit 1
    fi

    echo "🌱 Running all seed files in order..."

    # Find all .seed.sql files, sort them, and run each one
    local seed_files=($(find "$SEEDS_DIR" -type f -name '*.seed.sql' | sort))

    if [ ${#seed_files[@]} -eq 0 ]; then
        echo "⚠️  No seed files found in $SEEDS_DIR"
        exit 0
    fi

    for seed_file in "${seed_files[@]}"; do
        local seed_basename=$(basename "$seed_file")
        echo "🌱 Running seed: $seed_basename"
        
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" < "$seed_file"
        
        echo "✅ Seed completed: $seed_basename"
    done

    echo "🎉 All seeds completed successfully!"
}

show_usage() {
    echo "Usage: $0 [ACTION] [SEED_NAME]"
    echo ""
    echo "Actions:"
    echo "  run        Run all seeds (default)"
    echo "  run [name] Run specific seed file"
    echo ""
    echo "Examples:"
    echo "  $0                    # Run all seeds"
    echo "  $0 run                # Run all seeds"
    echo "  $0 run users          # Run users.seed.sql"
}



#MAIN EXECUTION
#
#
#
main() {
    # Load environment variables
    load_environment_variables "$ENV_DIR"
    
    # Validate required environment variables
    validate_environment_variables

    case "$ACTION" in
        "run")
            if [[ -n "$SEED_NAME" ]]; then
                run_single_seed "$SEED_NAME"
            else
                run_all_seeds
            fi
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