import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  const AddressEntity({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.city,
    required this.street,
    this.building = '',
    this.notes = '',
    this.isDefault = false,
    this.zoneId = '',
    this.district = '',
    this.apartment = '',
    this.floor = '',
  });

  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String city;
  final String street;
  final String building;
  final String notes;
  final bool isDefault;
  final String zoneId;
  final String district;
  final String apartment;
  final String floor;

  String get displayLine => [
        street,
        building,
        district,
        city,
      ].where((element) => element.isNotEmpty).join('، ');

  factory AddressEntity.fromMap(Map<String, dynamic> map) {
    return AddressEntity(
      id: map['id'] as String? ?? '',
      label: map['label'] as String? ?? '',
      fullName: map['recipient_name'] as String? ?? '',
      phone: map['recipient_phone'] as String? ?? '',
      city: map['city'] as String? ?? '',
      street: map['street'] as String? ?? '',
      building: map['building'] as String? ?? '',
      notes: map['landmark'] as String? ?? '',
      isDefault: map['is_default'] as bool? ?? false,
      zoneId: map['zone_id'] as String? ?? '',
      district: map['district'] as String? ?? '',
      apartment: map['apartment'] as String? ?? '',
      floor: map['floor'] as String? ?? '',
    );
  }

  /// Column names verified against public.customer_addresses.
  Map<String, dynamic> toMap() => {
        'label': label,
        'recipient_name': fullName,
        'recipient_phone': phone,
        'city': city,
        'district': district,
        'street': street,
        'building': building,
        'apartment': apartment,
        'floor': floor,
        'landmark': notes,
        'zone_id': zoneId.isEmpty ? null : zoneId,
        'is_default': isDefault,
      };

  @override
  List<Object?> get props => [
        id,
        label,
        fullName,
        phone,
        city,
        street,
        building,
        notes,
        isDefault,
        zoneId,
        district,
        apartment,
        floor,
      ];
}
