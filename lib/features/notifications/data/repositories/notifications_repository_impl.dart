import '../../../../core/error/result.dart';
import '../../../../core/utils/repository_guard.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteDataSource _remote;

  @override
  Future<Result<List<AppNotification>>> getNotifications() =>
      runSafe(_remote.getNotifications);

  @override
  Future<Result<void>> markAllRead() => runSafe(_remote.markAllRead);

  @override
  Future<Result<void>> markRead(String id) =>
      runSafe(() => _remote.markRead(id));
}
