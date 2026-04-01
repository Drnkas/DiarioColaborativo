import 'package:diario_colaborativo/features/diary/models/diary_entry.dart';
import 'package:diario_colaborativo/features/diary/models/diary_comment.dart';
import 'package:equatable/equatable.dart';

class DiaryState extends Equatable {
  const DiaryState({
    this.entries = const [],
    this.commentsByEntry = const {},
    this.repliesByCommentId = const {},
    this.loadingCommentsEntryIds = const {},
    this.loadingRepliesCommentIds = const {},
    this.submittingCommentEntryIds = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  final List<DiaryEntry> entries;
  final Map<String, List<DiaryComment>> commentsByEntry;
  final Map<String, List<DiaryComment>> repliesByCommentId;
  final Set<String> loadingCommentsEntryIds;
  final Set<String> loadingRepliesCommentIds;
  final Set<String> submittingCommentEntryIds;
  final bool isLoading;
  final String? errorMessage;

  DiaryState copyWith({
    List<DiaryEntry>? entries,
    Map<String, List<DiaryComment>>? commentsByEntry,
    Map<String, List<DiaryComment>>? repliesByCommentId,
    Set<String>? loadingCommentsEntryIds,
    Set<String>? loadingRepliesCommentIds,
    Set<String>? submittingCommentEntryIds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DiaryState(
      entries: entries ?? this.entries,
      commentsByEntry: commentsByEntry ?? this.commentsByEntry,
      repliesByCommentId: repliesByCommentId ?? this.repliesByCommentId,
      loadingCommentsEntryIds:
          loadingCommentsEntryIds ?? this.loadingCommentsEntryIds,
      loadingRepliesCommentIds:
          loadingRepliesCommentIds ?? this.loadingRepliesCommentIds,
      submittingCommentEntryIds:
          submittingCommentEntryIds ?? this.submittingCommentEntryIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  DiaryState clearError() => copyWith(errorMessage: null);

  @override
  List<Object?> get props => [
        entries,
        commentsByEntry,
        repliesByCommentId,
        loadingCommentsEntryIds,
        loadingRepliesCommentIds,
        submittingCommentEntryIds,
        isLoading,
        errorMessage,
      ];
}
