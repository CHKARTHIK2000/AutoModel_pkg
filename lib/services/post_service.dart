import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class PostService {

  Future<List<Post>> fetchPost() async {
    final response = await http.get(Uri.parse("API_URL"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((i) => Post.fromJson(i)).toList();
    } else {
      throw Exception("Failed to load Post");
    }
  }
}
