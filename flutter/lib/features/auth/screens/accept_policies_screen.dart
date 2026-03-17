import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
import '../providers/auth_provider.dart';

class AcceptPoliciesScreen extends ConsumerWidget {
  const AcceptPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accept Policies'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.policy_outlined,
              size: 64,
              color: Color(0xFF6366F1),
            ),
            const SizedBox(height: 24),
            const Text(
              'Please Accept Our Policies',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Before continuing, please read and accept our Privacy Policy and Terms & Conditions.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {
                // Navigate to privacy policy page
                context.push(RoutePaths.privacyPolicy);
              },
              child: const Text('Read Privacy Policy'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                // Navigate to terms page
                context.push(RoutePaths.termsConditions);
              },
              child: const Text('Read Terms & Conditions'),
            ),
            const Spacer(),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).acceptPolicies();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Accept Policies',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go(RoutePaths.login);
                }
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}