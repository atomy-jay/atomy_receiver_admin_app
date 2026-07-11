import 'dart:convert';
import 'package:http/http.dart' as http;
import 'settings_service.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class ApiService {
  ApiService(this.settings);
  final SettingsService settings;

  Map<String, String> get _headers => {
        'content-type': 'application/json',
        'x-staff-pin': settings.staffPin,
      };

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('${settings.baseUrl}$path').replace(queryParameters: query);
  }

  Future<Map<String, dynamic>> authenticate() async {
    return _post('/api/staff-auth', const {});
  }

  Future<Map<String, dynamic>> lookupMember(String value) async {
    return _post('/api/staff-lookup', {
      'event_code': settings.eventCode,
      'query': value,
    });
  }

  Future<Map<String, dynamic>> lookupReceiver(String receiverNo) async {
    return _post('/api/staff-lookup', {
      'event_code': settings.eventCode,
      'receiver_no': receiverNo,
    });
  }

  Future<Map<String, dynamic>> rent({
    required String registrationId,
    required String receiverNo,
  }) async {
    return _post('/api/rent', {
      'event_code': settings.eventCode,
      'registration_id': registrationId,
      'receiver_no': receiverNo,
      'staff_name': settings.staffName,
    });
  }

  Future<Map<String, dynamic>> returnReceiver({
    required String receiverNo,
    required String returnStatus,
    String notes = '',
  }) async {
    return _post('/api/return', {
      'event_code': settings.eventCode,
      'receiver_no': receiverNo,
      'return_status': returnStatus,
      'staff_name': settings.staffName,
      'notes': notes,
    });
  }

  Future<Map<String, dynamic>> dashboard() async {
    final response = await http.get(
      _uri('/api/dashboard', {'event': settings.eventCode}),
      headers: _headers,
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'The server returned an invalid response.',
        statusCode: response.statusCode,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300 || json['ok'] != true) {
      throw ApiException(
        (json['error'] ?? 'Request failed').toString(),
        statusCode: response.statusCode,
      );
    }
    return json;
  }
}
