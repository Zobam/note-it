import 'package:flutter/material.dart';
import 'package:note_app_mobile/main.dart';
import 'package:note_app_mobile/note_class.dart';
import 'package:note_app_mobile/services/crud/notes_service.dart';

class AddNote extends StatefulWidget {
  final DatabaseNote? note;

  const AddNote({super.key, this.note});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  late final TextEditingController textController;
  late final TextEditingController titleController;
  late Note currentNote;
  DatabaseNote? _note;
  late final NoteService _notesService;
  bool formIsValid = false;

  @override
  void initState() {
    _notesService = NoteService();
    textController = TextEditingController();
    titleController = TextEditingController();
    textController.text = widget.note?.note ?? '';
    titleController.text = widget.note?.title ?? '';
    super.initState();
  }

  /* void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = textController.text;
    _note = await _notesService.updateNote(
      note: note,
      text: text,
    );
  } */

  /*  void _setupTextControllerListener() {
    textController.removeListener(_textControllerListener);
    textController.addListener(_textControllerListener);
  } */

  Future<DatabaseNote> createNewNote() async {
    final existingNote = widget.note;
    final text = textController.text;
    final title = titleController.text;
    if (existingNote != null) {
      debugPrint('updating note');
      return _notesService.updateNote(
        note: existingNote,
      );
    }
    debugPrint('creating new note');
    return _notesService.createNote(
      title: title,
      note: text,
    );
  }

  void checkFormValidity(String text) {
    setState(() {
      formIsValid = text.length >= 2;
    });
  }

/*   void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  } */

  /*  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final text = textController.text;
    if (note != null && text.isNotEmpty) {
      // await _notesService.createNote(title: 'title', note: text);
      await _notesService.updateNote(note: note, text: text);
    }
  } */

  @override
  void dispose() {
    // _deleteNoteIfTextIsEmpty();
    // _saveNoteIfTextIsNotEmpty();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String buttonText = widget.note == null ? 'Save Note' : 'Update Note';
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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'enter your note title',
                ),
              ),
              TextField(
                controller: textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'start typing your note',
                ),
                onChanged: (value) {
                  checkFormValidity(value);
                },
              ),
              !formIsValid
                  ? ElevatedButton(
                      onPressed: null,
                      child: Text(buttonText),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        await createNewNote();
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return NoteApp();
                        }));
                      },
                      child: Text(buttonText),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
