import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._repository) : super(const CartState());

  final CartRepository _repository;

  /// Guests have no server-side cart. Show an empty cart instead of
  /// surfacing the data source's "Not signed in" error as a page failure.
  void showGuestCart() {
    emit(const CartState(status: CartStatus.ready));
  }

  Future<void> load() async {
    emit(state.copyWith(status: CartStatus.loading, clearMessage: true));
    final result = await _repository.getCart();
    result.fold(
      (items) => emit(CartState(status: CartStatus.ready, items: items)),
      (failure) => emit(
        CartState(status: CartStatus.failure, message: failure.message),
      ),
    );
  }

  Future<bool> add({
    required String productId,
    int quantity = 1,
    String giftMessage = '',
    bool giftWrap = false,
    String? variantId,
    List<String>? optionIds,
    Map<String, int>? flowers,
    Map<String, int>? addons,
  }) async {
    emit(state.copyWith(status: CartStatus.loading, clearMessage: true));
    final result = await _repository.addToCart(
      productId: productId,
      quantity: quantity,
      giftMessage: giftMessage,
      giftWrap: giftWrap,
      variantId: variantId,
      optionIds: optionIds,
      flowers: flowers,
      addons: addons,
    );
    return result.fold(
      (_) async {
        await load();
        return true;
      },
      (failure) {
        emit(
          CartState(status: CartStatus.failure, message: failure.message),
        );
        return false;
      },
    );
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    final previous = state.items;
    emit(state.copyWith(
      items: previous
          .map((item) => item.id == itemId
              ? item.copyWithQuantity(quantity)
              : item)
          .toList(),
    ));
    final result = await _repository.updateItem(
      itemId: itemId,
      quantity: quantity,
    );
    result.fold(
      (_) => load(),
      (failure) => emit(
        state.copyWith(
          items: previous,
          status: CartStatus.failure,
          message: failure.message,
        ),
      ),
    );
  }

  Future<void> updateGift({
    required String itemId,
    String? giftMessage,
    bool? giftWrap,
  }) async {
    final result = await _repository.updateItem(
      itemId: itemId,
      giftMessage: giftMessage,
      giftWrap: giftWrap,
    );
    result.fold(
      (_) => load(),
      (failure) => emit(state.copyWith(message: failure.message)),
    );
  }

  Future<void> remove(String itemId) async {
    final previous = state.items;
    emit(state.copyWith(
      items: previous.where((item) => item.id != itemId).toList(),
    ));
    final result = await _repository.removeItem(itemId);
    result.fold(
      (_) => load(),
      (failure) => emit(
        state.copyWith(
          items: previous,
          status: CartStatus.failure,
          message: failure.message,
        ),
      ),
    );
  }

  Future<void> clear() async {
    final result = await _repository.clearCart();
    result.fold(
      (_) => emit(const CartState(status: CartStatus.ready)),
      (failure) => emit(state.copyWith(message: failure.message)),
    );
  }
}

extension on CartItemEntity {
  CartItemEntity copyWithQuantity(int quantity) => CartItemEntity(
        id: id,
        productId: productId,
        quantity: quantity < 1 ? 1 : quantity,
        giftMessage: giftMessage,
        giftWrap: giftWrap,
        product: product,
      );
}
