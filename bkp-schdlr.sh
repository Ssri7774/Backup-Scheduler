#!/bin/bash

# Backup the database
backup_dir="/root/backups"
daily_dir="$backup_dir/daily"
weekly_dir="$backup_dir/weekly"
monthly_dir="$backup_dir/monthly"

current_date=$(date +%F_%H-%M-%S)  # Update the time format to use '-'

# Create backup directories if they don't exist
mkdir -p "$daily_dir" "$weekly_dir" "$monthly_dir"

# Perform daily backup
cd /root/netbox-docker/ && /usr/local/bin/docker-compose exec -T postgres sh -c 'pg_dump -cU $POSTGRES_USER $POSTGRES_DB' | gzip > "$daily_dir/db_dump_$current_date.sql.gz"

# Cleanup old daily backups (older than 30 days)
find "$daily_dir" -name "db_dump_*" -mtime +30 -exec rm {} \;

# Determine if it's Monday of the week
day_of_week=$(date +%u)
is_first_monday=false

if [ "$day_of_week" -eq 1 ]; then
    is_first_monday=true
fi

# Perform weekly backup (only on Monday of the week)
if [ "$is_first_monday" = true ]; then
    # Find the most recent backup file in the daily directory
    latest_daily_backup=$(find "$daily_dir" -name "db_dump_*.sql.gz" -type f -printf "%T@ %p\n" | sort -nr | head -n 1 | awk '{print $2}')
    if [ -n "$latest_daily_backup" ]; then
        cp "$latest_daily_backup" "$weekly_dir/"
        echo "Copied daily backup '$latest_daily_backup' to the weekly directory."
    else
        echo "No daily backups found to copy to the weekly directory."
    fi

    # Cleanup old weekly backups (older than 3 months)
    find "$weekly_dir" -name "db_dump_*" -mtime +90 -exec rm {} \;
fi

# Determine if it's the first Monday of the month
day_of_month=$(date +%d)
is_first_monday=false

if [ "$day_of_month" -le 7 ] && [ "$day_of_week" -eq 1 ]; then
    is_first_monday=true
fi

# Perform monthly backup (only on the first Monday of the month)
if [ "$is_first_monday" = true ]; then
    # Find the most recent backup file in the daily directory
    latest_daily_backup=$(find "$daily_dir" -name "db_dump_*.sql.gz" -type f -printf "%T@ %p\n" | sort -nr | head -n 1 | awk '{print $2}')
    if [ -n "$latest_daily_backup" ]; then
        cp "$latest_daily_backup" "$monthly_dir/"
        echo "Copied daily backup '$latest_daily_backup' to the monthly directory."
    else
        echo "No daily backups found to copy to the monthly directory."
    fi

    # Cleanup old monthly backups (older than a year)
    find "$monthly_dir" -name "db_dump_*" -mtime +365 -exec rm {} \;
fi
