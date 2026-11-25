import 'package:equatable/equatable.dart';

import '../../../../core/network/storage_urls.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl = '',
    this.imagePath = '',
    this.sortOrder = 0,
    this.isActive = true,
    this.productCount = 0,
    this.parentId = '',
  });

  final String id;
  final String nameAr;
  final String nameEn;

  /// Public URL derived from `image_path` in the product-images bucket.
  final String imageUrl;
  final String imagePath;
  final int sortOrder;
  final bool isActive;
  final int productCount;
  final String parentId;

  String name(bool isArabic) => isArabic ? nameAr : nameEn;

  factory CategoryEntity.fromMap(Map<String, dynamic> map) {
    final path = map['image_path'] as String? ?? '';
    return CategoryEntity(
      id: map['id'] as String? ?? '',
      nameAr: map['name_ar'] as String? ?? '',
      nameEn: map['name_en'] as String? ?? '',
      imagePath: path,
      imageUrl: StorageUrls.publicUrl(path) ?? '',
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      isActive: map['is_active'] as bool? ?? true,
      productCount: (map['product_count'] as num?)?.toInt() ?? 0,
      parentId: map['parent_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name_ar': nameAr,
        'name_en': nameEn,
        'image_path': imagePath,
        'sort_order': sortOrder,
        'is_active': isActive,
        'parent_id': parentId.isEmpty ? null : parentId,
      };

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        imagePath,
        sortOrder,
        isActive,
        productCount,
        parentId,
      ];
}
