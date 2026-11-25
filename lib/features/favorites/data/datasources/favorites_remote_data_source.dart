import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../catalog/data/datasources/product_row_decorator.dart';
import '../../../catalog/domain/entities/product.dart';

class FavoritesRemoteDataSource {
  FavoritesRemoteDataSource(this._client, this._decorator);

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

  Future<Set<String>> getFavoriteIds() async {
    if (_db.auth.currentUser == null) return const <String>{};
    final rows = await _db
        .from('favorites')
        .select('product_id')
        .eq('customer_id', _userId);
    return rows
        .map((row) => row['product_id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<bool> toggleFavorite(String productId) async {
    final existing = await _db
        .from('favorites')
        .select('id')
        .eq('customer_id', _userId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      await _db.from('favorites').delete().eq('id', existing['id'] as String);
      return false;
    }

    await _db.from('favorites').insert(<String, dynamic>{
      'customer_id': _userId,
      'product_id': productId,
    });
    return true;
  }

  Future<List<ProductEntity>> getFavoriteProducts() async {
    final ids = (await getFavoriteIds()).toList();
    if (ids.isEmpty) return const [];
    return _decorator.fetchByIds(ids);
  }
}
