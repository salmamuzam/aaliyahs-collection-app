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
    return UserModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
      email: json['email'],
      profilePhotoUrl: json['profile_photo_url'],
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
