import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/cart/presentation/cubit/cart_state.dart';
import '../localization/app_strings.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child, required this.currentPath});

  final Widget child;
  final String currentPath;

  static const _paths = ['/home', '/shop', '/cart', '/favorites', '/profile'];

  static const _icons = [
    Icons.home_outlined,
    Icons.grid_view_outlined,
    Icons.shopping_bag_outlined,
    Icons.favorite_border_rounded,
    Icons.person_outline_rounded,
  ];

  static const _activeIcons = [
    Icons.home_rounded,
    Icons.grid_view_rounded,
    Icons.shopping_bag_rounded,
    Icons.favorite_rounded,
    Icons.person_rounded,
  ];

  static const _labels = ['home', 'shop', 'cart', 'favorites', 'profile'];

  int get _selectedIndex {
    final normalized = currentPath.replaceAll(RegExp(r'/$'), '');
    final exact = _paths.indexOf(normalized);
    if (exact != -1) return exact;
    if (normalized.startsWith('/shop')) return 1;
    if (normalized.startsWith('/cart') || normalized.startsWith('/checkout')) {
      return 2;
    }
    if (normalized.startsWith('/favorites')) return 3;
    if (normalized.startsWith('/profile') ||
        normalized.startsWith('/orders') ||
        normalized.startsWith('/addresses') ||
        normalized.startsWith('/notifications')) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final index = _selectedIndex;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wideLayout = constraints.maxWidth >= 900;
        return Scaffold(
          body: wideLayout
              ? Row(
                  children: [
                    _navigationRail(s, index),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: child,
                        ),
                      ),
                    ),
                  ],
                )
              : child,
          bottomNavigationBar: wideLayout
              ? null
              : _bottomNavigationBar(s, index),
        );
      },
    );
  }

  Widget _bottomNavigationBar(AppStrings s, int index) =>
      BlocBuilder<CartCubit, CartState>(
        builder: (context, cart) => NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => context.go(_paths[value]),
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height: 72,
          indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
          destinations: List.generate(
            5,
            (i) => _destination(s, i, cart.itemCount),
          ),
        ),
      );

  Widget _navigationRail(AppStrings s, int index) =>
      BlocBuilder<CartCubit, CartState>(
        builder: (context, cart) => NavigationRail(
          selectedIndex: index,
          onDestinationSelected: (value) => context.go(_paths[value]),
          labelType: NavigationRailLabelType.all,
          destinations: List.generate(
            5,
            (i) => NavigationRailDestination(
              icon: _navigationIcon(i, cart.itemCount, _icons[i]),
              selectedIcon: _navigationIcon(i, cart.itemCount, _activeIcons[i]),
              label: Text(s.t(_labels[i])),
            ),
          ),
        ),
      );

  NavigationDestination _destination(AppStrings s, int index, int itemCount) =>
      NavigationDestination(
        icon: _navigationIcon(index, itemCount, _icons[index]),
        selectedIcon: _navigationIcon(index, itemCount, _activeIcons[index]),
        label: s.t(_labels[index]),
      );

  Widget _navigationIcon(int index, int itemCount, IconData icon) {
    final badgeCount = index == 2 ? itemCount : 0;
    return badgeCount > 0
        ? Badge(label: Text('$badgeCount'), child: Icon(icon))
        : Icon(icon);
  }
}
