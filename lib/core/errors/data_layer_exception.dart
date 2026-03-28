/// Thrown when Firestore or another data source fails after [try/catch] in the service layer.
final class DataLayerException implements Exception {
  const DataLayerException(this.message, [this.cause, this.stackTrace]);

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() =>
      'DataLayerException: $message${cause != null ? ' ($cause)' : ''}';
}
