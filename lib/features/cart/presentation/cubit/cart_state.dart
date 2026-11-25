import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_item.dart';

enum CartStatus { initial, loading, ready, failure }

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.message,
  });

  final CartStatus status;
  final List<CartItemEntity> items;
  final String? message;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.lineTotal);
  bool get isEmpty => status == CartStatus.ready && items.isEmpty;
  bool get isBusy => status == CartStatus.loading;

  CartState copyWith({
    CartStatus? status,
    List<CartItemEntity>? items,
    String? message,
    bool clearMessage = false,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
