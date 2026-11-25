import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../admin/data/datasources/admin_remote_data_source.dart';
import '../../admin/data/repositories/admin_repository_impl.dart';
import '../../admin/domain/repositories/admin_repository.dart';
import '../../admin/presentation/cubit/admin_cubit.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/supabase_provider.dart';
import '../../features/catalog/data/datasources/product_row_decorator.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/cart/data/datasources/cart_remote_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/catalog/data/datasources/catalog_remote_data_source.dart';
import '../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/presentation/cubit/home_cubit.dart';
import '../../features/catalog/presentation/cubit/product_details_cubit.dart';
import '../../features/catalog/presentation/cubit/product_listing_cubit.dart';
import '../../features/favorites/data/datasources/favorites_remote_data_source.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../../features/notifications/data/datasources/notifications_remote_data_source.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/orders/data/datasources/address_remote_data_source.dart';
import '../../features/orders/data/datasources/orders_remote_data_source.dart';
import '../../features/orders/data/repositories/address_repository_impl.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/address_repository.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/presentation/cubit/address_cubit.dart';
import '../../features/orders/presentation/cubit/order_details_cubit.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../localization/locale_cubit.dart';
import '../router/app_router.dart';
import '../theme/theme_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  final preferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(preferences);

  SupabaseClient? client;
  if (AppConstants.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        publishableKey: AppConstants.supabasePublishableKey,
      );
      client = Supabase.instance.client;
    } catch (error) {
      debugPrint('Supabase initialization failed: $error');
    }
  }
  sl.registerSingleton<SupabaseProvider>(SupabaseProvider(client));
  sl.registerLazySingleton(
    () => ProductRowDecorator(sl<SupabaseProvider>().client),
  );

  final localeCubit = LocaleCubit(preferences);
  sl.registerSingleton<LocaleCubit>(localeCubit);
  await localeCubit.load();

  sl.registerSingleton<ThemeCubit>(ThemeCubit(preferences));

  _registerAuth();
  _registerCatalog();
  _registerCart();
  _registerFavorites();
  _registerOrders();
  _registerNotifications();
  _registerAdmin();

  sl.registerLazySingleton<AppRouter>(AppRouter.new);

  await sl<AuthCubit>().start();
}

void _registerAuth() {
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl<SupabaseProvider>().client));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => AuthCubit(sl<AuthRepository>()));
}

void _registerCatalog() {
  sl.registerLazySingleton(
    () => CatalogRemoteDataSource(
          sl<SupabaseProvider>().client,
          sl<ProductRowDecorator>(),
        ),
  );
  sl.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(sl<CatalogRemoteDataSource>()),
  );
  sl.registerFactory(() => HomeCubit(sl<CatalogRepository>()));
  sl.registerFactory(() => ProductListingCubit(sl<CatalogRepository>()));
  sl.registerFactory(() => ProductDetailsCubit(sl<CatalogRepository>()));
}

void _registerCart() {
  sl.registerLazySingleton(
    () => CartRemoteDataSource(
          sl<SupabaseProvider>().client,
          sl<ProductRowDecorator>(),
        ),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl<CartRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => CartCubit(sl<CartRepository>()));
}

void _registerFavorites() {
  sl.registerLazySingleton(
    () => FavoritesRemoteDataSource(
          sl<SupabaseProvider>().client,
          sl<ProductRowDecorator>(),
        ),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(sl<FavoritesRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => FavoritesCubit(sl<FavoritesRepository>()));
}

void _registerOrders() {
  sl.registerLazySingleton(
    () => AddressRemoteDataSource(sl<SupabaseProvider>().client),
  );
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(sl<AddressRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => AddressCubit(sl<AddressRepository>()));

  sl.registerLazySingleton(
    () => OrdersRemoteDataSource(
          sl<SupabaseProvider>().client,
          sl<CartRemoteDataSource>(),
        ),
  );
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(sl<OrdersRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => OrdersCubit(sl<OrdersRepository>()));
  sl.registerFactory(() => OrderDetailsCubit(sl<OrdersRepository>()));
}

void _registerNotifications() {
  sl.registerLazySingleton(
    () => NotificationsRemoteDataSource(sl<SupabaseProvider>().client),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(sl<NotificationsRemoteDataSource>()),
  );
  sl.registerLazySingleton(
    () => NotificationsCubit(sl<NotificationsRepository>()),
  );
}

void _registerAdmin() {
  sl.registerLazySingleton(
    () => AdminRemoteDataSource(
          sl<SupabaseProvider>().client,
          sl<ProductRowDecorator>(),
        ),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl<AdminRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => AdminCubit(sl<AdminRepository>()));
}
