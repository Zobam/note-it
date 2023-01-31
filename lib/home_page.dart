import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:note_app_mobile/add_note.dart';
import 'package:note_app_mobile/note_class.dart';
import 'package:note_app_mobile/note_details.dart';
import 'package:note_app_mobile/services/note_service.dart';

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
  var isLoaded = false;

  @override
  initState() {
    super.initState();
    // myNote = getNote();

    getData();
  }

  getData() async {
    notes = await NoteService().getNotes();
    if (notes != null) {
      setState(() {
        isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Visibility(
        visible: isLoaded,
        child: ListView.builder(
          itemCount: notes?.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    notes![index].title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      fontSize: 16,
                    ),
                  ),
                  const Divider(
                    color: Colors.black12,
                  )
                ],
              ),
              leading: Text(
                '${index + 1}.',
              ),
              trailing: const Icon(Icons.book_online),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return NoteDetails(note: notes![index]);
                }));
              },
            );
          },
        ),
        replacement: const Center(
          child: CircularProgressIndicator(),
        ),
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
