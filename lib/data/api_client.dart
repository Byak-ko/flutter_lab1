import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';
import '../models/user.dart';

class JsonPlaceholderApi {
  JsonPlaceholderApi({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  final http.Client _client;

  Future<List<User>> fetchUsers() async =>
      (await _getList('/users')).map(User.fromJson).toList();

  Future<List<Post>> fetchPosts() async =>
      (await _getList('/posts')).map(Post.fromJson).toList();

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    final response = await _client
        .get(Uri.parse('$baseUrl$path'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw http.ClientException(
        'HTTP ${response.statusCode} for $path',
        response.request?.url,
      );
    }
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }
}
