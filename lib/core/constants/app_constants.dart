/// Central, non-secret configuration for Love Flowers.
///
/// The Supabase publishable key is a public, RLS-scoped key. A service-role
/// key must never be present in this file or anywhere in the client app.
abstract final class AppConstants {
  static const String appName = 'Love Flowers';
  static const String appNameAr = 'زهور الحب';
  static const String packageId = 'com.loveflowers.app';

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://kdkgkkoscqexgegrukez.supabase.co',
  );

  /// Prefer the newer publishable key. Legacy anon keys are accepted through
  /// the fallback so existing Supabase projects keep working.
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'sb_publishable_3NnCaGJSgqEwaJr39n27Hg__z-DPi1x',
    ),
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static String get functionsBaseUrl => '$supabaseUrl/functions/v1';

  /// Prices in Supabase are numeric(12,2) EGP, not minor units.
  static const String currencyCode = 'EGP';
  static const String currencySymbol = 'ج.م';

  /// UI fallback shown before a delivery zone is resolved by the server.
  static const double defaultDeliveryFee = 0.0;
  static const double freeDeliveryThreshold = 0.0;
  static const int estimatedDeliveryMinutes = 120;

  static const String localePrefKey = 'app_locale';
  static const String themePrefKey = 'app_theme_mode';
  static const String onboardingPrefKey = 'onboarding_completed';
  static const int onboardingPages = 3;

  static const String productImagesBucket = 'product-images';

  static const int maxImageSizeMb = 8;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];
}
