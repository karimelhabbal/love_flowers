import 'package:equatable/equatable.dart';

import '../../domain/entities/address.dart';

enum AddressStatus { initial, loading, ready, failure }

class AddressState extends Equatable {
  const AddressState({
    this.status = AddressStatus.initial,
    this.addresses = const [],
    this.message,
  });

  final AddressStatus status;
  final List<AddressEntity> addresses;
  final String? message;

  AddressEntity? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  AddressState copyWith({
    AddressStatus? status,
    List<AddressEntity>? addresses,
    String? message,
    bool clearMessage = false,
  }) {
    return AddressState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, addresses, message];
}
