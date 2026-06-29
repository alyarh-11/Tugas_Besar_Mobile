import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'screens/shared/splash_screen.dart';
import 'screens/shared/login_portal_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/admin/google_books_search_screen.dart';
import 'screens/student/student_dashboard_screen.dart';

void main() {
  runApp(const PocketLibraryApp());
}

class PocketLibraryApp extends StatelessWidget {
  const PocketLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Library',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primaryBlue,
        fontFamily: 'Roboto',
      ),
      
      // 1. Jalur gerbang utama diatur di sini
      home: const SplashScreen(),
      
      // 2. Di sini daftar rute sisanya (Rute '/' SUDAH DIHAPUS agar tidak bentrok)
      routes: {
        '/login': (context) => const LoginPortalScreen(),
        '/admin-dashboard': (context) => const DashboardScreen(),
        '/student-dashboard': (context) => const StudentDashboardScreen(),
        '/admin/google-search': (context) => const GoogleBooksSearchScreen(),
      },
    );
  }
}