import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/auth/domain/entities/app_user.dart';
import '../../../features/catalog/data/datasources/product_row_decorator.dart';
import '../../../features/catalog/domain/entities/category.dart';
import '../../../features/catalog/domain/entities/product.dart';
import '../../../features/orders/domain/entities/order.dart';

class AdminRemoteDataSource {
  AdminRemoteDataSource(this._client, this._decorator);

  final SupabaseClient? _client;
  final ProductRowDecorator _decorator;

  SupabaseClient get _db {
    final client = _client;
    if (client == null || !AppConstants.isSupabaseConfigured) {
      throw StateError('Supabase is not configured');
    }
    return client;
  }

  Future<void> _ensureAdmin() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) throw StateError('Not signed in');
    final row = await _db
        .from('profiles')
        .select('role')
        .eq('id', uid)
        .maybeSingle();
    if (row?['role'] != 'admin') throw StateError('Admin only');
  }

  Future<List<ProductEntity>> getProducts() async {
    await _ensureAdmin();
    final rows = await _db
        .from('products')
        .select('*')
        .order('created_at', ascending: false);
    return _decorator.decorate(
      rows.map((row) => Map<String, dynamic>.from(row)).toList(),
    );
  }

  Future<ProductEntity> saveProduct(ProductEntity product) async {
    await _ensureAdmin();
    final payload = product.toMap()..remove('id');
    final Map<String, dynamic> row;
    if (product.id.isEmpty) {
      row = Map<String, dynamic>.from(
        await _db.from('products').insert(payload).select('*').single(),
      );
    } else {
      row = Map<String, dynamic>.from(
        await _db
            .from('products')
            .update(payload)
            .eq('id', product.id)
            .select('*')
            .single(),
      );
    }

    if (product.price > 0) {
      final productId = row['id'] as String;
      final variant = await _db
          .from('product_variants')
          .select('id')
          .eq('product_id', productId)
          .eq('is_default', true)
          .maybeSingle();
      if (variant != null) {
        await _db
            .from('product_variants')
            .update(<String, dynamic>{'price_egp': product.price})
            .eq('id', variant['id'] as String);
      }
    }

    final decorated = await _decorator.decorate([row]);
    if (decorated.isEmpty) throw StateError('Could not reload product');
    return decorated.first;
  }

  Future<void> deleteProduct(String id) async {
    await _ensureAdmin();
    await _db.from('products').update(<String, dynamic>{
      'is_active': false,
    }).eq('id', id);
  }

  Future<List<CategoryEntity>> getCategories() async {
    await _ensureAdmin();
    final rows = await _db.from('categories').select('*').order('sort_order');
    return rows
        .map((row) => CategoryEntity.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<CategoryEntity> saveCategory(CategoryEntity category) async {
    await _ensureAdmin();
    final payload = category.toMap()..remove('id');
    final Map<String, dynamic> row;
    if (category.id.isEmpty) {
      row = Map<String, dynamic>.from(
        await _db.from('categories').insert(payload).select('*').single(),
      );
    } else {
      row = Map<String, dynamic>.from(
        await _db
            .from('categories')
            .update(payload)
            .eq('id', category.id)
            .select('*')
            .single(),
      );
    }
    return CategoryEntity.fromMap(row);
  }

  Future<void> deleteCategory(String id) async {
    await _ensureAdmin();
    await _db
        .from('categories')
        .update(<String, dynamic>{'is_active': false})
        .eq('id', id);
  }

  Future<List<OrderEntity>> getOrders() async {
    await _ensureAdmin();
    final rows = await _db
        .from('orders')
        .select(
          '*, order_items(*), order_status_history(*)',
        )
        .order('created_at', ascending: false);
    return rows
        .map((row) => OrderEntity.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<OrderEntity> setOrderStatus(String orderId, OrderStatus status) async {
    await _ensureAdmin();
    await _db.rpc<dynamic>(
      'admin_update_order_status',
      params: <String, dynamic>{
        'p_order_id': orderId,
        'p_new_status': status.value,
        'p_note': '',
      },
    );
    final row = await _db
        .from('orders')
        .select('*, order_items(*), order_status_history(*)')
        .eq('id', orderId)
        .single();
    return OrderEntity.fromMap(Map<String, dynamic>.from(row));
  }

  Future<List<AppUser>> getCustomers() async {
    await _ensureAdmin();
    final rows = await _db
        .from('profiles')
        .select('id, full_name, phone, avatar_url, role, created_at')
        .order('created_at', ascending: false);
    return rows
        .map((row) => AppUser.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<Map<String, num>> getDashboardStats() async {
    await _ensureAdmin();
    final results = await Future.wait([
      _db.from('orders').select('total_egp, status'),
      _db.from('products').select('id'),
      _db.from('profiles').select('id'),
      _db.from('inventory').select('quantity, reserved_quantity'),
    ]);

    final orders = results[0] as List;
    final products = results[1] as List;
    final profiles = results[2] as List;
    final inventory = results[3] as List;

    num revenue = 0;
    for (final row in orders) {
      if (row['status'] != 'cancelled') {
        revenue += (row['total_egp'] as num?) ?? 0;
      }
    }
    final lowStock = inventory.where((row) {
      final available = ((row['quantity'] as num?) ?? 0) -
          ((row['reserved_quantity'] as num?) ?? 0);
      return available <= 5;
    }).length;

    return <String, num>{
      'revenue': revenue,
      'orders': orders.length,
      'customers': profiles.length,
      'products': products.length,
      'lowStock': lowStock,
    };
  }
}
