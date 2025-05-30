import 'package:flutter/material.dart';
import 'ui/pages/devices_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dry Fog Controller',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const DevicesPage(),
    );
  }
}
