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
