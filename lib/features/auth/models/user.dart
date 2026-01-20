import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? coverImageUrl;
  final String displayName;
  final String bio;
  final DateTime createdAt;
  final int followersCount;
  final int followingCount;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.coverImageUrl,
    required this.displayName,
    required this.bio,
    required this.createdAt,
    required this.followersCount,
    required this.followingCount,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
      coverImageUrl: map['coverImageUrl'] as String?,
      displayName: map['displayName'] as String? ?? map['name'] as String,
      bio: map['bio'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
      followersCount: map['followersCount'] as int? ?? 0,
      followingCount: map['followingCount'] as int? ?? 0,
    );
  }

  factory AppUser.fromFirebaseUser(User firebaseUser) {
    return AppUser(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
      coverImageUrl: null,
      displayName: firebaseUser.displayName ?? '',
      bio: '',
      createdAt: DateTime.now(),
      followersCount: 0,
      followingCount: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'coverImageUrl': coverImageUrl,
      'displayName': displayName,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'coverImageUrl': coverImageUrl,
      'displayName': displayName,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? coverImageUrl,
    String? displayName,
    String? bio,
    DateTime? createdAt,
    int? followersCount,
    int? followingCount,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }

  @override
  String toString() {
    return 'AppUser(uid: $uid, name: $name, email: $email, bio: $bio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
