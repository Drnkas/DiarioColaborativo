import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePromptCard extends StatelessWidget {
  const HomePromptCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppTheme t = context.watch();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAD4E8),
            Color(0xFFEEDCFD),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar “comfy”
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/onboarding_1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'O que está passando pela sua mente hoje?',
                  style: t.body16Bold.copyWith(
                    color: t.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Compartilhe um momento gentil com você mesma ✨',
                  style: t.label11.copyWith(
                    color: t.gray,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.9),
            ),
            child: Icon(
              Icons.favorite_border,
              color: t.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

