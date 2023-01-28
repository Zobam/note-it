import 'package:flutter/material.dart';

class AddNote extends StatelessWidget {
  final int? noteId;

  const AddNote({super.key, this.noteId});

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
        child: Center(
          child: Column(
            children: [
              Image.asset('images/city1.png'),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: 3 > 3 ? Colors.green : Colors.red,
                    padding: const EdgeInsets.all(30)),
                onPressed: () {
                  debugPrint('adding new note');
                },
                child: const Text(
                  'Add Note',
                  style: TextStyle(),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  debugPrint('Outlined Button');
                },
                child: const Text(
                  'Add Note',
                  style: TextStyle(),
                ),
              ),
              const Divider(
                color: Color.fromARGB(255, 45, 153, 185),
              ),
              TextButton(
                onPressed: () {
                  debugPrint('Text Button');
                },
                child: const Text(
                  'Add Note',
                  style: TextStyle(),
                ),
              ),
              const Divider(
                color: Color.fromARGB(255, 45, 153, 185),
              ),
              const Text(
                  'This is the body text and my first flutter test on device'),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: (() => {debugPrint('Tapped')}),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Icon(Icons.fire_extinguisher, color: Colors.redAccent),
                      Text(
                        'In a row',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Icon(Icons.fire_truck),
                    ],
                  ),
                ),
              ),
              Switch(
                  value: false,
                  onChanged: (switchValue) {
                    debugPrint(switchValue.toString());
                  }),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(80),
                  ),
                ),
                child: Image.network(
                    'https://i.swncdn.com/media/800w/cms/CW/faith/66864-cross-sunset-gettyimages-chaiyapruek2520.1200w.tn.jpg'),
              ),
              Container(
                color: Colors.purple,
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                child: const Center(
                  child: Text(
                    'This is at the very \n bottom of this page at the moment.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your name',
                  ),
                  onChanged: (value) => debugPrint(value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
