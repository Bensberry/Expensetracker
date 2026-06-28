import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';


/// Wrapper around Google ML Kit's text recognizer for on‑device OCR.
class OnDeviceOcrService {
  final TextRecognizer _recognizer = TextRecognizer();

  /// Extract plain text from an image file (photo or screenshot).
  Future<String> extractText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _recognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('OCR error: $e');
      rethrow;
    }
  }

  void dispose() => _recognizer.close();
}
