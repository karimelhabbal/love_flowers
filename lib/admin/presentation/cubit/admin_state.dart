import 'package:equatable/equatable.dart';

import '../../../features/auth/domain/entities/app_user.dart';
import '../../../features/catalog/domain/entities/category.dart';
import '../../../features/catalog/domain/entities/product.dart';
import '../../../features/orders/domain/entities/order.dart';

enum AdminStatus { initial, loading, ready, failure, saving }

class AdminState extends Equatable {
  const AdminState({
    this.status = AdminStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.orders = const [],
    this.customers = const [],
    this.stats = const {},
    this.message,
  });

  final AdminStatus status;
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final List<OrderEntity> orders;
  final List<AppUser> customers;
  final Map<String, num> stats;
  final String? message;

  List<ProductEntity> get lowStockProducts =>
      products.where((product) => product.stock <= 5).toList();

  AdminState copyWith({
    AdminStatus? status,
    List<ProductEntity>? products,
    List<CategoryEntity>? categories,
    List<OrderEntity>? orders,
    List<AppUser>? customers,
    Map<String, num>? stats,
    String? message,
    bool clearMessage = false,
  }) {
    return AdminState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      orders: orders ?? this.orders,
      customers: customers ?? this.customers,
      stats: stats ?? this.stats,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        categories,
        orders,
        customers,
        stats,
        message,
      ];
}
