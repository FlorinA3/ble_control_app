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
