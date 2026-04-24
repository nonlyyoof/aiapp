class Message {
  final String role; // 'user' or 'assistant'
  final String content;
  final String? imagePath;
  final DateTime timestamp;

  Message({
    required this.role,
    required this.content,
    this.imagePath,
    required this.timestamp,
  });
}