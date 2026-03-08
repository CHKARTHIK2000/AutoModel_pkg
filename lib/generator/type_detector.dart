import '../utils/string_utils.dart';

class TypeDetector {
  /// Detects the Dart type from a JSON value.
  /// If it's a Map, it returns the provided nestedModelName or the key capitalized.
  static String detectType(dynamic value, String fieldName) {
    if (value is int) {
      return 'int';
    } else if (value is double) {
      return 'double';
    } else if (value is bool) {
      return 'bool';
    } else if (value is String) {
      return 'String';
    } else if (value is Map) {
      return StringUtils.capitalize(StringUtils.snakeToCamel(fieldName));
    } else if (value is List) {
      if (value.isEmpty) {
        return 'List<dynamic>';
      }
      final firstElement = value.first;
      final typeOfElement = detectType(firstElement, fieldName);
      return 'List<$typeOfElement>';
    } else {
      return 'dynamic';
    }
  }

  /// Determines if a value is a complex object (Map) or a List of Maps
  /// which will require a separate model class.
  static bool isComplexType(dynamic value) {
    if (value is Map) {
      return true;
    } else if (value is List && value.isNotEmpty) {
      return isComplexType(value.first);
    }
    return false;
  }

  /// Gets the nested model name for a complex type
  static String getModelName(dynamic value, String fieldName) {
     if (value is Map) {
       return StringUtils.capitalize(StringUtils.snakeToCamel(fieldName));
     } else if (value is List && value.isNotEmpty) {
       return getModelName(value.first, fieldName);
     }
     return 'dynamic';
  }
}
