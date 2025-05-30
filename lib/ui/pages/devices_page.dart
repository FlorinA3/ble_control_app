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
