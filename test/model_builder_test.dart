import 'package:api_model_generator/generator/model_builder.dart';
import 'package:test/test.dart';

void main() {
  group('ModelBuilder', () {
    test('generates expected model code for simple JSON', () {
      final json = {
        'id': 1,
        'name': 'John'
      };
      final builder = ModelBuilder('User', json);
      final code = builder.build();
      
      expect(code, contains('class User {'));
      expect(code, contains('final int id;'));
      expect(code, contains('final String name;'));
      expect(code, contains('User({'));
      expect(code, contains('factory User.fromJson(Map<String, dynamic> json) {'));
      expect(code, contains('Map<String, dynamic> toJson() {'));
    });

    test('generates code for nested JSON with imports', () {
      final json = {
        'id': 1,
        'address': {
          'city': 'New York'
        }
      };
      final builder = ModelBuilder('User', json);
      final code = builder.build();
      
      expect(code, contains("import 'address.dart';"));
      expect(code, contains('final Address address;'));
      expect(code, contains("address: Address.fromJson(json['address'])"));
    });

    test('generates code for JSON with primitive lists', () {
      final json = {
        'tags': ['flutter', 'dart']
      };
      final builder = ModelBuilder('User', json);
      final code = builder.build();
      
      expect(code, contains('final List<String> tags;'));
      expect(code, contains("tags: List<String>.from(json['tags'])"));
    });

    test('generates code for JSON with complex lists', () {
      final json = {
        'projects': [{'id': 1, 'name': 'Alpha'}]
      };
      final builder = ModelBuilder('User', json);
      final code = builder.build();
      
      expect(code, contains("import 'projects.dart';"));
      expect(code, contains('final List<Projects> projects;'));
      expect(code, contains("(json['projects'] as List).map((i) => Projects.fromJson(i)).toList()"));
    });
  });
}
