import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product_customization.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(this._repository) : super(const ProductDetailsState());

  final CatalogRepository _repository;

  Future<void> load(String id) async {
    emit(state.copyWith(status: DetailsStatus.loading, clearMessage: true));
    final productFuture = _repository.getProduct(id);
    final customizationFuture = _repository.getCustomization(id);
    final productResult = await productFuture;
    final customizationResult = await customizationFuture;

    String? error;
    productResult.fold((_) {}, (failure) => error = failure.message);
    if (error != null) {
      emit(ProductDetailsState(
        status: DetailsStatus.failure,
        message: error,
      ));
      return;
    }

    emit(ProductDetailsState(
      status: DetailsStatus.ready,
      product: productResult.valueOrNull,
      customization: customizationResult.valueOrNull ??
          const ProductCustomizationEntity(),
    ));
  }
}
