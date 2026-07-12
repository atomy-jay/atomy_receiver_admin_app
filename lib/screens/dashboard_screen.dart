import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/status_tile.dart';
import '../widgets/section_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.api});
  final ApiService api;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted) setState(() => _loading = true);
    try {
      final data = await widget.api.dashboard();
      if (!mounted) return;
      setState(() {
        _data = data;
        _error = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _summary(String key) => ((_data?['summary']?[key] ?? 0) as num).toInt();

  @override
  Widget build(BuildContext context) {
    final languages = (_data?['languages'] as List<dynamic>? ?? []);
    final recent = (_data?['recent'] as List<dynamic>? ?? []);
    final receivers = (_data?['receivers'] as List<dynamic>? ?? []);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              const Expanded(child: Text('Live Dashboard', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800))),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _data?['event']?['name']?.toString() ?? 'Current event',
            style: const TextStyle(color: mutedText),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 3 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: [
              StatusTile(label: 'Total receivers', value: _summary('total_receivers'), icon: Icons.headphones),
              StatusTile(label: 'Currently rented', value: _summary('rented'), icon: Icons.person_pin_circle, accent: atomyBlue),
              StatusTile(label: 'Available', value: _summary('available'), icon: Icons.check_circle, accent: successGreen),
              StatusTile(label: 'Registered', value: _summary('registered'), icon: Icons.groups_2_outlined),
              StatusTile(label: 'Uncollected', value: _summary('uncollected'), icon: Icons.hourglass_bottom, accent: warningOrange),
              StatusTile(label: 'Issues', value: _summary('issues'), icon: Icons.warning_amber, accent: dangerRed),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!, style: const TextStyle(color: dangerRed)),
          ],
          const SizedBox(height: 18),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Receiver Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Tap a receiver to see details.', style: TextStyle(color: mutedText, fontSize: 13)),
                const SizedBox(height: 14),
                if (receivers.isEmpty)
                  const Text('No receivers yet.', style: TextStyle(color: mutedText))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: receivers.map((r) {
                      final item = r as Map<String, dynamic>;
                      final status = item['status']?.toString() ?? 'available';
                      final rental = item['active_rental'] as Map<String, dynamic>?;
                      final rented = status == 'rented';
                      final issue = status == 'damaged' || status == 'lost' || status == 'maintenance';
                      final bg = rented
                          ? Colors.white
                          : (issue ? dangerRed.withValues(alpha: 0.14) : const Color(0xFF0B1828));
                      final numColor = rented ? const Color(0xFF08111F) : Colors.white;
                      final subColor = rented ? atomyBlue : (issue ? dangerRed : mutedText);
                      return InkWell(
                        onTap: () => _showReceiverDetail(item),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 78,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: rented ? atomyBlue : (issue ? dangerRed : const Color(0xFF2A3E55)),
                              width: rented ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(item['receiver_no']?.toString() ?? '-',
                                  style: TextStyle(fontWeight: FontWeight.w800, color: numColor)),
                              const SizedBox(height: 2),
                              Text(
                                rented ? (rental?['full_name']?.toString() ?? 'rented') : status,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: subColor,
                                  fontWeight: rented ? FontWeight.w700 : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Language Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                if (languages.isEmpty)
                  const Text('No registration data yet.', style: TextStyle(color: mutedText))
                else
                  ...languages.take(8).map((row) {
                    final item = row as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(child: Text(item['language']?.toString() ?? '-')),
                          Text('${item['active'] ?? 0} active', style: const TextStyle(color: atomyBlue, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 12),
                          Text('${item['registered'] ?? 0} registered', style: const TextStyle(color: mutedText)),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                if (recent.isEmpty)
                  const Text('No activity yet.', style: TextStyle(color: mutedText))
                else
                  ...recent.take(12).map((row) {
                    final item = row as Map<String, dynamic>;
                    final reg = item['registrations'] as Map<String, dynamic>?;
                    final receiver = item['receivers'] as Map<String, dynamic>?;
                    final returned = item['returned_at'] != null;
                    final rawTime = (item['returned_at'] ?? item['rented_at'])?.toString();
                    String time = '-';
                    if (rawTime != null) {
                      final date = DateTime.tryParse(rawTime)?.toLocal();
                      if (date != null) time = DateFormat('HH:mm').format(date);
                    }
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: (returned ? successGreen : atomyBlue).withValues(alpha: 0.16),
                        child: Icon(returned ? Icons.keyboard_return : Icons.login, color: returned ? successGreen : atomyBlue),
                      ),
                      title: Text('${reg?['full_name'] ?? '-'} · #${receiver?['receiver_no'] ?? '-'}'),
                      subtitle: Text(returned ? 'Returned' : 'Rented', style: const TextStyle(color: mutedText)),
                      trailing: Text(time),
                    );
                  }),
              ],
            ),
          ),
          if (_loading) ...[
            const SizedBox(height: 18),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  void _showReceiverDetail(Map<String, dynamic> receiver) {
    final rental = receiver['active_rental'] as Map<String, dynamic>?;
    showModalBottomSheet(
      context: context,
      backgroundColor: navyCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receiver ${receiver['receiver_no'] ?? '-'}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (rental != null) ...[
              _detailRow('Name', rental['full_name']),
              _detailRow('Member no.', rental['member_no']),
              _detailRow('Language', rental['language']),
              _detailRow('Email', rental['email']),
              _detailRow('Phone', rental['phone']),
            ] else
              Text('Status: ${receiver['status'] ?? '-'} · no current renter',
                  style: const TextStyle(color: mutedText)),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: mutedText))),
          Expanded(
            child: Text(
              (value == null || value.toString().isEmpty) ? '-' : value.toString(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
