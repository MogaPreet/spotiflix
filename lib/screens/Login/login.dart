import 'package:expproj/screens/Login/loginWidget.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';


class LoginPage extends StatelessWidget {
  final Account account;

  const LoginPage({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LoginWidget(
          account: account,
          onLoginSuccess: (session) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login successful! Session ID: ${session.$id}')),
            );
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
    );
  }
}