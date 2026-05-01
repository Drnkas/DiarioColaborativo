import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickGalleryImageBytes({
  int imageQuality = 80,
  double maxWidth = 1200,
}) async {
  final picker = ImagePicker();
  final xFile = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: imageQuality,
    maxWidth: maxWidth,
  );
  if (xFile == null) return null;
  return xFile.readAsBytes();
}
