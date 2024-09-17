import 'package:flutter/material.dart';
import 'package:projeto_cloud/login_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Site',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xfff9a72d)),
        useMaterial3: true,
      ),
      home: const LoginPageCreateState(),
    );
  }
}
