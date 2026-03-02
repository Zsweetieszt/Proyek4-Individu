import 'package:mongo_dart/mongo_dart.dart';

class LogModel {
  final ObjectId? id;
  final String title;
  final String description;
  final String category;
  final String date;
  final String username;

  LogModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id ?? ObjectId(),
      'title': title,
      'description': description,
      'category': category,
      'date': date,
      'username': username,
    };
  }

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['_id'] as ObjectId?,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Umum',
      date: map['date'] ?? '',
      username: map['username'] ?? '',
    );
  }
}