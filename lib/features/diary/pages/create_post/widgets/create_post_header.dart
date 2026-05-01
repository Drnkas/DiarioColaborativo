import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CreatePostHeader extends StatelessWidget {
  const CreatePostHeader({
    super.key,
    required this.theme,
    required this.onSubmit,
    required this.onClose,
  });

  final AppTheme theme;
  final VoidCallback onSubmit;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: t.black,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onClose,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: t.inputBackground,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Rascunhos',
                style: t.body14Bold.copyWith(color: t.black, fontSize: 12),
              ),
            ),
          ),
          TextButton(
            onPressed: onSubmit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: t.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Publicar',
                style: t.body14Bold.copyWith(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
