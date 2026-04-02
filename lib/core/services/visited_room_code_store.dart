import 'package:shared_preferences/shared_preferences.dart';

import 'package:room_chat/features/room/domain/validators/join_room_code_validator.dart';

/// Persists `roomCode → roomId` so offline re-join can use [getRoomById] (cached doc read)
/// instead of [getRoomByCode] (collection query), which often has no offline index/cache hit.
final class VisitedRoomCodeStore {
  VisitedRoomCodeStore._();

  static final VisitedRoomCodeStore instance = VisitedRoomCodeStore._();

  static const _kPrefix = 'visited_room_id_';

  Future<String?> getRoomIdForCode(String rawCode) async {
    final normalized = JoinRoomCodeValidator.normalize(rawCode);
    if (!JoinRoomCodeValidator.isValid(normalized)) {
      return null;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_kPrefix$normalized');
  }

  Future<void> remember(String rawCode, String roomId) async {
    final normalized = JoinRoomCodeValidator.normalize(rawCode);
    if (!JoinRoomCodeValidator.isValid(normalized) || roomId.trim().isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_kPrefix$normalized', roomId.trim());
  }

  Future<void> clearForCode(String rawCode) async {
    final normalized = JoinRoomCodeValidator.normalize(rawCode);
    if (!JoinRoomCodeValidator.isValid(normalized)) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_kPrefix$normalized');
  }
}
