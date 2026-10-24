import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PhotoService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  static Future<String?> capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        return await _savePhotoLocally(photo);
      }
      return null;
    } catch (e) {
      print('Error capturing photo: $e');
      return null;
    }
  }

  /// Pick image from gallery
  static Future<String?> pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        return await _savePhotoLocally(photo);
      }
      return null;
    } catch (e) {
      print('Error picking photo: $e');
      return null;
    }
  }

  /// Save photo to local app directory
  static Future<String> _savePhotoLocally(XFile photo) async {
    final directory = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory('${directory.path}/receipts');

    // Create receipts directory if it doesn't exist
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }

    // Generate unique filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(photo.path);
    final fileName = 'receipt_$timestamp$extension';
    final savedPath = '${receiptsDir.path}/$fileName';

    // Copy file to app directory
    final File sourceFile = File(photo.path);
    await sourceFile.copy(savedPath);

    return savedPath;
  }

  /// Delete photo from local storage
  static Future<bool> deletePhoto(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting photo: $e');
      return false;
    }
  }

  /// Check if photo exists
  static Future<bool> photoExists(String photoPath) async {
    try {
      final file = File(photoPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get file size in MB
  static Future<double> getPhotoSize(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        final bytes = await file.length();
        return bytes / (1024 * 1024); // Convert to MB
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Show photo source selection dialog
  static Future<String?> showPhotoSourceDialog({
    required Function() onCamera,
    required Function() onGallery,
  }) async {
    // This would typically show a dialog
    // For now, we'll just capture from camera as default
    return await capturePhoto();
  }

  /// Compress image if needed (images over 2MB)
  static Future<String?> compressIfNeeded(String photoPath) async {
    try {
      final size = await getPhotoSize(photoPath);

      // If photo is larger than 2MB, we should compress it
      if (size > 2.0) {
        // In a real app, you'd use image compression library here
        // For now, we'll just return the original path
        print('Photo size: ${size.toStringAsFixed(2)}MB - Consider compressing');
      }

      return photoPath;
    } catch (e) {
      print('Error checking photo size: $e');
      return photoPath;
    }
  }

  /// Get all receipt photos
  static Future<List<String>> getAllReceiptPhotos() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${directory.path}/receipts');

      if (!await receiptsDir.exists()) {
        return [];
      }

      final files = receiptsDir.listSync();
      return files
          .where((file) => file is File)
          .map((file) => file.path)
          .toList();
    } catch (e) {
      print('Error getting receipt photos: $e');
      return [];
    }
  }

  /// Clean up old photos (older than specified days)
  static Future<int> cleanupOldPhotos({int daysOld = 90}) async {
    try {
      final photos = await getAllReceiptPhotos();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      int deletedCount = 0;

      for (final photoPath in photos) {
        final file = File(photoPath);
        final stat = await file.stat();

        if (stat.modified.isBefore(cutoffDate)) {
          await file.delete();
          deletedCount++;
        }
      }

      return deletedCount;
    } catch (e) {
      print('Error cleaning up photos: $e');
      return 0;
    }
  }
}
