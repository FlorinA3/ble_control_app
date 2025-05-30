import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<Map<String, dynamic>> schedules = [];

  // Controllers for form inputs
  final _deviceIdController = TextEditingController();
  final _durationController = TextEditingController(text: '60');
  double _intensity = 0.5;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    var data = await DatabaseHelper.instance.getSchedules();
    setState(() {
      schedules = data;
    });
  }

  Future<void> _pickDateTime() async {
    DateTime now = DateTime.now();
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _addSchedule() async {
    if (_deviceIdController.text.isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter device ID and select schedule time')),
      );
      return;
    }
    int scheduleMs = _selectedDateTime!.millisecondsSinceEpoch;
    int duration = int.tryParse(_durationController.text) ?? 60;
    await DatabaseHelper.instance.insertSchedule(
      _deviceIdController.text,
      scheduleMs,
      duration,
      _intensity,
    );
    _deviceIdController.clear();
    _durationController.text = '60';
    _intensity = 0.5;
    _selectedDateTime = null;
    await _loadSchedules();
  }

  String _formatTimestamp(int? ms) {
    if (ms == null) return '';
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Jobs'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: _deviceIdController,
                  decoration: InputDecoration(labelText: 'Device ID'),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Schedule Time: '),
                    Text(_selectedDateTime == null
                        ? 'Not set'
                        : DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!)),
                    Spacer(),
                    ElevatedButton(
                      onPressed: _pickDateTime,
                      child: Text('Pick Date/Time'),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Duration (seconds)'),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Intensity: ${( _intensity * 100).toInt()}%'),
                    Expanded(
                      child: Slider(
                        value: _intensity,
                        onChanged: (v) => setState(() => _intensity = v),
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                      ),
                    )
                  ],
                ),
                ElevatedButton(
                  onPressed: _addSchedule,
                  child: Text('Add Schedule'),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: schedules.isEmpty
                ? Center(child: Text('No scheduled jobs'))
                : ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      var sch = schedules[index];
                      return ListTile(
                        title: Text('Device: ${sch['deviceId']}'),
                        subtitle: Text(
                            'Time: ${_formatTimestamp(sch['scheduleTime'])}\nDuration: ${sch['duration']}s\nIntensity: ${(sch['intensity'] * 100).toInt()}%'),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
