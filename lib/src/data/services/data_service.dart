import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DataService {
  




  // 3. Write Data to Local Data Source (File System)
  Future<File> writeToLocalFile(String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_notes.txt');
    return file.writeAsString(content);
  }

  // 4. Read Data from Local Data Source (File System)
  Future<String> readFromLocalFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_notes.txt');
      
      if (await file.exists()) {
        return await file.readAsString();
      }
      return "No notes saved locally.";
    } catch (e) {
      return "Error reading file: $e";
    }
  }
}
