import 'package:flutter/material.dart';
import 'package:note_app_mobile/note_class.dart';
import 'package:note_app_mobile/services/crud/notes_service.dart';
import 'package:sqflite/sqflite.dart';

class AddNote extends StatefulWidget {
  final DatabaseNote? note;

  const AddNote({super.key, this.note});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  late final TextEditingController textController;
  final NoteHelper _noteHelper = NoteHelper();
  late Note currentNote;
  DatabaseNote? _note;
  late final NoteService _notesService;

  @override
  void initState() {
    _notesService = NoteService();
    textController = TextEditingController();
    textController.text = widget.note?.note ?? '';
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = textController.text;
    _note = await _notesService.updateNote(
      note: note,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    textController.removeListener(_textControllerListener);
    textController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    return _notesService.createNote(
      title: 'first note',
      note: 'this took so long',
    );
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final text = textController.text;
    if (note != null && text.isNotEmpty) {
      // await _notesService.createNote(title: 'title', note: text);
      await _notesService.updateNote(note: note, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Note'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data;
              _setupTextControllerListener();
              return TextField(
                controller: textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'start typing your note',
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
