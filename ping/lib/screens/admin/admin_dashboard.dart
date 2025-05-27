import 'package:flutter/material.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:ping/screens/admin/manage_professors_screen.dart';
import 'package:ping/screens/admin/manage_rooms_screen.dart';
import 'package:ping/screens/admin/manage_courses_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord administrateur'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildMenuCard(
            context,
            'Gérer les professeurs',
            Icons.people,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManageProfessorsScreen()),
            ),
          ),
          _buildMenuCard(
            context,
            'Gérer les salles',
            Icons.class_,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManageRoomsScreen()),
            ),
          ),
          _buildMenuCard(
            context,
            'Gérer les cours',
            Icons.school,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManageCoursesScreen()),
            ),
          ),
          _buildMenuCard(
            context,
            'Statistiques',
            Icons.bar_chart,
            () {
              // TODO: Implémenter l'écran des statistiques
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColor.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 