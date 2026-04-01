import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/core/widgets/app_user_avatar.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePromptCard extends StatelessWidget {
  const HomePromptCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppTheme t = context.watch();
    final user = context.read<SessionCubit>().state.loggedUser;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFAD4E8),
              Color(0xFFEEDCFD),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UserAvatar(photoUrl: user?.photoUrl),
            Text(
              'O que está passando pela sua mente hoje?',
              style: t.body16.copyWith(color: t.text, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
