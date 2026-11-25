import 'package:equatable/equatable.dart';

import '../../../catalog/domain/entities/product.dart';

class CartItemEntity extends Equatable {
  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.quantity,
    this.variantId = '',
    this.variantNameAr = '',
    this.variantNameEn = '',
    this.giftMessage = '',
    this.giftWrap = false,
    this.product,
  });

  final String id;
  final String productId;
  final int quantity;
  final String variantId;
  final String variantNameAr;
  final String variantNameEn;
  final String giftMessage;
  final bool giftWrap;
  final ProductEntity? product;

  double get unitPrice => product?.effectivePrice ?? 0;
  double get lineTotal => unitPrice * quantity;

  String? get imageUrl => product?.coverImage;
  String name(bool isArabic) => product?.name(isArabic) ?? '';
  String variantName(bool isArabic) =>
      isArabic ? variantNameAr : variantNameEn;

  factory CartItemEntity.fromMap(
    Map<String, dynamic> map, {
    ProductEntity? product,
  }) {
    final productMap = map['products'];
    if (product == null) {
      if (productMap is Map) {
        product = ProductEntity.fromMap(Map<String, dynamic>.from(productMap));
      } else if (productMap is List &&
          productMap.isNotEmpty &&
          productMap.first is Map) {
        product = ProductEntity.fromMap(
          Map<String, dynamic>.from(productMap.first as Map),
        );
      }
    }

    return CartItemEntity(
      id: map['id'] as String? ?? '',
      productId: map['product_id'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      variantId: map['variant_id'] as String? ?? '',
      variantNameAr: map['variant_name_ar'] as String? ?? '',
      variantNameEn: map['variant_name_en'] as String? ?? '',
      giftMessage: map['gift_message'] as String? ?? '',
      giftWrap: map['gift_wrap'] as bool? ?? false,
      product: product,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        quantity,
        variantId,
        giftMessage,
        giftWrap,
        product,
      ];
}
