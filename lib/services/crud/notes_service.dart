import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

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
    required String text,
    required String title,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // make sure note exists
    await getNote(id: note.id);

    // update db
    final updateCount = await db.update(
      notesTable,
      {
        titleColumn: title,
        noteColumn: text,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
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
            note: notes[index]['note'] as String));
    // notes.map((n) => DatabaseNote.fromRow(n));
    debugPrint('from get all notes method');
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
      final note = DatabaseNote.fromRow(results.first);
      _notes.removeWhere((note) => note.id == id);
      return note;
    }
  }

  Future<DatabaseNote> createNote(
      {required String title, required String note}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      notesTable,
      limit: 1,
      where: 'title = ?',
      whereArgs: [title.toLowerCase()],
    );
    /* if (results.isNotEmpty) {
      throw NoteAlreadyExists();
    } */
    final noteId = await db.insert(notesTable, {
      titleColumn: title.toLowerCase(),
      noteColumn: note.toLowerCase(),
    });
    final newNote = DatabaseNote(
      id: noteId,
      title: title,
      note: note,
    );
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
          '''CREATE TABLE IF NOT EXISTS $notesTable($idColumn INTEGER PRIMARY KEY AUTOINCREMENT, $titleColumn TEXT, $noteColumn TEXT)''';

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

@immutable
class DatabaseNote {
  final int id;
  final String title;
  final String note;

  const DatabaseNote(
      {required this.id, required this.title, required this.note});

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        title = map[titleColumn] as String,
        note = map[noteColumn] as String;

  @override
  String toString() => 'DatabaseNote(id: $id, title: $title, note: $note)';

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
