import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:room_chat/core/constants/api_constants.dart';
import 'package:room_chat/core/errors/data_layer_exception.dart';

/// Profile from [GET https://randomuser.me/api/](https://randomuser.me/api/) + local [userId].
final class AnonymousUserProfile {
  const AnonymousUserProfile({
    required this.userId,
    required this.userName,
    required this.username,
    required this.avatarUrl,
  });

  final String userId;

  /// `name.first` + `name.last`.
  final String userName;

  /// `login.username`.
  final String username;

  final String avatarUrl;
}

/// Fetches RandomUser JSON, parses `name`, `login.username`, and `picture`; assigns a new UUID [userId].
final class UserIdentityService {
  UserIdentityService._({http.Client? httpClient, Uuid? uuid})
    : _http = httpClient ?? http.Client(),
      _uuid = uuid ?? const Uuid();

  static final UserIdentityService instance = UserIdentityService._();

  final http.Client _http;
  final Uuid _uuid;

  String generateUserId() => _uuid.v4();

  /// GET [ApiConstants.randomUserApiUrl], then builds [AnonymousUserProfile].
  Future<AnonymousUserProfile> createAnonymousProfile() async {
    final userId = generateUserId();
    try {
      final uri = Uri.parse(ApiConstants.randomUserApiUrl);
      final response = await _http.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _fallbackProfile(userId);
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return _fallbackProfile(userId);
      }
      final results = decoded['results'];
      if (results is! List<dynamic> || results.isEmpty) {
        return _fallbackProfile(userId);
      }
      final first = results.first;
      if (first is! Map<String, dynamic>) {
        return _fallbackProfile(userId);
      }
      return _profileFromRandomUserResult(first, userId);
    } catch (e, st) {
      throw DataLayerException('createAnonymousProfile failed', e, st);
    }
  }

  /// Like [createAnonymousProfile] but never throws.
  Future<AnonymousUserProfile> createAnonymousProfileOrFallback() async {
    try {
      return await createAnonymousProfile();
    } on DataLayerException {
      final userId = generateUserId();
      return _fallbackProfile(userId);
    }
  }

  AnonymousUserProfile _profileFromRandomUserResult(
    Map<String, dynamic> first,
    String userId,
  ) {
    final name = first['name'];
    var userName = 'Guest';
    if (name is Map<String, dynamic>) {
      final firstName = name['first'] as String? ?? '';
      final lastName = name['last'] as String? ?? '';
      userName = ('$firstName $lastName').trim();
      if (userName.isEmpty) {
        userName = 'Guest';
      }
    }

    var username = 'guest';
    final login = first['login'];
    if (login is Map<String, dynamic>) {
      username = login['username'] as String? ?? 'guest';
      if (username.isEmpty) {
        username = 'guest';
      }
    }

    var avatar = '';
    final picture = first['picture'];
    if (picture is Map<String, dynamic>) {
      avatar =
          picture['medium'] as String? ??
          picture['thumbnail'] as String? ??
          '';
    }

    return AnonymousUserProfile(
      userId: userId,
      userName: userName,
      username: username,
      avatarUrl: avatar,
    );
  }

  AnonymousUserProfile _fallbackProfile(String userId) {
    return AnonymousUserProfile(
      userId: userId,
      userName: 'Guest',
      username: 'guest',
      avatarUrl: '',
    );
  }

  void dispose() {
    _http.close();
  }
}
