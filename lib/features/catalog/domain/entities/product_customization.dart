import 'package:equatable/equatable.dart';

import '../../../../core/network/storage_urls.dart';

class ProductOptionEntity extends Equatable {
  const ProductOptionEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.priceDeltaEgp = 0,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final double priceDeltaEgp;

  String name(bool isArabic) => isArabic ? nameAr : nameEn;

  factory ProductOptionEntity.fromMap(Map<String, dynamic> map) =>
      ProductOptionEntity(
        id: map['id'] as String? ?? '',
        nameAr: map['name_ar'] as String? ?? '',
        nameEn: map['name_en'] as String? ?? '',
        priceDeltaEgp: (map['price_delta_egp'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [id, nameAr, nameEn, priceDeltaEgp];
}

class ProductOptionGroupEntity extends Equatable {
  const ProductOptionGroupEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.isRequired = false,
    this.selectionType = '',
    this.minSelections = 0,
    this.maxSelections = 0,
    this.options = const [],
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final bool isRequired;
  final String selectionType;
  final int minSelections;
  final int maxSelections;
  final List<ProductOptionEntity> options;

  String name(bool isArabic) => isArabic ? nameAr : nameEn;

  factory ProductOptionGroupEntity.fromMap(Map<String, dynamic> map) {
    final rawOptions = map['product_options'];
    final options = <ProductOptionEntity>[];
    if (rawOptions is List) {
      for (final option in rawOptions) {
        if (option is Map) {
          options.add(
            ProductOptionEntity.fromMap(Map<String, dynamic>.from(option)),
          );
        }
      }
    }
    return ProductOptionGroupEntity(
      id: map['id'] as String? ?? '',
      nameAr: map['name_ar'] as String? ?? '',
      nameEn: map['name_en'] as String? ?? '',
      isRequired: map['is_required'] as bool? ?? false,
      selectionType: map['selection_type'] as String? ?? '',
      minSelections: (map['min_selections'] as num?)?.toInt() ?? 0,
      maxSelections: (map['max_selections'] as num?)?.toInt() ?? 0,
      options: options,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        isRequired,
        selectionType,
        minSelections,
        maxSelections,
        options,
      ];
}

class FlowerOptionEntity extends Equatable {
  const FlowerOptionEntity({
    required this.id,
    required this.flowerTypeId,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl = '',
    this.unitPriceEgp = 0,
    this.minQuantity = 0,
    this.maxQuantity = 0,
  });

  final String id;
  final String flowerTypeId;
  final String nameAr;
  final String nameEn;
  final String imageUrl;
  final double unitPriceEgp;
  final int minQuantity;
  final int maxQuantity;

  String name(bool isArabic) => isArabic ? nameAr : nameEn;

  factory FlowerOptionEntity.fromMap(Map<String, dynamic> map) {
    final flower = map['flower_types'];
    Map<String, dynamic>? flowerMap;
    if (flower is Map) {
      flowerMap = Map<String, dynamic>.from(flower);
    } else if (flower is List && flower.isNotEmpty && flower.first is Map) {
      flowerMap = Map<String, dynamic>.from(flower.first as Map);
    }
    final override = map['price_override_egp'] as num?;
    final base = flowerMap?['base_price_egp'] as num?;
    return FlowerOptionEntity(
      id: map['id'] as String? ?? '',
      flowerTypeId: map['flower_type_id'] as String? ?? '',
      nameAr: flowerMap?['name_ar'] as String? ?? '',
      nameEn: flowerMap?['name_en'] as String? ?? '',
      imageUrl: StorageUrls.publicUrl(flowerMap?['image_path'] as String?) ?? '',
      unitPriceEgp: (override ?? base ?? 0).toDouble(),
      minQuantity: (map['min_quantity'] as num?)?.toInt() ?? 0,
      maxQuantity: (map['max_quantity'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        flowerTypeId,
        nameAr,
        nameEn,
        imageUrl,
        unitPriceEgp,
        minQuantity,
        maxQuantity,
      ];
}

class ProductAddonEntity extends Equatable {
  const ProductAddonEntity({
    required this.id,
    required this.addonVariantId,
    required this.nameAr,
    required this.nameEn,
    this.priceEgp = 0,
    this.maxQuantity = 1,
  });

  /// `product_addons.id` is the catalog link; `addon_variant_id` is the
  /// variant whose price and stock are used by checkout_cart.
  final String id;
  final String addonVariantId;
  final String nameAr;
  final String nameEn;
  final double priceEgp;
  final int maxQuantity;

  String name(bool isArabic) => isArabic ? nameAr : nameEn;

  @override
  List<Object?> get props => [
        id,
        addonVariantId,
        nameAr,
        nameEn,
        priceEgp,
        maxQuantity,
      ];
}

class ProductCustomizationEntity extends Equatable {
  const ProductCustomizationEntity({
    this.groups = const [],
    this.flowers = const [],
    this.addons = const [],
  });

  final List<ProductOptionGroupEntity> groups;
  final List<FlowerOptionEntity> flowers;
  final List<ProductAddonEntity> addons;

  bool get isEmpty => groups.isEmpty && flowers.isEmpty && addons.isEmpty;

  @override
  List<Object?> get props => [groups, flowers, addons];
}
