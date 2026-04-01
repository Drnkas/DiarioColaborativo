import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/core/widgets/app_user_avatar.dart';
import 'package:diario_colaborativo/di/di.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_cubit.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_state.dart';
import 'package:diario_colaborativo/features/diary/models/card_gradient_preset.dart';
import 'package:diario_colaborativo/features/diary/models/diary_comment.dart';
import 'package:diario_colaborativo/features/diary/models/diary_entry.dart';
import 'package:diario_colaborativo/features/diary/models/mood_tag_preset.dart';
import 'package:diario_colaborativo/features/diary/widgets/comment_reaction_bar.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadComments());
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadComments() {
    final entry = _currentEntry;
    if (entry == null) return;
    getIt<DiaryCubit>().loadComments(
      entryId: entry.id,
      entryUserId: entry.userId,
    );
  }

  DiaryEntry? get _initialTypedEntry {
    final data = widget.initialpost;
    return data is DiaryEntry ? data : null;
  }

  DiaryEntry? get _currentEntry {
    final state = getIt<DiaryCubit>().state;
    for (final entry in state.entries) {
      if (entry.id == widget.postId) return entry;
    }
    return _initialTypedEntry;
  }

  Future<void> _sendComment(DiaryEntry entry) async {
    final sent = await getIt<DiaryCubit>().addComment(
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

    return BlocProvider.value(
      value: getIt<DiaryCubit>(),
      child: BlocBuilder<DiaryCubit, DiaryState>(
        builder: (context, state) {
          final entry = _currentEntry;
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

          final comments =
              state.commentsByEntry[entry.id] ?? const <DiaryComment>[];
          final repliesByCommentId = state.repliesByCommentId;
          final isLoadingComments =
              state.loadingCommentsEntryIds.contains(entry.id);
          final isSubmitting =
              state.submittingCommentEntryIds.contains(entry.id);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Post'),
              elevation: 0,
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      // Post detail card
                      _PostDetailCard(entry: entry),

                      const SizedBox(height: 12),

                      // Data
                      Text(
                        _formatPostDate(entry.createdAt),
                        style: t.label11.copyWith(color: t.gray),
                      ),
                      const SizedBox(height: 12),

                      // Reactions and comments count
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

                      // Actions bar
                      Divider(color: t.gray.withValues(alpha: 0.4)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
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
                                style: t.label11.copyWith(color: t.darkDetails),
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

                      // Comments list
                      Divider(color: t.gray.withValues(alpha: 0.25)),

                      const SizedBox(height: 12),
                      if (isLoadingComments && comments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          child: Text(
                            'Seja a primeira pessoa a comentar.',
                            textAlign: TextAlign.center,
                            style: t.body16.copyWith(color: t.gray),
                          ),
                        )
                      else
                        ...comments.map(
                          (comment) => _CommentTile(
                            entry: entry,
                            comment: comment,
                            replies: repliesByCommentId[comment.id] ?? const [],
                            isLoadingReplies: state.loadingRepliesCommentIds
                                .contains(comment.id),
                            onReplyTap: () async {
                              setState(() => _replyTarget = comment);
                              await getIt<DiaryCubit>().loadReplies(
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
                _CommentInputBar(
                  controller: _commentController,
                  isSubmitting: isSubmitting,
                  replyTarget: _replyTarget,
                  onCancelReply: () => setState(() => _replyTarget = null),
                  onSend: () => _sendComment(entry),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _totalReactions(Map<String, List<String>> reactions) {
    return reactions.values.fold<int>(0, (sum, value) => sum + value.length);
  }

  String _formatPostDate(DateTime date) {
    final months = [
      'jan.',
      'fev.',
      'mar.',
      'abr.',
      'mai.',
      'jun.',
      'jul.',
      'ago.',
      'set.',
      'out.',
      'nov.',
      'dez.',
    ];
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    final month = months[(date.month - 1).clamp(0, 11)];
    return '$hh:$mm · ${date.day} $month ${date.year}';
  }
}

class _PostDetailCard extends StatelessWidget {
  const _PostDetailCard({required this.entry});

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    final user = context.read<SessionCubit>().state.loggedUser;
    final preset = CardGradientPreset.byId(entry.cardGradientId);
    final mood = MoodTagPreset.byId(entry.moodTagId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatar(photoUrl: user?.photoUrl, radius: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.name ?? '', style: t.body14Bold),
                  const SizedBox(height: 2),
                  Text(
                    _timeAgo(entry.createdAt),
                    style: t.label11.copyWith(color: t.gray),
                  ),
                ],
              ),
            ),
            Icon(Icons.more_horiz, color: t.gray),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: preset.gradient,
            border: Border.all(color: t.primary, width: 0.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.text,
                style: t.body16.copyWith(height: 1.5),
              ),
              if (entry.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 14),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.imageUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        entry.imageUrls[i],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _HashtagChip(label: '#${mood?.label}', t: t),
          ],
        ),
      ],
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _HashtagChip extends StatelessWidget {
  const _HashtagChip({required this.label, required this.t});

  final String label;
  final AppTheme t;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: t.darkPrimary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: t.label11.copyWith(
          color: t.darkPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.entry,
    required this.comment,
    required this.replies,
    required this.isLoadingReplies,
    required this.onReplyTap,
  });

  final DiaryEntry entry;
  final DiaryComment comment;
  final List<DiaryComment> replies;
  final bool isLoadingReplies;
  final VoidCallback onReplyTap;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(photoUrl: comment.authorPhotoUrl, radius: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(comment.authorName, style: t.body14Bold),
                        const SizedBox(width: 8),
                        Text(
                          _timeAgo(comment.createdAt),
                          style: t.label11.copyWith(color: t.gray),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(comment.text, style: t.body16.copyWith(height: 1.35)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CommentReactionBar(
                          entry: entry,
                          comment: comment,
                        ),
                        const SizedBox(width: 14),
                        InkWell(
                          onTap: onReplyTap,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 1,
                            ),
                            child: Text(
                              'Responder',
                              style: t.label11.copyWith(color: t.gray),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.more_horiz, size: 16, color: t.gray),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLoadingReplies)
            const Padding(
              padding: EdgeInsets.only(left: 42, top: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          if (replies.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 20, top: 8),
              padding: const EdgeInsets.only(left: 22),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: t.gray.withValues(alpha: 0.35)),
                ),
              ),
              child: Column(
                children: [
                  for (final reply in replies)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UserAvatar(
                              photoUrl: reply.authorPhotoUrl, radius: 13),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(reply.authorName, style: t.body14Bold),
                                    const SizedBox(width: 6),
                                    Text(
                                      _timeAgo(reply.createdAt),
                                      style: t.label11.copyWith(color: t.gray),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(reply.text, style: t.body16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          if (comment.repliesCount > 0 && replies.isEmpty && !isLoadingReplies)
            Padding(
              padding: const EdgeInsets.only(left: 42, top: 6),
              child: InkWell(
                onTap: onReplyTap,
                child: Text(
                  'Ver respostas (${comment.repliesCount})',
                  style: t.label11.copyWith(color: t.gray),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dateTime.day}/${dateTime.month}';
  }
}


class _CommentInputBar extends StatelessWidget {
  const _CommentInputBar({
    required this.controller,
    required this.isSubmitting,
    required this.onSend,
    required this.replyTarget,
    required this.onCancelReply,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSend;
  final DiaryComment? replyTarget;
  final VoidCallback onCancelReply;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: t.gray.withValues(alpha: 0.3))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyTarget != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: t.lightGray.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Respondendo ${replyTarget!.authorName}',
                        style: t.label11.copyWith(color: t.gray),
                      ),
                    ),
                    InkWell(
                      onTap: onCancelReply,
                      child: Icon(Icons.close, size: 16, color: t.gray),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    decoration: InputDecoration(
                      hintText: replyTarget == null
                          ? 'Adicionar comentário...'
                          : 'Escreva uma resposta...',
                      filled: true,
                      fillColor: t.lightGray.withValues(alpha: 0.45),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: isSubmitting ? null : onSend,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: t.primary
                          .withValues(alpha: isSubmitting ? 0.45 : 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: isSubmitting
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.send_rounded, color: t.black, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
