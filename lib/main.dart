import 'package:flutter/material.dart';
import 'package:note_app_mobile/about.dart';
import 'package:note_app_mobile/add_note.dart';
import 'package:note_app_mobile/home_page.dart';
import 'package:note_app_mobile/models/note_model.dart';
import 'package:note_app_mobile/note_class.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
    create: (context) => NoteModel(),
    child: NoteApp(),
  ));
}

class NoteApp extends StatelessWidget {
  NoteApp({Key? key}) : super(key: key);
  final newNote = Note(
    id: 2,
    title: 'first note',
    note: 'this is just the beginning',
    uploaded: 1,
    views: 0,
  );

  @override
  Widget build(BuildContext context) {
    debugPrint(newNote.note);
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const NotePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotePage extends StatefulWidget {
  const NotePage({Key? key}) : super(key: key);
  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  var currentPage = 0;
  List<Widget> pages = const [HomePage(), About()];
  var titles = ['Note It', 'About NoteIt'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[currentPage]),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline_rounded),
          )
        ],
      ),
      body: pages[currentPage],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('Add button clicked');
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return const AddNote();
          }));
        },
        child: const Icon(
          Icons.add,
          semanticLabel: 'Add New Note',
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            currentPage = index;
          });
          debugPrint('Index $currentPage selected.');
        },
        selectedIndex: currentPage,
      ),
    );
  }
}
