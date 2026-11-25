import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/admin_repository.dart';
import '../../../features/catalog/domain/entities/category.dart';
import '../../../features/catalog/domain/entities/product.dart';
import '../../../features/orders/domain/entities/order.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit(this._repository) : super(const AdminState());

  final AdminRepository _repository;

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: AdminStatus.loading, clearMessage: true));
    final stats = await _repository.getDashboardStats();
    final orders = await _repository.getOrders();
    final products = await _repository.getProducts();

    String? error;
    stats.fold((_) {}, (failure) => error = failure.message);
    orders.fold((_) {}, (failure) => error ??= failure.message);
    products.fold((_) {}, (failure) => error ??= failure.message);
    if (error != null) {
      emit(AdminState(status: AdminStatus.failure, message: error));
      return;
    }

    emit(state.copyWith(
      status: AdminStatus.ready,
      stats: stats.valueOrNull ?? const {},
      orders: orders.valueOrNull ?? const [],
      products: products.valueOrNull ?? const [],
    ));
  }

  Future<void> loadProducts() async {
    emit(state.copyWith(status: AdminStatus.loading, clearMessage: true));
    final result = await _repository.getProducts();
    result.fold(
      (products) => emit(state.copyWith(
        status: AdminStatus.ready,
        products: products,
      )),
      (failure) => emit(state.copyWith(
        status: AdminStatus.failure,
        message: failure.message,
      )),
    );
  }

  Future<void> loadCategories() async {
    emit(state.copyWith(status: AdminStatus.loading, clearMessage: true));
    final result = await _repository.getCategories();
    result.fold(
      (categories) => emit(state.copyWith(
        status: AdminStatus.ready,
        categories: categories,
      )),
      (failure) => emit(state.copyWith(
        status: AdminStatus.failure,
        message: failure.message,
      )),
    );
  }

  Future<void> loadOrders() async {
    emit(state.copyWith(status: AdminStatus.loading, clearMessage: true));
    final result = await _repository.getOrders();
    result.fold(
      (orders) => emit(state.copyWith(
        status: AdminStatus.ready,
        orders: orders,
      )),
      (failure) => emit(state.copyWith(
        status: AdminStatus.failure,
        message: failure.message,
      )),
    );
  }

  Future<void> loadCustomers() async {
    emit(state.copyWith(status: AdminStatus.loading, clearMessage: true));
    final result = await _repository.getCustomers();
    result.fold(
      (customers) => emit(state.copyWith(
        status: AdminStatus.ready,
        customers: customers,
      )),
      (failure) => emit(state.copyWith(
        status: AdminStatus.failure,
        message: failure.message,
      )),
    );
  }

  Future<bool> saveProduct(ProductEntity product) async {
    emit(state.copyWith(status: AdminStatus.saving, clearMessage: true));
    final result = await _repository.saveProduct(product);
    return result.fold(
      (saved) {
        final list = List<ProductEntity>.from(state.products);
        final index = list.indexWhere((item) => item.id == saved.id);
        if (index == -1) {
          list.insert(0, saved);
        } else {
          list[index] = saved;
        }
        emit(state.copyWith(status: AdminStatus.ready, products: list));
        return true;
      },
      (failure) {
        emit(state.copyWith(
          status: AdminStatus.failure,
          message: failure.message,
        ));
        return false;
      },
    );
  }

  Future<void> deleteProduct(String id) async {
    final result = await _repository.deleteProduct(id);
    result.fold(
      (_) => emit(state.copyWith(
        products: state.products
            .map((product) => product.id == id
                ? product.copyWith(isActive: false)
                : product)
            .toList(),
      )),
      (failure) => emit(state.copyWith(message: failure.message)),
    );
  }

  Future<bool> saveCategory(CategoryEntity category) async {
    emit(state.copyWith(status: AdminStatus.saving, clearMessage: true));
    final result = await _repository.saveCategory(category);
    return result.fold(
      (saved) {
        final list = List<CategoryEntity>.from(state.categories);
        final index = list.indexWhere((item) => item.id == saved.id);
        if (index == -1) {
          list.add(saved);
        } else {
          list[index] = saved;
        }
        emit(state.copyWith(status: AdminStatus.ready, categories: list));
        return true;
      },
      (failure) {
        emit(state.copyWith(
          status: AdminStatus.failure,
          message: failure.message,
        ));
        return false;
      },
    );
  }

  Future<void> setOrderStatus(String orderId, OrderStatus status) async {
    emit(state.copyWith(status: AdminStatus.saving, clearMessage: true));
    final result = await _repository.setOrderStatus(orderId, status);
    result.fold(
      (updated) {
        emit(state.copyWith(
          status: AdminStatus.ready,
          orders: state.orders
              .map((order) => order.id == updated.id ? updated : order)
              .toList(),
        ));
      },
      (failure) {
        emit(state.copyWith(
          status: AdminStatus.failure,
          message: failure.message,
        ));
      },
    );
  }
}
