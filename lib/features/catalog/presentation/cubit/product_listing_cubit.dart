import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/catalog_repository.dart';
import 'product_listing_state.dart';

class ProductListingCubit extends Cubit<ProductListingState> {
  ProductListingCubit(this._repository) : super(const ProductListingState());

  final CatalogRepository _repository;

  Future<void> load({
    String? categoryId,
    String? query,
    ProductSort? sort,
    bool clearCategory = false,
  }) async {
    final next = state.copyWith(
      categoryId: clearCategory ? null : (categoryId ?? state.categoryId),
      query: query ?? state.query,
      sort: sort ?? state.sort,
      status: ListingStatus.loading,
      clearMessage: true,
    );
    emit(next);

    final result = await _repository.getProducts(
      categoryId: next.categoryId,
      query: next.query.trim().isEmpty ? null : next.query.trim(),
      sort: next.sort,
    );
    result.fold(
      (products) => emit(next.copyWith(
        status: ListingStatus.ready,
        products: products,
      )),
      (failure) => emit(next.copyWith(
        status: ListingStatus.failure,
        message: failure.message,
      )),
    );
  }

  Future<void> setCategory(String? id) => load(categoryId: id, clearCategory: id == null);

  Future<void> setQuery(String query) => load(query: query);

  Future<void> setSort(ProductSort sort) => load(sort: sort);

  Future<void> refresh() => load();
}
