import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/location.dart';

class ApiService {
  // Web/桌面用localhost，Android模拟器改为10.0.2.2，真机改为局域网IP
  static const String baseUrl = 'http://localhost:3000/api';

  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // 注册
  static Future<User> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data['user'], data['token']);
      _token = user.token;
      return user;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? '注册失败');
    }
  }

  // 登录
  static Future<User> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data['user'], data['token']);
      _token = user.token;
      return user;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? '登录失败');
    }
  }

  // 获取所有讲解点
  static Future<List<TourLocation>> getLocations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/locations'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TourLocation.fromJson(json)).toList();
    } else {
      throw Exception('获取讲解点失败');
    }
  }

  // 获取单个讲解点
  static Future<TourLocation> getLocation(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/locations/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return TourLocation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('获取讲解点详情失败');
    }
  }
}
