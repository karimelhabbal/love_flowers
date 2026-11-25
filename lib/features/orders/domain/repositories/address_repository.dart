import '../../../../core/error/result.dart';
import '../entities/address.dart';

abstract interface class AddressRepository {
  Future<Result<List<AddressEntity>>> getAddresses();

  Future<Result<AddressEntity>> saveAddress(AddressEntity address);

  Future<Result<void>> deleteAddress(String id);

  Future<Result<void>> setDefaultAddress(String id);
}
