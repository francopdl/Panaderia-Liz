import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImageStorageService {
  static final ImageStorageService _instance = ImageStorageService._internal();

  factory ImageStorageService() => _instance;

  ImageStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload product image to Firebase Storage
  /// Returns the download URL if successful, null otherwise
  Future<String?> uploadProductImage(String productId, XFile imageFile) async {
    try {
      final ref = _storage.ref()
          .child('products')
          .child(productId)
          .child('image_${DateTime.now().millisecondsSinceEpoch}');

      final bytes = await imageFile.readAsBytes();
      await ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'productId': productId},
        ),
      );

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading product image: $e');
      return null;
    }
  }

  /// Upload raw material image to Firebase Storage
  /// Returns the download URL if successful, null otherwise
  Future<String?> uploadRawMaterialImage(
      String materialId, XFile imageFile) async {
    try {
      final ref = _storage.ref()
          .child('raw_materials')
          .child(materialId)
          .child('image_${DateTime.now().millisecondsSinceEpoch}');

      final bytes = await imageFile.readAsBytes();
      await ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'materialId': materialId},
        ),
      );

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading raw material image: $e');
      return null;
    }
  }

  /// Delete image from Firebase Storage
  Future<bool> deleteProductImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting product image: $e');
      return false;
    }
  }

  /// Delete image from Firebase Storage
  Future<bool> deleteRawMaterialImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting raw material image: $e');
      return false;
    }
  }
}
