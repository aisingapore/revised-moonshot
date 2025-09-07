#!/bin/bash
# Setup script for Moonshot data directory symlink
# Run this script after cloning the repository to set up the data directory link

set -e

echo "Setting up Moonshot data directory symlink..."

# Get the script directory (should be in revised-moonshot root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOONSHOT_DIR="$SCRIPT_DIR/moonshot"
DATA_LINK="$MOONSHOT_DIR/data"
DATA_TARGET="../../revised-moonshot-data"

# Check if we're in the right directory structure
if [ ! -d "$MOONSHOT_DIR" ]; then
    echo "Error: This script should be run from the revised-moonshot directory"
    echo "Expected to find: $MOONSHOT_DIR"
    exit 1
fi

# Check if the target data directory exists
EXPECTED_DATA_DIR="$SCRIPT_DIR/../revised-moonshot-data"
if [ ! -d "$EXPECTED_DATA_DIR" ]; then
    echo "Error: revised-moonshot-data directory not found at: $EXPECTED_DATA_DIR"
    echo "Please ensure both revised-moonshot and revised-moonshot-data directories are in the same parent directory"
    exit 1
fi

# Remove existing data directory/link if it exists
if [ -e "$DATA_LINK" ]; then
    echo "Removing existing data directory/link at: $DATA_LINK"
    rm -rf "$DATA_LINK"
fi

# Create the symlink
echo "Creating symlink: $DATA_LINK -> $DATA_TARGET"
ln -s "$DATA_TARGET" "$DATA_LINK"

# Verify the symlink was created correctly
if [ -L "$DATA_LINK" ] && [ -d "$DATA_LINK" ]; then
    echo "✅ Successfully created data directory symlink"
    echo "   Link: $DATA_LINK"
    echo "   Target: $(readlink "$DATA_LINK")"
    echo "   Resolved: $(realpath "$DATA_LINK")"
    
    # Check if some key directories are accessible
    echo ""
    echo "Verifying data directory structure:"
    for dir in "cookbooks" "connectors" "connectors-endpoints" "io-modules"; do
        if [ -d "$DATA_LINK/$dir" ]; then
            count=$(find "$DATA_LINK/$dir" -name "*.py" -o -name "*.json" | wc -l)
            echo "  ✅ $dir ($count files)"
        else
            echo "  ❌ $dir (missing)"
        fi
    done
    
    echo ""
    echo "Setup complete! You can now run the Moonshot web API with:"
    echo "  python -m moonshot web-api"
    
else
    echo "❌ Failed to create symlink"
    exit 1
fi
