import 'package:equatable/equatable.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';

enum HomeStatus { initial, loading, ready, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.categories = const [],
    this.featured = const [],
    this.newArrivals = const [],
    this.message,
  });

  final HomeStatus status;
  final List<CategoryEntity> categories;
  final List<ProductEntity> featured;
  final List<ProductEntity> newArrivals;
  final String? message;

  HomeState copyWith({
    HomeStatus? status,
    List<CategoryEntity>? categories,
    List<ProductEntity>? featured,
    List<ProductEntity>? newArrivals,
    String? message,
    bool clearMessage = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      featured: featured ?? this.featured,
      newArrivals: newArrivals ?? this.newArrivals,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, categories, featured, newArrivals, message];
}
