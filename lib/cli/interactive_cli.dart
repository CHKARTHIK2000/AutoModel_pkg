import 'dart:io';
import '../generator/json_parser.dart';
import '../generator/model_builder.dart';
import '../generator/model_registry.dart';
import '../generator/service_generator.dart';
import '../generator/repository_generator.dart';
import '../writer/dart_writer.dart';
import '../utils/string_utils.dart';
import 'package:path/path.dart' as p;

class InteractiveCLI {
  void start() {
    print('🚀 Flutter API Model Generator');
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
      print('JSON file detected: $jsonPath');
    } catch (e) {
      print('Error: $e');
      return;
    }

    // 3. Get Model Name
    stdout.write('Enter model name: ');
    String? modelNameInput = stdin.readLineSync()?.trim();
    if (modelNameInput == null || modelNameInput.isEmpty) {
      print('Model name is required!');
      return;
    }
    final modelName = StringUtils.capitalize(modelNameInput);

    // 4. Get Options
    print('\nWhat do you want to generate?');
    print('1. Model');
    print('2. Model + Service');
    print('3. Model + Service + Repository');
    stdout.write('Choice (1-3, default: 1): ');
    String? choice = stdin.readLineSync()?.trim();
    if (choice == null || choice.isEmpty) choice = '1';

    // 5. Generate
    try {
      final registry = ModelRegistry();
      final baseObject = JsonParser.extractBaseObject(json);
      final isList = json is List;
      
      // Models Generation
      final outputDir = 'lib/models';
      final baseBuilder = ModelBuilder(modelName, baseObject, registry);
      final allModels = baseBuilder.getAllModels();
      
      for (var model in allModels) {
        if (registry.isProcessed(model.modelName)) continue;
        
        final fileName = StringUtils.camelToSnake(model.modelName);
        final fullPath = p.join(outputDir, '$fileName.dart');
        
        final code = model.build();
        DartWriter.write(fullPath, code);
        registry.markProcessed(model.modelName);
      }

      final baseModelFileName = StringUtils.camelToSnake(modelName);

      // Service Generation
      if (choice == '2' || choice == '3') {
        final serviceGen = ServiceGenerator(
          modelName: modelName,
          isList: isList,
          modelFileName: baseModelFileName,
        );
        final serviceCode = serviceGen.build();
        final serviceFileName = StringUtils.camelToSnake('${modelName}Service');
        DartWriter.write('lib/services/$serviceFileName.dart', serviceCode);
      }

      // Repository Generation
      if (choice == '3') {
        final repoGen = RepositoryGenerator(
          modelName: modelName,
          isList: isList,
          modelFileName: baseModelFileName,
        );
        final repoCode = repoGen.build();
        final repoFileName = StringUtils.camelToSnake('${modelName}Repository');
        DartWriter.write('lib/repositories/$repoFileName.dart', repoCode);
      }

      print('-----------------------------------------');
      print('Success! Generation complete.');
      print('-----------------------------------------');
    } catch (e) {
      print('Failed to generate: $e');
    }
  }
}
