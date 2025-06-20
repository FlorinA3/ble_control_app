# auto_dev.ps1 - AUTONOMOUS BLE APP DEVELOPER
# Save to: C:\Users\Alexx\Desktop\Munca\ble_control_app\auto_dev.ps1
# Usage: Run via start_automation.ps1

# Set project root
$PROJECT_ROOT = "C:\Users\Alexx\Desktop\Munca\ble_control_app"
Set-Location $PROJECT_ROOT

# Enhanced version logging
Write-Host "`n🔥 BLE AUTOMATION ENGINE v2.3 (PS $($PSVersionTable.PSVersion))" -BackgroundColor DarkBlue -ForegroundColor White
Write-Host "Start time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor Cyan

# Task queue with validation checks
$TASK_QUEUE = @(
    @{ 
        Name = "ble_core"
        Priority = 9
        Path = "src\services\bleCore.js"
        Validation = { Test-Path $_ -and (Get-Content $_ -Raw).Contains("BleManager") }
    },
    @{ 
        Name = "device_scanner"
        Priority = 8
        Path = "src\components\DeviceScanner.js"
        Validation = { Test-Path $_ -and (Get-Content $_ -Raw).Contains("scanDevices") }
    },
    @{ 
        Name = "control_interface"
        Priority = 7
        Path = "src\screens\ControlScreen.js"
        Validation = { Test-Path $_ -and (Get-Content $_ -Raw).Contains("handleCommand") }
    },
    @{ 
        Name = "electron_bridge"
        Priority = 6
        Path = "electron\main.js"
        Validation = { Test-Path $_ -and (Get-Content $_ -Raw).Contains("app.whenReady") }
    }
)

# Initialize Git if needed
if (-not (Test-Path .\.git)) {
    Write-Host "Initializing Git repository..." -ForegroundColor Magenta
    git init *>$null
    git add . *>$null
    git commit -m "Initial commit before automation" *>$null
    Write-Host "✓ Git repository initialized" -ForegroundColor Green
}

# Check Ollama availability
try {
    $ollamaTest = ollama --version
    Write-Host "✓ Ollama detected: $($ollamaTest[0])" -ForegroundColor Green
} catch {
    Write-Host "! CRITICAL: Ollama not installed or in PATH" -ForegroundColor Red
    Write-Host "Download from: https://ollama.com/download" -ForegroundColor Yellow
    exit 1
}

foreach ($task in $TASK_QUEUE | Sort-Object Priority -Descending) {
    $filePath = Join-Path $PROJECT_ROOT $task.Path
    
    # Skip task if validation passes
    if (& $task.Validation $filePath) {
        Write-Host "[✓] $($task.Name) already exists - skipping" -ForegroundColor DarkGreen
        continue
    }
    
    # Create directory if needed
    $dirPath = Split-Path $filePath -Parent
    if (-not (Test-Path $dirPath)) { 
        New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
        Write-Host "Created directory: $dirPath" -ForegroundColor DarkCyan
    }
    
    # Generate context-aware prompt
    $context = if (Test-Path $filePath) { 
        "Existing file content:`n" + (Get-Content $filePath -Raw -ErrorAction SilentlyContinue) 
    } else { 
        "No existing file - create new" 
    }
    
    $prompt = @"
CONTEXT: Building BLE control app at $PROJECT_ROOT. Current state: $context
TASK: Generate production-ready $($task.Name) module for React Native
REQUIREMENTS:
- Use react-native-ble-plx@3.1.1
- Support Android 13+ and iOS 17+
- Include proper error handling
- Must work on physical devices
- Optimize for battery life
- Export all required components/functions
- Add JSDoc comments for important functions
- Use async/await instead of promises
- Include connection retry logic with exponential backoff
"@

    # CPU-based model selection
    try {
        $cpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction Stop).CounterSamples.CookedValue
        if ($cpuLoad -gt 70) {
            $model = "deepseek-coder:3b"
            Write-Host "CPU overload ($([math]::Round($cpuLoad))% - downgrading to 3B model" -ForegroundColor Yellow
        } else {
            $model = "deepseek-coder"
        }
    } catch {
        $model = "deepseek-coder:3b"
        Write-Host "! CPU check failed - using 3B model" -ForegroundColor Yellow
    }

    # Backup existing file
    if (Test-Path $filePath) {
        $backupName = "$filePath.bak_$(Get-Date -Format 'yyyyMMdd_HHmm')"
        Copy-Item $filePath $backupName -Force
        Write-Host "[!] Backed up existing file to $(Split-Path $backupName -Leaf)" -ForegroundColor Magenta
    }

    # Generate code with Ollama
    Write-Host "`n🚀 Generating $($task.Name) module using $model..." -ForegroundColor Cyan
    $tempFile = "$filePath.tmp"
    $ollamaProcess = Start-Process -FilePath "ollama" -ArgumentList "run $model '$prompt'" `
        -NoNewWindow -PassThru -RedirectStandardOutput $tempFile
    
    # Wait for completion with timeout
    $timeout = 300 # 5 minutes
    $startTime = Get-Date
    while (-not $ollamaProcess.HasExited) {
        if (((Get-Date) - $startTime).TotalSeconds -gt $timeout) {
            Write-Host "! Timeout exceeded - terminating Ollama" -ForegroundColor Red
            Stop-Process -Id $ollamaProcess.Id -Force
            break
        }
        Start-Sleep -Seconds 5
    }

    # Validate and replace
    if ((Test-Path $tempFile) -and ((Get-Item $tempFile).Length -gt 500)) {
        Move-Item $tempFile $filePath -Force
        Write-Host "[✓] Generated $($task.Path) ($([math]::Round((Get-Item $filePath).Length/1KB, 2)) KB)" -ForegroundColor Green
        
        # Lightweight test (only if system not busy)
        if ($cpuLoad -lt 70 -and $cpuLoad -ne $null) {
            Write-Host "Running quick tests..." -ForegroundColor Cyan
            npm test -- --watchAll=false --passWithNoTests --silent *> "$PROJECT_ROOT\test.log"
            if ($LASTEXITCODE -ne 0) {
                Write-Host "! Tests failed - reverting changes" -ForegroundColor Red
                git checkout -- $filePath
                Write-Host "  Reverted to previous version" -ForegroundColor DarkYellow
            } else {
                Write-Host "  Tests passed!" -ForegroundColor Green
            }
        }
        
        # Commit changes
        git add $filePath *>$null
        git commit -m "Auto-build: $($task.Name)" -q
        Write-Host "  Committed changes to Git" -ForegroundColor DarkCyan
    }
    else {
        Write-Host "! Code generation failed for $($task.Name)" -ForegroundColor Red
        if (Test-Path $backupName) { 
            Move-Item $backupName $filePath -Force
            Write-Host "  Restored from backup" -ForegroundColor DarkGray
        }
    }
}

# Final notification
Write-Host "`n🔥 AUTOMATION CYCLE COMPLETE! 🔥" -BackgroundColor DarkGreen -ForegroundColor White
Write-Host "Completion time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "`nNext steps:"
Write-Host "1. Review changes in VS Code: 'code .'" -ForegroundColor DarkGray
Write-Host "2. Test on physical devices: 'npx react-native run-android'" -ForegroundColor DarkGray
Write-Host "3. Run full test suite: 'npm test'" -ForegroundColor DarkGray

# Play completion sound
[System.Media.SystemSounds]::Exclamation.Play()

# Auto-open VS Code if available
if (Get-Command code -ErrorAction SilentlyContinue) {
    Start-Process code -ArgumentList "." -WindowStyle Minimized
}