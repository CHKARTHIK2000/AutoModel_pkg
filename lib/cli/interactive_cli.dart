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

  void start(List<String> arguments) {
    print('🚀 Flutter API Model Generator');
    print('-----------------------------------------');

    final isGenerateCommand = arguments.contains('generate');
    final hasConfig = ConfigLoader.exists();

    // 1. Get JSON file path
    String? jsonPath;
    if (isGenerateCommand && hasConfig) {
      jsonPath = 'response.json'; // Default for generate command
    } else {
      stdout.write('Enter JSON file path (default: response.json): ');
      jsonPath = stdin.readLineSync()?.trim();
    }
    
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

    // 3. Handle Sync Option
    String? choice;
    if (isGenerateCommand && hasConfig) {
      choice = '1'; // Default to Model generation
      if (config.generateService) choice = '2';
      if (config.generateRepository) choice = '3';
    } else {
      print('\nWhat do you want to do?');
      print('1. Generate Model');
      print('2. Generate Model + Service');
      print('3. Generate Model + Service + Repository');
      print('4. Sync Existing Models');
      stdout.write('Choice (1-4, default: 1): ');
      choice = stdin.readLineSync()?.trim();
    }
    
    if (choice == null || choice.isEmpty) choice = '1';

    // 4. Handle Sync
    if (choice == '4') {
      _handleSync(json, jsonPath);
      return;
    }

    // 5. Get Model Name
    String? modelNameInput;
    if (isGenerateCommand && hasConfig) {
      // In config mode without prompt, we might need a way to know the model name.
      // Usually, config might specify a default or we can infer from filename?
      // The requirement didn't specify model_name in YAML.
      // Let's ask for it if not provided in arguments or something?
      // Actually, if it's "generate" command, maybe we should still ask for the name?
      // "Skip most prompts" - name is probably essential.
      stdout.write('Enter model name: ');
      modelNameInput = stdin.readLineSync()?.trim();
    } else {
      stdout.write('Enter model name: ');
      modelNameInput = stdin.readLineSync()?.trim();
    }

    if (modelNameInput == null || modelNameInput.isEmpty) {
      print('Model name is required!');
      return;
    }
    final modelName = StringUtils.capitalize(modelNameInput);

    // 6. Generate
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
      if (choice == '2' || choice == '3' || config.generateService) {
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
      if (choice == '3' || config.generateRepository) {
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
      print('Success! Generation complete.');
      print('-----------------------------------------');
    } catch (e) {
      print('Failed to generate: $e');
    }
  }

  void _handleSync(dynamic json, String jsonPath) {
     stdout.write('Enter existing model name to sync: ');
     final modelNameInput = stdin.readLineSync()?.trim();
     if (modelNameInput == null || modelNameInput.isEmpty) {
       print('Model name is required for sync!');
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
