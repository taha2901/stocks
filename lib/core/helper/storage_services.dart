import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  static final _storage = FirebaseStorage.instance;
  static final _picker = ImagePicker();

  static Future<String?> uploadProfileImage(String userId, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, maxWidth: 800, imageQuality: 80);
      if (image == null) return null;

      final ref = _storage.ref().child('users/$userId/profile.jpg');
      await ref.putFile(File(image.path));
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('فشل في رفع الصورة: $e');
    }
  }

  static Future<void> deleteProfileImage(String userId) async {
    try {
      await _storage.ref().child('users/$userId/profile.jpg').delete();
    } catch (e) {
      // تجاهل الخطأ إذا لم تكن الصورة موجودة
    }
  }
}