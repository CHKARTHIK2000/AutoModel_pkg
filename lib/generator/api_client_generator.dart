import '../config/config_loader.dart';
import '../utils/string_utils.dart';

class ApiClientGenerator {
  final GeneratorConfig config;

  ApiClientGenerator(this.config);

  String build() {
    final sb = StringBuffer();
    final isDio = config.httpClient == 'dio';

    // 1. Imports
    sb.writeln("import 'dart:convert';");
    if (isDio) {
      sb.writeln("import 'package:dio/dio.dart';");
    } else {
      sb.writeln("import 'package:http/http.dart' as http;");
    }

    // Import models
    final modelsToImport = <String>{};
    for (var endpoint in config.endpoints) {
      modelsToImport.add(StringUtils.camelToSnake(endpoint.responseModel));
      if (endpoint.requestModel != null) {
        modelsToImport.add(StringUtils.camelToSnake(endpoint.requestModel!));
      }
    }

    for (var modelFile in modelsToImport) {
      sb.writeln("import '../models/$modelFile.dart';");
    }
    sb.writeln();

    // 2. Class Definition
    sb.writeln('class ApiClient {');
    if (isDio) {
      sb.writeln('  final Dio dio;');
    }
    sb.writeln('  final String baseUrl;');
    sb.writeln();
    
    if (isDio) {
      sb.writeln('  ApiClient(this.baseUrl) : dio = Dio(BaseOptions(baseUrl: baseUrl));');
    } else {
      sb.writeln('  ApiClient(this.baseUrl);');
    }
    sb.writeln();

    // 3. Methods for each endpoint
    for (var endpoint in config.endpoints) {
      _buildMethod(sb, endpoint, isDio);
    }

    sb.writeln('}');
    return sb.toString();
  }

  void _buildMethod(StringBuffer sb, ApiEndpoint endpoint, bool isDio) {
    final responseType = endpoint.responseType == 'list' 
        ? 'List<${endpoint.responseModel}>' 
        : endpoint.responseModel;
    
    final params = endpoint.requestModel != null 
        ? '${endpoint.requestModel} ${StringUtils.snakeToCamel(endpoint.requestModel!.toLowerCase())}' 
        : '';

    sb.writeln('  Future<$responseType> ${endpoint.name}($params) async {');

    if (isDio) {
      _buildDioCall(sb, endpoint);
    } else {
      _buildHttpCall(sb, endpoint);
    }

    sb.writeln('  }');
    sb.writeln();
  }

  void _buildHttpCall(StringBuffer sb, ApiEndpoint endpoint) {
    final method = endpoint.method.toLowerCase();
    final url = 'Uri.parse("\$baseUrl${endpoint.path}")';
    
    if (method == 'get') {
      sb.writeln('    final response = await http.get($url);');
    } else if (method == 'post') {
      final bodyParam = endpoint.requestModel != null 
          ? StringUtils.snakeToCamel(endpoint.requestModel!.toLowerCase())
          : null;
      final body = bodyParam != null ? ', body: jsonEncode($bodyParam.toJson())' : '';
      sb.writeln('    final response = await http.post($url$body);');
    }

    sb.writeln();
    sb.writeln('    if (response.statusCode >= 200 && response.statusCode < 300) {');
    sb.writeln('      final data = jsonDecode(response.body);');
    
    if (endpoint.responseType == 'list') {
      sb.writeln('      return (data as List).map((e) => ${endpoint.responseModel}.fromJson(e)).toList();');
    } else {
      sb.writeln('      return ${endpoint.responseModel}.fromJson(data);');
    }
    
    sb.writeln('    } else {');
    sb.writeln('      throw Exception("Failed ${endpoint.name}: \${response.statusCode}");');
    sb.writeln('    }');
  }

  void _buildDioCall(StringBuffer sb, ApiEndpoint endpoint) {
    final method = endpoint.method.toLowerCase();
    final path = '"${endpoint.path}"';
    
    if (method == 'get') {
      sb.writeln('    final response = await dio.get($path);');
    } else if (method == 'post') {
      final bodyParam = endpoint.requestModel != null 
          ? StringUtils.snakeToCamel(endpoint.requestModel!.toLowerCase())
          : null;
      final data = bodyParam != null ? ', data: $bodyParam.toJson()' : '';
      sb.writeln('    final response = await dio.post($path$data);');
    }

    sb.writeln();
    sb.writeln('    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {');
    sb.writeln('      final data = response.data;');
    
    if (endpoint.responseType == 'list') {
      sb.writeln('      return (data as List).map((e) => ${endpoint.responseModel}.fromJson(e)).toList();');
    } else {
      sb.writeln('      return ${endpoint.responseModel}.fromJson(data);');
    }
    
    sb.writeln('    } else {');
    sb.writeln('      throw Exception("Failed ${endpoint.name}: \${response.statusCode}");');
    sb.writeln('    }');
  }
}
