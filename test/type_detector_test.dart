import 'package:api_model_generator/generator/type_detector.dart';
import 'package:test/test.dart';

void main() {
  group('TypeDetector', () {
    test('detects primitive types correctly', () {
      expect(TypeDetector.detectType(10, 'id'), 'int');
      expect(TypeDetector.detectType(10.5, 'rating'), 'double');
      expect(TypeDetector.detectType('hello', 'name'), 'String');
      expect(TypeDetector.detectType(true, 'is_active'), 'bool');
    });

    test('detects complex types', () {
      expect(TypeDetector.isComplexType({'city': 'NY'}), isTrue);
      expect(TypeDetector.isComplexType([{'city': 'NY'}]), isTrue);
      expect(TypeDetector.isComplexType([1, 2, 3]), isFalse);
    });

    test('detects List types', () {
      expect(TypeDetector.detectType([1, 2, 3], 'tags'), 'List<int>');
      expect(TypeDetector.detectType(['a', 'b'], 'tags'), 'List<String>');
      expect(TypeDetector.detectType([], 'tags'), 'List<dynamic>');
    });

    test('detects nested Map type as class name', () {
      expect(TypeDetector.detectType({'street': '123'}, 'address'), 'Address');
    });
  });
}
