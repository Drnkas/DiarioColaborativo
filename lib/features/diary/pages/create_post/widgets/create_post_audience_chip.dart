import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CreatePostAudienceChip extends StatelessWidget {
  const CreatePostAudienceChip({super.key, required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: t.inputBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.public, size: 16, color: t.black),
          const SizedBox(width: 6),
          Text('Todos podem ver', style: t.label11.copyWith(color: t.black)),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, color: t.black, size: 20),
        ],
      ),
    );
  }
}
