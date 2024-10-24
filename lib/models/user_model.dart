class UserModel {
  final String name;
  final String email;
  final String profilePicture;
  final String token;
  final String uid;

  UserModel({
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.token,
    required this.uid,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String,
      email: json['email'] as String,
      profilePicture: json['profilePicture'] as String,
      token: json['token'] ?? '',
      uid: json['_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'token': token,
      'uid': uid,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? profilePicture,
    String? token,
    String? uid,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      token: token ?? this.token,
      uid: uid ?? this.uid,
    );
  }
}
