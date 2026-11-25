import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:love_flowers/app/theme/app_theme.dart';
import 'package:love_flowers/core/constants/app_constants.dart';
import 'package:love_flowers/core/network/storage_urls.dart';
import 'package:love_flowers/core/utils/id_generator.dart';
import 'package:love_flowers/features/auth/domain/entities/app_user.dart';
import 'package:love_flowers/features/catalog/domain/entities/category.dart';
import 'package:love_flowers/features/catalog/domain/entities/product.dart';
import 'package:love_flowers/features/orders/domain/entities/address.dart';
import 'package:love_flowers/features/orders/domain/entities/order.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('design system uses the luxury botanical palette', () {
    expect(AppColors.sage, const Color(0xFF5F6D54));
    expect(AppColors.rose, const Color(0xFFD996A2));
    expect(AppColors.cream, const Color(0xFFF7F3EC));
    expect(AppColors.ink, const Color(0xFF48738B));
  });

  test('product entity reads verified Supabase columns', () {
    final product = ProductEntity.fromMap({
      'id': 'p1',
      'category_id': 'c1',
      'name_ar': 'باقة ورد',
      'name_en': 'Rose bouquet',
      'price_egp': 259.50,
      'stock': 7,
      'variant_id': 'v1',
      'image_urls': [
        'https://kdkgkkoscqexgegrukez.supabase.co/storage/v1/object/public/'
            'product-images/roses/1.jpg',
      ],
      'category_name_ar': 'ورود',
      'category_name_en': 'Roses',
      'is_active': true,
      'is_featured': true,
    });

    expect(product.price, 259.5);
    expect(product.effectivePrice, 259.5);
    expect(product.stock, 7);
    expect(product.inStock, isTrue);
    expect(product.variantId, 'v1');
    expect(product.categoryName(false), 'Roses');
    expect(product.coverImage, isNotNull);
    expect(product.hasDiscount, isFalse);
    expect(product.toMap(), isNot(contains('price')));
    expect(product.toMap(), isNot(contains('stock')));
  });

  test('category image path becomes a public storage URL', () {
    final category = CategoryEntity.fromMap({
      'id': 'c1',
      'name_ar': 'ورود',
      'name_en': 'Roses',
      'image_path': 'categories/roses.png',
      'is_active': true,
      'sort_order': 2,
    });
    expect(category.imagePath, 'categories/roses.png');
    expect(
      category.imageUrl,
      '${AppConstants.supabaseUrl}/storage/v1/object/public/'
      'product-images/categories/roses.png',
    );
    expect(category.toMap(), isNot(contains('image_url')));
  });

  test('storage url helper rejects empty paths', () {
    expect(StorageUrls.publicUrl(null), isNull);
    expect(StorageUrls.publicUrl(' '), isNull);
    expect(
      StorageUrls.publicUrl('a b/صورة.jpg'),
      contains('a%20b/'),
    );
  });

  test('profile role is read only and email comes from auth', () {
    final user = AppUser.fromMap({
      'id': 'u1',
      'full_name': 'سارة',
      'phone': '01000000000',
      'role': 'customer',
    });
    expect(user.role, 'customer');
    expect(user.isAdmin, isFalse);
    expect(user.email, isEmpty);
    expect(user.toMap(), isNot(contains('role')));
    expect(user.toMap(), isNot(contains('email')));
  });

  test('address maps recipient columns and zone id', () {
    final address = AddressEntity.fromMap({
      'id': 'a1',
      'label': 'المنزل',
      'recipient_name': 'سارة',
      'recipient_phone': '01000000000',
      'city': 'القاهرة',
      'district': 'مدينة نصر',
      'street': 'شارع النحرير',
      'building': '12',
      'landmark': 'بجوار المترو',
      'zone_id': 'z1',
      'is_default': true,
    });
    expect(address.fullName, 'سارة');
    expect(address.phone, '01000000000');
    expect(address.notes, 'بجوار المترو');
    expect(address.toMap()['recipient_name'], 'سارة');
    expect(address.toMap(), isNot(contains('full_name')));
  });

  test('order entity reads server-computed EGP totals and status history', () {
    final order = OrderEntity.fromMap({
      'id': 'o1',
      'customer_id': 'u1',
      'status': 'out_for_delivery',
      'subtotal_egp': 420.25,
      'delivery_fee_egp': 30,
      'total_egp': 450.25,
      'payment_method': 'cash_on_delivery',
      'recipient_name': 'سارة',
      'recipient_phone': '01000000000',
      'customer_notes': 'اتصل قبل الوصول',
      'order_items': [
        {
          'id': 'oi1',
          'product_id': 'p1',
          'product_name_ar': 'باقة ورد',
          'product_name_en': 'Rose bouquet',
          'variant_name_ar': 'كبيرة',
          'variant_name_en': 'Large',
          'quantity': 2,
          'unit_price_egp': 210.125,
          'line_total_egp': 420.25,
        },
      ],
      'order_status_history': [
        {'id': 'h1', 'new_status': 'confirmed', 'created_at': '2026-11-24T10:00:00Z'},
        {'id': 'h2', 'new_status': 'out_for_delivery', 'created_at': '2026-11-24T14:00:00Z'},
      ],
    });

    expect(order.status, OrderStatus.outForDelivery);
    expect(order.subtotal, 420.25);
    expect(order.deliveryFee, 30);
    expect(order.total, 450.25);
    expect(order.deliveryInstructions, 'اتصل قبل الوصول');
    expect(order.customerName, 'سارة');
    expect(order.items.single.computedLineTotal, 420.25);
    expect(order.items.single.name(false), 'Rose bouquet - Large');
    expect(order.events.last.status, OrderStatus.outForDelivery);
    expect(order.events.last.note, isEmpty);
  });

  test('checkout idempotency keys are unique UUID v4 strings', () {
    final first = IdGenerator.uuidV4();
    final second = IdGenerator.uuidV4();
    final pattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    expect(first, matches(pattern));
    expect(second, matches(pattern));
    expect(first, isNot(second));
  });
}
