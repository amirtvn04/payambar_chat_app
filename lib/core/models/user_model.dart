import 'dart:convert';
import 'dart:developer';

class UserModel {
  final String? uid;
  final String? name;
  final String? email;
  final String? imageUrl;
  final String? bio;

  UserModel(
      {this.uid,
      this.name,
      this.email,
      this.imageUrl,
      this.bio,});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'bio': bio,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    log(map.toString());
    return UserModel(
      uid: map['uid'] != null ? map['uid'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
      bio: map['bio'] != null ? map['bio'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, imageUrl: $imageUrl)';
  }
}
