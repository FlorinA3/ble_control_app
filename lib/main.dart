import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart'; // Generated localization class

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Request location permission for BLE scanning
  await Permission.location.request();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsProvider>(
      create: (_) => SettingsProvider(),
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'BLE Control App',
            locale: settings.locale,
            supportedLocales: [
              const Locale('en'),
              const Locale('es'),
              const Locale('fr'),
              const Locale('de'),
              const Locale('zh'),
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: HomePage(),
          );
        },
      ),
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;
  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    DevicesPage(),
    LogsPage(),
    SettingsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.bluetooth),
              label: AppLocalizations.of(context)!.devices),
          BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: AppLocalizations.of(context)!.logs),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: AppLocalizations.of(context)!.settings),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

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
    } catch (e) {
      // Already connected or error
    }
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
          id, duration, deviceIntensity[id]!, 'completed'
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
      id, deviceDuration[id]!, deviceIntensity[id]!, 'stopped'
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
                                label: '${(deviceIntensity[id]! * 100).toInt()}%',
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('${AppLocalizations.of(context)!.time}:'),
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
                            '${AppLocalizations.of(context)!.remaining}: ${deviceRemaining[id]} ${AppLocalizations.of(context)!.secs}'
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

class LogsPage extends StatefulWidget {
  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List<Map<String, dynamic>> logs = [];
  @override
  void initState() {
    super.initState();
    fetchLogs();
  }
  void fetchLogs() async {
    final data = await DatabaseHelper.instance.getLogs();
    setState(() {
      logs = data;
    });
  }
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        var log = logs[index];
        DateTime start = DateTime.fromMillisecondsSinceEpoch(log['startTime']);
        DateTime end = DateTime.fromMillisecondsSinceEpoch(log['endTime']);
        return ListTile(
          title: Text('${log['deviceId']} - ${log['status']}'),
          subtitle: Text(
            '${DateFormat.yMd().add_jm().format(start)} - '
            '${DateFormat.yMd().add_jm().format(end)}, '
            '${AppLocalizations.of(context)!.intensity}: ${log['intensity']}'
          ),
        );
      },
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _selectedDeviceId;
  DateTime? _selectedDateTime;
  double _scheduleIntensity = 0.5;
  int _scheduleDuration = 60;
  List<Map<String, dynamic>> schedules = [];

  @override
  void initState() {
    super.initState();
    loadSchedules();
  }

  void loadSchedules() async {
    final data = await DatabaseHelper.instance.getSchedules();
    setState(() {
      schedules = data;
    });
  }

  void _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year, date.month, date.day, time.hour, time.minute
          );
        });
      }
    }
  }

  void _addSchedule() {
    if (_selectedDeviceId != null && _selectedDateTime != null) {
      DatabaseHelper.instance.insertSchedule(
        _selectedDeviceId!,
        _selectedDateTime!.millisecondsSinceEpoch,
        _scheduleDuration,
        _scheduleIntensity
      );
      setState(() {
        _selectedDeviceId = null;
        _selectedDateTime = null;
        _scheduleDuration = 60;
        _scheduleIntensity = 0.5;
      });
      loadSchedules();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Text(AppLocalizations.of(context)!.language),
        DropdownButton<Locale>(
          value: settings.locale ?? Localizations.localeOf(context),
          onChanged: (Locale? locale) {
            if (locale != null) {
              settings.setLocale(locale);
            }
          },
          items: [
            DropdownMenuItem(child: Text('English'), value: Locale('en')),
            DropdownMenuItem(child: Text('Español'), value: Locale('es')),
            DropdownMenuItem(child: Text('Français'), value: Locale('fr')),
            DropdownMenuItem(child: Text('Deutsch'), value: Locale('de')),
            DropdownMenuItem(child: Text('中文'), value: Locale('zh')),
          ],
        ),
        SizedBox(height: 20),
        Text(AppLocalizations.of(context)!.schedule),
        DropdownButton<String>(
          hint: Text(AppLocalizations.of(context)!.deviceId),
          value: _selectedDeviceId,
          onChanged: (value) {
            setState(() {
              _selectedDeviceId = value;
            });
          },
          items: [
            DropdownMenuItem(child: Text('Device 1'), value: 'Device 1'),
            DropdownMenuItem(child: Text('Device 2'), value: 'Device 2'),
          ],
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _pickDateTime,
          child: Text(
            _selectedDateTime == null
              ? AppLocalizations.of(context)!.pickDateTime
              : DateFormat.yMd().add_jm().format(_selectedDateTime!)
          ),
        ),
        Row(
          children: [
            Text(AppLocalizations.of(context)!.intensity),
            Expanded(
              child: Slider(
                value: _scheduleIntensity,
                onChanged: (value) {
                  setState(() {
                    _scheduleIntensity = value;
                  });
                },
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: '${(_scheduleIntensity * 100).toInt()}%',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text('${AppLocalizations.of(context)!.time}:'),
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
                    _scheduleDuration = int.tryParse(value) ?? 60;
                  });
                },
              ),
            ),
            Text(AppLocalizations.of(context)!.secs),
          ],
        ),
        ElevatedButton(
          onPressed: _addSchedule,
          child: Text(AppLocalizations.of(context)!.addSchedule),
        ),
        Divider(),
        Text(AppLocalizations.of(context)!.scheduledJobs),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            var sched = schedules[index];
            DateTime time = DateTime.fromMillisecondsSinceEpoch(sched['scheduleTime']);
            return ListTile(
              title: Text('${sched['deviceId']}'),
              subtitle: Text(
                '${DateFormat.yMd().add_jm().format(time)}, '
                '${AppLocalizations.of(context)!.intensity}: ${sched['intensity']}, '
                '${AppLocalizations.of(context)!.duration}: ${sched['duration']} ${AppLocalizations.of(context)!.secs}',
              ),
            );
          },
        ),
      ],
    );
  }
}

class DatabaseHelper {
  static final _databaseName = "app.db";
  static final _databaseVersion = 1;
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }
  Future _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE logs ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'deviceId TEXT NOT NULL, '
      'startTime INTEGER, '
      'endTime INTEGER, '
      'intensity REAL, '
      'status TEXT'
      ')'
    );
    await db.execute(
      'CREATE TABLE schedule ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'deviceId TEXT NOT NULL, '
      'scheduleTime INTEGER, '
      'intensity REAL, '
      'duration INTEGER'
      ')'
    );
  }

  Future<void> insertLog(String deviceId, int duration, double intensity, String status) async {
    Database db = await database;
    int endTime = DateTime.now().millisecondsSinceEpoch;
    int startTime = status == 'completed'
        ? endTime - (duration * 1000)
        : endTime;
    await db.insert('logs', {
      'deviceId': deviceId,
      'startTime': startTime,
      'endTime': endTime,
      'intensity': intensity,
      'status': status
    });
  }

  Future<List<Map<String, dynamic>>> getLogs() async {
    Database db = await database;
    return await db.query('logs', orderBy: 'id DESC');
  }

  Future<void> insertSchedule(String deviceId, int scheduleTime, int duration, double intensity) async {
    Database db = await database;
    await db.insert('schedule', {
      'deviceId': deviceId,
      'scheduleTime': scheduleTime,
      'duration': duration,
      'intensity': intensity,
    });
  }

  Future<List<Map<String, dynamic>>> getSchedules() async {
    Database db = await database;
    return await db.query('schedule', orderBy: 'id DESC');
  }
}
