import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/features/diary/models/mood_tag_preset.dart';
import 'package:flutter/material.dart';

class CreatePostMoodChip extends StatelessWidget {
  const CreatePostMoodChip({
    super.key,
    required this.mood,
    required this.theme,
    this.isSelected = false,
    required this.onTap,
  });

  final MoodTagPreset mood;
  final AppTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected ? t.primary : t.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border:
                isSelected ? Border.all(color: t.details, width: 0.5) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mood.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                mood.label,
                style: t.label11.copyWith(
                  fontSize: 13,
                  color: isSelected
                      ? Colors.white
                      : t.black.withValues(alpha: 0.5),
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
