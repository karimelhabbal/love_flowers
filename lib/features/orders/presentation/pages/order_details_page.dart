import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../app/localization/app_strings.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/order_status_timeline.dart';
import '../../../../core/widgets/state_views.dart';
import '../cubit/order_details_cubit.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key, required this.orderId, this.placed = false});

  final String orderId;
  final bool placed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<OrderDetailsCubit>()..load(orderId),
      child: _OrderDetailsView(placed: placed, orderId: orderId),
    );
  }
}

class _OrderDetailsView extends StatelessWidget {
  const _OrderDetailsView({required this.placed, required this.orderId});

  final bool placed;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.t('trackOrder'))),
      body: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        builder: (context, state) {
          if (state.status == OrderDetailsStatus.initial ||
              state.status == OrderDetailsStatus.loading) {
            return const LoadingView();
          }
          if (state.status == OrderDetailsStatus.failure || state.order == null) {
            return ErrorView(
              message: state.message ?? s.t('errorGeneric'),
              onRetry: () =>
                  context.read<OrderDetailsCubit>().load(orderId),
            );
          }
          final order = state.order!;
          return RefreshIndicator(
            onRefresh: () => context.read<OrderDetailsCubit>().load(order.id),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 40),
              children: [
                if (placed) _SuccessBanner(),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(s.t('orderNumber'),
                                style: Theme.of(context).textTheme.bodySmall),
                            const Spacer(),
                            Text(
                              order.id.substring(
                                0,
                                order.id.length.clamp(0, 10),
                              ),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        OrderStatusTimeline(status: order.status),
                        const SizedBox(height: 18),
                        if (order.events.isNotEmpty)
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              order.events.last.note.isEmpty
                                  ? s.t(order.events.last.status.labelKey)
                                  : order.events.last.note,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.t('yourOrder'),
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        ...order.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                AppImage(
                                  url: item.imageUrl,
                                  width: 56,
                                  height: 56,
                                  borderRadius: 10,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name(s.isArabic)),
                                      Text(
                                        '${item.quantity} × ${s.money(item.unitPrice)}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      if (item.giftMessage.isNotEmpty)
                                        Text(
                                          item.giftMessage,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                    ],
                                  ),
                                ),
                                Text(s.money(item.lineTotal)),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        _SummaryRow(label: s.t('subtotal'), value: s.money(order.subtotal)),
                        _SummaryRow(label: s.t('shipping'), value: s.money(order.deliveryFee)),
                        _SummaryRow(
                          label: s.t('total'),
                          value: s.money(order.total),
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.t('shippingAddress'),
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          [
                            order.addressSnapshot['full_name'],
                            order.addressSnapshot['street'],
                            order.addressSnapshot['building'],
                            order.addressSnapshot['city'],
                            order.addressSnapshot['phone'],
                          ].where((value) => value != null && value.toString().isNotEmpty).join('، '),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (order.deliveryInstructions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(order.deliveryInstructions,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: bold ? FontWeight.bold : null,
                  color: bold ? AppColors.sage : null,
                ),
          ),
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.sage.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.sage, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.t('orderPlaced'),
                    style: Theme.of(context).textTheme.titleMedium),
                Text(s.t('orderPlacedSubtitle'),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
