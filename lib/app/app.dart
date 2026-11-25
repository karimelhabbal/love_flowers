import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../admin/presentation/cubit/admin_cubit.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/cart/presentation/cubit/cart_cubit.dart';
import '../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../features/orders/presentation/cubit/address_cubit.dart';
import '../features/orders/presentation/cubit/orders_cubit.dart';
import 'di/injection_container.dart';
import 'localization/app_strings.dart';
import 'localization/locale_cubit.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_cubit.dart';

class LoveFlowersApp extends StatelessWidget {
  const LoveFlowersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<LocaleCubit>()),
        BlocProvider.value(value: sl<ThemeCubit>()),
        BlocProvider.value(value: sl<AuthCubit>()),
        BlocProvider.value(value: sl<CartCubit>()),
        BlocProvider.value(value: sl<FavoritesCubit>()),
        BlocProvider.value(value: sl<OrdersCubit>()),
        BlocProvider.value(value: sl<AddressCubit>()),
        BlocProvider.value(value: sl<NotificationsCubit>()),
        BlocProvider.value(value: sl<AdminCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, locale) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              return MaterialApp.router(
                title: 'Love Flowers',
                debugShowCheckedModeBanner: false,
                locale: locale.locale,
                supportedLocales: AppStrings.supportedLocales,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: mode,
                routerConfig: sl<AppRouter>().router,
              );
            },
          );
        },
      ),
    );
  }
}
