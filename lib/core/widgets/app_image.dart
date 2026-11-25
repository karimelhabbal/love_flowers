import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius = 0,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final child = url.isEmpty
        ? const DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
            ),
            child: Center(
              child: Icon(
                Icons.local_florist_outlined,
                color: AppColors.sage,
                size: 44,
              ),
            ),
          )
        : CachedNetworkImage(
            imageUrl: url,
            fit: fit,
            width: width,
            height: height,
            placeholder: (_, _) => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (_, _, _) => const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.heroGradient),
              child: Center(
                child: Icon(
                  Icons.local_florist_outlined,
                  color: AppColors.sage,
                  size: 44,
                ),
              ),
            ),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}
