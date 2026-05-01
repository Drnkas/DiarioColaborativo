import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/features/diary/data/diary_datasource.dart';
import 'package:diario_colaborativo/features/diary/data/results/diary_failed.dart';
import 'package:diario_colaborativo/features/diary/models/create_diary_entry_input.dart';
import 'package:diario_colaborativo/features/diary/models/diary_comment.dart';
import 'package:diario_colaborativo/features/diary/models/diary_entry.dart';

import '../../../core/helpers/result.dart';


class DiaryRepository {
  DiaryRepository(this._datasource, this._sessionCubit);

  final DiaryDatasource _datasource;
  final SessionCubit _sessionCubit;

  String? get _userId => _sessionCubit.state.loggedUser?.uid;

  Future<Result<DiaryFailed, DiaryEntry>> create(
    CreateDiaryEntryInput input,
  ) async {
    final userId = _userId;
    if (userId == null) {
      return const Failure(DiaryFailed.notAuthenticated);
    }
    final payload = input.normalizedCopy();
    return _datasource.create(
      userId: userId,
      text: payload.text,
      imageBytes: payload.imageBytes,
      cardGradientId: payload.cardGradientId,
      moodTagId: payload.moodTagId,
    );
  }

  Future<Result<DiaryFailed, List<DiaryEntry>>> listMyEntries() async {
    final userId = _userId;
    if (userId == null) {
      return const Failure(DiaryFailed.notAuthenticated);
    }
    return _datasource.listByUser(userId);
  }

  Future<Result<DiaryFailed, DiaryEntry>> getById(String id) {
    return _datasource.getById(id);
  }

  Future<Result<DiaryFailed, DiaryEntry>> update(DiaryEntry entry) {
    return _datasource.update(entry);
  }

  Future<Result<DiaryFailed, List<DiaryComment>>> listComments({
    required String entryUserId,
    required String entryId,
  }) {
    return _datasource.listComments(userId: entryUserId, entryId: entryId);
  }

  Future<Result<DiaryFailed, List<DiaryComment>>> listReplies({
    required String entryUserId,
    required String entryId,
    required String parentCommentId,
  }) {
    return _datasource.listReplies(
      userId: entryUserId,
      entryId: entryId,
      parentCommentId: parentCommentId,
    );
  }

  Future<Result<DiaryFailed, DiaryComment>> addComment({
    required String entryUserId,
    required String entryId,
    required String text,
    String? parentCommentId,
  }) {
    final currentUser = _sessionCubit.state.loggedUser;
    if (currentUser == null) {
      return Future.value(const Failure(DiaryFailed.notAuthenticated));
    }
    return _datasource.addComment(
      userId: entryUserId,
      entryId: entryId,
      authorUserId: currentUser.uid,
      authorName: currentUser.name,
      authorPhotoUrl: currentUser.photoUrl,
      text: text,
      parentCommentId: parentCommentId,
    );
  }

  Future<Result<DiaryFailed, DiaryComment>> updateCommentReactions({
    required String entryUserId,
    required String entryId,
    required String commentId,
    required Map<String, List<String>> reactions,
  }) {
    if (_userId == null) {
      return Future.value(const Failure(DiaryFailed.notAuthenticated));
    }
    return _datasource.updateCommentReactions(
      userId: entryUserId,
      entryId: entryId,
      commentId: commentId,
      reactions: reactions,
    );
  }

  Future<Result<DiaryFailed, void>> delete(String id) {
    final userId = _userId;
    if (userId == null) {
      return Future.value(const Failure(DiaryFailed.notAuthenticated));
    }
    return _datasource.delete(userId: userId, id: id);
  }
}
