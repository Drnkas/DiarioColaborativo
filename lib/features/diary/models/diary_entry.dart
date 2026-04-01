import 'package:cloud_firestore/cloud_firestore.dart';


class DiaryEntry {
  final String id;
  final String userId;
  final String text;
  final DateTime createdAt;
  final Map<String, List<String>> reactions;
  final List<String> imageUrls;
  final String cardGradientId;
  final String? moodTagId;
  final int commentsCount;

  const DiaryEntry({
    required this.id,
    required this.userId,
    required this.text,
    required this.createdAt,
    this.reactions = const {},
    this.imageUrls = const [],
    this.cardGradientId = 'white',
    this.moodTagId,
    this.commentsCount = 0,
  });

  factory DiaryEntry.fromMap(Map<String, dynamic> map, {String? id}) {
    return DiaryEntry(
      id: id ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      createdAt: _parseDateTime(map['createdAt']),
      reactions: _parseReactions(map['reactions']),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      cardGradientId: map['cardGradientId'] as String? ?? 'cream',
      moodTagId: map['moodTagId'] as String?,
      commentsCount: (map['commentsCount'] as num?)?.toInt() ?? 0,
    );
  }

  static Map<String, List<String>> _parseReactions(dynamic value) {
    if (value == null || value is! Map) return {};
    final result = <String, List<String>>{};
    for (final e in value.entries) {
      final v = e.value;
      if (v is List && v.isNotEmpty) {
        result[e.key.toString()] = List<String>.from(v);
      }
    }
    return result;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'reactions': reactions,
      'imageUrls': imageUrls,
      'cardGradientId': cardGradientId,
      'moodTagId': moodTagId,
      'commentsCount': commentsCount,
    };
  }

  DiaryEntry copyWith({
    String? id,
    String? userId,
    String? text,
    DateTime? createdAt,
    Map<String, List<String>>? reactions,
    List<String>? imageUrls,
    String? cardGradientId,
    String? moodTagId,
    int? commentsCount,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      reactions: reactions ?? this.reactions,
      imageUrls: imageUrls ?? this.imageUrls,
      cardGradientId: cardGradientId ?? this.cardGradientId,
      moodTagId: moodTagId ?? this.moodTagId,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryEntry && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
