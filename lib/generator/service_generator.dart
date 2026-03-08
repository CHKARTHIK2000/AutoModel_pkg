import '../utils/string_utils.dart';

class ServiceGenerator {
  final String modelName;
  final bool isList;
  final String modelFileName;

  ServiceGenerator({
    required this.modelName,
    required this.isList,
    required this.modelFileName,
  });

  /// Generates the service class code
  String build() {
    final sb = StringBuffer();
    final serviceName = '${modelName}Service';
    final methodName = 'fetch$modelName';
    final returnType = isList ? 'List<$modelName>' : modelName;

    // 1. Imports
    sb.writeln("import 'dart:convert';");
    sb.writeln("import 'package:http/http.dart' as http;");
    sb.writeln("import '../models/$modelFileName.dart';");
    sb.writeln();

    // 2. Class Definition
    sb.writeln('class $serviceName {');
    sb.writeln();

    // 3. fetch method
    sb.writeln('  Future<$returnType> $methodName() async {');
    sb.writeln('    final response = await http.get(Uri.parse("API_URL"));');
    sb.writeln();
    sb.writeln('    if (response.statusCode == 200) {');
    sb.writeln('      final data = jsonDecode(response.body);');
    if (isList) {
      sb.writeln('      return (data as List).map((i) => $modelName.fromJson(i)).toList();');
    } else {
      sb.writeln('      return $modelName.fromJson(data);');
    }
    sb.writeln('    } else {');
    sb.writeln('      throw Exception("Failed to load $modelName");');
    sb.writeln('    }');
    sb.writeln('  }');

    sb.writeln('}');
    
    return sb.toString();
  }
}
