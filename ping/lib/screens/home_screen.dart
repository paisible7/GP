import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ping/providers/navigation_provider.dart';
import 'package:ping/providers/user_provider.dart';
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
  List<Widget>? _pages;
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
    // Pour les professeurs et étudiants, on utilise la page d'accueil
    userProvider.userRole == 'admin' ?
    (_pages = [
      const AdminDashboard(),
    ]):
    (  _pages = [
    const _HomePage(),
    const ProfileScreen(showBottomNav: false),
    ]);

  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Vérifier si les pages doivent être mises à jour
    if (_pages == null || 
        (userProvider.userRole == 'admin' && _pages![0] is! AdminDashboard) ||
        ((userProvider.userRole == 'professeur' || userProvider.userRole == 'etudiant') && _pages![0] is! _HomePage)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _initializePages();
            _navigationProvider.setIndex(0);
          });
        }
      });
    }

    if (_pages == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: navigationProvider.currentIndex,
        children: _pages!,
      ),
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
        toolbarHeight: 100.0,
        //title: Text(userProvider.userRole == 'professeur' ? 'Accueil Professeur' : 'Accueil Étudiant'),
        title: Text('Accueil', style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // TODO: Implémenter les notifications
            },
          ),
          Container(

            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profil');
              },
              icon: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],

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
          userProvider.userRole == 'professeur'
              ? Navigator.push(context, MaterialPageRoute(builder: (context) => const GenerateQRScreen()),)
              : Navigator.push(context, MaterialPageRoute(builder: (context) => const QRScannerScreen()),);
        },
        icon: Icon(
          (userProvider.userRole == 'professeur' ? Icons.qr_code : Icons.qr_code_scanner),
          color: Colors.white,
        ),
        label: Text(
            (userProvider.userRole == 'professeur' ? 'Générer QR' : 'Scanner QR'),
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.primary,
      ),
    );
  }
}
