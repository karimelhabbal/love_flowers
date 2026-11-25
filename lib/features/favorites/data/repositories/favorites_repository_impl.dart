import '../../../../core/error/result.dart';
import '../../../../core/utils/repository_guard.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._remote);

  final FavoritesRemoteDataSource _remote;

  @override
  Future<Result<Set<String>>> getFavoriteIds() => runSafe(_remote.getFavoriteIds);

  @override
  Future<Result<bool>> toggleFavorite(String productId) =>
      runSafe(() => _remote.toggleFavorite(productId));

  @override
  Future<Result<List<ProductEntity>>> getFavoriteProducts() =>
      runSafe(_remote.getFavoriteProducts);
}
