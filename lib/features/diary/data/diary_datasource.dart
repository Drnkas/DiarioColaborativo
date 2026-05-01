import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diario_colaborativo/features/diary/data/results/diary_failed.dart';
import 'package:diario_colaborativo/features/diary/models/diary_comment.dart';
import 'package:diario_colaborativo/features/diary/models/diary_entry.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../core/helpers/result.dart';

abstract class DiaryDatasource {
  Future<Result<DiaryFailed, DiaryEntry>> create({
    required String userId,
    required String text,
    List<Uint8List> imageBytes = const [],
    String cardGradientId = 'cream',
    String? moodTagId,
  });

  Future<Result<DiaryFailed, DiaryEntry>> getById(String id);
  Future<Result<DiaryFailed, List<DiaryEntry>>> listByUser(String userId);
  Future<Result<DiaryFailed, List<DiaryComment>>> listComments({
    required String userId,
    required String entryId,
  });
  Future<Result<DiaryFailed, List<DiaryComment>>> listReplies({
    required String userId,
    required String entryId,
    required String parentCommentId,
  });
  Future<Result<DiaryFailed, DiaryComment>> addComment({
    required String userId,
    required String entryId,
    required String authorUserId,
    required String authorName,
    required String? authorPhotoUrl,
    required String text,
    String? parentCommentId,
  });
  Future<Result<DiaryFailed, DiaryComment>> updateCommentReactions({
    required String userId,
    required String entryId,
    required String commentId,
    required Map<String, List<String>> reactions,
  });
  Future<Result<DiaryFailed, DiaryEntry>> update(DiaryEntry entry);
  Future<Result<DiaryFailed, void>> delete(
      {required String userId, required String id});
}


