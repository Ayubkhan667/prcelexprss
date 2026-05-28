import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../../data/providers/auth_provider.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/admin/admin_main_screen.dart';
import '../../presentation/screens/staff/staff_main_screen.dart';
import '../../presentation/screens/supervisor/supervisor_main_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  return GoRouter(
    initialLocation: AppConstants.routeSplash,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isSplash = location == AppConstants.routeSplash;
      final isLogin = location == AppConstants.routeLogin;

      if (!authState.isInitialized) {
        return isSplash ? null : AppConstants.routeSplash;
      }

      if (!authState.isLoggedIn || authState.user == null) {
        return isLogin ? null : AppConstants.routeLogin;
      }

      final homeRoute = AppConstants.homeRouteForRole(authState.user!.role);

      if (isSplash || isLogin) {
        return homeRoute;
      }

      if (!AppConstants.isRouteAllowedForRole(
        role: authState.user!.role,
        location: location,
      )) {
        return homeRoute;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.routeSplash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAdmin,
        builder: (_, __) => const AdminMainScreen(),
      ),
      GoRoute(
        path: AppConstants.routeSupervisor,
        builder: (_, __) => const SupervisorMainScreen(),
      ),
      GoRoute(
        path: AppConstants.routeStaff,
        builder: (_, __) => const StaffMainScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
