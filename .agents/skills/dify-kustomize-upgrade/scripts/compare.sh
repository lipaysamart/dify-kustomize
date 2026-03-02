#!/bin/bash
# Compare docker-compose.yaml between two Dify versions
# Usage: ./compare-compose.sh <old_version> <new_version> [output_file]

set -e

OLD_VERSION="${1:-}"
NEW_VERSION="${2:-}"
OUTPUT_FILE="${3:-/dev/stdout}"

if [ -z "$OLD_VERSION" ] || [ -z "$NEW_VERSION" ]; then
    echo "Usage: $0 <old_version> <new_version> [output_file]"
    echo "Example: $0 1.11.1 1.12.1"
    exit 1
fi

OLD_URL="https://raw.githubusercontent.com/langgenius/dify/refs/tags/${OLD_VERSION}/docker/docker-compose.yaml"
NEW_URL="https://raw.githubusercontent.com/langgenius/dify/refs/tags/${NEW_VERSION}/docker/docker-compose.yaml"

TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Fetching docker-compose files..."
curl -sL "$OLD_URL" -o "$TEMP_DIR/old.yaml"
curl -sL "$NEW_URL" -o "$TEMP_DIR/new.yaml"

echo "Comparing $OLD_VERSION -> $NEW_VERSION..."
echo ""

if [ "$OUTPUT_FILE" = "/dev/stdout" ]; then
    diff -u "$TEMP_DIR/old.yaml" "$TEMP_DIR/new.yaml" || true
else
    diff -u "$TEMP_DIR/old.yaml" "$TEMP_DIR/new.yaml" > "$OUTPUT_FILE" || true
    echo "Diff saved to: $OUTPUT_FILE"
fi