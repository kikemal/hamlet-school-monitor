import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/constants.dart';
import 'core/network/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/startup_error_app.dart';
import 'router/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!SupabaseConfig.isConfigured) {
    runApp(const MissingSupabaseConfigApp());
    return;
  }

  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    runApp(
      StartupErrorApp(
        title: '${AppConstants.appName} — startup failed',
        message: e.toString(),
      ),
    );
    return;
  }

  runApp(
    const ProviderScope(
      child: HamletSchoolApp(),
    ),
  );
}

class HamletSchoolApp extends ConsumerWidget {
  const HamletSchoolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: goRouter,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
