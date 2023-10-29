import 'dart:convert';

List<Note> noteFromJson(String str) =>
    List<Note>.from(json.decode(str).map((x) => Note.fromJson(x)));

const String tableName = 'notes';
const String column_id = 'id';
const String column_name1 = 'title';
const String column_name2 = 'note';

class Note {
  int? id;
  String? title;
  String? note;
  int? uploaded;
  int? views;
  String? updatedAt;
  String? createdAt;

  Note({
    required this.id,
    required this.title,
    required this.note,
    required this.uploaded,
    required this.views,
    this.updatedAt,
    this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      note: json['note'],
      uploaded: json['uploaded'],
      views: json['views'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'views': views,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Dog(id: $id, title: $title, note: $note)';
  }
}
