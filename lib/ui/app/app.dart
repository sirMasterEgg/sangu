import 'package:flutter/material.dart';
import 'package:sangu/ui/app/friends.dart';
import 'package:sangu/ui/app/home.dart';
import 'package:sangu/ui/app/profile.dart';

import '../widgets/bottom_navigation_bar.dart';

class AppPage extends StatefulWidget {
  static const routeName = '/app';
  const AppPage({Key? key}) : super(key: key);

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    const HomePage(),
    const FriendsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SANGU"),
      ),
      body:_children[_currentIndex],
      bottomNavigationBar: Builder(builder: (context) {
        return BottomNavBar(currentIndex: _currentIndex, onTap: (index){
          setState(() {
            _currentIndex = index;
          });
        });
      }),
    );
  }
}
