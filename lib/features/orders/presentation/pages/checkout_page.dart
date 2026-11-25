import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../app/localization/app_strings.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../cubit/address_cubit.dart';
import '../cubit/address_state.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final TextEditingController _instructions;
  String _payment = 'cash_on_delivery';
  DateTime? _deliveryDate;
  String? _timeSlot;

  static const _timeSlots = [
    '09:00-12:00',
    '12:00-15:00',
    '15:00-18:00',
    '18:00-21:00',
  ];

  double _deliveryFeeFor(double subtotal) =>
      subtotal >= AppConstants.freeDeliveryThreshold
          ? 0
          : AppConstants.defaultDeliveryFee;

  @override
  void initState() {
    super.initState();
    _instructions = TextEditingController();
    di.sl<OrdersCubit>().startNewCheckoutAttempt();
    di.sl<AddressCubit>().load();
  }

  @override
  void dispose() {
    _instructions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.t('checkout'))),
      body: BlocConsumer<OrdersCubit, OrdersState>(
        bloc: di.sl<OrdersCubit>(),
        listener: (context, state) async {
          if (state.status == OrdersStatus.created &&
              state.lastCreatedOrder != null) {
            // checkout_cart already deletes the items and deactivates the
            // cart server-side, so only refresh the local state here.
            await di.sl<CartCubit>().load();
            if (context.mounted) {
              context.go('/orders/${state.lastCreatedOrder!.id}?placed=true');
            }
          } else if (state.status == OrdersStatus.failure &&
              state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
          }
        },
        builder: (context, _) {
          return BlocBuilder<CartCubit, CartState>(
            builder: (context, cart) {
              return BlocBuilder<AddressCubit, AddressState>(
                builder: (context, addresses) {
                  final address = addresses.defaultAddress;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
                    children: [
                      _Section(
                        title: s.t('shippingAddress'),
                        child: address == null
                            ? _EmptyAddress(
                                onTap: () => context.go('/addresses'),
                              )
                            : ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.sage,
                                ),
                                title: Text(
                                  address.label.isEmpty
                                      ? address.fullName
                                      : address.label,
                                ),
                                subtitle: Text(address.displayLine),
                                trailing: TextButton(
                                  onPressed: () => context.go('/addresses'),
                                  child: Text(s.t('edit')),
                                ),
                              ),
                      ),
                      const SizedBox(height: 18),
                      _Section(
                        title: s.t('deliveryInstructions'),
                        child: TextField(
                          controller: _instructions,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: s.t('deliveryInstructions'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _Section(
                        title: s.t('deliverySchedule'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () async {
                                final now = DateTime.now();
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: now,
                                  firstDate: now,
                                  lastDate: now.add(const Duration(days: 30)),
                                );
                                if (picked != null) {
                                  setState(() => _deliveryDate = picked);
                                }
                              },
                              icon: const Icon(Icons.calendar_today_outlined, size: 18),
                              label: Text(_deliveryDate == null
                                  ? s.t('deliveryDate')
                                  : DateFormat.yMMMd(
                                      s.isArabic ? 'ar_EG' : 'en_US',
                                    ).format(_deliveryDate!)),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              s.t('deliveryTimeSlot'),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final slot in _timeSlots)
                                  ChoiceChip(
                                    label: Text(slot),
                                    selected: _timeSlot == slot,
                                    onSelected: (selected) => setState(
                                      () => _timeSlot = selected ? slot : null,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _Section(
                        title: s.t('giftOptions'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cart.items
                                  .where((item) => item.giftWrap)
                                  .map((item) => item.name(s.isArabic))
                                  .join('، ')
                                  .isEmpty
                                  ? s.t('giftCardSubtitle')
                                  : '${s.t('giftWrap')}: ${cart.items
                                      .where((item) => item.giftWrap)
                                      .map((item) => item.name(s.isArabic))
                                      .join('، ')}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () => context.go('/cart'),
                              icon: const Icon(Icons.card_giftcard_outlined, size: 18),
                              label: Text(s.t('edit')),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _Section(
                        title: s.t('paymentMethod'),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                _payment == 'cash_on_delivery'
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: AppColors.sage,
                              ),
                              title: Text(s.t('cashOnDelivery')),
                              onTap: () =>
                                  setState(() => _payment = 'cash_on_delivery'),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              enabled: false,
                              leading: const Icon(Icons.radio_button_unchecked),
                              title: Text(s.t('cardPayment')),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, orderState) {
          return BlocBuilder<CartCubit, CartState>(
            builder: (context, cart) {
              return BlocBuilder<AddressCubit, AddressState>(
            builder: (context, addressState) {
              final address = addressState.defaultAddress;
              return Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  14 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
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
                    Row(
                      children: [
                        Text(s.t('subtotal'), style: Theme.of(context).textTheme.bodyMedium),
                        const Spacer(),
                        Text(s.money(cart.subtotal), style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(s.t('shipping'), style: Theme.of(context).textTheme.bodyMedium),
                        const Spacer(),
                        Text(
                          _deliveryFeeFor(cart.subtotal) == 0
                              ? s.t('free')
                              : s.money(_deliveryFeeFor(cart.subtotal)),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const Divider(height: 18),
                    Row(
                      children: [
                        Text(s.t('total'),
                            style: Theme.of(context).textTheme.titleMedium),
                        const Spacer(),
                        Text(
                          s.money(cart.subtotal + _deliveryFeeFor(cart.subtotal)),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: (address == null || cart.items.isEmpty)
                          ? null
                          : () {
                              if (_deliveryDate == null || _timeSlot == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      s.t('deliveryScheduleRequired'),
                                    ),
                                  ),
                                );
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(s.t('processing'))),
                              );
                              di.sl<OrdersCubit>().createOrder(
                                    addressId: address.id,
                                    deliveryDate: DateFormat('yyyy-MM-dd')
                                        .format(_deliveryDate!),
                                    deliveryTimeSlot: _timeSlot!,
                                    customerNotes: _instructions.text.trim(),
                                  );
                            },
                      child: orderState.status == OrdersStatus.creating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(s.t('placeOrder')),
                    ),
                  ],
                ),
              );
            },
          );
        },
        );
      },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmptyAddress extends StatelessWidget {
  const _EmptyAddress({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            const Icon(Icons.add_location_alt_outlined, color: AppColors.sage),
            const SizedBox(width: 10),
            Text(s.t('addAddress')),
          ],
        ),
      ),
    );
  }
}
