import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sangu/ui/app/profile.dart';

import '../widgets/bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    return Container(
      child: Center(
        child: Text(user?.email??"tes")
      ),
    );
  }
}


