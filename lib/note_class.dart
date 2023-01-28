import 'dart:convert';

List<Note> noteFromJson(String str) =>
    List<Note>.from(json.decode(str).map((x) => Note.fromJson(x)));

class Note {
  final int id;
  final String title;
  final String note;

  Note({required this.id, required this.title, required this.note});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      note: json['note'],
    );
  }
}
