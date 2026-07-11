import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/settings_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = SettingsService();
  await settings.load();
  runApp(ReceiverAdminApp(settings: settings));
}

class ReceiverAdminApp extends StatelessWidget {
  const ReceiverAdminApp({super.key, required this.settings});

  final SettingsService settings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receiver Admin',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: settings.isConfigured
          ? MainShell(settings: settings)
          : LoginScreen(settings: settings),
    );
  }
}
