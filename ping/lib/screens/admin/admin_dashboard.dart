import 'package:flutter/material.dart';
import 'package:ping/providers/navigation_provider.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:ping/screens/admin/manage_professors_screen.dart';
import 'package:ping/screens/admin/manage_rooms_screen.dart';
import 'package:ping/screens/admin/manage_courses_screen.dart';
import 'package:ping/screens/admin/manage_students_screen.dart';
import 'package:ping/screens/admin/statistics_screen.dart';
import 'package:ping/widgets/admin_sidebar.dart';
import 'package:ping/responsive.dart';
import 'package:ping/core/data_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  String? _selectedPromotion;
  String? _selectedFiliere;
  bool _isSidebarCollapsed = false;
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await DataService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des statistiques: $e')),
        );
      }
    }
  }

  Widget _getScreen() {
    if (_selectedIndex == 4) {
      // Onglet Cours
      if (_selectedPromotion == null) {
        // Afficher la grille des promotions
        return _buildPromotionsGrid();
      } else if ((_selectedPromotion == 'L3' || _selectedPromotion == 'L4') && _selectedFiliere == null) {
        // Afficher la grille des filières
        return _buildFilieresGrid(_selectedPromotion!);
      } else {
        // Afficher les cours de la promotion/filière
        return Stack(
          children: [
            ManageCoursesScreen(
              level: _selectedPromotion!,
              filiere: _selectedFiliere,
            ),
            Positioned(
              bottom: 32,
              right: 32,
              child: FloatingActionButton(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                onPressed: () {
                  _showAddCourseModal(context);
                },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      }
    }
    // Autres onglets
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const ManageProfessorsScreen();
      case 2:
        return const ManageStudentsScreen();
      case 3:
        return const ManageRoomsScreen();
      case 5:
        return const StatisticsScreen();
      case 6:
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

  Widget _buildPromotionsGrid() {
    final promotions = ['L1', 'L2', 'L3', 'L4'];
    return Center(
      child: Wrap(
        spacing: 32,
        runSpacing: 32,
        children: promotions.map((promo) => GestureDetector(
          onTap: () {
            setState(() {
              _selectedPromotion = promo;
            });
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 180,
              height: 120,
              alignment: Alignment.center,
              child: Text(
                promo,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColor.primary),
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildFilieresGrid(String promotion) {
    final filieres = ['GL', 'MSI', 'DSG', 'TLC', 'AS'];
    return Center(
      child: Wrap(
        spacing: 32,
        runSpacing: 32,
        children: filieres.map((filiere) => GestureDetector(
          onTap: () {
            setState(() {
              _selectedFiliere = filiere;
            });
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 180,
              height: 120,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    filiere,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColor.primary),
                  ),
                  const SizedBox(height: 8),
                  Text('$promotion - $filiere', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  void _showAddCourseModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            width: 500,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ManageCoursesScreen(
                level: _selectedPromotion!,
                filiere: _selectedFiliere,
                modal: true,
              ),
            ),
          ),
        );
      },
    );
  }

  void _resetCoursNavigation() {
    setState(() {
      _selectedPromotion = null;
      _selectedFiliere = null;
    });
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
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: GridView.count(
                crossAxisCount: Responsive.isDesktop(context) ? 5 : 2,
                mainAxisSpacing: Responsive.isDesktop(context) ? 24 : 16,
                crossAxisSpacing: Responsive.isDesktop(context) ? 24 : 16,
                childAspectRatio: Responsive.isDesktop(context) ? 1.3 : 1.2,
                padding: EdgeInsets.zero,
                children: [
                  _buildStatCard(
                    'Total Étudiants',
                    _stats['totalStudents']?.toString() ?? '0',
                    Icons.school,
                    AppColor.primary,
                  ),
                  _buildStatCard(
                    'Total Professeurs',
                    _stats['totalProfessors']?.toString() ?? '0',
                    Icons.people,
                    AppColor.primary,
                  ),
                  _buildStatCard(
                    'Total Cours',
                    _stats['totalCourses']?.toString() ?? '0',
                    Icons.book,
                    AppColor.primary,
                  ),
                  _buildStatCard(
                    'Total Salles',
                    _stats['totalRooms']?.toString() ?? '0',
                    Icons.class_,
                    AppColor.primary,
                  ),
                  _buildStatCard(
                    'Cours Aujourd\'hui',
                    _stats['todaySessions']?.toString() ?? '0',
                    Icons.calendar_today,
                    AppColor.primary,
                  ),
                  _buildStatCard(
                    'Présences',
                    '${_stats['presenceRate']?.toString() ?? '0'}%',
                    Icons.check_circle,
                    AppColor.primary,
                  ),
                  _buildStatCard(
                    'Étudiants L1',
                    _stats['l1Students']?.toString() ?? '0',
                    Icons.grade,
                    AppColor.primary,
                  ),
                  _buildStatCard(
                    'Étudiants L2',
                    _stats['l2Students']?.toString() ?? '0',
                    Icons.grade,
                    AppColor.primary,
                  ),
                  _buildStatCard(
                    'Étudiants L3',
                    _stats['l3Students']?.toString() ?? '0',
                    Icons.grade,
                    AppColor.primary,
                  ),
                  _buildStatCard(
                    'Étudiants L4',
                    _stats['l4Students']?.toString() ?? '0',
                    Icons.grade,
                    AppColor.primary,
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
          drawer: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Drawer(
              child: AdminSidebar(
                selectedIndex: _selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                    if (index == 4) _resetCoursNavigation();
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ),
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
                    setState(() {
                      _selectedIndex = index;
                      if (index == 4) _resetCoursNavigation();
                    });
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