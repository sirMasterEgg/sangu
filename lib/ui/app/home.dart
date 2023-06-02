import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sangu/ui/widgets/home_card.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeCard(
              title: "I'm owed!",
              value: 10000000,
              warna: Theme.of(context).colorScheme.secondary,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                HomeCard(
                  title: "My costs",
                  value: 35000000,
                  warna: Theme.of(context).colorScheme.onSecondary,
                ),
                HomeCard(
                  title: "Total costs",
                  value: -25000000,
                  warna: Colors.white,
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}


