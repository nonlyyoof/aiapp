import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AIService {
  static const String baseUrl = 'http://127.0.0.1:8080/api';
  
  int? _currentStudentId;
  String? _studentName;
  String? _groupName;
  
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStudentId = prefs.getInt('studentId');
    _studentName = prefs.getString('studentName');
    _groupName = prefs.getString('groupName');
  }
  
  Future<void> setStudentId(int id, String name, String group) async {
    _currentStudentId = id;
    _studentName = name;
    _groupName = group;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('studentId', id);
    await prefs.setString('studentName', name);
    await prefs.setString('groupName', group);
  }
  
  Future<String> getStudentName() async {
    if (_studentName == null) {
      final prefs = await SharedPreferences.getInstance();
      _studentName = prefs.getString('studentName');
    }
    return _studentName ?? 'Студент';
  }
  
  Future<Map<String, dynamic>> getCurrentLesson() async {
    if (_currentStudentId == null) {
      return {'hasLesson': false, 'message': 'Студент не идентифицирован'};
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/${_currentStudentId}/schedule/current'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error getting current lesson: $e');
    }
    return {'hasLesson': false, 'message': 'Не удалось получить расписание'};
  }
  
  Future<Map<String, dynamic>> getNextLesson() async {
    if (_currentStudentId == null) {
      return {'hasNext': false, 'message': 'Студент не идентифицирован'};
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/${_currentStudentId}/schedule/next'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error getting next lesson: $e');
    }
    return {'hasNext': false, 'message': 'Не удалось получить расписание'};
  }
  
  Future<String> askQuestion(String question) async {
    try {
      // Получаем контекст расписания
      String context = '';
      
      final currentLesson = await getCurrentLesson();
      if (currentLesson['hasLesson'] == true) {
        context += 'Сейчас у студента пара: ${currentLesson['subject']} в аудитории ${currentLesson['room']}. ';
      }
      
      final nextLesson = await getNextLesson();
      if (nextLesson['hasNext'] == true) {
        context += 'Следующая пара: ${nextLesson['subject']} в ${nextLesson['startTime']} в аудитории ${nextLesson['room']}. ';
      }
      
      // Если спросили про расписание
      bool isScheduleQuestion = question.toLowerCase().contains('пара') ||
                                question.toLowerCase().contains('расписание') ||
                                question.toLowerCase().contains('урок') ||
                                question.toLowerCase().contains('занятие') ||
                                question.toLowerCase().contains('аудитор');
      
      String fullQuestion;
      if (isScheduleQuestion && context.isNotEmpty) {
        fullQuestion = 'Контекст расписания: $context\n\nВопрос студента: $question\n\nОтветь, используя контекст расписания.';
      } else {
        fullQuestion = question;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/ask'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': fullQuestion}),
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