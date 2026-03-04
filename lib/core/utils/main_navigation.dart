import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Dummy screens for now - will implement later
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/marketplace/marketplace_screen.dart';
import '../../features/learning/learning_screen.dart';
import '../../features/scan/scan_screen.dart';

import '../../features/onboarding/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../shared/widgets/modern_navigation_bar.dart';
import '../../features/learning/learning_models.dart';
import '../../features/learning/course_detail_screen.dart';
import '../../features/learning/course_content_screen.dart';
import '../../features/marketplace/marketplace_models.dart';
import '../../features/marketplace/add_product_screen.dart';
import '../../features/marketplace/product_detail_screen.dart';
import '../../features/weather/weather_screen.dart';
import '../../features/weather/weather_detail_screen.dart';
import '../../features/weather/weather_models.dart';
import '../../features/profile/profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/marketplace/add',
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: '/learning/detail',
        builder: (context, state) {
          final course = state.extra as Course;
          return CourseDetailScreen(course: course);
        },
      ),
      GoRoute(
        path: '/marketplace/detail',
        builder: (context, state) {
          final product = state.extra as Product;
          return ProductDetailScreen(product: product);
        },
      ),
      GoRoute(
        path: '/learning/content',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final course = extra['course'] as Course;
          final partIndex = extra['partIndex'] as int;
          return CourseContentScreen(course: course, partIndex: partIndex);
        },
      ),
      GoRoute(
        path: '/weather',
        builder: (context, state) => const WeatherScreen(),
      ),
      GoRoute(
        path: '/weather/detail',
        builder: (context, state) {
          final weather = state.extra as LocationWeather;
          return WeatherDetailScreen(weather: weather);
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/marketplace',
            builder: (context, state) => const MarketplaceScreen(),
          ),
          GoRoute(
            path: '/learning',
            builder: (context, state) => const LearningScreen(),
          ),
          GoRoute(
            path: '/scan',
            builder: (context, state) => const ScanScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

class MainScreen extends StatelessWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    
    int getCurrentIndex() {
      if (location.startsWith('/marketplace')) return 1;
      if (location.startsWith('/scan')) return 2; // Central action
      if (location.startsWith('/learning')) return 3;
      if (location.startsWith('/profile')) return 4;
      return 0; // Home
    }

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: ModernNavigationBar(
        selectedIndex: getCurrentIndex(),
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/marketplace'); break;
            case 2: context.go('/scan'); break;
            case 3: context.go('/learning'); break;
            case 4: context.go('/profile'); break;
          }
        },
      ),
    );
  }
}
