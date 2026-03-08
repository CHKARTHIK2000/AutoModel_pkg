import 'dart:convert';
import 'dart:io';

class JsonParser {
  /// Reads a JSON file and returns a Map or List
  static dynamic parseFile(String filePath) {
    final file = File(filePath);
    
    if (!file.existsSync()) {
      throw Exception('JSON file not found: $filePath');
    }
    
    try {
      final content = file.readAsStringSync();
      return jsonDecode(content);
    } on FormatException catch (e) {
      throw Exception('Invalid JSON format: ${e.message}');
    } catch (e) {
      throw Exception('Failed to read JSON: $e');
    }
  }

  /// Extracts the base object for model generation.
  /// If the input is a list, returns the first element if available.
  static Map<String, dynamic> extractBaseObject(dynamic json) {
    if (json is Map<String, dynamic>) {
      return json;
    } else if (json is List && json.isNotEmpty) {
      final first = json.first;
      if (first is Map<String, dynamic>) {
        return first;
      }
    }
    
    throw Exception('JSON does not contain a valid object for model generation.');
  }
}
