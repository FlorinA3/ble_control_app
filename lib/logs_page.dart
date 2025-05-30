import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

class LogsPage extends StatefulWidget {
  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List<Map<String, dynamic>> logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    var data = await DatabaseHelper.instance.getLogs();
    setState(() {
      logs = data;
    });
  }

  String _formatTimestamp(int? ms) {
    if (ms == null) return '';
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Session Logs'),
      ),
      body: logs.isEmpty
          ? Center(child: Text('No logs found.'))
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                var log = logs[index];
                return ListTile(
                  title: Text('Device: ${log['deviceId']}'),
                  subtitle: Text(
                      'Start: ${_formatTimestamp(log['startTime'])}\nEnd: ${_formatTimestamp(log['endTime'])}\nIntensity: ${(log['intensity'] * 100).toStringAsFixed(0)}%\nStatus: ${log['status']}'),
                );
              },
            ),
    );
  }
}
