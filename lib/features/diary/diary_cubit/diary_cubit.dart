import 'package:bloc/bloc.dart';
import 'package:diario_colaborativo/core/widgets/alert/alert_area_cubit.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/features/diary/data/diary_failed_messages.dart';
import 'package:diario_colaborativo/features/diary/data/diary_repository.dart';
import 'package:diario_colaborativo/features/diary/data/results/diary_failed.dart';
import 'package:diario_colaborativo/features/diary/models/create_diary_entry_input.dart';
import 'package:diario_colaborativo/features/diary/models/diary_entry.dart';

import '../../../core/helpers/result.dart';
import '../../../di/di.dart';
import 'diary_state.dart';


class DiaryCubit extends Cubit<DiaryState> {
  DiaryCubit({
    DiaryRepository? repository,
    AlertAreaCubit? alertAreaCubit,
    void Function(String entryId)? onEntryDeleted,
  })  : _repository = repository ?? getIt(),
        _alertAreaCubit = alertAreaCubit ?? getIt(),
        _onEntryDeleted = onEntryDeleted,
        super(const DiaryState());

  final DiaryRepository _repository;
  final AlertAreaCubit _alertAreaCubit;
  final void Function(String entryId)? _onEntryDeleted;

  /// Limpa lista e erro em memória (uso típico: logout antes de novo login).
  void clearUserCaches() {
    emit(const DiaryState());
  }

  /// Carrega as entradas do diário do usuário logado.
  Future<void> loadEntries() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _repository.listMyEntries();

    switch (result) {
      case Success(object: final entries):
        emit(state.copyWith(entries: entries, isLoading: false));
      case Failure(error: final error):
        final message = diaryFailureUserMessage(error);
        emit(state.copyWith(isLoading: false, errorMessage: message));
    }
  }

  /// Cria uma nova entrada a partir de [input]
  Future<bool> createEntry(CreateDiaryEntryInput input) async {
    if (input.hasNoTextContent) return false;

    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _repository.create(input);

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

  /// Atualiza só o campo [DiaryEntry.commentsCount] no cache da lista
  void syncEntryCommentsCount({
    required String entryId,
    required int visibleCommentsTotal,
  }) {
    emit(
      state.copyWith(
        entries: _replaceEntryCommentsCount(
          entryId: entryId,
          commentsCount: visibleCommentsTotal,
        ),
      ),
    );
  }

  /// Adiciona a reação do usuário atual ao emoji na entrada.
  Future<bool> addReaction(DiaryEntry entry, String emoji) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    final updated = entry.reactions.map(
      (k, v) => MapEntry(k, List<String>.from(v)),
    );

    for (final key in updated.keys.toList()) {
      updated[key]!.remove(userId);
      if (updated[key]!.isEmpty) updated.remove(key);
    }

    updated[emoji] = [...(updated[emoji] ?? []), userId];
    return updateEntry(entry.copyWith(reactions: updated));
  }

  /// Remove a reação do usuário atual ao emoji na entrada.
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

  /// Remove uma entrada
  Future<bool> deleteEntry(String id) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _repository.delete(id);

    switch (result) {
      case Success():
        _onEntryDeleted?.call(id);
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

  Alert _alertFromError(String title, DiaryFailed error) {
    final message = diaryFailureUserMessage(error);
    return Alert.error(title: '$title $message');
  }

  List<DiaryEntry> _replaceEntryCommentsCount({
    required String entryId,
    required int commentsCount,
  }) {
    return state.entries
        .map(
          (entry) => entry.id == entryId
              ? entry.copyWith(commentsCount: commentsCount)
              : entry,
        )
        .toList(growable: false);
  }
}
