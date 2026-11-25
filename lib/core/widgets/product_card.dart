import 'package:flutter/material.dart';

import '../../app/localization/app_strings.dart';
import '../../app/theme/app_theme.dart';
import '../../features/catalog/domain/entities/product.dart';
import 'app_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
    required this.onAdd,
    this.width,
  });

  final ProductEntity product;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onAdd;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AppImage(
                    url: product.coverImage ?? '',
                    width: double.infinity,
                    height: 150,
                    borderRadius: 18,
                  ),
                  Positioned(
                    top: 8,
                    right: s.isArabic ? null : 8,
                    left: s.isArabic ? 8 : null,
                    child: _FavoriteButton(
                      isFavorite: isFavorite,
                      onTap: onFavorite,
                      tooltip: s.t(
                        isFavorite ? 'removeFromFavorites' : 'addToFavorites',
                      ),
                    ),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 10,
                      left: s.isArabic ? null : 10,
                      right: s.isArabic ? 10 : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.roseInk,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${product.discountPercent}% ${s.t('off')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name(s.isArabic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.star,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${product.rating.toStringAsFixed(1)} (${product.reviewCount})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Text(
                          s.money(product.effectivePrice),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: product.inStock ? onAdd : null,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(
                          product.inStock
                              ? s.t('addToCart')
                              : s.t('outOfStock'),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.onTap,
    required this.tooltip,
  });

  final bool isFavorite;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite
              ? AppColors.roseInk
              : Theme.of(context).colorScheme.onSurface,
          size: 21,
        ),
        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      ),
    );
  }
}
