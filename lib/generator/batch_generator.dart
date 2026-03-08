import 'dart:io';
import 'package:path/path.dart' as p;
import '../config/config_loader.dart';
import '../utils/string_utils.dart';
import '../cli/progress_indicator.dart';
import 'json_parser.dart';
import 'model_builder.dart';
import 'model_registry.dart';
import 'service_generator.dart';
import 'repository_generator.dart';
import '../writer/dart_writer.dart';

class BatchGenerator {
  final String folderPath;
  final GeneratorConfig config;
  final ProgressIndicator _progress = ProgressIndicator();

  int _modelsCreated = 0;
  int _modelsReused = 0;
  int _servicesCreated = 0;
  int _repositoriesCreated = 0;

  BatchGenerator(this.folderPath, this.config);

  void run() {
    final dir = Directory(folderPath);

    if (!dir.existsSync()) {
      print('Error: Folder does not exist at $folderPath');
      return;
    }

    _progress.start('Scanning for JSON files...');
    final files = dir.listSync().whereType<File>().where((file) => p.extension(file.path) == '.json').toList();

    if (files.isEmpty) {
      _progress.error('No JSON files found in $folderPath');
      return;
    }
    
    _progress.success('${files.length} JSON files detected');

    print('\n🚀 Batch generation started');
    print('-----------------------------------------');

    for (var file in files) {
      final fileName = p.basenameWithoutExtension(file.path);
      final modelName = StringUtils.capitalize(StringUtils.snakeToCamel(fileName));
      
      try {
        _progress.start('Processing: $fileName.json -> $modelName');
        final json = JsonParser.parseFile(file.path);
        _generateForFile(json, modelName);
        _progress.success('Generated: $modelName');
      } catch (e) {
        _progress.error('Failed to process ${file.path}: $e');
      }
    }

    _printSummary();
    _progress.printFinalSuccess('Batch generation complete');
  }

  void _generateForFile(dynamic json, String modelName) {
    final registry = ModelRegistry();
    final baseObject = JsonParser.extractBaseObject(json);
    final isList = json is List;

    // Models Generation
    final modelsOutputDir = config.modelsPath;
    final baseBuilder = ModelBuilder(modelName, baseObject, registry);
    final allModels = baseBuilder.getAllModels();

    for (var model in allModels) {
      if (registry.isProcessed(model.modelName)) {
        _modelsReused++;
        continue;
      }

      final fileName = StringUtils.camelToSnake(model.modelName);
      final fullPath = p.join(modelsOutputDir, '$fileName.dart');

      final code = model.build();
      DartWriter.write(fullPath, code);
      registry.markProcessed(model.modelName);
      _modelsCreated++;
    }

    final baseModelFileName = StringUtils.camelToSnake(modelName);

    // Service Generation
    if (config.generateService) {
      final serviceGen = ServiceGenerator(
        modelName: modelName,
        isList: isList,
        modelFileName: baseModelFileName,
      );
      final serviceCode = serviceGen.build();
      final serviceFileName = StringUtils.camelToSnake('${modelName}Service');
      DartWriter.write(p.join(config.servicesPath, '$serviceFileName.dart'), serviceCode);
      _servicesCreated++;
    }

    // Repository Generation
    if (config.generateRepository) {
      final repoGen = RepositoryGenerator(
        modelName: modelName,
        isList: isList,
        modelFileName: baseModelFileName,
      );
      final repoCode = repoGen.build();
      final repoFileName = StringUtils.camelToSnake('${modelName}Repository');
      DartWriter.write(p.join(config.repositoriesPath, '$repoFileName.dart'), repoCode);
      _repositoriesCreated++;
    }
  }

  void _printSummary() {
    _progress.printSummaryHeader();
    print('Models created:      $_modelsCreated');
    print('Models reused:       $_modelsReused');
    print('Services created:    $_servicesCreated');
    print('Repositories created: $_repositoriesCreated');
    print('-----------------------------------------');
  }
}
