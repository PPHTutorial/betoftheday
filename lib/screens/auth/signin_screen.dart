import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback onToggleAuthMode;

  const SignInScreen({
    super.key,
    required this.onToggleAuthMode,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.signin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Defer UI updates to avoid build-time state changes
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          
          if (authProvider.isAuthenticated) {
            // Close the auth screen and return to previous screen
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Signed in successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            // Show error if not authenticated
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.error ?? 'Authentication failed. Please try again.'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Sign in catch block: $e');
      if (mounted) {
        final errorMessage = authProvider.error ?? e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            
            // Logo/Icon
            Icon(
              Icons.sports_soccer,
              size: 80,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              'Welcome Back',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            Text(
              'Sign in to continue',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            
            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to reset password screen
                },
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 24),
            
            // Sign In Button
            ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleSignIn,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign In'),
            ),
            const SizedBox(height: 24),
            
            // Sign Up Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: theme.textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: widget.onToggleAuthMode,
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

