import 'package:diario_colaborativo/features/diary/models/diary_entry.dart';
import 'package:equatable/equatable.dart';

class DiaryState extends Equatable {
  const DiaryState({
    this.entries = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<DiaryEntry> entries;
  final bool isLoading;
  final String? errorMessage;

  DiaryState copyWith({
    List<DiaryEntry>? entries,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DiaryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  DiaryState clearError() => copyWith(errorMessage: null);

  @override
  List<Object?> get props => [entries, isLoading, errorMessage];
}
