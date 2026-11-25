import '../../../../core/error/result.dart';
import '../entities/app_notification.dart';

abstract interface class NotificationsRepository {
  Future<Result<List<AppNotification>>> getNotifications();

  Future<Result<void>> markAllRead();

  Future<Result<void>> markRead(String id);
}
