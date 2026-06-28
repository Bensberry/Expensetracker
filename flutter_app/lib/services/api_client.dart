import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import 'auth_service.dart';

class ApiClient {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return http.get(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return http.post(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 90));
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return http.put(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return http.delete(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));
  }

  Future<http.StreamedResponse> postMultipart(
      String endpoint, String filePath) async {
    final token = await AuthService().getToken();
    final request = http.MultipartRequest(
        'POST', Uri.parse('${AppConstants.baseUrl}$endpoint'));
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    return request.send().timeout(const Duration(seconds: 90));
  }
}
