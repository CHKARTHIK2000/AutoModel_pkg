import 'package:api_model_generator/generator/model_registry.dart';
import 'package:test/test.dart';

void main() {
  group('ModelRegistry', () {
    test('registers and finds model by structure', () {
      final registry = ModelRegistry();
      final fields = {'id': 'int', 'name': 'String'};
      
      registry.registerModel('User', fields);
      
      final found = registry.findExistingModel(fields);
      expect(found, 'User');
    });

    test('recomputes signature correctly even if field order is different', () {
      final registry = ModelRegistry();
      
      registry.registerModel('User', {'id': 'int', 'name': 'String'});
      
      final found = registry.findExistingModel({'name': 'String', 'id': 'int'});
      expect(found, 'User');
    });

    test('returns null for unregistered structure', () {
      final registry = ModelRegistry();
      expect(registry.findExistingModel({'id': 'int'}), isNull);
    });

    test('tracks processed models', () {
      final registry = ModelRegistry();
      expect(registry.isProcessed('User'), isFalse);
      
      registry.markProcessed('User');
      expect(registry.isProcessed('User'), isTrue);
    });
  });
}
