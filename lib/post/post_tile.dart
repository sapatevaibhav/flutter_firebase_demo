import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final Map<String, dynamic> postMap;

  const PostTile({Key? key, required this.postMap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(postMap["profileImage"]),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(postMap["name"],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(postMap["time"],
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(postMap["content"]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {},
                    child: const Text("अपवोट करा",
                        style: TextStyle(color: Colors.green))),
                TextButton(
                    onPressed: () {},
                    child: const Text("विरुद्ध मत द्या",
                        style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
