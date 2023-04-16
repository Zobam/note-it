import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:note_app_mobile/note_details.dart';
import 'package:note_app_mobile/services/crud/notes_service.dart';
import 'package:note_app_mobile/utilities/dialogs.dart';

void main(List<String> args) {
  runApp(HomePage());
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DatabaseNote> allNotes = [];
  late final NoteService _noteService;
  bool loadedNotes = false;

  @override
  initState() {
    _noteService = NoteService();
    super.initState();
    // myNote = getNote();

    getData();
  }

  getData() async {
    var myNotes = await _noteService.getAllNote();
    setState(() {
      allNotes = myNotes;
      loadedNotes = true;
    });
    /* notes = await NoteService().getNotes();
    if (notes != null) {
      setState(() {
        isLoaded = true;
      });
    } */
    /*  _noteHelper.initDatabase();
    dbNotes = await _noteHelper.getNotes(); */
    /* if (dbNotes.isNotEmpty) {
      setState(() {
        isLoaded = true;
      });
    } */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loadedNotes
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (context, index) {
                final currentNote = allNotes[index];
                debugPrint('after getting current not at list view');
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${index + 1}). ${currentNote.title.toUpperCase()}",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 4, 81, 119),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currentNote.note,
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                      onPressed: () async {
                        var shouldDelete = await showDeleteDialog(context);
                        debugPrint('about to delete note ${currentNote.id}');
                        debugPrint(shouldDelete.toString());
                        if (shouldDelete == true) {
                          await _noteService.deleteNote(id: currentNote.id);
                          getData();
                        }
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Color.fromARGB(255, 88, 7, 7),
                      )),
                  onTap: () {
                    debugPrint('get note details');
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return NoteDetails(note: currentNote);
                    }));
                  },
                );
              },
            )
          : Container(
              padding: const EdgeInsets.only(top: 10),
              child: const LinearProgressIndicator(),
            ),
    );
  }

  /* Future<Note> getNote() async {
    const api_url = 'https://www.donzoby.com/api/test';
    final response = await http.get(Uri.parse(api_url));
    if (response.statusCode == 200) {
      return Note.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load note");
    }
  } */
}
