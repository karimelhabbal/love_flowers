import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../app/localization/app_strings.dart';
import '../../../../app/localization/locale_cubit.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/theme_cubit.dart';
import '../../../../core/utils/auth_navigation.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/directional_icons.dart';
import '../../../../core/widgets/flower_mark.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, auth) {
        final user = auth.user;
        return Scaffold(
          appBar: AppBar(
            title: Text(s.t('profile')),
            actions: [
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, mode) => PopupMenuButton<ThemeMode>(
                  tooltip: s.t('theme'),
                  initialValue: mode,
                  onSelected: context.read<ThemeCubit>().setMode,
                  icon: const Icon(Icons.brightness_6_outlined),
                  itemBuilder: (context) => [
                    for (final option in ThemeMode.values)
                      PopupMenuItem(
                        value: option,
                        child: Text(
                          s.t(switch (option) {
                            ThemeMode.system => 'themeSystem',
                            ThemeMode.light => 'themeLight',
                            ThemeMode.dark => 'themeDark',
                          }),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: s.t('language'),
                onPressed: () => context.read<LocaleCubit>().toggleLanguage(),
                icon: const Icon(Icons.translate_rounded),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const FlowerMark(size: 76, showShadow: true),
                      const SizedBox(height: 12),
                      Text(
                        user?.displayName ?? s.t('welcome'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (user != null) ...[
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () => _showEditDialog(
                            context,
                            user.fullName,
                            user.phone,
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: Text(s.t('editProfile')),
                        ),
                      ] else ...[
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () =>
                              goToLogin(context, returnTo: '/profile'),
                          child: Text(s.t('login')),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Column(
                  children: [
                    _Tile(
                      icon: Icons.receipt_long_outlined,
                      label: s.t('myOrders'),
                      onTap: () => context.go('/orders'),
                    ),
                    _Tile(
                      icon: Icons.location_on_outlined,
                      label: s.t('addresses'),
                      onTap: () => context.go('/addresses'),
                    ),
                    _Tile(
                      icon: Icons.favorite_border_rounded,
                      label: s.t('myFavorites'),
                      onTap: () => context.go('/favorites'),
                    ),
                    _Tile(
                      icon: Icons.notifications_none_rounded,
                      label: s.t('notificationsTitle'),
                      onTap: () => context.go('/notifications'),
                    ),
                    if (auth.isAdmin)
                      _Tile(
                        icon: Icons.admin_panel_settings_outlined,
                        label: s.t('dashboard'),
                        onTap: () => context.go('/admin'),
                      ),
                  ],
                ),
              ),
              if (user != null) ...[
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthCubit>().signOut();
                    context.go('/home');
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(s.t('logout')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    String fullName,
    String phone,
  ) async {
    final s = AppStrings.of(context);
    final name = TextEditingController(text: fullName);
    final mobile = TextEditingController(text: phone);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.t('editProfile')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: s.t('fullName'), controller: name),
            const SizedBox(height: 12),
            AppTextField(label: s.t('phone'), controller: mobile),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.t('save')),
          ),
        ],
      ),
    );
    if (saved == true) {
      await di.sl<AuthCubit>().updateProfile(
        fullName: name.text.trim(),
        phone: mobile.text.trim(),
      );
    }
    name.dispose();
    mobile.dispose();
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.sage, size: 21),
      title: Text(label),
      trailing: Icon(DirectionalIcons.forward(context), size: 18),
      onTap: onTap,
    );
  }
}
