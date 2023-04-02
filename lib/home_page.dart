import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:note_app_mobile/add_note.dart';
import 'package:note_app_mobile/note_class.dart';
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
  late Future<Note> myNote;
  List<Note>? notes;
  var isLoaded = true;
  final textController = TextEditingController();
  List<Note> dbNotes = [];
  late final NoteService _noteService;

  @override
  initState() {
    _noteService = NoteService();
    super.initState();
    // myNote = getNote();

    getData();
  }

  getData() async {
    await _noteService.getAllNote();
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
        body: StreamBuilder(
            stream: _noteService.allNotes,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  if (snapshot.hasData) {
                    final allNotes = snapshot.data as List<DatabaseNote>;
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: allNotes.length,
                            itemBuilder: (context, index) {
                              final currentNote = allNotes[index];
                              return ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentNote.title.toUpperCase(),
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
                                      var shouldDelete =
                                          await showDeleteDialog(context);
                                      debugPrint(
                                          'about to delete note ${currentNote.id}');
                                      debugPrint(shouldDelete.toString());
                                      if (shouldDelete == true) {
                                        await _noteService.deleteNote(
                                            id: currentNote.id);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Color.fromARGB(255, 88, 7, 7),
                                    )),
                                onTap: () {
                                  debugPrint('get note details');
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return NoteDetails(note: currentNote);
                                  }));
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }

                default:
                  return const CircularProgressIndicator();
              }
            }));
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
