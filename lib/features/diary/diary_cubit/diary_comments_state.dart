import 'package:diario_colaborativo/features/diary/models/diary_comment.dart';
import 'package:equatable/equatable.dart';

class DiaryCommentsState extends Equatable {
  const DiaryCommentsState({
    this.commentsByEntry = const {},
    this.repliesByCommentId = const {},
    this.loadingCommentsEntryIds = const {},
    this.loadingRepliesCommentIds = const {},
    this.submittingCommentEntryIds = const {},
  });

  final Map<String, List<DiaryComment>> commentsByEntry;
  final Map<String, List<DiaryComment>> repliesByCommentId;
  final Set<String> loadingCommentsEntryIds;
  final Set<String> loadingRepliesCommentIds;
  final Set<String> submittingCommentEntryIds;

  DiaryCommentsState copyWith({
    Map<String, List<DiaryComment>>? commentsByEntry,
    Map<String, List<DiaryComment>>? repliesByCommentId,
    Set<String>? loadingCommentsEntryIds,
    Set<String>? loadingRepliesCommentIds,
    Set<String>? submittingCommentEntryIds,
  }) {
    return DiaryCommentsState(
      commentsByEntry: commentsByEntry ?? this.commentsByEntry,
      repliesByCommentId: repliesByCommentId ?? this.repliesByCommentId,
      loadingCommentsEntryIds:
          loadingCommentsEntryIds ?? this.loadingCommentsEntryIds,
      loadingRepliesCommentIds:
          loadingRepliesCommentIds ?? this.loadingRepliesCommentIds,
      submittingCommentEntryIds:
          submittingCommentEntryIds ?? this.submittingCommentEntryIds,
    );
  }

  @override
  List<Object?> get props => [
        commentsByEntry,
        repliesByCommentId,
        loadingCommentsEntryIds,
        loadingRepliesCommentIds,
        submittingCommentEntryIds,
      ];
}
