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
