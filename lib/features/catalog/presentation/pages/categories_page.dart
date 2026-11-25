import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../app/localization/app_strings.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../core/widgets/state_views.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<HomeCubit>()..load(),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.t('categories'))),
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
          if (state.categories.isEmpty) {
            return EmptyView(
              title: s.t('noCategories'),
              subtitle: s.t('tryAgain'),
              icon: Icons.category_outlined,
              actionLabel: s.t('retry'),
              onAction: () => context.read<HomeCubit>().load(),
            );
          }
          return ResponsiveGridView(
            maxCardWidth: 230,
            itemHeight: 190,
            spacing: 14,
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.go('/shop?category=${category.id}'),
                  child: Column(
                    children: [
                      Expanded(
                        child: AppImage(
                          url: category.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                category.name(s.isArabic),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.sage,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
