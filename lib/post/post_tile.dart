import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

bool isDarkTheme = false;

class PostTile extends StatefulWidget {
  final Map<String, dynamic> postMap;

  const PostTile({Key? key, required this.postMap}) : super(key: key);

  @override
  PostTileState createState() => PostTileState();
}

class PostTileState extends State<PostTile> {
  String userName = 'अनामिक';
  String userProfileImageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    String uid = widget.postMap["uid"];
    try {
      DocumentSnapshot docSnapshot =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (docSnapshot.exists) {
        Map<String, dynamic> userData =
            docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          userName = userData['name'] ?? 'अनामिक';
          userProfileImageUrl = userData['profileImage'] ?? '';
        });
      }
    } catch (error) {
      log("Error fetching user data: $error");
    }
  }

  String getTimeDifferenceInMarathi(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) {
      return 'आत्ता';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} मिनिटांपूर्वी';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} तासांपूर्वी';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} दिवसांपूर्वी';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} आठवड्यांपूर्वी';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()} महिन्यांपूर्वी';
    } else {
      return '${(diff.inDays / 365).floor()} वर्षांपूर्वी';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    isDarkTheme = theme.brightness == Brightness.dark;

    final Timestamp time = widget.postMap["time"] ?? Timestamp.now();
    final String content = widget.postMap["content"] ?? '';
    final String? mediaUrl = widget.postMap["mediaUrl"];

    final DateTime postDateTime = time.toDate();

    final String timeAgo = getTimeDifferenceInMarathi(postDateTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: widget.postMap['shreni'] == 'उच्च'
          ? const Color.fromARGB(167, 128, 128, 128)
          : isDarkTheme
              ? Colors.white
              : Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), 
      ),
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: userProfileImageUrl.isNotEmpty
                      ? NetworkImage(userProfileImageUrl)
                      : const AssetImage('assets/images/profile.jpg')
                          as ImageProvider<Object>?,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkTheme ? Colors.black : Colors.white),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                          color: isDarkTheme ? Colors.black : Colors.white,
                          fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style:
                  TextStyle(color: isDarkTheme ? Colors.black : Colors.white),
            ),
            if (mediaUrl != null && mediaUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              Image.network(mediaUrl),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text("अपवोट करा",
                      style: TextStyle(color: Colors.green)),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("विरुद्ध मत द्या",
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
