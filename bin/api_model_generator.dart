import 'package:api_model_generator/cli/interactive_cli.dart';
import 'package:api_model_generator/config/config_loader.dart';

void main(List<String> arguments) {
  final config = ConfigLoader.load();
  final cli = InteractiveCLI(config);
  cli.start(arguments);
}
