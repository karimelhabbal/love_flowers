import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../app/localization/app_strings.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/directional_icons.dart';
import '../../../../core/widgets/flower_mark.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _returnPath() {
    final then = GoRouterState.of(context).uri.queryParameters['then'];
    return then != null && then.startsWith('/') && !then.startsWith('//')
        ? then
        : null;
  }

  String _authRoute(String path) {
    final then = _returnPath();
    return then == null ? path : '$path?then=${Uri.encodeComponent(then)}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await di.sl<AuthCubit>().signIn(
      email: _email.text,
      password: _password.text,
    );
    if (ok && mounted) context.go(_returnPath() ?? '/home');
  }

  Future<void> _showResetDialog() async {
    final s = AppStrings.of(context);
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.t('resetPassword')),
        content: AppTextField(
          label: s.t('email'),
          hint: 'name@example.com',
          keyboardType: TextInputType.emailAddress,
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.t('confirm')),
          ),
        ],
      ),
    );
    if (result == true && controller.text.trim().isNotEmpty) {
      final ok = await di.sl<AuthCubit>().resetPassword(controller.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.t(ok ? 'success' : 'errorGeneric'))),
        );
      }
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return BlocConsumer<AuthCubit, AuthState>(
      bloc: di.sl<AuthCubit>(),
      listener: (context, state) {
        if (state.status == AuthStatus.failure && state.message != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        tooltip: s.t('back'),
                        onPressed: () => context.go('/home'),
                        icon: Icon(DirectionalIcons.back(context)),
                      ),
                    ),
                    const FlowerMark(size: 88),
                    const SizedBox(height: 20),
                    Text(
                      s.t('welcomeBack'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.t('tagline'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 36),
                    AppTextField(
                      label: s.t('email'),
                      hint: 'name@example.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: _email,
                      validator: (value) => Validators.email(
                        value,
                        message: s.t('validationError'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      label: s.t('password'),
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscure,
                      controller: _password,
                      suffixIcon: IconButton(
                        tooltip: s.t(
                          _obscure ? 'showPassword' : 'hidePassword',
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                      ),
                      validator: (value) => Validators.password(
                        value,
                        message: s.t('validationError'),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: _showResetDialog,
                        child: Text(s.t('resetPassword')),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: state.isLoading ? null : _submit,
                      child: state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(s.t('login')),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.t('noAccount')),
                        TextButton(
                          onPressed: () => context.go(_authRoute('/register')),
                          child: Text(s.t('signUp')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