class RemoteDiaryDatasource implements DiaryDatasource {
  RemoteDiaryDatasource(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const int _maxImages = 6;

  CollectionReference<Map<String, dynamic>> _entriesRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('entries');

  CollectionReference<Map<String, dynamic>> _commentsRef({
    required String userId,
    required String entryId,
  }) =>
      _entriesRef(userId).doc(entryId).collection('comments');

  Future<List<String>> _uploadImages(
      String userId, String entryId, List<Uint8List> imageBytes) async {
    if (imageBytes.isEmpty) return [];

    final urls = <String>[];
    for (var i = 0; i < imageBytes.length && i < _maxImages; i++) {
      final ref = _storage
          .ref()
          .child('diary')
          .child(userId)
          .child(entryId)
          .child('img_$i.jpg');
      await ref.putData(
        imageBytes[i],
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  @override
  Future<Result<DiaryFailed, DiaryEntry>> create({
    required String userId,
    required String text,
    List<Uint8List> imageBytes = const [],
    String cardGradientId = 'cream',
    String? moodTagId,
  }) async {
    try {
      final docRef = _entriesRef(userId).doc();
      final entryId = docRef.id;

      final imageUrls = await _uploadImages(userId, entryId, imageBytes);

      final now = Timestamp.fromDate(DateTime.now());
      final data = {
        'userId': userId,
        'text': text,
        'createdAt': now,
        'reactions': <String, List<String>>{},
        'imageUrls': imageUrls,
        'cardGradientId': cardGradientId,
        'moodTagId': moodTagId,
        'commentsCount': 0,
      };

      await docRef.set(data);

      await _firestore
          .collection('users')
          .doc(userId)
          .set({'postsCount': FieldValue.increment(1)}, SetOptions(merge: true));

      final snap = await docRef.get();
      final created = DiaryEntry.fromMap(
        snap.data()!,
        id: snap.id,
      );
      return Success(created);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseError(e));
    } catch (e) {
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return const Failure(DiaryFailed.offline);
      }
      return const Failure(DiaryFailed.unknown);
    }
  }

  @override
  Future<Result<DiaryFailed, DiaryEntry>> getById(String id) async {
    try {
      final snapshot = await _firestore
          .collectionGroup('entries')
          .where(FieldPath.documentId, isEqualTo: id)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return const Failure(DiaryFailed.notFound);
      }

      final doc = snapshot.docs.first;
      final entry = DiaryEntry.fromMap(doc.data(), id: doc.id);
      return Success(entry);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseError(e));
    } catch (e) {
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return const Failure(DiaryFailed.offline);
      }
      return const Failure(DiaryFailed.unknown);
    }
  }

  @override
  Future<Result<DiaryFailed, List<DiaryEntry>>> listByUser(
      String userId) async {
    try {
      final snapshot = await _entriesRef(userId)
          .orderBy('createdAt', descending: true)
          .get();

      final entries = snapshot.docs
          .map((doc) => DiaryEntry.fromMap(doc.data(), id: doc.id))
          .toList();
      return Success(entries);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseError(e));
    } catch (e) {
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return const Failure(DiaryFailed.offline);
      }
      return const Failure(DiaryFailed.unknown);
    }
  }

  @override
  Future<Result<DiaryFailed, List<DiaryComment>>> listComments({
    required String userId,
    required String entryId,
  }) async {
    try {
      final snapshot = await _commentsRef(userId: userId, entryId: entryId)
          .where('parentCommentId', isNull: true)
          .orderBy('createdAt', descending: false)
          .get();

      final comments = snapshot.docs
          .map((doc) => DiaryComment.fromMap(doc.data(), id: doc.id))
          .toList();

      return Success(comments);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseError(e));
    } catch (e) {
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return const Failure(DiaryFailed.offline);
      }
      return const Failure(DiaryFailed.unknown);
    }
  }

  @override
  Future<Result<DiaryFailed, List<DiaryComment>>> listReplies({
    required String userId,
    required String entryId,
    required String parentCommentId,
  }) async {
    try {
      final snapshot = await _commentsRef(userId: userId, entryId: entryId)
          .where('parentCommentId', isEqualTo: parentCommentId)
          .orderBy('createdAt', descending: false)
          .get();

      final comments = snapshot.docs
          .map((doc) => DiaryComment.fromMap(doc.data(), id: doc.id))
          .toList();
      return Success(comments);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseError(e));
    } catch (e) {
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return const Failure(DiaryFailed.offline);
      }
      return const Failure(DiaryFailed.unknown);
    }
  }

  @override
  Future<Result<DiaryFailed, DiaryComment>> addComment({
    required String userId,
    required String entryId,
    required String authorUserId,
    required String authorName,
    required String? authorPhotoUrl,
    required String text,
    String? parentCommentId,
  }) async {
    try {
      final entryRef = _entriesRef(userId).doc(entryId);
      final commentRef = _commentsRef(userId: userId, entryId: entryId).doc();
      final parentCommentRef = parentCommentId == null
          ? null
          : _commentsRef(userId: userId, entryId: entryId).doc(parentCommentId);

      final now = Timestamp.fromDate(DateTime.now());

      await _firestore.runTransaction((transaction) async {
        final entrySnap = await transaction.get(entryRef);
        if (!entrySnap.exists) {
          throw FirebaseException(plugin: 'cloud_firestore', code: 'not-found');
        }

        transaction.set(commentRef, {
          'entryId': entryId,
          'userId': authorUserId,
          'authorName': authorName,
          'authorPhotoUrl': authorPhotoUrl,
          'text': text,
          'createdAt': now,
          'parentCommentId': parentCommentId,
          'reactions': <String, List<String>>{},
          'repliesCount': 0,
        });

        transaction.update(entryRef, {
          'commentsCount': FieldValue.increment(1),
        });

        if (parentCommentRef != null) {
          transaction.update(parentCommentRef, {
            'repliesCount': FieldValue.increment(1),
          });
        }
      });

      final createdSnap = await commentRef.get();
      final created =
          DiaryComment.fromMap(createdSnap.data()!, id: createdSnap.id);
      return Success(created);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseError(e));
    } catch (e) {
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return const Failure(DiaryFailed.offline);
      }
      return const Failure(DiaryFailed.unknown);
    }
  }

  @override
  Future<Result<DiaryFailed, DiaryComment>> updateCommentReactions({
    required String userId,
    required String entryId,
    required String commentId,
    required Map<String, List<String>> reactions,
  }) async {
    try {
      final commentRef =
          _commentsRef(userId: userId, entryId: entryId).doc(commentId);
      await commentRef.update({'reactions': reactions});
      final updatedSnap = await commentRef.get();
      if (!updatedSnap.exists) {
        return const Failure(DiaryFailed.notFound);
      }
      return Success(
          DiaryComment.fromMap(updatedSnap.data()!, id: updatedSnap.id));
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return const Failure(DiaryFailed.notFound);
      }
      return Failure(_mapFirebaseError(e));
    } catch (e) {
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return const Failure(DiaryFailed.offline);
      }
      return const Failure(DiaryFailed.unknown);
    }
  }

  @override
  Future<Result<DiaryFailed, DiaryEntry>> update(DiaryEntry entry) async {
    try {
      await _entriesRef(entry.userId).doc(entry.id).update({
        'text': entry.text,
        'imageUrls': entry.imageUrls,
        'reactions': entry.reactions,
      });

      return Success(entry);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return const Failure(DiaryFailed.notFound);
      }
      return Failure(_mapFirebaseError(e));
    } catch (e) {
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return const Failure(DiaryFailed.offline);
      }
      return const Failure(DiaryFailed.unknown);
    }
  }

  @override
  Future<Result<DiaryFailed, void>> delete({
    required String userId,
    required String id,
  }) async {
    try {
      final docRef = _entriesRef(userId).doc(id);
      final snap = await docRef.get();

      if (!snap.exists) {
        return const Failure(DiaryFailed.notFound);
      }

      await docRef.delete();

      await _firestore
          .collection('users')
          .doc(userId)
          .set({'postsCount': FieldValue.increment(-1)}, SetOptions(merge: true));

      return const Success(null);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseError(e));
    } catch (e) {
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return const Failure(DiaryFailed.offline);
      }
      return const Failure(DiaryFailed.unknown);
    }
  }

  DiaryFailed _mapFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'unauthenticated':
      case 'permission-denied':
        return DiaryFailed.notAuthenticated;
      case 'unavailable':
      case 'network-request-failed':
        return DiaryFailed.offline;
      case 'not-found':
        return DiaryFailed.notFound;
      default:
        return DiaryFailed.unknown;
    }
  }
}
