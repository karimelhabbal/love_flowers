import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../app/localization/app_strings.dart';
import '../../../../core/utils/auth_navigation.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../cubit/product_listing_cubit.dart';
import '../cubit/product_listing_state.dart';

class ProductListingPage extends StatelessWidget {
  const ProductListingPage({super.key, this.categoryId, this.initialQuery});

  final String? categoryId;
  final String? initialQuery;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) {
          final cubit = di.sl<ProductListingCubit>();
          cubit.load(categoryId: categoryId, query: initialQuery);
          return cubit;
        }),
        BlocProvider(create: (_) => di.sl<FavoritesCubit>()..load()),
      ],
      child: const _ListingView(),
    );
  }
}

class _ListingView extends StatelessWidget {
  const _ListingView();

  Future<void> _addToCart(BuildContext context, String id) async {
    final s = AppStrings.of(context);
    if (!context.read<AuthCubit>().state.isAuthenticated) {
      goToLogin(context);
      return;
    }
    final ok = await context.read<CartCubit>().add(productId: id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.t(ok ? 'success' : 'errorGeneric'))),
    );
  }

  Future<void> _toggleFavorite(BuildContext context, String id) async {
    if (!context.read<AuthCubit>().state.isAuthenticated) {
      goToLogin(context);
      return;
    }
    await context.read<FavoritesCubit>().toggle(id);
  }

  Future<void> _showFilters(BuildContext context) async {
    final s = AppStrings.of(context);
    final cubit = context.read<ProductListingCubit>();
    final selected = await showModalBottomSheet<ProductSort>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.t('sort'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            RadioGroup<ProductSort>(
              groupValue: cubit.state.sort,
              onChanged: (value) {
                if (value != null) Navigator.pop(context, value);
              },
              child: Column(
                children: ProductSort.values
                    .map(
                      (sort) => RadioListTile<ProductSort>(
                        value: sort,
                        title: Text(s.t(switch (sort) {
                          ProductSort.featured => 'bestSellers',
                          ProductSort.newest => 'newest',
                          ProductSort.priceAsc => 'priceLowHigh',
                          ProductSort.priceDesc => 'priceHighLow',
                          ProductSort.rating => 'ratingHigh',
                        })),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) cubit.setSort(selected);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('products')),
        actions: [
          IconButton(
            tooltip: s.t('search'),
            onPressed: () => context.go('/search'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: s.t('filters'),
            onPressed: () => _showFilters(context),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: BlocBuilder<ProductListingCubit, ProductListingState>(
        builder: (context, state) {
          if (state.status == ListingStatus.initial ||
              state.status == ListingStatus.loading) {
            return const LoadingView();
          }
          if (state.status == ListingStatus.failure) {
            return ErrorView(
              message: state.message ?? s.t('errorGeneric'),
              onRetry: () => context.read<ProductListingCubit>().refresh(),
            );
          }
          if (state.products.isEmpty) {
            return EmptyView(
              title: s.t('noResults'),
              subtitle: s.t('emptySearchSubtitle'),
              icon: Icons.search_off_rounded,
              actionLabel: s.t('clear'),
              onAction: () {
                context.read<ProductListingCubit>().load(
                      categoryId: null,
                      query: '',
                      clearCategory: true,
                    );
              },
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<ProductListingCubit>().refresh(),
            child: ResponsiveGridView(
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, favorites) => ProductCard(
                    product: product,
                    isFavorite: favorites.isFavorite(product.id),
                    onTap: () => context.push('/product/${product.id}'),
                    onFavorite: () => _toggleFavorite(context, product.id),
                    onAdd: () => _addToCart(context, product.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
