# PowerShell script for BLE Control App UI Setup
# Save this as setup_ui.ps1 and run in your project root

# 1. Configure dark theme in main.dart
$mainDartPath = "lib\main.dart"
if (Test-Path $mainDartPath) {
    $content = Get-Content $mainDartPath -Raw
    $newContent = $content -replace "return MaterialApp\(", @"
return MaterialApp(
  theme: ThemeData.dark(),
  debugShowCheckedModeBanner: false,
"@
    Set-Content -Path $mainDartPath -Value $newContent
    Write-Host "Dark theme configured in main.dart" -ForegroundColor Green
} else {
    Write-Host "main.dart not found!" -ForegroundColor Red
}

# 2. Create asset directories
$assetPaths = @("assets\icons", "assets\indicators")
foreach ($path in $assetPaths) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "Created directory: $path" -ForegroundColor Green
    }
}

# 3. Add assets to pubspec.yaml
$pubspecPath = "pubspec.yaml"
if (Test-Path $pubspecPath) {
    $content = Get-Content $pubspecPath -Raw
    if ($content -notmatch "assets:") {
        $newContent = $content -replace "flutter:", @"
flutter:
  assets:
    - assets/icons/
    - assets/indicators/
"@
        Set-Content -Path $pubspecPath -Value $newContent
        Write-Host "Assets added to pubspec.yaml" -ForegroundColor Green
    }
} else {
    Write-Host "pubspec.yaml not found!" -ForegroundColor Red
}

# 4. Create DeviceTile widget
$deviceTilePath = "lib\device_tile.dart"
$deviceTileContent = @"
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ble_device.dart';
import 'ble_service.dart';

class DeviceTile extends StatelessWidget {
  final BleDevice device;
  final VoidCallback onPressed;

  const DeviceTile({
    Key? key,
    required this.device,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BleService>(
      builder: (context, bleService, _) {
        return Card(
          color: Colors.grey[900],
          elevation: 2,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Device icon with connection indicator
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.asset(
                        'assets/icons/device_icon.png',
                        width: 48,
                        height: 48,
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: device.isConnected ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 1.5
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Device name
                  Text(
                    device.name.isNotEmpty 
                      ? device.name 
                      : 'Unknown Device',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  // Device ID
                  Text(
                    device.id.substring(0, 8),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
"@
Set-Content -Path $deviceTilePath -Value $deviceTileContent
Write-Host "Created DeviceTile widget" -ForegroundColor Green

# 5. Update DeviceListScreen
$deviceListPath = "lib\device_list_screen.dart"
$deviceListContent = @"
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ble_device.dart';
import 'ble_service.dart';
import 'device_tile.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bleService = Provider.of<BleService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dry Fog Controllers'),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: bleService.startScan,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => bleService.startScan(),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: bleService.devices.length,
          itemBuilder: (context, index) => DeviceTile(
            device: bleService.devices[index],
            onPressed: () => bleService.connect(bleService.devices[index]),
          ),
        ),
      ),
    );
  }
}
"@
Set-Content -Path $deviceListPath -Value $deviceListContent
Write-Host "Updated DeviceListScreen" -ForegroundColor Green

# Final instructions
Write-Host @"
UI setup complete! Now:

1. Add your device icon as:
   assets\icons\device_icon.png

2. Run these commands:
   flutter pub get
   flutter run

Note: If you see 'BleService' errors, make sure you have:
- ble_service.dart with devices list
- ble_device.dart with isConnected property
"@ -ForegroundColor Cyan