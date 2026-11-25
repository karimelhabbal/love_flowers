import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';

enum ListingStatus { initial, loading, ready, failure }

class ProductListingState extends Equatable {
  const ProductListingState({
    this.status = ListingStatus.initial,
    this.products = const [],
    this.categoryId,
    this.query = '',
    this.sort = ProductSort.featured,
    this.message,
  });

  final ListingStatus status;
  final List<ProductEntity> products;
  final String? categoryId;
  final String query;
  final ProductSort sort;
  final String? message;

  ProductListingState copyWith({
    ListingStatus? status,
    List<ProductEntity>? products,
    String? categoryId,
    bool clearCategory = false,
    String? query,
    ProductSort? sort,
    String? message,
    bool clearMessage = false,
  }) {
    return ProductListingState(
      status: status ?? this.status,
      products: products ?? this.products,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      query: query ?? this.query,
      sort: sort ?? this.sort,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, products, categoryId, query, sort, message];
}
