import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/constants.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/accept_policies_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/friends/screens/friends_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/backup_screen.dart';
import '../../features/settings/recovery_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/privacy_policy_screen.dart';
import '../../features/profile/screens/terms_conditions_screen.dart';

class GoRouterNotifier extends ChangeNotifier {
  final Ref _ref;

  GoRouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (_, __) => notifyListeners(),
    );
  }
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = GoRouterNotifier(ref);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final needsPolicy = authState.status == AuthStatus.needsPolicyAcceptance;
      final isLoggingIn = state.matchedLocation == RoutePaths.login;
      final isSigningUp = state.matchedLocation == RoutePaths.signup;
      final isOnSplash = state.matchedLocation == RoutePaths.splash;
      final isLoading = authState.status == AuthStatus.loading || authState.status == AuthStatus.initial;

      // If loading during app startup or deep links, force splash. 
      // If loading during login or signup actions, stay on that screen.
      if (isLoading) {
        if (isOnSplash || isLoggingIn || isSigningUp) return null;
        return RoutePaths.splash;
      }

      final isAcceptingPolicies = state.matchedLocation == RoutePaths.acceptPolicies;

      // If needs policy acceptance, redirect to accept policies
      if (needsPolicy && !isAcceptingPolicies) {
        return RoutePaths.acceptPolicies;
      }

      // If not authenticated and not on Auth screens, redirect to login
      if (!isAuthenticated && !isLoggingIn && !isSigningUp && !isAcceptingPolicies && state.matchedLocation != RoutePaths.splash) {
        return RoutePaths.login;
      }

      // If on splash screen and not authenticated, go to login
      if (!isAuthenticated && isOnSplash && !isLoading) {
        return RoutePaths.login;
      }

      // If authenticated and on auth-related screens, redirect to home
      if (isAuthenticated && (isLoggingIn || isSigningUp || isOnSplash || state.matchedLocation == RoutePaths.acceptPolicies)) {
        return RoutePaths.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.signup,
        name: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RoutePaths.acceptPolicies,
        name: RouteNames.acceptPolicies,
        builder: (context, state) => const AcceptPoliciesScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'chat/:userId',
            name: RouteNames.chat,
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return ChatScreen(otherUserId: userId);
            },
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.friends,
        name: RouteNames.friends,
        builder: (context, state) => const FriendsScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'backup',
            builder: (context, state) => const BackupScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.privacyPolicy,
        name: RouteNames.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: RoutePaths.termsConditions,
        name: RouteNames.termsConditions,
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: '/recovery',
        builder: (context, state) => const RecoveryScreen(),
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});