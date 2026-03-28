import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:room_chat/core/constants/app_route_paths.dart';
import 'package:room_chat/core/constants/app_strings.dart';
import 'package:room_chat/core/theme/app_spacing.dart';
import 'package:room_chat/core/theme/theme_extensions.dart';
import 'package:room_chat/features/splash/presentation/bloc/splash_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      Navigator.of(context).pushReplacementNamed(AppRoutePaths.joinRoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashBloc()..add(const SplashStarted()),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    final headlineStyle = theme.textTheme.headlineSmall?.copyWith(
      color: colors.primaryHeading1,
      fontWeight: FontWeight.w600,
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pageHorizontal(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/app-logo.png',
                  width: 88,
                  height: 88,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Text(
                AppStrings.appName,
                style: headlineStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
