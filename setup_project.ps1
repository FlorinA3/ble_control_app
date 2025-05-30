# Save this as setup_project.ps1 and run in your project root
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 1. Create directory structure
$directories = @(
    'assets/icons',
    'assets/indicators',
    'lib/data',
    'lib/data/models',
    'lib/data/repositories',
    'lib/providers',
    'lib/services',
    'lib/utils',
    'lib/ui',
    'lib/ui/widgets',
    'lib/ui/pages'
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

# 2. Create files with initial templates
$files = @{
    # Core files
    'lib/main.dart' = @"
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/ble_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BleProvider()),
      ],
      child: const App(),
    ),
  );
}
"@

    'lib/app.dart' = @"
import 'package:flutter/material.dart';
import 'ui/pages/devices_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dry Fog Controller',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const DevicesPage(),
    );
  }
}
"@

    # Providers
    'lib/providers/ble_provider.dart' = @"
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../data/models/ble_device.dart';

class BleProvider extends ChangeNotifier {
  List<BleDevice> _devices = [];
  
  List<BleDevice> get devices => _devices;
  
  Future<void> startScan() async {
    // TODO: Implement multi-device scanning
  }
  
  Future<void> connect(BleDevice device) async {
    // TODO: Implement multi-device connection
  }
}
"@

    'lib/providers/device_provider.dart' = @"
import 'package:flutter/material.dart';
import '../data/models/device_session.dart';

class DeviceProvider extends ChangeNotifier {
  final List<DeviceSession> _sessions = [];
  
  List<DeviceSession> get sessions => _sessions;
  
  void startSession(String deviceId, int intensity, int duration) {
    // TODO: Implement session management
  }
}
"@

    # Models
    'lib/data/models/ble_device.dart' = @"
class BleDevice {
  final String id;
  final String name;
  bool isConnected;

  BleDevice({
    required this.id,
    required this.name,
    this.isConnected = false,
  });
}
"@

    'lib/data/models/device_session.dart' = @"
class DeviceSession {
  final String deviceId;
  final DateTime startTime;
  final int duration;
  final int intensity;
  bool isActive;

  DeviceSession({
    required this.deviceId,
    required this.startTime,
    required this.duration,
    required this.intensity,
    this.isActive = false,
  });
}
"@

    # UI Components
    'lib/ui/widgets/device_tile.dart' = @"
import 'package:flutter/material.dart';
import '../../data/models/ble_device.dart';

class DeviceTile extends StatelessWidget {
  final BleDevice device;
  final VoidCallback onPressed;

  const DeviceTile({
    super.key,
    required this.device,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        child: Column(
          children: [
            // Device icon and status indicator
            Stack(/*...*/),
            Text(device.name),
            Text('Intensity: Medium'), // Placeholder
          ],
        ),
      ),
    );
  }
}
"@

    'lib/ui/widgets/intensity_selector.dart' = @"
import 'package:flutter/material.dart';

class IntensitySelector extends StatelessWidget {
  final Function(int) onChanged;
  final int currentLevel;

  const IntensitySelector({
    super.key,
    required this.onChanged,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton('Low', 1),
        _buildButton('Medium', 2),
        _buildButton('High', 3),
        _buildButton('Max', 4),
      ],
    );
  }
  
  Widget _buildButton(String label, int level) {
    return ElevatedButton(
      onPressed: () => onChanged(level),
      style: ElevatedButton.styleFrom(
        backgroundColor: currentLevel == level ? Colors.blue : Colors.grey,
      ),
      child: Text(label),
    );
  }
}
"@

    # Pages
    'lib/ui/pages/devices_page.dart' = @"
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ble_provider.dart';
import '../widgets/device_tile.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bleProvider = Provider.of<BleProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dry Fog Controllers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: bleProvider.startScan,
          )
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
        ),
        itemCount: bleProvider.devices.length,
        itemBuilder: (context, index) => DeviceTile(
          device: bleProvider.devices[index],
          onPressed: () => Navigator.pushNamed(
            context, 
            '/device-control',
            arguments: bleProvider.devices[index].id,
          ),
        ),
      ),
    );
  }
}
"@

    'lib/ui/pages/device_control_page.dart' = @"
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/device_provider.dart';
import '../widgets/intensity_selector.dart';
import '../widgets/timer_control.dart';
import '../widgets/session_buttons.dart';

class DeviceControlPage extends StatelessWidget {
  final String deviceId;

  const DeviceControlPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Device \$deviceId')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            IntensitySelector(
              currentLevel: 2,
              onChanged: (level) {
                // TODO: Handle intensity change
              },
            ),
            const SizedBox(height: 20),
            TimerControl(
              onDurationChanged: (seconds) {
                // TODO: Handle duration change
              },
            ),
            const SizedBox(height: 20),
            SessionButtons(
              onStart: () {
                // TODO: Start session
              },
              onPause: () {
                // TODO: Pause session
              },
              onStop: () {
                // TODO: Stop session
              },
            ),
          ],
        ),
      ),
    );
  }
}
"@
}

foreach ($file in $files.Keys) {
    if (-not (Test-Path $file)) {
        Set-Content -Path $file -Value $files[$file]
    }
}

# 3. Add assets to pubspec.yaml
$pubspecPath = "pubspec.yaml"
if (Test-Path $pubspecPath) {
    $content = Get-Content $pubspecPath -Raw
    $newContent = $content -replace "flutter:", @"
flutter:
  assets:
    - assets/icons/
    - assets/indicators/
"@
    Set-Content -Path $pubspecPath -Value $newContent
}

Write-Host @"
✅ Project structure created successfully!
Next steps:
1. Add your device icons to assets/icons/
   - device_connected.png
   - device_disconnected.png
   - device_icon.png

2. Integrate your existing BLE logic:
   - Copy ble_service.dart to lib/services/
   - Update BleProvider in lib/providers/ble_provider.dart

3. Run the app:
   flutter pub get
   flutter run

4. Implement session logic in DeviceProvider
"@ -ForegroundColor Green