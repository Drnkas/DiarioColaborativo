import 'package:bloc/bloc.dart';
import 'package:diario_colaborativo/core/widgets/alert/alert_area_cubit.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/features/diary/data/diary_repository.dart';
import 'package:diario_colaborativo/features/diary/data/results/diary_failed.dart';
import 'package:diario_colaborativo/features/diary/models/diary_comment.dart';
import 'package:diario_colaborativo/features/diary/models/diary_entry.dart';
import 'package:flutter/foundation.dart';

import '../../../core/helpers/result.dart';
import '../../../di/di.dart';
import 'diary_state.dart';


class DiaryCubit extends Cubit<DiaryState> {
  DiaryCubit({
    DiaryRepository? repository,
    AlertAreaCubit? alertAreaCubit,
  })  : _repository = repository ?? getIt(),
        _alertAreaCubit = alertAreaCubit ?? getIt(),
        super(const DiaryState());

  final DiaryRepository _repository;
  final AlertAreaCubit _alertAreaCubit;

  /// Carrega as entradas do diário do usuário logado.
  Future<void> loadEntries() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _repository.listMyEntries();

    switch (result) {
      case Success(object: final entries):
        emit(state.copyWith(entries: entries, isLoading: false));
      case Failure(error: final error):
        final message = _mapErrorToMessage(error);
        emit(state.copyWith(isLoading: false, errorMessage: message));
    }
  }

  /// Cria uma nova entrada.
  Future<bool> createEntry({
    required String text,
    List<Uint8List> imageBytes = const [],
    String cardGradientId = 'cream',
    String? moodTagId,
  }) async {
    if (text.trim().isEmpty) return false;

    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _repository.create(
      text: text.trim(),
      imageBytes: imageBytes,
      cardGradientId: cardGradientId,
      moodTagId: moodTagId,
    );

    switch (result) {
      case Success():
        await loadEntries();
        return true;
      case Failure(error: final error):
        _alertAreaCubit.showAlert(
          _alertFromError('Não foi possível criar a entrada.', error),
        );
        emit(state.copyWith(isLoading: false));
        return false;
    }
  }

  /// Atualiza uma entrada existente.
  Future<bool> updateEntry(DiaryEntry entry) async {
    if (entry.text.trim().isEmpty) return false;

    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _repository.update(
      entry.copyWith(text: entry.text.trim()),
    );

    switch (result) {
      case Success():
        await loadEntries();
        return true;
      case Failure(error: final error):
        _alertAreaCubit.showAlert(
          _alertFromError('Não foi possível atualizar.', error),
        );
        emit(state.copyWith(isLoading: false));
        return false;
    }
  }

  String? get _currentUserId => getIt<SessionCubit>().state.loggedUser?.uid;

  /// Adiciona a reação do usuário atual ao emoji na entrada
  Future<bool> addReaction(DiaryEntry entry, String emoji) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    final updated = entry.reactions.map(
      (k, v) => MapEntry(k, List<String>.from(v)),
    );

    // Remove qualquer reação anterior do usuário antes de adicionar a nova
    for (final key in updated.keys.toList()) {
      updated[key]!.remove(userId);
      if (updated[key]!.isEmpty) updated.remove(key);
    }

    updated[emoji] = [...(updated[emoji] ?? []), userId];
    return updateEntry(entry.copyWith(reactions: updated));
  }

  /// Remove a reação do usuário atual ao emoji na entrada
  /// Se nenhum usuário sobrar para aquele emoji, ele é removido do mapa
  Future<bool> removeReaction(DiaryEntry entry, String emoji) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    final updated = entry.reactions.map(
      (k, v) => MapEntry(k, List<String>.from(v)),
    );
    final users = updated[emoji] ?? [];
    final next = users.where((id) => id != userId).toList();

    if (next.isEmpty) {
      updated.remove(emoji);
    } else {
      updated[emoji] = next;
    }
    return updateEntry(entry.copyWith(reactions: updated));
  }

  Future<void> loadComments({
    required String entryId,
    required String entryUserId,
  }) async {
    final loading = Set<String>.from(state.loadingCommentsEntryIds)..add(entryId);
    emit(state.copyWith(loadingCommentsEntryIds: loading));

    final result = await _repository.listComments(
      entryUserId: entryUserId,
      entryId: entryId,
    );

    switch (result) {
      case Success(object: final comments):
        final updatedComments = Map<String, List<DiaryComment>>.from(
          state.commentsByEntry,
        )..[entryId] = comments;

        final nextLoading = Set<String>.from(state.loadingCommentsEntryIds)..remove(entryId);

        emit(
          state.copyWith(
            commentsByEntry: updatedComments,
            loadingCommentsEntryIds: nextLoading,
          ),
        );
      case Failure(error: final error):
        final nextLoading = Set<String>.from(state.loadingCommentsEntryIds)..remove(entryId);
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

    final submitting = Set<String>.from(state.submittingCommentEntryIds)..add(entry.id);
    emit(state.copyWith(submittingCommentEntryIds: submitting));

    final result = await _repository.addComment(
      entryUserId: entry.userId,
      entryId: entry.id,
      text: trimmed,
      parentCommentId: parentCommentId,
    );

    switch (result) {
      case Success(object: final created):
        final updatedComments = Map<String, List<DiaryComment>>.from(state.commentsByEntry);
        final updatedReplies = Map<String, List<DiaryComment>>.from(state.repliesByCommentId);

        if (parentCommentId == null) {
          final list = List<DiaryComment>.from(updatedComments[entry.id] ?? [])..add(created);
          updatedComments[entry.id] = list;
        } else {
          final replies = List<DiaryComment>.from(updatedReplies[parentCommentId] ?? [])
            ..add(created);

          updatedReplies[parentCommentId] = replies;
          
          updatedComments[entry.id] = _incrementReplyCounter(
            comments: updatedComments[entry.id] ?? const <DiaryComment>[],
            parentCommentId: parentCommentId,
          );
        }

        final visibleCommentsCount = (updatedComments[entry.id] ?? const []).length +
            _countAllRepliesForEntry(updatedComments[entry.id] ?? const [], updatedReplies);
        final updatedEntries = _replaceEntryCommentsCount(
          entryId: entry.id,
          commentsCount: visibleCommentsCount,
        );

        final nextSubmitting = Set<String>.from(
          state.submittingCommentEntryIds,
        )..remove(entry.id);

        emit(
          state.copyWith(
            commentsByEntry: updatedComments,
            repliesByCommentId: updatedReplies,
            entries: updatedEntries,
            submittingCommentEntryIds: nextSubmitting,
          ),
        );
        return true;
      case Failure(error: final error):
        final nextSubmitting = Set<String>.from(
          state.submittingCommentEntryIds,
        )..remove(entry.id);
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
    final loading = Set<String>.from(state.loadingRepliesCommentIds)..add(parentCommentId);
    emit(state.copyWith(loadingRepliesCommentIds: loading));

    final result = await _repository.listReplies(
      entryUserId: entryUserId,
      entryId: entryId,
      parentCommentId: parentCommentId,
    );

    switch (result) {
      case Success(object: final replies):
        final updatedReplies = Map<String, List<DiaryComment>>.from(state.repliesByCommentId)
          ..[parentCommentId] = replies;
        final nextLoading = Set<String>.from(state.loadingRepliesCommentIds)
          ..remove(parentCommentId);
        emit(
          state.copyWith(
            repliesByCommentId: updatedReplies,
            loadingRepliesCommentIds: nextLoading,
          ),
        );
      case Failure(error: final error):
        final nextLoading = Set<String>.from(state.loadingRepliesCommentIds)
          ..remove(parentCommentId);
        _alertAreaCubit.showAlert(
          _alertFromError('Não foi possível carregar as respostas.', error),
        );
        emit(state.copyWith(loadingRepliesCommentIds: nextLoading));
    }
  }

  /// Adiciona a reação do usuário atual ao emoji no comentário
  /// Remove qualquer outra reação existente do usuário no mesmo comentário
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
    return _persistCommentReactions(entry: entry, comment: comment, reactions: updated);
  }

  /// Remove a reação do usuário atual ao emoji no comentário.
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
    return _persistCommentReactions(entry: entry, comment: comment, reactions: updated);
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

  /// Remove uma entrada
  Future<bool> deleteEntry(String id) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _repository.delete(id);

    switch (result) {
      case Success():
        await loadEntries();
        return true;
      case Failure(error: final error):
        _alertAreaCubit.showAlert(
          _alertFromError('Não foi possível excluir.', error),
        );
        emit(state.copyWith(isLoading: false));
        return false;
    }
  }

  String _mapErrorToMessage(DiaryFailed error) {
    return switch (error) {
      DiaryFailed.notAuthenticated => 'Faça login para ver suas entradas.',
      DiaryFailed.offline => 'Sem conexão. Verifique sua internet e tente novamente.',
      DiaryFailed.notFound => 'Entrada não encontrada.',
      DiaryFailed.unknown => 'Algo deu errado. Tente novamente.',
    };
  }

  Alert _alertFromError(String title, DiaryFailed error) {
    final message = _mapErrorToMessage(error);
    return Alert.error(title: '$title $message');
  }

  List<DiaryEntry> _replaceEntryCommentsCount({
    required String entryId,
    required int commentsCount,
  }) {
    return state.entries
        .map(
          (entry) => entry.id == entryId ? entry.copyWith(commentsCount: commentsCount) : entry,
        )
        .toList(growable: false);
  }

  void _replaceCommentInState(DiaryComment updatedComment) {
    final updatedComments = Map<String, List<DiaryComment>>.from(state.commentsByEntry);
    final updatedReplies = Map<String, List<DiaryComment>>.from(state.repliesByCommentId);

    final entryId = updatedComment.entryId;
    final parentCommentId = updatedComment.parentCommentId;

    if (parentCommentId == null) {
      updatedComments[entryId] = (updatedComments[entryId] ?? const [])
          .map((c) => c.id == updatedComment.id ? updatedComment : c)
          .toList(growable: false);
    } else {
      updatedReplies[parentCommentId] = (updatedReplies[parentCommentId] ?? const [])
          .map((c) => c.id == updatedComment.id ? updatedComment : c)
          .toList(growable: false);
    }

    emit(state.copyWith(
      commentsByEntry: updatedComments,
      repliesByCommentId: updatedReplies,
    ));
  }

  List<DiaryComment> _incrementReplyCounter({
    required List<DiaryComment> comments,
    required String parentCommentId,
  }) {
    return comments
        .map((comment) => comment.id == parentCommentId
            ? comment.copyWith(repliesCount: comment.repliesCount + 1)
            : comment)
        .toList(growable: false);
  }

  int _countAllRepliesForEntry(
    List<DiaryComment> rootComments,
    Map<String, List<DiaryComment>> repliesByCommentId,
  ) {
    var total = 0;
    for (final comment in rootComments) {
      total += (repliesByCommentId[comment.id] ?? const []).length;
    }
    return total;
  }
}
