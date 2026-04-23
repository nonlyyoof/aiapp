import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/ai_service.dart';
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
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isLoading = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _addWelcomeMessage();
  }

  void _initSpeech() async {
    await _speech.initialize();
  }

  void _addWelcomeMessage() {
    _messages.add(Message(
      role: 'assistant',
      content: 'Привет! Я твой AI-ассистент. Спрашивай о чём хочешь, я помогу с расписанием и отвечу на любые вопросы!',
      timestamp: DateTime.now(),
    ));
    setState(() {});
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Добавляем сообщение пользователя
    setState(() {
      _messages.add(Message(
        role: 'user',
        content: text,
        timestamp: DateTime.now(),
      ));
      _controller.clear();
      _isLoading = true;
    });

    // Получаем ответ от API
    final answer = await _aiService.askQuestion(text);

    // Добавляем ответ ассистента
    setState(() {
      _messages.add(Message(
        role: 'assistant',
        content: answer,
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
            _isListening = false;
          });
          _sendMessage(_controller.text);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Ассистент'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // История сообщений
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final message = _messages.reversed.toList()[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          // Поле ввода
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
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
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            onPressed: _startListening,
            color: _isListening ? Colors.red : null,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Спросить...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendMessage(_controller.text),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }
}