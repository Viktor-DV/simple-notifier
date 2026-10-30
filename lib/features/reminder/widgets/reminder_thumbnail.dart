import 'dart:io';

import 'package:flutter/material.dart';

/// Reminder photo in lists, or the app icon when no photo was added.
class ReminderThumbnail extends StatelessWidget {
  const ReminderThumbnail({
    super.key,
    this.imagePath,
    this.size = 70,
    this.borderRadius = 12,
  });

  static const defaultAsset = 'assets/icon/app_icon.png';

  final String? imagePath;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (imagePath != null) {
      final file = File(imagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _defaultIcon(),
        );
      }
    }
    return _defaultIcon();
  }

  Widget _defaultIcon() {
    return Image.asset(
      defaultAsset,
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }
}
