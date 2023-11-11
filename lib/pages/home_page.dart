import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:untitled2/pages/profile_tab.dart';
import 'package:untitled2/pages/menu_tab.dart';
import 'package:untitled2/pages/messanger_tab.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ProfileTab(),
    MenuTab(),
    MessengerTab()
  ];

  final Map<String, dynamic> _navigationItems = {
    'Profile': Icons.person,
    'Menu': Platform.isIOS ? CupertinoIcons.house_fill : CustomMenuIcon(
      width: 31.0,
      height: 31.0,
      imagePath: 'lib/assets/images/menu.png', // Путь к изображению меню
    ),
    'Messenger': Icons.message,
  };

  void _loadScreen() {
    // Implement loading of the selected screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team IT'),
        backgroundColor: Color(0xFFBE9DE8),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Handle logout action here
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 66,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: Colors.white
          , // Цвет фона
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _navigationItems.entries.map<Widget>((entry) {
            return Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white, // Цвет фона
              ),
              child: IconButton(
                icon: entry.value is IconData
                    ? Icon(entry.value)
                    : entry.value,
                onPressed: () {
                  setState(() => _currentIndex = _navigationItems.keys.toList().indexOf(entry.key));
                  _loadScreen();
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}




class TabContent extends StatelessWidget {
  final String title;

  TabContent({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Content of $title Tab'),
    );
  }
}

class CustomMenuIcon extends StatelessWidget {
  final double width;
  final double height;
  final String imagePath; // Путь к изображению меню

  CustomMenuIcon({
    required this.width,
    required this.height,
    required this.imagePath, // Добавленный параметр для пути к изображению
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 90,
      height: 35,
      decoration: BoxDecoration(
        color: Color(0xFF9D69DE), // Цвет фона
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Center(
        child: Image.asset(
          imagePath,
          width: width,
          height: height,
          fit: BoxFit.contain, // Используйте BoxFit.contain для вписывания изображения в контейнер
        ),
      ),
    );
  }
}




