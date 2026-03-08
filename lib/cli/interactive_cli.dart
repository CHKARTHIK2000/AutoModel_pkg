import 'dart:io';
import '../generator/json_parser.dart';
import '../generator/model_builder.dart';
import '../generator/model_registry.dart';
import '../generator/service_generator.dart';
import '../generator/repository_generator.dart';
import '../generator/api_client_generator.dart';
import '../generator/batch_generator.dart';
import '../generator/model_sync.dart';
import '../config/config_loader.dart';
import '../writer/dart_writer.dart';
import '../utils/string_utils.dart';
import 'progress_indicator.dart';
import 'package:path/path.dart' as p;

class InteractiveCLI {
  final GeneratorConfig config;
  final ProgressIndicator _progress = ProgressIndicator();

  InteractiveCLI(this.config);

  /// Default interactive mode
  void startInteractive() {
    print('🚀 Flutter API Model Generator');
    print('-----------------------------------------');

    // Menu
    print('\nWhat do you want to do?');
    print('1. Generate Model');
    print('2. Generate Model + Service');
    print('3. Generate Model + Service + Repository');
    print('4. Generate API Client (from config)');
    print('5. Batch Generate from Folder');
    print('6. Sync Existing Models');
    stdout.write('Choice (1-6, default: 1): ');
    String? choiceInput = stdin.readLineSync()?.trim();
    if (choiceInput == null || choiceInput.isEmpty) choiceInput = '1';

    if (choiceInput == '4') {
      startApiGenerate();
      return;
    }

    if (choiceInput == '5') {
      stdout.write('Enter folder path: ');
      String? folderPath = stdin.readLineSync()?.trim();
      if (folderPath == null || folderPath.isEmpty) {
        print('Error: Folder path is required!');
        return;
      }
      startBatch(folderPath);
      return;
    }

    // 1. Get JSON file path
    stdout.write('Enter JSON file path (default: response.json): ');
    String? jsonPath = stdin.readLineSync()?.trim();
    if (jsonPath == null || jsonPath.isEmpty) {
      jsonPath = 'response.json';
    }

    // 2. Parse JSON
    dynamic json;
    try {
      _progress.start('Reading JSON file...');
      json = JsonParser.parseFile(jsonPath);
      _progress.success('JSON file detected: $jsonPath');
    } catch (e) {
      _progress.error('Error: $e');
      return;
    }

    if (choiceInput == '6') {
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

    _runGeneration(json, modelName, choiceInput, false);
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
      _progress.start('Parsing $jsonPath...');
      json = JsonParser.parseFile(jsonPath);
      _progress.success('$jsonPath parsed');
    } catch (e) {
      _progress.error('Error parsing $jsonPath: $e');
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

  /// API Client Generation
  void startApiGenerate() {
    print('🚀 Generating API Client...');
    
    if (config.endpoints.isEmpty) {
      print('Error: No endpoints defined in api_model_generator.yaml');
      return;
    }

    try {
      _progress.start('Building API Client...');
      final apiGenerator = ApiClientGenerator(config);
      final code = apiGenerator.build();
      final fullPath = p.join(config.apiPath, 'api_client.dart');
      
      DartWriter.write(fullPath, code);
      _progress.success('API Client generated at $fullPath');
      
      print('-----------------------------------------');
      _progress.printFinalSuccess('API Client generation complete.');
      print('-----------------------------------------');
    } catch (e) {
      _progress.error('Failed to generate API Client: $e');
    }
  }

  /// Batch Generation
  void startBatch(String folderPath) {
    final batchGen = BatchGenerator(folderPath, config);
    batchGen.run();
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
      _progress.start('Reading $jsonPath...');
      json = JsonParser.parseFile(jsonPath);
      _progress.success('$jsonPath loaded');
    } catch (e) {
      _progress.error('Error parsing $jsonPath: $e');
      return;
    }

    _handleSync(json);
  }

  void _runGeneration(dynamic json, String modelName, String choice, bool useConfig) {
    int modelsCreated = 0;
    int modelsReused = 0;
    int servicesCreated = 0;
    int repositoriesCreated = 0;

    try {
      _progress.start('Generating models...');
      final registry = ModelRegistry();
      final baseObject = JsonParser.extractBaseObject(json);
      final isList = json is List;
      
      // Models Generation
      final modelsOutputDir = config.modelsPath;
      final baseBuilder = ModelBuilder(modelName, baseObject, registry);
      final allModels = baseBuilder.getAllModels();
      
      for (var model in allModels) {
        if (registry.isProcessed(model.modelName)) {
          modelsReused++;
          continue;
        }
        
        final fileName = StringUtils.camelToSnake(model.modelName);
        final fullPath = p.join(modelsOutputDir, '$fileName.dart');
        
        final code = model.build();
        DartWriter.write(fullPath, code);
        registry.markProcessed(model.modelName);
        _progress.info('${model.modelName} model generated');
        modelsCreated++;
      }
      _progress.success('Model generation complete');

      final baseModelFileName = StringUtils.camelToSnake(modelName);

      // Service Generation
      if (choice == '2' || choice == '3' || (useConfig && config.generateService)) {
        _progress.start('Generating service...');
        final serviceGen = ServiceGenerator(
          modelName: modelName,
          isList: isList,
          modelFileName: baseModelFileName,
        );
        final serviceCode = serviceGen.build();
        final serviceFileName = StringUtils.camelToSnake('${modelName}Service');
        DartWriter.write(p.join(config.servicesPath, '$serviceFileName.dart'), serviceCode);
        _progress.success('Service generated');
        servicesCreated++;
      }

      // Repository Generation
      if (choice == '3' || (useConfig && config.generateRepository)) {
        _progress.start('Generating repository...');
        final repoGen = RepositoryGenerator(
          modelName: modelName,
          isList: isList,
          modelFileName: baseModelFileName,
        );
        final repoCode = repoGen.build();
        final repoFileName = StringUtils.camelToSnake('${modelName}Repository');
        DartWriter.write(p.join(config.repositoriesPath, '$repoFileName.dart'), repoCode);
        _progress.success('Repository generated');
        repositoriesCreated++;
      }

      _progress.printSummaryHeader();
      print('Models created:      $modelsCreated');
      print('Models reused:       $modelsReused');
      print('Services created:    $servicesCreated');
      print('Repositories created: $repositoriesCreated');
      print('-----------------------------------------');
      _progress.printFinalSuccess('Generation complete.');
    } catch (e) {
      _progress.error('Failed to generate: $e');
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
