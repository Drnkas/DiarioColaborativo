import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/core/utils/date_time_format.dart';
import 'package:diario_colaborativo/core/widgets/app_loading_overlay.dart';
import 'package:diario_colaborativo/di/di.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_comments_cubit.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_comments_state.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_cubit.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_state.dart';
import 'package:diario_colaborativo/features/diary/models/diary_comment.dart';
import 'package:diario_colaborativo/features/diary/models/diary_entry.dart';
import 'package:diario_colaborativo/features/diary/pages/detail_post/widgets/post_comment_input_bar.dart';
import 'package:diario_colaborativo/features/diary/pages/detail_post/widgets/post_comment_tile.dart';
import 'package:diario_colaborativo/features/diary/pages/detail_post/widgets/post_detail_card.dart';
import 'package:diario_colaborativo/features/diary/widgets/diary_reaction_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailPostPage extends StatefulWidget {
  const DetailPostPage({
    super.key,
    required this.postId,
    this.initialpost,
  });

  final String postId;
  final Object? initialpost;

  @override
  State<DetailPostPage> createState() => _DetailPostPageState();
}

class _DetailPostPageState extends State<DetailPostPage> {
  final TextEditingController _commentController = TextEditingController();
  DiaryComment? _replyTarget;

  DiaryCubit get _diary => getIt<DiaryCubit>();
  DiaryCommentsCubit get _comments => getIt<DiaryCommentsCubit>();

  DiaryEntry? _entryFor(DiaryState state) {
    for (final e in state.entries) {
      if (e.id == widget.postId) return e;
    }
    final data = widget.initialpost;
    return data is DiaryEntry ? data : null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_loadCommentsAfterFirstFrame);
  }

  void _loadCommentsAfterFirstFrame(Duration _) {
    if (!mounted) return;
    final entry = _entryFor(_diary.state);
    if (entry == null) return;
    _comments.loadComments(entryId: entry.id, entryUserId: entry.userId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment(DiaryEntry entry) async {
    final sent = await _comments.addComment(
      entry: entry,
      text: _commentController.text,
      parentCommentId: _replyTarget?.id,
    );
    if (!mounted || !sent) return;
    setState(() => _replyTarget = null);
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _diary),
        BlocProvider.value(value: _comments),
      ],
      child: BlocBuilder<DiaryCubit, DiaryState>(
        builder: (context, diaryState) {
          final entry = _entryFor(diaryState);
          if (entry == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Post'),
                elevation: 0,
              ),
              body: const Center(
                child: Text('Não foi possível carregar a publicação.'),
              ),
            );
          }

          return BlocBuilder<DiaryCommentsCubit, DiaryCommentsState>(
            builder: (context, ccState) {
              final comments =
                  ccState.commentsByEntry[entry.id] ?? const <DiaryComment>[];
              final repliesByCommentId = ccState.repliesByCommentId;
              final isLoadingComments =
                  ccState.loadingCommentsEntryIds.contains(entry.id);
              final isSubmitting =
                  ccState.submittingCommentEntryIds.contains(entry.id);

              return Scaffold(
                appBar: AppBar(
                  title: const Text('Post'),
                  elevation: 0,
                ),
                body: AppLoadingOverlay(
                  isLoading: isLoadingComments && comments.isEmpty,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          children: [
                            PostDetailCard(entry: entry),
                            const SizedBox(height: 12),
                            Text(
                              formatTimeAndShortDatePt(entry.createdAt),
                              style: t.label11.copyWith(color: t.gray),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  '${_totalReactions(entry.reactions)} curtidas',
                                  style: t.body14Bold,
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  '${entry.commentsCount} comentários',
                                  style: t.body16.copyWith(color: t.gray),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Divider(color: t.gray.withValues(alpha: 0.4)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: DiaryReactionBar(entry: entry),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 20,
                                      color: t.darkDetails,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${entry.commentsCount}',
                                      style: t.label11
                                          .copyWith(color: t.darkDetails),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.ios_share_rounded,
                                  size: 22,
                                  color: t.darkDetails,
                                ),
                              ],
                            ),
                            Divider(color: t.gray.withValues(alpha: 0.25)),
                            const SizedBox(height: 12),
                            if (isLoadingComments && comments.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 20),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            else if (comments.isEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 28),
                                child: Text(
                                  'Seja a primeira pessoa a comentar.',
                                  textAlign: TextAlign.center,
                                  style: t.body16.copyWith(color: t.gray),
                                ),
                              )
                            else
                              ...comments.map(
                                (comment) => PostCommentTile(
                                  entry: entry,
                                  comment: comment,
                                  replies: repliesByCommentId[comment.id] ?? const [],
                                  isLoadingReplies: ccState
                                      .loadingRepliesCommentIds
                                      .contains(comment.id),
                                  onReplyTap: () async {
                                    setState(() => _replyTarget = comment);
                                    await _comments.loadReplies(
                                      entryUserId: entry.userId,
                                      entryId: entry.id,
                                      parentCommentId: comment.id,
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      PostCommentInputBar(
                        controller: _commentController,
                        isSubmitting: isSubmitting,
                        replyTarget: _replyTarget,
                        onCancelReply: () =>
                            setState(() => _replyTarget = null),
                        onSend: () => _sendComment(entry),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  int _totalReactions(Map<String, List<String>> reactions) {
    return reactions.values.fold<int>(0, (sum, value) => sum + value.length);
  }
}
