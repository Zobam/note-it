import 'package:flutter/material.dart';
import 'package:note_app_mobile/note_class.dart';

class NoteDetails extends StatelessWidget {
  final Note note;
  const NoteDetails({super.key, required this.note});

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
        ],
      ),
    );
  }
}
