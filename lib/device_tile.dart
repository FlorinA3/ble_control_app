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
