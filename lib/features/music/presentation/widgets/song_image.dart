import 'package:flutter/material.dart';

/// Displays a Firestore imagePath containing either an asset path or a URL.
class SongImage extends StatelessWidget {
  const SongImage(
    this.source, {
    super.key,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  final String source;
  final BoxFit fit;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(source);
    final isRemote =
        uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
    return Image(
      image: isRemote ? NetworkImage(source) : AssetImage(source),
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
}
