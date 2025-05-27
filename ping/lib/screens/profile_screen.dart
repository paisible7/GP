import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ping/providers/user_provider.dart';
import 'package:ping/widgets/custom_bottom_navigation_bar.dart';
import '../theme/app_theme.dart';

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
  void confirmLogout() {
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
              Navigator.pop(context);
              await Provider.of<UserProvider>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = {
      'nom_complet': userProvider.userName,
      'role': userProvider.userRole,
      'avatar': null, // Vous pouvez ajouter l'avatar dans le UserProvider si nécessaire
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
                    (userData["avatar"] == null || userData['avatar'] == "")
                        ? "https://ui-avatars.com/api/?name=${userData['nom_complet']}"
                        : userData['avatar']!
                  ,
                    fit: BoxFit.cover,
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
                if (userProvider.isAdmin)
                  MenuTile(
                    title: 'Ajouter un cours',
                    icon: const Icon(Icons.people),
                    onTap: () {},
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
