import 'package:flutter/material.dart';
import 'package:ping/core/supabase_init.dart';
import 'package:ping/screens/login_screen.dart';
import 'package:ping/screens/profile_screen.dart';
import 'package:ping/screens/signup_screen.dart';
import 'package:ping/screens/reset_password_screen.dart';
import 'package:ping/screens/new_password_screen.dart';
import 'package:ping/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Ping",
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          /*'/signup': (context) => SignupScreen(),*/
          '/reset-password': (context) => ResetPasswordScreen(),
          '/new-password': (context) => NewPasswordScreen(),
          '/home': (context) => HomeScreen(),
          '/profile': (context) => ProfileScreen(),
          //'/scan': (context) => const ScanScreen(),
          //'/presences': (context) => const PresencesScreen(),
        },
        );
  }
}
