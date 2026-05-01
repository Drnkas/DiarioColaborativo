import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/features/diary/models/card_gradient_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePostGradientChip extends StatelessWidget {
  const CreatePostGradientChip({
    super.key,
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final CardGradientPreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: preset.gradient,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: t.primary, width: 1.5) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
