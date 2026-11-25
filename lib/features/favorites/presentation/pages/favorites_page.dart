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
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    final cubit = di.sl<FavoritesCubit>();
    cubit.load();
    cubit.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.t('favorites'))),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.status == FavoritesStatus.initial ||
              state.status == FavoritesStatus.loading) {
            return const LoadingView();
          }
          if (state.status == FavoritesStatus.failure) {
            return ErrorView(
              message: state.message ?? s.t('errorGeneric'),
              onRetry: () => di.sl<FavoritesCubit>().loadProducts(),
            );
          }
          if (state.products.isEmpty) {
            return EmptyView(
              title: s.t('emptyFavorites'),
              subtitle: s.t('emptyFavoritesSubtitle'),
              icon: Icons.favorite_border_rounded,
              actionLabel: s.t('continueShopping'),
              onAction: () => context.go('/shop'),
            );
          }
          return ResponsiveGridView(
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return ProductCard(
                product: product,
                isFavorite: true,
                onTap: () => context.push('/product/${product.id}'),
                onFavorite: () async {
                  await di.sl<FavoritesCubit>().toggle(product.id);
                  di.sl<FavoritesCubit>().loadProducts();
                },
                onAdd: () async {
                  if (!context.read<AuthCubit>().state.isAuthenticated) {
                    goToLogin(context);
                    return;
                  }
                  final ok = await di.sl<CartCubit>().add(productId: product.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(s.t(ok ? 'success' : 'errorGeneric')),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
