import 'package:flutter/material.dart';

import '../../app/localization/app_strings.dart';
import '../../app/theme/app_theme.dart';
import '../../features/orders/domain/entities/order.dart';

class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({super.key, required this.status});

  final OrderStatus status;

  static const _steps = [
    Icons.receipt_long_rounded,
    Icons.check_circle_outline_rounded,
    Icons.local_florist_rounded,
    Icons.inventory_2_outlined,
    Icons.delivery_dining_rounded,
    Icons.check_circle_rounded,
  ];

  static const _keys = [
    'statusPending',
    'statusConfirmed',
    'statusPreparing',
    'statusReady',
    'statusOutForDelivery',
    'statusDelivered',
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final current = status.stepIndex;

    if (status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: AppColors.danger),
            const SizedBox(width: 10),
            Text(s.t('statusCancelled')),
          ],
        ),
      );
    }

    return Row(
      children: List.generate(_steps.length, (index) {
        final done = index <= current;
        final isLast = index == _steps.length - 1;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index != 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: done ? AppColors.sage : AppColors.sand,
                      ),
                    ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: done ? AppColors.sage : AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: done ? AppColors.sage : AppColors.sand,
                      ),
                    ),
                    child: Icon(
                      _steps[index],
                      size: 15,
                      color: done ? Colors.white : AppColors.muted,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index < current ? AppColors.sage : AppColors.sand,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Semantics(
                label: s.t(_keys[index]),
                selected: done,
                child: Text(
                  s.t(_keys[index]),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: done
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
