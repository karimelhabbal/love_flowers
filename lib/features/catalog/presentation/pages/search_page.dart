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
import '../cubit/product_listing_cubit.dart';
import '../cubit/product_listing_state.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ProductListingCubit>()..load()),
        BlocProvider(create: (_) => di.sl<FavoritesCubit>()..load()),
      ],
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) =>
              context.read<ProductListingCubit>().setQuery(value),
          decoration: InputDecoration(
            hintText: s.t('searchHint'),
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: IconButton(
              tooltip: s.t('clear'),
              onPressed: () {
                _controller.clear();
                context.read<ProductListingCubit>().setQuery('');
              },
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
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
              title: s.t('emptySearch'),
              subtitle: s.t('emptySearchSubtitle'),
              icon: Icons.search_off_rounded,
            );
          }
          return BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, favorites) => ResponsiveGridView(
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return ProductCard(
                  product: product,
                  isFavorite: favorites.isFavorite(product.id),
                  onTap: () => context.push('/product/${product.id}'),
                  onFavorite: () async {
                    if (!context.read<AuthCubit>().state.isAuthenticated) {
                      goToLogin(context);
                      return;
                    }
                    await context.read<FavoritesCubit>().toggle(product.id);
                  },
                  onAdd: () => _addToCart(context, product.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
