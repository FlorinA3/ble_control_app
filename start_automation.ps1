# start_automation.ps1 - AUTOMATION ORCHESTRATOR
# Save to: C:\Users\Alexx\Desktop\Munca\ble_control_app\start_automation.ps1

# Start resource guardian in background job
Start-Job -ScriptBlock { 
    Set-Location "C:\Users\Alexx\Desktop\Munca\ble_control_app"
    .\resource_guardian.ps1 
} -Name ResourceGuardian | Out-Null

# Start main automation script in new window (Windows PowerShell 5.1 compatible)
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File auto_dev.ps1" -WindowStyle Minimized

# Diagnostic info
Write-Host "🤖 AUTOMATION ACTIVE! (PowerShell $($PSVersionTable.PSVersion))" -ForegroundColor Green
Write-Host "Resource Guardian running as job ID: $(Get-Job -Name ResourceGuardian | Select-Object -ExpandProperty Id)" -ForegroundColor Cyan
Write-Host "Monitor with:"
Write-Host "1. Jobs:     Receive-Job -Name ResourceGuardian -Keep" -ForegroundColor DarkGray
Write-Host "2. Process:  Get-Process powershell | Where Path -like '*auto_dev*'" -ForegroundColor DarkGray
Write-Host "3. VS Code:  code ." -ForegroundColor DarkGray

# Optional: Auto-open project in VS Code
$vscodePath = "code"
if (Get-Command $vscodePath -ErrorAction SilentlyContinue) {
    Start-Process $vscodePath -ArgumentList "."
} else {
    Write-Host "VS Code not detected - open project manually" -ForegroundColor Yellow
}