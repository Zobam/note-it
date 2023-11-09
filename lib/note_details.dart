import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_app_mobile/add_note.dart';
import 'package:note_app_mobile/models/note_model.dart';
import 'package:note_app_mobile/services/crud/notes_service.dart';
import 'package:note_app_mobile/utilities/dialogs.dart';
import 'package:provider/provider.dart';

class NoteDetails extends StatelessWidget {
  final DatabaseNote note;
  NoteDetails({super.key, required this.note});
  final NoteService _noteService = NoteService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note.title!.toUpperCase())),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 29),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    note.title == null ? '' : note.title!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    DateFormat.yMMMd().add_jm().format(note.createdAt!),
                  ),
                ],
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
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ColoredBox(
                    color: Color.fromARGB(255, 4, 81, 119),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Last modified: ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      DateFormat.yMMMd().add_jm().format(note.updatedAt!),
                    ),
                  ),
                ],
              ),
            ),
            if (note.uploadedAt == null) ...[
              Center(
                child: Container(
                  color: Color.fromARGB(255, 244, 237, 237),
                  padding: const EdgeInsets.all(6),
                  child: Text('Note NOT uploaded ${note.serverId}'),
                ),
              ),
            ],
            Container(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext contex) {
                        return AddNote(
                          note: note,
                        );
                      }));
                    },
                    child: const Text('Edit'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      var appState =
                          Provider.of<NoteModel>(context, listen: false);
                      var shouldDelete = await showDeleteDialog(context);
                      if (shouldDelete == true) {
                        await appState.deleteNote(note.id);
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
      ),
    );
  }
}
