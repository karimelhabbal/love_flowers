import '../../../../core/error/result.dart';
import '../entities/order.dart';

abstract interface class OrdersRepository {
  /// Prices, totals and stock reservations are computed by the Supabase
  /// checkout_cart RPC. [checkoutKey] must stay stable for one attempt.
  Future<Result<OrderEntity>> createOrder({
    required String addressId,
    required String checkoutKey,
    String deliveryDate = '',
    String deliveryTimeSlot = '',
    String customerNotes = '',
  });

  Future<Result<List<OrderEntity>>> getOrders();

  Future<Result<OrderEntity>> getOrder(String id);

  Future<Result<List<OrderStatusEventEntity>>> getStatusEvents(String orderId);
}
