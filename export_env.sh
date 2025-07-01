#!/bin/bash

# set -e  # Commented out to handle errors manually

# Require environment name as an argument
if [ $# -lt 1 ]; then
    echo "Usage: $0 <env-name>"
    exit 1
fi

ENV_NAME="$1"
FLOX_DIR=".flox"
RUN_DIR="$FLOX_DIR/run"
SIMPLE_STORE="$(pwd)/simple-store"
EXPORT_DIR="export"
ARCHIVE1="$EXPORT_DIR/simple-store.tar.gz"
ARCHIVE2="$EXPORT_DIR/flox-folder.tar.gz"
# Find the .dev file in $HOME/.flox/run matching the environment name
FLOX_RUN_PATH=$(find $RUN_DIR -name "*.dev" | head -n 1)

if [ -z "$FLOX_RUN_PATH" ]; then
    echo "Error: No .dev file found for environment '$ENV_NAME' in $HOME/.flox/run."
    exit 1
fi

RUN_DIR="$FLOX_DIR/run"

# Check for .flox directory
if [ ! -d "$FLOX_DIR" ]; then
    echo "Error: $FLOX_DIR not found in current directory."
    exit 1
fi

# Check for run directory inside .flox
if [ ! -d "$RUN_DIR" ]; then
    echo "Error: $RUN_DIR not found inside $FLOX_DIR."
    exit 1
fi

# Check if nix is installed
if ! command -v nix >/dev/null 2>&1; then
  echo "Error: nix command not found. Please install Nix."
  exit 1
fi

# Check if FLOX_RUN_PATH exists
if [ ! -e "$FLOX_RUN_PATH" ]; then
  echo "Error: $FLOX_RUN_PATH does not exist."
  exit 1
fi

# Create export directory
mkdir -p "$EXPORT_DIR"

# Give 777 permissions to .flox directory and its contents
echo "Setting permissions 777 on $FLOX_DIR and its contents"
chmod -R 777 "$FLOX_DIR"

# Tar and gzip .flox folder
echo "Tar and gzip .flox folder"
tar -czf "$ARCHIVE2" "$FLOX_DIR"

# nix copy command
echo "Running: nix copy \"$FLOX_RUN_PATH\" --to \"file://$SIMPLE_STORE\" --no-check-sigs"
if ! nix copy "$FLOX_RUN_PATH" --to "file://$SIMPLE_STORE" --no-check-sigs --extra-experimental-features nix-command; then
  echo "Error: nix copy failed."
  exit 1
fi
echo "nix copy succeeded."
echo "Exported archives:"
# Tar and gzip simple-store
#if [ ! -d "$SIMPLE_STORE" ]; then
#  echo "Error: $SIMPLE_STORE was not created."
#  exit 1
#fi
tar -cvf simple-store.tar simple-store
gzip simple-store.tar
mv simple-store.tar.gz $EXPORT_DIR

echo " - $ARCHIVE1"
echo " - $ARCHIVE2"
