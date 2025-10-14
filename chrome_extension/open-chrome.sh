#!/bin/bash

# Get the absolute path to the chrome_extension directory
EXTENSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo $EXTENSION_DIR
echo "Opening Chrome with extension from: $EXTENSION_DIR"

# Check if Chrome is already running with the extension
# If so, kill it to reload with fresh build
pkill -f "chrome.*--load-extension.*sweaty_wallet" 2>/dev/null

# Determine Chrome binary location (works for most Linux distros)
if command -v google-chrome &> /dev/null; then
    CHROME_BIN="google-chrome"
elif command -v google-chrome-stable &> /dev/null; then
    CHROME_BIN="google-chrome-stable"
elif command -v chromium &> /dev/null; then
    CHROME_BIN="chromium"
elif command -v chromium-browser &> /dev/null; then
    CHROME_BIN="chromium-browser"
else
    echo "Error: Chrome/Chromium not found. Please install Google Chrome or Chromium."
    exit 1
fi

# Open Chrome with the extension loaded
# --load-extension: loads the unpacked extension
# --no-first-run: skips first run wizards
# --no-default-browser-check: skips default browser check
$CHROME_BIN \
    --user-data-dir=/tmp/chrome-dev-profile \
    --load-extension="$EXTENSION_DIR" \
    --no-first-run \
    --no-default-browser-check \
    &

echo "Chrome opened with extension loaded!"
