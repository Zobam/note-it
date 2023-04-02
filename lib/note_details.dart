import 'package:flutter/material.dart';
import 'package:note_app_mobile/add_note.dart';
import 'package:note_app_mobile/note_class.dart';
import 'package:note_app_mobile/services/crud/notes_service.dart';
import 'package:note_app_mobile/utilities/dialogs.dart';

class NoteDetails extends StatelessWidget {
  final DatabaseNote note;
  NoteDetails({super.key, required this.note});
  final NoteService _noteService = NoteService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note.title.toUpperCase())),
      body: Column(
        children: [
          const SizedBox(height: 29),
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              note.title.toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              note.note,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          Image.asset('images/city1.png'),
          Container(
            padding: const EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (BuildContext contex) {
                      return AddNote(
                        note: note,
                      );
                    }));
                  },
                  child: const Text('Edit'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    var shouldDelete = await showDeleteDialog(context);
                    if (shouldDelete == true) {
                      _noteService.deleteNote(id: note.id);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
