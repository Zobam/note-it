import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:http/http.dart' as http;

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectory implements Exception {}

class DatabaseIsNotOpen implements Exception {}

class CouldNotDeleteUser implements Exception {}

class NoteAlreadyExists implements Exception {}

class CouldNotFindNote implements Exception {}

class CouldNotUpdateNote implements Exception {}

class NoteService {
  Database? _db;
  List<DatabaseNote> _notes = [];

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNote();
    _notes = allNotes.toList();
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // make sure note exists
    await getNote(id: note.id);

    // update db
    final updateCount = await db.update(
      notesTable,
      note.toRow(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      // _notes.removeWhere((note) => note.id == updatedNote.id);
      return updatedNote;
    }
  }

  Future<List<DatabaseNote>> getAllNote() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final notes = await db.query(
      notesTable,
    );

    // final results = notes.map((n) => DatabaseNote.fromRow(n));
    final results = List.generate(
        notes.length,
        (index) => DatabaseNote(
              id: notes[index]['id'] as int,
              title: notes[index]['title'] as String,
              note: notes[index]['note'] as String,
              uploadedAt: notes[index]['uploadedAt'] == null
                  ? null
                  : DateTime.parse(notes[index]['uploadedAt'] as String),
              serverId: notes[index]['server_id'] == null
                  ? null
                  : notes[index]['server_id'] as int,
              views: notes[index]['views'] as int,
              updatedAt: notes[index]['updated_at'] == null
                  ? null
                  : DateTime.parse(notes[index]['updated_at'] as String),
              createdAt: notes[index]['created_at'] == null
                  ? null
                  : DateTime.parse(notes[index]['created_at'] as String),
            ));
    // notes.map((n) => DatabaseNote.fromRow(n));
    return results;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      notesTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      throw CouldNotFindNote();
    } else {
      debugPrint(results.first.toString());
      final note = DatabaseNote.fromRow(results.first);
      return note;
    }
  }

  Future<DatabaseNote> createNote({
    String? title,
    required String note,
    String? serverId,
    String? createdAt,
    String? updateAt,
    String? uploadedAt,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      notesTable,
      limit: 1,
      where: 'title = ?',
      whereArgs: [title?.toLowerCase()],
    );
    /* if (results.isNotEmpty) {
      throw NoteAlreadyExists();
    } */
    Map<String, dynamic> insertMap = {
      titleColumn: title?.toLowerCase(),
      noteColumn: note.toLowerCase(),
    };
    if (serverId != null) {
      insertMap[serverIdColumn] = serverId;
      insertMap[uploadedAtColumn] = uploadedAt;
      insertMap[createdAtColumn] = createdAt;
      insertMap[updatedAtColumn] = updateAt;
    }
    final noteId = await db.insert(notesTable, insertMap);
    final newNote = await getNote(id: noteId);
    _notes.add(newNote);
    return newNote;
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletion = await db.delete(notesTable);
    _notes = [];
    return numberOfDeletion;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    } else {
      _notes.removeWhere((note) => note.id == id);
    }
  }

  Future<Map<dynamic, dynamic>> checkNewNote(int lastID) async {
    var response = await http
        .get(Uri.parse('https://donzoby.com/api/checknewnotes/$lastID'));
    var returnVal = {};
    if (response.statusCode == 200) {
      var payload = json.decode(response.body);
      returnVal['note_count'] = payload['note_count'];
      returnVal['new_notes'] = payload['new_notes'];
    }
    return returnVal;
  }

  Future<List<DatabaseNote>> uploadNotes(List<DatabaseNote> localNotes) async {
    List<DatabaseNote> updatedNotes = [];
    var response = await http.post(
      Uri.parse('https://donzoby.com/api/notes'),
      headers: <String, String>{
        'Content-type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'name': 'Donzoby',
        'localNotes': jsonEncode(
          localNotes.map((e) => e.toJson()).toList(),
        ),
      }),
    );
    print(response.body.toString());
    if (response.statusCode == 200) {
      var payload = jsonDecode(response.body);
      for (int i = 0; i < payload['updated_notes'].length; i++) {
        updatedNotes.add(DatabaseNote.fromJson(payload['updated_notes'][i]));
      }
    }
    return updatedNotes;
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // todo
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      const createNotesTable =
          '''CREATE TABLE IF NOT EXISTS $notesTable($idColumn INTEGER PRIMARY KEY AUTOINCREMENT, $titleColumn TEXT, $noteColumn TEXT, $serverIdColumn INTEGER, $viewsColumn INTEGER DEFAULT 0, $uploadedAtColumn TIMESTAMP, $updatedAtColumn TIMESTAMP DEFAULT CURRENT_TIMESTAMP, $createdAtColumn TIMESTAMP DEFAULT CURRENT_TIMESTAMP)''';

      await db.execute((createNotesTable));
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      db.close();
      _db = null;
    }
  }
}

// @immutable
class DatabaseNote {
  final int id;
  String? title;
  String note;
  final int? serverId;
  final int views;
  DateTime? uploadedAt;
  DateTime? updatedAt;
  DateTime? createdAt;

  DatabaseNote(
      {required this.id,
      this.title,
      required this.note,
      this.serverId,
      required this.views,
      this.uploadedAt,
      this.updatedAt,
      this.createdAt});

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        title = map[titleColumn] as String,
        note = map[noteColumn] as String,
        serverId =
            map[serverIdColumn] == null ? null : map[serverIdColumn] as int,
        views = map[viewsColumn] as int,
        // uploadedAt = map[updatedAtColumn],
        uploadedAt = map[uploadedAtColumn] == Null
            ? DateTime.parse(map[uploadedAtColumn] as String)
            : null,
        updatedAt = DateTime.parse(map[updatedAtColumn] as String),
        createdAt = DateTime.parse(map[createdAtColumn] as String);

  factory DatabaseNote.fromJson(Map<String, dynamic> json) {
    return DatabaseNote(
      id: json['id'],
      title: json['title'],
      note: json['note'],
      serverId: json['server_id'],
      views: json['views'],
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'])
          : null,
      updatedAt: DateTime.parse(json['updated_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'note': note,
        'views': views,
        'created_at': createdAt.toString(),
        'updated_at': updatedAt.toString(),
      };

  Map<String, dynamic> toRow() => {
        'title': title,
        'note': note,
        'views': views,
        'server_id': serverId,
        'uploaded_at': uploadedAt.toString(),
        'created_at': createdAt.toString(),
        'updated_at': updatedAt.toString(),
      };

  @override
  String toString() =>
      'DatabaseNote(id: $id, title: $title, note: $note, createdAt: $createdAt, uploadedAt: $uploadedAt)';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const String notesTable = 'notes';
const String idColumn = 'id';
const String titleColumn = 'title';
const String noteColumn = 'note';
const String serverIdColumn = 'server_id';
const String viewsColumn = 'views';
const String uploadedAtColumn = 'uploaded_at';
const String updatedAtColumn = 'updated_at';
const String createdAtColumn = 'created_at';
