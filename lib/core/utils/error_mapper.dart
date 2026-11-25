import '../error/failures.dart';

/// Converts provider-specific exceptions into domain failures so that Cubits
/// and widgets never branch on Supabase implementation details.
Failure mapError(Object error) {
  final text = error.toString();

  if (text.contains('Supabase is not configured')) {
    return ConfigurationFailure(text);
  }
  if (_looksLikeNetwork(text)) {
    return NetworkFailure(text);
  }
  if (text.contains('AuthException') ||
      text.contains('Invalid login credentials') ||
      text.contains('Email not confirmed')) {
    return AuthFailure(text);
  }
  if (text.contains('permission denied') ||
      text.contains('row-level security') ||
      text.toLowerCase().contains('rls')) {
    return PermissionFailure(text);
  }
  if (text.contains('PGRST116') || text.toLowerCase().contains('no rows')) {
    return NotFoundFailure(text);
  }
  if (text.contains('PGRST') || text.contains('PostgrestException')) {
    return ServerFailure(text, 'postgrest');
  }
  return ServerFailure(text);
}

bool _looksLikeNetwork(String text) {
  final lower = text.toLowerCase();
  return lower.contains('socketexception') ||
      lower.contains('connection failed') ||
      lower.contains('network is unreachable') ||
      lower.contains('timed out') ||
      lower.contains('failed host lookup');
}
