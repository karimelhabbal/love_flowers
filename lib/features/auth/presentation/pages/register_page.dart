import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../app/localization/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/directional_icons.dart';
import '../../../../core/widgets/flower_mark.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
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
    final ok = await di.sl<AuthCubit>().signUp(
      email: _email.text,
      password: _password.text,
      fullName: _name.text,
      phone: _phone.text,
    );
    if (ok && mounted) context.go(_returnPath() ?? '/home');
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
                        onPressed: () => context.go(_authRoute('/login')),
                        icon: Icon(DirectionalIcons.back(context)),
                      ),
                    ),
                    const FlowerMark(size: 72),
                    const SizedBox(height: 16),
                    Text(
                      s.t('createAccount'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      label: s.t('fullName'),
                      hint: s.t('fullName'),
                      prefixIcon: Icons.person_outline_rounded,
                      controller: _name,
                      validator: (value) => Validators.required(
                        value,
                        message: s.t('validationError'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: s.t('phone'),
                      hint: s.t('phoneHint'),
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      controller: _phone,
                      validator: (value) => Validators.phone(
                        value,
                        message: s.t('validationError'),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 26),
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
                          : Text(s.t('register')),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.t('haveAccount')),
                        TextButton(
                          onPressed: () => context.go(_authRoute('/login')),
                          child: Text(s.t('signIn')),
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
