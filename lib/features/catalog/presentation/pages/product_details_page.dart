import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../app/localization/app_strings.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/auth_navigation.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../cubit/product_details_cubit.dart';
import '../cubit/product_details_state.dart';
import '../../domain/entities/product_customization.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<ProductDetailsCubit>()..load(productId),
        ),
        BlocProvider(create: (_) => di.sl<FavoritesCubit>()..load()),
      ],
      child: _ProductDetailsView(productId: productId),
    );
  }
}

class _ProductDetailsView extends StatefulWidget {
  const _ProductDetailsView({required this.productId});

  final String productId;

  @override
  State<_ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<_ProductDetailsView> {
  int _quantity = 1;
  bool _giftWrap = false;
  final Set<String> _selectedOptionIds = <String>{};
  final Map<String, int> _flowerQuantities = <String, int>{};
  final Map<String, int> _addonQuantities = <String, int>{};
  final _giftMessage = TextEditingController();
  final _pageController = PageController();
  int _imageIndex = 0;

  @override
  void dispose() {
    _giftMessage.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _addToCart({bool goToCart = false}) async {
    final state = context.read<ProductDetailsCubit>().state;
    final product = state.product;
    if (product == null) return;
    final s = AppStrings.of(context);
    if (!context.read<AuthCubit>().state.isAuthenticated) {
      goToLogin(context);
      return;
    }
    final ok = await context.read<CartCubit>().add(
      productId: product.id,
      quantity: _quantity,
      giftMessage: _giftMessage.text.trim(),
      giftWrap: _giftWrap,
      variantId: product.variantId.isEmpty ? null : product.variantId,
      optionIds: _selectedOptionIds.isEmpty
          ? null
          : _selectedOptionIds.toList(),
      flowers: _flowerQuantities.isEmpty ? null : _flowerQuantities,
      addons: _addonQuantities.isEmpty ? null : _addonQuantities,
    );
    if (!mounted) return;
    if (ok) {
      if (goToCart) {
        context.go('/cart');
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.t('success'))));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.t('errorGeneric'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          if (state.status == DetailsStatus.initial ||
              state.status == DetailsStatus.loading) {
            return const Scaffold(body: LoadingView());
          }
          if (state.status == DetailsStatus.failure || state.product == null) {
            return Scaffold(
              appBar: AppBar(),
              body: ErrorView(
                message: state.message ?? s.t('errorGeneric'),
                onRetry: () =>
                    context.read<ProductDetailsCubit>().load(widget.productId),
              ),
            );
          }
          final product = state.product!;
          return Scaffold(
            bottomNavigationBar: _BottomBar(
              onAdd: () => _addToCart(),
              onBuy: () => _addToCart(goToCart: true),
              enabled: product.inStock,
            ),
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: MediaQuery.sizeOf(context).width >= 700
                      ? 320
                      : 360,
                  pinned: true,
                  backgroundColor: AppColors.cream,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: product.imageUrls.isEmpty
                              ? 1
                              : product.imageUrls.length,
                          onPageChanged: (value) =>
                              setState(() => _imageIndex = value),
                          itemBuilder: (context, index) => AppImage(
                            url: product.imageUrls.isEmpty
                                ? ''
                                : product.imageUrls[index],
                            width: double.infinity,
                            height: MediaQuery.sizeOf(context).width >= 700
                                ? 320
                                : 360,
                          ),
                        ),
                        Positioned(
                          bottom: 36,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              product.imageUrls.isEmpty
                                  ? 1
                                  : product.imageUrls.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: index == _imageIndex ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: index == _imageIndex
                                      ? AppColors.sage
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, favorites) => IconButton(
                        tooltip: s.t(
                          favorites.isFavorite(product.id)
                              ? 'removeFromFavorites'
                              : 'addToFavorites',
                        ),
                        onPressed: () async {
                          if (!context
                              .read<AuthCubit>()
                              .state
                              .isAuthenticated) {
                            goToLogin(context);
                            return;
                          }
                          await context.read<FavoritesCubit>().toggle(
                            product.id,
                          );
                        },
                        icon: Icon(
                          favorites.isFavorite(product.id)
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: favorites.isFavorite(product.id)
                              ? AppColors.roseInk
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blush,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.categoryName(s.isArabic),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xFFE5A23C),
                            ),
                            Text(
                              '${product.rating.toStringAsFixed(1)} (${product.reviewCount})',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          product.name(s.isArabic),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              s.money(product.effectivePrice),
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: AppColors.sage),
                            ),
                            if (product.hasDiscount) ...[
                              const SizedBox(width: 10),
                              Text(
                                s.money(product.price),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: AppColors.muted,
                                    ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          product.description(s.isArabic).isEmpty
                              ? s.t('flowerCare')
                              : product.description(s.isArabic),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(height: 1.8),
                        ),
                        const Divider(height: 34),
                        Row(
                          children: [
                            Text(
                              s.t('quantity'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            _QuantityStepper(
                              value: _quantity,
                              onChange: (value) =>
                                  setState(() => _quantity = value),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _GiftOptions(
                          giftWrap: _giftWrap,
                          controller: _giftMessage,
                          onChanged: (value) =>
                              setState(() => _giftWrap = value),
                        ),
                        const SizedBox(height: 20),
                        _CustomizationSection(
                          customization: state.customization,
                          isArabic: s.isArabic,
                          selectedOptionIds: _selectedOptionIds,
                          flowerQuantities: _flowerQuantities,
                          addonQuantities: _addonQuantities,
                          enabled: product.allowCustomization,
                          onOptionChanged: (optionId, selected) => setState(() {
                            if (selected) {
                              _selectedOptionIds.add(optionId);
                            } else {
                              _selectedOptionIds.remove(optionId);
                            }
                          }),
                          onFlowerChanged: (flowerTypeId, quantity) =>
                              setState(() {
                                if (quantity < 1) {
                                  _flowerQuantities.remove(flowerTypeId);
                                } else {
                                  _flowerQuantities[flowerTypeId] = quantity;
                                }
                              }),
                          onAddonChanged: (addonVariantId, quantity) =>
                              setState(() {
                                if (quantity < 1) {
                                  _addonQuantities.remove(addonVariantId);
                                } else {
                                  _addonQuantities[addonVariantId] = quantity;
                                }
                              }),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Icon(
                              product.inStock
                                  ? Icons.check_circle_outline
                                  : Icons.remove_shopping_cart_outlined,
                              color: product.inStock
                                  ? AppColors.success
                                  : AppColors.danger,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              s.t(product.inStock ? 'inStock' : 'outOfStock'),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.value,
    required this.onChange,
    this.min = 1,
  });

  final int value;
  final ValueChanged<int> onChange;
  final int min;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sand),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: s.t('decrease'),
            onPressed: () => onChange(value > min ? value - 1 : min),
            icon: const Icon(Icons.remove_rounded, size: 18),
          ),
          Text('$value', style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            tooltip: s.t('increase'),
            onPressed: () => onChange(value + 1),
            icon: const Icon(Icons.add_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _GiftOptions extends StatelessWidget {
  const _GiftOptions({
    required this.giftWrap,
    required this.controller,
    required this.onChanged,
  });

  final bool giftWrap;
  final TextEditingController controller;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.card_giftcard_rounded, color: AppColors.rose),
                const SizedBox(width: 10),
                Text(
                  s.t('giftOptions'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: giftWrap,
              onChanged: onChanged,
              title: Text(s.t('giftWrap')),
            ),
            const SizedBox(height: 8),
            AppTextField(
              label: s.t('writeMessage'),
              hint: s.t('giftMessageHint'),
              controller: controller,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomizationSection extends StatelessWidget {
  const _CustomizationSection({
    required this.customization,
    required this.isArabic,
    required this.selectedOptionIds,
    required this.flowerQuantities,
    required this.addonQuantities,
    required this.onOptionChanged,
    required this.onFlowerChanged,
    required this.onAddonChanged,
    this.enabled = true,
  });

  final ProductCustomizationEntity customization;
  final bool isArabic;
  final Set<String> selectedOptionIds;
  final Map<String, int> flowerQuantities;
  final Map<String, int> addonQuantities;
  final void Function(String optionId, bool selected) onOptionChanged;
  final void Function(String flowerTypeId, int quantity) onFlowerChanged;
  final void Function(String addonVariantId, int quantity) onAddonChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    if (!enabled || customization.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune_rounded, color: AppColors.sage),
                const SizedBox(width: 10),
                Text(
                  s.t('customization'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            for (final group in customization.groups) ...[
              const SizedBox(height: 14),
              Text(
                '${group.name(isArabic)}${group.isRequired ? ' *' : ''}',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final option in group.options)
                    FilterChip(
                      label: Text(
                        option.priceDeltaEgp > 0
                            ? '${option.name(isArabic)} (+${option.priceDeltaEgp.toStringAsFixed(0)})'
                            : option.name(isArabic),
                      ),
                      selected: selectedOptionIds.contains(option.id),
                      onSelected: (value) {
                        final selectedCount = group.options
                            .where(
                              (item) => selectedOptionIds.contains(item.id),
                            )
                            .length;
                        if (value &&
                            group.maxSelections > 0 &&
                            selectedCount >= group.maxSelections) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${s.t('maxSelections')}: ${group.maxSelections}',
                              ),
                            ),
                          );
                          return;
                        }
                        onOptionChanged(option.id, value);
                      },
                    ),
                ],
              ),
            ],
            for (final flower in customization.flowers) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      flower.name(isArabic).isEmpty
                          ? s.t('flowers')
                          : flower.name(isArabic),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  _QuantityStepper(
                    min: 0,
                    value: flowerQuantities[flower.flowerTypeId] ?? 0,
                    onChange: (value) =>
                        onFlowerChanged(flower.flowerTypeId, value),
                  ),
                ],
              ),
            ],
            for (final addon in customization.addons) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      addon.name(isArabic).isEmpty
                          ? s.t('addons')
                          : '${addon.name(isArabic)} (+${addon.priceEgp.toStringAsFixed(0)})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  _QuantityStepper(
                    min: 0,
                    value: addonQuantities[addon.addonVariantId] ?? 0,
                    onChange: (value) {
                      if (value > addon.maxQuantity) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${s.t('maxQuantity')}: ${addon.maxQuantity}',
                            ),
                          ),
                        );
                        return;
                      }
                      onAddonChanged(addon.addonVariantId, value);
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.onAdd,
    required this.onBuy,
    required this.enabled,
  });

  final VoidCallback onAdd;
  final VoidCallback onBuy;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: enabled ? onAdd : null,
              child: Text(s.t('addToCart')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: enabled ? onBuy : null,
              child: Text(s.t('buyNow')),
            ),
          ),
        ],
      ),
    );
  }
}
