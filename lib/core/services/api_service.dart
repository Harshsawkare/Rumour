import 'package:http/http.dart' as http;

import 'package:room_chat/core/constants/api_constants.dart';

/// Shared HTTP client for future REST integrations (e.g. profile APIs).
final class ApiService {
  ApiService._() : _client = http.Client();

  static final ApiService instance = ApiService._();

  final http.Client _client;

  http.Client get client => _client;

  Uri resolve(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${ApiConstants.httpBaseUrl}$normalized');
  }

  void dispose() {
    _client.close();
  }
}
