import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../admin/presentation/pages/admin_page.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/catalog/presentation/pages/categories_page.dart';
import '../../features/catalog/presentation/pages/home_page.dart';
import '../../features/catalog/presentation/pages/product_details_page.dart';
import '../../features/catalog/presentation/pages/product_listing_page.dart';
import '../../features/catalog/presentation/pages/search_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/orders/presentation/pages/addresses_page.dart';
import '../../features/orders/presentation/pages/checkout_page.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../di/injection_container.dart';
import '../localization/app_strings.dart';
import '../navigation/main_shell.dart';

class AppRouter {
  AppRouter() {
    _router = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: false,
      redirect: _redirect,
      errorBuilder: (context, state) {
        final s = AppStrings.of(context);
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48),
                const SizedBox(height: 12),
                Text(
                  s.t('notFound'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Text(
                    s.t('errorGeneric'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: Text(s.t('home')),
                ),
              ],
            ),
          ),
        );
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashPage()),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        ShellRoute(
          builder: (context, state, child) =>
              MainShell(currentPath: state.uri.path, child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: '/categories',
              builder: (context, state) => const CategoriesPage(),
            ),
            GoRoute(
              path: '/shop',
              builder: (context, state) => ProductListingPage(
                categoryId: state.uri.queryParameters['category'],
              ),
            ),
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchPage(),
            ),
            GoRoute(
              path: '/cart',
              builder: (context, state) => const CartPage(),
            ),
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesPage(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
        GoRoute(
          path: '/product/:id',
          builder: (context, state) =>
              ProductDetailsPage(productId: state.pathParameters['id'] ?? ''),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutPage(),
        ),
        GoRoute(
          path: '/addresses',
          builder: (context, state) => const AddressesPage(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrdersPage(),
        ),
        GoRoute(
          path: '/orders/:id',
          builder: (context, state) => OrderDetailsPage(
            orderId: state.pathParameters['id'] ?? '',
            placed: state.uri.queryParameters['placed'] == 'true',
          ),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(path: '/admin', builder: (context, state) => const AdminPage()),
      ],
    );
  }

  late final GoRouter _router;
  GoRouter get router => _router;

  String? _redirect(BuildContext context, GoRouterState state) {
    final path = state.uri.path;
    final auth = sl<AuthCubit>().state;
    final requiresLogin =
        path.startsWith('/checkout') ||
        path.startsWith('/addresses') ||
        path.startsWith('/orders') ||
        path.startsWith('/favorites') ||
        path.startsWith('/notifications') ||
        path.startsWith('/admin');

    String? safeReturn(String? value) =>
        value != null && value.startsWith('/') && !value.startsWith('//')
        ? value
        : null;

    if (requiresLogin && auth.status == AuthStatus.unauthenticated) {
      final then = Uri.encodeComponent(state.uri.toString());
      return '/login?then=$then';
    }
    if (path.startsWith('/admin') && auth.isAuthenticated && !auth.isAdmin) {
      return '/home';
    }
    if ((path == '/login' || path == '/register') && auth.isAuthenticated) {
      return safeReturn(state.uri.queryParameters['then']) ?? '/home';
    }
    return null;
  }
}
