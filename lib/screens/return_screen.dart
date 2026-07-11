import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/section_card.dart';

class ReturnScreen extends StatefulWidget {
  const ReturnScreen({super.key, required this.api});
  final ApiService api;

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  final _receiver = TextEditingController();
  final _notes = TextEditingController();
  Map<String, dynamic>? _lookup;
  String _status = 'returned';
  bool _busy = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _receiver.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _find() async {
    if (_receiver.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      final result = await widget.api.lookupReceiver(_receiver.text.trim());
      setState(() => _lookup = result);
    } catch (error) {
      _show(error.toString(), true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    if (_lookup == null) return;
    setState(() => _busy = true);
    try {
      await widget.api.returnReceiver(
        receiverNo: _receiver.text.trim(),
        returnStatus: _status,
        notes: _notes.text.trim(),
      );
      _show('Receiver ${_receiver.text.trim()} updated successfully.', false);
      setState(() {
        _lookup = null;
        _receiver.clear();
        _notes.clear();
        _status = 'returned';
      });
    } catch (error) {
      _show(error.toString(), true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _show(String text, bool error) {
    if (!mounted) return;
    setState(() {
      _message = text;
      _isError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rental = _lookup?['rental'] as Map<String, dynamic>?;
    final registration = rental?['registrations'] as Map<String, dynamic>?;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Receiver Return', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Enter the receiver number and confirm its condition.', style: TextStyle(color: mutedText)),
        const SizedBox(height: 18),
        SectionCard(
          child: Column(
            children: [
              TextField(
                controller: _receiver,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _find(),
                decoration: const InputDecoration(
                  labelText: 'Receiver number',
                  prefixIcon: Icon(Icons.headphones_outlined),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _busy ? null : _find,
                icon: const Icon(Icons.search),
                label: const Text('Find Receiver'),
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
        if (_lookup != null) ...[
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Receiver ${_lookup!['receiver']?['receiver_no'] ?? _receiver.text}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text('Current status: ${_lookup!['receiver']?['status'] ?? '-'}', style: const TextStyle(color: mutedText)),
                if (registration != null) ...[
                  const SizedBox(height: 12),
                  Text(registration['full_name']?.toString() ?? '-', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  Text('${registration['member_no'] ?? '-'} · ${registration['language'] ?? '-'}', style: const TextStyle(color: mutedText)),
                ],
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Return condition'),
                  items: const [
                    DropdownMenuItem(value: 'returned', child: Text('Normal return')),
                    DropdownMenuItem(value: 'damaged', child: Text('Damaged')),
                    DropdownMenuItem(value: 'lost', child: Text('Lost')),
                    DropdownMenuItem(value: 'maintenance', child: Text('Needs inspection')),
                  ],
                  onChanged: (value) => setState(() => _status = value ?? 'returned'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _busy ? null : _submit,
                  icon: const Icon(Icons.keyboard_return),
                  label: const Text('Complete Return'),
                ),
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
}
