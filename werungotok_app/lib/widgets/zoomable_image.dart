import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ZoomableImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final BorderRadius borderRadius;

  const ZoomableImage({
    super.key,
    required this.imageUrl,
    this.height = 180,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Scaffold(
            backgroundColor: Colors.black87,
            body: Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullscreen(context),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            height: height,
            color: Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (_, __, ___) => Container(
            height: height,
            color: Colors.grey.shade200,
            child: const Icon(Icons.image_not_supported),
          ),
        ),
      ),
    );
  }
}
