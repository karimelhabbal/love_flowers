import '../../../../core/error/result.dart';
import '../../../../core/utils/repository_guard.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._remote);

  final OrdersRemoteDataSource _remote;

  @override
  Future<Result<OrderEntity>> createOrder({
    required String addressId,
    required String checkoutKey,
    String deliveryDate = '',
    String deliveryTimeSlot = '',
    String customerNotes = '',
  }) =>
      runSafe(() => _remote.createOrder(
            addressId: addressId,
            checkoutKey: checkoutKey,
            deliveryDate: deliveryDate,
            deliveryTimeSlot: deliveryTimeSlot,
            customerNotes: customerNotes,
          ));

  @override
  Future<Result<List<OrderEntity>>> getOrders() => runSafe(_remote.getOrders);

  @override
  Future<Result<OrderEntity>> getOrder(String id) =>
      runSafe(() => _remote.getOrder(id));

  @override
  Future<Result<List<OrderStatusEventEntity>>> getStatusEvents(String orderId) =>
      runSafe(() => _remote.getStatusEvents(orderId));
}
