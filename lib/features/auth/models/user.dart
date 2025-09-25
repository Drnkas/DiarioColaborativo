import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String id;
  final String token;
  final String email;
  final String fullname;

  const AppUser({
    required this.id,
    required this.token,
    required this.email,
    required this.fullname,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      token: map['token'] as String,
      email: map['email'] as String,
      fullname: map['fullname'] as String,
    );
  }

  factory AppUser.fromFirebaseUser(User firebaseUser) {
    return AppUser(
      id: firebaseUser.uid,
      token: firebaseUser.uid, 
      email: firebaseUser.email ?? '',
      fullname: firebaseUser.displayName ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'token': token,
      'email': email,
      'fullname': fullname,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': id,
      'email': email,
      'displayName': fullname,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  AppUser copyWith({
    String? id,
    String? token,
    String? email,
    String? fullname,
  }) {
    return AppUser(
      id: id ?? this.id,
      token: token ?? this.token,
      email: email ?? this.email,
      fullname: fullname ?? this.fullname,
    );
  }

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, fullname: $fullname)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
