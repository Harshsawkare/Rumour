/// Base URLs and API-related constants (no secrets).
abstract final class ApiConstants {
  /// Example base for future HTTP APIs. Trailing slash omitted.
  static const String httpBaseUrl = 'https://jsonplaceholder.typicode.com';

  /// Random profile (name + avatar) for anonymous chat identity.
  static const String randomUserApiUrl = 'https://randomuser.me/api/';
}
