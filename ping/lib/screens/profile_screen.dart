import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widget/custom_bottom_navigation_bar.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final res = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return res;
  }

  void confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Se déconnecter ?"),
        content: Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
        actions: [
          TextButton(
            child: Text("Annuler"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Se déconnecter"),
            onPressed: () {
              Navigator.pop(context);
              logout();
            },
          ),
        ],
      ),
    );
  }


  void logout() async {
    await Supabase.instance.client.auth.signOut();
    // Rediriger vers la page de login
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CustomBottomNavigationBar(
      currentIndex: 3,
    ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data;

          if (userData == null) {
            return Center(child: Text('Erreur de chargement du profil'));
          }

          return ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 36),

            children: [
              SizedBox(height: 16),
              // section 1 - profile
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20,),
                  ClipOval(

                    child: Container(
                      width: 124,
                      height: 124,
                      color: Colors.blue,
                      child: Image.network(
                        (userData["avatar"] == null || userData['avatar'] == "")
                            ? "https://ui-avatars.com/api/?name=${userData['nom_complet']}"
                            : userData['avatar'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16, bottom: 4),
                    child: Text(
                      userData["nom_complet"] ?? "",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    userData["role"] ?? "",
                    style: TextStyle(color: AppColor.primary),
                  ),
                ],
              ),
              SizedBox(height: 15,),
              // section 2 - menu
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 42),
                child: Column(
                  children: [
                    MenuTile(
                      title: 'Metttre à jour le profil',
                      icon: Icon(Icons.person),
                      onTap: () =>         Navigator.pushNamed(context, '/home')
                    ),
                    if (userData["role"] == "admin")
                      MenuTile(
                        title: 'Ajouter un cours',
                        icon: Icon(Icons.people),
                        onTap: (){}/*Navigator.pushReplacementNamed(context, '/home');*/
                        ,
                      ),
                    MenuTile(
                      title: 'Changer le mot de passe',
                      icon: Icon(Icons.password),
                      onTap: () =>  Navigator.pushNamed(context, '/change_password')
                      ,
                    ),

                    MenuTile(
                        title: 'Se déconnecter',
                        icon: Icon(Icons.logout),
                        onTap: confirmLogout,
                        titleStyle: TextStyle(color: Colors.red)
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey[200],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final String title;
  final Widget icon;
  final void Function() onTap;
  final TextStyle? titleStyle;

  const MenuTile({
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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              margin: EdgeInsets.only(right: 24),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.primarySoft,
                borderRadius: BorderRadius.circular(100),
              ),
              child: icon,
            ),
            Expanded(
              child: Text(
                title,
                style: titleStyle ?? TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 24),
              ),

          ],
        ),
      ),
    );
  }
}
