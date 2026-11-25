import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/favorites_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._repository) : super(const FavoritesState());

  final FavoritesRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: FavoritesStatus.loading, clearMessage: true));
    final idsResult = await _repository.getFavoriteIds();
    idsResult.fold(
      (ids) => emit(state.copyWith(
        status: FavoritesStatus.ready,
        ids: ids,
      )),
      (failure) => emit(
        FavoritesState(status: FavoritesStatus.failure, message: failure.message),
      ),
    );
  }

  Future<void> loadProducts() async {
    emit(state.copyWith(status: FavoritesStatus.loading, clearMessage: true));
    final result = await _repository.getFavoriteProducts();
    result.fold(
      (products) => emit(state.copyWith(
        status: FavoritesStatus.ready,
        products: products,
      )),
      (failure) => emit(
        FavoritesState(status: FavoritesStatus.failure, message: failure.message),
      ),
    );
  }

  Future<bool> toggle(String productId) async {
    final wasFavorite = state.isFavorite(productId);
    final nextIds = Set<String>.from(state.ids);
    if (wasFavorite) {
      nextIds.remove(productId);
    } else {
      nextIds.add(productId);
    }
    emit(state.copyWith(ids: nextIds));

    final result = await _repository.toggleFavorite(productId);
    return result.fold(
      (isFavorite) {
        final updated = Set<String>.from(state.ids);
        if (isFavorite) {
          updated.add(productId);
        } else {
          updated.remove(productId);
        }
        emit(state.copyWith(status: FavoritesStatus.ready, ids: updated));
        return isFavorite;
      },
      (failure) {
        final restored = Set<String>.from(state.ids);
        if (wasFavorite) {
          restored.add(productId);
        } else {
          restored.remove(productId);
        }
        emit(state.copyWith(ids: restored, message: failure.message));
        return false;
      },
    );
  }
}
