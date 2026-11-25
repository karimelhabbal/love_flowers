import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    this.isRead = false,
    this.orderId = '',
    this.createdAt,
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final bool isRead;
  final String orderId;
  final DateTime? createdAt;

  String title(bool isArabic) => isArabic ? titleAr : titleEn;
  String body(bool isArabic) => isArabic ? bodyAr : bodyEn;

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String? ?? '',
      titleAr: map['title_ar'] as String? ?? '',
      titleEn: map['title_en'] as String? ?? '',
      bodyAr: map['body_ar'] as String? ?? '',
      bodyEn: map['body_en'] as String? ?? '',
      isRead: map['is_read'] as bool? ?? false,
      orderId: map['order_id'] as String? ?? '',
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        titleAr,
        titleEn,
        bodyAr,
        bodyEn,
        isRead,
        orderId,
        createdAt,
      ];
}
