import 'package:flutter/material.dart';
import 'package:sangu/ui/widgets/bottom_navigation_bar.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/app/profile';

  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Profile Page'),
      ),
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
