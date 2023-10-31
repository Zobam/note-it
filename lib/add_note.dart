import 'package:flutter/material.dart';
import 'package:note_app_mobile/main.dart';
import 'package:note_app_mobile/models/note_model.dart';
import 'package:note_app_mobile/note_class.dart';
import 'package:note_app_mobile/services/crud/notes_service.dart';
import 'package:provider/provider.dart';

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
  bool formIsValid = false;

  @override
  void initState() {
    textController = TextEditingController();
    titleController = TextEditingController();
    textController.text = widget.note?.note ?? '';
    titleController.text = widget.note?.title ?? '';
    super.initState();
  }

  /* Future<DatabaseNote> createNewNote() async {
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
  } */

  void checkFormValidity(String text) {
    setState(() {
      formIsValid = text.length >= 2;
    });
  }

  @override
  void dispose() {
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
                      child: Text(
                          widget.note == null ? 'Save Note' : 'Update Note'),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        var appState =
                            Provider.of<NoteModel>(context, listen: false);
                        await appState.createNewNote(widget.note,
                            textController.text, titleController.text);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                            return NoteApp();
                          }),
                        );
                      },
                      child: Text(
                          widget.note == null ? 'Save Note' : 'Update Note'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
