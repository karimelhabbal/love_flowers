import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_customization.dart';

enum DetailsStatus { initial, loading, ready, failure }

class ProductDetailsState extends Equatable {
  const ProductDetailsState({
    this.status = DetailsStatus.initial,
    this.product,
    this.customization = const ProductCustomizationEntity(),
    this.message,
  });

  final DetailsStatus status;
  final ProductEntity? product;
  final ProductCustomizationEntity customization;
  final String? message;

  ProductDetailsState copyWith({
    DetailsStatus? status,
    ProductEntity? product,
    ProductCustomizationEntity? customization,
    String? message,
    bool clearMessage = false,
  }) {
    return ProductDetailsState(
      status: status ?? this.status,
      product: product ?? this.product,
      customization: customization ?? this.customization,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, product, customization, message];
}
