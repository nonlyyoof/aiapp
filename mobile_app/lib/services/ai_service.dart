import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String baseUrl = 'http://127.0.0.1:8080/api';

  Future<String> askQuestion(String question) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ask'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': question}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['answer'] ?? 'Не удалось получить ответ';
      } else {
        return 'Ошибка: ${response.statusCode}';
      }
    } catch (e) {
      return 'Не удалось подключиться к серверу: $e';
    }
  }

  Future<Map<String, dynamic>> getModelInfo() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ai/model'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error getting model info: $e');
    }
    return {};
  }
}