import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ping/providers/navigation_provider.dart';
import 'package:ping/theme/app_theme.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      currentIndex: navigationProvider.currentIndex,
      onTap: (index) => navigationProvider.setCurrentIndex(index),
      selectedItemColor: AppColor.primary,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }
} 