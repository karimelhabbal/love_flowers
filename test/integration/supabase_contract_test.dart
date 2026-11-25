import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:love_flowers/core/constants/app_constants.dart';

/// Read-only checks against the real Supabase project. They verify the
/// integration contract that the Flutter client depends on. No data is
/// written, no authenticated session is used.
void main() {
  const baseUrl = 'https://kdkgkkoscqexgegrukez.supabase.co';
  const key = 'sb_publishable_3NnCaGJSgqEwaJr39n27Hg__z-DPi1x';

  Future<(int, String)> request(
    String method,
    String path, {
    String? body,
  }) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('$baseUrl$path');
      final request = method == 'GET'
          ? await client.getUrl(uri)
          : await client.postUrl(uri);
      request.headers
        ..set('apikey', key)
        ..set('Authorization', 'Bearer $key');
      if (body != null) {
        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        request.write(body);
      }
      final response = await request.close();
      final text = await response.transform(utf8.decoder).join();
      return (response.statusCode, text);
    } finally {
      client.close();
    }
  }

  test('public catalogue tables are reachable with the publishable key', () async {
    const tables = [
      'branches',
      'categories',
      'products',
      'product_variants',
      'product_images',
      'product_option_groups',
      'product_options',
      'flower_types',
      'product_flower_options',
      'product_components',
      'product_addons',
      'delivery_zones',
    ];
    for (final table in tables) {
      final (status, body) =
          await request('GET', '/rest/v1/$table?select=*&limit=0');
      expect(status, 200, reason: '$table: $body');
    }
  });

  test('customer-scoped tables deny anonymous access', () async {
    const tables = [
      'profiles',
      'customer_addresses',
      'carts',
      'cart_items',
      'favorites',
      'orders',
      'order_status_history',
    ];
    for (final table in tables) {
      final (status, _) =
          await request('GET', '/rest/v1/$table?select=*&limit=0');
      expect(status, 401, reason: '$table must not be readable by anon');
    }
  });

  test('checkout_cart exists but is not executable anonymously', () async {
    final payload = jsonEncode({
      'p_address_id': null,
      'p_cart_id': null,
      'p_checkout_key': null,
      'p_customer_notes': null,
      'p_delivery_date': null,
      'p_delivery_time_slot': null,
    });
    final (status, body) =
        await request('POST', '/rest/v1/rpc/checkout_cart', body: payload);
    expect(status, 401, reason: body);
    expect(body, contains('checkout_cart'));
  });

  test('notifications are exposed but empty for anon; bucket metadata hidden',
      () async {
    final (notificationStatus, notificationBody) = await request(
      'GET',
      '/rest/v1/notifications?select=*&limit=0',
    );
    expect(notificationStatus, 200, reason: notificationBody);
    expect(notificationBody, '[]');

    final (bucketStatus, bucketBody) = await request(
      'GET',
      '/storage/v1/bucket/product-images',
    );
    expect(bucketStatus, 400, reason: bucketBody);
    expect(bucketBody, contains('Bucket not found'));
  });

  test('client points at the approved Supabase project', () {
    expect(AppConstants.supabaseUrl, contains('kdkgkkoscqexgegrukez'));
    expect(AppConstants.productImagesBucket, 'product-images');
    expect(AppConstants.currencyCode, 'EGP');
  });
}
