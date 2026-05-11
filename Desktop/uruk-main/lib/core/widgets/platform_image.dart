import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Cross-platform image widget for files picked via image_picker.
///
/// Mobile (iOS/Android): renders via [Image.file] using dart:io.
/// Web: reads bytes from the [XFile] and renders via [Image.memory]
/// (Image.file is not supported on web).
class PlatformImage extends StatelessWidget {
  final XFile file;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const PlatformImage(
    this.file, {
    super.key,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // On web, XFile.path is a blob URL. We read the bytes and show them.
      return FutureBuilder(
        future: file.readAsBytes(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return SizedBox(
              width: width,
              height: height,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          if (snap.hasError || snap.data == null) {
            return SizedBox(
              width: width,
              height: height,
              child: const Icon(Icons.broken_image),
            );
          }
          return Image.memory(snap.data!, width: width, height: height, fit: fit);
        },
      );
    }
    return Image.file(File(file.path), width: width, height: height, fit: fit);
  }
}
