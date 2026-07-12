import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/section_card.dart';
import 'qr_scanner_screen.dart';

class RentalScreen extends StatefulWidget {
  const RentalScreen({super.key, required this.api});
  final ApiService api;

  @override
  State<RentalScreen> createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen> {
  final _query = TextEditingController();
  final _receiver = TextEditingController();
  Map<String, dynamic>? _registration;
  Map<String, dynamic>? _activeRental;
  bool _busy = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _query.dispose();
    _receiver.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final value = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (value == null) return;
    _query.text = value;
    await _lookup();
  }

  Future<void> _lookup() async {
    final value = _query.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final result = await widget.api.lookupMember(value);
      setState(() {
        _registration = result['registration'] as Map<String, dynamic>?;
        _activeRental = result['active_rental'] as Map<String, dynamic>?;
        // Pre-fill the next available receiver so the number is visible.
        if (_activeRental == null) {
          _receiver.text = (result['next_receiver_no'] ?? '').toString();
        }
      });
    } catch (error) {
      _show(error.toString(), true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rent() async {
    // Empty receiver number = auto-assign the lowest available receiver.
    if (_registration == null) return;
    setState(() => _busy = true);
    try {
      final result = await widget.api.rent(
        registrationId: _registration!['id'].toString(),
        receiverNo: _receiver.text.trim(),
      );
      final assigned =
          (result['rental']?['receiver_no'] ?? _receiver.text.trim()).toString();
      _show('Receiver $assigned rented successfully.', false);
      setState(() {
        _registration = null;
        _activeRental = null;
        _query.clear();
        _receiver.clear();
      });
    } catch (error) {
      _show(error.toString(), true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _show(String message, bool error) {
    if (!mounted) return;
    setState(() {
      _message = message;
      _isError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Receiver Rental', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Scan a member QR code or enter a member number.', style: TextStyle(color: mutedText)),
        const SizedBox(height: 18),
        SectionCard(
          child: Column(
            children: [
              TextField(
                controller: _query,
                onSubmitted: (_) => _lookup(),
                decoration: const InputDecoration(
                  labelText: 'Member QR or member number',
                  prefixIcon: Icon(Icons.person_search_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _scan,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan QR'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _lookup,
                      icon: const Icon(Icons.search),
                      label: const Text('Find Member'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_message != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (_isError ? dangerRed : successGreen).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _isError ? dangerRed : successGreen),
            ),
            child: Text(_message!),
          ),
        ],
        if (_registration != null) ...[
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _registration!['full_name']?.toString() ?? 'Member',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                _info('Member number', _registration!['member_no']),
                _info('Language', _registration!['language']),
                if (_activeRental != null) ...[
                  const SizedBox(height: 10),
                  const Text('This member already has an active receiver.', style: TextStyle(color: warningOrange, fontWeight: FontWeight.w700)),
                ] else ...[
                  const SizedBox(height: 18),
                  TextField(
                    controller: _receiver,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Receiver number (blank = auto-assign)',
                      hintText: 'Auto-assign next available',
                      prefixIcon: Icon(Icons.headphones_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _busy ? null : _rent,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Complete Rental'),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (_busy) ...[
          const SizedBox(height: 20),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  Widget _info(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: mutedText))),
          Expanded(child: Text(value?.toString() ?? '-')),
        ],
      ),
    );
  }
}
