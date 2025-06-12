import 'package:flutter/material.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:ping/screens/admin/manage_professors_screen.dart';
import 'package:ping/screens/admin/manage_rooms_screen.dart';
import 'package:ping/screens/admin/manage_courses_screen.dart';
import 'package:ping/screens/admin/manage_students_screen.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class AdminSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isCollapsed;

  const AdminSidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsed = false,
  }) : super(key: key);

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _widthAnimation = Tween<double>(
      begin: 280,
      end: 80,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Container(
            width: widget.isCollapsed ? 80 : 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColor.primary.withOpacity(0.95),
                  AppColor.primary.withOpacity(0.85),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: widget.isCollapsed ? 16 : 20,
                  ),
                  child: Row(

                    mainAxisAlignment: widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [

                      Container(

                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Image.asset("assets/images/LOGO_UDBL.png", width: 50.0,) ,
                      ),
                      if (!widget.isCollapsed) ...[
                        const SizedBox(width: 16),
                        const Text(
                          'Admin Panel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'poppins',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _buildMenuItem(
                        context,
                        icon: Icons.dashboard,
                        title: 'Dashboard',
                        index: 0,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.people,
                        title: 'Professeurs',
                        index: 1,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.school,
                        title: 'Étudiants',
                        index: 2,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.class_,
                        title: 'Salles',
                        index: 3,
                      ),
                      _buildExpansionTile(
                        context,
                        icon: Icons.book,
                        title: 'Cours',
                        children: [
                          _buildSubMenuItem(context, 'L1', 4),
                          _buildSubMenuItem(context, 'L2', 5),
                          _buildSubMenuItem(context, 'L3', 6),
                          _buildSubMenuItem(context, 'L4', 7),
                        ],
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.bar_chart,
                        title: 'Statistiques',
                        index: 8,
                      ),
                      const Divider(
                        height: 32,
                        color: Colors.white24,
                        thickness: 1,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.settings,
                        title: 'Paramètres',
                        index: 9,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.logout,
                        title: 'Déconnexion',
                        index: 10,
                        isLogout: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
    bool isLogout = false,
  }) {
    final isSelected = widget.selectedIndex == index;
    final color = isSelected ? Colors.white : Colors.white.withOpacity(0.7);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: Colors.white.withOpacity(0.2), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final userProvider = Provider.of<UserProvider>(context, listen: false);

            if (isLogout) {
              // TODO: Implémenter la déconnexion
              await userProvider.signOut();
              return;
            }
            widget.onItemSelected(index);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 12 : 20,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontFamily: 'poppins',
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.white.withOpacity(0.7)),
        title: widget.isCollapsed
            ? const SizedBox.shrink()
            : Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'poppins',
                  letterSpacing: 0.3,
                ),
              ),
        iconColor: Colors.white.withOpacity(0.7),
        collapsedIconColor: Colors.white.withOpacity(0.7),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        childrenPadding: const EdgeInsets.only(left: 16),
        children: children,
      ),
    );
  }

  Widget _buildSubMenuItem(BuildContext context, String title, int index) {
    final isSelected = widget.selectedIndex == index;
    final color = isSelected ? Colors.white : Colors.white.withOpacity(0.7);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: Colors.white.withOpacity(0.2), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onItemSelected(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontFamily: 'poppins',
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 