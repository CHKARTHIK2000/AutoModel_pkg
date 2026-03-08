import 'dart:io';
import 'json_parser.dart';
import 'type_detector.dart';
import 'model_builder.dart';
import 'model_registry.dart';
import '../utils/string_utils.dart';
import '../writer/dart_writer.dart';
import 'package:path/path.dart' as p;

class ModelSync {
  /// Synchronizes an existing Dart model file with a new JSON response.
  static void sync(String modelFilePath, dynamic newJson, String modelName, ModelRegistry registry) {
    final file = File(modelFilePath);
    if (!file.existsSync()) {
      throw Exception('Model file not found: $modelFilePath');
    }

    final content = file.readAsStringSync();
    final existingFields = _extractFields(content);
    
    final baseObject = JsonParser.extractBaseObject(newJson);
    final jsonFields = <String, String>{};
    baseObject.forEach((key, value) {
      jsonFields[StringUtils.snakeToCamel(key)] = TypeDetector.detectType(value, key, registry);
    });

    final newFields = <String, String>{};
    jsonFields.forEach((name, type) {
      if (!existingFields.containsKey(name)) {
        newFields[name] = type;
      }
    });

    if (newFields.isEmpty) {
      print('No new fields detected in $modelName.');
      return;
    }

    print('\n🚀 Model Update Detected for $modelName');
    print('New fields:');
    newFields.forEach((name, type) => print('  * $name : $type'));
    
    stdout.write('\nContinue updating $modelName? (y/n, default: y): ');
    final input = stdin.readLineSync()?.toLowerCase();
    if (input == 'n') {
      print('Sync cancelled for $modelName.');
      return;
    }

    // Use ModelBuilder to generate the updated model and any new nested models
    final builder = ModelBuilder(modelName, baseObject, registry);
    final allModels = builder.getAllModels();
    
    final outputDir = p.dirname(modelFilePath);
    
    for (var model in allModels) {
      // If it's the model we're syncing, always write it.
      // If it's a nested model, check if it was already processed or if it exists.
      if (model.modelName == modelName) {
         final code = model.build();
         DartWriter.write(modelFilePath, code);
         registry.markProcessed(modelName);
         continue;
      }

      if (registry.isProcessed(model.modelName)) continue;
      
      final nestedFileName = StringUtils.camelToSnake(model.modelName);
      final nestedPath = p.join(outputDir, '$nestedFileName.dart');
      
      // If it doesn't exist, generate it.
      if (!File(nestedPath).existsSync()) {
         final code = model.build();
         DartWriter.write(nestedPath, code);
         registry.markProcessed(model.modelName);
      }
    }
    
    print('Successfully synced $modelName.');
  }

  /// Extracts field names and types from an existing Dart model file content.
  /// Matches: final Type name;
  static Map<String, String> _extractFields(String content) {
    final fields = <String, String>{};
    final regex = RegExp(r'final\s+([\w<>]+)\s+(\w+);');
    final matches = regex.allMatches(content);
    
    for (final match in matches) {
      final type = match.group(1)!;
      final name = match.group(2)!;
      fields[name] = type;
    }
    
    return fields;
  }
}
