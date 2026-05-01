import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CreatePostFooterBar extends StatelessWidget {
  const CreatePostFooterBar({
    super.key,
    required this.theme,
    required this.onPickImage,
  });

  final AppTheme theme;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(color: t.gray.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.public, size: 14, color: t.gray),
              const SizedBox(width: 6),
              Text(
                'Todos podem responder',
                style: t.label11.copyWith(color: t.gray),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _FooterActionIcon(
                icon: Icons.add_photo_alternate_outlined,
                onTap: onPickImage,
                theme: t,
              ),
              const SizedBox(width: 20),
              _FooterActionIcon(
                icon: Icons.bar_chart_outlined,
                onTap: () {},
                theme: t,
              ),
              const SizedBox(width: 20),
              _FooterActionIcon(
                icon: Icons.emoji_emotions_outlined,
                onTap: () {},
                theme: t,
              ),
              const SizedBox(width: 20),
              _FooterActionIcon(
                icon: Icons.location_on_outlined,
                onTap: () {},
                theme: t,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterActionIcon extends StatelessWidget {
  const _FooterActionIcon({
    required this.icon,
    required this.onTap,
    required this.theme,
  });

  final IconData icon;
  final VoidCallback onTap;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 24, color: t.primary),
    );
  }
}
