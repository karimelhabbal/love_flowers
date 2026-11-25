import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/storage_urls.dart';
import '../../domain/entities/product.dart';

/// Attaches data from product_variants, product_images, inventory and
/// categories to `products` rows. Those tables hold the real price, images,
/// stock and category names; `products` itself does not.
class ProductRowDecorator {
  const ProductRowDecorator(this._client);

  final SupabaseClient? _client;

  SupabaseClient get _db {
    final client = _client;
    if (client == null) throw StateError('Supabase is not configured');
    return client;
  }

  Future<List<ProductEntity>> fetchByIds(List<String> ids) async {
    if (ids.isEmpty) return const <ProductEntity>[];
    final rows = await _db
        .from('products')
        .select('*')
        .inFilter('id', ids)
        .order('sort_order');
    return decorate(
      rows.map((row) => Map<String, dynamic>.from(row)).toList(),
    );
  }

  Future<List<ProductEntity>> decorate(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return const <ProductEntity>[];

    final productIds =
        rows.map((row) => row['id'] as String).whereType<String>().toList();
    if (productIds.isEmpty) return const <ProductEntity>[];

    final results = await Future.wait([
      _db
          .from('product_variants')
          .select('*')
          .inFilter('product_id', productIds)
          .eq('is_active', true)
          .order('is_default', ascending: false),
      _db
          .from('product_images')
          .select('*')
          .inFilter('product_id', productIds)
          .order('sort_order'),
    ]);

    final variants = _rows(results[0]);
    final images = _rows(results[1]);

    final variantIds = variants
        .map((row) => row['variant_id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    final inventory = variantIds.isEmpty
        ? const <Map<String, dynamic>>[]
        : _rows(
            await _db
                .from('inventory')
                .select('*')
                .inFilter('variant_id', variantIds),
          );

    final variantByProduct = <String, Map<String, dynamic>>{};
    for (final row in variants) {
      final productId = row['product_id'] as String? ?? '';
      if (productId.isEmpty || variantByProduct.containsKey(productId)) continue;
      variantByProduct[productId] = <String, dynamic>{
        'variant_id': row['id'],
        'price_egp': row['price_egp'],
      };
    }

    final availableByVariant = <String, int>{};
    for (final row in inventory) {
      final variantId = row['variant_id'] as String? ?? '';
      if (variantId.isEmpty) continue;
      final total = (row['quantity'] as num?)?.toInt() ?? 0;
      final reserved = (row['reserved_quantity'] as num?)?.toInt() ?? 0;
      availableByVariant[variantId] =
          (availableByVariant[variantId] ?? 0) + (total - reserved);
    }

    final imagePathsByProduct = <String, List<String>>{};
    for (final row in images) {
      final productId = row['product_id'] as String? ?? '';
      final path = row['storage_path'] as String?;
      if (productId.isEmpty || path == null || path.isEmpty) continue;
      imagePathsByProduct.putIfAbsent(productId, () => <String>[]).add(path);
    }

    final categoryIds = rows
        .map((row) => row['category_id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    final categoryRows = categoryIds.isEmpty
        ? const <Map<String, dynamic>>[]
        : _rows(
            await _db
                .from('categories')
                .select('id, name_ar, name_en')
                .inFilter('id', categoryIds),
          );
    final categoryById = <String, Map<String, dynamic>>{
      for (final row in categoryRows) row['id'] as String: row,
    };

    return rows.map((row) {
      final productId = row['id'] as String? ?? '';
      final variant = variantByProduct[productId];
      final variantId = variant?['variant_id'] as String? ?? '';
      final categoryId = row['category_id'] as String? ?? '';
      final category = categoryById[categoryId];
      final decorated = Map<String, dynamic>.from(row);
      decorated['variant_id'] = variantId;
      decorated['price_egp'] = variant?['price_egp'] ?? 0;
      decorated['stock'] = availableByVariant[variantId] ?? 0;
      decorated['image_urls'] = (imagePathsByProduct[productId] ?? const [])
          .map((path) => StorageUrls.publicUrl(path))
          .whereType<String>()
          .toList();
      decorated['category_name_ar'] = category?['name_ar'] ?? '';
      decorated['category_name_en'] = category?['name_en'] ?? '';
      return ProductEntity.fromMap(decorated);
    }).toList();
  }

  static List<Map<String, dynamic>> _rows(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }
}
