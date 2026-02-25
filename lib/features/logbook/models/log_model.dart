class LogModel {
  final String title;
  final String description;
  final String date;
  final String category;

  LogModel({
    required this.title,
    required this.description,
    required this.date,
    this.category = 'Umum',
  });

  // toMap(): Objek → Map, untuk disimpan ke SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'category': category,
    };
  }

  // fromMap(): Map → Objek, untuk dibaca dari SharedPreferences
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      title: map['title'],
      description: map['description'],
      date: map['date'],
      category: map['category'] ?? 'Umum',
    );
  }
}