import 'package:equatable/equatable.dart';

/// Values match public.order_status in Supabase.
enum OrderStatus {
  pending('pending', 'statusPending'),
  confirmed('confirmed', 'statusConfirmed'),
  preparing('preparing', 'statusPreparing'),
  ready('ready', 'statusReady'),
  outForDelivery('out_for_delivery', 'statusOutForDelivery'),
  delivered('delivered', 'statusDelivered'),
  cancelled('cancelled', 'statusCancelled');

  const OrderStatus(this.value, this.labelKey);

  final String value;
  final String labelKey;

  static OrderStatus fromString(String? value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }

  int get stepIndex => switch (this) {
        OrderStatus.pending => 0,
        OrderStatus.confirmed => 1,
        OrderStatus.preparing => 2,
        OrderStatus.ready => 3,
        OrderStatus.outForDelivery => 4,
        OrderStatus.delivered => 5,
        OrderStatus.cancelled => 0,
      };
}

class OrderItemEntity extends Equatable {
  const OrderItemEntity({
    required this.id,
    required this.productId,
    required this.productNameAr,
    required this.productNameEn,
    this.imageUrl = '',
    required this.quantity,
    required this.unitPrice,
    this.lineTotal = 0,
    this.sku = '',
    this.giftMessage = '',
    this.giftWrap = false,
  });

  final String id;
  final String productId;
  final String productNameAr;
  final String productNameEn;
  final String imageUrl;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final String sku;
  final String giftMessage;
  final bool giftWrap;

  String name(bool isArabic) => isArabic ? productNameAr : productNameEn;
  double get computedLineTotal =>
      lineTotal > 0 ? lineTotal : unitPrice * quantity;

  @override
  List<Object?> get props => [
        id,
        productId,
        productNameAr,
        productNameEn,
        imageUrl,
        quantity,
        unitPrice,
        lineTotal,
        giftMessage,
        giftWrap,
      ];

  factory OrderItemEntity.fromMap(Map<String, dynamic> map) {
    final variantAr = map['variant_name_ar'] as String? ?? '';
    final variantEn = map['variant_name_en'] as String? ?? '';
    final images = map['image_urls'];
    String image = '';
    if (images is List && images.isNotEmpty && images.first is String) {
      image = images.first as String;
    }

    return OrderItemEntity(
      id: map['id'] as String? ?? '',
      productId: map['product_id'] as String? ?? '',
      productNameAr: [
        map['product_name_ar'] as String? ?? '',
        variantAr,
      ].where((part) => part.isNotEmpty).join(' - '),
      productNameEn: [
        map['product_name_en'] as String? ?? '',
        variantEn,
      ].where((part) => part.isNotEmpty).join(' - '),
      imageUrl: image,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (map['unit_price_egp'] as num?)?.toDouble() ?? 0,
      lineTotal: (map['line_total_egp'] as num?)?.toDouble() ?? 0,
      sku: map['sku'] as String? ?? '',
      giftMessage: map['gift_message'] as String? ?? '',
      giftWrap: map['gift_wrap'] as bool? ?? false,
    );
  }
}

class OrderStatusEventEntity extends Equatable {
  const OrderStatusEventEntity({
    required this.id,
    required this.status,
    this.note = '',
    this.createdAt,
  });

  final String id;
  final OrderStatus status;
  final String note;
  final DateTime? createdAt;

  factory OrderStatusEventEntity.fromMap(Map<String, dynamic> map) {
    return OrderStatusEventEntity(
      id: map['id'] as String? ?? '',
      status: OrderStatus.fromString(
        (map['new_status'] as String?) ?? (map['status'] as String?),
      ),
      note: map['note'] as String? ?? '',
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, status, note, createdAt];
}

class OrderEntity extends Equatable {
  const OrderEntity({
    required this.id,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.customerId = '',
    this.paymentMethod = 'cash_on_delivery',
    this.paymentStatus = '',
    this.orderNumber = '',
    this.addressSnapshot = const {},
    this.giftSnapshot = const {},
    this.deliveryInstructions = '',
    this.createdAt,
    this.updatedAt,
    this.items = const [],
    this.events = const [],
    this.customerName = '',
    this.customerPhone = '',
    this.deliveryDate = '',
    this.deliveryTimeSlot = '',
    this.discount = 0,
  });

  final String id;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String customerId;
  final String paymentMethod;
  final String paymentStatus;
  final String orderNumber;
  final Map<String, dynamic> addressSnapshot;
  final Map<String, dynamic> giftSnapshot;
  final String deliveryInstructions;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderItemEntity> items;
  final List<OrderStatusEventEntity> events;
  final String customerName;
  final String customerPhone;
  final String deliveryDate;
  final String deliveryTimeSlot;
  final double discount;

  factory OrderEntity.fromMap(Map<String, dynamic> map) {
    final itemList = <OrderItemEntity>[];
    final rawItems = map['order_items'];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          itemList.add(OrderItemEntity.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }
    final eventList = <OrderStatusEventEntity>[];
    final rawEvents = map['order_status_history'];
    if (rawEvents is List) {
      for (final event in rawEvents) {
        if (event is Map) {
          eventList.add(
            OrderStatusEventEntity.fromMap(Map<String, dynamic>.from(event)),
          );
        }
      }
    } else if (rawEvents is List &&
        map['order_status_events'] is List) {
      // Backwards compatible with an already-loaded event list.
      for (final event in map['order_status_events'] as List) {
        if (event is Map) {
          eventList.add(
            OrderStatusEventEntity.fromMap(Map<String, dynamic>.from(event)),
          );
        }
      }
    }

    final customerName = map['recipient_name'] as String? ?? '';
    final customerPhone = map['recipient_phone'] as String? ?? '';
    final deliveryDate = map['delivery_date'] as String? ?? '';
    final deliveryTimeSlot = map['delivery_time_slot'] as String? ?? '';

    return OrderEntity(
      id: map['id'] as String? ?? '',
      customerId: map['customer_id'] as String? ?? '',
      status: OrderStatus.fromString(map['status'] as String?),
      subtotal: (map['subtotal_egp'] as num?)?.toDouble() ?? 0,
      deliveryFee: (map['delivery_fee_egp'] as num?)?.toDouble() ?? 0,
      total: (map['total_egp'] as num?)?.toDouble() ?? 0,
      discount: (map['discount_egp'] as num?)?.toDouble() ?? 0,
      paymentMethod: map['payment_method'] as String? ?? 'cash_on_delivery',
      paymentStatus: map['payment_status'] as String? ?? '',
      orderNumber: map['order_number'] as String? ?? '',
      addressSnapshot: <String, dynamic>{
        'recipient_name': customerName,
        'recipient_phone': customerPhone,
        'delivery_date': deliveryDate,
        'delivery_time_slot': deliveryTimeSlot,
      },
      giftSnapshot: <String, dynamic>{
        'gift_message': map['gift_message'] as String? ?? '',
        'gift_wrap': map['gift_wrap'] as bool? ?? false,
      },
      deliveryInstructions: map['customer_notes'] as String? ?? '',
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.tryParse(map['updated_at'] as String),
      items: itemList,
      events: eventList,
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryDate: deliveryDate,
      deliveryTimeSlot: deliveryTimeSlot,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        status,
        subtotal,
        deliveryFee,
        total,
        discount,
        paymentMethod,
        paymentStatus,
        orderNumber,
        addressSnapshot,
        giftSnapshot,
        deliveryInstructions,
        createdAt,
        updatedAt,
        items,
        events,
      ];
}
