import '../utils/string_utils.dart';
import 'type_detector.dart';
import 'model_registry.dart';

class ModelBuilder {
  final String modelName;
  final Map<String, dynamic> json;
  final ModelRegistry? registry;

  ModelBuilder(this.modelName, this.json, [this.registry]);

  /// Generates the complete Dart code for the model class
  String build() {
    final sb = StringBuffer();

    // 1. Imports (if needed, e.g., for nested models in separate files)
    _buildImports(sb);

    // 2. Class Definition
    sb.writeln('class $modelName {');

    // 3. Fields
    _buildFields(sb);

    sb.writeln();

    // 4. Constructor
    _buildConstructor(sb);

    sb.writeln();

    // 5. fromJson factory
    _buildFromJson(sb);

    sb.writeln();

    // 6. toJson method
    _buildToJson(sb);

    sb.writeln('}');
    
    return sb.toString();
  }

  void _buildImports(StringBuffer sb) {
    final imports = <String>{};
    for (var entry in json.entries) {
      if (TypeDetector.isComplexType(entry.value)) {
        final nestedName = TypeDetector.getModelName(entry.value, entry.key, registry);
        if (nestedName != modelName) {
           final fileName = StringUtils.camelToSnake(nestedName);
           imports.add("import '$fileName.dart';");
        }
      }
    }
    
    if (imports.isNotEmpty) {
      for (var importLine in imports.toList()..sort()) {
        sb.writeln(importLine);
      }
      sb.writeln();
    }
  }

  void _buildFields(StringBuffer sb) {
    json.forEach((key, value) {
      final type = TypeDetector.detectType(value, key, registry);
      final variableName = StringUtils.snakeToCamel(key);
      sb.writeln('  final $type $variableName;');
    });
  }

  void _buildConstructor(StringBuffer sb) {
    sb.writeln('  $modelName({');
    json.forEach((key, value) {
      final variableName = StringUtils.snakeToCamel(key);
      sb.writeln('    required this.$variableName,');
    });
    sb.writeln('  });');
  }

  void _buildFromJson(StringBuffer sb) {
    sb.writeln('  factory $modelName.fromJson(Map<String, dynamic> json) {');
    sb.writeln('    return $modelName(');
    
    json.forEach((key, value) {
      final variableName = StringUtils.snakeToCamel(key);
      final type = TypeDetector.detectType(value, key, registry);
      
      if (value is Map) {
         sb.writeln("      $variableName: $type.fromJson(json['$key']),");
      } else if (value is List) {
         if (value.isNotEmpty && value.first is Map) {
           final innerType = TypeDetector.detectType(value.first, key, registry);
           sb.writeln("      $variableName: (json['$key'] as List).map((i) => $innerType.fromJson(i)).toList(),");
         } else {
           // type is List<Something>
           final innerType = type.replaceAll('List<', '').replaceAll('>', '');
           sb.writeln("      $variableName: List<$innerType>.from(json['$key']),");
         }
      } else {
         sb.writeln("      $variableName: json['$key'],");
      }
    });
    
    sb.writeln('    );');
    sb.writeln('  }');
  }

  void _buildToJson(StringBuffer sb) {
    sb.writeln('  Map<String, dynamic> toJson() {');
    sb.writeln('    return {');
    
    json.forEach((key, value) {
      final variableName = StringUtils.snakeToCamel(key);
      
      if (value is Map) {
         sb.writeln("      '$key': $variableName.toJson(),");
      } else if (value is List && value.isNotEmpty && value.first is Map) {
         sb.writeln("      '$key': $variableName.map((i) => i.toJson()).toList(),");
      } else {
         sb.writeln("      '$key': $variableName,");
      }
    });
    
    sb.writeln('    };');
    sb.writeln('  }');
  }

  /// Recursively finds and creates nested model builders
  List<ModelBuilder> getAllModels() {
    List<ModelBuilder> allModels = [this];
    
    json.forEach((key, value) {
      if (value is Map) {
        final nestedName = TypeDetector.getModelName(value, key, registry);
        final nestedBuilder = ModelBuilder(nestedName, value as Map<String, dynamic>, registry);
        allModels.addAll(nestedBuilder.getAllModels());
      } else if (value is List && value.isNotEmpty && value.first is Map) {
        final nestedName = TypeDetector.getModelName(value.first, key, registry);
        final nestedBuilder = ModelBuilder(nestedName, value.first as Map<String, dynamic>, registry);
        allModels.addAll(nestedBuilder.getAllModels());
      }
    });
    
    return allModels;
  }
}
