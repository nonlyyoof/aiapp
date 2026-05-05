import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  bool _isLoading = false;
  bool _isLoginMode = true;

  Future<void> _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _studentIdController.text.isEmpty) {
      _showError('Заполните все поля');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8080/api/student/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          'studentId': _studentIdController.text,
          'groupName': _groupController.text,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final studentId = data['student']['id'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('studentId', studentId);
          await prefs.setString('studentName', _nameController.text);
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            );
          }
        } else {
          _showError(data['message'] ?? 'Ошибка регистрации');
        }
      } else {
        _showError('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _login() async {
    if (_studentIdController.text.isEmpty) {
      _showError('Введите Student ID');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/api/student/list/all'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final students = data['students'] as List;
          final student = students.firstWhere(
            (s) => s['studentId'] == _studentIdController.text,
            orElse: () => null,
          );
          
          if (student != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('studentId', student['id']);
            await prefs.setString('studentName', student['name']);
            
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
            }
          } else {
            _showError('Студент с таким ID не найден');
          }
        }
      } else {
        _showError('Ошибка сервера');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    }
    
    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Вход в систему' : 'Регистрация студента'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 80, color: Colors.purple),
            const SizedBox(height: 32),
            
            if (!_isLoginMode) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ФИО',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _groupController,
                decoration: const InputDecoration(
                  labelText: 'Группа',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _isLoading ? null : (_isLoginMode ? _login : _register),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: _isLoading 
                  ? const CircularProgressIndicator()
                  : Text(_isLoginMode ? 'Войти' : 'Зарегистрироваться'),
            ),
            
            const SizedBox(height: 16),
            
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoginMode = !_isLoginMode;
                  _nameController.clear();
                  _groupController.clear();
                });
              },
              child: Text(_isLoginMode 
                  ? 'Нет аккаунта? Зарегистрироваться' 
                  : 'Уже есть аккаунт? Войти'),
            ),
          ],
        ),
      ),
    );
  }
}