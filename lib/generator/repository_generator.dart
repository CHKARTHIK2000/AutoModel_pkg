import '../utils/string_utils.dart';

class RepositoryGenerator {
  final String modelName;
  final bool isList;
  final String modelFileName;

  RepositoryGenerator({
    required this.modelName,
    required this.isList,
    required this.modelFileName,
  });

  /// Generates the repository class code
  String build() {
    final sb = StringBuffer();
    final repositoryName = '${modelName}Repository';
    final serviceName = '${modelName}Service';
    final methodName = isList ? 'get${modelName}List' : 'get$modelName';
    final fetchMethod = 'fetch$modelName';
    final returnType = isList ? 'List<$modelName>' : modelName;
    final serviceFileName = StringUtils.camelToSnake(serviceName);

    // 1. Imports
    sb.writeln("import '../services/$serviceFileName.dart';");
    sb.writeln("import '../models/$modelFileName.dart';");
    sb.writeln();

    // 2. Class Definition
    sb.writeln('class $repositoryName {');
    sb.writeln('  final $serviceName service = $serviceName();');
    sb.writeln();

    // 3. fetch method
    sb.writeln('  Future<$returnType> $methodName() {');
    sb.writeln('    return service.$fetchMethod();');
    sb.writeln('  }');

    sb.writeln('}');
    
    return sb.toString();
  }
}
