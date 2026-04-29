# PowerShell script to start Boundary connection
# Run this script before executing dbt commands

param(
    [string]$TargetId = $env:BOUNDARY_TARGET_ID,
    [int]$ListenPort = 5432,
    [string]$BoundaryAddr = $env:BOUNDARY_ADDR
)

Write-Host "Starting Boundary connection to RDS..." -ForegroundColor Cyan
Write-Host "Target ID: $TargetId" -ForegroundColor Yellow
Write-Host "Listen Port: $ListenPort" -ForegroundColor Yellow

if (-not $TargetId) {
    Write-Host "ERROR: Target ID is required. Set BOUNDARY_TARGET_ID environment variable or pass -TargetId parameter." -ForegroundColor Red
    exit 1
}

# Set Boundary address if provided
if ($BoundaryAddr) {
    $env:BOUNDARY_ADDR = $BoundaryAddr
}

# Start Boundary connection
Write-Host "`nStarting Boundary proxy on localhost:$ListenPort..." -ForegroundColor Green
Write-Host "Keep this terminal open while running dbt commands.`n" -ForegroundColor Yellow

boundary connect postgres -target-id $TargetId -listen-port $ListenPort

# Note: The above command will keep running until you close it
# Open another terminal to run dbt commands
