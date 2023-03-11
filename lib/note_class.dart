import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

List<Note> noteFromJson(String str) =>
    List<Note>.from(json.decode(str).map((x) => Note.fromJson(x)));

const String tableName = 'notes';
const String column_id = 'id';
const String column_name1 = 'title';
const String column_name2 = 'note';

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
    };
  }

  @override
  String toString() {
    return 'Dog(id: $id, title: $title, note: $note)';
  }
}

class NoteHelper {
  Database? _db;

  NoteHelper() {
    initDatabase();
  }

  Future<void> initDatabase() async {
    _db = await openDatabase(join(await getDatabasesPath(), 'my_notes.db'),
        onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE $tableName($column_id INTEGER PRIMARY KEY AUTOINCREMENT, $column_name1 TEXT, $column_name2 TEXT)");
    }, version: 1);
  }

  Future<void> insertTask(Note note) async {
    try {
      _db!.insert(tableName, note.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {
      print('error occurred');
    }
  }

  Future<List<Note>> getNotes() async {
    final List<Map<String, dynamic>> notes = await _db!.query(tableName);
    return List.generate(
        notes.length,
        (index) => Note(
            id: notes[index][column_id],
            title: notes[index][column_name1],
            note: notes[index][column_name2]));
  }
}
