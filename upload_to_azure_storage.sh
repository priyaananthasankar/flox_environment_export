#!/bin/bash

# Usage: ./upload_to_azure_storage.sh /path/to/export <storage_account> <file_share> [<share_directory>]

EXPORT_DIR="$1"
STORAGE_ACCOUNT="$2"
FILE_SHARE="$3"
SHARE_DIR="$4"

if [[ -z "$EXPORT_DIR" || -z "$STORAGE_ACCOUNT" || -z "$FILE_SHARE" ]]; then
    echo "Usage: $0 <export_folder> <storage_account> <file_share> [<share_directory>]"
    exit 1
fi

read -s -p "Enter Azure Storage Account Key: " ACCOUNT_KEY
echo

if [[ -z "$SHARE_DIR" ]]; then
    SHARE_DIR="flox_environment"
    # Check if directory exists in Azure File Share
    DIR_EXISTS=$(az storage directory exists \
        --account-name "$STORAGE_ACCOUNT" \
        --account-key "$ACCOUNT_KEY" \
        --share-name "$FILE_SHARE" \
        --name "$SHARE_DIR" \
        --query "exists" \
        --output tsv)
    if [[ "$DIR_EXISTS" != "true" ]]; then
        echo "Directory '$SHARE_DIR' does not exist. Creating it..."
        az storage directory create \
            --account-name "$STORAGE_ACCOUNT" \
            --account-key "$ACCOUNT_KEY" \
            --share-name "$FILE_SHARE" \
            --name "$SHARE_DIR"
        if [[ $? -ne 0 ]]; then
            echo "Failed to create directory '$SHARE_DIR' in Azure File Share."
            exit 1
        fi
    fi
fi

if [[ -z "$EXPORT_DIR" || -z "$STORAGE_ACCOUNT" || -z "$FILE_SHARE" || -z "$SHARE_DIR" ]]; then
    echo "Usage: $0 <export_folder> <storage_account> <file_share> <share_directory>"
    exit 1
fi



FILES=("flox-folder.tar.gz" "simple-store.tar.gz")

for FILE in "${FILES[@]}"; do
    FILE_PATH="$EXPORT_DIR/$FILE"
    if [[ ! -f "$FILE_PATH" ]]; then
        echo "File not found: $FILE_PATH"
        continue
    fi

    az storage file upload \
        --account-name "$STORAGE_ACCOUNT" \
        --account-key "$ACCOUNT_KEY" \
        --share-name "$FILE_SHARE" \
        --source "$FILE_PATH" \
        --path "$SHARE_DIR/$FILE"

    if [[ $? -eq 0 ]]; then
        echo "Uploaded $FILE to Azure File Share."
    else
        echo "Failed to upload $FILE."
    fi
done