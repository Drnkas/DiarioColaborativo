import 'package:bloc/bloc.dart';
import 'package:diario_colaborativo/core/helpers/result.dart';
import 'package:diario_colaborativo/core/widgets/alert/alert_area_cubit.dart'
    show Alert, AlertAreaCubit;
import 'package:diario_colaborativo/di/di.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/features/diary/data/diary_failed_messages.dart';
import 'package:diario_colaborativo/features/diary/data/diary_repository.dart';
import 'package:diario_colaborativo/features/diary/data/results/diary_failed.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_comments_state.dart';
import 'package:diario_colaborativo/features/diary/models/diary_comment.dart';
import 'package:diario_colaborativo/features/diary/models/diary_entry.dart';

import 'diary_cubit.dart';

DiaryCubit _diaryCubitLazy() => getIt<DiaryCubit>();


class DiaryCommentsCubit extends Cubit<DiaryCommentsState> {
  DiaryCommentsCubit({
    DiaryRepository? repository,
    AlertAreaCubit? alertAreaCubit,
    DiaryCubit Function()? diaryCubitLocator,
  })  : _repository = repository ?? getIt(),
        _alertAreaCubit = alertAreaCubit ?? getIt(),
        _diaryLocator = diaryCubitLocator ?? _diaryCubitLazy,
        super(const DiaryCommentsState());

  final DiaryRepository _repository;
  final AlertAreaCubit _alertAreaCubit;
  final DiaryCubit Function() _diaryLocator;

  String? get _currentUserId => getIt<SessionCubit>().state.loggedUser?.uid;

  Future<void> loadComments({
    required String entryId,
    required String entryUserId,
  }) async {
    final loading = Set<String>.from(state.loadingCommentsEntryIds)
      ..add(entryId);
    emit(state.copyWith(loadingCommentsEntryIds: loading));

    final result = await _repository.listComments(
      entryUserId: entryUserId,
      entryId: entryId,
    );

    switch (result) {
      case Success(object: final comments):
        final updatedComments =
            Map<String, List<DiaryComment>>.from(state.commentsByEntry)
              ..[entryId] = comments;

        final nextLoading = Set<String>.from(state.loadingCommentsEntryIds)
          ..remove(entryId);

        emit(
          state.copyWith(
            commentsByEntry: updatedComments,
            loadingCommentsEntryIds: nextLoading,
          ),
        );
      case Failure(error: final error):
        final nextLoading = Set<String>.from(state.loadingCommentsEntryIds)
          ..remove(entryId);
        _alertAreaCubit.showAlert(
          _alertFromError('Não foi possível carregar os comentários.', error),
        );
        emit(state.copyWith(loadingCommentsEntryIds: nextLoading));
    }
  }

