import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class NewPost extends StatefulWidget {
  final String uid;
  const NewPost({Key? key, required this.uid}) : super(key: key);

  @override
  NewPostState createState() => NewPostState();
}

class NewPostState extends State<NewPost> {
  final TextEditingController _controller = TextEditingController();
  File? mediaFile;
  String? mediaUrl;
  String _selectedShreni = 'कमी';

  Future<void> _uploadMedia() async {
    if (mediaFile == null) return;

    try {
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child("postMedia")
          .child(const Uuid().v1())
          .putFile(mediaFile!);

      TaskSnapshot taskSnapshot = await uploadTask;
      mediaUrl = await taskSnapshot.ref.getDownloadURL();
    } catch (error) {
      log("Error uploading media: $error");
    }
  }

  Future<void> _createPost() async {
    String content = _controller.text.trim();
    if (content.isEmpty) return;

    await _uploadMedia();

    Map<String, dynamic> postData = {
      "uid": widget.uid,
      "content": content,
      "mediaUrl": mediaUrl,
      "time": Timestamp.now(),
      "shreni": _selectedShreni,
    };

    try {
      await FirebaseFirestore.instance.collection("posts").add(postData);
      Navigator.pop(context);
    } catch (error) {
      log("Error creating post: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'पोस्ट तयार करा',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'काय चालू आहे?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedShreni,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedShreni = newValue!;
                });
              },
              items: <String>['उच्च', 'कमी'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'श्रेणी निवडा',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                XFile? selectedMedia = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (selectedMedia != null) {
                  setState(() {
                    mediaFile = File(selectedMedia.path);
                  });
                }
              },
              child: const Text('मीडिया संलग्न करा'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createPost,
              child: const Text('झाले'),
            ),
          ],
        ),
      ),
    );
  }
}
