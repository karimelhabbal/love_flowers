import 'package:equatable/equatable.dart';

import '../../../../core/network/storage_urls.dart';

/// Catalogue product. Prices and stock are not columns of `products`; they
/// come from `product_variants.price_egp` and `inventory`, and are attached by
/// [ProductRowDecorator] before this entity is created.
class ProductEntity extends Equatable {
  const ProductEntity({
    required this.id,
    required this.categoryId,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr = '',
    this.descriptionEn = '',
    this.price = 0,
    this.salePrice = 0,
    this.stock = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.rating = 0,
    this.reviewCount = 0,
    this.imageUrls = const [],
    this.createdAt,
    this.categoryNameAr = '',
    this.categoryNameEn = '',
    this.variantId = '',
    this.sortOrder = 0,
    this.allowCustomization = false,
  });

  final String id;
  final String categoryId;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;

  /// EGP amount from product_variants.price_egp.
  final double price;
  final double salePrice;

  /// Available units from inventory (quantity minus reserved_quantity).
  final int stock;
  final bool isActive;
  final bool isFeatured;
  final double rating;
  final int reviewCount;
  final List<String> imageUrls;
  final DateTime? createdAt;
  final String categoryNameAr;
  final String categoryNameEn;
  final String variantId;
  final int sortOrder;
  final bool allowCustomization;

  String name(bool isArabic) => isArabic ? nameAr : nameEn;
  String description(bool isArabic) => isArabic ? descriptionAr : descriptionEn;
  String categoryName(bool isArabic) =>
      isArabic ? categoryNameAr : categoryNameEn;

  double get effectivePrice => price;
  bool get hasDiscount => salePrice > 0 && salePrice < price;
  int get discountPercent => hasDiscount
      ? (((price - salePrice) / price) * 100).round()
      : 0;
  bool get inStock => stock > 0;
  String? get coverImage => imageUrls.isEmpty ? null : imageUrls.first;

  factory ProductEntity.fromMap(Map<String, dynamic> map) {
    final rawImages = map['image_urls'];
    final images = <String>[];
    if (rawImages is List) {
      for (final value in rawImages) {
        if (value is String && value.isNotEmpty) images.add(value);
      }
    }
    final rawPaths = map['image_paths'];
    if (images.isEmpty && rawPaths is List) {
      for (final value in rawPaths) {
        final url = StorageUrls.publicUrl(value is String ? value : null);
        if (url != null) images.add(url);
      }
    }
    final category = map['categories'];
    Map<String, dynamic>? categoryMap;
    if (category is Map) {
      categoryMap = Map<String, dynamic>.from(category);
    } else if (category is List && category.isNotEmpty && category.first is Map) {
      categoryMap = Map<String, dynamic>.from(category.first as Map);
    }

    return ProductEntity(
      id: map['id'] as String? ?? '',
      categoryId: map['category_id'] as String? ?? '',
      nameAr: map['name_ar'] as String? ?? '',
      nameEn: map['name_en'] as String? ?? '',
      descriptionAr: map['description_ar'] as String? ?? '',
      descriptionEn: map['description_en'] as String? ?? '',
      price: (map['price_egp'] as num?)?.toDouble() ??
          (map['price'] as num?)?.toDouble() ??
          0,
      salePrice: (map['sale_price'] as num?)?.toDouble() ?? 0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      isActive: map['is_active'] as bool? ?? true,
      isFeatured: map['is_featured'] as bool? ?? false,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (map['review_count'] as num?)?.toInt() ?? 0,
      imageUrls: images,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'] as String),
      categoryNameAr: (map['category_name_ar'] as String?) ??
          (categoryMap?['name_ar'] as String?) ??
          '',
      categoryNameEn: (map['category_name_en'] as String?) ??
          (categoryMap?['name_en'] as String?) ??
          '',
      variantId: map['variant_id'] as String? ?? '',
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      allowCustomization: map['allow_customization'] as bool? ?? false,
    );
  }

  /// Only columns that actually exist on `products`. Price, images and stock
  /// live in separate tables and are not writable through this map.
  Map<String, dynamic> toMap() => {
        'category_id': categoryId,
        'name_ar': nameAr,
        'name_en': nameEn,
        'description_ar': descriptionAr,
        'description_en': descriptionEn,
        'is_active': isActive,
        'is_featured': isFeatured,
        'sort_order': sortOrder,
        'allow_customization': allowCustomization,
      };

  ProductEntity copyWith({
    String? id,
    String? categoryId,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    double? price,
    double? salePrice,
    int? stock,
    bool? isActive,
    bool? isFeatured,
    List<String>? imageUrls,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      rating: rating,
      reviewCount: reviewCount,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt,
      categoryNameAr: categoryNameAr,
      categoryNameEn: categoryNameEn,
      variantId: variantId,
      sortOrder: sortOrder,
      allowCustomization: allowCustomization,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        nameAr,
        nameEn,
        descriptionAr,
        descriptionEn,
        price,
        salePrice,
        stock,
        isActive,
        isFeatured,
        rating,
        reviewCount,
        imageUrls,
        createdAt,
        variantId,
      ];
}
