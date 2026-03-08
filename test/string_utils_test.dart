import 'package:api_model_generator/utils/string_utils.dart';
import 'package:test/test.dart';

void main() {
  group('StringUtils', () {
    test('snakeToCamel converts snake_case to camelCase', () {
      expect(StringUtils.snakeToCamel('first_name'), 'firstName');
      expect(StringUtils.snakeToCamel('user_id'), 'userId');
      expect(StringUtils.snakeToCamel('zip_code'), 'zipCode');
      expect(StringUtils.snakeToCamel('is_active'), 'isActive');
    });

    test('capitalize capitalizes first letter', () {
      expect(StringUtils.capitalize('hello'), 'Hello');
      expect(StringUtils.capitalize('User'), 'User');
    });

    test('camelToSnake converts camelCase to snake_case', () {
      expect(StringUtils.camelToSnake('firstName'), 'first_name');
      expect(StringUtils.camelToSnake('userId'), 'user_id');
      expect(StringUtils.camelToSnake('Address'), 'address');
    });
  });
}
