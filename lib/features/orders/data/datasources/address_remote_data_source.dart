import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/address.dart';

class AddressRemoteDataSource {
  AddressRemoteDataSource(this._client);

  final SupabaseClient? _client;

  SupabaseClient get _db {
    final client = _client;
    if (client == null || !AppConstants.isSupabaseConfigured) {
      throw StateError('Supabase is not configured');
    }
    return client;
  }

  String get _userId {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw StateError('Not signed in');
    return id;
  }

  Future<List<AddressEntity>> getAddresses() async {
    final rows = await _db
        .from('customer_addresses')
        .select('*')
        .eq('customer_id', _userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);
    return rows
        .map((row) => AddressEntity.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<AddressEntity> saveAddress(AddressEntity address) async {
    final payload = <String, dynamic>{
      ...address.toMap(),
      'customer_id': _userId,
    }..remove('id');

    final Map<String, dynamic> row;
    if (address.id.isEmpty) {
      row = Map<String, dynamic>.from(
        await _db
            .from('customer_addresses')
            .insert(payload)
            .select('*')
            .single(),
      );
    } else {
      row = Map<String, dynamic>.from(
        await _db
            .from('customer_addresses')
            .update(payload)
            .eq('id', address.id)
            .eq('customer_id', _userId)
            .select('*')
            .single(),
      );
    }

    if (address.isDefault) {
      await _db
          .from('customer_addresses')
          .update(<String, dynamic>{'is_default': false})
          .eq('customer_id', _userId)
          .neq('id', row['id'] as String);
    }
    return AddressEntity.fromMap(row);
  }

  Future<void> deleteAddress(String id) => _db
      .from('customer_addresses')
      .delete()
      .eq('id', id)
      .eq('customer_id', _userId);

  Future<void> setDefaultAddress(String id) async {
    await _db
        .from('customer_addresses')
        .update(<String, dynamic>{'is_default': true})
        .eq('id', id)
        .eq('customer_id', _userId);
    await _db
        .from('customer_addresses')
        .update(<String, dynamic>{'is_default': false})
        .eq('customer_id', _userId)
        .neq('id', id);
  }
}
