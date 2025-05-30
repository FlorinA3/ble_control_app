import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:your_app_name/db_helper.dart';  // Adjust to your actual db helper path
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DevicesPage extends StatefulWidget {
  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];
  Map<String, bool> deviceConnections = {};
  Map<String, bool> deviceRunning = {};
  Map<String, Timer?> deviceTimers = {};
  Map<String, int> deviceRemaining = {};
  Map<String, double> deviceIntensity = {};
  Map<String, int> deviceDuration = {};

  @override
  void dispose() {
    deviceTimers.forEach((id, timer) => timer?.cancel());
    super.dispose();
  }

  void startScan() {
    devices.clear();
    flutterBlue.startScan(timeout: Duration(seconds: 5));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        var id = r.device.id.id;
        if (!devices.contains(r.device) && devices.length < 9) {
          setState(() {
            devices.add(r.device);
            deviceConnections[id] = false;
            deviceRunning[id] = false;
            deviceTimers[id]?.cancel();
            deviceIntensity[id] = 0.5;
            deviceDuration[id] = 60;
          });
        }
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        deviceConnections[device.id.id] = true;
      });
    } catch (e) {}
  }

  void disconnectFromDevice(BluetoothDevice device) {
    device.disconnect();
    setState(() {
      deviceConnections[device.id.id] = false;
    });
  }

  void startSession(String id) {
    setState(() {
      deviceRunning[id] = true;
    });
    int duration = deviceDuration[id]!;
    deviceRemaining[id] = duration;

    deviceTimers[id] = Timer.periodic(Duration(seconds: 1), (timer) {
      if (deviceRemaining[id]! > 0) {
        setState(() {
          deviceRemaining[id] = deviceRemaining[id]! - 1;
        });
      } else {
        timer.cancel();
        setState(() {
          deviceRunning[id] = false;
        });
        DatabaseHelper.instance.insertLog(
          id,
          duration,
          deviceIntensity[id]!,
          'completed'
        );
      }
    });
  }

  void stopSession(String id) {
    deviceTimers[id]?.cancel();
    setState(() {
      deviceRunning[id] = false;
    });
    DatabaseHelper.instance.insertLog(
      id,
      deviceDuration[id]!,
      deviceIntensity[id]!,
      'stopped'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: startScan,
          child: Text(AppLocalizations.of(context)!.scanDevices),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              var device = devices[index];
              String id = device.id.id;
              bool connected = deviceConnections[id] ?? false;
              bool running = deviceRunning[id] ?? false;
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name.isNotEmpty ? device.name : id,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      connected
                        ? ElevatedButton(
                            onPressed: () => disconnectFromDevice(device),
                            child: Text(AppLocalizations.of(context)!.disconnect),
                          )
                        : ElevatedButton(
                            onPressed: () => connectToDevice(device),
                            child: Text(AppLocalizations.of(context)!.connect),
                          ),
                      if (connected) ...[
                        Row(
                          children: [
                            Text(AppLocalizations.of(context)!.intensity),
                            Expanded(
                              child: Slider(
                                value: deviceIntensity[id]!,
                                onChanged: (value) {
                                  setState(() {
                                    deviceIntensity[id] = value;
                                  });
                                },
                                min: 0.0,
                                max: 1.0,
                                divisions: 10,
                                label: '\%',
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('\:'),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 60,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.seconds,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    deviceDuration[id] = int.tryParse(value) ?? 60;
                                  });
                                },
                              ),
                            ),
                            Text(AppLocalizations.of(context)!.secs),
                          ],
                        ),
                        running
                          ? ElevatedButton(
                              onPressed: () => stopSession(id),
                              child: Text(AppLocalizations.of(context)!.stop),
                            )
                          : ElevatedButton(
                              onPressed: () => startSession(id),
                              child: Text(AppLocalizations.of(context)!.start),
                            ),
                        if (running)
                          Text(
                            '\: \ \'
                          ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
