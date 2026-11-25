import '../../../../core/error/result.dart';
import '../../../../core/utils/repository_guard.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_data_source.dart';

class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl(this._remote);

  final AddressRemoteDataSource _remote;

  @override
  Future<Result<List<AddressEntity>>> getAddresses() => runSafe(_remote.getAddresses);

  @override
  Future<Result<AddressEntity>> saveAddress(AddressEntity address) =>
      runSafe(() => _remote.saveAddress(address));

  @override
  Future<Result<void>> deleteAddress(String id) =>
      runSafe(() => _remote.deleteAddress(id));

  @override
  Future<Result<void>> setDefaultAddress(String id) =>
      runSafe(() => _remote.setDefaultAddress(id));
}
