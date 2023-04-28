import 'dart:async';

import 'package:flutter/material.dart';
import 'home_page_view.dart';
import 'presets_page_view.dart';

class RootPageView extends StatefulWidget {
  const RootPageView({super.key});


  @override
  State<RootPageView> createState() => _RootPageViewState();
}

class _RootPageViewState extends State<RootPageView> {

  int currentPage = 0;
  List<Widget> pages = const[
    HomePageView(),
    PresetsPageView(),
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPage],
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home'
          ),
          NavigationDestination(
            icon: Icon(Icons.storage),
            label: 'Presets',
          )
        ],
        onDestinationSelected: (int index) {
          setState(() {
            currentPage = index;
          });
        },
        selectedIndex: currentPage,
      ),
    );
  }
}