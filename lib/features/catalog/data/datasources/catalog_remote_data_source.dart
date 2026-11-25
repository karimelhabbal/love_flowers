import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_customization.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'product_row_decorator.dart';

class CatalogRemoteDataSource {
  CatalogRemoteDataSource(this._client, this._decorator);

  final SupabaseClient? _client;
  final ProductRowDecorator _decorator;

  SupabaseClient get _db {
    final client = _client;
    if (client == null || !AppConstants.isSupabaseConfigured) {
      throw StateError('Supabase is not configured');
    }
    return client;
  }

  Future<List<CategoryEntity>> getCategories({bool includeInactive = false}) async {
    var query = _db.from('categories').select('*');
    if (!includeInactive) query = query.eq('is_active', true);
    final rows = await query.order('sort_order');
    return rows
        .map((row) => CategoryEntity.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<List<ProductEntity>> getProducts({
    String? categoryId,
    String? query,
    ProductSort sort = ProductSort.featured,
    int limit = 60,
    int offset = 0,
    bool includeInactive = false,
  }) async {
    dynamic request = _db.from('products').select('*');
    if (!includeInactive) request = request.eq('is_active', true);
    if (categoryId != null && categoryId.isNotEmpty) {
      request = request.eq('category_id', categoryId);
    }
    final safeQuery = query?.trim().replaceAll(RegExp(r'[(),]'), ' ') ?? '';
    if (safeQuery.isNotEmpty) {
      request = request.or(
        'name_ar.ilike.%$safeQuery%,name_en.ilike.%$safeQuery%,'
        'description_ar.ilike.%$safeQuery%,description_en.ilike.%$safeQuery%',
      );
    }

    // `products` has no price or rating column. Those sorts are applied after
    // variant prices have been attached by the decorator.
    final sortByPrice = sort == ProductSort.priceAsc ||
        sort == ProductSort.priceDesc;
    if (!sortByPrice) {
      request = switch (sort) {
        ProductSort.featured =>
          request.order('is_featured', ascending: false),
        ProductSort.newest => request.order('created_at', ascending: false),
        ProductSort.rating => request.order('sort_order', ascending: true),
        ProductSort.priceAsc || ProductSort.priceDesc => request,
      };
    }

    final rows = sortByPrice
        ? await request.order('sort_order').limit(300)
        : await request.range(offset, offset + limit - 1);

    var products = await _decorator.decorate(
      rows.map((row) => Map<String, dynamic>.from(row)).toList(),
    );
    if (sortByPrice) {
      products.sort((a, b) => sort == ProductSort.priceAsc
          ? a.price.compareTo(b.price)
          : b.price.compareTo(a.price));
      products = products.skip(offset).take(limit).toList();
    }
    return products;
  }

  Future<ProductEntity> getProduct(String id) async {
    final row = await _db.from('products').select('*').eq('id', id).single();
    final products = await _decorator.decorate([
      Map<String, dynamic>.from(row),
    ]);
    if (products.isEmpty) throw StateError('Product not found');
    return products.first;
  }

  Future<List<ProductEntity>> getFeatured({int limit = 8}) async {
    final rows = await _db
        .from('products')
        .select('*')
        .eq('is_active', true)
        .eq('is_featured', true)
        .order('sort_order')
        .limit(limit);
    return _decorator.decorate(
      rows.map((row) => Map<String, dynamic>.from(row)).toList(),
    );
  }

  Future<List<ProductEntity>> getNewArrivals({int limit = 8}) async {
    final rows = await _db
        .from('products')
        .select('*')
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(limit);
    return _decorator.decorate(
      rows.map((row) => Map<String, dynamic>.from(row)).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> getBranches() async {
    final rows = await _db
        .from('branches')
        .select('*')
        .eq('is_active', true)
        .order('created_at');
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<List<Map<String, dynamic>>> getDeliveryZones(
    String branchId,
  ) async {
    final rows = await _db
        .from('delivery_zones')
        .select('*')
        .eq('branch_id', branchId)
        .eq('is_active', true)
        .order('sort_order');
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<ProductCustomizationEntity> getCustomization(String productId) async {
    final results = await Future.wait([
      _db
          .from('product_option_groups')
          .select('*, product_options(*)')
          .eq('product_id', productId)
          .eq('is_active', true)
          .order('sort_order'),
      _db
          .from('product_flower_options')
          .select('*, flower_types(*)')
          .eq('product_id', productId)
          .eq('is_active', true)
          .order('sort_order'),
      _db
          .from('product_addons')
          .select('*')
          .eq('product_id', productId)
          .eq('is_active', true)
          .order('sort_order'),
    ]);

    final groups = (results[0] as List)
        .whereType<Map>()
        .map(
          (row) => ProductOptionGroupEntity.fromMap(
            Map<String, dynamic>.from(row),
          ),
        )
        .toList();
    final flowers = (results[1] as List)
        .whereType<Map>()
        .map(
          (row) => FlowerOptionEntity.fromMap(Map<String, dynamic>.from(row)),
        )
        .toList();

    final addonRows = (results[2] as List)
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    final addonVariantIds = addonRows
        .map((row) => row['addon_variant_id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    final addonProductIds = <String>{};
    final variantById = <String, Map<String, dynamic>>{};
    if (addonVariantIds.isNotEmpty) {
      final variants = await _db
          .from('product_variants')
          .select('id, product_id, price_egp')
          .inFilter('id', addonVariantIds);
      for (final row in variants) {
        final map = Map<String, dynamic>.from(row);
        variantById[map['id'] as String] = map;
        final productIdValue = map['product_id'] as String?;
        if (productIdValue != null) addonProductIds.add(productIdValue);
      }
    }
    final productNamesById = <String, Map<String, dynamic>>{};
    if (addonProductIds.isNotEmpty) {
      final products = await _db
          .from('products')
          .select('id, name_ar, name_en')
          .inFilter('id', addonProductIds.toList());
      for (final row in products) {
        final map = Map<String, dynamic>.from(row);
        productNamesById[map['id'] as String] = map;
      }
    }

    final addons = <ProductAddonEntity>[];
    for (final row in addonRows) {
      final variantId = row['addon_variant_id'] as String? ?? '';
      final variant = variantById[variantId];
      final addonProductId = variant?['product_id'] as String? ?? '';
      final names = productNamesById[addonProductId];
      addons.add(ProductAddonEntity(
        id: row['id'] as String? ?? '',
        addonVariantId: variantId,
        nameAr: names?['name_ar'] as String? ?? '',
        nameEn: names?['name_en'] as String? ?? '',
        priceEgp: (row['price_override_egp'] as num?)?.toDouble() ??
            (variant?['price_egp'] as num?)?.toDouble() ??
            0,
        maxQuantity: (row['max_quantity'] as num?)?.toInt() ?? 1,
      ));
    }
    return ProductCustomizationEntity(
      groups: groups,
      flowers: flowers,
      addons: addons,
    );
  }
}
