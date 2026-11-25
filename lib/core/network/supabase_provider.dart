import 'package:supabase_flutter/supabase_flutter.dart';

/// Holds the optional Supabase client so data sources can fail gracefully
/// with a clear configuration error when credentials are not supplied.
class SupabaseProvider {
  const SupabaseProvider(this.client);

  final SupabaseClient? client;
}
