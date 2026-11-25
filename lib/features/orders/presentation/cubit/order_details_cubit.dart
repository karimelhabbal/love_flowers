import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';

enum OrderDetailsStatus { initial, loading, ready, failure }

class OrderDetailsState extends Equatable {
  const OrderDetailsState({
    this.status = OrderDetailsStatus.initial,
    this.order,
    this.events = const [],
    this.message,
  });

  final OrderDetailsStatus status;
  final OrderEntity? order;
  final List<OrderStatusEventEntity> events;
  final String? message;

  @override
  List<Object?> get props => [status, order, events, message];
}

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit(this._repository) : super(const OrderDetailsState());

  final OrdersRepository _repository;

  Future<void> load(String id) async {
    emit(const OrderDetailsState(status: OrderDetailsStatus.loading));
    final orderResult = await _repository.getOrder(id);
    final eventsResult = await _repository.getStatusEvents(id);

    String? error;
    orderResult.fold((_) {}, (failure) => error = failure.message);
    eventsResult.fold((_) {}, (failure) => error ??= failure.message);
    if (error != null) {
      emit(OrderDetailsState(
        status: OrderDetailsStatus.failure,
        message: error,
      ));
      return;
    }

    emit(OrderDetailsState(
      status: OrderDetailsStatus.ready,
      order: orderResult.valueOrNull,
      events: eventsResult.valueOrNull ?? const [],
    ));
  }
}
