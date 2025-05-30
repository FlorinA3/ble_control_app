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
