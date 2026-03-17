import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double iconSize;
  final BorderRadius? borderRadius;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.iconSize = 40,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) => Container(
        height: height,
        width: width,
        color: const Color(0xFFF0F4FF),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: height,
        width: width,
        color: const Color(0xFFF0F4FF),
        child: Icon(
          Icons.directions_car,
          size: iconSize,
          color: Colors.grey.shade400,
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}