import 'package:aaliyahs_collection_estore/src/constants/api_strings.dart';

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

  String get name => '$firstName $lastName'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Extensive fallback for profile image fields
    String photoUrl = json['profile_photo_url'] ?? 
                      json['profile_photo_path'] ?? 
                      json['image'] ?? 
                      json['photo'] ?? 
                      json['avatar'] ?? 
                      '';

    return UserModel(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profilePhotoUrl: _processImageUrl(photoUrl),
      token: json['token'],
    );
  }

  static String _processImageUrl(String url) {
    if (url.isEmpty) return '';
    
    // 1. Handle complete URLs pointing to localhost/emulator IPs
    if (url.startsWith('http')) {
        if (url.contains('localhost') || url.contains('127.0.0.1') || url.contains('10.0.2.2')) {
           final Uri uri = Uri.parse(url);
           return "$rootBaseURL${uri.path}";
        }
        return url;
    }

    // 2. Handle relative paths (e.g. /storage/... or storage/...)
    if (url.startsWith('/')) {
        return "$rootBaseURL$url";
    } else {
        // Prepend splash if missing
        return "$rootBaseURL/$url";
    }
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
