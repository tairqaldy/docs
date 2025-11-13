#!/bin/bash

# CodeArchitect MCP - Cursor Setup Script
# This script automatically adds CodeArchitect MCP configuration to Cursor

set -e

# Determine OS and set config path
if [[ "$OSTYPE" == "darwin"* ]]; then
    CONFIG_DIR="$HOME/.cursor"
    CONFIG_FILE="$CONFIG_DIR/mcp.json"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CONFIG_DIR="$HOME/.config/cursor"
    CONFIG_FILE="$CONFIG_DIR/mcp.json"
else
    echo "This script is for macOS and Linux. For Windows, use the PowerShell script."
    exit 1
fi

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Configuration JSON
CONFIG='{
  "mcpServers": {
    "codearchitect": {
      "command": "codearchitect-mcp",
      "cwd": "${workspaceFolder}",
      "env": {
        "CODEARCHITECT_SESSIONS_DIR": "${workspaceFolder}/.codearchitect/sessions"
      }
    }
  }
}'

# Check if config file exists
if [ -f "$CONFIG_FILE" ]; then
    echo "Found existing mcp.json file. Merging configuration..."
    
    # Use jq if available, otherwise append manually
    if command -v jq &> /dev/null; then
        # Merge using jq
        jq '.mcpServers.codearchitect = {
            "command": "codearchitect-mcp",
            "cwd": "${workspaceFolder}",
            "env": {
                "CODEARCHITECT_SESSIONS_DIR": "${workspaceFolder}/.codearchitect/sessions"
            }
        }' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        echo "✅ Configuration merged successfully!"
    else
        echo "⚠️  jq not found. Please manually merge the configuration."
        echo "Add this to your existing mcpServers object:"
        echo "$CONFIG"
        exit 1
    fi
else
    echo "Creating new mcp.json file..."
    echo "$CONFIG" > "$CONFIG_FILE"
    echo "✅ Configuration file created successfully!"
fi

echo ""
echo "Next steps:"
echo "1. Open Cursor"
echo "2. Go to Settings → MCP & Tools"
echo "3. Find 'codearchitect' server and toggle it ON"
echo "4. Verify you see 'store_session' in available tools"
echo ""
echo "Configuration file location: $CONFIG_FILE"

