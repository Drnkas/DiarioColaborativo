import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/di/di.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_cubit.dart';
import 'package:diario_colaborativo/features/diary/models/diary_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _reactionEmojis = ['🤏', '🌸', '✨', '🌿', '☀️'];
const _heartEmoji = '❤️';

class DiaryReactionBar extends StatelessWidget {
  const DiaryReactionBar({super.key, required this.entry});

  final DiaryEntry entry;

  bool _isLikedBy(String userId) => entry.reactions[_heartEmoji]?.contains(userId) ?? false;

  bool _hasReacted(String emoji, String userId) =>
      entry.reactions[emoji]?.contains(userId) ?? false;

  void _toggleHeart(String userId) {
    if (_isLikedBy(userId)) {
      getIt<DiaryCubit>().removeReaction(entry, _heartEmoji);
    } else {
      getIt<DiaryCubit>().addReaction(entry, _heartEmoji);
    }
  }

  void _showReactionPicker(BuildContext context, RenderBox renderBox, String userId) {
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _reactionEmojis.map((emoji) {
                          final isActive = _hasReacted(emoji, userId);

                          return GestureDetector(
                            onTap: () {
                              overlayEntry.remove();
                              if (isActive) {
                                getIt<DiaryCubit>().removeReaction(entry, emoji);
                              } else {
                                getIt<DiaryCubit>().addReaction(entry, emoji);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
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

    final reactedEntries = entry.reactions.entries.where((e) => e.value.isNotEmpty).toList();
    final totalReactions = entry.reactions.values.fold<int>(0, (acc, users) => acc + users.length);

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
            Icon(Icons.favorite_outline_sharp, size: 20, color: t.darkDetails)
          else ...[
            SizedBox(
              width: (14.0 * (reactedEntries.length - 1) + 22).clamp(22.0, 80.0),
              height: 24,
              child: Stack(
                children: [
                  for (var i = 0; i < reactedEntries.length; i++)
                    Positioned(
                      left: i * 14.0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        child: Text(
                          reactedEntries[i].key,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$totalReactions',
              style: t.label11.copyWith(color: t.darkDetails),
            ),
          ],
        ],
      ),
    );
  }
}
