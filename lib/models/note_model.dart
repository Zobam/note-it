import 'package:flutter/widgets.dart';
import 'package:note_app_mobile/services/crud/notes_service.dart';

class NoteModel extends ChangeNotifier {
  final List<DatabaseNote> _notes = [];
  final NoteService _noteService = NoteService();
  bool hasNewNotesOnServer = false;
  bool hasLocalNotes = false;
  bool checkingServerNotes = true;
  bool loadingLocalNotes = true;
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
    loadingLocalNotes = false;
    var localNotes = _notes.where(
      (element) => element.serverId == null,
    );
    if (localNotes.isNotEmpty) {
      _localNotes.addAll(localNotes);
      hasLocalNotes = true;
    }
    notifyListeners();
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
    checkingServerNotes = false;
    if (result['note_count'] > 0) {
      hasNewNotesOnServer = true;
      for (int i = 0; i < result['new_notes'].length; i++) {
        _newNotesOnServer.add(DatabaseNote.fromJson(result['new_notes'][i]));
      }
    }
    notifyListeners();
  }

  bool noteHasLocalEdit(DatabaseNote note) {
    bool returnVal = false;
    if (note.serverId != null) {
      final DateTime updatedTime = DateTime.parse(note.updatedAt.toString());
      final DateTime uploadedTime = DateTime.parse(note.uploadedAt.toString());
      returnVal = updatedTime.isAfter(uploadedTime);
    }
    return returnVal;
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
          uploadedAt: currentNote.createdAt.toString(),
          createdAt: currentNote.createdAt.toString(),
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

  Future<DatabaseNote> createNewNote(
      DatabaseNote? existingNote, text, title) async {
    var response;
    if (existingNote != null) {
      debugPrint('updating note');
      existingNote.note = text;
      existingNote.updatedAt = DateTime.now();
      response = await _noteService.updateNote(
        note: existingNote,
      );
    } else {
      debugPrint('creating new note');
      response = await _noteService.createNote(
        title: title,
        note: text,
      );
      _notes.insert(0, response);
      _localNotes.add(response);
    }
    return response;
  }

  Future<void> deleteNote(int id) async {
    if (_notes.firstWhere((element) => element.id == id).uploadedAt == null) {
      debugPrint('is not uploaded');
      _localNotes.removeWhere((element) => element.id == id);
    }
    _notes.removeWhere((element) => element.id == id);
    notifyListeners();
    await _noteService.deleteNote(id: id);
  }
}
