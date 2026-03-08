import 'dart:io';

class DartWriter {
  /// Writes the content to a file at the specified path.
  /// Creates directories if they don't exist.
  static void write(String path, String content) {
    try {
      final file = File(path);
      file.createSync(recursive: true);
      file.writeAsStringSync(content);
      print('Generated: $path');
    } catch (e) {
      throw Exception('Failed to write file at $path: $e');
    }
  }
}
