import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'screens/shared/splash_screen.dart';
import 'screens/shared/login_portal_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/admin/google_books_search_screen.dart';
import 'screens/student/student_dashboard_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const PocketLibraryApp());
}

class PocketLibraryApp extends StatelessWidget {
  const PocketLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Pocket Library',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.background,
            primaryColor: AppColors.primaryBlue,
            fontFamily: 'Roboto',
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              background: AppColors.background,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: AppColors.primaryBlue,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryBlue,
            ),
          ),
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginPortalScreen(),
            '/admin-dashboard': (context) => const DashboardScreen(),
            '/student-dashboard': (context) => const StudentDashboardScreen(),
            '/admin/google-search': (context) => const GoogleBooksSearchScreen(),
          },
        );
      },
    );
  }
}