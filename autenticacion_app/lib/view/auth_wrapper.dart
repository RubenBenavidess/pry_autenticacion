import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'welcome_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authService, child) {
        if (authService.isLoggedIn) {
          return WelcomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
