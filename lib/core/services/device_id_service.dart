import 'package:uuid/uuid.dart';

/// One stable id per app process (memory-only). Same device reuses the same id until restart.
final class DeviceIdService {
  DeviceIdService._();

  static final DeviceIdService instance = DeviceIdService._();

  static final Uuid _uuid = const Uuid();

  late final String deviceId = _uuid.v4();
}
