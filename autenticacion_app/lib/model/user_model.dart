class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      role: data['role'] ?? 'user',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'createdAt': createdAt,
    };
  }
}
