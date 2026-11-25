import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../cart/data/datasources/cart_remote_data_source.dart';
import '../../domain/entities/order.dart';

class OrdersRemoteDataSource {
  OrdersRemoteDataSource(this._client, this._cartDataSource);

  final SupabaseClient? _client;
  final CartRemoteDataSource _cartDataSource;

  SupabaseClient get _db {
    final client = _client;
    if (client == null || !AppConstants.isSupabaseConfigured) {
      throw StateError('Supabase is not configured');
    }
    return client;
  }

  static const _orderSelect =
      '*, order_items(*), order_status_history(*)';

  /// All amounts and stock reservations are computed by this RPC on the
  /// server. The client only sends identifiers and delivery preferences.
  Future<OrderEntity> createOrder({
    required String addressId,
    required String checkoutKey,
    String deliveryDate = '',
    String deliveryTimeSlot = '',
    String customerNotes = '',
  }) async {
    final cartId = await _cartDataSource.currentCartId();
    final response = await _db.rpc<dynamic>(
      'checkout_cart',
      params: <String, dynamic>{
        'p_address_id': addressId,
        'p_cart_id': cartId,
        'p_checkout_key': checkoutKey,
        'p_customer_notes':
            customerNotes.trim().isEmpty ? null : customerNotes.trim(),
        'p_delivery_date': deliveryDate.trim().isEmpty
            ? null
            : deliveryDate.trim(),
        'p_delivery_time_slot': deliveryTimeSlot.trim().isEmpty
            ? null
            : deliveryTimeSlot.trim(),
      },
    );
    // The RPC may return the order id, a boolean success flag or nothing.
    // Reload by checkout_key so the result always comes from Supabase.
    final rows = await _db
        .from('orders')
        .select(_orderSelect)
        .eq('checkout_key', checkoutKey)
        .order('created_at', ascending: false)
        .limit(1);
    if (rows.isEmpty) {
      throw StateError(
        'Checkout completed (rpc=$response) but no order was returned',
      );
    }
    return OrderEntity.fromMap(Map<String, dynamic>.from(rows.first));
  }

  Future<List<OrderEntity>> getOrders() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) throw StateError('Not signed in');
    final rows = await _db
        .from('orders')
        .select(_orderSelect)
        .eq('customer_id', uid)
        .order('created_at', ascending: false);
    return rows
        .map((row) => OrderEntity.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<OrderEntity> getOrder(String id) async {
    final row = await _db
        .from('orders')
        .select(_orderSelect)
        .eq('id', id)
        .single();
    return OrderEntity.fromMap(Map<String, dynamic>.from(row));
  }

  Future<List<OrderStatusEventEntity>> getStatusEvents(String orderId) async {
    final rows = await _db
        .from('order_status_history')
        .select('*')
        .eq('order_id', orderId)
        .order('created_at');
    return rows
        .map((row) =>
            OrderStatusEventEntity.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

}
