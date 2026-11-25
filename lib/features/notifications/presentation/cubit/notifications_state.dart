import 'package:equatable/equatable.dart';

import '../../domain/entities/app_notification.dart';

enum NotificationsStatus { initial, loading, ready, failure }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.items = const [],
    this.message,
  });

  final NotificationsStatus status;
  final List<AppNotification> items;
  final String? message;

  int get unreadCount => items.where((item) => !item.isRead).length;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? items,
    String? message,
    bool clearMessage = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
