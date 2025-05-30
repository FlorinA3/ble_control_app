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
      appBar: AppBar(title: Text('Device \')),
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
