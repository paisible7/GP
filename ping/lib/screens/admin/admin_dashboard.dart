import 'package:flutter/material.dart';
import 'package:ping/providers/navigation_provider.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:ping/screens/admin/manage_professors_screen.dart';
import 'package:ping/screens/admin/manage_rooms_screen.dart';
import 'package:ping/screens/admin/manage_courses_screen.dart';
import 'package:ping/screens/admin/manage_students_screen.dart';
import 'package:ping/widgets/admin_sidebar.dart';
import 'package:ping/responsive.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;

  Widget _getScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const ManageProfessorsScreen();
      case 2:
        return const ManageStudentsScreen();
      case 3:
        return const ManageRoomsScreen();
      case 4:
        return _buildCoursesScreen('L1');
      case 5:
        return _buildCoursesScreen('L2');
      case 6:
        return _buildCoursesScreen('L3');
      case 7:
        return _buildCoursesScreen('L4');
      case 8:
        return _buildStatsPlaceholder();
      case 9:
        return _buildSettingsPlaceholder();
      default:
        return _buildDashboard();
    }
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Tableau de Bord';
      case 1:
        return 'Gérer les Professeurs';
      case 2:
        return 'Gérer les Étudiants';
      case 3:
        return 'Gérer les Salles';
      case 4:
        return 'Cours - L1';
      case 5:
        return 'Cours - L2';
      case 6:
        return 'Cours - L3';
      case 7:
        return 'Cours - L4';
      case 8:
        return 'Statistiques';
      case 9:
        return 'Paramètres';
      default:
        return 'Tableau de Bord';
    }
  }

  Widget _buildCoursesScreen(String level) {
    List<String> filieres = [];
    if (level == 'L3' || level == 'L4') {
      filieres = ['GL', 'MSI', 'DSG', 'TLC', 'AS'];
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestion des Cours - $level',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'poppins',
            ),
          ),
          const SizedBox(height: 24),
          if (filieres.isNotEmpty) ...[
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: filieres.map((filiere) {
                return _buildFiliereCard(level, filiere);
              }).toList(),
            ),
          ] else ...[
            Expanded(
              child: ManageCoursesScreen(level: level),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFiliereCard(String level, String filiere) {
    return Card(
      elevation: 4,
      shadowColor: AppColor.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Naviguer vers la gestion des cours de la filière
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.primary.withOpacity(0.1),
                AppColor.primary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school,
                  color: AppColor.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                filiere,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                  fontFamily: 'poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$level - $filiere',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Container(
      padding: EdgeInsets.all(Responsive.isDesktop(context) ? 24 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[50]!,
            Colors.grey[100]!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tableau de Bord',
            style: TextStyle(
              fontSize: Responsive.isDesktop(context) ? 28 : 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'poppins',
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: Responsive.isDesktop(context) ? 4 : 2,
              mainAxisSpacing: Responsive.isDesktop(context) ? 24 : 16,
              crossAxisSpacing: Responsive.isDesktop(context) ? 24 : 16,
              childAspectRatio: Responsive.isDesktop(context) ? 1.5 : 1.3,
              padding: EdgeInsets.zero,
              children: [
                _buildStatCard(
                  'Total Étudiants',
                  '250',
                  Icons.school,
                  AppColor.primary,
                ),
                _buildStatCard(
                  'Total Professeurs',
                  '25',
                  Icons.people,
                  AppColor.secondary,
                ),
                _buildStatCard(
                  'Total Cours',
                  '45',
                  Icons.book,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Total Salles',
                  '15',
                  Icons.class_,
                  Colors.purple,
                ),
                _buildStatCard(
                  'Cours Aujourd\'hui',
                  '12',
                  Icons.calendar_today,
                  Colors.teal,
                ),
                _buildStatCard(
                  'Présences',
                  '85%',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  'Étudiants L1',
                  '80',
                  Icons.grade,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Étudiants L2',
                  '65',
                  Icons.grade,
                  Colors.indigo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(Responsive.isDesktop(context) ? 16 : 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(Responsive.isDesktop(context) ? 8 : 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: Responsive.isDesktop(context) ? 24 : 20,
                  ),
                ),
                Icon(
                  Icons.more_vert,
                  color: Colors.grey[600],
                  size: Responsive.isDesktop(context) ? 20 : 16,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: Responsive.isDesktop(context) ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: Responsive.isDesktop(context) ? 14 : 12,
                color: Colors.grey[600],
                fontFamily: 'poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsPlaceholder() {
    return const Center(
      child: Text(
        'Statistiques à venir',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsPlaceholder() {
    return const Center(
      child: Text(
        'Paramètres à venir',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.white,
            foregroundColor: Colors.white,
            toolbarHeight: 100,
            backgroundColor: AppColor.primary,
            elevation: 0,
            title: Text(
              _getTitle(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'poppins',
              ),
            ),
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
          drawer: Padding(padding: const EdgeInsets.only(top: 50), // Ajuster la position du tiroir
          child : Drawer(
            child: AdminSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
                Navigator.pop(context);
              },
            ),
          )),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[50]!,
                  Colors.grey[100]!,
                ],
              ),
            ),
            child: _getScreen(),
          ),
        ),
        desktop: Row(
          children: [
            Stack(
              children: [
                AdminSidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  isCollapsed: _isSidebarCollapsed,
                ),
                /*Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(-2, 0),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isSidebarCollapsed ? Icons.chevron_right : Icons.chevron_left,
                        color: AppColor.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSidebarCollapsed = !_isSidebarCollapsed;
                        });
                      },
                    ),
                  ),*/
              ],
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[50]!,
                      Colors.grey[100]!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTitle(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'poppins',
                            ),
                          ),
                          const SizedBox(height: 24),
                          Expanded(child: _getScreen()),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications, color: AppColor.primary),
                            onPressed: () {
                              // TODO: Implémenter les notifications
                            },
                          ),
                          const SizedBox(width: 8),
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: IconButton(onPressed: (){
                              Navigator.pushNamed(context, '/profil');
                            }, icon: CircleAvatar(
                              backgroundColor: AppColor.primary.withOpacity(0.1),
                              child: const Icon(
                                Icons.person,
                                color: AppColor.primary,
                              ),
                            ),),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 