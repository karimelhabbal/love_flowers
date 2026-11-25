import 'package:equatable/equatable.dart';

import '../../../catalog/domain/entities/product.dart';

enum FavoritesStatus { initial, loading, ready, failure }

class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.ids = const {},
    this.products = const [],
    this.message,
  });

  final FavoritesStatus status;
  final Set<String> ids;
  final List<ProductEntity> products;
  final String? message;

  bool isFavorite(String productId) => ids.contains(productId);
  bool get isBusy => status == FavoritesStatus.loading;

  FavoritesState copyWith({
    FavoritesStatus? status,
    Set<String>? ids,
    List<ProductEntity>? products,
    String? message,
    bool clearMessage = false,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      ids: ids ?? this.ids,
      products: products ?? this.products,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, ids, products, message];
}
