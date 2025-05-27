import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ping/providers/user_provider.dart';
import 'package:ping/widgets/custom_bottom_navigation_bar.dart';
import '../theme/app_theme.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final bool showBottomNav;

  const ProfileScreen({
    Key? key,
    this.showBottomNav = true,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _getAvatarUrl(String name) {
    // Encoder le nom pour l'URL
    final encodedName = Uri.encodeComponent(name);
    return "https://ui-avatars.com/api/?name=$encodedName&background=random";
  }

  void confirmLogout() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Se déconnecter ?"),
        content: const Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Se déconnecter"),
            onPressed: () async {
              Navigator.pop(context); // Fermer la boîte de dialogue
              
              // Déconnecter l'utilisateur
              await userProvider.signOut();
              
              // Vérifier si le contexte est toujours valide
              if (!context.mounted) return;
              
              // Rediriger vers la page de connexion en supprimant toutes les routes précédentes
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false, // Supprime toutes les routes précédentes
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    // Vérifier si l'utilisateur est connecté
    if (!userProvider.isLoggedIn) {
      // Si l'utilisateur n'est pas connecté, rediriger vers la page de connexion
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userData = {
      'nom_complet': userProvider.userName ?? 'Utilisateur',
      'role': userProvider.userRole ?? 'Non défini',
      'avatar': null,
    };

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: widget.showBottomNav ? const CustomBottomNavigationBar() : null,
      body: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 36),
        children: [
          const SizedBox(height: 16),
          // section 1 - profile
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              ClipOval(
                child: Container(
                  width: 124,
                  height: 124,
                  color: Colors.blue,
                  child: Image.network(
                    _getAvatarUrl(userData['nom_complet'] ?? ''),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // En cas d'erreur, afficher un avatar par défaut
                      return Container(
                        color: AppColor.primarySoft,
                        child: Icon(
                          Icons.person,
                          size: 64,
                          color: AppColor.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 16, bottom: 4),
                child: Text(
                  userData["nom_complet"] ?? "",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                userData["role"] == 'professeur'
                    ? 'Professeur'
                    : userData["role"] == 'etudiant'
                        ? 'Étudiant'
                        : 'Administrateur',
                style: TextStyle(color: AppColor.primary),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // section 2 - menu
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(top: 42),
            child: Column(
              children: [
                MenuTile(
                  title: 'Mettre à jour le profil',
                  icon: const Icon(Icons.person),
                  onTap: () => Navigator.pushNamed(context, '/home'),
                ),
                MenuTile(
                  title: 'Changer le mot de passe',
                  icon: const Icon(Icons.password),
                  onTap: () => Navigator.pushNamed(context, '/change_password'),
                ),
                MenuTile(
                  title: 'Se déconnecter',
                  icon: const Icon(Icons.logout),
                  onTap: confirmLogout,
                  titleStyle: const TextStyle(color: Colors.red),
                ),
                Container(
                  height: 1,
                  color: Colors.grey[200],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback onTap;
  final TextStyle? titleStyle;

  const MenuTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              margin: const EdgeInsets.only(right: 24),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.primarySoft,
                borderRadius: BorderRadius.circular(100),
              ),
              child: icon,
            ),
            Expanded(
              child: Text(
                title,
                style: titleStyle ?? const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 24),
            ),
          ],
        ),
      ),
    );
  }
}
