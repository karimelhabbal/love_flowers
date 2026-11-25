import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/localization/app_strings.dart';

/// Explains why sign-in is required and returns the user to this screen after
/// a successful login.
void goToLogin(BuildContext context, {String? returnTo}) {
  final s = AppStrings.of(context);
  final then = returnTo ?? GoRouterState.of(context).uri.toString();
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(s.t('loginToContinue'))));
  context.go('/login?then=${Uri.encodeComponent(then)}');
}
