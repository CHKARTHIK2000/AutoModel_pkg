import 'dart:io';
import '../generator/json_parser.dart';
import '../generator/model_builder.dart';
import '../writer/dart_writer.dart';
import '../utils/string_utils.dart';
import 'package:path/path.dart' as p;

class InteractiveCLI {
  void start() {
    print('-----------------------------------------');
    print('   Flutter JSON Model Generator CLI   ');
    print('-----------------------------------------');

    // 1. Get JSON file path
    stdout.write('Enter JSON file path (default: response.json): ');
    String? jsonPath = stdin.readLineSync()?.trim();
    if (jsonPath == null || jsonPath.isEmpty) {
      jsonPath = 'response.json';
    }

    // 2. Parse JSON
    dynamic json;
    try {
      json = JsonParser.parseFile(jsonPath);
    } catch (e) {
      print('Error: $e');
      return;
    }

    // 3. Get Model Name
    stdout.write('Enter model name: ');
    String? modelName = stdin.readLineSync()?.trim();
    if (modelName == null || modelName.isEmpty) {
      print('Model name is required!');
      return;
    }
    modelName = StringUtils.capitalize(modelName);

    // 4. Get Output Directory
    stdout.write('Enter output folder (default: lib/models): ');
    String? outputDir = stdin.readLineSync()?.trim();
    if (outputDir == null || outputDir.isEmpty) {
      outputDir = 'lib/models';
    }

    // 5. Generate Models
    try {
      final baseObject = JsonParser.extractBaseObject(json);
      final baseBuilder = ModelBuilder(modelName, baseObject);
      
      final allModels = baseBuilder.getAllModels();
      final processedModelNames = <String>{};

      for (var model in allModels) {
        if (processedModelNames.contains(model.modelName)) continue;
        
        final fileName = StringUtils.camelToSnake(model.modelName);
        final fullPath = p.join(outputDir, '$fileName.dart');
        
        final code = model.build();
        DartWriter.write(fullPath, code);
        processedModelNames.add(model.modelName);
      }

      print('-----------------------------------------');
      print('Success! Model generation complete.');
      print('Files created in: $outputDir');
      print('-----------------------------------------');
    } catch (e) {
      print('Failed to generate models: $e');
    }
  }
}
