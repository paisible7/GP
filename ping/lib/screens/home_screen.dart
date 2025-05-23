import 'package:flutter/material.dart';
import '../widget/custom_bottom_navigation_bar.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Home Screen"),
      ),
      bottomNavigationBar:  CustomBottomNavigationBar(currentIndex: 0),
    );
  }

}
