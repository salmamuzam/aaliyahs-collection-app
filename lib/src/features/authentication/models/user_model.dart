import 'package:flutter/foundation.dart';

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String profilePhotoUrl;
  final String? token;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.profilePhotoUrl,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String photoUrl = json['profile_photo_url'] ?? '';
    
    // Fix for Network/Emulator: Replace localhost/127.0.0.1/10.0.2.2 with 192.168.1.11
    photoUrl = photoUrl.replaceAll('localhost', '192.168.1.11');
    photoUrl = photoUrl.replaceAll('127.0.0.1', '192.168.1.11');
    photoUrl = photoUrl.replaceAll('10.0.2.2', '192.168.1.11');
    
    debugPrint("UserModel: Final Translated Photo URL: $photoUrl");

    // If for some reason Laravel returns a relative path
    if (photoUrl.startsWith('/storage')) {
      photoUrl = 'http://192.168.1.11:8000$photoUrl';
    }

    return UserModel(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profilePhotoUrl: photoUrl,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'profile_photo_url': profilePhotoUrl,
      'token': token,
    };
  }
}
