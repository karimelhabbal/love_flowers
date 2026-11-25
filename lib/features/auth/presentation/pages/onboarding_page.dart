import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../app/localization/app_strings.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/flower_mark.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static const _icons = [
    Icons.local_florist_rounded,
    Icons.delivery_dining_rounded,
    Icons.card_giftcard_rounded,
  ];

  static const _titleKeys = [
    'onboarding1Title',
    'onboarding2Title',
    'onboarding3Title',
  ];

  static const _bodyKeys = [
    'onboarding1Body',
    'onboarding2Body',
    'onboarding3Body',
  ];

  Future<void> _finish() async {
    await di.sl<SharedPreferences>().setBool(AppConstants.onboardingPrefKey, true);
    if (mounted) context.go('/home');
  }

  void _next() {
    if (_page < AppConstants.onboardingPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: TextButton(
                onPressed: _finish,
                child: Text(s.t('skip')),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: AppConstants.onboardingPages,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.sand),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.sage.withValues(alpha: 0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: index == 0
                              ? const FlowerMark(size: 150)
                              : Icon(
                                  _icons[index],
                                  size: 96,
                                  color: index == 1
                                      ? AppColors.sage
                                      : AppColors.rose,
                                ),
                        ),
                        const SizedBox(height: 44),
                        Text(
                          s.t(_titleKeys[index]),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          s.t(_bodyKeys[index]),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                                height: 1.7,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(AppConstants.onboardingPages, (index) {
                final active = index == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active ? AppColors.sage : AppColors.sand,
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(
                  _page == AppConstants.onboardingPages - 1
                      ? s.t('getStarted')
                      : s.t('next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
