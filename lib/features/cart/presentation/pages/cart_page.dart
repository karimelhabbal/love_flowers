import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../app/localization/app_strings.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/auth_navigation.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    if (di.sl<AuthCubit>().state.isAuthenticated) {
      di.sl<CartCubit>().load();
    } else {
      di.sl<CartCubit>().showGuestCart();
    }
  }

  double get _deliveryFee {
    final subtotal = di.sl<CartCubit>().state.subtotal;
    return subtotal >= AppConstants.freeDeliveryThreshold
        ? 0
        : AppConstants.defaultDeliveryFee;
  }

  Future<void> _editGift(
    BuildContext context,
    String itemId,
    String current,
  ) async {
    final s = AppStrings.of(context);
    final controller = TextEditingController(text: current);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.t('giftOptions')),
        content: AppTextField(
          label: s.t('writeMessage'),
          hint: s.t('giftMessageHint'),
          controller: controller,
          maxLines: 3,
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
      await di.sl<CartCubit>().updateGift(
        itemId: itemId,
        giftMessage: controller.text.trim(),
      );
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('cart')),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  di.sl<CartCubit>().clear();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(s.t('success'))));
                },
                child: Text(s.t('clear')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.status == CartStatus.loading ||
              state.status == CartStatus.initial) {
            return const LoadingView();
          }
          if (state.status == CartStatus.failure) {
            return ErrorView(
              message: state.message ?? s.t('errorGeneric'),
              onRetry: () => di.sl<CartCubit>().load(),
            );
          }
          if (state.items.isEmpty) {
            return EmptyView(
              title: s.t('emptyCart'),
              subtitle: s.t('emptyCartSubtitle'),
              icon: Icons.shopping_bag_outlined,
              actionLabel: s.t('continueShopping'),
              onAction: () => context.go('/shop'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppImage(
                              url: item.imageUrl ?? '',
                              width: 82,
                              height: 96,
                              borderRadius: 12,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name(s.isArabic),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s.money(item.unitPrice),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppColors.sage),
                                  ),
                                  if (item.giftMessage.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      item.giftMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _QuantityControl(
                                        quantity: item.quantity,
                                        onChanged: (value) => di
                                            .sl<CartCubit>()
                                            .updateQuantity(item.id, value),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () => _editGift(
                                          context,
                                          item.id,
                                          item.giftMessage,
                                        ),
                                        icon: const Icon(
                                          Icons.card_giftcard_outlined,
                                          size: 19,
                                        ),
                                        tooltip: s.t('giftOptions'),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            di.sl<CartCubit>().remove(item.id),
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 19,
                                          color: AppColors.danger,
                                        ),
                                        tooltip: s.t('remove'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _Summary(
                subtotal: state.subtotal,
                delivery: _deliveryFee,
                onCheckout: () {
                  if (!context.read<AuthCubit>().state.isAuthenticated) {
                    goToLogin(context, returnTo: '/checkout');
                    return;
                  }
                  context.go('/checkout');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.sand),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: s.t('decrease'),
            onPressed: () => onChanged(quantity - 1),
            icon: const Icon(Icons.remove_rounded, size: 15),
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          ),
          Text('$quantity'),
          IconButton(
            tooltip: s.t('increase'),
            onPressed: () => onChanged(quantity + 1),
            icon: const Icon(Icons.add_rounded, size: 15),
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.subtotal,
    required this.delivery,
    required this.onCheckout,
  });

  final double subtotal;
  final double delivery;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        18 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Row(label: s.t('subtotal'), value: s.money(subtotal)),
          const SizedBox(height: 8),
          _Row(
            label: s.t('shipping'),
            value: delivery == 0 ? s.t('free') : s.money(delivery),
          ),
          const Divider(height: 20),
          _Row(
            label: s.t('total'),
            value: s.money(subtotal + delivery),
            bold: true,
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onCheckout,
            child: Text(s.t('proceedCheckout')),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
