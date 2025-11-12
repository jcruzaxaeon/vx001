

```sh
run_latest_down_migration() {
    echo "🔍 Finding latest migration to roll back..."
    
    local latest_migration
    latest_migration=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_DEV_USER" -p"$DB_DEV_PASS" "$DB_NAME" \
        -sN -e "SELECT migration FROM migrations ORDER BY executed_at DESC LIMIT 1")
    
    if [[ -z "$latest_migration" ]]; then
        echo "📭 No migrations to roll back"
        return
    fi
    
    echo "⏪ Rolling back latest migration: $latest_migration"
    run_migration "down" "$latest_migration"
}
```