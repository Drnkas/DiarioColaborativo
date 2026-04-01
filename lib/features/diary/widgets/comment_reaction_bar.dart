import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/di/di.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_cubit.dart';
import 'package:diario_colaborativo/features/diary/models/diary_comment.dart';
import 'package:diario_colaborativo/features/diary/models/diary_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _reactionEmojis = ['🤏', '🌸', '✨', '🌿', '☀️'];
const _heartEmoji = '❤️';


class CommentReactionBar extends StatelessWidget {
  const CommentReactionBar({
    super.key,
    required this.entry,
    required this.comment,
  });

  final DiaryEntry entry;
  final DiaryComment comment;

  bool _isLikedBy(String userId) =>
      comment.reactions[_heartEmoji]?.contains(userId) ?? false;

  bool _hasReacted(String emoji, String userId) =>
      comment.reactions[emoji]?.contains(userId) ?? false;

  void _toggleHeart(String userId) {
    if (_isLikedBy(userId)) {
      getIt<DiaryCubit>().removeCommentReaction(
          entry: entry, comment: comment, emoji: _heartEmoji);
    } else {
      getIt<DiaryCubit>().addCommentReaction(
          entry: entry, comment: comment, emoji: _heartEmoji);
    }
  }

  void _showReactionPicker(
      BuildContext context, RenderBox renderBox, String userId) {
    final overlay = Overlay.of(context);
    final position = renderBox.localToGlobal(Offset.zero);
    const barHeight = 50;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (ctx) {
        final screenWidth = MediaQuery.of(ctx).size.width;
        final left = (position.dx - 80).clamp(16.0, screenWidth - 180.0);
        final top = (position.dy - barHeight - 8).clamp(16.0, double.infinity);

        return GestureDetector(
          onTap: () => overlayEntry.remove(),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: left,
                top: top,
                child: GestureDetector(
                  onTap: () {},
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(28),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _reactionEmojis.map((emoji) {
                          final isActive = _hasReacted(emoji, userId);
                          return GestureDetector(
                            onTap: () {
                              overlayEntry.remove();
                              if (isActive) {
                                getIt<DiaryCubit>().removeCommentReaction(
                                    entry: entry,
                                    comment: comment,
                                    emoji: emoji);
                              } else {
                                getIt<DiaryCubit>().addCommentReaction(
                                    entry: entry,
                                    comment: comment,
                                    emoji: emoji);
                              }
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: AnimatedScale(
                                scale: isActive ? 1.25 : 1.0,
                                duration: const Duration(milliseconds: 150),
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    overlay.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    final userId = context.read<SessionCubit>().state.loggedUser?.uid ?? '';

    final reactedEntries =
        comment.reactions.entries.where((e) => e.value.isNotEmpty).toList();
    final totalReactions = comment.reactions.values
        .fold<int>(0, (acc, users) => acc + users.length);

    return GestureDetector(
      onTap: () => _toggleHeart(userId),
      onLongPress: () {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          _showReactionPicker(context, box, userId);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (reactedEntries.isEmpty)
            Icon(Icons.favorite_outline_sharp, size: 16, color: t.gray)
          else ...[
            SizedBox(
              width:
                  (12.0 * (reactedEntries.length - 1) + 18).clamp(18.0, 70.0),
              height: 20,
              child: Stack(
                children: [
                  for (var i = 0; i < reactedEntries.length; i++)
                    Positioned(
                      left: i * 12.0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          reactedEntries[i].key,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$totalReactions',
              style: t.label11.copyWith(color: t.gray),
            ),
          ],
        ],
      ),
    );
  }
}
