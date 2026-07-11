import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/settings_service.dart';
import '../theme.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.settings});
  final SettingsService settings;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _url;
  late final TextEditingController _pin;
  late final TextEditingController _name;
  late final TextEditingController _event;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: widget.settings.baseUrl);
    _pin = TextEditingController(text: widget.settings.staffPin);
    _name = TextEditingController(text: widget.settings.staffName);
    _event = TextEditingController(text: widget.settings.eventCode);
  }

  @override
  void dispose() {
    _url.dispose();
    _pin.dispose();
    _name.dispose();
    _event.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (_url.text.trim().isEmpty || _pin.text.trim().isEmpty || _name.text.trim().isEmpty) {
      setState(() => _error = 'Site URL, staff name and PIN are required.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.settings.save(
        baseUrlValue: _url.text,
        staffPinValue: _pin.text,
        staffNameValue: _name.text,
        eventCodeValue: _event.text,
      );
      await ApiService(widget.settings).authenticate();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainShell(settings: widget.settings)),
      );
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.headphones_rounded, color: atomyBlue, size: 58),
                  const SizedBox(height: 18),
                  const Text(
                    'Receiver Admin',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect the staff app to your event system.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: mutedText),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _url,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Netlify site URL',
                      hintText: 'https://your-site.netlify.app',
                      prefixIcon: Icon(Icons.cloud_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _event,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Event code (optional)',
                      hintText: 'SA2026',
                      prefixIcon: Icon(Icons.event_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Staff name',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _pin,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Staff PIN',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(_error!, style: const TextStyle(color: dangerRed)),
                  ],
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    onPressed: _busy ? null : _connect,
                    icon: _busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: const Text('Connect'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
