import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {

  Future<User> fetchUser() async {
    final response = await http.get(Uri.parse("API_URL"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception("Failed to load User");
    }
  }
}
