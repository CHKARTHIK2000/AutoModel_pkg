import 'dart:io';
import '../generator/json_parser.dart';
import '../generator/model_builder.dart';
import '../generator/model_registry.dart';
import '../generator/service_generator.dart';
import '../generator/repository_generator.dart';
import '../generator/model_sync.dart';
import '../config/config_loader.dart';
import '../writer/dart_writer.dart';
import '../utils/string_utils.dart';
import 'package:path/path.dart' as p;

class InteractiveCLI {
  final GeneratorConfig config;

  InteractiveCLI(this.config);

  /// Default interactive mode
  void startInteractive() {
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
      print('✔ JSON file detected: $jsonPath');
    } catch (e) {
      print('Error: $e');
      return;
    }

    // 3. Menu
    print('\nWhat do you want to do?');
    print('1. Generate Model');
    print('2. Generate Model + Service');
    print('3. Generate Model + Service + Repository');
    print('4. Sync Existing Models');
    stdout.write('Choice (1-4, default: 1): ');
    String? choice = stdin.readLineSync()?.trim();
    if (choice == null || choice.isEmpty) choice = '1';

    if (choice == '4') {
      _handleSync(json);
      return;
    }

    // Get Model Name
    stdout.write('Enter model name: ');
    String? modelNameInput = stdin.readLineSync()?.trim();
    if (modelNameInput == null || modelNameInput.isEmpty) {
      print('Error: Model name is required!');
      return;
    }
    final modelName = StringUtils.capitalize(modelNameInput);

    _runGeneration(json, modelName, choice, false);
  }

  /// Generate based on config file
  void startGenerate() {
    if (!ConfigLoader.exists()) {
      print('Warning: api_model_generator.yaml not found. Falling back to interactive mode.');
      startInteractive();
      return;
    }

    print('🚀 Generating from configuration...');
    
    final jsonPath = 'response.json'; // Default
    if (!File(jsonPath).existsSync()) {
      print('Error: $jsonPath not found.');
      return;
    }

    dynamic json;
    try {
      json = JsonParser.parseFile(jsonPath);
    } catch (e) {
      print('Error parsing $jsonPath: $e');
      return;
    }

    stdout.write('Enter model name: ');
    final modelNameInput = stdin.readLineSync()?.trim();
    if (modelNameInput == null || modelNameInput.isEmpty) {
      print('Error: Model name is required!');
      return;
    }
    final modelName = StringUtils.capitalize(modelNameInput);

    String choice = '1';
    if (config.generateService) choice = '2';
    if (config.generateRepository) choice = '3';

    _runGeneration(json, modelName, choice, true);
  }

  /// Direct sync mode
  void startSync() {
    print('🚀 Starting Model Sync...');
    
    stdout.write('Enter JSON file path (default: response.json): ');
    String? jsonPath = stdin.readLineSync()?.trim();
    if (jsonPath == null || jsonPath.isEmpty) jsonPath = 'response.json';

    if (!File(jsonPath).existsSync()) {
      print('Error: $jsonPath not found.');
      return;
    }

    dynamic json;
    try {
      json = JsonParser.parseFile(jsonPath);
    } catch (e) {
      print('Error parsing $jsonPath: $e');
      return;
    }

    _handleSync(json);
  }

  void _runGeneration(dynamic json, String modelName, String choice, bool useConfig) {
    try {
      final registry = ModelRegistry();
      final baseObject = JsonParser.extractBaseObject(json);
      final isList = json is List;
      
      // Models Generation
      final modelsOutputDir = config.modelsPath;
      final baseBuilder = ModelBuilder(modelName, baseObject, registry);
      final allModels = baseBuilder.getAllModels();
      
      for (var model in allModels) {
        if (registry.isProcessed(model.modelName)) continue;
        
        final fileName = StringUtils.camelToSnake(model.modelName);
        final fullPath = p.join(modelsOutputDir, '$fileName.dart');
        
        final code = model.build();
        DartWriter.write(fullPath, code);
        registry.markProcessed(model.modelName);
      }

      final baseModelFileName = StringUtils.camelToSnake(modelName);

      // Service Generation
      if (choice == '2' || choice == '3' || (useConfig && config.generateService)) {
        final serviceGen = ServiceGenerator(
          modelName: modelName,
          isList: isList,
          modelFileName: baseModelFileName,
        );
        final serviceCode = serviceGen.build();
        final serviceFileName = StringUtils.camelToSnake('${modelName}Service');
        DartWriter.write(p.join(config.servicesPath, '$serviceFileName.dart'), serviceCode);
      }

      // Repository Generation
      if (choice == '3' || (useConfig && config.generateRepository)) {
        final repoGen = RepositoryGenerator(
          modelName: modelName,
          isList: isList,
          modelFileName: baseModelFileName,
        );
        final repoCode = repoGen.build();
        final repoFileName = StringUtils.camelToSnake('${modelName}Repository');
        DartWriter.write(p.join(config.repositoriesPath, '$repoFileName.dart'), repoCode);
      }

      print('-----------------------------------------');
      print('✔ Success! Generation complete.');
      print('-----------------------------------------');
    } catch (e) {
      print('Failed to generate: $e');
    }
  }

  void _handleSync(dynamic json) {
     stdout.write('Enter existing model name to sync: ');
     final modelNameInput = stdin.readLineSync()?.trim();
     if (modelNameInput == null || modelNameInput.isEmpty) {
       print('Error: Model name is required for sync!');
       return;
     }
     final modelName = StringUtils.capitalize(modelNameInput);
     final fileName = StringUtils.camelToSnake(modelName);
     final modelFilePath = p.join(config.modelsPath, '$fileName.dart');
     
     if (!File(modelFilePath).existsSync()) {
       print('Error: Model file not found at $modelFilePath');
       return;
     }

     try {
       final registry = ModelRegistry();
       ModelSync.sync(modelFilePath, json, modelName, registry);
     } catch (e) {
       print('Sync failed: $e');
     }
  }
}
