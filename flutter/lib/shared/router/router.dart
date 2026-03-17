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
import '../../features/profile/screens/profile_screen.dart';

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final needsPolicy = authState.status == AuthStatus.needsPolicyAcceptance;
      final isLoggingIn = state.matchedLocation == RoutePaths.login;
      final isSigningUp = state.matchedLocation == RoutePaths.signup;
      final isOnSplash = state.matchedLocation == RoutePaths.splash;

      // If still loading, stay on splash
      if (authState.status == AuthStatus.loading || authState.status == AuthStatus.initial) {
        if (!isOnSplash) {
          return RoutePaths.splash;
        }
        return null;
      }

      // If needs policy acceptance, redirect to accept policies
      if (needsPolicy && state.matchedLocation != RoutePaths.acceptPolicies) {
        return RoutePaths.acceptPolicies;
      }

      // If not authenticated, redirect to login
      if (!isAuthenticated && !isLoggingIn && !isSigningUp) {
        return RoutePaths.login;
      }

      // If authenticated and on login/signup, redirect to home
      if (isAuthenticated && (isLoggingIn || isSigningUp)) {
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