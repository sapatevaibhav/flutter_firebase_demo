import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_demo/post/post_tile.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
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
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'काय चालू आहे?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("posts").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> postMap =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                        return PostTile(postMap: postMap);
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        "No posts available",
                        // style: TextStyle(color: Colors.black),
                      ),
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
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
        selectedItemColor: _isDarkTheme ? Colors.black : Colors.white,
        unselectedItemColor: _isDarkTheme ? Colors.black54 : Colors.white54,
        showUnselectedLabels: true,
        selectedFontSize: 20,
        unselectedFontSize: 18,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
