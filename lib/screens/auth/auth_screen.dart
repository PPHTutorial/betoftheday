import 'package:flutter/material.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignIn = true;

  void _toggleAuthMode() {
    setState(() {
      _isSignIn = !_isSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isSignIn
            ? SignInScreen(onToggleAuthMode: _toggleAuthMode)
            : SignUpScreen(onToggleAuthMode: _toggleAuthMode),
      ),
    );
  }
}

