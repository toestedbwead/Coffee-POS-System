import 'package:flutter/material.dart';
import 'screens/cashier_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Latte - Coffee POS',
      theme: AppTheme.lightTheme,
      home: const CashierScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}