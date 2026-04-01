import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/core/widgets/app_user_avatar.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/features/diary/models/card_gradient_preset.dart';
import 'package:diario_colaborativo/features/diary/models/diary_entry.dart';
import 'package:diario_colaborativo/features/diary/models/mood_tag_preset.dart';
import 'package:diario_colaborativo/features/diary/widgets/diary_reaction_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiaryCard extends StatelessWidget {
  const DiaryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
  });

  final DiaryEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    final user = context.read<SessionCubit>().state.loggedUser;
    final preset = CardGradientPreset.byId(entry.cardGradientId);

    return Container(
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
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Cabeçalho: avatar, nome, categoria, tempo e menu
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              // Avatar
                              UserAvatar(photoUrl: user?.photoUrl, radius: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Nome
                                    Text(user?.name ?? '', style: t.body14Bold),
                                    const SizedBox(height: 4),

                                    // Tag e tempo
                                    Row(
                                      children: [
                                        if (entry.moodTagId != null) ...[
                                          _MoodTagPill(
                                            mood: MoodTagPreset.byId(entry.moodTagId),
                                            t: t,
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        Text(
                                          _timeAgo(entry.createdAt),
                                          style:
                                              t.label11.copyWith(color: t.black.withOpacity(0.5)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.text,
                            style: t.body16.copyWith(height: 1.4),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(Icons.more_horiz, color: t.gray),
                        onPressed: () => _showMenu(context, t),
                      ),
                  ],
                ),
                if (entry.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.imageUrls.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            entry.imageUrls[i],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Divider(
                  color: t.darkPrimary.withValues(alpha: 0.2),
                  thickness: 0.5,
                ),
                Row(
                  children: [
                    DiaryReactionBar(entry: entry),
                    const SizedBox(width: 14),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context, AppTheme t) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Excluir'),
              onTap: () {
                Navigator.pop(ctx);
                onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${diff.inDays}d';
  }
}

class _MoodTagPill extends StatelessWidget {
  const _MoodTagPill({required this.mood, required this.t});

  final MoodTagPreset? mood;
  final AppTheme t;

  @override
  Widget build(BuildContext context) {
    if (mood == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: t.darkPrimary.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mood!.emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 6),
          Text(mood!.label, style: t.label11.copyWith(color: t.black, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
