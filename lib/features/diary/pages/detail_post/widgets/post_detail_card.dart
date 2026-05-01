import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/core/utils/date_time_format.dart';
import 'package:diario_colaborativo/core/widgets/app_user_avatar.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/features/diary/models/card_gradient_preset.dart';
import 'package:diario_colaborativo/features/diary/models/diary_entry.dart';
import 'package:diario_colaborativo/features/diary/models/mood_tag_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostDetailCard extends StatelessWidget {
  const PostDetailCard({super.key, required this.entry});

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
                    formatRelativeTimePt(entry.createdAt),
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
                color: Colors.black.withValues(alpha: 0.03),
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
            MoodHashtagChip(label: '#${mood?.label}', t: t),
          ],
        ),
      ],
    );
  }
}

class MoodHashtagChip extends StatelessWidget {
  const MoodHashtagChip({super.key, required this.label, required this.t});

  final String label;
  final AppTheme t;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: t.darkPrimary.withValues(alpha: 0.12),
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
