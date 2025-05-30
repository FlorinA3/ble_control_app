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
