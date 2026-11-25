import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../app/localization/app_strings.dart';
import '../../../../app/localization/locale_cubit.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/auth_navigation.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/flower_mark.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../notifications/presentation/cubit/notifications_state.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<HomeCubit>()..load()),
        BlocProvider(create: (_) => di.sl<FavoritesCubit>()..load()),
        BlocProvider(create: (_) => di.sl<CartCubit>()..load()),
        BlocProvider(create: (_) => di.sl<NotificationsCubit>()..load()),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  Future<void> _addToCart(BuildContext context, String productId) async {
    final auth = context.read<AuthCubit>().state;
    final s = AppStrings.of(context);
    if (!auth.isAuthenticated) {
      goToLogin(context);
      return;
    }
    final ok = await context.read<CartCubit>().add(productId: productId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.t(ok ? 'success' : 'errorGeneric')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context, String productId) async {
    final auth = context.read<AuthCubit>().state;
    if (!auth.isAuthenticated) {
      goToLogin(context);
      return;
    }
    await context.read<FavoritesCubit>().toggle(productId);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsetsDirectional.only(start: 12),
          child: FlowerMark(size: 40),
        ),
        title: Text(s.isArabic ? 'زهور الحب' : 'Love Flowers'),
        actions: [
          IconButton(
            tooltip: s.t('language'),
            onPressed: () => context.read<LocaleCubit>().toggleLanguage(),
            icon: const Icon(Icons.translate_rounded),
          ),
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, notifications) => IconButton(
              tooltip: s.t('notifications'),
              onPressed: () => context.go('/notifications'),
              icon: Badge(
                isLabelVisible: notifications.unreadCount > 0,
                label: Text('${notifications.unreadCount}'),
                child: const Icon(Icons.notifications_none_rounded),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading ||
              state.status == HomeStatus.initial) {
            return const LoadingView();
          }
          if (state.status == HomeStatus.failure) {
            return ErrorView(
              message: state.message ?? s.t('errorGeneric'),
              onRetry: () => context.read<HomeCubit>().load(),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
              children: [
                _SearchBar(onTap: () => context.go('/search')),
                const SizedBox(height: 18),
                _HeroCard(products: state.featured),
                const SizedBox(height: 28),
                SectionHeader(
                  title: s.t('popularCategories'),
                  onSeeAll: () => context.go('/categories'),
                ),
                const SizedBox(height: 14),
                _CategoryStrip(categories: state.categories),
                const SizedBox(height: 28),
                SectionHeader(
                  title: s.t('bestSellers'),
                  onSeeAll: () => context.go('/shop'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 286,
                  child: state.featured.isEmpty
                      ? Center(child: Text(s.t('noProducts')))
                      : BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, favorites) => ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.featured.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final product = state.featured[index];
                        return ProductCard(
                          product: product,
                          width: 178,
                          isFavorite: favorites.isFavorite(product.id),
                          onTap: () => context.push('/product/${product.id}'),
                          onFavorite: () => _toggleFavorite(context, product.id),
                          onAdd: () => _addToCart(context, product.id),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _SameDayBanner(),
                const SizedBox(height: 28),
                SectionHeader(
                  title: s.t('newArrivals'),
                  onSeeAll: () => context.go('/shop'),
                ),
                const SizedBox(height: 14),
                state.newArrivals.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text(s.t('noProducts'))),
                      )
                    : BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, favorites) => ResponsiveGridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.newArrivals.length,
                    itemBuilder: (context, index) {
                      final product = state.newArrivals[index];
                      return ProductCard(
                        product: product,
                        isFavorite: favorites.isFavorite(product.id),
                        onTap: () => context.push('/product/${product.id}'),
                        onFavorite: () => _toggleFavorite(context, product.id),
                        onAdd: () => _addToCart(context, product.id),
                      );
                    },
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.muted, size: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                s.t('searchHint'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                    ),
              ),
            ),
            const Icon(Icons.tune_rounded, color: AppColors.sage, size: 20),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatefulWidget {
  const _HeroCard({required this.products});

  final List<ProductEntity> products;

  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard> {
  final _controller = PageController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final slides = <_HeroSlide>[
      _HeroSlide(
        title: s.t('hero1Title'),
        subtitle: s.t('hero1Subtitle'),
        image: widget.products.isNotEmpty
            ? widget.products.first.coverImage ?? ''
            : '',
      ),
      _HeroSlide(
        title: s.t('onboarding2Title'),
        subtitle: s.t('onboarding2Body'),
        image: widget.products.length > 1
            ? widget.products[1].coverImage ?? ''
            : '',
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, index) {
              final slide = slides[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: AppColors.blush,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AppImage(url: slide.image, fit: BoxFit.cover),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.white.withValues(alpha: 0.94),
                              AppColors.white.withValues(alpha: 0.45),
                            ],
                            begin: s.isArabic
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            end: s.isArabic
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slide.title,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 20,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slide.subtitle,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () => context.go('/shop'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(110, 38),
                            ),
                            child: Text(
                              s.t('shopNow'),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) => Semantics(
            button: true,
            selected: index == _index,
            label: '${s.t('shopNow')} ${index + 1}',
            child: InkWell(
              onTap: () => _controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == _index ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: index == _index
                      ? Theme.of(context).colorScheme.primary
                      : AppColors.sand,
                ),
              ),
            ),
          )),
        ),
      ],
    );
  }
}

class _HeroSlide {
  const _HeroSlide({required this.title, required this.subtitle, required this.image});
  final String title;
  final String subtitle;
  final String image;
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.categories});

  final List<CategoryEntity> categories;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    if (categories.isEmpty) {
      return SizedBox(
        height: 76,
        child: Center(
          child: Text(s.t('noCategories'), style: Theme.of(context).textTheme.bodySmall),
        ),
      );
    }
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkResponse(
            onTap: () => context.go('/shop?category=${category.id}'),
            radius: 36,
            child: Column(
              children: [
                ClipOval(
                  child: category.imageUrl.isEmpty
                      ? Container(
                          width: 54,
                          height: 54,
                          color: Theme.of(context).colorScheme.surface,
                          child: Icon(
                            Icons.local_florist_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : AppImage(
                          url: category.imageUrl,
                          width: 54,
                          height: 54,
                        ),
                ),
                const SizedBox(height: 6),
                Text(
                  category.name(s.isArabic),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SameDayBanner extends StatelessWidget {
  const _SameDayBanner();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.t('sameDayTitle'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.t('sameDaySubtitle'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.delivery_dining_rounded,
              size: 46, color: AppColors.sage),
        ],
      ),
    );
  }
}
