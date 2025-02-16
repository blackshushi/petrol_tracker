import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileSystem {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/vehicles.json');
  }

  static Future<String> readVehicles() async {
    try {
      final file = await _localFile;
      // Read the file
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      // If encountering an error, return an empty string
      return '';
    }
  }

  static Future<File> writeVehicles(String vehicles) async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString(vehicles);
  }
}