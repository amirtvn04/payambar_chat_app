import 'package:payambar/core/enums/enums.dart';
import 'package:payambar/core/models/user_model.dart';
import 'package:payambar/core/other/base_viewmodel.dart';
import 'package:payambar/core/services/database_service.dart';
import 'package:payambar/core/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ProfileViewmodel extends BaseViewmodel {
  final DatabaseService _db;
  final StorageService _storage;
  final UserModel _currentUser;

  ProfileViewmodel(this._db, this._storage, this._currentUser) {
    _name = _currentUser.name ?? '';
    _email = _currentUser.email ?? '';
    _bio = _currentUser.bio ?? '';
    _imageUrl = _currentUser.imageUrl;
  }

  String _name = '';
  String _email = '';
  String _phone = '';
  String _bio = '';
  String? _imageUrl;
  XFile? _imageFile;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get bio => _bio;
  String? get imageUrl => _imageUrl;
  XFile? get imageFile => _imageFile;

  void setName(String value) => _name = value;
  void setPhone(String value) => _phone = value;
  void setBio(String value) => _bio = value;

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        _imageFile = pickedFile;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile() async {
    try {
      setstate(ViewState.loading);

      final updatedData = {
        'name': _name.trim(),
        'phone': _phone.trim(),
        'bio': _bio.trim(),
      };

      await _db.updateUser(_currentUser.uid!, updatedData);

      // به‌روزرسانی کاربر فعلی
      final updatedUser = UserModel(
        uid: _currentUser.uid,
        name: _name.trim(),
        email: _currentUser.email,
        bio: _bio.trim(),
      );

      setstate(ViewState.idle);

    } catch (e) {
      setstate(ViewState.idle);
      rethrow;
    }
  }

  void resetChanges() {
    _name = _currentUser.name ?? '';
    _bio = _currentUser.bio ?? '';
    notifyListeners();
  }
}