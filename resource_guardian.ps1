# resource_guardian.ps1 - SYSTEM RESOURCE MANAGER
# Save to: C:\Users\Alexx\Desktop\Munca\ble_control_app\resource_guardian.ps1

# Check PowerShell version compatibility
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "! CRITICAL: Requires PowerShell 5.1 or newer" -ForegroundColor Red
    exit 1
}

Write-Host "🛡️ RESOURCE GUARDIAN ACTIVATED (PS $($PSVersionTable.PSVersion))" -ForegroundColor Cyan

while ($true) {
    try {
        # Get system metrics with error handling
        $memCounter = Get-Counter '\Memory\Available MBytes' -ErrorAction Stop
        $cpuCounter = Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction Stop
        
        $freeMem = $memCounter.CounterSamples.CookedValue
        $cpuLoad = $cpuCounter.CounterSamples.CookedValue
        
        # Memory management (critical: <2GB)
        if ($freeMem -lt 2048) {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ALERT: Free RAM low ($([math]::Round($freeMem))MB! Throttling heavy tasks..." -ForegroundColor Red
            
            Get-Process "java", "gradle", "qemu", "node", "python" -ErrorAction SilentlyContinue | 
                Where-Object { $_.CPU -gt 30 } | 
                ForEach-Object {
                    try {
                        $_.PriorityClass = "Idle"
                        Write-Host "  • Set $($_.Name) ($($_.Id)) to Idle priority" -ForegroundColor DarkYellow
                    }
                    catch {
                        Write-Host "  ! Failed to adjust $($_.Name): $_" -ForegroundColor Gray
                    }
                }
        }
        
        # CPU management (critical: >85%)
        if ($cpuLoad -gt 85) {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ALERT: CPU overload ($([math]::Round($cpuLoad))%! Throttling background tasks..." -ForegroundColor Red
            
            Get-Process "ollama", "node", "python", "compiler" -ErrorAction SilentlyContinue | 
                Where-Object { $_.CPU -gt 40 } | 
                ForEach-Object {
                    try {
                        $_.PriorityClass = "BelowNormal"
                        Write-Host "  • Set $($_.Name) ($($_.Id)) to BelowNormal priority" -ForegroundColor Magenta
                    }
                    catch {
                        Write-Host "  ! Failed to adjust $($_.Name): $_" -ForegroundColor Gray
                    }
                }
        }
        
        # Normal state indicator
        if ($freeMem -ge 2048 -and $cpuLoad -le 85) {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] System OK | RAM: $([math]::Round($freeMem))MB | CPU: $([math]::Round($cpuLoad))%" -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ! Monitoring error: $_" -ForegroundColor Yellow
    }
    
    # Sleep with progress indicator
    for ($i = 0; $i -lt 30; $i++) {
        Write-Progress -Activity "Resource Guardian" -Status "Next check in $((30 - $i)) seconds" -PercentComplete ($i/30*100)
        Start-Sleep -Seconds 1
    }
    Write-Progress -Activity "Resource Guardian" -Completed
}