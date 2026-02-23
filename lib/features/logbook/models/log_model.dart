class LogModel {
  final String title;
  final String description;
  final DateTime timestamp;

  // Constructor
  LogModel({
    required this.title,
    required this.description,
    required this.timestamp,
  });

  // Mengubah objek LogModel → Map (format JSON-friendly)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      // DateTime disimpan sebagai string (format standar)
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Mengubah Map → objek LogModel
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      title: map['title'] as String,
      description: map['description'] as String,
      // DateTime di-parse kembali dari String
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}