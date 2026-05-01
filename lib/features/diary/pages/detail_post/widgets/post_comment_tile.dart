import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/core/utils/date_time_format.dart';
import 'package:diario_colaborativo/core/widgets/app_user_avatar.dart';
import 'package:diario_colaborativo/features/diary/models/diary_comment.dart';
import 'package:diario_colaborativo/features/diary/models/diary_entry.dart';
import 'package:diario_colaborativo/features/diary/widgets/comment_reaction_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostCommentTile extends StatelessWidget {
  const PostCommentTile({
    super.key,
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
                          formatRelativeTimePt(
                            comment.createdAt,
                            includeYearWhenOld: false,
                          ),
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
          if (replies.isNotEmpty) PostCommentReplyThread(replies: replies),
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
}

class PostCommentReplyThread extends StatelessWidget {
  const PostCommentReplyThread({super.key, required this.replies});

  final List<DiaryComment> replies;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return Container(
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
                  UserAvatar(photoUrl: reply.authorPhotoUrl, radius: 13),
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
                              formatRelativeTimePt(
                                reply.createdAt,
                                includeYearWhenOld: false,
                              ),
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
    );
  }
}
