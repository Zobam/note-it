import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:note_app_mobile/add_note.dart';
import 'package:note_app_mobile/note_class.dart';

void main(List<String> args) {
  runApp(HomePage());
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Note> myNote;

  @override
  initState() {
    super.initState();
    myNote = getNote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<Note>(
            future: myNote,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!.note);
              } else {
                return const CircularProgressIndicator();
              }
            }),
/*         child: ElevatedButton(
          onPressed: () {
            debugPrint('about to navigate');
            Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) {
                return const AddNote();
              }),
            );
          },
          child: const Text('visit add note page'),
        ), */
      ),
    );
  }

  Future<Note> getNote() async {
    const api_url = 'https://www.donzoby.com/api/test';
    final response = await http.get(Uri.parse(api_url));
    if (response.statusCode == 200) {
      return Note.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load note");
    }
  }
}
