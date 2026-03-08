import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/config_user.dart';

class ConfigUserService {

  Future<ConfigUser> fetchConfigUser() async {
    final response = await http.get(Uri.parse("API_URL"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ConfigUser.fromJson(data);
    } else {
      throw Exception("Failed to load ConfigUser");
    }
  }
}
