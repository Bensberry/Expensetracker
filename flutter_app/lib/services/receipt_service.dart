import 'dart:io';
import 'dart:convert';
import '../models/expense.dart';
import '../services/on_device_ocr_service.dart';
import '../services/image_preprocessor.dart';

import '../services/api_client.dart';

class ReceiptUploadResult {
  final bool success;
  final String message;
  final List<Expense> expenses;

  ReceiptUploadResult(this.success, this.message, this.expenses);
}

class ReceiptService {
  final OnDeviceOcrService _ocr = OnDeviceOcrService();
  final ImagePreprocessor _preprocessor = ImagePreprocessor();

  /// Processes a receipt image locally via ML Kit OCR, forwards raw text to the ASP.NET
  /// backend for Grok AI extraction, and then saves the structured JSON locally on the phone.
  Future<ReceiptUploadResult> uploadReceipt(String filePath) async {
    final originalFile = File(filePath);
    // Preprocess image to improve OCR accuracy
    final processedFile = await _preprocessor.preprocess(originalFile);
    try {
      String text = await _ocr.extractText(processedFile);
      // If OCR result is suspiciously short, try the original image before failing
      if (text.trim().length < 20) {
        text = await _ocr.extractText(originalFile);
        if (text.trim().length < 20) {
          return ReceiptUploadResult(false, 'Image unclear, please provide a clearer picture.', []);
        }
      }

      // Forward raw OCR text to ASP.NET backend for Grok AI extraction
      final response = await ApiClient().post('/receipt/process-text', {
        'ocrText': text,
      });

      if (response.statusCode != 200) {
        return ReceiptUploadResult(
          false,
          'Backend AI extraction failed (${response.statusCode}): ${response.body}',
          [],
        );
      }

      // Parse structured JSON returned by the backend
      final List<dynamic> jsonList = jsonDecode(response.body);
      final List<Expense> expenses = jsonList.map((item) {
        return Expense(
          title: item['title'] ?? 'Unknown Item',
          amount: (item['amount'] as num?)?.toDouble() ?? 0.0,
          category: item['category'] ?? 'Food',
          date: DateTime.now(),
        );
      }).toList();

      // Return extracted expenses to let user select which to save

      return ReceiptUploadResult(true, text, expenses);
    } catch (e) {
      return ReceiptUploadResult(false, 'OCR / AI Error: $e', []);
    }
  }

  void dispose() {
    _ocr.dispose();
  }
}
