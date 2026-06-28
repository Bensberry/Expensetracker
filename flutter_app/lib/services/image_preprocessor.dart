import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Simple image preprocessor that improves OCR accuracy by:
///   • Converting to grayscale
///   • Increasing contrast
///   • Resizing to a max width of 1080px (preserves aspect ratio)
/// Returns a new temporary file containing the processed image.
class ImagePreprocessor {
  Future<File> preprocess(File original) async {
    // Read image bytes
    final bytes = await original.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return original;

    // Convert to grayscale
    image = img.grayscale(image);
    // Increase contrast (value range -100..100, 40 is a reasonable boost)
    image = img.adjustColor(image, contrast: 40);
    // Resize if too large
    const maxWidth = 1080;
    if (image.width > maxWidth) {
      final scale = maxWidth / image.width;
      image = img.copyResize(image, width: maxWidth, height: (image.height * scale).round());
    }

    // Encode back to JPEG (good compression for OCR)
    final processedBytes = img.encodeJpg(image);
    // Save to temporary directory
    final tempDir = await getTemporaryDirectory();
    final processedFile = File('${tempDir.path}/processed_${original.uri.pathSegments.last}');
    await processedFile.writeAsBytes(processedBytes);
    return processedFile;
  }
}
