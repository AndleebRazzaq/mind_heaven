import 'package:flutter/material.dart';

import '../../../screens/auth_screen.dart';

class AuthFlowPage extends StatelessWidget {
  final bool initialLogin;

  const AuthFlowPage({super.key, required this.initialLogin});

  @override
  Widget build(BuildContext context) => AuthScreen(initialLogin: initialLogin);
}
