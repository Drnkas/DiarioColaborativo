import 'package:diario_colaborativo/features/auth/pages/auth/auth_page.dart';
import 'package:diario_colaborativo/features/diary/pages/create_post/create_post_page.dart';
import 'package:diario_colaborativo/features/diary/pages/detail_post/detail_post_page.dart';
import 'package:diario_colaborativo/features/auth/pages/login/login_page.dart';
import 'package:diario_colaborativo/features/auth/pages/sign_up/signup_page.dart';
import 'package:diario_colaborativo/features/home/pages/base/base_page.dart';
import 'package:diario_colaborativo/features/intro/pages/force_update/force_update_page.dart';
import 'package:diario_colaborativo/features/intro/pages/maintenance/maintenance_page.dart';
import 'package:diario_colaborativo/features/intro/pages/not_found_page/not_found_page.dart';
import 'package:diario_colaborativo/features/intro/pages/onboarding/onboarding_page.dart';
import 'package:go_router/go_router.dart';

import '../../features/intro/pages/splash/splash_page.dart';

final router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    return null;
  },
  errorBuilder: (context, state) => NotFoundPage(),
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.auth,
      builder: (context, state) => const AuthPage(),
      routes: [
        GoRoute(
          path: AppRoutes.signUp.path,
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: AppRoutes.login.path,
          builder: (context, state) => const LoginPage(),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.maintenance,
      builder: (context, state) => const MaintenancePage(),
    ),
    GoRoute(
      path: AppRoutes.forceUpdate,
      builder: (context, state) => const ForceUpdatePage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const BasePage(),
      routes: [
        GoRoute(
          path: 'create-entry',
          builder: (context, state) => const CreatePostPage(),
        ),
        GoRoute(
          path: 'entry/:entryId',
          builder: (context, state) {
            return DetailPostPage(
              postId: state.pathParameters['postId'] ?? '',
              initialpost: state.extra,
            );
          },
        ),
      ],
    ),
  ],
);

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String maintenance = '/maintenance';
  static const String forceUpdate = '/force-update';
  static const String home = '/home';
  static const String createpost = '/home/create-entry';
  static const String postDetail = '/home/entry';

  static const AppRoute signUp = AppRoute(
    fullPath: '/auth/signup',
    path: 'signup',
  );

  static const AppRoute login = AppRoute(
    fullPath: '/auth/login',
    path: 'login',
  );
}

class AppRoute {
  const AppRoute({required this.fullPath, required this.path});

  final String fullPath;
  final String path;
}
