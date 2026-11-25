import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  AddressCubit(this._repository) : super(const AddressState());

  final AddressRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: AddressStatus.loading, clearMessage: true));
    final result = await _repository.getAddresses();
    result.fold(
      (addresses) =>
          emit(AddressState(status: AddressStatus.ready, addresses: addresses)),
      (failure) => emit(
        AddressState(status: AddressStatus.failure, message: failure.message),
      ),
    );
  }

  Future<AddressEntity?> save(AddressEntity address) async {
    emit(state.copyWith(status: AddressStatus.loading, clearMessage: true));
    final result = await _repository.saveAddress(address);
    return result.fold(
      (saved) {
        emit(state.copyWith(status: AddressStatus.ready));
        return saved;
      },
      (failure) {
        emit(state.copyWith(
          status: AddressStatus.failure,
          message: failure.message,
        ));
        return null;
      },
    );
  }

  Future<void> remove(String id) async {
    final result = await _repository.deleteAddress(id);
    result.fold(
      (_) => load(),
      (failure) => emit(state.copyWith(message: failure.message)),
    );
  }

  Future<void> setDefault(String id) async {
    final result = await _repository.setDefaultAddress(id);
    result.fold((_) => load(), (failure) {
      emit(state.copyWith(message: failure.message));
    });
  }
}
