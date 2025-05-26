import 'package:flutter/material.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:ping/widgets/custom_bottom_navigation_bar.dart';
import 'package:ping/screens/admin/manage_professors_screen.dart';
import 'package:ping/screens/admin/manage_students_screen.dart';
import 'package:ping/screens/admin/manage_courses_screen.dart';
import 'package:ping/screens/admin/manage_rooms_screen.dart';
//import 'package:ping/screens/admin/statistics_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: AppColor.primary),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Administrateur'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildMenuCard(
            context: context,
            title: 'Gérer les Professeurs',
            icon: Icons.people,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageProfessorsScreen(),
              ),
            ),
          ),
          _buildMenuCard(
            context: context,
            title: 'Gérer les Étudiants',
            icon: Icons.school,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageStudentsScreen(),
              ),
            ),
          ),
          _buildMenuCard(
            context: context,
            title: 'Gérer les Cours',
            icon: Icons.book,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageCoursesScreen(),
              ),
            ),
          ),
          _buildMenuCard(
            context: context,
            title: 'Gérer les Salles',
            icon: Icons.room,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageRoomsScreen(),
              ),
            ),
          ),
          _buildMenuCard(
            context: context,
            title: 'Statistiques',
            icon: Icons.bar_chart,
            onTap: () {
              // TODO: Implémenter l'écran des statistiques
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité à venir'),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar:  CustomBottomNavigationBar(),
    );
  }
} 