import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/id_generator.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repository) : super(const OrdersState());

  final OrdersRepository _repository;

  /// One idempotency key per checkout attempt. Retries reuse the same key.
  String? _checkoutKey;

  void startNewCheckoutAttempt() => _checkoutKey = null;

  Future<void> load() async {
    emit(state.copyWith(status: OrdersStatus.loading, clearMessage: true));
    final result = await _repository.getOrders();
    result.fold(
      (orders) => emit(OrdersState(status: OrdersStatus.ready, orders: orders)),
      (failure) => emit(
        OrdersState(status: OrdersStatus.failure, message: failure.message),
      ),
    );
  }

  Future<OrderEntity?> createOrder({
    required String addressId,
    String deliveryDate = '',
    String deliveryTimeSlot = '',
    String customerNotes = '',
  }) async {
    _checkoutKey ??= IdGenerator.uuidV4();
    emit(state.copyWith(status: OrdersStatus.creating, clearMessage: true));
    final result = await _repository.createOrder(
      addressId: addressId,
      checkoutKey: _checkoutKey!,
      deliveryDate: deliveryDate,
      deliveryTimeSlot: deliveryTimeSlot,
      customerNotes: customerNotes,
    );
    return result.fold(
      (order) {
        _checkoutKey = null;
        emit(
          state.copyWith(
            status: OrdersStatus.created,
            lastCreatedOrder: order,
            orders: [order, ...state.orders],
          ),
        );
        return order;
      },
      (failure) {
        emit(
          state.copyWith(
            status: OrdersStatus.failure,
            message: failure.message,
          ),
        );
        return null;
      },
    );
  }

  void clearCreatedOrder() =>
      emit(state.copyWith(clearLastCreated: true, clearMessage: true));
}
