import 'package:flutter/material.dart';
import 'package:ping/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://xvkenqfcdmhlvfxkzqwe.supabase.co",
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2a2VucWZjZG1obHZmeGt6cXdlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc3NDU0MjQsImV4cCI6MjA2MzMyMTQyNH0.d9tEQGgq8a3cDuUqlHJfHw0EGyu6klKg6QArjmxqqdg',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ping', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('Bienvenu sur Ping\nune application pour marquer la presence dans les !'),
      ),
    );
  }
}
