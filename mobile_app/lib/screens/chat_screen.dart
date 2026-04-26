import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/ai_service.dart';
import '../services/ml_service.dart';
import '../models/message.dart';
import 'camera_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

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
  
  bool _isLoading = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _addWelcomeMessage();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize();
  }

  void _addWelcomeMessage() {
    _messages.add(Message(
      role: 'assistant',
      content: 'Привет! Я твой AI-ассистент. Я умею:\n'
               '• Отвечать на вопросы\n'
               '• Распознавать лица на фото\n'
               '• Читать текст с картинок\n\n'
               'Отправь фото или напиши сообщение!',
      timestamp: DateTime.now(),
    ));
    setState(() {});
  }

  Future<void> _sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(
        role: 'user',
        content: text,
        timestamp: DateTime.now(),
      ));
      _controller.clear();
      _isLoading = true;
    });

    final answer = await _aiService.askQuestion(text);

    setState(() {
      _messages.add(Message(
        role: 'assistant',
        content: answer,
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
    });
  }

  Future<void> _sendImageMessage(File imageFile) async {
    setState(() {
      _messages.add(Message(
        role: 'user',
        content: '📷 Отправлено фото',
        imagePath: imageFile.path,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    final analysis = await _analyzeImage(imageFile);
    String prompt = _buildAIPrompt(analysis);
    final answer = await _aiService.askQuestion(prompt);
    
    setState(() {
      _messages.add(Message(
        role: 'assistant',
        content: answer,
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
    });
  }

  Future<Map<String, dynamic>> _analyzeImage(File imageFile) async {
    Map<String, dynamic> result = {};
    
    try {
      final faceResult = await _mlService.detectFaces(imageFile);
      if (faceResult['success'] == true) {
        result['face_count'] = faceResult['face_count'] ?? 0;
        result['faces'] = faceResult['faces'] ?? [];
      } else {
        result['face_error'] = faceResult['error'] ?? 'Unknown error';
      }
    } catch (e) {
      result['face_error'] = e.toString();
    }
    
    try {
      final ocrResult = await _mlService.recognizeText(imageFile);
      if (ocrResult['success'] == true && ocrResult['text'] != null) {
        result['ocr_text'] = ocrResult['text'].trim();
      } else {
        result['ocr_error'] = ocrResult['error'] ?? 'No text recognized';
      }
    } catch (e) {
      result['ocr_error'] = e.toString();
    }
    
    return result;
  }

  String _buildAIPrompt(Map<String, dynamic> analysis) {
    String prompt = 'Пользователь отправил фото. ';
    
    if (analysis.containsKey('face_count') && analysis['face_count'] > 0) {
      prompt += 'На фото обнаружено ${analysis['face_count']} лиц. ';
    } else if (analysis.containsKey('face_error')) {
      prompt += 'Распознавание лиц не удалось: ${analysis['face_error']}. ';
    }
    
    if (analysis.containsKey('ocr_text') && analysis['ocr_text'].isNotEmpty) {
      prompt += 'На фото распознан текст: "${analysis['ocr_text']}". ';
    } else if (analysis.containsKey('ocr_error')) {
      prompt += 'Распознавание текста не удалось: ${analysis['ocr_error']}. ';
    }
    
    prompt += 'Ответь пользователю, основываясь на этой информации. '
              'Если есть текст на фото, прокомментируй его. '
              'Если есть лица, упомяни это. '
              'Если ничего не распознано, сообщи, что фото не удалось проанализировать.';
    
    return prompt;
  }


  void _startListening() async {
  // Для Web используем Web Speech API
    if (kIsWeb) {
      _startWebSpeech();
      return;
    }
  
  // Для Android/iOS
    bool available = await _speech.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );
  
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
            _isListening = false;
          });
          _sendTextMessage(_controller.text);
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 2),
        partialResults: true,
        localeId: 'ru_RU',
      );
    } else {
      _showSpeechError();
    }
  }

// Для Web используем Web Speech API
  void _startWebSpeech() {
  // @dart=2.9
  // ignore: undefined_prefixed_name
    final webSpeech = html.window.navigator;
  // ignore: undefined_prefixed_name
    if (webSpeech != null && webSpeech is html.WindowNavigator) {
    // ignore: undefined_prefixed_name
      final SpeechRecognition? speechRecognition = webSpeech.webkitSpeechRecognition;
      if (speechRecognition != null) {
        speechRecognition.lang = 'ru-RU';
        speechRecognition.interimResults = true;
        speechRecognition.maxAlternatives = 1;
      
        speechRecognition.onResult = (event) {
          final transcript = event.results[0][0].transcript;
          setState(() {
            _controller.text = transcript;
          });
          _sendTextMessage(transcript);
        };
      
        speechRecognition.onError = (event) {
          print('Speech error: $event');
          _showSpeechError();
        };
      
        speechRecognition.start();
        setState(() => _isListening = true);
      } else {
        _showSpeechError();
      }
    } else {
      _showSpeechError();
    }
  }

  void _showSpeechError() {
    ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(content: Text('Голосовой ввод не поддерживается в этом браузере')),
    );
  }

  Future<void> _openCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
    if (result != null && result is File) {
      await _sendImageMessage(result);
    }
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.role == 'user';
    
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (message.imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImageFromPath(message.imagePath!),
                  ),
                ),
              Text(message.content),
              const SizedBox(height: 4),
              Text(
                '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  'assets/images/avatar.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.android, size: 40, color: Colors.purple);
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message.content),
                    const SizedBox(height: 4),
                    Text(
                      '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildImageFromPath(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        return Image.memory(
          file.readAsBytesSync(),
          width: 200,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 200,
              height: 150,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 50),
            );
          },
        );
      }
    } catch (e) {
      print('Error loading image: $e');
    }
    return Container(
      width: 200,
      height: 150,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported, size: 50),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.green),
            onPressed: _isLoading ? null : _openCamera,
            tooltip: 'Открыть камеру',
          ),
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.red),
            onPressed: _isLoading ? null : _startListening,
            tooltip: 'Голосовой ввод',
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Напишите сообщение...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (_) => _sendTextMessage(_controller.text),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: _isLoading ? null : () => _sendTextMessage(_controller.text),
            tooltip: 'Отправить',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Ассистент', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () async {
              final modelInfo = await _aiService.getModelInfo();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Модель: ${modelInfo['model'] ?? 'недоступна'}')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 12),
                          Text('Ассистент думает...'),
                        ],
                      ),
                    ),
                  );
                }
                final message = _messages.reversed.toList()[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }
}