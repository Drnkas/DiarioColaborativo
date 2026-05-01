import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CreatePostComposerField extends StatelessWidget {
  const CreatePostComposerField({
    super.key,
    required this.controller,
    required this.theme,
    this.onChanged,
  });

  final TextEditingController controller;
  final AppTheme theme;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: null,
      style: t.body16.copyWith(color: t.black),
      decoration: InputDecoration(
        hintText: 'O que está acontecendo?',
        hintStyle: t.body16.copyWith(color: t.gray),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
