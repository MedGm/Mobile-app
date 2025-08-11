import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tarl_mobile_app/app/localization/locale_controller.dart';
import 'package:tarl_mobile_app/app/theme/theme.dart';
import 'package:tarl_mobile_app/l10n/app_localizations.dart';
import 'package:tarl_mobile_app/features/auth/presentation/splash_screen.dart';
import 'package:tarl_mobile_app/features/auth/presentation/login_screen.dart';
import 'package:tarl_mobile_app/features/auth/presentation/change_password_screen.dart';
import 'package:tarl_mobile_app/features/shell/presentation/main_shell.dart';
import 'package:tarl_mobile_app/features/students/presentation/student_profile_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'TARL',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: const [
          Breakpoint(start: 0, end: 450, name: MOBILE),
          Breakpoint(start: 451, end: 800, name: TABLET),
          Breakpoint(start: 801, end: 1200, name: DESKTOP),
          Breakpoint(start: 1201, end: double.infinity, name: '4K'),
        ],
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const MainShell(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/change-password') {
          final username = settings.arguments as String? ?? '';
          return MaterialPageRoute(
            builder: (_) => ChangePasswordScreen(username: username),
          );
        }
        if (settings.name == '/student-profile') {
          final student = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (_) => StudentProfileScreen(student: student),
          );
        }
        return null;
      },
    );
  }
}
