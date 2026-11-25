import '../../../../core/error/result.dart';
import '../entities/category.dart';
import '../entities/product.dart';
import '../entities/product_customization.dart';

enum ProductSort { featured, newest, priceAsc, priceDesc, rating }

abstract interface class CatalogRepository {
  Future<Result<List<CategoryEntity>>> getCategories({bool includeInactive = false});

  Future<Result<List<ProductEntity>>> getProducts({
    String? categoryId,
    String? query,
    ProductSort sort = ProductSort.featured,
    int limit = 60,
    int offset = 0,
    bool includeInactive = false,
  });

  Future<Result<ProductEntity>> getProduct(String id);

  Future<Result<List<ProductEntity>>> getFeatured({int limit = 8});

  Future<Result<List<ProductEntity>>> getNewArrivals({int limit = 8});

  Future<Result<ProductCustomizationEntity>> getCustomization(String productId);

  Future<Result<List<Map<String, dynamic>>>> getBranches();

  Future<Result<List<Map<String, dynamic>>>> getDeliveryZones(String branchId);
}
