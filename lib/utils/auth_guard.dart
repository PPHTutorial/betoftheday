import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/auth_screen.dart';

/// Widget that requires authentication
/// Shows auth screen if user is not authenticated
class AuthGuard extends StatelessWidget {
  final Widget child;
  final String? requiredMessage;

  const AuthGuard({
    super.key,
    required this.child,
    this.requiredMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!authProvider.isAuthenticated) {
          // Show message if provided
          if (requiredMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(requiredMessage!),
                  backgroundColor: Colors.orange,
                  action: SnackBarAction(
                    label: 'Sign In',
                    textColor: Colors.white,
                    onPressed: () {
                      // Navigation handled by showing AuthScreen
                    },
                  ),
                ),
              );
            });
          }
          return const AuthScreen();
        }

        return child;
      },
    );
  }
}

/// Function to check if user is authenticated and show auth screen if not
Future<bool> requireAuth(BuildContext context, {String? message}) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  if (!authProvider.isAuthenticated) {
    // Show auth screen
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Sign In Required'),
          ),
          body: const AuthScreen(),
        ),
        fullscreenDialog: true,
      ),
    );
    
    // Show message if provided
    if (message != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
        ),
      );
    }
    
    return result ?? false;
  }
  
  return true;
}

