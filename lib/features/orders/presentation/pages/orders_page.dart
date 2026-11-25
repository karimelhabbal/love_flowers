import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../app/localization/app_strings.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/order.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    di.sl<OrdersCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.t('orderHistory'))),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.status == OrdersStatus.loading ||
              state.status == OrdersStatus.initial) {
            return const LoadingView();
          }
          if (state.status == OrdersStatus.failure) {
            return ErrorView(
              message: state.message ?? s.t('errorGeneric'),
              onRetry: () => di.sl<OrdersCubit>().load(),
            );
          }
          if (state.orders.isEmpty) {
            return EmptyView(
              title: s.t('noOrders'),
              subtitle: s.t('noOrdersSubtitle'),
              icon: Icons.receipt_long_outlined,
              actionLabel: s.t('continueShopping'),
              onAction: () => context.go('/shop'),
            );
          }
          return RefreshIndicator(
            onRefresh: () => di.sl<OrdersCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: state.orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return Card(
                  child: InkWell(
                    onTap: () => context.push('/orders/${order.id}'),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '#${order.id.substring(0, order.id.length.clamp(0, 8))}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: order.status == OrderStatus.cancelled
                                      ? AppColors.danger.withValues(alpha: 0.1)
                                      : AppColors.sage.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  s.t(order.status.labelKey),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: order.status == OrderStatus.cancelled
                                        ? AppColors.danger
                                        : AppColors.sage,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            order.createdAt == null
                                ? ''
                                : DateFormat.yMMMd(
                                    s.isArabic ? 'ar_EG' : 'en_US',
                                  ).add_jm().format(order.createdAt!.toLocal()),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              Text(
                                '${order.items.length} ${s.t('items')}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const Spacer(),
                              Text(
                                s.money(order.total),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: AppColors.sage),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
