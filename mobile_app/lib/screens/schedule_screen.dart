import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  Map<String, dynamic> _currentLesson = {};
  Map<String, dynamic> _nextLesson = {};
  bool _isLoading = true;
  int? _studentId;
  String? _studentName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _studentId = prefs.getInt('studentId');
    _studentName = prefs.getString('studentName');
    
    if (_studentId != null) {
      await Future.wait([
        _fetchCurrentLesson(),
        _fetchNextLesson(),
      ]);
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _fetchCurrentLesson() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/api/student/$_studentId/schedule/current'),
      );
      if (response.statusCode == 200) {
        setState(() => _currentLesson = jsonDecode(response.body));
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchNextLesson() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/api/student/$_studentId/schedule/next'),
      );
      if (response.statusCode == 200) {
        setState(() => _nextLesson = jsonDecode(response.body));
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Моё расписание'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _isLoading = true);
          await _loadData();
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Приветствие
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '👋 $_studentName',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('EEEE, d MMMM', 'ru').format(DateTime.now()),
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Текущая пара
                    const Text(
                      '🔴 ТЕКУЩАЯ ПАРА',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      color: _currentLesson['hasLesson'] == true 
                          ? Colors.green[50] 
                          : Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _currentLesson['hasLesson'] == true
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentLesson['subject'] ?? '—',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16),
                                      const SizedBox(width: 4),
                                      Text('Аудитория ${_currentLesson['room'] ?? '?'}'),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.access_time, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${_currentLesson['startTime']} - ${_currentLesson['endTime']}'),
                                    ],
                                  ),
                                  if (_currentLesson.containsKey('teacher'))
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.person, size: 16),
                                          const SizedBox(width: 4),
                                          Text(_currentLesson['teacher']),
                                        ],
                                      ),
                                    ),
                                ],
                              )
                            : const Text('😊 Сейчас нет пар, можно отдохнуть!'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Следующая пара
                    const Text(
                      '⏰ СЛЕДУЮЩАЯ ПАРА',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _nextLesson['hasNext'] == true
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _nextLesson['subject'] ?? '—',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16),
                                      const SizedBox(width: 4),
                                      Text('Аудитория ${_nextLesson['room'] ?? '?'}'),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.access_time, size: 16),
                                      const SizedBox(width: 4),
                                      Text('в ${_nextLesson['startTime']}'),
                                    ],
                                  ),
                                ],
                              )
                            : const Text('✅ На сегодня пар больше нет!'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Расписание на неделю (заглушка, потом заменишь)
                    const Text(
                      '📅 РАСПИСАНИЕ НА НЕДЕЛЮ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildWeekRow('ПН', 'Математика, Физика'),
                            const Divider(),
                            _buildWeekRow('ВТ', 'Английский, Базы данных'),
                            const Divider(),
                            _buildWeekRow('СР', 'Математика, Физика'),
                            const Divider(),
                            _buildWeekRow('ЧТ', 'Английский, Базы данных'),
                            const Divider(),
                            _buildWeekRow('ПТ', 'Математика, Физика'),
                            const Divider(),
                            _buildWeekRow('СБ', 'Выходной', isWeekend: true),
                            const Divider(),
                            _buildWeekRow('ВС', 'Выходной', isWeekend: true),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWeekRow(String day, String subjects, {bool isWeekend = false}) {
    final isToday = DateFormat('EEEE', 'ru').format(DateTime.now()).startsWith(
      day == 'ПН' ? 'понедельник' :
      day == 'ВТ' ? 'вторник' :
      day == 'СР' ? 'среда' :
      day == 'ЧТ' ? 'четверг' :
      day == 'ПТ' ? 'пятница' :
      day == 'СБ' ? 'суббота' : 'воскресенье'
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isWeekend 
                  ? Colors.grey[300] 
                  : (isToday ? Colors.purple : Colors.blue[100]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Colors.white : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subjects,
              style: TextStyle(
                color: isWeekend ? Colors.grey : null,
                decoration: isWeekend ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}