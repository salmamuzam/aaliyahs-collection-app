import 'package:aaliyahs_collection_estore/utils/constants/api_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String profilePhotoUrl;
  final String? token;
  final String? createdAt;
  final String? dob;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.profilePhotoUrl,
    this.token,
    this.createdAt,
    this.dob,
  });

  String get name => '$firstName $lastName'.trim();
  String get fullName => name;
  String get profilePicture => profilePhotoUrl;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Extensive fallback for profile image fields
    String photoUrl = json['profile_photo_url'] ?? 
                      json['profile_photo_path'] ?? 
                      json['profile_picture'] ?? 
                      json['image'] ?? 
                      json['photo'] ?? 
                      json['avatar'] ?? 
                      '';

    return UserModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profilePhotoUrl: _processImageUrl(photoUrl),
      token: json['token'],
      createdAt: json['created_at'],
      dob: json['dob'],
    );
  }

  factory UserModel.fromFirebaseUser(User user) {
    // Split display name into first and last
    final names = (user.displayName ?? '').split(' ');
    final firstName = names.isNotEmpty ? names.first : 'Google';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : 'User';

    return UserModel(
      id: user.uid.hashCode, // Use hash of UID as an integer ID
      firstName: firstName,
      lastName: lastName,
      username: user.email?.split('@').first ?? 'google_user',
      email: user.email ?? '',
      profilePhotoUrl: user.photoURL ?? '',
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  static String _processImageUrl(String url) {
    if (url.isEmpty) return '';
    
    // 1. Handle Local Assets (Requirement 3)
    if (url.startsWith('assets/')) {
        return url;
    }

    // 2. Handle complete URLs pointing to localhost/emulator IPs
    if (url.startsWith('http')) {
        if (url.contains('localhost') || url.contains('127.0.0.1') || url.contains('10.0.2.2')) {
           final Uri uri = Uri.parse(url);
           return '$rootBaseURL${uri.path}';
        }
        return url;
    }

    // 3. Handle relative paths (e.g. /storage/... or storage/...)
    if (url.startsWith('/')) {
        return '$rootBaseURL$url';
    } else {
        // Prepend splash if missing
        return '$rootBaseURL/$url';
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
      'created_at': createdAt,
      'dob': dob,
    };
  }
}
