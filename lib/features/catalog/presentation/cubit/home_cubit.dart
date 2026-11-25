import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/catalog_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState());

  final CatalogRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading, clearMessage: true));
    final categories = await _repository.getCategories();
    final featured = await _repository.getFeatured();
    final arrivals = await _repository.getNewArrivals();

    String? error;
    categories.fold((_) {}, (failure) => error = failure.message);
    featured.fold((_) {}, (failure) => error ??= failure.message);
    arrivals.fold((_) {}, (failure) => error ??= failure.message);

    if (error != null) {
      emit(HomeState(status: HomeStatus.failure, message: error));
      return;
    }

    emit(HomeState(
      status: HomeStatus.ready,
      categories: categories.valueOrNull ?? const [],
      featured: featured.valueOrNull ?? const [],
      newArrivals: arrivals.valueOrNull ?? const [],
    ));
  }
}
