import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/write/write_screen.dart';
import '../../features/review/review_screen.dart';
import '../../features/archive/archive_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  refreshListenable: NotificationService.instance.pendingRoute,
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool('onboarded') ?? false;
    if (!onboarded && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }

    final pendingRoute = NotificationService.instance.pendingRoute.value;
    if (pendingRoute != null && state.matchedLocation != pendingRoute) {
      NotificationService.instance.clearPendingRoute();
      return pendingRoute;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => _fadePage(const OnboardingScreen()),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => _fadePage(const HomeScreen()),
    ),
    GoRoute(
      path: '/write',
      pageBuilder: (context, state) => _slidePage(const WriteScreen()),
    ),
    GoRoute(
      path: '/review/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _slidePage(ReviewScreen(worryId: id));
      },
    ),
    GoRoute(
      path: '/archive',
      pageBuilder: (context, state) => _slidePage(const ArchiveScreen()),
    ),
  ],
);

CustomTransitionPage _fadePage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 600),
  );
}

CustomTransitionPage _slidePage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: animation.drive(tween), child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}
