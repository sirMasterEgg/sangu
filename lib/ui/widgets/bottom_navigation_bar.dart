import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final dynamic Function(int) onTap;
  const BottomNavBar({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomNavigationBar(
        iconSize: 30.0,
        selectedColor: Theme.of(context).colorScheme.secondary,
        strokeColor: Theme.of(context).colorScheme.secondary,
        unSelectedColor: Theme.of(context).colorScheme.onSecondary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        items: <CustomNavigationBarItem>[
          CustomNavigationBarItem(icon: const Icon(Icons.home),),
          CustomNavigationBarItem(icon: const Icon(Icons.person_add),),
          CustomNavigationBarItem(icon: const Icon(Icons.settings),),
        ],
        currentIndex: currentIndex,
        onTap: onTap
    );
  }
}
