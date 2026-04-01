import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryComment {
  const DiaryComment({
    required this.id,
    required this.entryId,
    required this.userId,
    required this.authorName,
    required this.text,
    required this.createdAt,
    this.authorPhotoUrl,
    this.parentCommentId,
    this.reactions = const {},
    this.repliesCount = 0,
  });

  final String id;
  final String entryId;
  final String userId;
  final String authorName;
  final String? authorPhotoUrl;
  final String text;
  final DateTime createdAt;
  final String? parentCommentId;
  /// Mapa de emoji → lista de userIds que reagiram com aquele emoji
  final Map<String, List<String>> reactions;
  final int repliesCount;

  factory DiaryComment.fromMap(Map<String, dynamic> map, {String? id}) {
    return DiaryComment(
      id: id ?? (map['id'] as String? ?? ''),
      entryId: map['entryId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '',
      authorPhotoUrl: map['authorPhotoUrl'] as String?,
      text: map['text'] as String? ?? '',
      createdAt: _parseDateTime(map['createdAt']),
      parentCommentId: map['parentCommentId'] as String?,
      reactions: _parseReactions(map['reactions']),
      repliesCount: (map['repliesCount'] as num?)?.toInt() ?? 0,
    );
  }

  static Map<String, List<String>> _parseReactions(dynamic value) {
    if (value is! Map) return {};
    final result = <String, List<String>>{};
    for (final entry in value.entries) {
      final v = entry.value;
      if (v is List && v.isNotEmpty) {
        result[entry.key.toString()] = List<String>.from(v);
      }
    }
    return result;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'entryId': entryId,
      'userId': userId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'parentCommentId': parentCommentId,
      'reactions': reactions,
      'repliesCount': repliesCount,
    };
  }

  DiaryComment copyWith({
    String? id,
    String? entryId,
    String? userId,
    String? authorName,
    String? authorPhotoUrl,
    String? text,
    DateTime? createdAt,
    String? parentCommentId,
    Map<String, List<String>>? reactions,
    int? repliesCount,
  }) {
    return DiaryComment(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      reactions: reactions ?? this.reactions,
      repliesCount: repliesCount ?? this.repliesCount,
    );
  }
}
