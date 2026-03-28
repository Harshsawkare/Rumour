import 'package:flutter/material.dart';

import 'package:room_chat/core/theme/app_colors_extension.dart';

extension AppThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
