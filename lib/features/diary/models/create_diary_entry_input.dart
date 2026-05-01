import 'dart:typed_data';

class CreateDiaryEntryInput {
  const CreateDiaryEntryInput({
    required this.text,
    this.imageBytes = const [],
    required this.cardGradientId,
    this.moodTagId,
  });

  final String text;
  final List<Uint8List> imageBytes;
  final String cardGradientId;
  final String? moodTagId;

  bool get hasNoTextContent => text.trim().isEmpty;

  CreateDiaryEntryInput normalizedCopy() => CreateDiaryEntryInput(
        text: text.trim(),
        imageBytes: imageBytes,
        cardGradientId: cardGradientId,
        moodTagId: moodTagId,
      );
}
