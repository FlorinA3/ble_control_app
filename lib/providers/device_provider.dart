import 'package:flutter/material.dart';
import '../data/models/device_session.dart';

class DeviceProvider extends ChangeNotifier {
  final List<DeviceSession> _sessions = [];
  
  List<DeviceSession> get sessions => _sessions;
  
  void startSession(String deviceId, int intensity, int duration) {
    // TODO: Implement session management
  }
}
