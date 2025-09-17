import 'dart:developer';
import 'dart:io';

import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/core/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class SignupViewmodel extends BaseViewmodel {
  final AuthService _auth;
  final DatabaseService _db;
  final StorageService _storage;

  SignupViewmodel(this._auth, this._db, this._storage);

  final _picker = ImagePicker();

  String _name = "";
  String _email = "";
  String _password = "";
  String _confirmPassword = "";

  File? _image;

  File? get image => _image;

  pickImage() async {
    log("Pick Image");
    final pic = await _picker.pickImage(source: ImageSource.gallery);

    if (pic != null) {
      _image = File(pic.path);
      notifyListeners();
    }
  }

  void setName(String value) {
    _name = value;
    notifyListeners();

    log("Name: $_name");
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();

    log("Email: $_email");
  }

  setPassword(String value) {
    _password = value;
    notifyListeners();

    log("Password: $_password");
  }

  setConfirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();

    log("Confirm Password: $_confirmPassword");
  }

  signup() async {
    String? downloadUrl;
    setstate(ViewState.loading);
    try {
      if (_password != _confirmPassword) {
        throw Exception("The password do not match");
      }

      final res = await _auth.signup(_email, _password);

      if (res != null) {
        if (_image != null) {
          downloadUrl = await _storage.uploadImage(_image!);
        }

        UserModel user = UserModel(
            uid: res.uid, name: _name, email: _email, imageUrl: downloadUrl);

        await _db.saveUser(user.toMap());
      }

      setstate(ViewState.idle);
    } on FirebaseAuthException catch (e) {
      setstate(ViewState.idle);
      rethrow;
    } catch (e) {
      setstate(ViewState.idle);
      log(e.toString());
      rethrow;
    }
  }
}
