import 'dart:io';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/ai_service.dart';
import '../services/ml_service.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final AIService _aiService = AIService();
  final MLService _mlService = MLService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;
  bool _isListening = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await _aiService.init();
    await _initTts();
    await _initSpeech();
    _addWelcomeMessage();
    setState(() {});
  }

  Future<void> _initSpeech() async {
    await _speech.initialize();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("ru-RU");
      await _flutterTts.setSpeechRate(0.6);
      await _flutterTts.setPitch(0.65);
      await _flutterTts.setVolume(1.0);
      print('✅ TTS инициализирован');
    } catch (e) {
      print('❌ TTS ошибка: $e');
    }
  }

  // ПРОСТАЯ ОЗВУЧКА
  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    print('🎤 Озвучиваю: $text');
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('❌ Ошибка: $e');
    }
  }

  void _addWelcomeMessage() async {
    final studentName = await _aiService.getStudentName();
    final msg = 'Привет, $studentName! Я твой помощник.';
    
    _messages.add(Message(role: 'assistant', content: msg, timestamp: DateTime.now()));
    _scrollToBottom();
    setState(() {});
    await _speak(msg);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(Message(role: 'user', content: text, timestamp: DateTime.now()));
    _controller.clear();
    setState(() => _isLoading = true);
    _scrollToBottom();

    final answer = await _aiService.askQuestion(text);
    
    _messages.add(Message(role: 'assistant', content: answer, timestamp: DateTime.now()));
    setState(() => _isLoading = false);
    _scrollToBottom();
    
    // ОЗВУЧКА ОТВЕТА
    await _speak(answer);
  }

  Future<void> _pickAndSendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    
    final File imageFile = File(image.path);
    
    _messages.add(Message(
      role: 'user',
      content: '📷 Отправлено фото',
      imagePath: imageFile.path,
      timestamp: DateTime.now(),
    ));
    setState(() => _isLoading = true);
    _scrollToBottom();

    try {
      final faceResult = await _mlService.detectFaces(imageFile);
      final ocrResult = await _mlService.recognizeText(imageFile);
      
      String analysis = 'Пользователь отправил фото. ';
      if (faceResult['success'] && faceResult['face_count'] > 0) {
        analysis += 'На фото обнаружено ${faceResult['face_count']} лиц. ';
      }
      if (ocrResult['success'] && ocrResult['text'] != null && ocrResult['text'].isNotEmpty) {
        analysis += 'На фото распознан текст: "${ocrResult['text']}". ';
      }
      analysis += 'Ответь пользователю.';
      
      final answer = await _aiService.askQuestion(analysis);
      
      _messages.add(Message(role: 'assistant', content: answer, timestamp: DateTime.now()));
      setState(() => _isLoading = false);
      _scrollToBottom();
      
      await _speak(answer);
    } catch (e) {
      final error = 'Не удалось проанализировать фото.';
      _messages.add(Message(role: 'assistant', content: error, timestamp: DateTime.now()));
      setState(() => _isLoading = false);
      _scrollToBottom();
      await _speak(error);
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Голосовой ввод не доступен')),
      );
      return;
    }

    setState(() => _isListening = true);

    _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          setState(() {
            _controller.text = result.recognizedWords;
            _isListening = false;
          });
          _sendTextMessage(_controller.text);
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      localeId: 'ru_RU',
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 48, bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple[900]!, Colors.deepPurple[800]!],
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.deepPurple.withOpacity(0.6), blurRadius: 20, spreadRadius: 5),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/avatar.gif',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.deepPurple[600],
                        child: const Icon(Icons.android, size: 60, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('AI Ассистент', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green[700], borderRadius: BorderRadius.circular(20)),
                  child: const Text('● В сети', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Ассистент печатает', style: TextStyle(color: Colors.deepPurple)),
                            SizedBox(width: 8),
                            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurple)),
                          ],
                        ),
                      ),
                    );
                  }
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
          ),
          
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.role == 'user';
    final timeFormat = DateFormat('HH:mm').format(message.timestamp);
    
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.deepPurple[400]!, Colors.deepPurple[600]!]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(message.content, style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 4),
              Text(timeFormat, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple),
            child: ClipOval(
              child: Image.asset(
                'assets/images/avatar.gif',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.android, size: 24, color: Colors.white),
              ),
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
                  ),
                  child: Text(message.content, style: const TextStyle(color: Colors.black87)),
                ),
                const SizedBox(height: 4),
                Text(timeFormat, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            GestureDetector(
              onTap: _isLoading ? null : _pickAndSendImage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.deepPurple[50], borderRadius: BorderRadius.circular(30)),
                child: Icon(Icons.image, color: Colors.deepPurple[400], size: 24),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isListening ? _stopListening : (_isLoading ? null : _startListening),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isListening ? Colors.red[50] : Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.red : Colors.deepPurple[400],
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(30)),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Напишите сообщение...', border: InputBorder.none),
                  onSubmitted: (_) => _sendTextMessage(_controller.text),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isLoading ? null : () => _sendTextMessage(_controller.text),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.deepPurple[500]!, Colors.deepPurple[700]!]),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}