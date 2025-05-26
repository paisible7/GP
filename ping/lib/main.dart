import 'package:flutter/material.dart';
import 'package:ping/core/supabase_init.dart';
import 'package:ping/providers/user_provider.dart';
import 'package:ping/providers/navigation_provider.dart';
import 'package:ping/screens/login_screen.dart';
import 'package:ping/screens/profile_screen.dart';
import 'package:ping/screens/scan_screen.dart';
import 'package:ping/screens/reset_password_screen.dart';
import 'package:ping/screens/new_password_screen.dart';
import 'package:ping/screens/home_screen.dart';
import 'package:provider/provider.dart';

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
        ChangeNotifierProvider(
          create: (context) {
            final provider = UserProvider();
            // Initialiser l'état de l'utilisateur au démarrage
            provider.initialize();
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Ping",
            // Rediriger vers la page d'accueil si l'utilisateur est connecté
            initialRoute: userProvider.isLoggedIn ? '/home' : '/login',
            routes: {
              '/login': (context) => LoginScreen(),
              '/reset-password': (context) => ResetPasswordScreen(),
              '/new-password': (context) => NewPasswordScreen(),
              '/home': (context) => HomeScreen(),
              '/profile': (context) => ProfileScreen(),
              '/scan': (context) => QRScannerScreen(),
            },
          );
        },
      ),
    );
  }
}
