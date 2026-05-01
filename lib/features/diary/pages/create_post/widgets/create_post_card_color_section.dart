import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/features/diary/models/card_gradient_preset.dart';
import 'package:diario_colaborativo/features/diary/pages/create_post/widgets/create_post_gradient_chip.dart';
import 'package:flutter/material.dart';

class CreatePostCardColorSection extends StatelessWidget {
  const CreatePostCardColorSection({
    super.key,
    required this.theme,
    required this.selectedGradientId,
    required this.onGradientSelected,
  });

  final AppTheme theme;
  final String selectedGradientId;
  final ValueChanged<String> onGradientSelected;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cor do card',
              style:
                  t.label11.copyWith(color: t.gray, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final preset in CardGradientPreset.all)
                  CreatePostGradientChip(
                    preset: preset,
                    isSelected: selectedGradientId == preset.id,
                    onTap: () => onGradientSelected(preset.id),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
