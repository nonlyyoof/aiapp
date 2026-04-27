import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  
  TTSService() {
    _init();
  }
  
  Future<void> _init() async {
    await _flutterTts.setLanguage("ru-RU");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }
  
  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }
  
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}