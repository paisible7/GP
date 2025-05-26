import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ping/providers/navigation_provider.dart';
import 'package:ping/providers/user_provider.dart';
import 'package:ping/widgets/custom_bottom_navigation_bar.dart';
import 'package:ping/screens/scan_screen.dart';
import 'package:ping/screens/profile_screen.dart';
import 'package:ping/screens/generate_qr_screen.dart';
import 'package:ping/screens/admin/admin_dashboard.dart';
import 'package:ping/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.userRole == 'admin') {
      // Pour les administrateurs, on utilise le tableau de bord admin
      _pages = [
        const AdminDashboard(),
         ProfileScreen(),
      ];
    } else {
      // Pour les professeurs et étudiants
      _pages = [
        Scaffold(
          body: Center(
            child: Text(
              "Écran d'Accueil (${userProvider.userRole == 'professeur' ? 'Professeur' : 'Étudiant'})"
            ),
          ),
        ),
         ProfileScreen(),
      ];
    }
  }

  void _handleActionButton() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);

    if (userProvider.userRole == 'professeur') {
      // Pour les professeurs, naviguer vers l'écran de génération de QR
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GenerateQRScreen()),
      );
    } else if (userProvider.userRole == 'etudiant') {
      // Pour les étudiants, naviguer vers l'écran de scan
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QRScannerScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: IndexedStack(
        index: navigationProvider.currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      floatingActionButton: userProvider.userRole != 'admin' 
          ? FloatingActionButton(
              onPressed: _handleActionButton,
              backgroundColor: AppColor.primary,
              child: Icon(
                userProvider.userRole == 'professeur' 
                    ? Icons.qr_code 
                    : Icons.qr_code_scanner,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
