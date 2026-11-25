import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState());

  final NotificationsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(
      status: NotificationsStatus.loading,
      clearMessage: true,
    ));
    final result = await _repository.getNotifications();
    result.fold(
      (items) => emit(
        NotificationsState(status: NotificationsStatus.ready, items: items),
      ),
      (failure) => emit(
        NotificationsState(
          status: NotificationsStatus.failure,
          message: failure.message,
        ),
      ),
    );
  }

  Future<void> markAllRead() async {
    final result = await _repository.markAllRead();
    result.fold(
      (_) => emit(state.copyWith(
        items: state.items.map((item) => item.isRead
            ? item
            : AppNotification(
                id: item.id,
                titleAr: item.titleAr,
                titleEn: item.titleEn,
                bodyAr: item.bodyAr,
                bodyEn: item.bodyEn,
                isRead: true,
                orderId: item.orderId,
                createdAt: item.createdAt,
              )).toList(),
      )),
      (failure) => emit(state.copyWith(message: failure.message)),
    );
  }

  Future<void> markRead(String id) async {
    final result = await _repository.markRead(id);
    result.fold(
      (_) => load(),
      (failure) => emit(state.copyWith(message: failure.message)),
    );
  }
}
