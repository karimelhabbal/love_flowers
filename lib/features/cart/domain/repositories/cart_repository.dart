import '../../../../core/error/result.dart';
import '../entities/cart_item.dart';

abstract interface class CartRepository {
  Future<Result<List<CartItemEntity>>> getCart();

  Future<Result<CartItemEntity>> addToCart({
    required String productId,
    int quantity = 1,
    String giftMessage = '',
    bool giftWrap = false,
    String? variantId,
    List<String>? optionIds,
    Map<String, int>? flowers,
    Map<String, int>? addons,
  });

  Future<Result<void>> updateItem({
    required String itemId,
    int? quantity,
    String? giftMessage,
    bool? giftWrap,
  });

  Future<Result<void>> removeItem(String itemId);

  Future<Result<void>> clearCart();
}
