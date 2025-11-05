import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile photo and return download URL
  Future<String> uploadProfilePhoto(File imageFile, String userId) async {
    try {
      final ref = _storage.ref().child('profile_photos/$userId.jpg');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  // Delete profile photo
  Future<void> deleteProfilePhoto(String userId) async {
    try {
      final ref = _storage.ref().child('profile_photos/$userId.jpg');
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete photo: $e');
    }
  }
}