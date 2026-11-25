import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    this.fullName = '',
    this.phone = '',
    this.avatarUrl = '',
    this.role = 'customer',
    this.createdAt,
  });

  final String id;

  /// Email comes from auth.users; `profiles` has no email column.
  final String email;
  final String fullName;
  final String phone;
  final String avatarUrl;

  /// Read from profiles.role. The client never writes this field.
  final String role;
  final DateTime? createdAt;

  bool get isAdmin => role == 'admin';
  String get displayName => fullName.trim().isEmpty ? email : fullName.trim();

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String? ?? '',
      role: map['role'] as String? ?? 'customer',
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'] as String),
    );
  }

  /// Deliberately excludes email and role: users cannot change their own role.
  Map<String, dynamic> toMap() => {
        'full_name': fullName,
        'phone': phone,
        'avatar_url': avatarUrl,
      };

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phone,
        avatarUrl,
        role,
        createdAt,
      ];
}
