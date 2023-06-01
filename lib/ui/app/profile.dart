import 'package:flutter/material.dart';
import 'package:sangu/ui/widgets/bottom_navigation_bar.dart';

import 'home.dart';

class ProfilePage extends StatefulWidget {

  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text("Profile"),
      ),
    );
  }
}
