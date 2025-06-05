import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ping/providers/navigation_provider.dart';
import 'package:ping/providers/user_provider.dart';
import 'package:ping/screens/login_screen.dart';
import 'package:ping/screens/home_screen.dart';
import 'core/supabase_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()..initializeUser()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ping',
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    if (userProvider.isLoggedIn) {
      return const HomeScreen();
    }
    return LoginScreen();
  }
}
