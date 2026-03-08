import '../utils/string_utils.dart';
import 'model_registry.dart';

class TypeDetector {
  /// Detects the Dart type from a JSON value.
  /// If it's a Map, it returns the provided nestedModelName or the key capitalized.
  static String detectType(dynamic value, String fieldName, [ModelRegistry? registry]) {
    if (value is int) {
      return 'int';
    } else if (value is double) {
      return 'double';
    } else if (value is bool) {
      return 'bool';
    } else if (value is String) {
      return 'String';
    } else if (value is Map) {
      // For a Map, we use getModelName which will handle registration if registry is present.
      return getModelName(value, fieldName, registry);
    } else if (value is List) {
      if (value.isEmpty) {
        return 'List<dynamic>';
      }
      final firstElement = value.first;
      final typeOfElement = detectType(firstElement, fieldName, registry);
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

  /// Gets the nested model name for a complex type.
  /// If the structure is already registered, returns the existing name.
  /// Otherwise, registers the structure with a new name based on fieldName.
  static String getModelName(dynamic value, String fieldName, [ModelRegistry? registry]) {
     if (value is Map) {
        final Map<String, dynamic> mapValue = value as Map<String, dynamic>;
        final structure = <String, String>{};
        mapValue.forEach((k, v) {
          // Note: We use detectType recursively but without passing the registry 
          // to avoid circular registration issues or overly complex logic here.
          // Wait, actually passing registry is fine because detectType for Map calls getModelName.
          // But for child Maps, we might not have a fieldName that is unique yet.
          structure[k] = detectType(v, k, registry);
        });
        
        if (registry != null) {
          final existing = registry.findExistingModel(structure);
          if (existing != null) return existing;
          
          final name = StringUtils.capitalize(StringUtils.snakeToCamel(fieldName));
          registry.registerModel(name, structure);
          return name;
        }
        return StringUtils.capitalize(StringUtils.snakeToCamel(fieldName));
     } else if (value is List && value.isNotEmpty) {
       return getModelName(value.first, fieldName, registry);
     }
     return 'dynamic';
  }
}
