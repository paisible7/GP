import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ping/providers/navigation_provider.dart';
import 'package:ping/providers/user_provider.dart';
import 'package:ping/theme/app_theme.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return BottomNavigationBar(
      currentIndex: navigationProvider.currentIndex,
      onTap: (index) => navigationProvider.setIndex(index),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home,
          ),
          label:'Accueil',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      selectedItemColor: AppColor.primary,
      unselectedItemColor: Colors.grey,
    );
  }
} 