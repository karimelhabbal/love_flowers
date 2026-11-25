import '../../../../core/error/result.dart';
import '../../../../core/utils/repository_guard.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_customization.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._remote);

  final CatalogRemoteDataSource _remote;

  @override
  Future<Result<List<CategoryEntity>>> getCategories({bool includeInactive = false}) =>
      runSafe(() => _remote.getCategories(includeInactive: includeInactive));

  @override
  Future<Result<List<ProductEntity>>> getProducts({
    String? categoryId,
    String? query,
    ProductSort sort = ProductSort.featured,
    int limit = 60,
    int offset = 0,
    bool includeInactive = false,
  }) =>
      runSafe(() => _remote.getProducts(
            categoryId: categoryId,
            query: query,
            sort: sort,
            limit: limit,
            offset: offset,
            includeInactive: includeInactive,
          ));

  @override
  Future<Result<ProductEntity>> getProduct(String id) =>
      runSafe(() => _remote.getProduct(id));

  @override
  Future<Result<List<ProductEntity>>> getFeatured({int limit = 8}) =>
      runSafe(() => _remote.getFeatured(limit: limit));

  @override
  Future<Result<List<ProductEntity>>> getNewArrivals({int limit = 8}) =>
      runSafe(() => _remote.getNewArrivals(limit: limit));

  @override
  Future<Result<ProductCustomizationEntity>> getCustomization(String productId) =>
      runSafe(() => _remote.getCustomization(productId));

  @override
  Future<Result<List<Map<String, dynamic>>>> getBranches() =>
      runSafe(_remote.getBranches);

  @override
  Future<Result<List<Map<String, dynamic>>>> getDeliveryZones(String branchId) =>
      runSafe(() => _remote.getDeliveryZones(branchId));
}
