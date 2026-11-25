import '../../../../core/error/result.dart';
import '../../../../core/utils/repository_guard.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._remote);

  final CartRemoteDataSource _remote;

  @override
  Future<Result<List<CartItemEntity>>> getCart() => runSafe(_remote.getCart);

  @override
  Future<Result<CartItemEntity>> addToCart({
    required String productId,
    int quantity = 1,
    String giftMessage = '',
    bool giftWrap = false,
    String? variantId,
    List<String>? optionIds,
    Map<String, int>? flowers,
    Map<String, int>? addons,
  }) =>
      runSafe(() => _remote.addToCart(
            productId: productId,
            quantity: quantity,
            giftMessage: giftMessage,
            giftWrap: giftWrap,
            variantId: variantId,
      optionIds: optionIds,
      flowers: flowers,
      addons: addons,
    ));

  @override
  Future<Result<void>> updateItem({
    required String itemId,
    int? quantity,
    String? giftMessage,
    bool? giftWrap,
  }) =>
      runSafe(() => _remote.updateItem(
            itemId: itemId,
            quantity: quantity,
            giftMessage: giftMessage,
            giftWrap: giftWrap,
          ));

  @override
  Future<Result<void>> removeItem(String itemId) =>
      runSafe(() => _remote.removeItem(itemId));

  @override
  Future<Result<void>> clearCart() => runSafe(_remote.clearCart);
}
