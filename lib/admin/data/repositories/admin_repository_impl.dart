import '../../../core/error/result.dart';
import '../../../core/utils/repository_guard.dart';
import '../../../features/auth/domain/entities/app_user.dart';
import '../../../features/catalog/domain/entities/category.dart';
import '../../../features/catalog/domain/entities/product.dart';
import '../../../features/orders/domain/entities/order.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._remote);

  final AdminRemoteDataSource _remote;

  @override
  Future<Result<List<ProductEntity>>> getProducts() => runSafe(_remote.getProducts);

  @override
  Future<Result<ProductEntity>> saveProduct(ProductEntity product) =>
      runSafe(() => _remote.saveProduct(product));

  @override
  Future<Result<void>> deleteProduct(String id) =>
      runSafe(() => _remote.deleteProduct(id));

  @override
  Future<Result<List<CategoryEntity>>> getCategories() =>
      runSafe(_remote.getCategories);

  @override
  Future<Result<CategoryEntity>> saveCategory(CategoryEntity category) =>
      runSafe(() => _remote.saveCategory(category));

  @override
  Future<Result<void>> deleteCategory(String id) =>
      runSafe(() => _remote.deleteCategory(id));

  @override
  Future<Result<List<OrderEntity>>> getOrders() => runSafe(_remote.getOrders);

  @override
  Future<Result<OrderEntity>> setOrderStatus(String orderId, OrderStatus status) =>
      runSafe(() => _remote.setOrderStatus(orderId, status));

  @override
  Future<Result<List<AppUser>>> getCustomers() => runSafe(_remote.getCustomers);

  @override
  Future<Result<Map<String, num>>> getDashboardStats() =>
      runSafe(_remote.getDashboardStats);
}
