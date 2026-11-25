import '../../../core/error/result.dart';
import '../../../features/auth/domain/entities/app_user.dart';
import '../../../features/catalog/domain/entities/category.dart';
import '../../../features/catalog/domain/entities/product.dart';
import '../../../features/orders/domain/entities/order.dart';

abstract interface class AdminRepository {
  Future<Result<List<ProductEntity>>> getProducts();

  Future<Result<ProductEntity>> saveProduct(ProductEntity product);

  Future<Result<void>> deleteProduct(String id);

  Future<Result<List<CategoryEntity>>> getCategories();

  Future<Result<CategoryEntity>> saveCategory(CategoryEntity category);

  Future<Result<void>> deleteCategory(String id);

  Future<Result<List<OrderEntity>>> getOrders();

  Future<Result<OrderEntity>> setOrderStatus(String orderId, OrderStatus status);

  Future<Result<List<AppUser>>> getCustomers();

  Future<Result<Map<String, num>>> getDashboardStats();
}
