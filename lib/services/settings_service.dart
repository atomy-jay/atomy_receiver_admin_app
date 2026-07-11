import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _baseUrlKey = 'base_url';
  static const _staffPinKey = 'staff_pin';
  static const _staffNameKey = 'staff_name';
  static const _eventCodeKey = 'event_code';

  String baseUrl = '';
  String staffPin = '';
  String staffName = '';
  String eventCode = '';

  bool get isConfigured =>
      baseUrl.isNotEmpty && staffPin.isNotEmpty && staffName.isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString(_baseUrlKey) ?? '';
    staffPin = prefs.getString(_staffPinKey) ?? '';
    staffName = prefs.getString(_staffNameKey) ?? '';
    eventCode = prefs.getString(_eventCodeKey) ?? '';
  }

  Future<void> save({
    required String baseUrlValue,
    required String staffPinValue,
    required String staffNameValue,
    required String eventCodeValue,
  }) async {
    baseUrl = baseUrlValue.trim().replaceAll(RegExp(r'/$'), '');
    staffPin = staffPinValue.trim();
    staffName = staffNameValue.trim();
    eventCode = eventCodeValue.trim().toUpperCase();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, baseUrl);
    await prefs.setString(_staffPinKey, staffPin);
    await prefs.setString(_staffNameKey, staffName);
    await prefs.setString(_eventCodeKey, eventCode);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_baseUrlKey);
    await prefs.remove(_staffPinKey);
    await prefs.remove(_staffNameKey);
    await prefs.remove(_eventCodeKey);
    baseUrl = '';
    staffPin = '';
    staffName = '';
    eventCode = '';
  }
}
