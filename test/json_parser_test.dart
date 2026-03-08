import 'dart:io';
import 'package:api_model_generator/generator/json_parser.dart';
import 'package:test/test.dart';

void main() {
  group('JsonParser', () {
    const String tempFile = 'test_json.json';

    tearDown(() {
      if (File(tempFile).existsSync()) {
        File(tempFile).deleteSync();
      }
    });

    test('parseFile reads and decodes JSON correctly', () {
      File(tempFile).writeAsStringSync('{"id": 1, "name": "John"}');
      final result = JsonParser.parseFile(tempFile);
      
      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], 1);
      expect(result['name'], 'John');
    });

    test('parseFile throws exception for non-existent file', () {
      expect(() => JsonParser.parseFile('missing.json'), throwsA(isA<Exception>()));
    });

    test('extractBaseObject handles Map', () {
      final json = {"id": 1};
      expect(JsonParser.extractBaseObject(json), json);
    });

    test('extractBaseObject handles List of Maps', () {
      final json = [{"id": 1}, {"id": 2}];
      expect(JsonParser.extractBaseObject(json), json.first);
    });
  });
}
