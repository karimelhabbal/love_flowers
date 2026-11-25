import '../constants/app_constants.dart';

/// Builds public Storage URLs from the `storage_path` values stored in
/// Supabase. The bucket itself must be created and made public in Supabase;
/// this class only formats URLs, it never uploads anything.
abstract final class StorageUrls {
  static String? publicUrl(
    String? path, {
    String bucket = AppConstants.productImagesBucket,
  }) {
    if (path == null || path.trim().isEmpty) return null;
    final normalized = path.trim().replaceAll(r'\', '/');
    final relative = normalized.startsWith('/')
        ? normalized.substring(1)
        : normalized;
    final encoded = Uri(path: relative).toString();
    return '${AppConstants.supabaseUrl}/storage/v1/object/public/$bucket/$encoded';
  }
}
