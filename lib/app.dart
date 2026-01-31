import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/auth/login_screen.dart';
import 'presentation/auth/splash_screen.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/providers.dart';
import 'presentation/crm/crm_shell.dart';
import 'theme/app_theme.dart';

class BilimCrmApp extends ConsumerStatefulWidget {
  const BilimCrmApp({super.key});

  @override
  ConsumerState<BilimCrmApp> createState() => _BilimCrmAppState();
}

class _BilimCrmAppState extends ConsumerState<BilimCrmApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(baseUrlControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'BilimCRM',
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: authState.status == AuthStatus.unknown
          ? const SplashScreen()
          : authState.status == AuthStatus.authenticated
              ? const CrmShell()
              : const LoginScreen(),
    );
  }
}