  Future<bool> addComment({
    required DiaryEntry entry,
    required String text,
    String? parentCommentId,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final submitting =
        Set<String>.from(state.submittingCommentEntryIds)..add(entry.id);
    emit(state.copyWith(submittingCommentEntryIds: submitting));

    final result = await _repository.addComment(
      entryUserId: entry.userId,
      entryId: entry.id,
      text: trimmed,
      parentCommentId: parentCommentId,
    );

    switch (result) {
      case Success(object: final created):
        final updatedComments =
            Map<String, List<DiaryComment>>.from(state.commentsByEntry);
        final updatedReplies =
            Map<String, List<DiaryComment>>.from(state.repliesByCommentId);

        if (parentCommentId == null) {
          final list = List<DiaryComment>.from(updatedComments[entry.id] ?? [])
            ..add(created);
          updatedComments[entry.id] = list;
        } else {
          final replies = List<DiaryComment>.from(
            updatedReplies[parentCommentId] ?? [],
          )..add(created);

          updatedReplies[parentCommentId] = replies;

          updatedComments[entry.id] = _incrementReplyCounter(
            comments: updatedComments[entry.id] ?? const <DiaryComment>[],
            parentCommentId: parentCommentId,
          );
        }

        final visibleCommentsCount =
            (updatedComments[entry.id] ?? const []).length +
                _countAllRepliesForEntry(
                  updatedComments[entry.id] ?? const [],
                  updatedReplies,
                );

        _diaryLocator().syncEntryCommentsCount(
          entryId: entry.id,
          visibleCommentsTotal: visibleCommentsCount,
        );

        final nextSubmitting =
            Set<String>.from(state.submittingCommentEntryIds)..remove(entry.id);

        emit(
          state.copyWith(
            commentsByEntry: updatedComments,
            repliesByCommentId: updatedReplies,
            submittingCommentEntryIds: nextSubmitting,
          ),
        );
        return true;
      case Failure(error: final error):
        final nextSubmitting =
            Set<String>.from(state.submittingCommentEntryIds)..remove(entry.id);
        _alertAreaCubit.showAlert(
          _alertFromError('Não foi possível enviar o comentário.', error),
        );
        emit(state.copyWith(submittingCommentEntryIds: nextSubmitting));
        return false;
    }
  }

  Future<void> loadReplies({
    required String entryUserId,
    required String entryId,
    required String parentCommentId,
  }) async {
    final loading =
        Set<String>.from(state.loadingRepliesCommentIds)..add(parentCommentId);
    emit(state.copyWith(loadingRepliesCommentIds: loading));

    final result = await _repository.listReplies(
      entryUserId: entryUserId,
      entryId: entryId,
      parentCommentId: parentCommentId,
    );

    switch (result) {
      case Success(object: final replies):
        final updatedReplies =
            Map<String, List<DiaryComment>>.from(state.repliesByCommentId)
              ..[parentCommentId] = replies;
        final nextLoading =
            Set<String>.from(state.loadingRepliesCommentIds)
              ..remove(parentCommentId);
        emit(
          state.copyWith(
            repliesByCommentId: updatedReplies,
            loadingRepliesCommentIds: nextLoading,
          ),
        );
      case Failure(error: final error):
        final nextLoading =
            Set<String>.from(state.loadingRepliesCommentIds)
              ..remove(parentCommentId);
        _alertAreaCubit.showAlert(
          _alertFromError('Não foi possível carregar as respostas.', error),
        );
        emit(state.copyWith(loadingRepliesCommentIds: nextLoading));
    }
  }

  Future<bool> addCommentReaction({
    required DiaryEntry entry,
    required DiaryComment comment,
    required String emoji,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    final updated = comment.reactions.map(
      (k, v) => MapEntry(k, List<String>.from(v)),
    );

    for (final key in updated.keys.toList()) {
      updated[key]!.remove(userId);
      if (updated[key]!.isEmpty) updated.remove(key);
    }

    updated[emoji] = [...(updated[emoji] ?? []), userId];
    return _persistCommentReactions(
      entry: entry,
      comment: comment,
      reactions: updated,
    );
  }

  Future<bool> removeCommentReaction({
    required DiaryEntry entry,
    required DiaryComment comment,
    required String emoji,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    final updated = comment.reactions.map(
      (k, v) => MapEntry(k, List<String>.from(v)),
    );

    final users = updated[emoji] ?? [];
    final next = users.where((id) => id != userId).toList();

    if (next.isEmpty) {
      updated.remove(emoji);
    } else {
      updated[emoji] = next;
    }
    return _persistCommentReactions(
      entry: entry,
      comment: comment,
      reactions: updated,
    );
  }

  Future<bool> _persistCommentReactions({
    required DiaryEntry entry,
    required DiaryComment comment,
    required Map<String, List<String>> reactions,
  }) async {
    final result = await _repository.updateCommentReactions(
      entryUserId: entry.userId,
      entryId: entry.id,
      commentId: comment.id,
      reactions: reactions,
    );
    switch (result) {
      case Success(object: final updatedComment):
        _replaceCommentInState(updatedComment);
        return true;
      case Failure(error: final error):
        _alertAreaCubit.showAlert(
          _alertFromError('Não foi possível reagir ao comentário.', error),
        );
        return false;
    }
  }

  void _replaceCommentInState(DiaryComment updatedComment) {
    final updatedComments =
        Map<String, List<DiaryComment>>.from(state.commentsByEntry);
    final updatedReplies =
        Map<String, List<DiaryComment>>.from(state.repliesByCommentId);

    final entryId = updatedComment.entryId;
    final parentCommentId = updatedComment.parentCommentId;

    if (parentCommentId == null) {
      updatedComments[entryId] =
          (updatedComments[entryId] ?? const [])
              .map((c) => c.id == updatedComment.id ? updatedComment : c)
              .toList(growable: false);
    } else {
      updatedReplies[parentCommentId] =
          (updatedReplies[parentCommentId] ?? const [])
              .map((c) => c.id == updatedComment.id ? updatedComment : c)
              .toList(growable: false);
    }

    emit(
      state.copyWith(
        commentsByEntry: updatedComments,
        repliesByCommentId: updatedReplies,
      ),
    );
  }

  List<DiaryComment> _incrementReplyCounter({
    required List<DiaryComment> comments,
    required String parentCommentId,
  }) {
    return comments
        .map(
          (comment) => comment.id == parentCommentId
              ? comment.copyWith(repliesCount: comment.repliesCount + 1)
              : comment,
        )
        .toList(growable: false);
  }

  int _countAllRepliesForEntry(
    List<DiaryComment> rootComments,
    Map<String, List<DiaryComment>> repliesByCommentIdMap,
  ) {
    var total = 0;
    for (final comment in rootComments) {
      total += (repliesByCommentIdMap[comment.id] ?? const []).length;
    }
    return total;
  }

  /// Remove comentários, respostas e flags de carregamento em memória do post
  void clearCacheForEntry(String entryId) {
    final roots =
        state.commentsByEntry[entryId] ?? const <DiaryComment>[];
    final rootIds = roots.map((c) => c.id).toSet();

    final nextComments =
        Map<String, List<DiaryComment>>.from(state.commentsByEntry)
          ..remove(entryId);

    final nextReplies =
        Map<String, List<DiaryComment>>.from(state.repliesByCommentId);
    for (final id in rootIds) {
      nextReplies.remove(id);
    }

    final nextLoadingComments =
        Set<String>.from(state.loadingCommentsEntryIds)..remove(entryId);
    final nextSubmitting =
        Set<String>.from(state.submittingCommentEntryIds)..remove(entryId);
    final nextLoadingReplies =
        Set<String>.from(state.loadingRepliesCommentIds);
    for (final id in rootIds) {
      nextLoadingReplies.remove(id);
    }

    emit(
      state.copyWith(
        commentsByEntry: nextComments,
        repliesByCommentId: nextReplies,
        loadingCommentsEntryIds: nextLoadingComments,
        loadingRepliesCommentIds: nextLoadingReplies,
        submittingCommentEntryIds: nextSubmitting,
      ),
    );
  }


  void clearAllCaches() {
    emit(const DiaryCommentsState());
  }

  Alert _alertFromError(String title, DiaryFailed error) {
    final message = diaryFailureUserMessage(error);
    return Alert.error(title: '$title $message');
  }
}

