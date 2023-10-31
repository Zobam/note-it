import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:note_app_mobile/services/crud/notes_service.dart';

class NoteModel extends ChangeNotifier {
  final List<DatabaseNote> _notes = [];
  final NoteService _noteService = NoteService();
  bool hasNewNotesOnServer = false;
  bool hasLocalNotes = false;
  final List<DatabaseNote> _newNotesOnServer = [];
  final List<DatabaseNote> _localNotes = [];

  NoteModel() {
    getNotes();
  }

  get notes => _notes;
  get newNotesOnServer => _newNotesOnServer;
  get localNotes => _localNotes;

  getNotes() async {
    _notes.addAll(await _noteService.getAllNote());
    var localNotes = _notes.where(
      (element) => element.serverId == null,
    );
    if (localNotes.isNotEmpty) {
      _localNotes.addAll(localNotes);
      hasLocalNotes = true;
    }
    checkServerNotes();
  }

  checkServerNotes() async {
    int lastID = 0;
    if (_notes.isNotEmpty) {
      try {
        var note = _notes.lastWhere((element) => element.serverId != null);
        lastID = note.serverId!;
      } catch (e) {
        debugPrint('--------no note with server id yet------');
      }
    }
    var result = await _noteService.checkNewNote(lastID);
    if (result['note_count'] > 0) {
      hasNewNotesOnServer = true;
      for (int i = 0; i < result['new_notes'].length; i++) {
        _newNotesOnServer.add(DatabaseNote.fromJson(result['new_notes'][i]));
      }
      notifyListeners();
    }
  }

  addServerNotes() {
    if (_newNotesOnServer.isNotEmpty) {
      // _notes.addAll(_newNotesOnServer);
      for (int i = 0; i < _newNotesOnServer.length; i++) {
        var currentNote = _newNotesOnServer[i];
        _noteService.createNote(
          note: currentNote.note,
          title: currentNote.title,
          serverId: currentNote.id.toString(),
          createdAt: currentNote.createdAt as String,
          updateAt: currentNote.updatedAt.toString(),
        );
        _notes.add(_newNotesOnServer[i]);
      }
      _newNotesOnServer.clear();
      hasNewNotesOnServer = false;
      notifyListeners();
    }
  }

  uploadLocalNotes() async {
    if (_localNotes.isNotEmpty) {
      var results = await _noteService.uploadNotes(_localNotes);
      debugPrint('=====uploaded local notes=====');
      debugPrint(results.toString());
      for (int i = 0; i < results.length; i++) {
        _noteService.updateNote(note: results[i]);
      }
      _localNotes.clear();
      hasLocalNotes = false;
      notifyListeners();
    }
  }

  Future<DatabaseNote> createNewNote(existingNote, text, title) async {
    var response;
    if (existingNote != null) {
      debugPrint('updating note');
      response = await _noteService.updateNote(
        note: existingNote,
      );
    }
    debugPrint('creating new note');
    response = await _noteService.createNote(
      title: title,
      note: text,
    );
    _localNotes.clear();
    _notes.clear();
    _newNotesOnServer.clear();
    await getNotes();
    return response;
  }
}
