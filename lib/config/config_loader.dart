import 'dart:io';
import 'package:yaml/yaml.dart';

class GeneratorConfig {
  final String modelsPath;
  final String servicesPath;
  final String repositoriesPath;
  final bool generateService;
  final bool generateRepository;
  final String httpClient;

  GeneratorConfig({
    this.modelsPath = 'lib/models',
    this.servicesPath = 'lib/services',
    this.repositoriesPath = 'lib/repositories',
    this.generateService = false,
    this.generateRepository = false,
    this.httpClient = 'http',
  });

  factory GeneratorConfig.fromYaml(String yamlContent) {
    final yaml = loadYaml(yamlContent) as YamlMap?;
    if (yaml == null) return GeneratorConfig();

    final generate = yaml['generate'] as YamlMap?;

    return GeneratorConfig(
      modelsPath: yaml['models_path'] ?? 'lib/models',
      servicesPath: yaml['services_path'] ?? 'lib/services',
      repositoriesPath: yaml['repositories_path'] ?? 'lib/repositories',
      generateService: generate?['service'] ?? false,
      generateRepository: generate?['repository'] ?? false,
      httpClient: yaml['http_client'] ?? 'http',
    );
  }

  @override
  String toString() {
    return 'GeneratorConfig(modelsPath: $modelsPath, servicesPath: $servicesPath, repositoriesPath: $repositoriesPath, generateService: $generateService, generateRepository: $generateRepository, httpClient: $httpClient)';
  }
}

class ConfigLoader {
  static const String fileName = 'api_model_generator.yaml';

  /// Loads configuration from the YAML file if it exists.
  /// Returns a GeneratorConfig with default values if the file is missing or invalid.
  static GeneratorConfig load() {
    final file = File(fileName);
    if (!file.existsSync()) {
      return GeneratorConfig();
    }

    try {
      final content = file.readAsStringSync();
      return GeneratorConfig.fromYaml(content);
    } catch (e) {
      print('Warning: Failed to parse $fileName. Using default values.');
      print('Error: $e');
      return GeneratorConfig();
    }
  }

  /// Checks if the configuration file exists.
  static bool exists() => File(fileName).existsSync();
}
