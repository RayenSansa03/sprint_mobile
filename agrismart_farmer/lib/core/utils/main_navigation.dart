import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/marketplace/marketplace_screen.dart';
import '../../features/learning/learning_screen.dart';
import '../../features/scan/scan_screen.dart';
import '../../features/auth/auth_service.dart';

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
import '../../features/chatbot/chatbot_screen.dart';
import '../../features/chat/chat_list_screen.dart';
import '../../features/chat/chat_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Routes publiques — accessibles sans être connecté
const _publicRoutes = {'/splash', '/onboarding', '/login', '/register'};

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',

    /// Garde d'authentification — redirige vers /login si non connecté
    redirect: (context, state) {
      final isLoggedIn = authState != null;
      final isPublic = _publicRoutes.contains(state.matchedLocation);

      if (!isLoggedIn && !isPublic) {
        return '/login';
      }
      // Si déjà connecté et qu'on va vers une page publique → dashboard
      if (isLoggedIn && (
          state.matchedLocation == '/login' || 
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/onboarding'
      )) {
        return authState.role?.toUpperCase() == 'VIEWER' ? '/marketplace' : '/';
      }

      // Force VIEWER to marketplace if they try to access dashboard or scan/learn
      if (isLoggedIn && authState.role?.toUpperCase() == 'VIEWER') {
        final restricted = {'/', '/scan', '/learning'};
        if (restricted.contains(state.matchedLocation)) {
          return '/marketplace';
        }
      }
      return null;
    },

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
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
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
      GoRoute(
        path: '/chatbot',
        builder: (context, state) => const ChatbotScreen(),
      ),
      GoRoute(
        path: '/chat/inbox',
        builder: (context, state) => const ChatListScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          final user = ref.watch(authStateProvider);
          return MainScreen(child: child, userRole: user?.role ?? '');
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

class MainScreen extends ConsumerWidget {
  final Widget child;
  final String userRole;
  const MainScreen({super.key, required this.child, required this.userRole});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final isViewer = userRole.toUpperCase() == 'VIEWER';

    int getCurrentIndex() {
      if (location.startsWith('/marketplace')) return 1;
      if (location.startsWith('/scan')) return 2;
      if (location.startsWith('/learning')) return 3;
      if (location.startsWith('/profile')) return 4;
      return 0;
    }

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: isViewer ? null : ModernNavigationBar(
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
