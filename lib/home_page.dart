import 'package:flutter/material.dart';
import 'package:note_app_mobile/models/note_model.dart';
import 'package:note_app_mobile/note_details.dart';
import 'package:note_app_mobile/utilities/dialogs.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color firstColor = Colors.white;
  final Color secondColor = const Color.fromARGB(146, 235, 235, 235);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<NoteModel>();
    return Scaffold(
      body: !appState.loadingLocalNotes
          ? Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                if (appState.checkingServerNotes == true) ...[
                  const LinearProgressIndicator(),
                  const Text('Checking server for new notes ...'),
                ],
                if (appState.hasNewNotesOnServer == true) ...[
                  Text(
                    "You have ${appState.newNotesOnServer.length} new notes online.",
                  ),
                  IconButton(
                    onPressed: () {
                      appState.addServerNotes();
                    },
                    icon: const Icon(Icons.download),
                  ),
                ],
                if (appState.hasLocalNotes == true) ...[
                  Text(
                    "You have ${appState.localNotes.length} notes that are not uploaded.",
                  ),
                  IconButton(
                    onPressed: () {
                      appState.uploadLocalNotes();
                    },
                    icon: const Icon(Icons.upload),
                  ),
                ],
                Expanded(
                  child: ListView.builder(
                    itemCount: appState.notes.length,
                    itemBuilder: (context, index) {
                      final currentNote = appState.notes[index];
                      return Container(
                        color: index.isOdd ? firstColor : secondColor,
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${index + 1}). ${currentNote.title?.toUpperCase()}",
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 4, 81, 119),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: Text(
                                  currentNote.note,
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(15),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        "${currentNote.note.length} Chars",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    textAlign: TextAlign.right,
                                    DateFormat.yMMMd()
                                        .add_jm()
                                        .format(currentNote.createdAt!),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                              onPressed: () async {
                                var appState = Provider.of<NoteModel>(context,
                                    listen: false);
                                var shouldDelete =
                                    await showDeleteDialog(context);
                                debugPrint(
                                    'about to delete note ${currentNote.id}');
                                debugPrint(shouldDelete.toString());
                                if (shouldDelete == true) {
                                  await appState.deleteNote(currentNote.id);
                                }
                              },
                              icon: const Icon(
                                Icons.delete_forever_outlined,
                                color: Color.fromARGB(255, 125, 42, 42),
                              )),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return NoteDetails(note: currentNote);
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : Container(
              padding: const EdgeInsets.only(top: 10),
              child: const LinearProgressIndicator(),
            ),
    );
  }
}
