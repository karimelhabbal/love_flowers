import 'package:flutter/material.dart';

/// Icons that must follow the active text direction in this bilingual app.
abstract final class DirectionalIcons {
  static IconData forward(BuildContext context) =>
      Directionality.of(context) == TextDirection.rtl
          ? Icons.chevron_left_rounded
          : Icons.chevron_right_rounded;

  static IconData back(BuildContext context) =>
      Directionality.of(context) == TextDirection.rtl
          ? Icons.arrow_forward_ios_rounded
          : Icons.arrow_back_ios_new_rounded;
}
