import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/settings_service.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'rental_screen.dart';
import 'return_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.settings});
  final SettingsService settings;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  late final ApiService _api;

  @override
  void initState() {
    super.initState();
    _api = ApiService(widget.settings);
  }

  Future<void> _logout() async {
    await widget.settings.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen(settings: widget.settings)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      RentalScreen(api: _api),
      ReturnScreen(api: _api),
      DashboardScreen(api: _api),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        title: Row(
          children: [
            const Icon(Icons.headphones_rounded, color: atomyBlue),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Receiver Admin', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  Text(
                    widget.settings.eventCode.isEmpty ? widget.settings.staffName : '${widget.settings.eventCode} · ${widget.settings.staffName}',
                    style: const TextStyle(fontSize: 11, color: mutedText),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'logout', child: Text('Change connection')),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: const Color(0xFF091F3B),
        indicatorColor: atomyBlue.withValues(alpha: 0.20),
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Rental'),
          NavigationDestination(icon: Icon(Icons.keyboard_return), label: 'Return'),
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
        ],
      ),
    );
  }
}
