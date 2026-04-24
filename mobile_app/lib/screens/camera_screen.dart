import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ml_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  File? _capturedImage;
  Uint8List? _capturedImageBytes;
  String _result = '';
  final MLService _mlService = MLService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    try {
      final image = await _controller!.takePicture();
      final file = File(image.path);
      if (mounted) {
        setState(() {
          _capturedImage = file;
          _capturedImageBytes = file.readAsBytesSync();
          _result = '';
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      
      if (picked != null && mounted) {
        final file = File(picked.path);
        setState(() {
          _capturedImage = file;
          _capturedImageBytes = file.readAsBytesSync();
          _result = '';
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_capturedImage == null) return;
    
    setState(() {
      _isProcessing = true;
      _result = 'Анализ...';
    });
    
    try {
      final result = await _mlService.analyzeImage(_capturedImage!);
      
      if (mounted) {
        if (result['success'] == true) {
          final faceCount = result['face_count'] ?? 0;
          final text = result['text'] ?? '';
          
          String analysisResult = '';
          if (faceCount > 0) {
            analysisResult += '👤 Найдено лиц: $faceCount\n';
          } else {
            analysisResult += '👤 Лиц не обнаружено\n';
          }
          
          if (text.isNotEmpty) {
            analysisResult += '\n📝 Распознанный текст:\n$text';
          } else {
            analysisResult += '\n📝 Текст не обнаружен';
          }
          
          setState(() {
            _result = analysisResult;
          });
        } else {
          setState(() {
            _result = 'Ошибка: ${result['error']}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = 'Ошибка: $e';
        });
      }
    }
    
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _sendToChat() {
    if (_capturedImage != null && mounted) {
      Navigator.pop(context, _capturedImage);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📷 Камера и анализ'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          if (_capturedImage != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() {
                _capturedImage = null;
                _capturedImageBytes = null;
                _result = '';
              }),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: _capturedImage != null && _capturedImageBytes != null
                  ? Image.memory(_capturedImageBytes!, fit: BoxFit.contain)
                  : (_controller != null && _controller!.value.isInitialized
                      ? CameraPreview(_controller!)
                      : const Center(
                          child: Text(
                            'Камера не доступна',
                            style: TextStyle(color: Colors.white),
                          ),
                        )),
            ),
          ),
          
          if (_result.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _result,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Снять'),
                ),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Галерея'),
                ),
                ElevatedButton.icon(
                  onPressed: _capturedImage == null || _isProcessing ? null : _analyzeImage,
                  icon: _isProcessing 
                      ? const SizedBox(width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.analytics),
                  label: const Text('Анализ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (_capturedImage != null)
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _sendToChat,
                    icon: const Icon(Icons.send),
                    label: const Text('В чат'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}