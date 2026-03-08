import 'package:api_model_generator/cli/command_handler.dart';

void main(List<String> arguments) {
  final handler = CommandHandler(arguments);
  handler.handle();
}
