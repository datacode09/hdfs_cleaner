#!/bin/bash

# File containing the list of directories
PATHS_FILE="paths.txt"

# Log file
LOG_FILE="delete_old_files_$(date +%Y-%m-%d_%H-%M-%S).log"

# Start logging
echo "Starting script at $(date)" | tee -a $LOG_FILE

# Cutoff date for 6 months ago in YYYY-MM-DD format
CUTOFF_DATE=$(date -d '6 months ago' +%Y-%m-%d)

# Read each path from the file
while IFS= read -r HDFS_DIR
do
    echo "Checking for files older than 6 months in $HDFS_DIR..." | tee -a $LOG_FILE

    # Listing all files and their modification dates in HDFS directory
    hdfs dfs -ls $HDFS_DIR | while read -r line; do
        # Extracting modification date and file path
        mod_date=$(echo $line | awk '{print $6}')
        file_path=$(echo $line | awk '{print $8}')

        # Check if the modification date is older than the cutoff date
        if [[ "$mod_date" < "$CUTOFF_DATE" ]]; then
            echo "Deleting old file: $file_path" | tee -a $LOG_FILE
            if hdfs dfs -rm "$file_path"; then
                echo "Successfully deleted: $file_path" | tee -a $LOG_FILE
            else
                echo "Failed to delete: $file_path" | tee -a $LOG_FILE
            fi
        fi
    done
done < "$PATHS_FILE"

echo "Deletion process completed." | tee -a $LOG_FILE
