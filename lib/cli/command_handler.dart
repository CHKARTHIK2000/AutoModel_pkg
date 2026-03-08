import 'dart:io';
import 'package:args/args.dart';
import '../config/config_loader.dart';
import 'interactive_cli.dart';
import '../writer/dart_writer.dart';

class CommandHandler {
  final List<String> arguments;
  late final ArgParser _parser;

  CommandHandler(this.arguments) {
    _parser = _createParser();
  }

  ArgParser _createParser() {
    final parser = ArgParser();
    
    // Commands
    parser.addCommand('generate');
    parser.addCommand('g'); // Alias for generate
    
    parser.addCommand('sync');
    parser.addCommand('s'); // Alias for sync
    
    parser.addCommand('interactive');
    parser.addCommand('i'); // Alias for interactive
    
    parser.addCommand('api');
    parser.addCommand('a'); // Alias for api
    
    parser.addCommand('batch');
    parser.addCommand('b'); // Alias for batch
    
    parser.addCommand('init');
    parser.addCommand('help');
    
    // Options
    parser.addFlag('help', abbr: 'h', negatable: false, help: 'Show help information');
    parser.addFlag('version', abbr: 'v', negatable: false, help: 'Show version information');
    
    return parser;
  }

  void handle() {
    try {
      final results = _parser.parse(arguments);

      if (results['help'] || (results.command?.name == 'help')) {
        _printHelp();
        return;
      }

      if (results['version']) {
        _printVersion();
        return;
      }

      final command = results.command?.name;
      final config = ConfigLoader.load();
      final cli = InteractiveCLI(config);

      switch (command) {
        case 'generate':
        case 'g':
          cli.startGenerate();
          break;
        case 'sync':
        case 's':
          cli.startSync();
          break;
        case 'interactive':
        case 'i':
          cli.startInteractive();
          break;
        case 'api':
        case 'a':
          cli.startApiGenerate();
          break;
        case 'batch':
        case 'b':
          final rest = results.command!.rest;
          if (rest.isEmpty) {
            print('Error: Please provide a folder path for batch generation.');
            print('Usage: amg batch <folder_path>');
            return;
          }
          cli.startBatch(rest.first);
          break;
        case 'init':
          _handleInit();
          break;
        case 'version':
          _printVersion();
          break;
        default:
          // Default to interactive if no command or empty arguments
          cli.startInteractive();
          break;
      }
    } catch (e) {
      print('Error parsing arguments: $e');
      _printHelp();
    }
  }

  void _handleInit() {
    const yamlContent = '''models_path: lib/models
services_path: lib/services
repositories_path: lib/repositories

generate:
  service: true
  repository: true

http_client: http

api:
  base_url: https://api.example.com

endpoints:
  - name: getUsers
    method: GET
    path: /users
    response_model: User
    response_type: list
''';
    
    final file = File('api_model_generator.yaml');
    if (file.existsSync()) {
      print('api_model_generator.yaml already exists.');
    } else {
      DartWriter.write('api_model_generator.yaml', yamlContent);
      print('✔ Default configuration file created: api_model_generator.yaml');
    }
  }

  void _printHelp() {
    print('Usage: amg <command> [options]');
    print('\nCommands:');
    print('  generate (g)       Generate models/services using config file');
    print('  sync (s)           Sync existing models with JSON response');
    print('  interactive (i)    Start interactive CLI mode');
    print('  api (a)            Generate API client from config endpoints');
    print('  batch (b)          Generate models from a folder of JSON files');
    print('  init               Create configuration file');
    print('  help               Show help information');
    print('  version            Show CLI version');
    print('\nOptions:');
    print(_parser.usage);
  }

  void _printVersion() {
    try {
      final file = File('pubspec.yaml');
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final match = RegExp(r'version:\s*([\d\.\+\-]+)').firstMatch(content);
        if (match != null) {
          print('api_model_generator version: ${match.group(1)}');
          return;
        }
      }
    } catch (_) {}
    print('api_model_generator version: 1.0.0');
  }
}
