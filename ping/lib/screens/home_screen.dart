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
  late final NavigationProvider _navigationProvider;

  @override
  void initState() {
    super.initState();
    _navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    _initializePages();
    _navigationProvider.setIndex(0);
  }

  void _initializePages() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.userRole == 'admin') {
      _pages = [
        const AdminDashboard(),
        const ProfileScreen(showBottomNav: false),
      ];
    } else {
      // Pour les professeurs et étudiants, on utilise la page d'accueil
      _pages = [
        const _HomePage(),
        const ProfileScreen(showBottomNav: false),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.userRole == 'admin' && _pages[0] is! AdminDashboard ||
        (userProvider.userRole == 'professeur' || userProvider.userRole == 'etudiant') && _pages[0] is! _HomePage) {
      _initializePages();
      _navigationProvider.setIndex(0);
    }

    return Scaffold(
      body: IndexedStack(
        index: navigationProvider.currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(userProvider.userRole == 'professeur' ? 'Accueil Professeur' : 'Accueil Étudiant'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenue ${userProvider.userName}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text(
              userProvider.userRole == 'professeur' 
                ? 'Utilisez le bouton ci-dessous pour générer un QR code'
                : 'Utilisez le bouton ci-dessous pour scanner un QR code',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (userProvider.userRole == 'professeur') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GenerateQRScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRScannerScreen()),
            );
          }
        },
        icon: Icon(
          userProvider.userRole == 'professeur' ? Icons.qr_code : Icons.qr_code_scanner,
        ),
        label: Text(
          userProvider.userRole == 'professeur' ? 'Générer QR' : 'Scanner QR',
        ),
      ),
    );
  }
}
