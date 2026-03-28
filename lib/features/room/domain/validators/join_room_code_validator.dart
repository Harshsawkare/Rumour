/// Normalizes and validates room codes for the join flow (no UI / Firestore).
abstract final class JoinRoomCodeValidator {
  static const int requiredLength = 6;

  /// Trims and uppercases — call before [isValid].
  static String normalize(String raw) => raw.trim().toUpperCase();

  /// Exactly [requiredLength] characters, [A-Z0-9] only (after [normalize]).
  static bool isValid(String normalized) {
    if (normalized.length != requiredLength) {
      return false;
    }
    return RegExp(r'^[A-Z0-9]+$').hasMatch(normalized);
  }
}
