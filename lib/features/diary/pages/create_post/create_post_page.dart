import 'dart:typed_data';

import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/core/widgets/app_user_avatar.dart';
import 'package:diario_colaborativo/di/di.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_cubit.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_state.dart';
import 'package:diario_colaborativo/features/diary/models/card_gradient_preset.dart';
import 'package:diario_colaborativo/features/diary/models/mood_tag_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  String _text = '';
  final List<Uint8List> _imageBytes = [];
  static const int _maxImages = 6;
  String _selectedGradientId = CardGradientPreset.white.id;
  String? _selectedMoodTagId;
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_imageBytes.length >= _maxImages) return;

    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (xFile != null) {
      final bytes = await xFile.readAsBytes();
      setState(() => _imageBytes.add(bytes));
    }
  }

  void _removeImage(int index) {
    setState(() => _imageBytes.removeAt(index));
  }

  Future<void> _submit() async {
    if (_text.trim().isEmpty) return;

    final success = await getIt<DiaryCubit>().createEntry(
      text: _text,
      imageBytes: _imageBytes,
      cardGradientId: _selectedGradientId,
      moodTagId: _selectedMoodTagId,
    );

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    final user = getIt<SessionCubit>().state.loggedUser;

    return BlocProvider.value(
      value: getIt<DiaryCubit>(),
      child: BlocBuilder<DiaryCubit, DiaryState>(
        builder: (context, state) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              body: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        _Header(t: t, onSubmit: _submit, onClose: () => context.pop()),
                        // Body
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),

                                // Content
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Avatar
                                    UserAvatar(photoUrl: user?.photoUrl),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Audience
                                          _AudienceChip(t: t),
                                          const SizedBox(height: 12),

                                          // Textarea
                                          _ComposerField(
                                            controller: _textController,
                                            t: t,
                                            onChanged: (v) => setState(() => _text = v),
                                          ),
                                          const SizedBox(height: 20),

                                          //Moods section
                                          Text(
                                            'Como você está?',
                                            style: t.label11.copyWith(
                                                color: t.gray, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 8),

                                          // Moods Chips
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Wrap(
                                              spacing: 6,
                                              runSpacing: 8,
                                              children: [
                                                for (final mood in MoodTagPreset.all)
                                                  _MoodChip(
                                                    mood: mood,
                                                    t: t,
                                                    isSelected: _selectedMoodTagId == mood.id,
                                                    onTap: () => setState(() => _selectedMoodTagId =
                                                        _selectedMoodTagId == mood.id
                                                            ? null
                                                            : mood.id),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          if (_imageBytes.isNotEmpty)
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                for (var i = 0; i < _imageBytes.length; i++)
                                                  _ImageThumbnail(
                                                    bytes: _imageBytes[i],
                                                    onRemove: () => _removeImage(i),
                                                  ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Color card select
                        SizedBox(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cor do card',
                                  style: t.label11
                                      .copyWith(color: t.gray, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    for (final preset in CardGradientPreset.all)
                                      _GradientChip(
                                        preset: preset,
                                        isSelected: _selectedGradientId == preset.id,
                                        onTap: () =>
                                            setState(() => _selectedGradientId = preset.id),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        _FooterBar(t: t, onPickImage: _pickImage),
                      ],
                    ),
                    if (state.isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black26,
                          child: Center(
                            child: CircularProgressIndicator(color: t.primary),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.t,
    required this.onSubmit,
    required this.onClose,
  });

  final AppTheme t;
  final VoidCallback onSubmit;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
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
              child: Text('Rascunhos', style: t.body14Bold.copyWith(color: t.black, fontSize: 12)),
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
              child:
                  Text('Publicar', style: t.body14Bold.copyWith(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.mood,
    required this.t,
    this.isSelected = false,
    required this.onTap,
  });

  final MoodTagPreset mood;
  final AppTheme t;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected ? t.primary : t.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: isSelected ? Border.all(color: t.details, width: 0.5) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mood.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(mood.label,
                  style: t.label11.copyWith(
                      fontSize: 13,
                      color: isSelected ? Colors.white : t.black.withValues(alpha: 0.5),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientChip extends StatelessWidget {
  const _GradientChip({
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
                color: Colors.black.withOpacity(0.08),
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

class _AudienceChip extends StatelessWidget {
  const _AudienceChip({required this.t});

  final AppTheme t;

  @override
  Widget build(BuildContext context) {
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

class _ComposerField extends StatelessWidget {
  const _ComposerField({
    required this.controller,
    required this.t,
    required this.onChanged,
  });

  final TextEditingController controller;
  final AppTheme t;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
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

class _FooterBar extends StatelessWidget {
  const _FooterBar({required this.t, required this.onPickImage});

  final AppTheme t;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(top: BorderSide(color: t.gray.withOpacity(0.2))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.public, size: 14, color: t.gray),
              const SizedBox(width: 6),
              Text('Todos podem responder', style: t.label11.copyWith(color: t.gray)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ActionIcon(icon: Icons.add_photo_alternate_outlined, onTap: onPickImage, t: t),
              const SizedBox(width: 20),
              _ActionIcon(icon: Icons.bar_chart_outlined, onTap: () {}, t: t),
              const SizedBox(width: 20),
              _ActionIcon(icon: Icons.emoji_emotions_outlined, onTap: () {}, t: t),
              const SizedBox(width: 20),
              _ActionIcon(icon: Icons.location_on_outlined, onTap: () {}, t: t),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.onTap, required this.t});

  final IconData icon;
  final VoidCallback onTap;
  final AppTheme t;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 24, color: t.primary),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  const _ImageThumbnail({
    required this.bytes,
    required this.onRemove,
  });

  final Uint8List bytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
