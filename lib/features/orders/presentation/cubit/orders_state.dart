import 'package:equatable/equatable.dart';

import '../../domain/entities/order.dart';

enum OrdersStatus { initial, loading, ready, failure, creating, created }

class OrdersState extends Equatable {
  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.lastCreatedOrder,
    this.message,
  });

  final OrdersStatus status;
  final List<OrderEntity> orders;
  final OrderEntity? lastCreatedOrder;
  final String? message;

  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderEntity>? orders,
    OrderEntity? lastCreatedOrder,
    bool clearLastCreated = false,
    String? message,
    bool clearMessage = false,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      lastCreatedOrder: clearLastCreated
          ? null
          : (lastCreatedOrder ?? this.lastCreatedOrder),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, orders, lastCreatedOrder, message];
}
