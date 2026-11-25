import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../catalog/data/datasources/product_row_decorator.dart';
import '../../domain/entities/cart_item.dart';

class CartRemoteDataSource {
  CartRemoteDataSource(this._client, this._decorator);

  final SupabaseClient? _client;
  final ProductRowDecorator _decorator;

  SupabaseClient get _db {
    final client = _client;
    if (client == null || !AppConstants.isSupabaseConfigured) {
      throw StateError('Supabase is not configured');
    }
    return client;
  }

  String get _userId {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw StateError('Not signed in');
    return id;
  }

  Future<String> _cartId() async {
    final existing = await _db
        .from('carts')
        .select('id')
        .eq('customer_id', _userId)
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(1);
    if (existing.isNotEmpty) return existing.first['id'] as String;

    final branch = await _db
        .from('branches')
        .select('id')
        .eq('is_active', true)
        .eq('is_default', true)
        .maybeSingle();
    final created = await _db.from('carts').insert(<String, dynamic>{
      'customer_id': _userId,
      'is_active': true,
      if (branch?['id'] != null) 'branch_id': branch!['id'],
    }).select('id').single();
    return created['id'] as String;
  }

  Future<List<CartItemEntity>> getCart() async {
    // A guest has no server cart. Return an empty one instead of failing.
    if (_db.auth.currentUser == null) return const [];
    final cartId = await _cartId();
    final rows = await _db
        .from('cart_items')
        .select('*')
        .eq('cart_id', cartId)
        .order('created_at');
    final productIds = rows
        .map((row) => row['product_id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    final products = await _decorator.fetchByIds(productIds);
    final productsById = <String, dynamic>{
      for (final product in products) product.id: product,
    };

    return rows.map((row) {
      final map = Map<String, dynamic>.from(row);
      final productId = map['product_id'] as String? ?? '';
      return CartItemEntity.fromMap(
        map,
        product: productsById[productId],
      );
    }).toList();
  }

  Future<CartItemEntity> addToCart({
    required String productId,
    int quantity = 1,
    String giftMessage = '',
    bool giftWrap = false,
    String? variantId,
    List<String>? optionIds,
    Map<String, int>? flowers,
    Map<String, int>? addons,
  }) async {
    final cartId = await _cartId();
    final resolvedVariantId = variantId ?? await _defaultVariantId(productId);
    final rows = await _db
        .from('cart_items')
        .select('*')
        .eq('cart_id', cartId)
        .eq('product_id', productId)
        .eq('variant_id', resolvedVariantId)
        .eq('gift_wrap', giftWrap);

    final Map<String, dynamic> row;
    if (rows.isNotEmpty) {
      final existing = Map<String, dynamic>.from(rows.first as Map);
      final nextQuantity =
          (existing['quantity'] as num?)?.toInt() ?? 0;
      row = Map<String, dynamic>.from(
        await _db
            .from('cart_items')
            .update(<String, dynamic>{
              'quantity': nextQuantity + quantity,
              'gift_message': giftMessage,
            })
            .eq('id', existing['id'] as String)
            .select('*')
            .single(),
      );
    } else {
      row = Map<String, dynamic>.from(
        await _db.from('cart_items').insert(<String, dynamic>{
          'cart_id': cartId,
          'product_id': productId,
          'variant_id': resolvedVariantId,
          'quantity': quantity < 1 ? 1 : quantity,
          'gift_message': giftMessage,
          'gift_wrap': giftWrap,
        }).select('*').single(),
      );
    }

    final itemId = row['id'] as String;
    if (optionIds != null && optionIds.isNotEmpty) {
      await _db.from('cart_item_options').insert([
        for (final optionId in optionIds)
          <String, dynamic>{
            'cart_item_id': itemId,
            'option_id': optionId,
          },
      ]);
    }
    if (flowers != null && flowers.isNotEmpty) {
      await _db.from('cart_item_flowers').insert([
        for (final entry in flowers.entries)
          <String, dynamic>{
            'cart_item_id': itemId,
            'flower_type_id': entry.key,
            'quantity': entry.value < 1 ? 1 : entry.value,
          },
      ]);
    }
    if (addons != null && addons.isNotEmpty) {
      await _db.from('cart_item_addons').insert([
        for (final entry in addons.entries)
          <String, dynamic>{
            'cart_item_id': itemId,
            'addon_variant_id': entry.key,
            'quantity': entry.value < 1 ? 1 : entry.value,
          },
      ]);
    }

    final products = await _decorator.fetchByIds([productId]);
    return CartItemEntity.fromMap(
      row,
      product: products.isEmpty ? null : products.first,
    );
  }

  Future<void> updateItem({
    required String itemId,
    int? quantity,
    String? giftMessage,
    bool? giftWrap,
  }) async {
    final payload = <String, dynamic>{
      if (quantity != null) 'quantity': quantity < 1 ? 1 : quantity,
      'gift_message': ?giftMessage,
      'gift_wrap': ?giftWrap,
    };
    if (payload.isEmpty) return;
    await _db.from('cart_items').update(payload).eq('id', itemId);
  }

  Future<void> removeItem(String itemId) =>
      _db.from('cart_items').delete().eq('id', itemId);

  Future<void> clearCart() async {
    final cartId = await _cartId();
    await _db.from('cart_items').delete().eq('cart_id', cartId);
  }

  Future<String> currentCartId() => _cartId();

  Future<String> _defaultVariantId(String productId) async {
    final row = await _db
        .from('product_variants')
        .select('id')
        .eq('product_id', productId)
        .eq('is_active', true)
        .order('is_default', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) {
      throw StateError('No active variant for this product');
    }
    return row['id'] as String;
  }
}
