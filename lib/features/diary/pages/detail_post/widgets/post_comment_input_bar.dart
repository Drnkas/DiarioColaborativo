import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/features/diary/models/diary_comment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostCommentInputBar extends StatelessWidget {
  const PostCommentInputBar({
    super.key,
    required this.controller,
    required this.isSubmitting,
    required this.onSend,
    required this.replyTarget,
    required this.onCancelReply,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSend;
  final DiaryComment? replyTarget;
  final VoidCallback onCancelReply;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: t.gray.withValues(alpha: 0.3))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyTarget != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: t.lightGray.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Respondendo ${replyTarget!.authorName}',
                        style: t.label11.copyWith(color: t.gray),
                      ),
                    ),
                    InkWell(
                      onTap: onCancelReply,
                      child: Icon(Icons.close, size: 16, color: t.gray),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    decoration: InputDecoration(
                      hintText: replyTarget == null
                          ? 'Adicionar comentário...'
                          : 'Escreva uma resposta...',
                      filled: true,
                      fillColor: t.lightGray.withValues(alpha: 0.45),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: isSubmitting ? null : onSend,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: t.primary.withValues(alpha: isSubmitting ? 0.45 : 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: isSubmitting
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.send_rounded, color: t.black, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
