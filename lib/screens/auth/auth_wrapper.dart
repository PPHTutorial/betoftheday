import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

/// AuthWrapper now allows unauthenticated access to home
/// Authentication is only required for specific protected features
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading indicator during initialization only
        if (authProvider.isLoading && authProvider.user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Always show home screen - it will handle auth requirements internally
        return const HomeScreen();
      },
    );
  }
}

