import 'package:flutter/material.dart';
import 'package:cheers_travel_app/screens/home_screen.dart';
import 'package:cheers_travel_app/theme/app_theme.dart';

void main() {
  runApp(const CheersTravelApp());
}

class CheersTravelApp extends StatelessWidget {
  const CheersTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cheers Travel',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
