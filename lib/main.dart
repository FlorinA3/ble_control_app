import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'devices_page.dart';
import 'logs_page.dart';
import 'schedule_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  _HomePageState create
