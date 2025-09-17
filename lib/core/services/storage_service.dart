import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File image) async {
    try {
      Reference ref =
          _storage.ref("images/${DateTime.now().millisecondsSinceEpoch}");

      final task = await ref.putFile(image);

      String downloadUrl = await task.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }
}
