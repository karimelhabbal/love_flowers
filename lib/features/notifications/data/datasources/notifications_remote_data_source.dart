import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/app_notification.dart';

class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource(this._client);

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

  Future<List<AppNotification>> getNotifications() async {
    if (_db.auth.currentUser == null) return const [];
    final rows = await _db
        .from('notifications')
        .select('*')
        .eq('customer_id', _userId)
        .order('created_at', ascending: false)
        .limit(100);
    return rows
        .map((row) => AppNotification.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<void> markAllRead() => _db
      .from('notifications')
      .update(<String, dynamic>{'is_read': true})
      .eq('customer_id', _userId)
      .eq('is_read', false);

  Future<void> markRead(String id) => _db
      .from('notifications')
      .update(<String, dynamic>{'is_read': true})
      .eq('id', id)
      .eq('customer_id', _userId);
}
