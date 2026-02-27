import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePostCardData {
  HomePostCardData({
    required this.authorName,
    required this.category,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.comments,
  });

  final String authorName;
  final String category;
  final String timeAgo;
  final String content;
  final int likes;
  final int comments;
}

class HomePostCard extends StatelessWidget {
  const HomePostCard({
    super.key,
    required this.data,
  });

  final HomePostCardData data;

  @override
  Widget build(BuildContext context) {
    final AppTheme t = context.watch();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF1E8),
            Color(0xFFFFF9F5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: avatar, nome, categoria, tempo e menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/onboarding_2.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.authorName,
                        style: t.body14Bold,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '✨ ${data.category}',
                            style: t.label11.copyWith(color: t.gray),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            data.timeAgo,
                            style: t.label11.copyWith(color: t.gray),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_horiz,
                  color: t.gray,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              data.content,
              style: t.body16.copyWith(
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 18,
                  color: t.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  data.likes.toString(),
                  style: t.label11Bold,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: t.gray,
                ),
                const SizedBox(width: 4),
                Text(
                  data.comments.toString(),
                  style: t.label11Bold,
                ),
                const Spacer(),
                Icon(
                  Icons.ios_share,
                  size: 18,
                  color: t.gray,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

