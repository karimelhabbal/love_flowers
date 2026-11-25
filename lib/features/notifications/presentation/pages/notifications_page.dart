import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../app/localization/app_strings.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/directional_icons.dart';
import '../../../../core/widgets/state_views.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    di.sl<NotificationsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('notificationsTitle')),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => di.sl<NotificationsCubit>().markAllRead(),
                child: Text(s.t('markAllRead')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.status == NotificationsStatus.initial ||
              state.status == NotificationsStatus.loading) {
            return const LoadingView();
          }
          if (state.status == NotificationsStatus.failure) {
            return ErrorView(
              message: state.message ?? s.t('errorGeneric'),
              onRetry: () => di.sl<NotificationsCubit>().load(),
            );
          }
          if (state.items.isEmpty) {
            return EmptyView(
              title: s.t('noNotifications'),
              subtitle: s.t('noNotificationsSubtitle'),
              icon: Icons.notifications_none_rounded,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: state.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = state.items[index];
              final scheme = Theme.of(context).colorScheme;
              return Card(
                color: scheme.brightness == Brightness.dark
                    ? (item.isRead ? scheme.surface : scheme.secondaryContainer)
                    : (item.isRead ? AppColors.white : AppColors.blush),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.white,
                    child: Icon(
                      Icons.local_florist_outlined,
                      color: AppColors.rose,
                      size: 19,
                    ),
                  ),
                  title: Text(
                    item.title(s.isArabic),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(item.body(s.isArabic)),
                  trailing: item.orderId.isEmpty
                      ? null
                      : Icon(DirectionalIcons.forward(context)),
                  onTap: () {
                    di.sl<NotificationsCubit>().markRead(item.id);
                    if (item.orderId.isNotEmpty) {
                      context.push('/orders/${item.orderId}');
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
