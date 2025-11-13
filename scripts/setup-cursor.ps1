# CodeArchitect MCP - Cursor Setup Script (PowerShell)
# This script automatically adds CodeArchitect MCP configuration to Cursor

$configPath = "$env:APPDATA\Cursor\mcp.json"
$configDir = Split-Path $configPath

# Create config directory if it doesn't exist
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    Write-Host "Created config directory: $configDir" -ForegroundColor Green
}

# Configuration object
$codearchitectConfig = @{
    command = "codearchitect-mcp"
    cwd = "${workspaceFolder}"
    env = @{
        CODEARCHITECT_SESSIONS_DIR = "${workspaceFolder}/.codearchitect/sessions"
    }
}

# Check if config file exists
if (Test-Path $configPath) {
    Write-Host "Found existing mcp.json file. Merging configuration..." -ForegroundColor Yellow
    
    try {
        $existing = Get-Content $configPath -Raw | ConvertFrom-Json
        
        # Ensure mcpServers object exists
        if (-not $existing.mcpServers) {
            $existing | Add-Member -MemberType NoteProperty -Name "mcpServers" -Value @{}
        }
        
        # Add or update codearchitect configuration
        $existing.mcpServers.codearchitect = $codearchitectConfig
        
        # Save updated configuration
        $existing | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
        Write-Host "✅ Configuration merged successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  Error merging configuration: $_" -ForegroundColor Red
        Write-Host "Please manually add the configuration to: $configPath" -ForegroundColor Yellow
        exit 1
    }
}
else {
    Write-Host "Creating new mcp.json file..." -ForegroundColor Yellow
    
    $newConfig = @{
        mcpServers = @{
            codearchitect = $codearchitectConfig
        }
    }
    
    $newConfig | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
    Write-Host "✅ Configuration file created successfully!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Open Cursor"
Write-Host "2. Go to Settings → MCP & Tools"
Write-Host "3. Find 'codearchitect' server and toggle it ON"
Write-Host "4. Verify you see 'store_session' in available tools"
Write-Host ""
Write-Host "Configuration file location: $configPath" -ForegroundColor Gray

