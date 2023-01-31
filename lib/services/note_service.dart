import 'package:note_app_mobile/note_class.dart';
import 'package:http/http.dart' as http;

class NoteService {
  Future<List<Note>?> getNotes() async {
    var client = http.Client();

    var uri = Uri.parse('https://donzoby.com/api/test');
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var json = response.body;
      return noteFromJson(json);
    }
  }
}
