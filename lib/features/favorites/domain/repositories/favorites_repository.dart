import '../../../../core/error/result.dart';
import '../../../catalog/domain/entities/product.dart';

abstract interface class FavoritesRepository {
  Future<Result<Set<String>>> getFavoriteIds();

  /// Returns `true` when the product is a favourite after the toggle.
  Future<Result<bool>> toggleFavorite(String productId);

  Future<Result<List<ProductEntity>>> getFavoriteProducts();
}
