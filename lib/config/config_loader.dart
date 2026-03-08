import 'dart:io';
import 'package:yaml/yaml.dart';

class ApiEndpoint {
  final String name;
  final String method;
  final String path;
  final String? requestModel;
  final String responseModel;
  final String responseType; // 'object' or 'list'

  ApiEndpoint({
    required this.name,
    required this.method,
    required this.path,
    this.requestModel,
    required this.responseModel,
    required this.responseType,
  });

  factory ApiEndpoint.fromYaml(YamlMap map) {
    return ApiEndpoint(
      name: map['name'],
      method: map['method'],
      path: map['path'],
      requestModel: map['request_model'],
      responseModel: map['response_model'],
      responseType: map['response_type'] ?? 'object',
    );
  }
}

class GeneratorConfig {
  final String modelsPath;
  final String servicesPath;
  final String repositoriesPath;
  final String apiPath;
  final bool generateService;
  final bool generateRepository;
  final String httpClient;
  final String? baseUrl;
  final List<ApiEndpoint> endpoints;

  GeneratorConfig({
    this.modelsPath = 'lib/models',
    this.servicesPath = 'lib/services',
    this.repositoriesPath = 'lib/repositories',
    this.apiPath = 'lib/api',
    this.generateService = false,
    this.generateRepository = false,
    this.httpClient = 'http',
    this.baseUrl,
    this.endpoints = const [],
  });

  factory GeneratorConfig.fromYaml(String yamlContent) {
    final yaml = loadYaml(yamlContent) as YamlMap?;
    if (yaml == null) return GeneratorConfig();

    final generate = yaml['generate'] as YamlMap?;
    final api = yaml['api'] as YamlMap?;
    final endpointsYaml = yaml['endpoints'] as YamlList?;
    
    final endpointList = <ApiEndpoint>[];
    if (endpointsYaml != null) {
      for (var item in endpointsYaml) {
        if (item is YamlMap) {
          endpointList.add(ApiEndpoint.fromYaml(item));
        }
      }
    }

    return GeneratorConfig(
      modelsPath: yaml['models_path'] ?? 'lib/models',
      servicesPath: yaml['services_path'] ?? 'lib/services',
      repositoriesPath: yaml['repositories_path'] ?? 'lib/repositories',
      apiPath: yaml['api_path'] ?? 'lib/api',
      generateService: generate?['service'] ?? false,
      generateRepository: generate?['repository'] ?? false,
      httpClient: yaml['http_client'] ?? 'http',
      baseUrl: api?['base_url'],
      endpoints: endpointList,
    );
  }

  @override
  String toString() {
    return 'GeneratorConfig(modelsPath: $modelsPath, servicesPath: $servicesPath, repositoriesPath: $repositoriesPath, apiPath: $apiPath, generateService: $generateService, generateRepository: $generateRepository, httpClient: $httpClient, baseUrl: $baseUrl, endpoints: ${endpoints.length})';
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
