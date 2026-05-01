import 'dart:typed_data';

import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/core/utils/gallery_image_picker.dart';
import 'package:diario_colaborativo/core/widgets/app_loading_overlay.dart';
import 'package:diario_colaborativo/core/widgets/app_user_avatar.dart';
import 'package:diario_colaborativo/di/di.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_cubit.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_state.dart';
import 'package:diario_colaborativo/features/diary/models/create_diary_entry_input.dart';
import 'package:diario_colaborativo/features/diary/models/card_gradient_preset.dart';
import 'package:diario_colaborativo/features/diary/models/mood_tag_preset.dart';
import 'package:diario_colaborativo/features/diary/pages/create_post/widgets/create_post_audience_chip.dart';
import 'package:diario_colaborativo/features/diary/pages/create_post/widgets/create_post_card_color_section.dart';
import 'package:diario_colaborativo/features/diary/pages/create_post/widgets/create_post_composer_field.dart';
import 'package:diario_colaborativo/features/diary/pages/create_post/widgets/create_post_footer_bar.dart';
import 'package:diario_colaborativo/features/diary/pages/create_post/widgets/create_post_header.dart';
import 'package:diario_colaborativo/features/diary/pages/create_post/widgets/create_post_image_thumbnail.dart';
import 'package:diario_colaborativo/features/diary/pages/create_post/widgets/create_post_mood_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final List<Uint8List> _imageBytes = [];
  static const int _maxImages = 6;
  String _selectedGradientId = CardGradientPreset.white.id;
  String? _selectedMoodTagId;
  final _textController = TextEditingController();

  DiaryCubit get _diary => getIt<DiaryCubit>();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_imageBytes.length >= _maxImages) return;
    final bytes = await pickGalleryImageBytes();
    if (bytes == null || !mounted) return;
    setState(() => _imageBytes.add(bytes));
  }

  void _removeImage(int index) {
    setState(() => _imageBytes.removeAt(index));
  }

  Future<void> _submit() async {
    final draft = CreateDiaryEntryInput(
      text: _textController.text,
      imageBytes: _imageBytes,
      cardGradientId: _selectedGradientId,
      moodTagId: _selectedMoodTagId,
    );
    if (draft.hasNoTextContent) return;

    final success = await _diary.createEntry(draft);

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    final user = getIt<SessionCubit>().state.loggedUser;

    return BlocProvider.value(
      value: _diary,
      child: BlocBuilder<DiaryCubit, DiaryState>(
        builder: (context, state) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              body: SafeArea(
                child: AppLoadingOverlay(
                  isLoading: state.isLoading,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      CreatePostHeader(
                        theme: t,
                        onSubmit: _submit,
                        onClose: () => context.pop(),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // User avatar
                                  UserAvatar(photoUrl: user?.photoUrl),

                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Audience chip
                                        CreatePostAudienceChip(theme: t),
                                        const SizedBox(height: 12),

                                        // Composer field
                                        CreatePostComposerField(
                                          controller: _textController,
                                          theme: t,
                                        ),

                                        const SizedBox(height: 20),

                                        // Moods section
                                        Text(
                                          'Como você está?',
                                          style: t.label11.copyWith(
                                            color: t.gray,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Wrap(
                                            spacing: 6,
                                            runSpacing: 8,
                                            children: [
                                              for (final mood in MoodTagPreset.all)
                                                // Mood chip
                                                CreatePostMoodChip(
                                                  mood: mood,
                                                  theme: t,
                                                  isSelected: _selectedMoodTagId == mood.id,
                                                  onTap: () => setState(
                                                    () => _selectedMoodTagId =
                                                        _selectedMoodTagId == mood.id
                                                            ? null
                                                            : mood.id,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // Image thumbnails
                                        if (_imageBytes.isNotEmpty)
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              for (var i = 0; i < _imageBytes.length; i++)
                                                CreatePostImageThumbnail(
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

                      // Card color section
                      CreatePostCardColorSection(
                        theme: t,
                        selectedGradientId: _selectedGradientId,
                        onGradientSelected: (id) => setState(() => _selectedGradientId = id),
                      ),
                      CreatePostFooterBar(theme: t, onPickImage: _pickImage),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
