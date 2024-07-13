import 'package:flutter/material.dart';
import 'package:flutter_firebase_demo/pages/home_page.dart';
import 'package:flutter_firebase_demo/pages/messages_page.dart';
import 'package:flutter_firebase_demo/pages/notifications_page.dart';
import 'package:flutter_firebase_demo/pages/profile_page.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserUid; // Assuming you have the current user's uid

  const HomeScreen({Key? key, required this.currentUserUid}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDarkTheme = false;
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'आपले गाव',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkTheme ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: () {
              setState(() {
                _isDarkTheme = !_isDarkTheme;
              });
              final themeMode = Theme.of(context).brightness == Brightness.dark
                  ? AdaptiveThemeMode.light
                  : AdaptiveThemeMode.dark;
              AdaptiveTheme.of(context).setThemeMode(
                themeMode,
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
          const HomePage(),
          const NotificationsPage(),
          const MessagesPage(),
          ProfilePage(uid: widget.currentUserUid),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'गाव',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'सूचना',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'संदेश',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'मी',
          ),
        ],
        currentIndex: _selectedIndex,
        showUnselectedLabels: true,
        selectedFontSize: 20,
        selectedItemColor: const Color.fromARGB(255, 173, 76, 190),
        selectedIconTheme: const IconThemeData(size: 35),
        unselectedFontSize: 18,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
