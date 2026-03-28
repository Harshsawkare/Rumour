/// A single line in the room chat thread.
///
/// [sentAt] is used for date separators in the message list (normalized to a calendar day in the UI).
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.sentAt,
  });

  final String text;
  final bool isMe;
  final DateTime sentAt;
}
